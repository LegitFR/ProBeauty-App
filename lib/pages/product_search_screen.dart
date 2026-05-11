import "package:flutter/material.dart";
import "package:probeauty_app/l10n/app_localizations.dart";
import "package:probeauty_app/providers/product_provider.dart";
import "package:probeauty_app/resources/AppColors.dart";
import "package:provider/provider.dart";

class ProductSearchScreen extends StatefulWidget {
  final String initialQuery;

  const ProductSearchScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);

    Future.microtask(() {
      context.read<ProductProvider>().searchProducts(
            query: widget.initialQuery,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BAR (same UI)
            Padding(
              padding: EdgeInsets.all(width * 0.035),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontFamily: "PoppinsRegular"),
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter a product name.",
                              ),
                            ),
                          );

                          return;
                        }

                        provider.searchProducts(
                          query: value,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: l10n.shopSearchHint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔄 BODY
            Expanded(
              child: Builder(
                builder: (_) {
                  if (provider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.rusticSunset,
                      ),
                    );
                  }

                  if (provider.searchError != null) {
                    return const Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.black45,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Unable to load search results.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Please try again later.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: Colors.black45,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.shopNoProducts,
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Try searching for another product.",
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.035),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 🔥 2 per row
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final p = provider.searchResults[index];
                      final image = p.images.isNotEmpty ? p.images.first : null;
                      final salonName = provider.salonNames[p.salonId] ??
                          l10n.shopLoadingSalon;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product_screen',
                            arguments: {
                              "product": p,
                              "salonName": salonName,
                            },
                          );
                        },
                        child: specialOfferCard(
                          context,
                          width,
                          brand: salonName,
                          productName: p.title ?? 'Product',
                          price: '€${p.price ?? "-"}',
                          oldPrice: '',
                          discount: '',
                          imageUrl: image,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget specialOfferCard(
  BuildContext context,
  double width, {
  required String brand,
  required String productName,
  required String price,
  required String oldPrice,
  required String discount,
  String? imageUrl,
}) {
  return Container(
    width: width * 0.55,
    height: width * 0.75, // 🔥 FIX: give fixed height
    margin: EdgeInsets.only(right: width * 0.04),
    decoration: BoxDecoration(
      color: AppColors.softIvory,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: Column(
      // ❌ REMOVE mainAxisSize.min
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE
        Padding(
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.image, size: 60),
            ),
          ),
        ),

        /// CONTENT
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "PoppinsMedium",
                  fontSize: 13,
                  color: AppColors.rusticSunset,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (oldPrice.isNotEmpty)
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45,
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (discount.isNotEmpty)
                    Expanded(
                      // 🔥 FIX: prevents overflow
                      child: Text(
                        discount,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        /// 🔥 THIS IS THE MAIN FIX
        const Spacer(),

        /// BUTTON (no navigation change)
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                "Shop",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
