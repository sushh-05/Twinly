import 'package:flutter/foundation.dart';

import '../../models/garment.dart';
import '../data/garment_catalog.dart';
import '../services/twinly_api_service.dart';

class CatalogState extends ChangeNotifier {
  List<Garment> garments = garmentCatalog;
  bool usingOfflineCatalog = true;
  bool loading = true;
  CatalogState() {
    load();
  }
  Future<void> load() async {
    try {
      garments = await TwinlyApiService().getGarments();
      usingOfflineCatalog = false;
    } catch (_) {}
    loading = false;
    notifyListeners();
  }
}

class SelectedGarmentState extends ChangeNotifier {
  Garment? value;

  void select(Garment garment) {
    value = garment;
    notifyListeners();
  }

  void clear() {
    value = null;
    notifyListeners();
  }
}
