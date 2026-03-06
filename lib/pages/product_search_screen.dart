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
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        provider.searchProducts(query: value);
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
                    return Center(
                      child: Text(provider.searchError!),
                    );
                  }

                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Text(l10n.shopNoProducts),
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
                          price: '₹${p.price ?? "-"}',
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
    margin: EdgeInsets.only(right: width * 0.04),
    decoration: BoxDecoration(
      color: AppColors.softIvory,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE
        Padding(
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
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
        ),

        /// CONTENT AREA
        Expanded(
          child: Padding(
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
                const Spacer(),
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
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        discount,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "PoppinsMedium",
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
        ),

        const SizedBox(
          height: 5,
        ),

        /// SHOP BUTTON
        Container(
          height: 40,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
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
      ],
    ),
  );
}
