import 'package:flutter/material.dart';
import 'package:workie/values/color.dart';
import 'package:workie/widgets/simple_textfeild.dart';

class AddOverviewPage extends StatefulWidget {
  final ValueChanged<bool>? onTextChanged;

  const AddOverviewPage({
    super.key,
    this.onTextChanged
  });

  @override
  State<AddOverviewPage> createState() => _AddTitlePageState();
}

class _AddTitlePageState extends State<AddOverviewPage> {
  final TextEditingController _overviewController = TextEditingController();
  int _letterCount = 0;

  @override
  void initState() {
    super.initState();
    _overviewController.addListener(_countLetters);
  }

  void _countLetters() {
    setState(() {
      String text = _overviewController.text;
      _letterCount = text.length;
      _notifyParent();
    });
  }

  void _notifyParent() {
    widget.onTextChanged?.call(_overviewController.text.isNotEmpty);
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
              'Great. Now write a bio to tell the world about yourself',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Let others know about you in a few lines. What work are you good at? Write it clearly in a short paragraph. You can change it later, but read it again now to make sure there are no mistakes.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSilver,
                  height: 1.3
              ),
            ),
            const SizedBox(height: 32),
            SimpleTextfield(
              lengthLimit: 400,
              focusBorderColor: Theme.of(context).colorScheme.inverseSurface,
              paddingHorizontal: 0,
              controller: _overviewController,
              hintText: 'Write your main skills, work experiences, and interests. This is one of the first things people will see on your profile.',
              obscureText: false,
              maxLines: 6,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'At least 100 Characters',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13
                  ),
                ),
                Text(
                  '$_letterCount/400 letters',
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
