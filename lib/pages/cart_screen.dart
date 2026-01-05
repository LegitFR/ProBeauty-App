import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final cart = context.watch<CartProvider>();

    double totalAmount = cart.subtotal;
    String totalText = "₹${totalAmount.toStringAsFixed(0)}";

    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Cart",
            style: TextStyle(fontFamily: "PoppinsSemiBold"),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          centerTitle: true,
          backgroundColor: AppColors.softIvory,
        ),
        backgroundColor: AppColors.softIvory,

        // ======================
        // FIXED BOTTOM BAR
        // ======================
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(color: AppColors.softIvory),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalText,
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Inclusive Of All Taxes",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: cart.items.isEmpty || _isPaying
                    ? null
                    : () async {
                        setState(() => _isPaying = true);

                        try {
                          // 1️⃣ Create order + payment intent
                          final result = await cart.checkoutWithStripe();
                          if (result == null) {
                            throw Exception(cart.error ?? "Checkout failed");
                          }

                          final clientSecret = result['clientSecret'] as String;

                          // 2️⃣ Confirm payment USING PROVIDER
                          final success = await cart.confirmStripePayment(
                            clientSecret,
                          );

                          if (!success) {
                            throw Exception(cart.error ?? "Payment failed");
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Payment successful!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }

                          await cart.fetchCart();
                        } on StripeException catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.error.message ?? "Payment cancelled",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isPaying = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rusticSunset,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================
        // MAIN CONTENT (UNCHANGED)
        // ======================
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.03),
                      if (cart.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (cart.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            cart.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: "PoppinsRegular",
                            ),
                          ),
                        )
                      else if (cart.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Your cart is empty",
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 16,
                            ),
                          ),
                        )
                      else ...[
                        for (int i = 0; i < cart.items.length; i++) ...[
                          _productQtyTile(cart.items[i], cart),
                          if (i != cart.items.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 22),
                      const Text(
                        "Order Summary",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final item in cart.items)
                        _summaryRow(
                          item.title,
                          "${item.quantity} × ${item.price.toStringAsFixed(0)}",
                        ),
                      if (cart.items.isNotEmpty) const SizedBox(height: 4),
                      if (cart.items.isNotEmpty)
                        _summaryRow("Discount", "-₹0", green: true),
                      if (cart.items.isNotEmpty) const SizedBox(height: 4),
                      if (cart.items.isNotEmpty)
                        _summaryRow("Shipping", "Free"),
                      if (cart.items.isNotEmpty) const Divider(thickness: 1),
                      _summaryRow("Total", totalText, bold: true),
                      SizedBox(height: height * 0.03),
                      const Text(
                        "Delivery Address",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _addressTile(),
                      SizedBox(height: height * 0.03),
                      const Text(
                        "Payment Method",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _paymentTile(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // UI METHODS (UNCHANGED)
  // =========================

  Widget _productQtyTile(CartItemModel item, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 15,
                    color: AppColors.rusticSunset,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.rusticSunset,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final newQty = item.quantity - 1;
                    final msg = await cart.updateItemQuantity(
                      productId: item.productId,
                      quantity: newQty,
                    );
                    if (msg != null && mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.remove, color: Colors.white, size: 18),
                  ),
                ),
                Text(
                  "${item.quantity}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 15,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final newQty = item.quantity + 1;
                    final msg = await cart.updateItemQuantity(
                      productId: item.productId,
                      quantity: newQty,
                    );
                    if (msg != null && mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool green = false,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "PoppinsRegular",
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 14,
              color: green ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/icons/location_icon.svg",
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.rusticSunset,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home",
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 16,
                    color: AppColors.rusticSunset,
                  ),
                ),
                Text(
                  "38/38 Guruvappa st, Ayanavaram...",
                  maxLines: 2,
                  style: TextStyle(fontFamily: "PoppinsRegular", fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _paymentTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/icons/cash_icon.svg",
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.rusticSunset,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cash On Delivery",
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 16,
                    color: AppColors.rusticSunset,
                  ),
                ),
                Text(
                  "Cash will be collected after delivery",
                  maxLines: 2,
                  style: TextStyle(fontFamily: "PoppinsRegular", fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
