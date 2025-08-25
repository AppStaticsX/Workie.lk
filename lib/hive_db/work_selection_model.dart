// work_selection_model.dart
import 'package:hive/hive.dart';

part 'work_selection_model.g.dart';

@HiveType(typeId: 0)
class WorkSelection extends HiveObject {
  @HiveField(0)
  String categoryTitle;

  @HiveField(1)
  List<String> selectedOptions;

  WorkSelection({
    required this.categoryTitle,
    required this.selectedOptions,
  });

  // Convert to Map for easy JSON serialization if needed
  Map<String, dynamic> toMap() {
    return {
      'categoryTitle': categoryTitle,
      'selectedOptions': selectedOptions,
    };
  }

  // Create from Map
  factory WorkSelection.fromMap(Map<String, dynamic> map) {
    return WorkSelection(
      categoryTitle: map['categoryTitle'] ?? '',
      selectedOptions: List<String>.from(map['selectedOptions'] ?? []),
    );
  }
}