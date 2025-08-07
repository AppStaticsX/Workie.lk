import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'MealMate'**
  String get appName;

  /// Application subtitle/tagline
  ///
  /// In en, this message translates to:
  /// **'EMPOWERING PEOPLE'**
  String get workieSubtitle;

  /// Welcome message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get welcomeBack;

  /// Guide text displayed on the login screen
  ///
  /// In en, this message translates to:
  /// **'Let’s get you back in! Enter your login details to access your account.'**
  String get loginGuide;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Placeholder text for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enterAddress;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Error message when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Error message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// Error message when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Error message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Terms agreement checkbox text
  ///
  /// In en, this message translates to:
  /// **'I confirm that I have read, consent and agree to WORKIE\'s '**
  String get termsAgreement;

  /// Terms of Use link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// Conjunction word between Terms of Use and Privacy Policy
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Privacy Policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy.'**
  String get privacyPolicy;

  /// End part of terms agreement text
  ///
  /// In en, this message translates to:
  /// **'null'**
  String get termsAgreementFull;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// Contact us button text
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text separator for social login options
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orContinueWith;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Log in with Google'**
  String get continueWithGoogle;

  /// Sign-up prompt text
  ///
  /// In en, this message translates to:
  /// **'Not a member?'**
  String get notAMember;

  /// Sign-up link text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupNow;

  /// Cancel button text in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Agree button text in agreement dialog
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// Guide text displayed on the signup screen
  ///
  /// In en, this message translates to:
  /// **'Ready to work?\nJoin with our family to build your future'**
  String get signupGuide;

  /// Guide text displayed on the email verification screen
  ///
  /// In en, this message translates to:
  /// **'We have just send email verification link on your\nemail. Please check email and click on that link\nto verify your Email address.\n\nIf not auto redirected after verification, click on the\nContinue button.'**
  String get emailVerificationGuide;

  /// Subtitle text for the first onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Whether you\'re looking for work or hiring talent, we match you with the right opportunities and professionals in seconds.'**
  String get onBoardSubtitle1;

  /// Text separator for social login options
  ///
  /// In en, this message translates to:
  /// **'Or Sign in with'**
  String get orSigninWith;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
