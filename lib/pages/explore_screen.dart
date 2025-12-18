import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/pages/explore_results_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:intl/intl.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTimeSlot;

  bool _loadingServices = true;

  List<Map<String, String>> _services = [];

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
    _fetchServices();
    _getUserLocation();
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

      currentLat = position.latitude;
      currentLong = position.longitude;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(currentLat!, currentLong!);

      if (placemarks.isNotEmpty) {
        currentCity = placemarks.first.locality ?? "Unknown";
      }

      setState(() {});
    } catch (e) {
      print("Location error: $e");
    }
  }

  Future<void> _fetchServices() async {
    final images = [
      "assets/images/services/hair_styling.png",
      "assets/images/services/ayurvedic.png",
      "assets/images/services/eyebrow.png",
      "assets/images/services/makeup.png",
    ];

    try {
      final url =
          Uri.parse("https://probeauty-backend.onrender.com/api/v1/services");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse["data"];

        setState(() {
          _services = data.asMap().entries.map<Map<String, String>>((entry) {
            final index = entry.key;
            final service = entry.value;

            return {
              "id": service["id"],
              "title": service["title"] ?? "Service",
              // CYCLE BETWEEN 4 IMAGES
              "img": images[index % images.length],
            };
          }).toList();

          _loadingServices = false;
        });
      } else {
        setState(() => _loadingServices = false);
      }
    } catch (e) {
      setState(() => _loadingServices = false);
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
            colorScheme:
                const ColorScheme.light(primary: AppColors.rusticSunset),
          ),
          child: child!,
        );
      },
    );

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
              _timeOption("Morning"),
              _timeOption("Afternoon"),
              _timeOption("Evening"),
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.03),

                Text(
                  "Explore",
                  style: TextStyle(
                    fontFamily: "PlayfairDisplayBold",
                    fontSize: width * 0.08,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: height * 0.03),

                // ----------------------- SEARCH BOX -----------------------
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.softIvory,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2.87,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSearchField(
                        controller: searchController,
                        hint: "Any treatment or venue",
                        svgIcon: "assets/images/icons/search_icon.svg",
                      ),
                      SizedBox(height: height * 0.02),
                      _buildLocationField(),
                      SizedBox(height: height * 0.02),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: _buildChip(
                                svgIcon:
                                    "assets/images/icons/calendar_icon.svg",
                                label: selectedDate == null
                                    ? "Any date"
                                    : _formatDate(selectedDate!),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.04),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectTimeSlot,
                              child: _buildChip(
                                svgIcon: "assets/images/icons/time_icon.svg",
                                label: selectedTimeSlot ?? "Any time",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                      Column(
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
                                      serviceText: searchController
                                          .text, // your search field text
                                      dateText: selectedDate != null
                                          ? _formatDate(selectedDate!)
                                          : "",
                                      timeText: selectedTimeSlot ?? "",
                                      locationText: "Mumbai" ?? "",
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.rusticSunset,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Search Probeauty",
                                  style: TextStyle(
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
                    ],
                  ),
                ),

                SizedBox(height: height * 0.035),

                // ----------------------- FILTERS ROW -----------------------
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterIcon(onTap: _openCombinedFilterSheet),
                      SizedBox(width: width * 0.03),
                      _buildFilterChip("Sort", onTap: _openSortSheet),
                      SizedBox(width: width * 0.03),
                      _buildFilterChip("Max price", onTap: _openMaxPriceSheet),
                      SizedBox(width: width * 0.03),
                      _buildFilterChip("Venue type",
                          onTap: _openVenueTypeSheet),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.03),

                Center(
                  child: Text(
                    "446,305 appointments booked today",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: width * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // ----------------------- SERVICES SECTION -----------------------
                Text(
                  "Services",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: width * 0.055,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: height * 0.02),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // itemCount: _loadingServices ? 4 : _services.length,
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    if (_loadingServices) {
                      return _buildServiceShimmer(width);
                    }

                    final item = _services[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.softIvory,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2.87),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              child: Image.asset(
                                item['img']!,
                                height: width * 0.22,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                item['title']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: "PoppinsMedium",
                                  fontSize: 13,
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

                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ SHIMMER PLACEHOLDER
  Widget _buildServiceShimmer(double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2.87),
      ),
      child: Column(
        children: [
          Container(
            height: width * 0.22,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 70,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // ---------------- UI BUILDERS ----------------

  Widget _buildSearchField({
    required String hint,
    required String svgIcon,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.softIvory,
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: TextField(
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.softIvory,
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              "assets/images/icons/location_icon.svg",
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          Expanded(
            child: Text(
              currentCity?.isNotEmpty == true
                  ? currentCity!
                  : "Detecting location...",
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

  Widget _buildChip({
    required String svgIcon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: "PoppinsMedium",
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: SvgPicture.asset(
          "assets/images/icons/filter_icon.svg",
          height: 20,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: "PoppinsMedium",
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String selectedSort = "Recommended";
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Drag Handle ---
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // --- TITLE + CLOSE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sort by",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 26, color: Colors.black),
                      )
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Sort by",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // === Options ===
                  _sortOption("Recommended", setModalState),
                  _sortOption("Top-rated", setModalState),
                  _sortOption("Nearest", setModalState),

                  const SizedBox(height: 22),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortOption(String label, Function setModalState) {
    bool selected = selectedSortOptions.contains(label);

    return InkWell(
      onTap: () {
        setModalState(() {
          if (selected) {
            selectedSortOptions.remove(label);
          } else {
            selectedSortOptions.add(label);
          }
        });
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            // checkbox style circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.rusticSunset : Colors.black54,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _openMaxPriceSheet() {
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Drag handle ---
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // --- Title + close ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Maximum price",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 26, color: Colors.black),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Max price",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Price bubble ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.4),
                          color: AppColors.softIvory,
                        ),
                        child: Text(
                          "₹${maxPrice.toInt()}",
                          style: const TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Slider ---
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.rusticSunset,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.rusticSunset,
                      overlayColor: AppColors.rusticSunset.withOpacity(0.2),
                    ),
                    child: Slider(
                      min: 0,
                      max: 5000,
                      value: maxPrice,
                      onChanged: (value) {
                        setModalState(() => maxPrice = value);
                        setState(() {}); // update main screen
                      },
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openVenueTypeSheet() {
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Venue type",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 26, color: Colors.black),
                      )
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "Venue type",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    children: [
                      _venueOption("Everyone", setModalState),
                      _venueOption("Male only", setModalState),
                      _venueOption("Female only", setModalState),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _venueOption(String label, Function setModalState) {
    bool selected = selectedVenueTypes.contains(label);

    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (selected) {
            selectedVenueTypes.remove(label);
          } else {
            selectedVenueTypes.add(label);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.rusticSunset : AppColors.softIvory,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: selected ? AppColors.rusticSunset : Colors.black,
              width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 14,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  void _openCombinedFilterSheet() {
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Drag handle ---
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // --- Title + close ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 26),
                      )
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ---------------------- SORT BY ----------------------
                  const Text(
                    "Sort by",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _combinedSortOption("Recommended", setModalState),
                  _combinedSortOption("Top-rated", setModalState),
                  _combinedSortOption("Nearest", setModalState),

                  const SizedBox(height: 25),

                  // ---------------------- MAX PRICE ----------------------
                  const Text(
                    "Maximum price",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.3),
                          color: AppColors.softIvory,
                        ),
                        child: Text(
                          "₹${maxPrice.toInt()}",
                          style: const TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.rusticSunset,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.rusticSunset,
                    ),
                    child: Slider(
                      min: 0,
                      max: 5000,
                      value: maxPrice,
                      onChanged: (value) {
                        setModalState(() => maxPrice = value);
                        setState(() {}); // update main ui
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------------------- VENUE TYPE ----------------------
                  const Text(
                    "Venue type",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    children: [
                      _combinedVenueChip("Everyone", setModalState),
                      _combinedVenueChip("Male only", setModalState),
                      _combinedVenueChip("Female only", setModalState),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ---------------------- BUTTONS ----------------------
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1.3),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedSortOptions.clear();
                                selectedVenueTypes.clear();
                                maxPrice = 1000;
                              });
                              setState(() {});
                            },
                            child: const Text(
                              "Clear all",
                              style: TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _combinedSortOption(String label, Function setModalState) {
    bool selected = selectedSortOptions.contains(label);

    return InkWell(
      onTap: () {
        setModalState(() {
          if (selected) {
            selectedSortOptions.remove(label);
          } else {
            selectedSortOptions.add(label);
          }
        });
        setState(() {}); // update main screen
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.rusticSunset : Colors.black54,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _combinedVenueChip(String label, Function setModalState) {
    bool selected = selectedVenueTypes.contains(label);

    return GestureDetector(
      onTap: () {
        setModalState(() {
          selected
              ? selectedVenueTypes.remove(label)
              : selectedVenueTypes.add(label);
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.rusticSunset : AppColors.softIvory,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected ? AppColors.rusticSunset : Colors.black,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
