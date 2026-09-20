import 'package:flutter/material.dart';

import '../../services/api_service.dart';

import 'profile_screen.dart';


class FinancialScreen
    extends StatefulWidget {

  final int businessId;

  const FinancialScreen({
    super.key,
    required this.businessId,
  });


  @override
  State<FinancialScreen> createState() =>
      _FinancialScreenState();
}


class _FinancialScreenState
    extends State<FinancialScreen> {

  final fiscalYear =
      TextEditingController();


  String currency = 'NPR';

  String paymentMethod =
      'Cash';


  bool cashEnabled = true;

  bool bankEnabled = true;

  bool qrEnabled = true;

  bool creditEnabled = true;


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
        'financial.php',
        {
          'business_id':
              widget.businessId,

          'fiscal_year':
              fiscalYear.text.trim(),

          'currency':
              currency,

          'default_payment_method':
              paymentMethod,

          'cash_enabled':
              cashEnabled,

          'bank_enabled':
              bankEnabled,

          'qr_enabled':
              qrEnabled,

          'credit_enabled':
              creditEnabled,
        },
      );


      if (result['success'] == true) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProfileScreen(
              businessId:
                  widget.businessId,
            ),
          ),
        );
      } else {
        message(
          result['message'] ??
              'Could not save settings.',
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
    fiscalYear.dispose();

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
          'Financial Setup',
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
              '5. Financial Setup',

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

            TextField(
              controller:
                  fiscalYear,

              decoration:
                  const InputDecoration(
                labelText:
                    'Fiscal Year',
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            dropdown(
              'Currency',
              currency,
              [
                'NPR',
                'USD',
                'INR',
              ],
              (value) {
                setState(() {
                  currency = value!;
                });
              },
            ),

            dropdown(
              'Default Payment Method',
              paymentMethod,
              [
                'Cash',
                'Bank',
                'QR',
                'Credit',
              ],
              (value) {
                setState(() {
                  paymentMethod =
                      value!;
                });
              },
            ),

            SwitchListTile(
              title:
                  const Text(
                'Cash',
              ),

              value:
                  cashEnabled,

              onChanged:
                  (value) {
                setState(() {
                  cashEnabled =
                      value;
                });
              },
            ),

            SwitchListTile(
              title:
                  const Text(
                'Bank',
              ),

              value:
                  bankEnabled,

              onChanged:
                  (value) {
                setState(() {
                  bankEnabled =
                      value;
                });
              },
            ),

            SwitchListTile(
              title:
                  const Text(
                'QR',
              ),

              value:
                  qrEnabled,

              onChanged:
                  (value) {
                setState(() {
                  qrEnabled =
                      value;
                });
              },
            ),

            SwitchListTile(
              title:
                  const Text(
                'Credit',
              ),

              value:
                  creditEnabled,

              onChanged:
                  (value) {
                setState(() {
                  creditEnabled =
                      value;
                });
              },
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
                          'Save & Continue',
                        ),
            ),
          ],
        ),
      ),
    );
  }


  Widget dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?>
        onChanged,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child:
          DropdownButtonFormField<
              String>(
        value:
            value,

        decoration:
            InputDecoration(
          labelText:
              label,
        ),

        items:
            items.map(
          (item) {
            return DropdownMenuItem(
              value: item,
              child:
                  Text(item),
            );
          },
        ).toList(),

        onChanged:
            onChanged,
      ),
    );
  }
}