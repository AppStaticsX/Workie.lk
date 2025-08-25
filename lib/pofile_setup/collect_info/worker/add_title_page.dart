import 'package:flutter/material.dart';
import 'package:workie/widgets/simple_textfeild.dart';

class AddTitlePage extends StatefulWidget {
  final ValueChanged<bool>? onTextChanged;

  const AddTitlePage({
    super.key,
    this.onTextChanged
  });

  @override
  State<AddTitlePage> createState() => _AddTitlePageState();
}

class _AddTitlePageState extends State<AddTitlePage> {
  final TextEditingController _professionController = TextEditingController();
  int _letterCount = 0;

  @override
  void initState() {
    super.initState();
    _professionController.addListener(_countLetters);
  }

  void _countLetters() {
    setState(() {
      String text = _professionController.text;
      _letterCount = text.length;
      _notifyParent();
    });
  }

  void _notifyParent() {
    widget.onTextChanged?.call(_professionController.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Got it. Now, add a title to tell the world what you do.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'It\'s the very first thing clients see, so make it count. Stand out by describing your expertise in your own word.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your professional role',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            SimpleTextfield(
              focusBorderColor: Colors.white,
                paddingHorizontal: 0,
                controller: _professionController,
                hintText: 'Example: Professional Carpenter Specializing in Custom Furniture & Woodcraft',
                obscureText: false,
                maxLines: 3,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_letterCount/99 letters',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
