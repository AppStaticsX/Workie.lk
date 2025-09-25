import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:workie/values/color.dart';

class EducationDetailModel extends StatefulWidget {
  final String school;
  final String degree;
  final String field ;
  final String startDate;
  final String endDate;
  final String schoolUrl;

  const EducationDetailModel({
    super.key,
    required this.school,
    required this.degree,
    required this.field,
    required this.startDate,
    required this.endDate,
    required this.schoolUrl
  });

  @override
  State<EducationDetailModel> createState() => _EducationDetailModelState();
}

class _EducationDetailModelState extends State<EducationDetailModel> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.schoolUrl,
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    widget.school,
                    style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.bold
                    )
                ),
                Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    widget.degree,
                    style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.normal
                    )
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.diamonds_copy, size: 18,),
                    const SizedBox(width: 4),
                    Text(
                      widget.field,
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ]
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        widget.startDate,
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSilver
                        )
                    ),
                    Text(
                      ' - ',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSilver
                        )
                    ),
                    Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        widget.endDate,
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSilver
                        )
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
