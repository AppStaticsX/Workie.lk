import 'dart:io';

class ExperienceModel {
  final String company;
  final String position;
  final String jobType;
  final String startYear;
  final String? endYear;
  final String description;
  final String location;
  final File? certificateFile;
  final String? certificateFileName;

  ExperienceModel({
    required this.company,
    required this.position,
    required this.jobType,
    required this.startYear,
    this.endYear,
    required this.description,
    required this.location,
    this.certificateFile,
    this.certificateFileName,
  });

  bool get isCurrentJob {
    return endYear == null || endYear!.isEmpty;
  }

  String get dateRange {
    String start = startYear;
    if (isCurrentJob) {
      return '$start - Present';
    } else {
      String end = endYear!;
      return '$start - $end';
    }
  }

  bool get hasCertificate {
    return certificateFile != null && certificateFileName != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'jobType': jobType,
      'startYear': startYear,
      'endYear': endYear,
      'description': description,
      'location': location,
      'certificateFileName': certificateFileName,
    };
  }

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      jobType: json['jobType'] ?? '',
      startYear: json['startYear'] ?? '',
      endYear: json['endYear'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      certificateFileName: json['certificateFileName'],
    );
  }
}