# Twilio SMS Verification Setup Guide

This guide will help you set up Twilio SMS verification for the Workie mobile app.

## Prerequisites

1. A Twilio account
2. Flutter development environment
3. Android/iOS device or emulator for testing

## Step 1: Create a Twilio Account

1. Go to [https://www.twilio.com](https://www.twilio.com)
2. Sign up for a new account
3. Verify your email address and phone number
4. Complete the account setup process

## Step 2: Get Twilio Credentials

1. Log in to your Twilio Console
2. Navigate to the Dashboard
3. Copy your **Account SID** and **Auth Token**
4. Keep these credentials secure - you'll need them in Step 4

## Step 3: Purchase a Phone Number

1. In the Twilio Console, go to **Phone Numbers** > **Manage** > **Buy a number**
2. Choose your country
3. Select a number with **SMS** capabilities
4. Purchase the number
5. Note down the phone number (it will be in format +1234567890)

## Step 4: Configure the App

1. Open `lib/services/twilio_config.dart`
2. Replace the placeholder values with your actual Twilio credentials:

```dart
class TwilioConfig {
  // Replace with your actual Twilio Account SID
  static const String accountSid = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  
  // Replace with your actual Twilio Auth Token  
  static const String authToken = 'your_actual_auth_token_here';
  
  // Replace with your Twilio phone number
  static const String fromPhoneNumber = '+1234567890';
  
  // Update country code if needed (currently set to +94 for Sri Lanka)
  static const String defaultCountryCode = '+94';
}
```

## Step 5: Install Dependencies

Run the following command in your project root:

```bash
flutter pub get
```

## Step 6: Test the Integration

1. Run the app on a device or emulator
2. Navigate to the mobile verification screen
3. Enter a valid phone number
4. Tap "Send Code"
5. Check your phone for the SMS with the 5-digit code
6. Enter the code and tap "Verify"

## Troubleshooting

### Common Issues

1. **SMS not received**
   - Check if the phone number is correctly formatted
   - Verify your Twilio account has sufficient balance
   - Check Twilio logs in the Console for error messages

2. **Invalid credentials error**
   - Double-check your Account SID and Auth Token
   - Ensure there are no extra spaces or characters

3. **Phone number format issues**
   - Make sure the "From" number includes country code (+1234567890)
   - Verify the destination number format matches your country

4. **Network errors**
   - Check internet connectivity
   - Verify firewall/proxy settings aren't blocking requests

### Testing with Trial Account

If you're using a Twilio trial account:
- You can only send SMS to verified phone numbers
- Add test phone numbers in Twilio Console under **Phone Numbers** > **Manage** > **Verified Caller IDs**
- Trial accounts have limited credits

## Security Best Practices

1. **Never commit real credentials to version control**
2. **Use environment variables in production**
3. **Implement rate limiting to prevent abuse**
4. **Add proper phone number validation**
5. **Monitor usage in Twilio Console**

## Production Deployment

For production deployment:

1. **Upgrade from trial account**
2. **Use environment variables for credentials**
3. **Implement proper error handling**
4. **Add logging and monitoring**
5. **Set up webhook endpoints for delivery status**

## Support

- Twilio Documentation: [https://www.twilio.com/docs](https://www.twilio.com/docs)
- Twilio Support: Available through Twilio Console
- Flutter Documentation: [https://flutter.dev/docs](https://flutter.dev/docs)

## File Structure

```
lib/
├── services/
│   ├── twilio_service.dart     # Main Twilio integration service
│   └── twilio_config.dart      # Configuration file for credentials
└── pofile_setup/verification/worker/
    └── mobile_verification.dart # Mobile verification UI
```

## Features Implemented

- ✅ Generate 5-digit verification codes
- ✅ Send SMS via Twilio API
- ✅ Store verification codes in SharedPreferences
- ✅ Verify entered codes against stored codes
- ✅ Resend functionality with countdown timer
- ✅ Proper error handling and user feedback
- ✅ Phone number formatting
- ✅ Input validation and sanitization