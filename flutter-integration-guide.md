# MaHyp Illustrations - Flutter Integration Guide

## Overview
This package contains 10 custom vector illustrations designed for the MaHyp (My Hypertension Monitor) mobile app.

## Files Included

### Primary Feature Illustrations
1. `heart_monitor.svg` - Real-time heart rate monitoring
2. `blood_pressure_check.svg` - Blood pressure tracking
3. `medication_reminder.svg` - Medication schedule reminders
4. `health_data.svg` - Health analytics and trends
5. `doctor_consult.svg` - Telemedicine consultation
6. `health_goals.svg` - Wellness targets and achievements

### Onboarding & UI States
7. `onboarding_welcome.svg` - Welcome/first screen
8. `success_state.svg` - Achievement and confirmation
9. `empty_state.svg` - No data available
10. `calendar_reminder.svg` - Schedule and appointments

## Flutter Integration Steps

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_svg: ^2.0.10
```

Run:
```bash
flutter pub get
```

### Step 2: Add SVG Files to Assets

1. Create a folder structure:
   ```
   assets/
     └── illustrations/
         ├── heart_monitor.svg
         ├── blood_pressure_check.svg
         ├── medication_reminder.svg
         ├── health_data.svg
         ├── doctor_consult.svg
         ├── health_goals.svg
         ├── onboarding_welcome.svg
         ├── success_state.svg
         ├── empty_state.svg
         └── calendar_reminder.svg
   ```

2. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/illustrations/
   ```

### Step 3: Usage Examples

#### Basic Usage

```dart
import 'package:flutter_svg/flutter_svg.dart';

// Display an illustration
SvgPicture.asset(
  'assets/illustrations/heart_monitor.svg',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
)
```

#### Onboarding Screen Example

```dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/illustrations/onboarding_welcome.svg',
                height: 250,
              ),
              SizedBox(height: 32),
              Text(
                'Welcome to MaHyp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your personal health companion for monitoring blood pressure and maintaining heart health.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C9D6),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Empty State Example

```dart
class EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_state.svg',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 24),
          Text(
            'No Readings Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start tracking your blood pressure\nto see your health journey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00C9D6),
            ),
            child: Text('Add First Reading'),
          ),
        ],
      ),
    );
  }
}
```

#### Feature Card Example

```dart
class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String illustrationPath;

  const FeatureCard({
    required this.title,
    required this.description,
    required this.illustrationPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0FFFE), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF5CE1E6).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            illustrationPath,
            width: 80,
            height: 80,
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Usage
GridView.count(
  crossAxisCount: 2,
  children: [
    FeatureCard(
      title: 'Track BP',
      description: 'Monitor daily readings',
      illustrationPath: 'assets/illustrations/blood_pressure_check.svg',
    ),
    FeatureCard(
      title: 'Medications',
      description: 'Set reminders',
      illustrationPath: 'assets/illustrations/medication_reminder.svg',
    ),
    FeatureCard(
      title: 'Analytics',
      description: 'View trends',
      illustrationPath: 'assets/illustrations/health_data.svg',
    ),
  ],
)
```

#### Success Dialog Example

```dart
void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustrations/success_state.svg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 16),
            Text(
              'Success!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your reading has been saved successfully.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00C9D6),
              ),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## Color Palette Reference

Use these colors to match the illustrations:

```dart
class AppColors {
  static const primaryTurquoise = Color(0xFF00C9D6);
  static const softCyan = Color(0xFF5CE1E6);
  static const turquoiseDark = Color(0xFF00A5B0);
  static const healthRed = Color(0xFFDC2626);
  static const lightCyan = Color(0xFF81ECEC);
  static const teal = Color(0xFF00CEC9);
}
```

## Design Guidelines

### Sizing Recommendations
- **Onboarding screens**: 200-300px height
- **Feature cards**: 60-100px
- **Empty states**: 150-250px
- **Success dialogs**: 120-180px
- **Dashboard icons**: 40-60px

### Accessibility
- All illustrations maintain WCAG AA contrast ratios
- Large, clear shapes optimized for elderly users
- Works well on light backgrounds

### Best Practices
1. Always specify width and height for consistent rendering
2. Use `BoxFit.contain` to maintain aspect ratio
3. Add proper spacing around illustrations (16-24px padding)
4. Consider adding loading placeholders for better UX

## Troubleshooting

### Issue: SVG not displaying
- Check that the asset path is correct in pubspec.yaml
- Verify the SVG file is in the assets/illustrations/ folder
- Run `flutter clean` and `flutter pub get`

### Issue: Animation not working
- Note: SVG animations (SMIL) are not supported in flutter_svg
- Use Flutter's animation framework for animated effects

### Issue: Colors not matching
- Ensure you're using the exact color codes from AppColors
- Some SVG colors are baked into the illustration files

## Support Files

All SVG files are provided in the `/svg-exports/` folder.

---

**Design System**: MaHyp Health Monitoring App
**Version**: 1.0
**Last Updated**: March 2026
