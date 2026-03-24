import 'package:flutter/material.dart';
import 'package:prontosindico/constants.dart';

class AvailableSpaceCard extends StatelessWidget {
  const AvailableSpaceCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    required this.isAvailable,
  });

  final String name;
  final String imageUrl;
  final String capacity;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: blackColor10,
                  child: const Icon(Icons.image, size: 50, color: blackColor40),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAvailable ? secondaryColor : errorColor)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isAvailable ? "LIVRE HOJE" : "OCUPADO",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: blackColor40),
                        const SizedBox(width: 4),
                        Text(capacity,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: isAvailable ? () {} : null,
                  child: const Text("Reservar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
