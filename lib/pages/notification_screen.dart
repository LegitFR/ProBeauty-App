import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;
  List<_NotificationItem> _unread = [];
  List<_NotificationItem> _read = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // ================= AUTH =================
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Access token missing');
    }
    return token;
  }

  // ================= FETCH =================
  Future<void> _fetchNotifications() async {
    try {
      final token = await _getToken();

      final res = await http.get(
        Uri.parse(
          'https://probeauty-backend.onrender.com/api/v1/notifications',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to fetch notifications');
      }

      final body = jsonDecode(res.body);
      final List list = body['notifications'];

      final items = list.map((e) => _NotificationItem.fromJson(e)).toList();

      setState(() {
        _unread = items.where((n) => !n.isRead).toList();
        _read = items.where((n) => n.isRead).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ================= ACTIONS =================
  Future<void> _markAsRead(String id) async {
    final token = await _getToken();

    await http.put(
      Uri.parse(
        'https://probeauty-backend.onrender.com/api/v1/notifications/$id/read',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _fetchNotifications();
  }

  Future<void> _deleteNotification(String id) async {
    final token = await _getToken();

    await http.delete(
      Uri.parse(
        'https://probeauty-backend.onrender.com/api/v1/notifications/$id',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _fetchNotifications();
  }

  Future<void> _markAllAsRead() async {
    final token = await _getToken();

    await http.put(
      Uri.parse(
        'https://probeauty-backend.onrender.com/api/v1/notifications/read-all',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _fetchNotifications();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: _buildAppBar(l10n, screenWidth),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- UNREAD HEADER ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.notificationsUnreadCount(_unread.length),
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontFamily: "PoppinsSemiBold",
                            ),
                          ),
                          if (_unread.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.done_all,
                                  color: AppColors.rusticSunset),
                              onPressed: _markAllAsRead,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ..._unread.map(_buildDismissibleTile),

                      // ---------- READ SECTION ----------
                      if (_read.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          "Read (${_read.length})",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontFamily: "PoppinsSemiBold",
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._read.map(_buildDismissibleTile),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ================= DISMISSIBLE =================
  Widget _buildDismissibleTile(_NotificationItem n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction:
          n.isRead ? DismissDirection.endToStart : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && !n.isRead) {
          await _markAsRead(n.id);
          return false;
        }
        return true;
      },
      onDismissed: (_) => _deleteNotification(n.id),
      background: n.isRead
          ? const SizedBox.shrink()
          : _roundedSwipeBg(
              Icons.mark_email_read,
              Colors.green,
              Alignment.centerLeft,
            ),
      secondaryBackground: _roundedSwipeBg(
        Icons.delete,
        Colors.red,
        Alignment.centerRight,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTile(n),
      ),
    );
  }

  // ================= TILE =================
  Widget _buildTile(_NotificationItem n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            _iconForType(n.type),
            width: 24,
            height: 24,
            color: AppColors.rusticSunset,
          ),
          const SizedBox(width: 12),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "InterSemiBold",
                    fontSize: 14,
                    color: AppColors.rusticSunset,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// TIME (FIXED WIDTH)
          SizedBox(
            width: 60,
            child: Text(
              _formatTime(n.createdAt),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SWIPE BG =================
  Widget _roundedSwipeBg(
    IconData icon,
    Color color,
    Alignment align,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: align,
      child: Icon(icon, color: Colors.white),
    );
  }

  // ================= APP BAR =================
  Widget _buildAppBar(AppLocalizations l10n, double screenWidth) {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                l10n.notificationsTitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontFamily: "PoppinsSemiBold",
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  String _iconForType(String type) {
    switch (type) {
      case 'booking':
        return 'assets/images/icons/appointment.svg';
      case 'order':
        return 'assets/images/icons/cart_icon.svg';
      case 'promotion':
        return 'assets/images/icons/discount.svg';
      default:
        return 'assets/images/icons/notification.svg';
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }
}

// ================= MODEL =================
class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory _NotificationItem.fromJson(Map<String, dynamic> json) {
    return _NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
