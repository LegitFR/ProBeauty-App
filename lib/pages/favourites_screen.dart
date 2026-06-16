// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';
import 'package:probeauty_app/services/salon_service.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/models/product.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _favourites = [];

  String? _addingToCartId; // 👈 track loading per product item
  String? _openingSalonId; // 👈 track loading per salon item

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.softIvory,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: double.infinity,
                height: 160,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 12),
              const SkeletonBox(width: 220, height: 16),
              const SizedBox(height: 6),
              const SkeletonBox(width: 140, height: 14),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 80, height: 18),
                  SkeletonBox(width: 90, height: 34),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================
  // FETCH FAVOURITES
  // ==========================
  Future<void> _fetchFavourites() async {
    try {
      final resp = await ApiClient.get(
        "/api/v1/favourites",
        query: {
          "type": "product",
          "page": "1",
          "limit": "20",
        },
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        setState(() {
          _favourites = body["data"] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load favourites";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Unable to load favourites right now. Please try again later.";
        _loading = false;
      });
    }
  }

  // ==========================
  // REMOVE FROM FAVOURITES
  // ==========================
  Future<void> _removeFavourite(
    String itemId,
    String type,
    int index,
  ) async {
    try {
      final resp = await ApiClient.delete(
        "/api/v1/favourites/$itemId?type=$type",
      );

      print(resp.body);

      if (resp.statusCode == 200) {
        setState(() {
          _favourites.removeAt(index);
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.favouritesRemovedSuccess),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.favouritesRemoveFailed),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.favouritesError(e.toString()),
          ),
        ),
      );
    }
  }

  // ==========================
  // ADD TO CART
  // ==========================
  Future<void> _addToCart(String productId) async {
    try {
      setState(() => _addingToCartId = productId);

      final resp = await ApiClient.post(
        "/api/v1/cart/items",
        body: {
          "productId": productId,
          "quantity": 1,
        },
      );

      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.favouritesAddedToCart),
          ),
        );
      } else {
        final body = jsonDecode(resp.body);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body["message"] ??
                  AppLocalizations.of(context)!.favouritesAddToCartFailed,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.favouritesError(e.toString()),
          ),
        ),
      );
    } finally {
      setState(() => _addingToCartId = null);
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.favouritesTitle,
          style:
              const TextStyle(fontFamily: "PoppinsMedium", color: Colors.black),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1️⃣ LOADING → SKELETON
    if (_loading) {
      return _buildSkeletonList();
    }

    // 2️⃣ ERROR
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.black45,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "PoppinsMedium",
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchFavourites,
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
      );
    }

    // 3️⃣ EMPTY (ONLY AFTER LOAD)
    if (_favourites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.black45,
              size: 38,
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.favouritesEmpty,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 4️⃣ REAL DATA
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _favourites.length,
      itemBuilder: (context, index) {
        final item = _favourites[index];
        final String type = item["type"] ?? "product";

        if (type == "salon") {
          final salon = item["salon"];
          final String salonId =
              salon?["id"] ?? salon?["_id"] ?? item["itemId"] ?? "";
          return _favouriteSalonCard(salon, salonId, index);
        }

        final product = item["product"];
        return _favouriteProductCard(product, index);
      },
    );
  }

  // ==========================
  // OPEN SALON DETAIL
  // ==========================
  Future<void> _openSalon(String salonId) async {
    if (_openingSalonId == salonId) return;
    setState(() => _openingSalonId = salonId);
    try {
      final salon = await SalonService.fetchSalonById(salonId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SalonDetailScreen(
            id: salon["id"] ?? salon["_id"] ?? salonId,
            name: salon["name"] ?? "",
            address: salon["address"] ?? "",
            image: salon["thumbnail"] ?? salon["image"] ?? "",
            services: salon["services"] ?? [],
            salonStaffList: salon["staff"] ?? [],
            hours: salon["hours"] ?? {},
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to load salon details. Please try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingSalonId = null);
    }
  }

  // ==========================
  // SALON CARD
  // ==========================
  Widget _favouriteSalonCard(dynamic salon, String salonId, int index) {
    final String name = salon?["name"] ?? "Salon";
    final String address = salon?["address"] ?? "";
    final String image = salon?["thumbnail"] ?? salon?["image"] ?? "";

    final bool isOpening = _openingSalonId == salonId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + remove button ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: Colors.grey[300],
                          child: const Icon(Icons.storefront,
                              size: 48, color: Colors.white70),
                        ),
                      )
                    : Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.storefront,
                            size: 48, color: Colors.white70),
                      ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _removeFavourite(
                    salonId,
                    "salon",
                    index,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                      color: AppColors.softIvory,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),

          // ── Info + Book now ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "PoppinsMedium",
                          fontSize: 14,
                        ),
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "PoppinsRegular",
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isOpening ? null : () => _openSalon(salonId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rusticSunset,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isOpening
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Book now",
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // PRODUCT CARD
  // ==========================
  Widget _favouriteProductCard(dynamic product, int index) {
    final String title = product["title"] ?? "";
    final String price = product["price"] ?? "";
    final String salonName = product["salon"]?["name"] ?? "";
    final String productId = product["id"];
    final String image =
        (product["images"] != null && product["images"].isNotEmpty)
            ? product["images"][0]
            : "";

    final bool isAdding = _addingToCartId == productId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(
              product: Product.fromJson(product),
              salonName: salonName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/images/saloons/saloon1.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/saloons/saloon1.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _removeFavourite(
                  productId,
                  "product",
                  index,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                    color: AppColors.softIvory,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontFamily: "PoppinsMedium", fontSize: 14)),
          const SizedBox(height: 4),
          Text(salonName,
              style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: 12,
                  color: Colors.black54)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("€$price",
                style: const TextStyle(
                    fontFamily: "PoppinsSemiBold", fontSize: 16)),
            ElevatedButton(
              onPressed: isAdding ? null : () => _addToCart(productId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isAdding
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppLocalizations.of(context)!.favouritesAddToCart,
                      style: const TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 12,
                          color: Colors.white)),
            ),
          ]),
        ]),
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
