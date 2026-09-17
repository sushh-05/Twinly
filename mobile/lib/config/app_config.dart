const String revenueCatAndroidApiKey = String.fromEnvironment(
  'REVENUECAT_ANDROID_API_KEY',
);

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const demoMode =
      String.fromEnvironment('DEMO_MODE', defaultValue: 'false') == 'true';
  static const useRevenueCat =
      String.fromEnvironment('USE_REVENUECAT', defaultValue: 'false') == 'true';
  static const revenueCatAndroidKey = revenueCatAndroidApiKey;
  static const revenueCatEntitlement = 'twinly_pro';
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: '',
  );
  static const privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );
  static const deleteAccountUrl = String.fromEnvironment(
    'DELETE_ACCOUNT_URL',
    defaultValue: '',
  );
}
