import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../services/address_service.dart';
import 'business_screen.dart';

class AddressContactScreen extends StatefulWidget {

  const AddressContactScreen({
    super.key,
  });

  @override
  State<AddressContactScreen> createState() =>
      _AddressContactScreenState();
}

class _AddressContactScreenState
    extends State<AddressContactScreen> {

  final AddressService addressService =
      AddressService();

  final mobileController =
      TextEditingController();

  final whatsappController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final addressController =
      TextEditingController();


  // ==========================================
  // LOCATION DATA
  // ==========================================

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> municipalities = [];
  List<Map<String, dynamic>> wards = [];


  Map<String, dynamic>? selectedProvince;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedMunicipality;
  Map<String, dynamic>? selectedWard;


  // ==========================================
  // MAP
  // ==========================================

  GoogleMapController? mapController;

  LatLng selectedLocation =
      const LatLng(
        27.7172,
        85.3240,
      );

  Set<Marker> markers = {};


  bool loading = false;
  bool saving = false;


  @override
  void initState() {

    super.initState();

    loadProvinces();

    getCurrentLocation();
  }


  @override
  void dispose() {

    mobileController.dispose();

    whatsappController.dispose();

    emailController.dispose();

    addressController.dispose();

    super.dispose();
  }


  // ==========================================
  // LOAD PROVINCES
  // ==========================================

  Future<void> loadProvinces() async {

    try {

      setState(() {
        loading = true;
      });

      final data =
          await addressService.getProvinces();

      setState(() {

        provinces = data;

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      showError(
        e.toString(),
      );
    }
  }


  // ==========================================
  // LOAD DISTRICTS
  // ==========================================

  Future<void> loadDistricts(
      int provinceId) async {

    try {

      final data =
          await addressService
              .getDistricts(
            provinceId,
          );

      setState(() {

        districts = data;

        selectedDistrict = null;

        selectedMunicipality = null;

        selectedWard = null;

        municipalities = [];

        wards = [];
      });

    } catch (e) {

      showError(
        e.toString(),
      );
    }
  }


  // ==========================================
  // LOAD MUNICIPALITIES
  // ==========================================

  Future<void> loadMunicipalities(
      int districtId) async {

    try {

      final data =
          await addressService
              .getLocalGovernments(
            districtId,
          );

      setState(() {

        municipalities = data;

        selectedMunicipality = null;

        selectedWard = null;

        wards = [];
      });

    } catch (e) {

      showError(
        e.toString(),
      );
    }
  }


  // ==========================================
  // LOAD WARDS
  // ==========================================

  Future<void> loadWards(
      int municipalityId) async {

    try {

      final data =
          await addressService.getWards(
            municipalityId,
          );

      setState(() {

        wards = data;

        selectedWard = null;
      });

    } catch (e) {

      showError(
        e.toString(),
      );
    }
  }


  // ==========================================
  // CURRENT LOCATION
  // ==========================================

  Future<void> getCurrentLocation() async {

    try {

      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }


      LocationPermission permission =
          await Geolocator.checkPermission();


      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }


      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {

        return;
      }


      Position position =
          await Geolocator
              .getCurrentPosition();


      final location = LatLng(
        position.latitude,
        position.longitude,
      );


      setState(() {

        selectedLocation =
            location;

        markers = {

          Marker(
            markerId:
                const MarkerId(
              'selected-location',
            ),

            position:
                location,
          ),
        };
      });


      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          location,
          16,
        ),
      );


      await updateAddress(
        location,
      );

    } catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }


  // ==========================================
  // MAP TAP
  // ==========================================

  Future<void> onMapTapped(
      LatLng location) async {

    setState(() {

      selectedLocation =
          location;

      markers = {

        Marker(
          markerId:
              const MarkerId(
            'selected-location',
          ),

          position:
              location,
        ),
      };
    });


    await updateAddress(
      location,
    );
  }


  // ==========================================
  // REVERSE GEOCODING
  // ==========================================

  Future<void> updateAddress(
      LatLng location) async {

    try {

      final placemarks =
          await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );


      if (placemarks.isEmpty) {
        return;
      }


      final place =
          placemarks.first;


      final address = [

        place.street,

        place.subLocality,

        place.locality,

        place.administrativeArea,

        place.country,

      ]
          .where(
            (value) =>
                value != null &&
                value!
                    .trim()
                    .isNotEmpty,
          )
          .join(', ');


      setState(() {

        addressController.text =
            address;
      });

    } catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }


  // ==========================================
  // SAVE
  // ==========================================

  Future<void> saveAndContinue() async {

    if (selectedProvince == null) {

      showError(
        'Please select Province',
      );

      return;
    }


    if (selectedDistrict == null) {

      showError(
        'Please select District',
      );

      return;
    }


    if (selectedMunicipality == null) {

      showError(
        'Please select Municipality / Rural Municipality',
      );

      return;
    }


    if (selectedWard == null) {

      showError(
        'Please select Ward No.',
      );

      return;
    }


    if (mobileController.text
        .trim()
        .isEmpty) {

      showError(
        'Please enter Mobile Number',
      );

      return;
    }


    try {

      setState(() {
        saving = true;
      });


      // IMPORTANT:
      // Replace this with your actual
      // logged-in user ID from Session.

      final int userId =
          1;


      await addressService
          .saveBusinessContact(

        userId: userId,

        provinceId:
            selectedProvince!['id'],

        districtId:
            selectedDistrict!['id'],

        localGovernmentId:
            selectedMunicipality!['id'],

        wardId:
            selectedWard!['id'],

        selectedAddress:
            addressController.text
                .trim(),

        latitude:
            selectedLocation.latitude,

        longitude:
            selectedLocation.longitude,

        mobileNo:
            mobileController.text
                .trim(),

        whatsappNo:
            whatsappController.text
                .trim(),

        email:
            emailController.text
                .trim(),
      );


      setState(() {
        saving = false;
      });


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Address & Contact saved successfully',
          ),
        ),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const BusinessScreen(),
        ),
      );

    } catch (e) {

      setState(() {
        saving = false;
      });

      showError(
        e.toString(),
      );
    }
  }


  // ==========================================
  // ERROR
  // ==========================================

  void showError(
      String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }


  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Address & Contact',
        ),
      ),

      body: SafeArea(

        child:
            SingleChildScrollView(

          padding:
              const EdgeInsets.all(
            20,
          ),

          child:
              Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              buildLabel(
                'Province',
              ),

              buildDropdown(
                value:
                    selectedProvince,

                items:
                    provinces,

                hint:
                    'Select Province',

                onChanged:
                    (value) {

                  setState(() {

                    selectedProvince =
                        value;
                  });


                  if (value != null) {

                    loadDistricts(
                      value['id'],
                    );
                  }
                },
              ),


              const SizedBox(
                height: 18,
              ),


              buildLabel(
                'District',
              ),


              buildDropdown(
                value:
                    selectedDistrict,

                items:
                    districts,

                hint:
                    'Select District',

                enabled:
                    selectedProvince !=
                        null,

                onChanged:
                    (value) {

                  setState(() {

                    selectedDistrict =
                        value;
                  });


                  if (value != null) {

                    loadMunicipalities(
                      value['id'],
                    );
                  }
                },
              ),


              const SizedBox(
                height: 18,
              ),


              buildLabel(
                'Municipality / Rural Municipality',
              ),


              buildDropdown(
                value:
                    selectedMunicipality,

                items:
                    municipalities,

                hint:
                    'Select Municipality',

                enabled:
                    selectedDistrict !=
                        null,

                onChanged:
                    (value) {

                  setState(() {

                    selectedMunicipality =
                        value;
                  });


                  if (value != null) {

                    loadWards(
                      value['id'],
                    );
                  }
                },
              ),


              const SizedBox(
                height: 18,
              ),


              buildLabel(
                'Ward No.',
              ),


              DropdownButtonFormField<
                  Map<String, dynamic>>(
                value:
                    selectedWard,

                isExpanded:
                    true,

                decoration:
                    inputDecoration(
                  'Select Ward',
                ),

                items:
                    wards.map(
                  (item) {

                    return DropdownMenuItem<
                        Map<String, dynamic>>(
                      value:
                          item,

                      child:
                          Text(
                        'Ward ${item['ward_no']}',
                      ),
                    );
                  },
                ).toList(),

                onChanged:
                    selectedMunicipality ==
                            null
                        ? null
                        : (value) {

                            setState(() {

                              selectedWard =
                                  value;
                            });
                          },
              ),


              const SizedBox(
                height: 22,
              ),


              buildLabel(
                'Location',
              ),


              ClipRRect(

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                child:
                    SizedBox(

                  height: 260,

                  child:
                      GoogleMap(

                    initialCameraPosition:
                        CameraPosition(

                      target:
                          selectedLocation,

                      zoom:
                          14,
                    ),

                    myLocationEnabled:
                        true,

                    myLocationButtonEnabled:
                        true,

                    markers:
                        markers,

                    onMapCreated:
                        (controller) {

                      mapController =
                          controller;
                    },

                    onTap:
                        onMapTapped,
                  ),
                ),
              ),


              const SizedBox(
                height: 22,
              ),


              buildLabel(
                'Selected Address',
              ),


              TextField(

                controller:
                    addressController,

                maxLines:
                    2,

                readOnly:
                    true,

                decoration:
                    inputDecoration(
                  'Selected address',
                ),
              ),


              const SizedBox(
                height: 20,
              ),


              buildLabel(
                'Mobile No.',
              ),


              buildPhoneField(
                mobileController,
              ),


              const SizedBox(
                height: 18,
              ),


              buildLabel(
                'WhatsApp No.',
              ),


              buildPhoneField(
                whatsappController,
              ),


              const SizedBox(
                height: 18,
              ),


              buildLabel(
                'Email',
              ),


              TextField(

                controller:
                    emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration:
                    inputDecoration(
                  'example@email.com',
                ),
              ),


              const SizedBox(
                height: 30,
              ),


              SizedBox(

                width:
                    double.infinity,

                height:
                    52,

                child:
                    ElevatedButton(

                  onPressed:
                      saving
                          ? null
                          : saveAndContinue,

                  child:
                      saving

                          ? const SizedBox(

                              height: 22,

                              width: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )

                          : const Text(
                              'Continue',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ==========================================
  // LABEL
  // ==========================================

  Widget buildLabel(
      String text) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),

      child:
          Text(

        text,

        style:
            const TextStyle(
          fontSize: 14,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }


  // ==========================================
  // DROPDOWN
  // ==========================================

  Widget buildDropdown({

    required Map<String, dynamic>?
        value,

    required List<Map<String, dynamic>>
        items,

    required String hint,

    required ValueChanged<
            Map<String, dynamic>?>
        onChanged,

    bool enabled = true,
  }) {

    return DropdownButtonFormField<
        Map<String, dynamic>>(

      value:
          value,

      isExpanded:
          true,

      decoration:
          inputDecoration(
        hint,
      ),

      items:
          items.map(
        (item) {

          return DropdownMenuItem<
              Map<String, dynamic>>(

            value:
                item,

            child:
                Text(
              item['name']
                  .toString(),

              overflow:
                  TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),

      onChanged:
          enabled
              ? onChanged
              : null,
    );
  }


  // ==========================================
  // PHONE FIELD
  // ==========================================

  Widget buildPhoneField(
      TextEditingController controller) {

    return Row(

      children: [

        Container(

          height: 56,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          decoration:
              BoxDecoration(

            border:
                Border.all(
              color:
                  Colors.grey.shade400,
            ),

            borderRadius:
                const BorderRadius.horizontal(
              left:
                  Radius.circular(10),
            ),
          ),

          child:
              const Row(

            children: [

              Text(
                '🇳🇵',
                style:
                    TextStyle(
                  fontSize:
                      20,
                ),
              ),

              SizedBox(
                width: 5,
              ),

              Text(
                '+977',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),


        Expanded(

          child:
              TextField(

            controller:
                controller,

            keyboardType:
                TextInputType.phone,

            decoration:
                const InputDecoration(

              hintText:
                  '98XXXXXXXX',

              border:
                  OutlineInputBorder(

                borderRadius:
                    BorderRadius.horizontal(
                  right:
                      Radius.circular(
                    10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration inputDecoration(
      String hint) {

    return InputDecoration(

      hintText:
          hint,

      filled:
          true,

      fillColor:
          Colors.white,

      border:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
          10,
        ),

        borderSide:
            BorderSide(
          color:
              Colors.grey.shade400,
        ),
      ),
    );
  }
}