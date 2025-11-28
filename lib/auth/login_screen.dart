import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/api_service/api_service.dart';
import 'package:tms_app/api_service/global/utils.dart';
import 'package:tms_app/api_service/prefs/PreferencesKey.dart';
import 'package:tms_app/api_service/prefs/app_preference.dart';
import 'package:tms_app/api_service/urls.dart';
import 'package:tms_app/dashbard_Screen.dart';

class AimaLoginScreen extends ConsumerStatefulWidget {
  const AimaLoginScreen({super.key});

  @override
  ConsumerState<AimaLoginScreen> createState() => _AimaLoginScreenState();
}

class _AimaLoginScreenState extends ConsumerState<AimaLoginScreen> {
  bool isLoading = false;
  bool _obscure = true; // add this above build()
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // _idController.text = "stall102@gmail.com";
    // _passwordController.text = "stall@102";
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // LOGO
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset("assets/images/tms_logo.png", height: 40),
              ),

              const SizedBox(height: 40),

              // WELCOME BACK
              Text(
                "WELCOME BACK",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              // TITLE
              const Text(
                "Log In to your Account",
                style: TextStyle(
                  color: Color(0xff3B2E8D),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              // ID TextField
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(14),
                    labelText: "Email",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // PASSWORD TextField
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14),
                    labelText: "Password",
                    border: InputBorder.none,

                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      child: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Color(0xff3B2E8D),
                        value: true,
                        onChanged: (v) {},
                      ),
                      const Text("Remember me", style: TextStyle(fontSize: 14)),
                    ],
                  ),

                  // const Text(
                  //   "Forgot Password?",
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Color(0xff3B2E8D),
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 20),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3B2E8D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (_idController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      Utils().showToastMessage(
                        "Please enter email and password",
                      );
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final response = await ApiService()
                          .postRequest(stalLLogin, {
                            "email": _idController.text.trim(),
                            "password": _passwordController.text.trim(),
                          });

                      if (response?.statusCode == 200) {
                        final data = response!.data;

                        Utils().showToastMessage("Login Successful");

                        final stall = data["stall"];

                        // await AppPreference().setBool(PreferencesKey.isLoggedIn, true);

                        // TOKEN Save
                        await AppPreference().setString(
                          PreferencesKey.token,
                          data["token"],
                        );

                        // STALL DETAILS SAVE
                        await AppPreference().setString(
                          PreferencesKey.stall_id,
                          stall["id"].toString(),
                        );
                        await AppPreference().setString(
                          PreferencesKey.stall_no,
                          stall["stall_no"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.stall_name,
                          stall["stall_name"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.business,
                          stall["business"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.stall_user_name,
                          stall["stall_user_name"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.mobile,
                          stall["mobile"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.email,
                          stall["email"] ?? "",
                        );
                        await AppPreference().setString(
                          PreferencesKey.website,
                          stall["website"] ?? "",
                        );
                        // await AppPreference().setString(
                        //     PreferencesKey.created_at, stall["created_at"] ?? "");
                        // await AppPreference().setString(
                        //     PreferencesKey.updated_at, stall["updated_at"] ?? "");

                        // After Login → Move to Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainDashboard(),
                          ),
                        );
                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        Utils().showToastMessage(
                          response?.data['message'] ?? 'Invalid ID or Password',
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      Utils().showToastMessage("Something went wrong!");
                    }
                  },
                  child:
                      isLoading
                          ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const Spacer(),

              // FOOTER
              Center(
                child: Text(
                  "Powered by TechMET IT Solutions",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
