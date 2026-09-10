/// Centralized list of antihypertensive medications organized by class.
/// Provided by Prof. Biney's team for the MaHyp app.
///
/// Each entry includes the drug name with dosage (e.g., "Amlodipine 5 mg").
/// Used in the medication selection dropdown.
class MedicationData {
  MedicationData._();

  /// All medication entries with name and dosage
  static const List<String> allMedications = [
    // Thiazide / thiazide-like diuretics
    'Bendroflumethiazide 2.5 mg',
    'Bendroflumethiazide 5 mg',
    'Hydrochlorothiazide 12.5 mg',
    'Hydrochlorothiazide 25 mg',
    'Indapamide 1.5 mg',
    'Indapamide 2.5 mg',
    'Chlorthalidone 25 mg',

    // Loop diuretics
    'Furosemide 20 mg',
    'Furosemide 40 mg',

    // Potassium-sparing diuretics
    'Amiloride 5 mg',

    // Aldosterone receptor blockers
    'Spironolactone 25 mg',
    'Spironolactone 50 mg',

    // Beta blockers
    'Atenolol 25 mg',
    'Atenolol 50 mg',
    'Atenolol 100 mg',
    'Bisoprolol 2.5 mg',
    'Bisoprolol 5 mg',
    'Carvedilol 6.25 mg',
    'Carvedilol 12.5 mg',
    'Carvedilol 25 mg',
    'Labetalol 100 mg',
    'Labetalol 200 mg',
    'Propranolol 10 mg',
    'Propranolol 20 mg',
    'Propranolol 40 mg',
    'Metoprolol 25 mg',

    // ACE inhibitors
    'Lisinopril 2.5 mg',
    'Lisinopril 5 mg',
    'Lisinopril 10 mg',
    'Lisinopril 20 mg',
    'Enalapril 5 mg',
    'Enalapril 10 mg',
    'Captopril 25 mg',
    'Ramipril 5 mg',

    // Angiotensin II receptor blockers (ARBs)
    'Losartan 50 mg',
    'Losartan 100 mg',
    'Valsartan 80 mg',
    'Valsartan 160 mg',
    'Candesartan 2 mg',
    'Candesartan 4 mg',
    'Telmisartan 40 mg',
    'Telmisartan 80 mg',

    // Calcium channel blockers - dihydropyridines
    'Amlodipine 5 mg',
    'Amlodipine 10 mg',
    'Nifedipine 20 mg',
    'Nifedipine 30 mg',
    'Nifedipine 60 mg',

    // Alpha-1 blockers
    'Prazosin 1 mg',
    'Prazosin 2 mg',
    'Doxazosin 1 mg',
    'Doxazosin 4 mg',

    // Central acting antihypertensives
    'Methyldopa 250 mg',
    'Methyldopa 500 mg',

    // Direct vasodilators
    'Hydralazine 25 mg',
    'Hydralazine 50 mg',
  ];

  /// Medication classes with their corresponding medications
  static const Map<String, List<String>> medicationsByClass = {
    'Thiazide / Thiazide-like Diuretics': [
      'Bendroflumethiazide 2.5 mg',
      'Bendroflumethiazide 5 mg',
      'Hydrochlorothiazide 12.5 mg',
      'Hydrochlorothiazide 25 mg',
      'Indapamide 1.5 mg',
      'Indapamide 2.5 mg',
      'Chlorthalidone 25 mg',
    ],
    'Loop Diuretics': [
      'Furosemide 20 mg',
      'Furosemide 40 mg',
    ],
    'Potassium-sparing Diuretics': [
      'Amiloride 5 mg',
    ],
    'Aldosterone Receptor Blockers': [
      'Spironolactone 25 mg',
      'Spironolactone 50 mg',
    ],
    'Beta Blockers': [
      'Atenolol 25 mg',
      'Atenolol 50 mg',
      'Atenolol 100 mg',
      'Bisoprolol 2.5 mg',
      'Bisoprolol 5 mg',
      'Carvedilol 6.25 mg',
      'Carvedilol 12.5 mg',
      'Carvedilol 25 mg',
      'Labetalol 100 mg',
      'Labetalol 200 mg',
      'Propranolol 10 mg',
      'Propranolol 20 mg',
      'Propranolol 40 mg',
      'Metoprolol 25 mg',
    ],
    'ACE Inhibitors': [
      'Lisinopril 2.5 mg',
      'Lisinopril 5 mg',
      'Lisinopril 10 mg',
      'Lisinopril 20 mg',
      'Enalapril 5 mg',
      'Enalapril 10 mg',
      'Captopril 25 mg',
      'Ramipril 5 mg',
    ],
    'Angiotensin II Receptor Blockers (ARBs)': [
      'Losartan 50 mg',
      'Losartan 100 mg',
      'Valsartan 80 mg',
      'Valsartan 160 mg',
      'Candesartan 2 mg',
      'Candesartan 4 mg',
      'Telmisartan 40 mg',
      'Telmisartan 80 mg',
    ],
    'Calcium Channel Blockers': [
      'Amlodipine 5 mg',
      'Amlodipine 10 mg',
      'Nifedipine 20 mg',
      'Nifedipine 30 mg',
      'Nifedipine 60 mg',
    ],
    'Alpha-1 Blockers': [
      'Prazosin 1 mg',
      'Prazosin 2 mg',
      'Doxazosin 1 mg',
      'Doxazosin 4 mg',
    ],
    'Central Acting Antihypertensives': [
      'Methyldopa 250 mg',
      'Methyldopa 500 mg',
    ],
    'Direct Vasodilators': [
      'Hydralazine 25 mg',
      'Hydralazine 50 mg',
    ],
  };

  /// Get the class name for a given medication
  static String? getClassForMedication(String medication) {
    for (final entry in medicationsByClass.entries) {
      if (entry.value.contains(medication)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Parses drug name and dosage from a combined string like "Amlodipine 5 mg"
  static ({String name, String dosage}) parseMedication(String medication) {
    final regex = RegExp(r'^(.+?)\s+(\d+\.?\d*\s*mg)$', caseSensitive: false);
    final match = regex.firstMatch(medication.trim());
    if (match != null) {
      return (name: match.group(1)!.trim(), dosage: match.group(2)!.trim());
    }
    return (name: medication.trim(), dosage: '');
  }

  /// Common side effects by medication class (used in education section)
  static const Map<String, List<String>> sideEffectsByClass = {
    'Thiazide / Thiazide-like Diuretics': [
      'Frequent urination',
      'Dizziness or lightheadedness',
      'Muscle cramps',
      'Increased thirst',
      'Electrolyte imbalance (low potassium)',
      'Increased blood sugar',
    ],
    'Loop Diuretics': [
      'Frequent urination',
      'Dehydration',
      'Low potassium levels',
      'Dizziness',
      'Muscle cramps',
      'Ringing in ears (with high doses)',
    ],
    'Potassium-sparing Diuretics': [
      'High potassium levels',
      'Nausea',
      'Diarrhea',
      'Headache',
      'Dizziness',
    ],
    'Aldosterone Receptor Blockers': [
      'High potassium levels',
      'Breast tenderness',
      'Fatigue',
      'Dizziness',
      'Nausea',
    ],
    'Beta Blockers': [
      'Fatigue and tiredness',
      'Cold hands and feet',
      'Dizziness',
      'Slow heartbeat',
      'Weight gain',
      'Difficulty sleeping',
    ],
    'ACE Inhibitors': [
      'Persistent dry cough',
      'Dizziness',
      'Elevated blood potassium',
      'Fatigue',
      'Headache',
      'Loss of taste',
    ],
    'Angiotensin II Receptor Blockers (ARBs)': [
      'Dizziness',
      'Elevated blood potassium',
      'Fatigue',
      'Muscle pain',
      'Nasal congestion',
    ],
    'Calcium Channel Blockers': [
      'Swollen ankles or feet',
      'Constipation',
      'Headache',
      'Dizziness',
      'Flushing',
      'Palpitations',
    ],
    'Alpha-1 Blockers': [
      'Dizziness (especially when standing)',
      'Headache',
      'Fatigue',
      'Nasal congestion',
      'Fast heartbeat',
    ],
    'Central Acting Antihypertensives': [
      'Drowsiness',
      'Dry mouth',
      'Dizziness',
      'Constipation',
      'Fatigue',
      'Depression',
    ],
    'Direct Vasodilators': [
      'Headache',
      'Fast heartbeat',
      'Fluid retention',
      'Dizziness',
      'Nausea',
      'Joint pain (with hydralazine)',
    ],
  };
}
