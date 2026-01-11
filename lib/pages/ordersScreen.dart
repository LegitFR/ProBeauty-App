import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordersProvider = context.watch<OrderProvider>();

    return SafeArea(
      bottom: true,
      child: Scaffold(
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  l10n.ordersActiveTitle,
                  style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              if (ordersProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(
                      color: AppColors.rusticSunset,
                    ),
                  ),
                )
              else if (ordersProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    ordersProvider.error!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontFamily: "PoppinsRegular",
                        fontSize: 14),
                  ),
                )
              else if (ordersProvider.orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    l10n.ordersEmpty,
                    style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final order in ordersProvider.orders)
                      _orderCard(order),
                  ],
                ),
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
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Order cancelled successfully"),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
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
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
