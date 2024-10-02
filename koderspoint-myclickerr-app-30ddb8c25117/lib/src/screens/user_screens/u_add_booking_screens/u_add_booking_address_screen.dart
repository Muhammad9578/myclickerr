import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_add_booking_order_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:place_picker/place_picker.dart';

class UserAddBookingAddressScreen extends StatefulWidget {
  static const String route = "userAddBookingAddressScreen";
  final LocationResult locationResult;

  UserAddBookingAddressScreen({Key? key, required this.locationResult})
      : super(key: key);

  @override
  State<UserAddBookingAddressScreen> createState() =>
      _UserAddBookingAddressScreenState();
}

class _UserAddBookingAddressScreenState
    extends State<UserAddBookingAddressScreen> {
  String location = '';
  LatLng? latLng;
  late LocationResult locationResult;
  bool isLoading = false;
  final Completer<GoogleMapController> mapController = Completer();

  // late GoogleMapController _mapController;
  final Set<Marker> markers = Set();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressLane1 = TextEditingController();
  final TextEditingController addressLane2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController pinCode = TextEditingController();

  late UserAddBookingOrderController orderProvider;

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    // _mapController = controller;
    setState(() {});
    moveToCurrentUserLocation();
  }

  void moveToCurrentUserLocation() async {
    moveToLocation(latLng!);
  }

  void moveToLocation(LatLng latLng) {
    print("inside moveToLocation: $latLng");
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15.0)),
      );
    });

    setMarker(latLng);
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();

    setState(() {
      markers.clear();
      markers.add(Marker(
          markerId: MarkerId("selected-location"),
          position: latLng,
          icon: locationMarker!));
    });
  }

  BitmapDescriptor? locationMarker;

  createMarkerIcon() async {
    locationMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "${ImageAsset.CurrentLocationIcon}",
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    createMarkerIcon();
    locationResult = widget.locationResult;
    debugLog(
        "locationResult 1: ${locationResult.name},  ${locationResult.locality}, "
        " ${locationResult.country?.name},  ${locationResult.city?.name}, "
        " ${locationResult.postalCode}, "
        " ${locationResult.administrativeAreaLevel1?.name}, "
        " ${locationResult.administrativeAreaLevel2?.name}, "
        " ${locationResult.subLocalityLevel1?.name}, "
        " ${locationResult.subLocalityLevel1?.name}, "
        " ${locationResult.subLocalityLevel2?.name}, "
        " ${locationResult.placeId} ");

    latLng = locationResult.latLng;

    String? formattedAddress = locationResult.formattedAddress;

    if (formattedAddress != null) {
      print("locationResult 2: ${locationResult}");
      locationController.text = formattedAddress;
      print("formattedAddress: $formattedAddress");
      print("location1: $location");
      location = formattedAddress;
      print("location2: $location");

      if (locationResult.city != null) {
        city.text = locationResult.city!.name ?? '';
        // if (!city.text.isEmpty) {
        //   location = location + city.text + ', ';
        // }
      }
      if (locationResult.country != null) {
        // location =
        //     location + (locationResult.country!.name ?? '');
        country.text = locationResult.country!.name ?? '';
      }
      if (locationResult.administrativeAreaLevel1 != null) {
        // location = location +
        //     (locationResult.administrativeAreaLevel1!.name ??
        //         '');
        state.text = locationResult.administrativeAreaLevel1!.name ?? '';
      }
      pinCode.text = locationResult.postalCode ?? '';
      setState(() {});
    }
  }

  tappedOnGoogleMap(val) async {
    try {
      locationResult = await showPlacePicker(context, displayLocation: latLng);
      debugLog(
          "locationResult 1: ${locationResult.name},  ${locationResult.locality}, "
          " ${locationResult.country?.name},  ${locationResult.city?.name}, "
          " ${locationResult.postalCode}, "
          " ${locationResult.administrativeAreaLevel1?.name}, "
          " ${locationResult.administrativeAreaLevel2?.name}, "
          " ${locationResult.subLocalityLevel1?.name}, "
          " ${locationResult.subLocalityLevel1?.name}, "
          " ${locationResult.subLocalityLevel2?.name}, "
          " ${locationResult.placeId} ");

      latLng = locationResult.latLng;
      String? formattedAddress = locationResult.formattedAddress;
      moveToLocation(latLng!);
      if (formattedAddress != null) {
        print("locationResult 2: ${locationResult}");
        locationController.text = formattedAddress;

        location = formattedAddress + "\u{20B9}";
        if (locationResult.city != null) {
          city.text = locationResult.city!.name ?? '';
          if (!city.text.isEmpty) {
            location = location + city.text + ', ';
          }
        }
        if (locationResult.country != null) {
          location = location + (locationResult.country!.name ?? '');
          country.text = locationResult.country!.name ?? '';
        }
        if (locationResult.administrativeAreaLevel1 != null) {
          location =
              location + (locationResult.administrativeAreaLevel1!.name ?? '');
          state.text = locationResult.administrativeAreaLevel1!.name ?? '';
        }
        setState(() {});
      }
    } catch (e) {
      Toasty.error("Unable to fetch event location. PLease try again.");
      debugLog("Exception occur in getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Booking Location",
        action: [],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                locationMarker == null
                    ? Center(
                        child: CircularProgressIndicator(
                            // color: Color(0xffFF8E3C)
                            ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        margin: const EdgeInsets.only(bottom: 12),
                        // padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(kInputBorderRadius),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset.zero)
                          ],
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: latLng!,
                                    zoom: 15,
                                  ),
                                  minMaxZoomPreference:
                                      MinMaxZoomPreference(0, 16),
                                  // myLocationButtonEnabled: true,
                                  // myLocationEnabled: true,
                                  // buildingsEnabled: false,
                                  onMapCreated: onMapCreated,
                                  //     (controller){
                                  //   setState(() {
                                  //     _mapController = controller;
                                  //   });
                                  // },
                                  compassEnabled: false,
                                  onTap: tappedOnGoogleMap,
                                  markers: markers,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                // PrimaryTextField(
                //   textCapitalization: TextCapitalization.sentences,
                //   labelText: "Location",
                //   'USA, New York',
                //   validator: (value) => value == null || value.isEmpty
                //       ? 'Please enter event location'
                //       : null,
                //   suffixIcon: Icons.location_on,
                //   /*onChange: (value) {
                //     location = value;
                //   },*/
                //   controller: locationController,
                //   readOnly: true,
                //   onTap: () async {
                //     try {
                //        locationResult =
                //       await showPlacePicker(context);
                //       debugLog(
                //           "locationResult 1: ${locationResult.name},  ${locationResult.locality}, "
                //               " ${locationResult.country?.name},  ${locationResult.city?.name}, "
                //               " ${locationResult.postalCode}, "
                //               " ${locationResult.administrativeAreaLevel1?.name}, "
                //               " ${locationResult.administrativeAreaLevel2?.name}, "
                //               " ${locationResult.subLocalityLevel1?.name}, "
                //               " ${locationResult.subLocalityLevel1?.name}, "
                //               " ${locationResult.subLocalityLevel2?.name}, "
                //               " ${locationResult.placeId} ");
                //
                //       latLng = locationResult.latLng;
                //       String? formattedAddress =
                //           locationResult.formattedAddress;
                //
                //       if (formattedAddress != null) {
                //         print("locationResult 2: ${locationResult}");
                //         locationController.text = formattedAddress;
                //
                //         location = formattedAddress + "\u{20B9}";
                //         if (locationResult.city != null) {
                //           city.text = locationResult.city!.name ?? '';
                //           if (!city.text.isEmpty) {
                //             location = location + city.text + ', ';
                //           }
                //         }
                //         if (locationResult.country != null) {
                //           location =
                //               location + (locationResult.country!.name ?? '');
                //           country.text = locationResult.country!.name ?? '';
                //         }
                //         if (locationResult.administrativeAreaLevel1 != null) {
                //           location = location +
                //               (locationResult.administrativeAreaLevel1!.name ??
                //                   '');
                //           state.text =
                //               locationResult.administrativeAreaLevel1!.name ??
                //                   '';
                //         }
                //         setState(() {});
                //       }
                //     } catch (e) {
                //       Toasty.error(
                //           "Unable to fetch event location. PLease try again.");
                //       debugLog("Exception occur in getting location: $e");
                //     }
                //   },
                //
                // ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: addressLane1,
                  labelText: 'Address Lane 1',
                  'Provide address 1',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter address of lane1'
                      : null,
                ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: addressLane2,
                  labelText: 'Address Lane2',
                  'Provide  address 2',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter address of lane2'
                      : null,
                ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: city,
                  labelText: 'City',
                  readOnly: city.text.isEmpty ? false : true,
                  'Provide city name',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter city'
                      : null,
                ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: state,
                  labelText: 'State',
                  readOnly: state.text.isEmpty ? false : true,
                  'Provide state name',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter state'
                      : null,
                ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: country,
                  labelText: 'Country',
                  'Provide country',
                  readOnly: state.text.isEmpty ? false : true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter country'
                      : null,
                ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),
                PrimaryTextField(
                  controller: pinCode,
                  keyboardType: TextInputType.number,
                  labelText: 'Pin Code',
                  'Provide postal code',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter pin code';
                    else if (!value.trim().isValidNumbers()) {
                      return 'Only numbers are allowed';
                    } else if (value.length != 6) {
                      return 'Only six digits are allowed';
                    } else
                      return null;
                  },
                ),
                const SizedBox(
                  height: kDefaultSpace,
                ),

                const SizedBox(
                  height: kDefaultSpace * 2,
                ),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GradientButton(
                        text: 'Add Location',
                        onPress: () async {
                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic> addressDetails = {
                              'longitude': latLng!.longitude,
                              'latitude': latLng!.latitude,
                              'addressLane1': addressLane1.text,
                              'addressLane2': addressLane2.text,
                              'city': city.text,
                              'country': country.text,
                              'pinCode': pinCode.text,
                              'state': state.text,
                              'location': location,
                            };
                            debugLog("addressDetails: $addressDetails");
                            Navigator.pop(context, addressDetails);

                            // Order order = Order(
                            //   userId: loggedInUser!.id,
                            //
                            //   type: selectedEventCategory.name,
                            //   date: date,
                            //   time: time,
                            //   title: title,
                            //
                            //   endDate: endDate,
                            //   endTime: endTime,

                            //   duration: duration,
                            //   paidEquipment: paidEquipments,
                            //   totalAmount: totalAmount,
                            //
                            // );

                            // orderProvider.setNewOrder(order);
                          }
                        }),
                const SizedBox(
                  height: kDefaultSpace * 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
