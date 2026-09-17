# Twinly Privacy Policy

**Last updated:** September 16, 2026
**Developer:** Team Sapphire
**Privacy contact:** sushdevv05@gmail.com

This Privacy Policy describes the current behavior of the Twinly Flutter application and its connected services.

## 1. Information Twinly processes

### Account and profile information

Twinly uses Firebase Authentication for email/password sign-up, sign-in, password reset, sign-out, and Firebase account deletion. The app stores the entered name, email address, and gender preference locally on the device using `SharedPreferences`.

The app also stores fashion and avatar information locally, including height, shoulder width, bust/chest, waist, hip, inseam, body frame, skin tone, hair type, hair color, fit preference, style preference, and budget. The app's current profile implementation does not use a Firestore client or a Firebase Storage client.

When profile onboarding is completed, the app also attempts to send the fashion profile to the Express API at `POST /api/profile`. The server writes that request body to a UID-scoped file under `server/data/profiles/`.

### Saved looks and usage data

Saved fashion looks, including their generated image URL, garment information, fit-guide result, identifier, and creation time, are stored locally with `SharedPreferences` under the app's saved-looks key. Usage-limit counters and avatar profiles are also stored locally.

The current saved-fashion-look screen supports viewing and sharing a generated image URL. The current implementation does not provide a saved-look deletion method.

### Garment images and generated previews

If you choose to upload a garment image, Twinly reads the image from the device and sends its bytes to the Express API as a multipart request for garment analysis. If you provide a product URL, Twinly sends that URL to the API instead.

When you generate a try-on preview, Twinly can send the garment image bytes, fashion profile, garment data, and optional garment URL to the Express API. The API processes the request using its configured provider integrations and returns an image URL. Twinly stores that returned URL in the local saved-look record when you save the look.

The repository does not establish how long an external image-generation provider retains uploaded inputs or generated outputs. It also does not contain a server-side media deletion endpoint. Those retention and deletion terms must be confirmed with the configured providers before publication.

### Purchases and subscriptions

When RevenueCat is enabled on a supported native platform, Twinly configures the RevenueCat SDK, requests customer information and offerings, processes purchases, restores purchases, and listens for customer-information updates. The app checks the RevenueCat entitlement identifier:

```text
twinly_pro
```

The current app code does not pass fashion measurements or image bytes directly to RevenueCat. RevenueCat's own privacy policy and applicable store terms govern the purchase and subscription data it processes.

### Analytics and crash reporting

No analytics SDK, crash-reporting SDK, analytics event calls, or crash-reporting calls were found in the current `mobile/pubspec.yaml` or `mobile/lib/` implementation. This policy therefore does not state that Twinly currently collects analytics or crash reports.

### Merchant and affiliate links

No merchant checkout links, affiliate links, affiliate identifiers, or merchant-link tracking implementation were found in the current repository. The catalog currently contains product and image data, but the implementation does not establish an affiliate relationship or send users to a merchant checkout.

## 2. How Twinly uses this information

The current implementation uses this information to:

- authenticate users and manage their Firebase account;
- build and update a local avatar and fashion profile;
- calculate fit-guide recommendations;
- analyze selected garment images or product URLs;
- request generated try-on previews from the Express API;
- display and locally save generated looks;
- enforce local free-tier usage limits; and
- determine premium access through RevenueCat when RevenueCat is enabled.

The repository does not provide a basis for claiming that Twinly sells personal information, uses information for advertising, performs facial recognition, or uses analytics. Those statements should not be added unless the implementation changes and the policy is updated.

## 3. Sharing and service providers

Depending on the feature and configuration used, information may be sent to:

- **Firebase Authentication**, for account operations;
- **Twinly's Express API**, for profile saving, garment analysis, and try-on generation;
- **The image-generation or garment-analysis providers configured by the Express API**, when those server features are enabled; and
- **RevenueCat and the relevant app store**, for purchases, subscriptions, and entitlement status.

The current repository does not identify a single fixed image provider in this policy because the Express API selects providers from its server configuration. The deployed server configuration and each provider's privacy terms must be reviewed before publication.

## 4. Local storage and retention

The app stores profile data, avatar data, usage counters, and saved-look records in local app storage through `SharedPreferences`. The current code has no documented automatic retention schedule. These records may remain on the device until the app's account-deletion workflow, app data removal, or uninstall.

The Express API writes the submitted profile to a UID-scoped file under `server/data/profiles/`. The authenticated `DELETE /api/account` endpoint removes that profile file. The repository contains no automatic retention job. Retention of uploaded inputs and generated image URLs outside the device is not defined by the current code.

## 5. Deletion and account requests

The in-app account deletion action in `mobile/lib/features/account/screen.dart` uses `AccountDeletionService` to coordinate deletion. With Demo Mode disabled, it sends the current Firebase ID token to the authenticated `DELETE /api/account` endpoint, deletes the Firebase Auth user, and clears these local `SharedPreferences` keys: `user_name`, `user_email`, `user_is_feminine`, `twinly.fashion_profile`, `twinly.fashion_saved_looks`, `twinly_saved_profiles_json`, `twinly_active_profile_id`, `usage_tries`, `usage_saves`, and `usage_last_garment`. If Firebase requires recent authentication, the app requests the password and retries with email/password reauthentication. The server deletion is UID-scoped and idempotent; a failed server deletion keeps the Firebase account so the request can be retried. In Demo Mode, only local data is cleared.

The deletion tests cover successful deletion, Firebase failure, recent-login reauthentication, server failure, repeated deletion, local cleanup, and Demo Mode. These tests do not prove deletion of data retained by external image providers. The current server no longer uploads request images to Catbox or another public temporary host, but configured providers may return generated image URLs and their retention terms are not controlled by Twinly. Accordingly, Twinly must not claim complete deletion of third-party media until each production provider's retention/deletion behavior is verified or the architecture is changed to avoid persistent third-party media.

Requests for deletion can also be sent to sushdevv05@gmail.com. Third-party image-provider retention and the deployment's backup policy may affect how quickly all copies can be removed.

## 6. Security

The app uses the security mechanisms provided by Firebase, RevenueCat, HTTPS-capable APIs, and the configured hosting/provider environments. The repository does not provide a complete security or retention audit, and no method of transmission or storage can be guaranteed to be completely secure.

## 7. Children's privacy

Twinly is not intended for use by anyone under 16 years of age. We do not knowingly collect information from children under 16. If we learn that we have collected data from a child under 16, we will delete it.

## 8. Changes to this policy

Twinly may update this policy when the implementation, connected services, or legal requirements change. The updated policy will include a new effective date.

## 9. Contact

For privacy questions or deletion requests, contact:

**sushdevv05@gmail.com**
