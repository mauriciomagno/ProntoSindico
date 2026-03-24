import 'package:flutter/material.dart';
import 'package:prontosindico/constants.dart';

enum NoticeCategory { importante, manutencao, social }

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.hasAttachment = false,
  });

  final String title;
  final String description;
  final String date;
  final NoticeCategory category;
  final bool hasAttachment;

  Color _getCategoryColor() {
    switch (category) {
      case NoticeCategory.importante:
        return errorColor;
      case NoticeCategory.manutencao:
        return primaryColor;
      case NoticeCategory.social:
        return secondaryColor;
    }
  }

  String _getCategoryText() {
    switch (category) {
      case NoticeCategory.importante:
        return "IMPORTANTE";
      case NoticeCategory.manutencao:
        return "MANUTENÇÃO";
      case NoticeCategory.social:
        return "SOCIAL";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getCategoryText(),
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                if (hasAttachment) ...[
                  const Icon(Icons.attachment, size: 16, color: blackColor40),
                  const SizedBox(width: 4),
                  const Text("Anexo (PDF)",
                      style: TextStyle(fontSize: 12, color: blackColor40)),
                  const Spacer(),
                ],
                TextButton(
                  onPressed: () {},
                  child: const Text("Ler Mais"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
