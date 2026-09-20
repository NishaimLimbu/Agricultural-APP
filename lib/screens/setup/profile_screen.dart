import 'package:flutter/material.dart';

import '../../services/api_service.dart';

import '../home/home_screen.dart';


class ProfileScreen
    extends StatefulWidget {

  final int businessId;

  const ProfileScreen({
    super.key,
    required this.businessId,
  });


  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}


class _ProfileScreenState
    extends State<ProfileScreen> {

  final information =
      TextEditingController();

  final oneWord =
      TextEditingController();

  final aboutUs =
      TextEditingController();

  final notes =
      TextEditingController();


  final api =
      ApiService();

  bool loading = false;


  Future<void> save() async {
    setState(() {
      loading = true;
    });


    try {
      final result =
          await api.post(
        'profile.php',
        {
          'business_id':
              widget.businessId,

          'information':
              information.text.trim(),

          'one_word':
              oneWord.text.trim(),

          'about_us':
              aboutUs.text.trim(),

          'additional_notes':
              notes.text.trim(),
        },
      );


      if (result['success'] == true) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(
            builder: (_) =>
                HomeScreen(
              businessId:
                  widget.businessId,
            ),
          ),

          (route) => false,
        );
      } else {
        message(
          result['message'] ??
              'Could not save profile.',
        );
      }
    } catch (e) {
      message(
        e.toString(),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(text),
      ),
    );
  }


  @override
  void dispose() {
    information.dispose();
    oneWord.dispose();
    aboutUs.dispose();
    notes.dispose();

    super.dispose();
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          'Business Profile',
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const Text(
              '6. Business Profile',

              style:
                  TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            field(
              information,
              'Information',
              lines: 4,
            ),

            field(
              oneWord,
              'One Word',
            ),

            field(
              aboutUs,
              'About Us',
              lines: 5,
            ),

            field(
              notes,
              'Additional Notes',
              lines: 5,
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(
              onPressed:
                  loading
                      ? null
                      : save,

              child:
                  loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Setup',
                        ),
            ),
          ],
        ),
      ),
    );
  }


  Widget field(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child:
          TextField(
        controller:
            controller,

        maxLines:
            lines,

        decoration:
            InputDecoration(
          labelText:
              label,
        ),
      ),
    );
  }
}