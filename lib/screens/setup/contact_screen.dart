import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/address_service.dart';
import '../../services/api_service.dart';

import 'farm_screen.dart';

class ContactScreen extends StatefulWidget {
  final int businessId;

  const ContactScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _toleController =
      TextEditingController();

  final TextEditingController _fullAddressController =
      TextEditingController();

  final TextEditingController _mobileController =
      TextEditingController();

  final TextEditingController _whatsappController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _websiteController =
      TextEditingController();

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _localGovernments = [];
  List<Map<String, dynamic>> _wards = [];

  int? _selectedProvinceId;
  int? _selectedDistrictId;
  int? _selectedLocalGovernmentId;
  int? _selectedWardId;

  bool _loadingProvinces = false;
  bool _loadingDistricts = false;
  bool _loadingLocalGovernments = false;
  bool _loadingWards = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _toleController.dispose();
    _fullAddressController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _loadingProvinces = true;
    });

    try {
      final data = await AddressService.getProvinces();

      if (!mounted) return;

      setState(() {
        _provinces = data;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not load provinces.\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingProvinces = false;
      });
    }
  }

  Future<void> _selectProvince(int? provinceId) async {
    if (provinceId == null) return;

    setState(() {
      _selectedProvinceId = provinceId;

      _selectedDistrictId = null;
      _selectedLocalGovernmentId = null;
      _selectedWardId = null;

      _districts = [];
      _localGovernments = [];
      _wards = [];

      _loadingDistricts = true;
    });

    try {
      final data =
          await AddressService.getDistricts(provinceId);

      if (!mounted) return;

      setState(() {
        _districts = data;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not load districts.\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingDistricts = false;
      });
    }
  }

  Future<void> _selectDistrict(int? districtId) async {
    if (districtId == null) return;

    setState(() {
      _selectedDistrictId = districtId;

      _selectedLocalGovernmentId = null;
      _selectedWardId = null;

      _localGovernments = [];
      _wards = [];

      _loadingLocalGovernments = true;
    });

    try {
      final data =
          await AddressService.getLocalGovernments(
        districtId,
      );

      if (!mounted) return;

      setState(() {
        _localGovernments = data;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not load local governments.\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingLocalGovernments = false;
      });
    }
  }

  Future<void> _selectLocalGovernment(
    int? localGovernmentId,
  ) async {
    if (localGovernmentId == null) return;

    setState(() {
      _selectedLocalGovernmentId = localGovernmentId;

      _selectedWardId = null;
      _wards = [];

      _loadingWards = true;
    });

    try {
      final data =
          await AddressService.getWards(
        localGovernmentId,
      );

      if (!mounted) return;

      setState(() {
        _wards = data;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not load wards.\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingWards = false;
      });
    }
  }

  Future<void> _saveContact() async {
    FocusScope.of(context).unfocus();

    if (_selectedProvinceId == null) {
      _showError('Please select a province.');
      return;
    }

    if (_selectedDistrictId == null) {
      _showError('Please select a district.');
      return;
    }

    if (_selectedLocalGovernmentId == null) {
      _showError('Please select a local government.');
      return;
    }

    if (_selectedWardId == null) {
      _showError('Please select a ward.');
      return;
    }

    if (_toleController.text.trim().isEmpty) {
      _showError('Please enter Tole.');
      return;
    }

    if (_fullAddressController.text.trim().isEmpty) {
      _showError('Please enter the full address.');
      return;
    }

    if (_mobileController.text.trim().isEmpty) {
      _showError('Please enter mobile number.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final result = await _apiService.post(
        'contact.php',
        {
          'business_id': widget.businessId,
          'province_id': _selectedProvinceId,
          'district_id': _selectedDistrictId,
          'local_government_id':
              _selectedLocalGovernmentId,
          'ward_id': _selectedWardId,
          'tole': _toleController.text.trim(),
          'full_address':
              _fullAddressController.text.trim(),
          'mobile_no':
              _mobileController.text.trim(),
          'whatsapp_no':
              _whatsappController.text.trim(),
          'email':
              _emailController.text.trim(),
          'website':
              _websiteController.text.trim(),
        },
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FarmScreen(
              businessId: widget.businessId,
            ),
          ),
        );
      } else {
        _showError(
          result['message']?.toString() ??
              'Could not save contact information.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Could not save contact information.\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _provinceName(Map<String, dynamic> item) {
    return item['name']?.toString() ?? '';
  }

  String _districtName(Map<String, dynamic> item) {
    return item['name']?.toString() ?? '';
  }

  String _localGovernmentName(
    Map<String, dynamic> item,
  ) {
    final name = item['name']?.toString() ?? '';
    final type = item['type']?.toString() ?? '';

    if (type.isEmpty) {
      return name;
    }

    return '$name ($type)';
  }

  String _wardName(Map<String, dynamic> item) {
    return 'Ward ${item['ward_no']}';
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required int Function(Map<String, dynamic>) getId,
    required String Function(Map<String, dynamic>) getName,
    required ValueChanged<int?>? onChanged,
    bool enabled = true,
    bool loading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : null,
        ),
        items: items.map((item) {
          final id = getId(item);

          return DropdownMenuItem<int>(
            value: id,
            child: Text(
              getName(item),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: enabled && !loading
            ? onChanged
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address & Contact'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Business Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Select your official administrative address.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Province',
                value: _selectedProvinceId,
                items: _provinces,
                getId: (item) =>
                    int.parse(item['id'].toString()),
                getName: _provinceName,
                onChanged: _selectProvince,
                loading: _loadingProvinces,
              ),

              _buildDropdown(
                label: 'District',
                value: _selectedDistrictId,
                items: _districts,
                getId: (item) =>
                    int.parse(item['id'].toString()),
                getName: _districtName,
                onChanged: _selectedProvinceId == null
                    ? null
                    : _selectDistrict,
                enabled:
                    _selectedProvinceId != null,
                loading: _loadingDistricts,
              ),

              _buildDropdown(
                label: 'Local Government',
                value: _selectedLocalGovernmentId,
                items: _localGovernments,
                getId: (item) =>
                    int.parse(item['id'].toString()),
                getName: _localGovernmentName,
                onChanged:
                    _selectedDistrictId == null
                        ? null
                        : _selectLocalGovernment,
                enabled:
                    _selectedDistrictId != null,
                loading:
                    _loadingLocalGovernments,
              ),

              _buildDropdown(
                label: 'Ward',
                value: _selectedWardId,
                items: _wards,
                getId: (item) =>
                    int.parse(item['id'].toString()),
                getName: _wardName,
                onChanged:
                    _selectedLocalGovernmentId == null
                        ? null
                        : (wardId) {
                            setState(() {
                              _selectedWardId = wardId;
                            });
                          },
                enabled:
                    _selectedLocalGovernmentId !=
                        null,
                loading: _loadingWards,
              ),

              const Divider(height: 32),

              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _toleController,
                label: 'Tole',
                required: true,
              ),

              _buildTextField(
                controller: _fullAddressController,
                label: 'Full Address',
                required: true,
                maxLines: 3,
              ),

              const Divider(height: 32),

              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],
                required: true,
              ),

              _buildTextField(
                controller: _whatsappController,
                label: 'WhatsApp Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType:
                    TextInputType.emailAddress,
              ),

              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                keyboardType:
                    TextInputType.url,
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : _saveContact,
                  child: _saving
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

