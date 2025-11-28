import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tms_app/api_service/prefs/PreferencesKey.dart';
import 'package:tms_app/api_service/prefs/app_preference.dart';
import 'package:tms_app/auth/login_screen.dart';
import 'package:tms_app/dashbard_Screen.dart';

class ExitProfileScreen extends ConsumerStatefulWidget {
  const ExitProfileScreen({super.key});

  @override
  ConsumerState<ExitProfileScreen> createState() => _ExitProfileScreenState();
}
class _ExitProfileScreenState extends ConsumerState<ExitProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // TITLE
              const Text(
                "PROFILE",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4A3090),
                ),
              ),

              const SizedBox(height: 30),

              // PROFILE HEADER
              Row(
                children: [
                  // Rounded Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "13",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A3090),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Store Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A3090),
                        ),
                      ),
                      Text(
                        "Store co-ordinator",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // DETAILS FIELDS
              _title("Store Name"),
              _value("${AppPreference().getString(PreferencesKey.stall_name)}"),

              _title("Store Number"),
              _value("${AppPreference().getString(PreferencesKey.stall_id)}"),

              _title("Store co-ordinator"),
              _value(
                "${AppPreference().getString(PreferencesKey.stall_user_name)}",
              ),

              _title("Shop Category"),
              _value("${AppPreference().getString(PreferencesKey.business)}"),

              // const Spacer(),

              // LOGOUT BUTTON
              Center(
                child: SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3090),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      showLogoutPopup(context, ref);
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  "powered by TechMET IT Solutions",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutPopup(BuildContext context, ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E3FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFF4A3090), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are you sure you want to\nLog Out?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4C7B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        ref.invalidate(userListProvider);

                        AppPreference().clearSharedPreferences();
                        Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const AimaLoginScreen()),
    (route) => false, // remove all screens
  );
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    // NO BUTTON
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E4C7B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Color(0xFF1E4C7B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _value(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4A3090),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Colors.black26),
        ],
      ),
    );
  }
}
