// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/models/cart_item.dart';
import 'package:probeauty_app/providers/address_provider.dart';
import 'package:probeauty_app/routes/app_routes.dart';
import 'package:probeauty_app/services/api_client.dart';
import 'package:probeauty_app/widgets/success_animation.dart';
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
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  Future<String?> pollMbWayWebhook({
    required String orderId,
    required String requestId,
    required dynamic amount,
  }) async {
    try {
      final response = await ApiClient.get(
        "/api/v1/webhooks/ifthenpay/mbway",
        query: {
          "orderId": orderId,
          "requestId": requestId,
          "amount": amount.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"];
      }
    } catch (e) {
      debugPrint("Webhook polling error: $e");
    }

    return null;
  }

  Future<String?> getOrderPaymentStatus(String orderId) async {
    try {
      final response = await ApiClient.get(
        "/api/v1/orders/$orderId/payment",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final payments = data["data"];

        if (payments != null && payments.isNotEmpty) {
          return payments[0]["status"];
        }
      }
    } catch (e) {
      debugPrint("Payment status error: $e");
    }

    return null;
  }

  Future<void> _showSuccessOverlay() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) {
        return AnimatedSuccessScreen(
          title: "Order Placed!",
          buttonText: "Continue shopping",
          successSvgPath: "assets/images/icons/success.svg",
          onContinue: () {
            Navigator.pop(context); // close overlay
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final cart = context.watch<CartProvider>();

    double totalAmount = cart.subtotal;
    String totalText = "₹${totalAmount.toStringAsFixed(0)}";

    return Scaffold(
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
      bottomNavigationBar: SafeArea(
        child: Container(
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
                onPressed: cart.items.isEmpty || _isPaying || cart.isLoading
                    ? null
                    : () async {
                        setState(() => _isPaying = true);

                        try {
                          final phone = _phoneController.text.trim();

                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter your phone number.",
                                ),
                              ),
                            );
                            setState(() => _isPaying = false);
                            return;
                          }

                          final result = await cart.checkoutWithIfThenPay(
                            paymentMethod: "MBWAY",
                            mobileNumber: "351#$phone",
                          );

                          if (result == null) {
                            throw Exception(cart.error ?? "Checkout failed");
                          }

                          final payment = result["payment"];
                          final orderId = result["orderId"];
                          final requestId = payment["requestId"];
                          final amount = payment["amount"]; // check if exists

                          print(orderId);

// ✅ MBWAY message
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                payment["message"] ??
                                    "Please approve the payment in your MB WAY app.",
                              ),
                            ),
                          );

// ✅ Poll status
                          int attempts = 0;
                          String? status;

                          do {
                            await Future.delayed(const Duration(seconds: 3));

                            await pollMbWayWebhook(
                              orderId: orderId,
                              requestId: requestId,
                              amount: amount,
                            );

                            status = await pollMbWayWebhook(
                              orderId: orderId,
                              requestId: requestId,
                              amount: amount,
                            );

                            attempts++;
                          } while (status != null &&
                              status.toUpperCase() == "PAYMENT_PENDING" &&
                              attempts < 15);

                          if (status != null &&
                              status.toUpperCase() == "CONFIRMED") {
                            await cart.clearCart();

                            if (mounted) {
                              await _showSuccessOverlay();
                            }
                          }
                        } catch (e) {
                          if (!mounted) return;

                          String message =
                              "Unable to complete payment. Please try again later.";

                          final error = e.toString().toLowerCase();

                          if (error.contains("mb way")) {
                            message =
                                "Payment failed. Please verify your MB WAY number.";
                          } else if (error.contains("network")) {
                            message =
                                "Please check your internet connection and try again.";
                          }

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
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
                          child: CircularProgressIndicator(
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      )
                    else if (cart.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          cart.error!.contains("network")
                              ? "Please check your internet connection."
                              : "Unable to load cart items.",
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
                    if (cart.items.isNotEmpty) _summaryRow("Shipping", "Free"),
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
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Add another product",
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Enter Phone Number",
                      style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter phone number",
                        hintStyle: const TextStyle(
                            fontFamily: "PoppinsRegular", fontSize: 13),
                        prefixText: "351#",

                        // 🔥 DEFAULT BORDER
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.rusticSunset),
                        ),

                        // 🔥 WHEN ENABLED (NOT FOCUSED)
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.rusticSunset),
                        ),

                        // 🔥 WHEN FOCUSED (CLICKED)
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.rusticSunset,
                            width: 2, // optional thicker border
                          ),
                        ),

                        // 🔥 ERROR BORDER (optional but clean)
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
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
                    final msg = await cart.decreaseQty(
                      productId: item.productId,
                      currentQty: item.quantity,
                    );

                    if (msg != null && mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            msg.isNotEmpty ? msg : "Cart updated successfully.",
                          ),
                        ),
                      );
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
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            msg.isNotEmpty ? msg : "Cart updated successfully.",
                          ),
                        ),
                      );
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

  Future<void> _showAddressPickerDialog() async {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);

    await addressProvider.fetchAddresses();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<AddressProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================
                    // DRAG HANDLE
                    // =====================
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Select Delivery Address",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =====================
                    // ADDRESS LIST
                    // =====================
                    Expanded(
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.rusticSunset,
                              ),
                            )
                          : provider.addresses.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No saved addresses",
                                    style: TextStyle(
                                      fontFamily: "PoppinsRegular",
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  itemCount: provider.addresses.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final address = provider.addresses[index];

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        await provider.setDefault(address.id);
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.softIvory,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: address.isDefault
                                                ? AppColors.rusticSunset
                                                : Colors.black12,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: address.isDefault
                                                  ? AppColors.rusticSunset
                                                  : Colors.black45,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    address.addressType,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "PoppinsSemiBold",
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    address.shortAddress,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "PoppinsRegular",
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (address.isDefault)
                                              const Icon(
                                                Icons.check_circle,
                                                color: AppColors.rusticSunset,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),

                    // =====================
                    // ADD NEW ADDRESS
                    // =====================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.rusticSunset),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 14),
                        ),
                        onPressed: () async {
                          final rootContext = Navigator.of(context).context;

                          Navigator.pop(context);

                          await Navigator.pushNamed(
                            rootContext,
                            AppRoutes.savedAddress,
                          );

                          if (mounted) {
                            Provider.of<AddressProvider>(rootContext,
                                    listen: false)
                                .fetchAddresses();
                          }
                        },
                        icon: const Icon(Icons.add,
                            color: AppColors.rusticSunset),
                        label: const Text(
                          "Add New Address",
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            color: AppColors.rusticSunset,
                          ),
                        ),
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

  Widget _addressTile() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        final address = addressProvider.defaultAddress;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _showAddressPickerDialog();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softIvory,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.rusticSunset),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address?.addressType ?? "Add Address",
                        style: const TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 16,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address?.shortAddress ??
                            "Tap to add your delivery address",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "PoppinsRegular",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        );
      },
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
                  "Online Payment",
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 16,
                    color: AppColors.rusticSunset,
                  ),
                ),
                Text(
                  "Supports Online Payment",
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
