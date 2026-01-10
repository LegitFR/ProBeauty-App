import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/decision_screen.dart';
import 'package:probeauty_app/pages/language_selection_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("userName") ?? "User";
      userEmail = prefs.getString("userEmail") ?? "";
    });
  }

  // Get initials (AB, AJ, A)
  String _getInitials(String name) {
    if (name.trim().isEmpty) return "";

    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(height: screenHeight * 0.04),

              // Title
              Text(
                l10n.profileTitle,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplayBold',
                  color: Colors.black,
                  fontSize: screenHeight * 0.04,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Profile card
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/profile_details",
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                  decoration: BoxDecoration(
                    color: AppColors.softIvory,
                    border: Border.all(color: Colors.black, width: 2.5),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Initials Circle
                      Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rusticSunset,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: "PoppinsMedium",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'PoppinsSemiBold',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Subtitle
                            Text(
                              l10n.profileEdit,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'PoppinsRegular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Menu items
              _buildMenuItem(Icons.favorite_border, l10n.profileMenuFavourites,
                  () {
                Navigator.pushNamed(context, "/favourites");
              }),
              _buildMenuItem(
                  Icons.location_on_outlined, l10n.profileMenuSavedAddresses,
                  () {
                Navigator.pushNamed(context, "/saved_address");
              }),
              _buildMenuItem(
                  Icons.shopping_bag_outlined, l10n.profileMenuOrders, () {
                Navigator.pushNamed(context, "/orders");
              }),
              // _buildMenuItem(Icons.credit_card_outlined,
              //     l10n.profileMenuPaymentMethods, () {}),
              // _buildMenuItem(Icons.card_giftcard_outlined,
              //     l10n.profileMenuGiftCard, () {}),
              _buildMenuItem(
                  Icons.notifications_outlined, l10n.profileMenuNotifications,
                  () {
                Navigator.pushNamed(context, "/notification");
              }),
              // _buildMenuItem(
              //     Icons.settings_outlined, l10n.profileMenuSettings, () {}),

              const SizedBox(height: 8),

              // Language & Support Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen(),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/images/icons/english_icon.svg',
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        AppColors.rusticSunset,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.profileLanguageEnglish,
                      style: const TextStyle(
                        color: AppColors.rusticSunset,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  TextButton.icon(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/images/icons/support_icon.svg',
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        AppColors.rusticSunset,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      l10n.profileSupport,
                      style: const TextStyle(
                        color: AppColors.rusticSunset,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DecisionScreen()),
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rusticSunset,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    l10n.profileLogout,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'PoppinsSemiBold',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontFamily: 'PoppinsMedium',
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
        onTap: onTap,
      ),
    );
  }
}
