// SOLUTION: Make ExpandableSelectionWidget a controlled component
// Replace your entire expandable_selection_widget.dart with this:

import 'package:flutter/material.dart';

class ExpandableSelectionWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final int minSelections;
  final int maxSelections;
  final Function(List<String>)? onSelectionChanged;
  final bool isDisabled;
  final List<String> selectedOptions; // Changed from initialSelectedOptions to selectedOptions

  const ExpandableSelectionWidget({
    super.key,
    required this.title,
    required this.options,
    this.minSelections = 1,
    this.maxSelections = 3,
    this.onSelectionChanged,
    this.isDisabled = false,
    this.selectedOptions = const [], // This is now the current selected options, not initial
  });

  @override
  State<ExpandableSelectionWidget> createState() => _ExpandableSelectionWidgetState();
}

class _ExpandableSelectionWidgetState extends State<ExpandableSelectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _updateExpansionState();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _updateExpansionState() {
    final shouldExpand = widget.selectedOptions.isNotEmpty;
    if (shouldExpand != _isExpanded) {
      _isExpanded = shouldExpand;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(ExpandableSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateExpansionState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
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
    if (widget.isDisabled) return;

    List<String> newSelections = List<String>.from(widget.selectedOptions);

    if (newSelections.contains(option)) {
      newSelections.remove(option);
    } else {
      if (newSelections.length < widget.maxSelections) {
        newSelections.add(option);
      }
    }

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(newSelections);
    }
  }

  String _getSelectionCountText() {
    if (widget.selectedOptions.isEmpty) {
      return '';
    }
    return ' (${widget.selectedOptions.length})';
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled;
    final containerColor = isDisabled
        ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5)
        : Theme.of(context).colorScheme.tertiary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: isDisabled
            ? Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: isDisabled ? null : _toggleExpansion,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: isDisabled
                              ? Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.4)
                              : Theme.of(context).colorScheme.inverseSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.selectedOptions.isNotEmpty)
                        Text(
                          _getSelectionCountText(),
                          style: TextStyle(
                            color: isDisabled
                                ? const Color(0xFF4E6BF5).withValues(alpha: 0.4)
                                : const Color(0xFF4E6BF5),
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
                      color: isDisabled
                          ? Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.4)
                          : Theme.of(context).colorScheme.inverseSurface,
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
                          ? Colors.grey[400]?.withValues(alpha: 0.4)
                          : Colors.grey,
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
    final isSelected = widget.selectedOptions.contains(option);
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
                      ? Colors.grey[600]!.withValues(alpha: 0.4)
                      : isSelected
                      ? const Color(0xFF4E6BF5)
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
                    ? const Color(0xFF4E6BF5).withValues(alpha: 0.4)
                    : const Color(0xFF4E6BF5),
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
                      ? Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.4)
                      : Theme.of(context).colorScheme.inverseSurface,
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