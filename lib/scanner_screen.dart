// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:tms_app/api_service/api_service.dart';
// import 'package:tms_app/api_service/global/utils.dart';
// import 'package:tms_app/api_service/urls.dart';
// import 'package:tms_app/dashbard_Screen.dart';

// class ScannerPage extends ConsumerStatefulWidget {
//   const ScannerPage({super.key});

//   @override
//   ConsumerState<ScannerPage> createState() => _ScannerPageState();
// }

// class _ScannerPageState extends ConsumerState<ScannerPage> {
//   MobileScannerController cameraController = MobileScannerController();
//   bool isDetected = false;
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Camera View
//           MobileScanner(
//             controller: cameraController,
//             fit: BoxFit.cover,
//             onDetect: (scanData)async {
//               if (!isDetected) {
//                 isDetected = true;

//                 final String code = scanData.barcodes.first.rawValue ?? "";
//                 _showResultDialog(code);

//                   setState(() async{
//                       isDetected = true;
//                     });
//                     try {
//                       final response = await ApiService()
//                           .postRequest(scanUser, {
//                             "user_id": code,
//                           });

//                       if (response?.statusCode == 200 
//                           ) {

//                         final data = response!.data;

//                         Utils().showToastMessage("Login Successful");

//                         final stall = data["stall"];

//                         // await AppPreference().setBool(PreferencesKey.isLoggedIn, true);

//                         // TOKEN Save

//                         // await AppPreference().setString(
//                         //     PreferencesKey.created_at, stall["created_at"] ?? "");
//                         // await AppPreference().setString(
//                         //     PreferencesKey.updated_at, stall["updated_at"] ?? "");

//                         // After Login → Move to Dashboard
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const HomePage(),
//                           ),
//                         );
//                           setState(() {
//                       isDetected = false;
//                     });
//                       } else {
//                         Utils().showToastMessage(
//                           response?.data['message'] ?? 'Invalid ID or Password',
//                         );
//                           setState(() {
//                       isDetected = false;
//                     });
//                       }
//                     } catch (e) {
//                       setState(() {
//                       isDetected = false;
//                     });
//                       Utils().showToastMessage("Something went wrong!");
//                     }
//               }
//             },
//           ),

//           // Back Button
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.white,
//                   size: 26,
//                 ),
//               ),
//             ),
//           ),

//           // White Scanner Corners (Top-Left & Top-Right)
//           Positioned(top: 180, left: 40, child: _cornerTopLeft()),
//           Positioned(top: 180, right: 40, child: _cornerTopRight()),

//           // White Scanner Corners (Bottom-Left & Bottom-Right)
//           Positioned(bottom: 220, left: 40, child: _cornerBottomLeft()),
//           Positioned(bottom: 220, right: 40, child: _cornerBottomRight()),

//           // Flash Button
//           Positioned(
//             bottom: 100,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: GestureDetector(
//                 onTap: () {
//                   cameraController.toggleTorch();
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.flashlight_on,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------ SCANNER CORNER UI ------------------

//   Widget _cornerTopLeft() => Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           border: Border(
//             top: BorderSide(color: Colors.white, width: 6),
//             left: BorderSide(color: Colors.white, width: 6),
//           ),
//         ),
//       );

//   Widget _cornerTopRight() => Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           border: Border(
//             top: BorderSide(color: Colors.white, width: 6),
//             right: BorderSide(color: Colors.white, width: 6),
//           ),
//         ),
//       );

//   Widget _cornerBottomLeft() => Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: Colors.white, width: 6),
//             left: BorderSide(color: Colors.white, width: 6),
//           ),
//         ),
//       );

//   Widget _cornerBottomRight() => Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: Colors.white, width: 6),
//             right: BorderSide(color: Colors.white, width: 6),
//           ),
//         ),
//       );

//   // ------------------ RESULT POPUP ------------------

//   void _showResultDialog(String code) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Scan Result"),
//         content: Text(
//           code,
//           style: const TextStyle(fontSize: 18),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               isDetected = false;
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
// }
