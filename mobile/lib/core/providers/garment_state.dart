import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/garment.dart';
import '../data/garment_catalog.dart';
import '../services/twinly_api_service.dart';

class CatalogState {
  const CatalogState({
    required this.garments,
    required this.usingOfflineCatalog,
  });
  final List<Garment> garments;
  final bool usingOfflineCatalog;
}

final twinlyApiServiceProvider = Provider<TwinlyApiService>(
  (ref) => TwinlyApiService(),
);
final remoteGarmentsProvider = FutureProvider<CatalogState>((ref) async {
  try {
    return CatalogState(
      garments: await ref.read(twinlyApiServiceProvider).getGarments(),
      usingOfflineCatalog: false,
    );
  } catch (_) {
    if (garmentCatalog.isNotEmpty) {
      return const CatalogState(
        garments: garmentCatalog,
        usingOfflineCatalog: true,
      );
    }
    rethrow;
  }
});

class SelectedGarmentNotifier extends Notifier<Garment?> {
  @override
  Garment? build() => null;

  void select(Garment garment) => state = garment;

  void clear() => state = null;
}

final selectedGarmentProvider =
    NotifierProvider<SelectedGarmentNotifier, Garment?>(
      SelectedGarmentNotifier.new,
    );
