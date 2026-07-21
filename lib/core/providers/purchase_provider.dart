import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/services/purchase_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Streams RevenueCat CustomerInfo updates. Emits null until configured.
final customerInfoProvider = StreamProvider<CustomerInfo?>((ref) {
  if (!PurchaseService.instance.isConfigured) return Stream.value(null);

  final controller = StreamController<CustomerInfo?>();
  void listener(CustomerInfo info) => controller.add(info);
  Purchases.addCustomerInfoUpdateListener(listener);
  // Prime with whatever we already know.
  Purchases.getCustomerInfo().then(controller.add).catchError((_) {});

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });
  return controller.stream;
});

/// Whether the RevenueCat "pro" entitlement is currently active.
final revenueCatProProvider = Provider<bool>((ref) {
  final info = ref.watch(customerInfoProvider).value;
  if (info == null) return false;
  return PurchaseService.instance.entitlementActive(info);
});

/// The package to purchase (price shown on the paywall). Null until an offering
/// is configured in RevenueCat.
final proPackageProvider = FutureProvider<Package?>((ref) {
  // Re-fetch when entitlement state changes (e.g. after a restore).
  ref.watch(customerInfoProvider);
  return PurchaseService.instance.proPackage();
});
