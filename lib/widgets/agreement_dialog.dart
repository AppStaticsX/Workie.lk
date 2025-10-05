import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../screens/terms_privacy_page.dart';
import '../values/dimension.dart';

class AgreementDialog extends StatelessWidget {
  final List<Widget> actions;
  final String title;
  final String contentText;

  const AgreementDialog({
    super.key,
    required this.actions,
    this.title = 'Terms of Use & Privacy Policy',
    this.contentText = 'I confirm that I have read, consent and agree to WORKIE\'s ',
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title, style: TextStyle(fontFamily: 'Google Sans'),),
      content: Padding(
        padding: const EdgeInsets.only(top: AppDimension.paddingDefault),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Google Sans'),
            children: [
              TextSpan(
                text: contentText),
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,  // Typically blue for links in iOS
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const TermsAndPrivacyPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // Start from bottom
                          const end = Offset.zero; // End at normal position
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                    if (kDebugMode) {
                      print('Terms of Use tapped!');
                    }
                  },
              ),
              TextSpan(text: ' and ',
              style: TextStyle(
              )),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,  // Typically blue for links in iOS
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const TermsAndPrivacyPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // Start from bottom
                          const end = Offset.zero; // End at normal position
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                    if (kDebugMode) {
                      print('Privacy Policy tapped!');
                    }
                  },
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }
}

void showCustomAlertDialog(BuildContext context, List<Widget> actions) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AgreementDialog(actions: actions);
    },
  );
}
