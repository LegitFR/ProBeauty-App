import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:probeauty_app/resources/AppColors.dart";

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool appointmentAlerts = true;
  bool offerUpdates = false;
  bool systemNotifications = true;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    "Notification Settings",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03),
            _buildSettingItem(
              title: "Text message appointment",
              description: "Receive texts based on your sender’s settings",
              value: appointmentAlerts,
              onChanged: (val) => setState(() => appointmentAlerts = val),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildSettingItem(
              title: "Email Marketing",
              description: "Receive offers and news via email",
              value: offerUpdates,
              onChanged: (val) => setState(() => offerUpdates = val),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildSettingItem(
              title: "Order and Support",
              description:
                  "Receive notifications related to your order status, payments and support communications",
              value: systemNotifications,
              onChanged: (val) => setState(() => systemNotifications = val),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildSettingItem(
              title: "WhatsApp Messages",
              description: "Get updates from us on WhatsApp",
              value: reminders,
              onChanged: (val) => setState(() => reminders = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        _customSwitch(value, onChanged),
      ],
    );
  }

  Widget _customSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 55,
        height: 27,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.rusticSunset : AppColors.softIvory,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? Colors.transparent : Colors.black,
            width: 1,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 30,
          decoration: BoxDecoration(
            color: value ? Colors.white : Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
