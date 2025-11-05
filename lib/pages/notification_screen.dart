import "package:flutter/material.dart";
import "package:probeauty_app/resources/AppColors.dart";

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.softIvory,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.black87),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notification_settings');
                      // Handle notification settings
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 17),
            Text(
              "Unread (2)",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontFamily: "PoppinsSemiBold",
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Notification Tile 1
            _buildNotificationTile(
              imagePath: "assets/images/icons/appointment.png",
              title: "Appointment Success",
              message:
                  "Your appointment has been successfully scheduled with Dr. Meera at 4:30 PM...",
              time: "Just now",
              onTap: () {},
            ),
            const SizedBox(height: 12),

            // Notification Tile 2
            _buildNotificationTile(
              imagePath: "assets/images/icons/discount.png",
              title: "Appointment Success",
              message:
                  "Your appointment has been successfully confirmed for tomorrow...",
              time: "Just now",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String imagePath,
    required String title,
    required String message,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Title + Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: "InterSemiBold",
                            fontSize: 14,
                            color: AppColors.rusticSunset,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontFamily: "RobotoRegular",
                          fontSize: 11,
                          color: AppColors.greyTone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: "InterRegular",
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.rusticSunset),
          ],
        ),
      ),
    );
  }
}
