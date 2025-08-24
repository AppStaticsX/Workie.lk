class EducationModel {
  final String title;
  final String company;
  final String location;
  final String startMonth;
  final String startYear;
  final String? endMonth;
  final String? endYear;
  final bool isCurrentWork;

  EducationModel({
    required this.title,
    required this.company,
    required this.location,
    required this.startMonth,
    required this.startYear,
    this.endMonth,
    this.endYear,
    required this.isCurrentWork,
  });

  String get dateRange {
    String start = '$startMonth $startYear';
    if (isCurrentWork) {
      return '$start - Present';
    } else {
      String end = '$endMonth $endYear';
      return '$start - $end';
    }
  }
}