import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import '../../services/session.dart';
import 'contact_screen.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  // ------------------------------------------------------------
  // TEXT CONTROLLERS
  // ------------------------------------------------------------

  final businessName = TextEditingController();
  final registrationNo = TextEditingController();
  final panNo = TextEditingController();
  final ownerName = TextEditingController();

  // ------------------------------------------------------------
  // API
  // ------------------------------------------------------------

  final api = ApiService();

  bool loading = false;

  // ------------------------------------------------------------
  // BUSINESS TYPE OPTIONS
  // ------------------------------------------------------------

  final List<String> businessTypes = [
    'Farming Production',
    'Processing & Value Addition',
    'Agri-Inputs & Trading',
    'Agri-Services',
    'Mixed Farming',
  ];

  // ------------------------------------------------------------
  // CATEGORY OPTIONS
  // ------------------------------------------------------------

  final List<String> categories = [
    'Mushroom Farming',
    'Vegetable Cultivation',
    'Livestock & Poultry',
    'Floriculture / Nursery',
    'Agri-Inputs & Seeds',
    'Mixed Farming',
  ];

  // ------------------------------------------------------------
  // SELECTED DROPDOWN VALUES
  // ------------------------------------------------------------

  String? selectedBusinessType;
  String? selectedCategory;

  // ------------------------------------------------------------
  // SAVE BUSINESS
  // ------------------------------------------------------------

  Future<void> saveBusiness() async {
    final userId = await Session.getUserId();

    if (userId == null) {
      message('User session not found.');
      return;
    }

    // Business name validation
    if (businessName.text.trim().isEmpty) {
      message('Business/Farm name is required.');
      return;
    }

    // Business type validation
    if (selectedBusinessType == null) {
      message('Please select Business Type.');
      return;
    }

    // Category validation
    if (selectedCategory == null) {
      message('Please select Category.');
      return;
    }

    // PAN validation
    if (panNo.text.isNotEmpty && panNo.text.length != 9) {
      message('PAN No. must contain exactly 9 digits.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await api.post(
        'business.php',
        {
          'user_id': userId,

          'business_name':
              businessName.text.trim(),

          'business_type':
              selectedBusinessType,

          'category':
              selectedCategory,

          'registration_no':
              registrationNo.text.trim(),

          'pan_no':
              panNo.text.trim(),

          'owner_name':
              ownerName.text.trim(),
        },
      );

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (result['success'] == true) {
        final id = result['business_id'] as int;

        await Session.saveBusinessId(id);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContactScreen(
              businessId: id,
            ),
          ),
        );
      }

      // --------------------------------------------------------
      // FAILED
      // --------------------------------------------------------

      else {
        message(
          result['message'] ??
              'Could not save business.',
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
  }

  // ------------------------------------------------------------
  // SHOW MESSAGE
  // ------------------------------------------------------------

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    businessName.dispose();
    registrationNo.dispose();
    panNo.dispose();
    ownerName.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Information',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            // --------------------------------------------------
            // TITLE
            // --------------------------------------------------

            const Text(
              '2. Business Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // BUSINESS / FARM NAME
            // --------------------------------------------------

            field(
              businessName,
              'Farm / Business Name',
            ),

            // --------------------------------------------------
            // BUSINESS TYPE
            // --------------------------------------------------

            dropdownField(
              label: 'Business Type',
              icon: Icons.business,
              value: selectedBusinessType,
              items: businessTypes,
              onChanged: (value) {
                setState(() {
                  selectedBusinessType = value;

                  // Reset category whenever
                  // business type changes.
                  selectedCategory = null;
                });
              },
            ),

            // --------------------------------------------------
            // CATEGORY
            // --------------------------------------------------

            dropdownField(
              label: 'Category',
              icon: Icons.category,
              value: selectedCategory,
              items: categories,
              onChanged: selectedBusinessType == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
            ),

            // --------------------------------------------------
            // REGISTRATION NUMBER
            // --------------------------------------------------

            field(
              registrationNo,
              'Registration No.',
            ),

            // --------------------------------------------------
            // PAN NUMBER
            // --------------------------------------------------

            panField(),

            // --------------------------------------------------
            // OWNER NAME
            // --------------------------------------------------

            field(
              ownerName,
              'Owner Name',
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // SAVE BUTTON
            // --------------------------------------------------

            ElevatedButton(
              onPressed:
                  loading ? null : saveBusiness,

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
                      'Save & Continue',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NORMAL TEXT FIELD
  // ------------------------------------------------------------

  Widget field(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PAN FIELD
  // ------------------------------------------------------------

  Widget panField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(
        controller: panNo,

        // Number keyboard
        keyboardType: TextInputType.number,

        // Maximum 9 characters
        maxLength: 9,

        // Only digits 0-9
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],

        decoration: const InputDecoration(
          labelText: 'PAN No.',
          hintText: 'Enter 9 digit PAN number',
          prefixIcon: Icon(Icons.badge),
          border: OutlineInputBorder(),

          // Hide "0/9" counter
          counterText: '',
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DROPDOWN FIELD
  // ------------------------------------------------------------

  Widget dropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: DropdownButtonFormField<String>(
        value: value,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),

        items: items.map(
          (item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          },
        ).toList(),

        onChanged: onChanged,
      ),
    );
  }
}