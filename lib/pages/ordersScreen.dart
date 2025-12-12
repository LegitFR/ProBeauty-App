import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Orders",
          style: TextStyle(
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
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.rusticSunset,
                    ),
                    child: const Text(
                      "5",
                      style: TextStyle(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Active Orders",
                style: TextStyle(
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
                  child: CircularProgressIndicator(),
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
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  "No active orders",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final order in ordersProvider.orders) _orderCard(order),
                ],
              ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
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
          Image.asset(
            "assets/images/appointments/saloon_thumb_1.png",
            width: 85,
            height: 120,
            fit: BoxFit.cover,
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
                      ? "₹${order.price} (${order.quantity} item)"
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
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.rusticSunset,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Track",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 12,
                            ),
                          ),
                        ),
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
