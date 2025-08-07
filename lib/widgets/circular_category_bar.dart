import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryItem {
  final String id;
  final String name;
  final String svgAsset; // Changed from IconData to String for SVG path
  final Color? color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.svgAsset, // SVG asset path
    this.color,
  });
}

class CircularCategoryBar extends StatefulWidget {
  final List<CategoryItem> categories;
  final Function(CategoryItem)? onCategorySelected;
  final String? selectedCategoryId;
  final double itemSize;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double spacing;
  final EdgeInsets padding;

  const CircularCategoryBar({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.selectedCategoryId,
    this.itemSize = 40.0, // Reduced from 60.0 to 45.0
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.selectedTextColor = Colors.black,
    this.unselectedTextColor = Colors.grey,
    this.spacing = 12.0, // Reduced from 16.0 to 12.0
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0), // Reduced from 16.0 to 12.0
  });

  @override
  State<CircularCategoryBar> createState() => _CircularCategoryBarState();
}

class _CircularCategoryBarState extends State<CircularCategoryBar> {
  late String? selectedId;

  @override
  void initState() {
    super.initState();
    selectedId = widget.selectedCategoryId;
  }

  @override
  void didUpdateWidget(CircularCategoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      selectedId = widget.selectedCategoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemSize + 25, // Reduced extra space from 30 to 25
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = selectedId == category.id;

          return Container(
            margin: EdgeInsets.only(
              right: index < widget.categories.length - 1 ? widget.spacing : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedId = category.id;
                });
                widget.onCategorySelected?.call(category);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.itemSize,
                    height: widget.itemSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? widget.selectedColor
                          : (category.color ?? Colors.white),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.surface,
                          blurRadius: 6, // Reduced from 8 to 6
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(widget.itemSize * 0.2),
                      child: SvgPicture.asset(
                        category.svgAsset,
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? Colors.black
                              : Colors.black,
                          BlendMode.srcIn,
                        ),
                        width: widget.itemSize * 0.3,
                        height: widget.itemSize * 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 8 to 6
                  SizedBox(
                    width: widget.itemSize + 4,
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11, // Reduced from 12 to 11
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? widget.selectedTextColor
                            : widget.unselectedTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}