import 'package:flutter/material.dart';

class ExpandableSelectionWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final int minSelections;
  final int maxSelections;
  final Function(List<String>)? onSelectionChanged;
  final bool isDisabled;

  const ExpandableSelectionWidget({
    super.key,
    required this.title,
    required this.options,
    this.minSelections = 1,
    this.maxSelections = 3,
    this.onSelectionChanged,
    this.isDisabled = false,
  });

  @override
  State<ExpandableSelectionWidget> createState() => _ExpandableSelectionWidgetState();
}

class _ExpandableSelectionWidgetState extends State<ExpandableSelectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  List<String> _selectedOptions = [];
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    // Don't allow expansion if disabled
    if (widget.isDisabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleSelection(String option) {
    // Don't allow selection changes if disabled
    if (widget.isDisabled) return;

    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        if (_selectedOptions.length < widget.maxSelections) {
          _selectedOptions.add(option);
        }
      }
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(_selectedOptions);
    }
  }

  String _getSelectionCountText() {
    if (_selectedOptions.isEmpty) {
      return '';
    }
    return ' (${_selectedOptions.length})';
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled;
    final containerColor = isDisabled
        ? const Color(0xFF2D2D2D).withOpacity(0.5)
        : const Color(0xFF2D2D2D);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: isDisabled
            ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: isDisabled ? null : _toggleExpansion,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: isDisabled ? Colors.white.withOpacity(0.4) : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedOptions.isNotEmpty)
                        Text(
                          _getSelectionCountText(),
                          style: TextStyle(
                            color: isDisabled
                                ? const Color(0xFF4CAF50).withOpacity(0.4)
                                : const Color(0xFF4CAF50),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDisabled ? Colors.white.withOpacity(0.4) : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now, select ${widget.minSelections} to ${widget.maxSelections} specialties',
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey[400]?.withOpacity(0.4)
                          : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.options.map((option) => _buildOptionItem(option)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String option) {
    final isSelected = _selectedOptions.contains(option);
    final isDisabled = widget.isDisabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isDisabled ? null : () => _toggleSelection(option),
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey[600]!.withOpacity(0.4)
                      : isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[600]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                color: isDisabled
                    ? const Color(0xFF4CAF50).withOpacity(0.4)
                    : const Color(0xFF4CAF50),
                size: 18,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isDisabled
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage widget
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Expandable Selection Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ExpandableSelectionWidget(
              title: 'Accounting & Consulting',
              options: const [
                'Personal & Professional Coaching',
                'Accounting & Bookkeeping',
                'Financial Planning',
                'Recruiting & Human Resources',
                'Management Consulting & Analysis',
                'Other - Accounting & Consulting',
              ],
              onSelectionChanged: (selectedOptions) {
                print('Selected options: $selectedOptions');
              },
            ),
          ],
        ),
      ),
    );
  }
}