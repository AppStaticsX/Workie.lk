import 'dart:io';

class EducationModel {
  final String school;
  final String course;
  final String fieldOfStudy;
  final String startYear;
  final String? endYear;
  final File? certificateFile;
  final String? certificateFileName;

  EducationModel({
    required this.school,
    required this.course,
    required this.fieldOfStudy,
    required this.startYear,
    this.endYear,
    this.certificateFile,
    this.certificateFileName,
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

  bool get hasCertificate {
    return certificateFile != null && certificateFileName != null;
  }
}