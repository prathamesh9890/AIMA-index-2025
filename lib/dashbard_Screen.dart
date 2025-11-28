import 'package:excel/excel.dart' hide Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/api_service/api_service.dart';
import 'package:tms_app/api_service/global/utils.dart';
import 'package:tms_app/api_service/prefs/PreferencesKey.dart';
import 'package:tms_app/api_service/prefs/app_preference.dart';
import 'package:tms_app/api_service/urls.dart';
import 'package:tms_app/model/exit_screen.dart';
import 'package:tms_app/model/user_list_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'model/excel_sheet_model.dart';
import 'package:device_info_plus/device_info_plus.dart';


final deviceInfo = DeviceInfoPlugin();


final selectedDateProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
});

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _index = 0;

  final List<Widget> pages = [
    HomePage(),
    // ScannerPage(),
    Text("data"),
    ExitProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF4A3090),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", 0),

          // Center QR icon → open Scanner Page
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const ScannerPage()),
              // );
            },
            child: _middleNavIcon(),
          ),

          _navItem(Icons.logout, "Exit", 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool selected = _index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),

          // ⭐ bottom indicator bar
          SizedBox(height: 6),
          Container(
            width: 40,
            height: selected ? 3 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _middleNavIcon() {
    bool selected = _index == 1;

    return GestureDetector(
      onTap: () {
        setState(() {
          _index = 1;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),

          // ⭐ indicator
          Container(
            width: 40,
            height: selected ? 3 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

final userListProvider = StateProvider<List<UserListModel>>((ref) => []);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isDetected = false;
  bool isScanning = false;


  // Future<bool> requestStoragePermission() async {
  //   if (await Permission.manageExternalStorage.isGranted) {
  //     return true;
  //   } else {
  //     var status = await Permission.manageExternalStorage.request();
  //
  //     if (status.isGranted) {
  //       return true;
  //     } else {
  //       // 🔥 Android 13/14/15/16 ke liye special settings page open karna padega
  //       bool opened = await openAppSettings();
  //
  //       if (!opened) {
  //         Utils().showToastMessage("Please enable Storage permission manually!");
  //       }
  //       return false;
  //     }
  //   }
  // }


  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      int sdk = androidInfo.version.sdkInt;

      if (sdk <= 29) {
        // Android 10 and below
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        Utils().showToastMessage("Please allow storage access!");
        return false;
      }
      else {
        // Android 11+
        if (await Permission.manageExternalStorage.isGranted) return true;

        var status = await Permission.manageExternalStorage.request();
        if (status.isGranted) return true;

        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<AndroidDeviceInfo> androidInfo() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info;
  }

  Future<void> downloadExcel() async {
    try {
      // 🔥 Step 1: Permission Check
      //  var status = await Permission.storage.request();
      // if (!status.isGranted) {
      //   Utils().showToastMessage("Storage permission required!");
      //   return;
      // }
      bool allowed = await requestStoragePermission();
      if (!allowed) return;

      final selectedDate = ref.read(selectedDateProvider);

      final response = await ApiService().postRequest(
        "http://aimaindex.techmetworks.com/api/stall-user-export-list",
        {
          "stall_id": AppPreference().getString(PreferencesKey.stall_id),
          "date": selectedDate,
        },
      );

      if (response == null) {
        Utils().showToastMessage("No Data Found", bgColor: Colors.red);
        return;
      }

      final data = StallUserExportModel.fromJson(response.data);

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Visitors List'];
      // Set column width (adjust as needed)
      sheetObject.setColWidth(0, 10);  // Sr
      sheetObject.setColWidth(1, 25);  // Name
      sheetObject.setColWidth(2, 20);  // Phone
      sheetObject.setColWidth(3, 30);  // Email
      sheetObject.setColWidth(4, 30);  // Company
      sheetObject.setColWidth(5, 25);  // Scanned At


      sheetObject.appendRow(["Sr", "Name", "Phone", "Email", "Company", "Scanned At"]);

      int index = 1;
      for (var item in data.data) {
        sheetObject.appendRow([
          index++,
          item.user.name,
          item.user.phone,
          item.user.email,
          item.user.compName,
          item.scannedAt,
        ]);
      }

      // 🔥 Step 2: Save in Download Folder (Visible to User)
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory("/storage/emulated/0/Download");
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      String filePath = "${downloadsDir.path}/visitor_list_${selectedDate}.xlsx";

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      Utils().showToastMessage(
          "File Saved: Download Folder\nvisitor_list_${selectedDate}.xlsx",
          bgColor: Colors.green);

      // 🔥 OPTIONAL: Share File Popup Open Automatically
      await Share.shareXFiles([XFile(filePath)], text: "Visitor Excel Export");

    } catch (e) {
      print("Excel Export Error: $e");
      Utils().showToastMessage("Download Failed");
    }
  }




  Future<void> _callNumber(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      Utils().showToastMessage("Unable to launch dialer");
    }
  }

  Future<List<UserListModel>> userListApi(WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider);

    try {
      final response = await ApiService().postRequest(stallUserList, {
        "stall_id": AppPreference().getString(PreferencesKey.stall_id),
        "date": selectedDate,
      });

      if (response != null && response.data['success'] == true) {

        final parsedResponse = StallUserResponse.fromJson(response.data);

        final userList = parsedResponse.paginationData.users;

        ref.read(userListProvider.notifier).state = userList;

        return userList;
      } else {
        //throw Exception(response?.data['message'] ?? "Something went wrong.");
      }

    } catch (e) {
      print("Error fetching user list: $e");
    }

    return [];
  }


  String convertDate(String date) {
    DateTime d = DateTime.parse(date);
    return "${d.day} ${_monthName(d.month)} ${d.year}";
  }

  String _monthName(int month) {
    const m = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return m[month];
  }

  List<String> dateList = [
    "2025-11-25",
    "2025-11-26",
    "2025-11-27",
    "2025-11-28",
    "2025-11-29",
    "2025-11-30",
    "2025-12-01",
  ];

  @override
  void initState() {
    userListApi(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(userListProvider);
    final size = MediaQuery.of(context).size;

    // COLUMN WIDTHS
    const double colSr = 60;
    const double colName = 160;
    const double colPhone = 140;
    const double colEmail = 200;
    const double colTime = 120;

    // TOTAL TABLE WIDTH = AUTO CALCULATED
    double tableWidth =
        colSr + colName + colPhone + colEmail + colTime;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopHeader(size),
          SizedBox(height: 10),
          _scannerBox(),
          SizedBox(height: 10),
          _dateCountRow(),
          SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,     // << AUTO RESPONSIVE WIDTH
                child: Column(
                  children: [
                    _buildTableHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 40),
                        itemCount: userList.length,
                        itemBuilder: (_, i) =>
                            _buildTableRow(i + 1, userList[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Map<String, String> _parseNormalQR(String raw) {
    List<String> lines = raw.split("\n");

    String id = "";
    String name = "";

    for (String line in lines) {
      line = line.trim();

      if (line.startsWith("ID:")) {
        id = line.replaceAll("ID:", "").trim();
      }

      if (line.startsWith("Name:")) {
        name = line.replaceAll("Name:", "").trim();
      }
    }

    return {"id": id, "name": name};
  }

  // ------------------- SCANNER UI -------------------
  Widget _scannerBox() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (barcode) async {
              final raw = barcode.barcodes.first.rawValue ?? "";
              if (raw.isEmpty) return;

              if (isScanning) return;   // BLOCK MULTIPLE SCANS

              isScanning = true;
              print("SCANNED → $raw");

              // Smooth slow-down
              await Future.delayed(Duration(milliseconds: 500));

              final parsed = _parseNormalQR(raw);
              final userId = parsed["id"] ?? "";

              await _handleScan(userId);

              // lock scanning for 2 seconds
              await Future.delayed(Duration(seconds: 2));

              isScanning = false;
            },

          ),

          // Corner Design
          Positioned(top: 20, left: 20, child: _cornerTL()),
          Positioned(top: 20, right: 20, child: _cornerTR()),
          Positioned(bottom: 20, left: 20, child: _cornerBL()),
          Positioned(bottom: 20, right: 20, child: _cornerBR()),

          // Flash Button
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.flashlight_on, color: Colors.white),
                onPressed: () => cameraController.toggleTorch(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(String userId) async {
    // Utils().showToastMessage("Scanned: $userId");

    try {
      final response = await ApiService().postRequest(scanUser, {
        "user_id": userId,
      });

      if (response?.statusCode == 200) {
        Utils().showToastMessage("Scan Successful",bgColor: Colors.green);
        userListApi(ref);
      } else {
        //  Utils().showToastMessage(response?.data['message'] ?? "",bgColor: Colors.red,textColor: Colors.white);
      }
    } catch (e) {
      Utils().showToastMessage("Something went wrong");
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => isDetected = false);
    });
  }

  Widget _cornerTL() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      border: Border(
        top: const BorderSide(color: Colors.white, width: 3),
        left: const BorderSide(color: Colors.white, width: 3),
      ),
    ),
  );

  Widget _cornerTR() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      border: Border(
        top: const BorderSide(color: Colors.white, width: 3),
        right: const BorderSide(color: Colors.white, width: 3),
      ),
    ),
  );

  Widget _cornerBL() => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.white, width: 3),
        left: BorderSide(color: Colors.white, width: 3),
      ),
    ),
  );

  Widget _cornerBR() => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.white, width: 3),
        right: BorderSide(color: Colors.white, width: 3),
      ),
    ),
  );

  // ------------------- HEADER -------------------
  Widget _buildTopHeader(Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: size.width,
      decoration: const BoxDecoration(
        color: Color(0xFF4A3090),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _topItem(
                        "Store No : ${AppPreference().getString(PreferencesKey.stall_id).toString()}",
                      ),

                      _topItem(
                        "Store Name : ${AppPreference().getString(PreferencesKey.stall_name).toString()}",
                      ),
                    ],
                  ),

                  Image.asset(
                    "assets/images/tms_logo.png",
                    height: 40,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dateCountRow() {
    final userList = ref.watch(userListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final selectedDate = ref.watch(selectedDateProvider);
              return DropdownButton<String>(
                value: selectedDate,
                icon: const Icon(Icons.calendar_month),
                underline: SizedBox(),
                items: dateList.map((date) {
                  return DropdownMenuItem(
                    value: date,
                    child: Text(
                      convertDate(date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  ref.read(selectedDateProvider.notifier).state = value!;
                  await userListApi(ref);
                },
              );
            },
          ),

          // Text(
          //   "Total Visitors: ${userList.length}",
          //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          // ),
          Row(
            children: [
              Text(
                "Total Visitors: ${userList.length}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15),

              ElevatedButton(
                // onPressed: downloadExcel,
                onPressed: () async {
                  bool allowed = await requestStoragePermission();
                  if (allowed) {
                    downloadExcel();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Download", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          )

        ],
      ),
    );
  }


  Widget _buildTableHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:  [
          _headerCell("Sr.", 60),
          _headerCell("Name", 160),
          _headerCell("Phone", 140),
          _headerCell("Email", 200),
          _headerCell("Co.", 120),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
  // ------------------- TABLE ROW -------------------
  Widget _buildTableRow(int sr, UserListModel user) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _rowCell(sr.toString(), 60),
          // _rowCell(user.user.name, 160),
          _gestureRowCell(user.user.name, 160, user),

          _gesturePhoneCell(user.user.phone, 140),
          _rowCell(user.user.email, 200),
          _rowCell(user.user.compName, 120),
        ],
      ),
    );
  }

  Widget _rowCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(text),
    );
  }

  Widget _gesturePhoneCell(String text, double width) {
    return GestureDetector(
      onTap: () => _callNumber(text),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4A3090),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }


  Widget _gestureRowCell(String text, double width, UserListModel user) {
    return GestureDetector(
      onTap: () => _showUserDetailDialog(user),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
  void _showUserDetailDialog(UserListModel user) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Visitor Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3090),
                  ),
                ),
                const SizedBox(height: 15),

                _detailRow("Name:", user.user.name),
                _detailRow("Phone:", user.user.phone),
                _detailRow("Email:", user.user.email),
                _detailRow("Company:", user.user.compName),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3090),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 👈 radius kam kiya
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )

              ],
            ),
          ),
        );
      },
    );
  }
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }


}

// ----------- TABLE TEXT WIDGETS ----------
class _colHeading extends StatelessWidget {
  final String text;
  const _colHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    );
  }
}

class _colText extends StatelessWidget {
  final String text;
  const _colText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13));
  }
}