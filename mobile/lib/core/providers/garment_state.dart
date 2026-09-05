import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/garment.dart';

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
