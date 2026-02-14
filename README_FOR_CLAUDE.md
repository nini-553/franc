# Undiyal Project - Quick Reference for AI Assistants

**Last Updated:** February 13, 2026

---

## 🎯 Project at a Glance

**Undiyal** is a Flutter-based personal finance app for students that automatically detects expenses from SMS messages.

- **Platform:** Flutter (Android & iOS)
- **Backend:** https://undiyal-backend-8zqj.onrender.com
- **Repository:** https://github.com/Nivekhitha/undiyal-frontend
- **Status:** ✅ Core features complete, ready for testing

---

## 📚 Essential Documentation

Read these files to understand the project:

1. **PROJECT_STATUS_REPORT.md** ⭐ START HERE
   - Complete project overview
   - All features, tech stack, architecture
   - Known issues, pending features
   - 50+ pages of comprehensive documentation

2. **APP_FLOW_DOCUMENTATION.md**
   - Complete user journey
   - All screens and navigation
   - Background processes

3. **BACKEND_INTEGRATION_STATUS.md**
   - API endpoints
   - Data flow
   - Integration points

4. **PERMISSIONS_SETUP.md**
   - Permission configuration
   - Android & iOS setup
   - ProGuard rules

5. **CLAUDE_PROMPT_TEMPLATE.md**
   - How to ask for help
   - Prompt templates
   - Example requests

---

## 🏗️ Project Structure (Key Files)

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget
├── screens/
│   ├── auth/                   # Login, Signup, AuthGate
│   ├── home/                   # Dashboard
│   ├── add_expense/            # Manual, Scan, Review
│   ├── transactions/           # List, Details
│   ├── analytics/              # Charts, Trends
│   ├── profile/                # Settings, Profile
│   ├── permissions/            # Permission request
│   └── bank/                   # Bank balance setup
├── services/
│   ├── auth_service.dart       # Authentication API
│   ├── expense_service.dart    # Expense API
│   ├── sms_expense_service.dart # SMS parsing
│   ├── notification_service.dart # Notifications
│   └── biometric_service.dart  # Biometric auth
└── models/
    └── transaction_model.dart  # Transaction data

android/
├── app/src/main/AndroidManifest.xml  # Permissions
└── app/proguard-rules.pro            # ProGuard config

Documentation/
├── PROJECT_STATUS_REPORT.md          # ⭐ Main doc
├── APP_FLOW_DOCUMENTATION.md
├── BACKEND_INTEGRATION_STATUS.md
├── PERMISSIONS_SETUP.md
└── CLAUDE_PROMPT_TEMPLATE.md
```

---

## 🔑 Key Features

1. **Authentication** - Login/Signup with backend
2. **SMS Auto-Detection** - Parse bank SMS for transactions
3. **Manual Entry** - Form-based expense input
4. **Receipt Scanning** - Camera + AI extraction
5. **Transaction Management** - List, view, edit, delete
6. **Analytics** - Charts, trends, category breakdown
7. **Bank Balance** - Call bank, parse SMS balance
8. **Biometric Auth** - Fingerprint/Face ID
9. **Notifications** - Alerts for low-confidence transactions
10. **Profile & Settings** - User preferences

---

## 🔄 User Flow (Simplified)

```
New User:
Login Screen → Sign Up → Permissions → Bank Setup → Home

Returning User:
Login Screen → Login → (Biometric) → Home

Add Expense:
Home → Add Tab → Manual/Scan/Auto → Save → Home
```

---

## 🌐 Backend APIs

**Base URL:** `https://undiyal-backend-8zqj.onrender.com`

```
POST /auth/register  - Sign up
POST /auth/login     - Login
POST /expenses       - Add expense
GET  /expenses       - Get expenses
```

---

## 📱 Tech Stack

**Frontend:**
- Flutter 3.x
- Dart
- Cupertino widgets (iOS-style)
- SharedPreferences (local storage)

**Key Dependencies:**
- `flutter_sms_inbox` - Read SMS
- `permission_handler` - Runtime permissions
- `flutter_local_notifications` - Push notifications
- `local_auth` - Biometric authentication
- `image_picker` - Camera/Gallery
- `http` - API calls

**Backend:**
- Node.js
- Deployed on Render.com

---

## ✅ What's Working

- [x] Complete authentication flow
- [x] SMS-based auto-detection
- [x] Manual expense entry
- [x] Receipt scanning
- [x] Transaction management
- [x] Analytics dashboard
- [x] Profile & settings
- [x] Backend integration
- [x] Permission handling
- [x] Biometric authentication
- [x] Bank balance integration
- [x] Notifications
- [x] ProGuard configuration

---

## 🐛 Known Issues

1. **SMS Parsing** - Some bank formats not recognized
2. **Offline Mode** - Backend sync fails when offline
3. **Receipt Scanning** - AI extraction not always accurate
4. **Real-time Listener** - Requires notification access
5. **Bank Balance** - Depends on SMS response timing

---

## 🚀 Pending Features

**High Priority:**
- Budget management
- Search & filters
- Export & reports

**Medium Priority:**
- Multi-bank support
- Widgets
- Dark mode
- Onboarding tutorial

**Low Priority:**
- Social features
- AI insights

---

## 🔧 Common Tasks

### Run the App
```bash
flutter pub get
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```

### Check for Issues
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

---

## 💡 When Helping with This Project

### Always Consider:
1. **User Experience** - Keep it simple and intuitive
2. **Performance** - Optimize for mobile devices
3. **Security** - Protect user data
4. **Offline Support** - App should work without internet
5. **Battery Life** - Minimize background processes
6. **Permissions** - Request only when needed

### Code Style:
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Testing:
- Test on physical devices
- Verify SMS detection works
- Check all permissions
- Test offline mode

---

## 📞 Quick Help Guide

### For Bug Fixes:
1. Read PROJECT_STATUS_REPORT.md (Known Issues section)
2. Check relevant service file
3. Review error logs
4. Test on physical device

### For New Features:
1. Check if similar feature exists
2. Review APP_FLOW_DOCUMENTATION.md
3. Plan data model
4. Consider backend changes
5. Update documentation

### For Code Review:
1. Check code quality
2. Verify error handling
3. Test edge cases
4. Update tests
5. Update documentation

---

## 🎯 Current Focus

**Immediate:**
- Test on physical Android device
- Fix critical bugs
- Add loading states

**Short-term:**
- Implement budget management
- Add search & filters
- Improve SMS parsing

**Long-term:**
- Add automated testing
- Implement dark mode
- Create onboarding tutorial
- Prepare for launch

---

## 📊 Project Metrics

- **Total Screens:** 15+
- **Total Services:** 10+
- **Lines of Code:** ~5000+
- **Documentation Pages:** 50+
- **Features Completed:** 10/15
- **Test Coverage:** 0% (needs work)

---

## 🔗 Important Links

- **Repository:** https://github.com/Nivekhitha/undiyal-frontend
- **Backend:** https://undiyal-backend-8zqj.onrender.com
- **Flutter Docs:** https://docs.flutter.dev
- **Dart Docs:** https://dart.dev

---

## 💬 How to Ask for Help

Use the templates in **CLAUDE_PROMPT_TEMPLATE.md**

**Quick Template:**
```
I'm working on Undiyal (Flutter personal finance app).

ISSUE: [Describe issue]
FILE: [Relevant file]
HELP NEEDED: [What you need]
```

---

## ✨ Key Achievements

1. ✅ Complete end-to-end user flow (no dead ends)
2. ✅ Backend fully integrated and working
3. ✅ SMS auto-detection functional
4. ✅ Permission handling properly implemented
5. ✅ ProGuard configured for release builds
6. ✅ Comprehensive documentation created
7. ✅ Authentication flow corrected (login first)
8. ✅ Biometric authentication working
9. ✅ Bank balance integration complete
10. ✅ Notification system functional

---

## 🎉 Project Status

**Overall:** 80% Complete

**Ready for:**
- ✅ Testing on physical devices
- ✅ Bug fixes and refinements
- ✅ Additional features
- ⏳ Release preparation

**Not Ready for:**
- ❌ Production release (needs testing)
- ❌ App store submission (needs polish)
- ❌ Public beta (needs stability)

---

## 📝 Final Notes

This is a well-structured, functional app with solid foundations. The core features work, backend is integrated, and the user flow is complete. Focus now should be on:

1. **Testing** - Verify everything works on real devices
2. **Polish** - Fix bugs, improve UX
3. **Features** - Add high-priority features (budgets, search)
4. **Launch** - Prepare for app store submission

**The project is in great shape and ready for the next phase!** 🚀

---

**For detailed information, always refer to PROJECT_STATUS_REPORT.md first.**
