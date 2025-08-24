class EducationModel {
  final String school;
  final String course;
  final String fieldOfStudy;
  final String startYear;
  final String? endYear;

  EducationModel({
    required this.school,
    required this.course,
    required this.fieldOfStudy,
    required this.startYear,
    this.endYear,
  });

  bool get isCurrentEducation {
    return endYear == null || endYear!.isEmpty;
  }

  String get dateRange {
    String start = startYear;
    if (isCurrentEducation) {
      return '$start - Present';
    } else {
      String end = endYear!;
      return '$start - $end';
    }
  }
}