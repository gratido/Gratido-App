// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../auth/firebase_auth_service.dart';
import 'package:gratido_sample/features/receiver/receiver_form.dart';
import 'receiver_loginpage.dart';

class ReceiverRegistration extends StatefulWidget {
  const ReceiverRegistration({super.key});

  @override
  State<ReceiverRegistration> createState() => _ReceiverRegistrationState();
}

class _ReceiverRegistrationState extends State<ReceiverRegistration> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController fname = TextEditingController();
  final TextEditingController lname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController cpass = TextEditingController();

  bool _obscurePass = true;
  bool _obscureCpass = true;

  InputDecoration inputStyle(String label, {Widget? suffix}) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    suffixIcon: suffix, // ✅ moved to right side
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 243, 159, 33),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        child: TextField(
                          controller: fname,
                          decoration: inputStyle("Firstname"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: lname,
                        decoration: inputStyle("Lastname"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  decoration: inputStyle(
                    "Email",
                    suffix: const Icon(Icons.email_outlined), // ✅ right side
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pass,
                  obscureText: _obscurePass,
                  decoration: inputStyle(
                    "Password",
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePass = !_obscurePass;
                        });
                      },
                    ), // ✅ right side
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cpass,
                  obscureText: _obscureCpass,
                  decoration: inputStyle(
                    "Confirm Password",
                    suffix: IconButton(
                      icon: Icon(
                        _obscureCpass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCpass = !_obscureCpass;
                        });
                      },
                    ), // ✅ right side
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 243, 159, 33),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (pass.text.trim() != cpass.text.trim()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Passwords do not match"),
                          ),
                        );
                        return;
                      }

                      final user = await _auth.signup(
                        email.text.trim(),
                        pass.text.trim(),
                      );
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReceiverFormPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Signup failed")),
                        );
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReceiverLoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
