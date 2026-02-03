import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:probeauty_app/providers/address_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class AddressPickerScreen extends StatelessWidget {
  const AddressPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Address",
          style: TextStyle(fontFamily: "PoppinsSemiBold"),
        ),
        centerTitle: true,
        backgroundColor: AppColors.softIvory,
      ),
      backgroundColor: AppColors.softIvory,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rusticSunset,
        onPressed: () {
          // 🔥 Open Add Address Form (I can build this too)
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addressProvider.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addressProvider.addresses[index];

                return GestureDetector(
                  onTap: () async {
                    await addressProvider.setDefault(address.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: address.isDefault
                            ? AppColors.rusticSunset
                            : Colors.black12,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.addressType,
                                style: const TextStyle(
                                  fontFamily: "PoppinsSemiBold",
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address.shortAddress,
                                style: const TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (address.isDefault)
                          const Icon(Icons.check_circle,
                              color: AppColors.rusticSunset),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
