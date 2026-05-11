// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/models/order.dart';
import 'package:provider/provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _cancellingOrderId;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  Widget _buildOrdersSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Section title
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonBox(width: 140, height: 18),
          ),

          const SizedBox(height: 16),

          ...List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softIvory,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 85,
                    height: 120,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 160, height: 14),
                        const SizedBox(height: 6),
                        SkeletonBox(width: double.infinity, height: 16),
                        const SizedBox(height: 6),
                        SkeletonBox(width: 120, height: 13),
                        const SizedBox(height: 6),
                        SkeletonBox(width: 90, height: 13),
                        const SizedBox(height: 12),
                        SkeletonBox(width: 140, height: 16),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SkeletonBox(
                                  height: 42, width: double.infinity),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SkeletonBox(
                                  height: 42, width: double.infinity),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordersProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          l10n.ordersTitle,
          style: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              children: [
                SvgPicture.asset(
                  "assets/images/icons/cart_icon.svg",
                  width: 26,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                if (ordersProvider.orders.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.rusticSunset,
                      ),
                      child: Text(
                        ordersProvider.orders.length.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontFamily: "PoppinsSemiBold",
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: ordersProvider.isLoading
            ? _buildOrdersSkeleton(context) // 1️⃣ LOADING FIRST
            : ordersProvider.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.black45,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Unable to load your orders.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please try again later.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<OrderProvider>().fetchOrders();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.rusticSunset,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Try Again",
                              style: TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ordersProvider.orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.black45,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.ordersEmpty,
                              style: const TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Your orders will appear here.",
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text(
                                l10n.ordersActiveTitle,
                                style: const TextStyle(
                                  fontFamily: "PoppinsSemiBold",
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            for (final order in ordersProvider.orders)
                              _orderCard(order),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final bool canCancel = order.status != "SHIPPED" &&
        order.status != "DELIVERED" &&
        order.status != "CANCELLED";

    Widget _orderStatusChip(String status) {
      Color color;
      String label;

      switch (status) {
        case "SHIPPED":
          color = Colors.orange;
          label = "Shipped";
          break;
        case "DELIVERED":
          color = Colors.green;
          label = "Delivered";
          break;
        case "CANCELLED":
          color = Colors.red;
          label = "Cancelled";
          break;
        default:
          color = Colors.grey;
          label = status;
      }

      return Container(
        height: 42, // ✅ same height as button
        alignment: Alignment.center, // ✅ perfect centering
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 12,
            color: color,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order.image.isNotEmpty
                ? Image.network(
                    order.image,
                    width: 85,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/appointments/saloon_thumb_1.png",
                      width: 85,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/images/appointments/saloon_thumb_1.png",
                    width: 85,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.salonName,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  order.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Order #${order.id}",
                  style: const TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Delivery on —",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  order.price > 0
                      ? AppLocalizations.of(context)!
                          .ordersItemPrice(order.price, order.quantity)
                      : "",
                  style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rusticSunset,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.ordersTrackButton,
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: canCancel
                            ? OutlinedButton(
                                onPressed: _cancellingOrderId == order.id
                                    ? null
                                    : () async {
                                        setState(() {
                                          _cancellingOrderId = order.id;
                                        });

                                        try {
                                          await context
                                              .read<OrderProvider>()
                                              .cancelOrder(order.id);

                                          await context
                                              .read<OrderProvider>()
                                              .fetchOrders();

                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Order cancelled successfully"),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Unable to cancel order. Please try again.",
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _cancellingOrderId = null;
                                            });
                                          }
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _cancellingOrderId == order.id
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown, // ✅ KEY LINE
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .ordersCancelButton,
                                          style: const TextStyle(
                                            fontFamily: "PoppinsSemiBold",
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              )
                            : _orderStatusChip(order.status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // const Padding(
          //   padding: EdgeInsets.only(top: 6),
          //   child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          // ),
        ],
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: borderRadius,
      ),
    );
  }
}
