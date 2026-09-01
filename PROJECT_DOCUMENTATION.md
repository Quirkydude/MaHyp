# MaHyp Project Documentation

**Application:** MaHyp (Hypertension Self-Management)  
**Version:** 1.0.0 (Build 2)  
**Platform:** Android and iOS (Flutter)  
**Package ID:** `com.mahypucc.app`  
**Document date:** September 2025

---

## 1. Executive Summary

MaHyp is a mobile health application built to help people manage hypertension at home. The app is designed with elderly users in mind: large text, simple navigation, portrait-only layout, and high-contrast visuals.

Users can record blood pressure readings, track medications with reminders, view health trends, read educational content, and reach emergency contacts when needed. All personal health data is stored securely in Firebase and tied to the user's account.

The application is functional end to end. Authentication, data storage, notifications, reporting, and the main user flows are implemented and working. This document describes what has been built, how it works, and what is required to run and maintain the project.

---

## 2. About the Application

### 2.1 Purpose

Hypertension affects a large number of adults, and consistent monitoring is one of the most effective ways to manage it. MaHyp gives users a single place to log readings, stay on top of medication schedules, and understand their numbers over time.

The app does not replace a doctor. It supports daily self-management and gives users something concrete to bring to medical appointments, such as BP history and medication adherence reports.

### 2.2 Design Principles

The interface was built around a few practical goals:

- **Accessibility:** Touch targets are at least 48dp. Users can switch between four font sizes and enable dark mode.
- **Simplicity:** The main navigation uses five bottom tabs. Common actions (record BP, take medication) are reachable from the dashboard.
- **Clarity:** Blood pressure results are colour-coded into three categories so users can understand them at a glance.
- **Safety:** Crisis-level readings trigger an emergency screen with guidance to seek immediate care.

---

## 3. Target Users

The primary audience is older adults living with high blood pressure. The app also works for any adult who wants to track BP and medications in a straightforward way.

Phone number verification uses SMS through Moolre, which supports Ghana-format numbers. Social login (Google and Facebook) is available as an alternative to email signup.

---

## 4. Feature Overview

### 4.1 Onboarding and Authentication

| Feature | Status | Description |
|---------|--------|-------------|
| Splash screen | Done | Shows the MaHyp logo and routes users based on login state |
| Onboarding | Done | Multi-page introduction for first-time users |
| Email and password signup | Done | Full name, email, mobile, date of birth |
| Email and password login | Done | Standard Firebase authentication |
| Email verification | Done | Required before full app access |
| Phone OTP verification | Done | SMS code sent via Moolre during signup |
| Google sign-in | Done | OAuth through Firebase |
| Facebook sign-in | Done | OAuth through Firebase |
| Apple sign-in | Not implemented | Button exists in UI but shows a "not available" message |
| Forgot password | Done | Firebase password reset email |
| Set password | Done | Post-signup password setup for email and phone paths |
| Account deletion | Done | Removes Firestore data and the Firebase Auth account |

**How signup works**

1. User fills in profile details on the signup screen.
2. If signing up with a phone number, they receive an OTP via SMS (Moolre).
3. After verification, they set a password.
4. Email users must verify their email before accessing the main app.
5. The app creates a user profile document in Firestore.

Route guards in the app router enforce these steps. Unauthenticated users are sent to login. Unverified email users are held on the verification screen.

### 4.2 Dashboard (Home)

The dashboard is the first screen after login. It shows:

- A greeting with the user's name and profile photo
- Latest blood pressure reading and category
- Medication adherence percentage for the day
- A weekly calendar for navigating dates
- Daily tasks (medications due, BP check reminders)
- Quick action buttons for recording BP and viewing health insights
- Notification badge for unread alerts

The bottom navigation bar provides access to Home, Health (BP history), Medication, Education, and Support.

### 4.3 Blood Pressure Monitoring

**Recording a reading**

Users enter systolic and diastolic values, optional heart rate, time of day, symptoms (dizziness, headache, nausea), and notes.

**Categories**

The app classifies readings using these thresholds:

| Category | Criteria | Colour |
|----------|----------|--------|
| Controlled | Below 140/90 mmHg | Green |
| Not Controlled | 140/90 or higher | Orange |
| Hypertensive Crisis | Above 180 systolic or above 120 diastolic | Red |

When a crisis reading is logged, the user is directed to an emergency page with instructions to seek immediate medical attention.

**Other BP features**

- **History:** Chronological list of past readings
- **Analysis:** Detailed breakdown of a single reading with recommendations
- **Health Insights:** 30-day averages, category distribution chart, time-of-day trends
- **BP reminders:** Configurable morning and evening local notifications
- **Export:** PDF reports shareable via the device share sheet

### 4.4 Medication Management

**Adding medications**

Users enter the medication name, dosage, frequency (once, twice, or three times daily), and schedule times.

**Daily use**

The medication screen has Today and Upcoming tabs. Each dose can be marked as taken or skipped. The app tracks adherence and shows progress on the dashboard.

**Reminders**

Local push notifications alert users when a dose is due. These can be turned on or off in Settings.

**Reports**

Users can generate a PDF medication report and share it (for example, with a doctor).

### 4.5 Patient Education

Six topics are available:

1. Understanding Hypertension
2. How to Measure Blood Pressure
3. Lifestyle Tips (diet, exercise, stress)
4. Medications Guide
5. Treatment Procedures
6. Reading Your Results

Each topic opens a detail page with written content and illustrations. A search bar filters topics by title.

### 4.6 Profile and Emergency Contacts

**Profile**

Users can view and edit their name, date of birth, mobile number, and profile photo. Photos are uploaded to Firebase Storage.

**Emergency contacts**

Users can save contacts for their doctor, family members, and pharmacist. Each contact supports a direct phone call through the device dialer.

### 4.7 Support

The Support tab includes frequently asked questions and contact options (email and phone via the device's native apps).

### 4.8 Settings

| Setting | Description |
|---------|-------------|
| Push notifications | Toggle medication reminders |
| BP reminders | Toggle daily measurement reminders |
| Dark mode | Switch between light and dark theme |
| Font size | Small, Medium, Large, or Extra Large |
| Reminder schedule | Set morning and evening reminder times |
| Privacy policy | Full in-app privacy policy page |
| Account deletion | Permanently delete account and data |
| Feedback | In-app feedback dialog |

Settings are saved locally using SharedPreferences and persist across sessions.

### 4.9 Notifications

The app generates in-app notifications for events such as high BP readings and missed medications. These are stored in Firestore and shown on the notifications screen. Unread count appears on the dashboard.

Firebase Cloud Messaging is configured for push delivery. Local notifications handle medication and BP reminders when the app is in the background.

### 4.10 Offline Support

An offline banner appears when the device loses internet connectivity. The app reads cached data where possible, but new readings and medication logs require a connection to sync with Firestore.

---

## 5. User Flows

### 5.1 New User Registration (Phone)

```
Splash → Onboarding → Sign Up → Phone Verification (OTP) → Set Password → Dashboard
```

### 5.2 New User Registration (Email)

```
Splash → Onboarding → Sign Up → Email Verification → Dashboard
```

### 5.3 Daily Use

```
Login → Dashboard → Record BP / Take Medication → View Insights
```

### 5.4 Hypertensive Crisis

```
Record BP (crisis values) → Emergency Page → Call emergency contact
```

---

## 6. Technical Architecture

### 6.1 Overview

MaHyp is a Flutter mobile application. The backend is entirely Firebase-based. There is no custom server or REST API.

```
┌─────────────────────────────────────────┐
│           Flutter App (Dart)            │
│  ┌─────────┐  ┌──────────┐  ┌────────┐ │
│  │  Pages  │  │ Providers│  │Widgets │ │
│  └────┬────┘  └────┬─────┘  └────────┘ │
│       │            │                    │
│  ┌────▼────────────▼─────────────────┐ │
│  │         Core Services             │ │
│  │  Auth, BP, Medication, Reports,   │ │
│  │  Notifications, Profile, Settings │ │
│  └────┬──────────────────────────────┘ │
└───────┼─────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────┐
│              Firebase                  │
│  Auth │ Firestore │ Storage │ FCM     │
│  Analytics │ Crashlytics              │
└───────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────┐
│         Moolre SMS API                 │
│         (Phone OTP only)               │
└───────────────────────────────────────┘
```

### 6.2 State Management

The app uses **Riverpod** for state management. Feature-specific providers handle BP readings, medications, user profile, settings, and notifications. UI pages watch these providers and rebuild when data changes.

### 6.3 Navigation

**GoRouter** handles all routing. A redirect function checks authentication and verification status on every navigation. Public routes (login, signup, onboarding) are accessible without login. Protected routes redirect unauthenticated users to the login screen.

### 6.4 Project Structure

```
lib/
├── main.dart                    App entry point
├── firebase_options.dart        Firebase configuration
├── core/
│   ├── config/                  Moolre SMS credentials
│   ├── constants/               Colours, dimensions, text styles
│   ├── router/                  Route definitions and guards
│   ├── services/                Business logic and Firebase calls
│   ├── theme/                   Light and dark themes
│   └── utils/                   Helpers (email validation, etc.)
├── features/
│   ├── auth/                    Login, signup, verification
│   ├── splash/                  Splash screen
│   ├── onboarding/              First-run introduction
│   ├── dashboard/               Home screen and widgets
│   ├── bp_monitoring/           BP recording, history, analysis
│   ├── medication/              Medication list, add/edit, reports
│   ├── education/               Health education content
│   ├── notification/            In-app notifications
│   ├── profile/                 Profile and emergency contacts
│   ├── settings/                App settings and privacy policy
│   ├── support/                 Help and FAQs
│   └── demo/                    Component testing page
├── shared/widgets/              Reusable UI components
└── illustrations/               Custom SVG illustration widgets
```

Business logic lives in `core/services/`. Feature folders contain presentation code (pages, widgets, providers) and data models. There is no separate domain or repository layer.

---

## 7. Data Model

All user data is stored in Firestore under `users/{userId}`.

### 7.1 User Profile

| Field | Type | Description |
|-------|------|-------------|
| fullName | string | User's display name |
| email | string | Account email |
| mobile | string | Phone number (optional) |
| dob | timestamp | Date of birth (optional) |
| avatarUrl | string | Profile photo URL (optional) |
| isPhoneVerified | boolean | Phone verification status |
| createdAt | timestamp | Account creation date |
| updatedAt | timestamp | Last profile update |

### 7.2 Blood Pressure Readings

Stored in `users/{userId}/bp_readings/{readingId}`.

| Field | Type | Description |
|-------|------|-------------|
| systolic | int | Systolic value (70 to 300) |
| diastolic | int | Diastolic value (40 to 200) |
| heartRate | int | Optional heart rate |
| recordedAt | timestamp | When the reading was taken |
| timeOfDay | int | Morning, afternoon, evening, or night |
| notes | string | Optional user notes |
| feltDizzy | boolean | Symptom flag |
| hadHeadache | boolean | Symptom flag |
| feltNausea | boolean | Symptom flag |

### 7.3 Medications

Stored in `users/{userId}/medications/{medicationId}`.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Medication name |
| dosage | string | Dosage description |
| frequency | string | onceDaily, twiceDaily, thriceDaily, or custom |
| createdAt | timestamp | When the medication was added |

### 7.4 Medication Logs

Stored in `users/{userId}/medication_logs/{logId}`.

| Field | Type | Description |
|-------|------|-------------|
| medicationId | string | Reference to the medication |
| doseId | string | Reference to the specific dose |
| scheduledTime | timestamp | When the dose was scheduled |
| status | string | taken, skipped, missed, or upcoming |

### 7.5 Security Rules

Firestore security rules enforce that users can only read and write their own data. BP readings are validated on write (systolic must be higher than diastolic, values within safe ranges). All other collections are denied by default.

Profile photos are stored in Firebase Storage under the user's folder.

---

## 8. External Services

| Service | Purpose |
|---------|---------|
| Firebase Authentication | User accounts (email, Google, Facebook) |
| Cloud Firestore | All app data |
| Firebase Storage | Profile photo uploads |
| Firebase Cloud Messaging | Push notifications |
| Firebase Crashlytics | Crash and error reporting |
| Firebase Analytics | Screen and event tracking |
| Moolre SMS | Phone OTP delivery during signup |
| Google Sign-In | Social authentication |
| Facebook Auth | Social authentication |

### Moolre Configuration

Phone verification requires a Moolre VAS key and an approved Sender ID. These are set either in `lib/core/config/moolre_config.dart` or passed at build time:

```
flutter run --dart-define=MOOLRE_VAS_KEY=your_key --dart-define=MOOLRE_SENDER_ID=MaHyp
```

For testing, add `--dart-define=MOOLRE_USE_SANDBOX=true` to use the Moolre sandbox environment.

Credentials can be obtained from the [Moolre dashboard](https://app.moolre.com).

---

## 9. Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.10+ |
| State management | Riverpod | 2.4+ |
| Navigation | GoRouter | 13.0+ |
| HTTP client | Dio | 5.4+ |
| Charts | fl_chart | 0.70+ |
| PDF generation | pdf | 3.11+ |
| Local storage | SharedPreferences | 2.2+ |
| Notifications | flutter_local_notifications | 18.0+ |
| Image picking | image_picker | 1.0+ |

---

## 10. Setup and Build Instructions

### 10.1 Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio (for Android builds) or Xcode (for iOS builds)
- A configured Firebase project with `firebase_options.dart` and `google-services.json` in place
- Moolre credentials for phone OTP (if testing signup)

### 10.2 Running Locally

```bash
flutter pub get
flutter doctor
flutter run
```

With Moolre credentials:

```bash
flutter run --dart-define=MOOLRE_VAS_KEY=your_key --dart-define=MOOLRE_SENDER_ID=MaHyp
```

### 10.3 Android Release Build

1. Create a signing keystore and place it in the `android/` directory.
2. Configure `android/key.properties` with keystore details.
3. Build the release bundle:

```bash
flutter build appbundle --release
```

The output AAB file is at `build/app/outputs/bundle/release/app-release.aab`.

See `GOOGLE_PLAY_PUBLISHING_GUIDE.md` for the full Play Store checklist.

### 10.4 Firestore Rules

Deploy security rules from the project root:

```bash
firebase deploy --only firestore:rules
```

The rules file is `firestore.rules`.

---

## 11. Screen Reference

### Public screens (no login required)

| Screen | Route |
|--------|-------|
| Splash | `/` |
| Onboarding | `/onboarding` |
| Login | `/login` |
| Sign Up | `/signup` |
| Phone Verification | `/phone-verification` |
| Set Password | `/set-password` |
| Forgot Password | `/forgot-password` |

### Authenticated screens

| Screen | Route |
|--------|-------|
| Dashboard | `/dashboard` |
| Record BP | `/record-bp` |
| BP History | `/bp-history` |
| BP Analysis | `/bp-analysis` |
| BP Emergency | `/bp-emergency` |
| Medication List | `/medication-list` |
| Add Medication | `/add-medication` |
| Edit Medication | `/edit-medication/:id` |
| Medication Report | `/medication-report` |
| Education | `/education` |
| Education Detail | `/education-detail` |
| Support | `/support` |
| Health Insights | `/health-insights` |
| Profile | `/profile` |
| Edit Profile | `/edit-profile` |
| Emergency Contacts | `/emergency-contacts` |
| Settings | `/settings` |
| Notifications | `/notifications` |
| Privacy Policy | `/privacy-policy` |
| Account Deletion | `/account-deletion` |
| Email Verification | `/email-verification` |

---

## 12. Known Limitations

The following items are worth noting for anyone reviewing or maintaining the project:

1. **Apple Sign-In** is shown in the UI but not implemented. Only Google and Facebook social login work today.

2. **Phone OTP verification** generates and stores the code on the client side. For production, consider moving OTP generation and validation to a secure backend function.

3. **No custom backend.** All data operations go through Firebase client SDKs. Complex server-side logic would require Firebase Cloud Functions.

4. **Limited automated tests.** The project has minimal test coverage. Manual testing is the primary QA method at this stage.

5. **Offline writes** are not queued. If the user is offline, new readings and medication logs cannot be saved until connectivity returns.

6. **Education content** is static and bundled in the app. It cannot be updated without a new app release.

7. **No payment or subscription** features are included.

8. **README.md is outdated.** It still references a planned Node.js/MongoDB backend. The actual backend is Firebase. This document reflects the current state of the codebase.

---

## 13. Future Enhancements

These are reasonable next steps if the project continues:

- Implement Apple Sign-In for iOS App Store compliance
- Move OTP logic to Firebase Cloud Functions
- Add offline write queue with sync on reconnect
- Expand automated test coverage
- Remote content management for education articles
- Doctor or caregiver sharing portal
- Wearable device integration for automatic BP import
- Multi-language support

---

## 14. Related Documents

| Document | Contents |
|----------|----------|
| `APP_STORE_ASSETS.md` | Store listing text, screenshots guide, privacy policy template |
| `GOOGLE_PLAY_PUBLISHING_GUIDE.md` | Play Store release checklist and signing setup |
| `EDIT_PROFILE_IMPLEMENTATION.md` | Profile editing and Firebase Storage notes |
| `EDIT_MEDICATION_IMPLEMENTATION.md` | Medication edit feature implementation notes |
| `firestore.rules` | Database security rules |

---

## 15. Contact and Handover

This documentation covers the MaHyp application as delivered. For questions about setup, deployment, or feature behaviour, refer to the source code in the `lib/` directory and the service files in `lib/core/services/`.

**App version:** 1.0.0+2  
**Firebase project:** Configured in `firebase_options.dart`  
**Android package:** `com.mahypucc.app`

---

*End of document.*
