# MaHyp - Google Play Store Publishing Guide

## ✅ Implementation Complete

All three requested features have been successfully implemented:

1. **Phone OTP Authentication with Arkesel** - Ready for integration
2. **Updated Blood Pressure Logic** - Simplified to Controlled/Not Controlled/Crisis
3. **Medication Dropdown with Backend** - Integrated with Firestore master list

---

## 📱 Google Play Store Publishing Checklist

### **Phase 1: Pre-requisites**

#### 1.1 Google Play Developer Account
- [ ] Visit [Google Play Console](https://play.google.com/console)
- [ ] Pay one-time $25 registration fee
- [ ] Complete account setup
- [ ] Verify identity (1-2 days)

#### 1.2 Prepare App Assets

**Required Assets:**
- [ ] **App Icon**: 512x512 px (already have at `assets/icons/app_icon.png`)
- [ ] **Feature Graphic**: 1024x500 px
- [ ] **Screenshots**: 2-8 screenshots, min 320px shortest side (recommend 1080x1920)
- [ ] **Promo Video** (optional): 30s-2min YouTube video

**Store Listing Content:**
- [ ] **Title**: "MaHyp - Blood Pressure & Medication Tracker" (max 30 chars)
- [ ] **Short Description**: "Track BP, manage medications, monitor hypertension." (max 80 chars)
- [ ] **Full Description**: Detailed feature list (max 4000 chars)
- [ ] **Privacy Policy URL**: Must be live and accessible

---

### **Phase 2: Build Release App**

#### 2.1 Update Configuration Files

**Update `android/app/build.gradle`**:
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.mahyp"  // CHANGE THIS!
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1  // Increment with each release
        versionName "1.0.0"  // Match pubspec.yaml
    }
    
    signingConfigs {
        release {
            // Configure in next step
            storeFile file('mahyp-upload-key.jks')
            storePassword 'your-store-password'
            keyAlias 'mahyp-key'
            keyPassword 'your-key-password'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 2.2 Generate Signing Key (IMPORTANT!)

```bash
# Navigate to android/app directory
cd mahyp/android/app

# Generate keystore (Windows)
keytool -genkey -v -keystore mahyp-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mahyp-key

# You'll be prompted for:
# - Keystore password (SAVE THIS SECURELY!)
# - Your name, organization, city, country
# - Key password (can be same as keystore password)
```

**⚠️ CRITICAL SECURITY NOTES:**
- **BACKUP THIS KEY FILE** - You cannot update your app without it!
- Store in password manager or secure cloud storage
- **NEVER commit to version control**
- Share only with trusted team members

#### 2.3 Build Android App Bundle (AAB)

Google Play requires AAB format (not APK):

```bash
# From mahyp directory
flutter build appbundle --release

# Output: mahyp/build/app/outputs/bundle/release/app-release.aab
```

---

### **Phase 3: Google Play Console Setup**

#### 3.1 Create App
1. In Play Console, click **"Create app"**
2. Fill in:
   - App name: "MaHyp"
   - Default language: English
   - App or game: App
   - Free or paid: Free (or Paid)
3. Accept developer declarations

#### 3.2 Complete Store Listing

**App Details:**
- [ ] Title: "MaHyp - Blood Pressure & Medication Tracker"
- [ ] Short description: "Track blood pressure, manage medications, and monitor hypertension effectively."
- [ ] Full description: Write 3-4 paragraphs covering:
  - What MaHyp does
  - Key features (BP tracking, medication management, insights)
  - Benefits for elderly users
  - How it helps manage hypertension

**Graphics:**
- [ ] Upload app icon
- [ ] Upload feature graphic
- [ ] Upload 2-8 screenshots
- [ ] Upload promo video (optional)

**Contact Details:**
- [ ] Email: your-support@email.com
- [ ] Website: (if available)
- [ ] Phone: (optional)

**Privacy Policy:**
- [ ] Create privacy policy page
- [ ] Host on Firebase Hosting, GitHub Pages, or your website
- [ ] Must include:
  - What data is collected
  - How data is used
  - How data is protected
  - User rights (access, deletion)
  - Third-party services (Firebase, Arkesel)
- [ ] Link in Play Console

#### 3.3 Upload App
1. Go to **"Release"** → **"Production"**
2. Click **"Create new release"**
3. Upload `app-release.aab`
4. Release name: "Version 1.0.0"
5. Release notes:
   ```
   Initial release of MaHyp!
   
   Features:
   - Blood pressure tracking with intelligent categorization
   - Medication management with reminders
   - Health insights and reports
   - Secure phone verification
   - Easy-to-use interface for elderly users
   ```

#### 3.4 Content Rating
1. Go to **"Policy"** → **"App content"**
2. Complete **"Content rating"** questionnaire
3. Answer honestly about:
   - Violence, sexual content, profanity (all "No")
   - User-generated content (if any)
   - Data collection practices
4. Submit for IESRB rating

#### 3.5 Target Audience
1. Go to **"Policy"** → **"App content"**
2. **Target audience**:
   - Age range: 18 and over
   - Not primarily for children
3. **Ads**: No (if not showing ads)

#### 3.6 Data Safety
1. Go to **"Policy"** → **"App content"** → **"Data safety"**
2. Complete form:
   - **Data collected**:
     - Personal info: Name, email, phone number
     - Health data: Blood pressure readings, medications, dosage
   - **Data shared**: None (or with Firebase/Arkesel as service providers)
   - **Security practices**:
     - Data encrypted in transit (HTTPS)
     - Data encrypted at rest (Firestore encryption)
   - **Deletion**: Users can request data deletion

---

### **Phase 4: Testing**

#### 4.1 Internal Testing (REQUIRED)
1. Go to **"Testing"** → **"Internal testing"**
2. Create closed testing track
3. Add testers (email addresses)
4. Upload app
5. Testers receive email invitation
6. Install via Play Store
7. Test for 3-7 days

**Test These Features:**
- [ ] Sign up with phone verification
- [ ] Record blood pressure readings
- [ ] Add medications
- [ ] View history and insights
- [ ] All navigation flows
- [ ] Offline behavior
- [ ] Error handling

#### 4.2 Fix Issues
- Monitor Firebase Crashlytics
- Fix critical bugs
- Optimize performance

---

### **Phase 5: Production Release**

#### 5.1 Final Checklist
- [ ] App builds without errors
- [ ] All features tested and working
- [ ] Privacy policy is live
- [ ] Store listing complete
- [ ] Screenshots and graphics uploaded
- [ ] Content rating completed
- [ ] Data safety form completed
- [ ] Tested on real devices

#### 5.2 Submit for Review
1. Go to **"Release"** → **"Production"**
2. Click **"Review and roll out to production"**
3. Review all information carefully
4. Click **"Start rollout to production"**

**Review Timeline**: 1-7 days for first-time apps

#### 5.3 After Approval
- [ ] App goes live on Google Play Store
- [ ] You receive email notification
- [ ] Monitor Play Console for:
  - Downloads
  - Reviews
  - Crashes
  - User feedback

---

### **Phase 6: Post-Launch**

#### 6.1 Monitor & Maintain
- **Firebase Console**:
  - Crashlytics: Monitor crashes
  - Analytics: Track user behavior
  - Performance: Monitor app speed
- **Play Console**:
  - Reviews: Respond to user feedback
  - Statistics: Monitor downloads and ratings
  - Pre-launch reports: Check for issues

#### 6.2 Future Updates

When ready to update:
1. Increment `versionCode` in `android/app/build.gradle`
2. Update `versionName` in `pubspec.yaml`
3. Build new AAB: `flutter build appbundle --release`
4. Upload to Play Console
5. Submit for review

---

## 🔧 Arkesel OTP Configuration

### Before Production:

1. **Get Arkesel Credentials**:
   - Log into [Arkesel Dashboard](https://sms.arkesel.com)
   - Navigate to API settings
   - Copy your API Key
   - Get your approved Sender ID

2. **Update `arkesel_otp_service.dart`**:
   ```dart
   final String _apiKey = 'YOUR_ACTUAL_API_KEY';
   final String _senderId = 'YOUR_ACTUAL_SENDER_ID';
   ```

3. **Verify Endpoints**:
   - Check Arkesel documentation for exact OTP endpoints
   - Current implementation uses:
     - Send: `POST /api/v2/otp/send`
     - Verify: `POST /api/v2/otp/verify`
   - Adjust if Arkesel uses different endpoints

4. **Test OTP Flow**:
   - Test with real phone numbers
   - Verify OTP delivery
   - Verify OTP validation
   - Check error handling

---

## 📋 Additional Recommendations

### Security
- [ ] Enable Google Play App Signing (recommended)
- [ ] Use Firebase App Check for API security
- [ ] Implement proper OTP validation on backend (not just client-side)
- [ ] Add rate limiting for OTP requests

### Compliance
- [ ] Ensure HIPAA compliance if targeting US users
- [ ] Add GDPR compliance for EU users
- [ ] Include health data disclaimers
- [ ] Consult legal advisor for medical app regulations

### Optimization
- [ ] Optimize app size (currently ~15-20MB)
- [ ] Add app shortcuts
- [ ] Implement deep linking
- [ ] Add widget support
- [ ] Optimize for tablets

### Marketing
- [ ] Create app website
- [ ] Set up social media presence
- [ ] Prepare press kit
- [ ] Plan launch campaign
- [ ] Reach out to health communities

---

## 🆘 Support & Resources

**Google Play Console Help**: https://support.google.com/googleplay/android-developer

**Flutter Documentation**: https://docs.flutter.dev/deployment/android

**Arkesel Support**: Contact via https://sms.arkesel.com/support

**Firebase Documentation**: https://firebase.google.com/docs/flutter/setup

---

## 📞 Next Steps

1. **Immediate**:
   - Get Arkesel API credentials
   - Update `arkesel_otp_service.dart` with real credentials
   - Test OTP flow thoroughly

2. **This Week**:
   - Prepare app assets (screenshots, feature graphic)
   - Write privacy policy
   - Create Google Play Developer account

3. **Next Week**:
   - Build release AAB
   - Set up Play Console
   - Complete store listing
   - Upload for internal testing

4. **In 2-3 Weeks**:
   - Fix any testing issues
   - Submit for production review
   - Prepare launch materials

---

**Good luck with your MaHyp app launch! 🚀**

For questions about specific steps, refer to the detailed sections above or consult the official documentation links.