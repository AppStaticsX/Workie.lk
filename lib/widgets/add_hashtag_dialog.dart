import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AddHashtagsDialog extends StatefulWidget {
  final List<String> selectedHashtags;
  final Function(List<String>) onHashtagsChanged;

  const AddHashtagsDialog({
    super.key,
    required this.selectedHashtags,
    required this.onHashtagsChanged,
  });

  @override
  State<AddHashtagsDialog> createState() => _AddHashtagsDialogState();
}

class _AddHashtagsDialogState extends State<AddHashtagsDialog> {
  late TextEditingController _textController;
  late List<String> _selectedHashtags;

  final List<String> _popularHashtags = [
    'react',
    'javascript',
    'webdev',
    'coding',
    'programming',
    'frontend',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _selectedHashtags = List.from(widget.selectedHashtags);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleHashtag(String hashtag) {
    setState(() {
      if (_selectedHashtags.contains(hashtag)) {
        _selectedHashtags.remove(hashtag);
      } else {
        _selectedHashtags.add(hashtag);
      }
    });
  }

  void _addCustomHashtag() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_selectedHashtags.contains(text)) {
      setState(() {
        _selectedHashtags.add(text);
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Hashtags',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _addCustomHashtag(),
                decoration: InputDecoration(
                  hintText: 'Type a hashtag...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.tag,
                    color: Colors.grey,
                    size: 18,
                  ),
                  suffixIcon: IconButton(
                      onPressed: (){
                        String userHashTags = _textController.text.trim().toString();
                        setState(() {
                          _popularHashtags.add(userHashTags);
                        });
                      },
                      icon: const Icon(Iconsax.add_copy)
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Popular hashtags label
            Text(
              'Popular hashtags:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Popular hashtags chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularHashtags.map((hashtag) {
                final isSelected = _selectedHashtags.contains(hashtag);
                return GestureDetector(
                  onTap: () => _toggleHashtag(hashtag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Theme.of(context).colorScheme.tertiary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$hashtag',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedHashtags.length} hashtags selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onHashtagsChanged(_selectedHashtags);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}