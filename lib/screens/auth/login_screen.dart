import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import '../../services/session.dart';

import '../setup/business_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final mobileNo = TextEditingController();
final password = TextEditingController();

final api = ApiService();

bool loading = false;
bool hidePassword = true;

Future<void> login() async {
final mobile = mobileNo.text.trim();
final pass = password.text;

```
if (mobile.isEmpty || pass.isEmpty) {
  message('Enter phone number and password.');
  return;
}

setState(() {
  loading = true;
});

try {
  final result = await api.post(
    'login.php',
    {
      'mobile_no': mobile,
      'password': pass,
    },
  );

  if (result['success'] == true) {
    // --------------------------------------------------
    // USER INFORMATION
    // --------------------------------------------------

    final user = result['user'];

    if (user is! Map) {
      message('Invalid user information received.');
      return;
    }

    final dynamic rawUserId = user['id'];

    final int? userId = rawUserId is int
        ? rawUserId
        : int.tryParse(rawUserId.toString());

    if (userId == null) {
      message('Invalid user ID received from server.');
      return;
    }

    // --------------------------------------------------
    // BUSINESS INFORMATION
    // login.php returns:
    //
    // "business": {
    //     "business_id": 6,
    //     "role": "Admin"
    // }
    // --------------------------------------------------

    final businessData = result['business'];

    int? businessId;

    if (businessData is Map) {
      final dynamic rawBusinessId =
          businessData['business_id'];

      businessId = rawBusinessId is int
          ? rawBusinessId
          : int.tryParse(
              rawBusinessId?.toString() ?? '',
            );
    }

    // --------------------------------------------------
    // SAVE SESSION
    // --------------------------------------------------

    await Session.saveUser(
      userId: userId,
      businessId: businessId,
    );

    if (!mounted) return;

    // --------------------------------------------------
    // NAVIGATION
    // --------------------------------------------------

    if (businessId == null) {
      // New account without business setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BusinessScreen(),
        ),
      );
    } else {
      // Existing account with business
      // Go directly to Dashboard/Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            businessId: businessId!,
          ),
        ),
      );
    }
  } else {
    message(
      result['message']?.toString() ??
          'Login failed.',
    );
  }
} catch (e) {
  message(e.toString());
} finally {
  if (mounted) {
    setState(() {
      loading = false;
    });
  }
}
```

}

void message(String text) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(text),
),
);
}

@override
void dispose() {
mobileNo.dispose();
password.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Sign In'),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,
children: [
const SizedBox(height: 30),

```
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        TextField(
          controller: mobileNo,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: password,
          obscureText: hidePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                hidePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : login,
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
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    ),
  ),
);
```

}
}
