import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../resources/AppColors.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  TextEditingController controller = TextEditingController();
  String get apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  List<dynamic> places = [];
  bool isLoading = false;
  Timer? _debounce;

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => places = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://places.googleapis.com/v1/places:autocomplete',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'suggestions.placePrediction.text.text,suggestions.placePrediction.placeId',
        },
        body: jsonEncode({
          "input": input,
          "includedRegionCodes": ["IN"],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          places = data["suggestions"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }


  bool _isDetectingLocation = false;
  bool _isAutoDetecting = false;
  String? _detectedLocationName;

  @override
  void initState() {
    super.initState();
    _checkAndAutoDetectLocation();
  }

  Future<void> _checkAndAutoDetectLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (mounted) setState(() => _isAutoDetecting = true);
        final address = await _fetchAddressFromGPS();
        if (mounted && address != null && address.isNotEmpty) {
          setState(() {
            _detectedLocationName = address;
          });
        }
      }
    } catch (e) {
      print('[Location] Auto-detect error: $e');
    } finally {
      if (mounted) setState(() => _isAutoDetecting = false);
    }
  }

  Future<String?> _fetchAddressFromGPS() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      print('[Location] GPS coordinates: ${position.latitude}, ${position.longitude}');

      // 1. Native reverse geocoding via geocoding package
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if ((p.subLocality ?? '').isNotEmpty) parts.add(p.subLocality!);
          if ((p.locality ?? '').isNotEmpty && !parts.contains(p.locality)) {
            parts.add(p.locality!);
          }
          if ((p.administrativeArea ?? '').isNotEmpty &&
              !parts.contains(p.administrativeArea)) {
            parts.add(p.administrativeArea!);
          }
          if ((p.country ?? '').isNotEmpty && !parts.contains(p.country)) {
            parts.add(p.country!);
          }

          if (parts.isNotEmpty) {
            final formatted = parts.join(', ');
            print('[Location] Resolved native address: $formatted');
            return formatted;
          }
        }
      } catch (e) {
        print('[Location] Native geocoding failed: $e');
      }

      // 2. Fallback to Google Geocoding REST API if native fails
      if (apiKey.isNotEmpty && apiKey != 'your_google_places_api_key_here') {
        try {
          final geoRes = await http.get(
            Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey',
            ),
          );
          if (geoRes.statusCode == 200) {
            final data = jsonDecode(geoRes.body);
            if (data['results'] != null &&
                (data['results'] as List).isNotEmpty) {
              final formatted = data['results'][0]['formatted_address'];
              print('[Location] Google geocoding resolved: $formatted');
              return formatted;
            }
          }
        } catch (e) {
          print('[Location] Google geocoding fallback failed: $e');
        }
      }

      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('[Location] Failed to get position: $e');
      return null;
    }
  }

  Future<void> _handleCurrentLocationTap() async {
    if (_isDetectingLocation) return;

    if (_detectedLocationName != null && _detectedLocationName!.isNotEmpty) {
      Navigator.pop(context, _detectedLocationName);
      return;
    }

    setState(() => _isDetectingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable GPS in device settings.'),
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission was denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is permanently denied. Please enable it in App Settings.'),
            ),
          );
        }
        return;
      }

      final address = await _fetchAddressFromGPS();

      if (!mounted) return;

      if (address != null && address.isNotEmpty) {
        setState(() => _detectedLocationName = address);
        Navigator.pop(context, address);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not detect current location address. Please search manually.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error detecting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 🔙 Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Location",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔍 Search Field (MATCHED STYLE)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.softIvory,
                  border: Border.all(color: Colors.black, width: 1.4),
                ),
                child: TextField(
                  controller: controller,
                  cursorColor: AppColors.rusticSunset,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/images/icons/location_icon.svg",
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                      ),
                    ),
                    hintText: "Search location",
                    hintStyle: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      color: Colors.black,
                    ),
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.rusticSunset,
                              ),
                            ),
                          )
                        : controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.clear();
                                    places = [];
                                  });
                                },
                                child: const Icon(Icons.close, size: 18),
                              )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    _debounce = Timer(
                      const Duration(milliseconds: 400),
                      () {
                        searchPlaces(value);
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _handleCurrentLocationTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // 🎯 Icon circle background
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: AppColors.rusticSunset.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: _isDetectingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(9),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.rusticSunset,
                                ),
                              )
                            : const Icon(
                                Icons.navigation,
                                color: AppColors.rusticSunset,
                                size: 18,
                              ),
                      ),

                      const SizedBox(width: 12),

                      // 📍 Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Current location",
                              style: TextStyle(
                                fontFamily: "PoppinsMedium",
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            if (_detectedLocationName != null &&
                                _detectedLocationName!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _detectedLocationName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                            ] else if (_isDetectingLocation || _isAutoDetecting) ...[
                              const SizedBox(height: 2),
                              Text(
                                "Detecting location...",
                                style: TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Divider(
                thickness: 0.6,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            // 📍 Results
            Expanded(
              child: ListView.separated(
                itemCount: places.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                  child: Divider(
                    height: 20,
                    thickness: 0.6,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                itemBuilder: (context, index) {
                  final place = places[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(
                          context, place["placePrediction"]["text"]["text"]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.045,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              place["placePrediction"]["text"]["text"],
                              style: const TextStyle(
                                fontFamily: "PoppinsMedium",
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
