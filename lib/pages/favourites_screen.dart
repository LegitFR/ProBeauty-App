import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final String baseUrl = "https://probeauty-backend.onrender.com";

  bool _loading = true;
  String? _error;
  List<dynamic> _favourites = [];

  String? _addingToCartId; // 👈 track loading per item

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  // ==========================
  // FETCH FAVOURITES
  // ==========================
  Future<void> _fetchFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        setState(() {
          _error = "Please login to view favourites";
          _loading = false;
        });
        return;
      }

      final url = Uri.parse("$baseUrl/api/v1/favourites?page=1&limit=20");

      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
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
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ==========================
  // REMOVE FROM FAVOURITES
  // ==========================
  Future<void> _removeFavourite(String productId, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) return;

      final url = Uri.parse("$baseUrl/api/v1/favourites/$productId");

      final resp = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode == 200) {
        setState(() {
          _favourites.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from favourites")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to remove favourite"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ==========================
  // ADD TO CART
  // ==========================
  Future<void> _addToCart(String productId) async {
    try {
      setState(() => _addingToCartId = productId);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please login to add items to cart"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url = Uri.parse("$baseUrl/api/v1/cart/items");

      final resp = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "productId": productId,
          "quantity": 1,
        }),
      );

      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to cart")),
        );
      } else {
        final body = jsonDecode(resp.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body["message"] ?? "Failed to add to cart"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
        title: const Text(
          "Favourites",
          style: TextStyle(fontFamily: "PoppinsMedium", color: Colors.black),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_favourites.isEmpty) {
      return const Center(
        child: Text("No favourites yet",
            style: TextStyle(fontFamily: "PoppinsRegular")),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _favourites.length,
      itemBuilder: (context, index) {
        final product = _favourites[index]["product"];
        return _favouriteProductCard(product, index);
      },
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

    return Container(
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
                ? Image.network(image,
                    height: 160, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 160, color: Colors.grey[300]),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _removeFavourite(productId, index),
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
            style: const TextStyle(fontFamily: "PoppinsMedium", fontSize: 14)),
        const SizedBox(height: 4),
        Text(salonName,
            style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 12,
                color: Colors.black54)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("₹$price",
              style:
                  const TextStyle(fontFamily: "PoppinsSemiBold", fontSize: 16)),
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
                : const Text("Add to cart",
                    style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 12,
                        color: Colors.white)),
          ),
        ]),
      ]),
    );
  }
}
