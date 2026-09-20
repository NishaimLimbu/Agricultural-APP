import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'financial_screen.dart';

class FarmScreen extends StatefulWidget {
  final int businessId;

  const FarmScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final farmName = TextEditingController();
  final landArea = TextEditingController();
  final cultivatedArea = TextEditingController();
  final openFieldArea = TextEditingController();
  final tunnelCount = TextEditingController();
  final greenhouseCount = TextEditingController();
  final landOwnerName = TextEditingController();
  final leaseAgreementYears = TextEditingController();

  String landUnit = 'Ropani';

  String landCondition = 'Owner';

  String productionType = 'Conventional';

  String irrigationType = 'Other';

  final api = ApiService();

  bool loading = false;

  Future<void> save() async {
    if (farmName.text.trim().isEmpty) {
      message('Please enter Farm Name.');
      return;
    }

    if (landArea.text.trim().isEmpty) {
      message('Please enter Total Land Area.');
      return;
    }

    if (landCondition == 'Lease') {
      if (landOwnerName.text.trim().isEmpty) {
        message('Please enter Land Owner Name.');
        return;
      }

      if (leaseAgreementYears.text.trim().isEmpty) {
        message('Please enter Lease Agreement Years.');
        return;
      }
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await api.post(
        'farm.php',
        {
          'business_id': widget.businessId,

          'farm_name': farmName.text.trim(),

          'total_land_area':
              double.tryParse(landArea.text.trim()),

          'land_unit': landUnit,

          'cultivated_area':
              double.tryParse(cultivatedArea.text.trim()),

          'open_field_area':
              double.tryParse(openFieldArea.text.trim()),

          'tunnel_count':
              int.tryParse(tunnelCount.text.trim()) ?? 0,

          'greenhouse_count':
              int.tryParse(greenhouseCount.text.trim()) ?? 0,

          'production_type': productionType,

          'irrigation_type': irrigationType,

          'land_condition': landCondition,

          'land_owner_name':
              landCondition == 'Lease'
                  ? landOwnerName.text.trim()
                  : null,

          'lease_agreement_years':
              landCondition == 'Lease'
                  ? int.tryParse(
                      leaseAgreementYears.text.trim(),
                    )
                  : null,
        },
      );

      if (result['success'] == true) {
        if (!mounted) return;

        message('Farm information saved successfully.');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FinancialScreen(
              businessId: widget.businessId,
            ),
          ),
        );
      } else {
        message(
          result['message'] ??
              'Could not save farm information.',
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

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    farmName.dispose();
    landArea.dispose();
    cultivatedArea.dispose();
    openFieldArea.dispose();
    tunnelCount.dispose();
    greenhouseCount.dispose();
    landOwnerName.dispose();
    leaseAgreementYears.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farm Information',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '4. Farm Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Enter your farm and land details.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            field(
              farmName,
              'Farm Name',
            ),

            field(
              landArea,
              'Total Land Area',
              number: true,
            ),

            dropdown(
              'Land Unit',
              landUnit,
              [
                'Ropani',
                'Bigha',
                'Hectare',
                'Acre',
                'Sq Meter',
              ],
              (value) {
                if (value == null) return;

                setState(() {
                  landUnit = value;
                });
              },
            ),

            dropdown(
              'Land Condition',
              landCondition,
              [
                'Owner',
                'Lease',
              ],
              (value) {
                if (value == null) return;

                setState(() {
                  landCondition = value;

                  if (landCondition == 'Owner') {
                    landOwnerName.clear();
                    leaseAgreementYears.clear();
                  }
                });
              },
            ),

            if (landCondition == 'Lease') ...[
              field(
                landOwnerName,
                'Land Owner Name',
              ),

              field(
                leaseAgreementYears,
                'Lease Agreement Years',
                number: true,
              ),
            ],

            field(
              cultivatedArea,
              'Cultivated Area',
              number: true,
            ),

            field(
              openFieldArea,
              'Open Field Area',
              number: true,
            ),

            field(
              tunnelCount,
              'Number of Tunnels',
              number: true,
            ),

            field(
              greenhouseCount,
              'Number of Greenhouses',
              number: true,
            ),

            dropdown(
              'Production Type',
              productionType,
              [
                'Organic',
                'Conventional',
                'Mixed',
              ],
              (value) {
                if (value == null) return;

                setState(() {
                  productionType = value;
                });
              },
            ),

            dropdown(
              'Irrigation Type',
              irrigationType,
              [
                'Rain-fed',
                'Drip',
                'Sprinkler',
                'Canal',
                'Well/Borewell',
                'Other',
              ],
              (value) {
                if (value == null) return;

                setState(() {
                  irrigationType = value;
                });
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : save,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(
                decimal: true,
              )
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
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