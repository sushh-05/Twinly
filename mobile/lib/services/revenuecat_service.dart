import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService extends ChangeNotifier {
  RevenueCatService({required this.enabled, String? initialError})
      : errorMessage = initialError;
  final bool enabled;
  static const entitlementId = 'twinly_pro';
  CustomerInfo? customerInfo;
  Offering? offering;
  bool loading = false;
  String? errorMessage;

  static void validateAndroidApiKey(String apiKey) {
    if (!kReleaseMode) return;
    if (apiKey.isEmpty || apiKey.startsWith('test_')) {
      throw StateError(
        'RevenueCat Android API key is missing or invalid for a release build. '
        'Provide REVENUECAT_ANDROID_API_KEY with a production public SDK key.',
      );
    }
  }

  bool get isAvailable => enabled;
  bool get isPremium =>
      customerInfo?.entitlements.active.containsKey(entitlementId) ?? false;
  List<Package> get packages => offering?.availablePackages ?? const [];

  void listenForUpdates() {
    if (!enabled) return;
    Purchases.addCustomerInfoUpdateListener((info) {
      customerInfo = info;
      notifyListeners();
    });
  }

  Future<void> identify(String uid) async {
    if (!enabled) return;
    try {
      customerInfo = (await Purchases.logIn(uid)).customerInfo;
      notifyListeners();
    } catch (error) {
      debugPrint('RevenueCat login failed: $error');
    }
  }

  Future<void> refresh() async {
    if (!enabled) return;
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      customerInfo = await Purchases.getCustomerInfo();
      offering = (await Purchases.getOfferings()).current;
      if (offering == null) {
        errorMessage = 'No premium plans are available yet.';
      }
    } catch (error) {
      debugPrint('RevenueCat refresh failed: $error');
      errorMessage = 'Premium plans are temporarily unavailable.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> purchase(Package package) async {
    if (!enabled) return false;
    try {
      customerInfo = (await Purchases.purchase(PurchaseParams.package(package)))
          .customerInfo;
      notifyListeners();
      return isPremium;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) !=
          PurchasesErrorCode.purchaseCancelledError) {
        errorMessage = 'Purchase could not be completed.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Purchase could not be completed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> restore() async {
    if (!enabled) return false;
    try {
      customerInfo = await Purchases.restorePurchases();
      notifyListeners();
      return isPremium;
    } catch (_) {
      errorMessage = 'Purchases could not be restored.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (!enabled) return;
    try {
      await Purchases.logOut();
    } catch (error) {
      debugPrint('RevenueCat logout failed: $error');
    }
  }
}
