import 'dart:async';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../services/ai_post_generation_service.dart';

class AIContentWriterDialog extends StatefulWidget {
  final List<String> selectedHashtags;
  final Function(String) onContentGenerated;

  const AIContentWriterDialog({
    super.key,
    required this.selectedHashtags,
    required this.onContentGenerated,
  });

  @override
  State<AIContentWriterDialog> createState() => _AIContentWriterDialogState();
}

class _AIContentWriterDialogState extends State<AIContentWriterDialog> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController(text: '300');
  
  PostType _selectedPostType = PostType.general;
  String _selectedTone = 'Professional';
  bool _isGenerating = false;
  String _generatedContent = '';
  String _lastUsedApi = '';
  bool _showGeneratedContent = false;

  final List<String> _toneOptions = [
    'Professional',
    'Casual',
    'Friendly',
    'Motivational',
    'Informative',
    'Humorous',
    'Inspirational',
    'Conversational',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a prompt to generate content'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedContent = '';
      _showGeneratedContent = false;
    });

    try {
      final maxLength = int.tryParse(_lengthController.text) ?? 300;
      
      final response = await AIPostGenerationService.generatePost(
        prompt: _promptController.text.trim(),
        postType: _selectedPostType,
        tone: _selectedTone,
        maxLength: maxLength,
        hashtags: widget.selectedHashtags.isNotEmpty ? widget.selectedHashtags : null,
      );

      setState(() {
        _isGenerating = false;
        if (response.success) {
          _generatedContent = response.generatedContent;
          _lastUsedApi = response.apiUsed;
          _showGeneratedContent = true;
        } else {
          _showErrorSnackBar(response.message);
        }
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showErrorSnackBar('Failed to generate content: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _useGeneratedContent() {
    if (_generatedContent.isNotEmpty) {
      widget.onContentGenerated(_generatedContent);
      Navigator.of(context).pop();
    }
  }

  void _regenerateContent() {
    _generateContent();
  }

  @override
  Widget build(BuildContext context) {
    return _isGenerating
        ? Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 250,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 2.5,
              child: Lottie.asset(
                'assets/animation/ai_loading_model.json',
                width: 120,
                height: 120,
                frameRate: FrameRate(120),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.center,
              'Generating...\nPlease wait a moment.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ) :
    Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Iconsax.magicpen,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Content Writer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content area
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_showGeneratedContent) ...[
                      // Input form
                      _buildInputForm(),
                    ] else ...[
                      // Generated content display
                      _buildGeneratedContentView(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt input
        Text(
          'What would you like to write about?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          maxLines: 3,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., "Write about the importance of work-life balance in tech industry"',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 20),

        // Post type selection
        Text(
          'Post Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PostType>(
              value: _selectedPostType,
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              items: PostType.values.map((PostType type) {
                return DropdownMenuItem<PostType>(
                  value: type,
                  child: Text(type.displayName, style: TextStyle(fontFamily: 'Lato', fontSize: 15, letterSpacing: 0.5),),
                );
              }).toList(),
              onChanged: (PostType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPostType = newValue;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tone and length row
        Row(
          children: [
            // Tone selection
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTone,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: _toneOptions.map((String tone) {
                          return DropdownMenuItem<String>(
                            value: tone,
                            child: Text(tone, style: TextStyle(fontFamily: 'Lato', fontSize: 15, letterSpacing: 0.5),),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTone = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Max length
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Length',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '300',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Hashtags info (if any selected)
        if (widget.selectedHashtags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected Hashtags (${widget.selectedHashtags.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.selectedHashtags.take(5).map((tag) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ).toList(),
          ),
          if (widget.selectedHashtags.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '... and ${widget.selectedHashtags.length - 5} more',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildGeneratedContentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Generated Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            /*if (_lastUsedApi.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _lastUsedApi,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),*/
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _generatedContent,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(onPressed: _isGenerating ? null : _regenerateContent,
                icon: Icon(Icons.refresh)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _useGeneratedContent,
                icon: Icon(Icons.check),
                label: Text('Use This Content'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_showGeneratedContent) {
      return Row(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _showGeneratedContent = false;
                _generatedContent = '';
              });
            },
            child: Text('Back to Edit'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateContent,
            icon: _isGenerating
              ? SizedBox(
                  width: 32,
                  height: 32,
                  child: Transform.scale(
                    scale: 0.45, // Makes it half the size
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: CircularProgressIndicator(
                        strokeWidth: 9,
                        color: Colors.white,
                        strokeCap: StrokeCap.square,
                      ),
                    ),
                  ),
                )
              : Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}