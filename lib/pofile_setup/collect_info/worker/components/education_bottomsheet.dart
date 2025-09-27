import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:async';
import 'package:workie/models/education_model.dart';
import 'package:workie/services/file_cache_service.dart';
import 'package:workie/services/google_places_service.dart';

class EducationBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;
  final Function(EducationModel) onSave;
  final EducationModel? initialData;

  const EducationBottomsheet({
    super.key,
    required this.closeBottomSheet,
    required this.onSave,
    this.initialData,
  });

  @override
  State<EducationBottomsheet> createState() => _EducationBottomsheetState();
}

class _EducationBottomsheetState extends State<EducationBottomsheet> {
  String endYear = 'Year';
  String startYear = 'Year';
  File? certificateFile;
  String? certificateFileName;
  bool _isFileSaving = false;

  bool _isSchoolEmpty = false;
  bool _isCourseEmpty = false;
  bool _isFieldOfStudyEmpty = false;
  bool _isStartYearEmpty = false;
  bool _isEndYearEmpty = false;
  bool _isYearRangeInvalid = false;
  bool _hasErrors = false;

  final TextEditingController schoolController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController fieldOfStudyController = TextEditingController();

  final FocusNode schoolFocusNode = FocusNode();
  final FocusNode courseFocusNode = FocusNode();
  final FocusNode fieldOfStudyFocusNode = FocusNode();

  // Autocomplete related variables
  final GooglePlacesService _placesService = GooglePlacesService();
  List<PlaceAutocomplete> _schoolSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFields(widget.initialData!);
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _removeOverlay(); // Hide autocomplete suggestions when keyboard is dismissed
  }

  void _populateFields(EducationModel education) {
    schoolController.text = education.school;
    courseController.text = education.course;
    fieldOfStudyController.text = education.fieldOfStudy;
    startYear = education.startYear;

    if (education.endYear != null) {
      endYear = education.endYear!;
    }

    // Populate certificate fields if they exist
    if (education.hasCertificate) {
      certificateFile = education.certificateFile;
      certificateFileName = education.certificateFileName;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    schoolController.dispose();
    courseController.dispose();
    fieldOfStudyController.dispose();
    schoolFocusNode.dispose();
    courseFocusNode.dispose();
    fieldOfStudyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    try {
      setState(() {
        _isFileSaving = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final File pickedFile = File(result.files.single.path!);
        final String fileName = result.files.single.name;

        // Save file to cache
        final File? cachedFile = await FileCacheService.saveFileToCache(pickedFile, fileName);

        if (cachedFile != null) {
          setState(() {
            certificateFile = cachedFile;
            certificateFileName = fileName;
            _isFileSaving = false;
          });
        } else {
          setState(() {
            _isFileSaving = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save certificate. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          _isFileSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _isFileSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeCertificate() async {
    if (certificateFile != null) {
      // Delete from cache
      await FileCacheService.deleteFileFromCache(certificateFile!);
    }

    setState(() {
      certificateFile = null;
      certificateFileName = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _validateInput() {
    setState(() {
      _isSchoolEmpty = schoolController.text.isEmpty;
      _isCourseEmpty = courseController.text.isEmpty;
      _isFieldOfStudyEmpty = fieldOfStudyController.text.isEmpty;
      _isStartYearEmpty = startYear == 'Year';
      _isEndYearEmpty = endYear == 'Year';
      _isYearRangeInvalid = false;

      if (!_isStartYearEmpty && !_isEndYearEmpty) {
        _isYearRangeInvalid = _isEndYearBeforeStartYear();
      }

      _hasErrors = _isSchoolEmpty || _isCourseEmpty || _isFieldOfStudyEmpty ||
          _isStartYearEmpty || _isEndYearEmpty || _isYearRangeInvalid;
    });
  }

  bool _isEndYearBeforeStartYear() {
    if (startYear == 'Year' || endYear == 'Year') {
      return false;
    }

    int startYearInt = int.parse(startYear);
    int endYearInt = int.parse(endYear);

    return endYearInt < startYearInt;
  }

  void _handleSave() {
    _validateInput();

    if (!_hasErrors && !_isFileSaving) {
      final education = EducationModel(
        school: schoolController.text,
        course: courseController.text,
        fieldOfStudy: fieldOfStudyController.text,
        startYear: startYear,
        endYear: endYear,
        certificateFile: certificateFile,
        certificateFileName: certificateFileName,
      );

      widget.onSave(education);
      Navigator.pop(context);
    } else if (_isFileSaving) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while file is being saved...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFormFields(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              widget.initialData != null ? 'Edit Education History' : 'Add Education History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold
              )
          ),
          IconButton(
              onPressed: () {
                _dismissKeyboard();
                widget.closeBottomSheet();
              },
              icon: const Icon(
                Icons.close,
                size: 28,
              )
          )
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchoolField(),
                  const SizedBox(height: 16),
                  _buildCourseField(),
                  const SizedBox(height: 16),
                  _buildFieldOfStudyField(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildCertificateField(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 16),
              SafeArea(child: _buildBottomActionButtons()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certificate (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload PDF or image of your certificate',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        if (certificateFile == null)
          InkWell(
            onTap: _isFileSaving ? null : _pickCertificate,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _isFileSaving
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isFileSaving)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Transform.scale(
                        scale: 0.45, // Makes it half the size
                        child: CircularProgressIndicator(
                          strokeWidth: 9,
                          color: Colors.white,
                          strokeCap: StrokeCap.square,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.upload_file,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isFileSaving ? 'Saving File...' : 'Choose File',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  _getFileIcon(),
                  width: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificateFileName ?? 'Unknown file',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getFileSize(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _isFileSaving ? null : _pickCertificate,
                      icon: Icon(
                        CupertinoIcons.pencil_outline,
                        color: _isFileSaving
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      onPressed: _isFileSaving ? null : _removeCertificate,
                      icon: Icon(
                        CupertinoIcons.trash_circle,
                        color: _isFileSaving ? Colors.grey : Colors.red,
                        size: 24,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getFileIcon() {
    if (certificateFileName == null) return 'assets/icon/script-svgrepo-com.svg';

    String extension = certificateFileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'assets/icon/pdf2-svgrepo-com.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'assets/icon/images-svgrepo-com.svg';
      default:
        return 'assets/icon/script-svgrepo-com.svg';
    }
  }

  String _getFileSize() {
    if (certificateFile == null) return '';

    try {
      int bytes = certificateFile!.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  // Autocomplete helper methods
  void _onSchoolQueryChanged(String query) {
    if (query.isEmpty) {
      _removeOverlay();
      setState(() {
        _schoolSuggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchSchools(query);
    });
  }

  Future<void> _searchSchools(String query) async {
    try {
      final suggestions = await _placesService.getSchoolSuggestions(query);
      if (mounted) {
        setState(() {
          _schoolSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
        
        if (suggestions.isNotEmpty) {
          _showSuggestionOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _schoolSuggestions = [];
          _isLoadingSuggestions = false;
        });
        _removeOverlay();
      }
    }
  }

  void _showSuggestionOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 48, // Account for padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 60.0), // Position below the text field
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _schoolSuggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final suggestion = _schoolSuggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion.mainText,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: suggestion.secondaryText.isNotEmpty
                        ? Text(
                            suggestion.secondaryText,
                            style: TextStyle(
                              fontSize: 12, 
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => _selectSchool(suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectSchool(PlaceAutocomplete suggestion) {
    schoolController.text = suggestion.mainText;
    _removeOverlay();
    setState(() {
      _schoolSuggestions = [];
      _isSchoolEmpty = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSchoolField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Training School / Institute *',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: schoolController,
            focusNode: schoolFocusNode,
            onChanged: (value) {
              if (_isSchoolEmpty && value.isNotEmpty) {
                setState(() => _isSchoolEmpty = false);
              }
              _onSchoolQueryChanged(value);
            },
            onTap: () {
              // Show suggestions when field gets focus if there's already text
              if (schoolController.text.isNotEmpty && _schoolSuggestions.isEmpty) {
                _onSchoolQueryChanged(schoolController.text);
              }
            },
            decoration: InputDecoration(
              hintText: 'Ex: Vocational Training School',
              hintStyle: const TextStyle(
                  color: Colors.grey
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.tertiary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isSchoolEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isSchoolEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                  width: 2,
                ),
              ),
              suffixIcon: _isLoadingSuggestions
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Transform.scale(
                        scale: 0.45, // Makes it half the size
                        child: CircularProgressIndicator(
                          strokeWidth: 7,
                          color: Colors.white,
                          strokeCap: StrokeCap.square,
                        ),
                      ),
                    ),
                  )
                : schoolController.text.isNotEmpty
                  ? IconButton(
                  onPressed: () {
                    schoolController.clear();
                    _removeOverlay();
                  },
                  icon: Icon(Icons.close, size: 20)
              )
                  : Icon(Icons.school)
            ),
          ),
        ),
        if (_isSchoolEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Training School / Institute is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Name *',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: courseController,
          focusNode: courseFocusNode,
          onChanged: (value) {
            if (_isCourseEmpty && value.isNotEmpty) {
              setState(() => _isCourseEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: NVQ Level 6',
            hintStyle: const TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isCourseEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isCourseEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isCourseEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Course is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFieldOfStudyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Field of Study *',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: fieldOfStudyController,
          focusNode: fieldOfStudyFocusNode,
          onChanged: (value) {
            if (_isFieldOfStudyEmpty && value.isNotEmpty) {
              setState(() => _isFieldOfStudyEmpty = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Ex: Carpentry',
            hintStyle: const TextStyle(
                color: Colors.grey
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isFieldOfStudyEmpty ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isFieldOfStudyEmpty ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                width: 2,
              ),
            ),
          ),
        ),
        if (_isFieldOfStudyEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Field of study is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Years Attended *',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Year',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildYearPicker(
                      selectedYear: startYear,
                      isError: _isStartYearEmpty || _isYearRangeInvalid,
                      onYearSelected: (year) {
                        setState(() {
                          startYear = year;
                          _isStartYearEmpty = false;
                          _isYearRangeInvalid = false;
                        });
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Year',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildYearPicker(
                      selectedYear: endYear,
                      isError: _isEndYearEmpty || _isYearRangeInvalid,
                      onYearSelected: (year) {
                        setState(() {
                          endYear = year;
                          _isEndYearEmpty = false;
                          _isYearRangeInvalid = false;
                        });
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (_isStartYearEmpty)
              Expanded(
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Start year is required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (_isEndYearEmpty)
              Expanded(
                child: const Padding(
                  padding: EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'End year is required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (_isYearRangeInvalid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Start year cannot be after end year',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _buildYearPicker({
    required String selectedYear,
    required Function(String) onYearSelected,
    bool isError = false
  }) {
    return InkWell(
      onTap: () {
        _showYearPicker(onYearSelected);
        _dismissKeyboard();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                width: 1.5,
                color: isError
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            )
        ),
        child: Center(
          child: Text(
            selectedYear,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: selectedYear == 'Year'
                    ? Theme.of(context).hintColor
                    : null
            ),
          ),
        ),
      ),
    );
  }

  void _showYearPicker(Function(String) onYearSelected) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        int currentYear = DateTime.now().year;
        int selectedYear = currentYear; // Initialize with current year
        int initialIndex = 50; // Current year is at index 50 (middle of range)

        return CupertinoAlertDialog(
          title: const Text('Select Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Google Sans'),),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32.0,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: (int index) {
                selectedYear = currentYear - 50 + index;
              },
              children: List.generate(101, (index) { // Generate 101 items for proper range
                int year = currentYear - 50 + index;
                return Center(
                  child: Text(
                    year.toString(),
                    style: const TextStyle(fontSize: 18, fontFamily: 'Google Sans'),
                  ),
                );
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Google Sans', fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Select', style: TextStyle(fontFamily: 'Google Sans', fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                onYearSelected(selectedYear.toString());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () {
              _dismissKeyboard();
              Navigator.pop(context);
            },
            child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                    fontWeight: FontWeight.bold
                )
            )
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: _isFileSaving ? null : () {
            _handleSave();
            _dismissKeyboard();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFileSaving ? Colors.grey : const Color(0xFF4E6BF5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: _isFileSaving
              ? SizedBox(
            width: 16,
            height: 16,
            child: Transform.scale(
              scale: 0.45, // Makes it half the size
              child: CircularProgressIndicator(
                strokeWidth: 7,
                color: Colors.white,
                strokeCap: StrokeCap.square,
              ),
            ),
          )
              : Text(
              'Save',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
          ),
        ),
      ],
    );
  }
}