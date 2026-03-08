import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/explore_results_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/explore_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTimeSlot;
  final ScrollController _filterScrollController = ScrollController();
  double _leftPadding = 16;
  bool showAllServices = false;

  String _formatDate(DateTime date) {
    return DateFormat("d MMM yy").format(date);
  }

  double maxPrice = 1000; // default
  List<String> selectedVenueTypes = [];
  List<String> selectedSortOptions = [];

  String? currentCity = "";
  double? currentLat;
  double? currentLong;

  @override
  void initState() {
    super.initState();

    // Future.microtask(() {
    //   context.read<ExploreProvider>().fetchServices();
    // });

    _filterScrollController.addListener(() {
      final offset = _filterScrollController.offset;
      setState(() => _leftPadding = offset <= 0 ? 16 : 0);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      currentLat = position.latitude;
      currentLong = position.longitude;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(currentLat!, currentLong!);

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        currentCity = placemarks.first.locality ?? "Unknown";
      }

      setState(() {});
    } catch (_) {
      // silent fail
    }
  }

  Future<void> _selectDate() async {
    DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: AppColors.rusticSunset,
              surface: AppColors.softIvory,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectTimeSlot() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeOption(AppLocalizations.of(context)!.exploreMorning),
              _timeOption(AppLocalizations.of(context)!.exploreAfternoon),
              _timeOption(AppLocalizations.of(context)!.exploreEvening),
            ],
          ),
        );
      },
    );
  }

  Widget _timeOption(String label) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
            fontFamily: "PoppinsMedium", fontSize: 16, color: Colors.black),
      ),
      onTap: () {
        setState(() {
          selectedTimeSlot = label;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final provider = context.watch<ExploreProvider>();

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.03),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: Text(
                  "Search",
                  style: TextStyle(
                    fontFamily: "PlayfairDisplayBold",
                    fontSize: width * 0.065,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: height * 0.012),

              // ----------------------- SEARCH BOX -----------------------
              Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  children: [
                    _buildSearchField(
                      controller: searchController,
                      hint: l10n.exploreSearchHint,
                      svgIcon: "assets/images/icons/search_icon.svg",
                    ),
                    SizedBox(height: height * 0.015),
                    _buildLocationField(),
                    SizedBox(height: height * 0.015),
                    GestureDetector(
                      onTap: _selectDate,
                      child: _buildChip(
                        svgIcon: "assets/images/icons/calendar_icon.svg",
                        label: selectedDate == null
                            ? l10n.exploreAnyDate
                            : _formatDate(selectedDate!),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    GestureDetector(
                      onTap: _selectTimeSlot,
                      child: _buildChip(
                        svgIcon: "assets/images/icons/time_icon.svg",
                        label: selectedTimeSlot ?? l10n.exploreAnyTime,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExploreResultsScreen(
                                  serviceText: searchController.text,
                                  dateText: selectedDate != null
                                      ? _formatDate(selectedDate!)
                                      : "",
                                  timeText: selectedTimeSlot ?? "",
                                  locationText: currentCity),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l10n.exploreSearchButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "PoppinsMedium",
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(height: height * 0.015),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent",
                      style: TextStyle(
                        fontFamily: "PlayfairDisplayBold",
                        fontSize: width * 0.065,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Clear",
                        style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            fontSize: width * 0.035,
                            color: AppColors.rusticSunset),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: Column(
                  children: [
                    _recentSearchItem(
                      title: "Hair & styling",
                    ),
                    _recentSearchItem(
                      title: "Hair & styling",
                    ),
                    _recentSearchItem(
                      title: "Hair removal",
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // ----------------------- SERVICES SECTION -----------------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explore",
                      style: TextStyle(
                        fontFamily: "PlayfairDisplayBold",
                        fontSize: width * 0.065,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showAllServices = !showAllServices;
                        });
                      },
                      child: Text(
                        showAllServices ? "See less" : "See all",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: width * 0.035,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: showAllServices
                      ? provider.services.length
                      : (provider.services.length > 2
                          ? 2
                          : provider.services.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    // if (provider.isLoadingServices) {
                    //   return _buildServiceShimmer(width);
                    // }

                    final item = provider.services[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExploreResultsScreen(
                              serviceText: item["title"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // IMAGE
                              Positioned.fill(
                                child: item['img']!.startsWith('http')
                                    ? Image.network(
                                        item['img']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                          "assets/images/services/hair_styling.png",
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        item['img']!,
                                        fit: BoxFit.cover,
                                      ),
                              ),

                              // DARK GRADIENT OVERLAY
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Colors.black.withOpacity(0.55),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // TITLE TEXT
                              Positioned(
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: Text(
                                  item['title']!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "PoppinsSemiBold",
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI BUILDERS ----------------

  Widget _recentSearchItem({
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: subtitle != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // Circle icon
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 210, 191),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: AppColors.rusticSunset,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required String hint,
    required String svgIcon,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.softIvory,
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: TextField(
        cursorColor: AppColors.rusticSunset,
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              svgIcon,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "PoppinsMedium",
            color: Colors.black,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: const TextStyle(
          fontFamily: "PoppinsMedium",
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.softIvory,
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: Row(
        children: [
          // 📍 ICON → auto-detect
          InkWell(
            onTap: _getUserLocation,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                "assets/images/icons/location_icon.svg",
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
          ),

          // FIELD → search city
          Expanded(
            child: InkWell(
              onTap: _openCitySearchSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  currentCity?.isNotEmpty == true
                      ? currentCity!
                      : l10n.exploreDetectingLocation,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCitySearchSheet() {
    TextEditingController cityController = TextEditingController();
    List<String> cityResults = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.8, // 👈 controls height
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 5, // 👈 reduced
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 1.4),
                      ),
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          hintText: "Search city",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        onChanged: (value) async {
                          if (value.trim().length < 3) {
                            setModalState(() => cityResults = []);
                            return;
                          }

                          try {
                            final locations = await locationFromAddress(value);
                            final cities = <String>{};

                            for (final loc in locations) {
                              final placemarks = await placemarkFromCoordinates(
                                  loc.latitude, loc.longitude);

                              for (final p in placemarks) {
                                if (p.locality != null &&
                                    p.locality!.isNotEmpty) {
                                  cities.add(p.locality!);
                                }
                              }
                            }

                            if (!mounted) return;
                            setModalState(() {
                              cityResults = cities.toList();
                            });
                          } catch (_) {
                            if (!mounted) return;
                            setModalState(() => cityResults = []);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Results
                    Expanded(
                      child: ListView.builder(
                        itemCount: cityResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              cityResults[index],
                              style: const TextStyle(
                                fontFamily: "PoppinsMedium",
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                currentCity = cityResults[index];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip({
    required String svgIcon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.6),
        color: AppColors.softIvory,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontFamily: "PoppinsMedium",
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
