import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/colors.dart';
import 'package:mobile_app/schemas.dart';
import 'package:mobile_app/widgets/event_detail.dart';

class EventCard extends StatelessWidget {
  final EventInformation data;

  const EventCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CachedNetworkImage(
                imageUrl: data.images.activityImage.url,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => const Center(
                  child: SizedBox.square(
                    dimension: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  color: dimmedColor,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy – HH:mm a').format(
                          data.date.starts,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Desde', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            'S/ ${data.pricing.amount.toString()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      // buy button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetail(data: data),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(dimmedColor),
                          backgroundColor: WidgetStateProperty.all(appColor),
                        ),
                        child: const Text('Comprar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
