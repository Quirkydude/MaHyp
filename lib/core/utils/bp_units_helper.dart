import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

/// Helper class for BP unit conversion
class BpUnitsHelper {
  /// Convert mmHg to the user's preferred units
  static String formatBpValue(int mmHgValue, String units) {
    if (units == 'kPa') {
      // Convert mmHg to kPa (1 mmHg = 0.133322 kPa)
      final kPaValue = mmHgValue * 0.133322;
      return kPaValue.toStringAsFixed(1);
    }
    return mmHgValue.toString();
  }

  /// Format a BP reading like "120/80" or "16.0/10.7"
  static String formatBpReading(int systolic, int diastolic, String units) {
    return '${formatBpValue(systolic, units)}/${formatBpValue(diastolic, units)}';
  }

  /// Get the unit label
  static String getUnitLabel(String units) {
    return units == 'kPa' ? 'kPa' : 'mmHg';
  }
}

/// Provider for BP units setting
final bpUnitsFormatterProvider = Provider<String>((ref) {
  return ref.watch(bpUnitsProvider);
});
