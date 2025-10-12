import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/values/color.dart';

class ExperienceDetailModel extends StatefulWidget {
  final String company;
  final String position;
  final String location;
  final String startDate;
  final String endDate;
  final String companyUrl;
  final bool isCurrentJob;

  const ExperienceDetailModel({
    super.key,
    required this.company,
    required this.position,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.companyUrl,
    this.isCurrentJob = false,
  });

  @override
  State<ExperienceDetailModel> createState() => _ExperienceDetailModelState();
}

class _ExperienceDetailModelState extends State<ExperienceDetailModel> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              widget.companyUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.building,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.position,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '@${widget.company}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.isCurrentJob) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF36C897),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 18,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.endDate,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                /*Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 18,
                      color: AppColors.textSilver,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSilver,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}