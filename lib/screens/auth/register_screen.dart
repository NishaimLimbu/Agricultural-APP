import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import '../../services/session.dart';
import '../setup/business_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final username = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final api = ApiService();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  Future<void> register() async {
    final usernameValue = username.text.trim();
    final mobileValue = mobile.text.trim();
    final emailValue = email.text.trim();
    final passwordValue = password.text;
    final confirmValue = confirmPassword.text;

    // -----------------------------
    // VALIDATION
    // -----------------------------

    if (usernameValue.isEmpty ||
        mobileValue.isEmpty ||
        emailValue.isEmpty ||
        passwordValue.isEmpty ||
        confirmValue.isEmpty) {
      message('Please fill all required fields.');
      return;
    }

    if (mobileValue.length < 7) {
      message('Please enter a valid mobile number.');
      return;
    }

    if (passwordValue.length < 6) {
      message('Password must be at least 6 characters.');
      return;
    }

    if (passwordValue != confirmValue) {
      message('Passwords do not match.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      print('========================================');
      print('REGISTER REQUEST');
      print('Username: $usernameValue');
      print('Mobile: $mobileValue');
      print('Email: $emailValue');
      print('========================================');

      final result = await api.post(
        'register.php',
        {
          'username': usernameValue,
          'mobile_no': mobileValue,
          'email': emailValue,
          'password': passwordValue,
        },
      );

      // IMPORTANT DEBUG OUTPUT
      print('========================================');
      print('REGISTER API RESULT');
      print('Result: $result');
      print('Success: ${result['success']}');
      print('Message: ${result['message']}');
      print('User ID: ${result['user_id']}');
      print('========================================');

      if (result['success'] == true) {
        final dynamic rawUserId = result['user_id'];

        final int? userId = rawUserId is int
            ? rawUserId
            : int.tryParse(
                rawUserId.toString(),
              );

        if (userId == null) {
          print('ERROR: Invalid user ID received.');
          message(
            'Invalid user ID received from server.',
          );
          return;
        }

        await Session.saveUser(
          userId: userId,
        );

        print('Registration successful.');
        print('User ID: $userId');

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BusinessScreen(),
          ),
        );
      } else {
        final serverMessage =
            result['message']?.toString() ??
                'Registration failed.';

        print('REGISTRATION FAILED');
        print('Server message: $serverMessage');

        message(serverMessage);
      }
    } catch (e, stackTrace) {
      print('========================================');
      print('REGISTER ERROR');
      print(e);
      print('STACK TRACE');
      print(stackTrace);
      print('========================================');

      message(
        'Registration error: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    username.dispose();
    mobile.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            field(
              username,
              'Username *',
              Icons.person,
            ),

            field(
              mobile,
              'Mobile Number *',
              Icons.phone,
              type: TextInputType.phone,
              digitsOnly: true,
            ),

            field(
              email,
              'Email *',
              Icons.email,
              type: TextInputType.emailAddress,
            ),

            passwordField(
              password,
              'Password *',
              hidePassword,
              () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
            ),

            passwordField(
              confirmPassword,
              'Re-enter Password *',
              hideConfirmPassword,
              () {
                setState(() {
                  hideConfirmPassword =
                      !hideConfirmPassword;
                });
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    loading ? null : register,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? type,
    bool digitsOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        inputFormatters: digitsOnly
            ? [
                FilteringTextInputFormatter
                    .digitsOnly,
              ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget passwordField(
    TextEditingController controller,
    String label,
    bool hidden,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: hidden,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              hidden
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}

