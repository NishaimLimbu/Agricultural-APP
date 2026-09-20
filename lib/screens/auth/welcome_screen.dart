import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';


class WelcomeScreen
    extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Container(
                  width: 110,
                  height: 110,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFE8F5E9,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons.agriculture,
                    size: 60,
                    color:
                        Color(0xFF14532D),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                const Text(
                  'MS FLORA ERP',

                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF14532D),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Farm Management System',

                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(),
                        ),
                      );
                    },

                    child:
                        const Text(
                      'Sign In',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },

                    child:
                        const Text(
                      'Create Account',
                    ),
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