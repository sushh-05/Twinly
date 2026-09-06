import '../providers/avatar_state.dart';
import '../../models/garment.dart';

enum FitVerdict { tight, good, loose }

class RegionFit {
  final String region;
  final FitVerdict verdict;
  final String note;
  const RegionFit(this.region, this.verdict, this.note);
}

// delta = user's measurement minus the garment's chart measurement.
// Positive delta = user is bigger than the garment there = tight.
// Negative delta = user is smaller than the garment there = loose.
List<RegionFit> computeFit(AvatarMeasurements m, Garment g) {
  RegionFit evaluate(String region, double userVal, double chartVal) {
    final delta = userVal - chartVal;
    if (delta > 3) {
      return RegionFit(region, FitVerdict.tight, 'Snug at $region');
    }
    if (delta < -3) {
      return RegionFit(region, FitVerdict.loose, 'Loose at $region');
    }
    return RegionFit(region, FitVerdict.good, 'Good fit at $region');
  }

  return [
    evaluate('chest', m.chest, g.chartChest),
    evaluate('waist', m.waist, g.chartWaist),
    evaluate('hip', m.hip, g.chartHip),
  ];
}
