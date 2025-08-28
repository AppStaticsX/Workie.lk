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
            const SizedBox(height: 24),
            Text(
              'Now, add a title to show the work you do.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Clients see this first, so make it clear. Describe the work you do in your own words.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface,
                height: 1.3
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Work Title',
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
                hintText: 'Ex: Skilled Carpenter for Custom Furniture & Wood Work',
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
