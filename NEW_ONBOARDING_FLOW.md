# New Onboarding Flow - Bank Balance Setup

## 🎯 Complete User Journey

### Step 1: App Launch (First Time)
```
Splash Screen (3 seconds)
    ↓
Login Screen
    ↓
User taps "Sign Up"
    ↓
Sign Up Screen
    ↓
User fills form and submits
    ↓
Permission Request Screen
```

### Step 2: Permission Request
```
Permission Request Screen
    ↓
User grants SMS + Notification permissions
    ↓
Blocked Home Screen (Light Blue)
```

### Step 3: Blocked Home Screen
```
┌─────────────────────────────────────────┐
│     BLOCKED HOME SCREEN                 │
│     (Light Blue Background)             │
│                                         │
│     🏦 White Circular Icon              │
│                                         │
│     Set up your bank balance            │
│                                         │
│     Set up your bank balance so         │
│     Undiyal knows how much you're       │
│     really working with.                │
│                                         │
│     [➡️ Set it up]                      │
│                                         │
└─────────────────────────────────────────┘

User CANNOT proceed without setup
```

### Step 4: Bank Setup Screen
```
User taps "Set it up"
    ↓
Bank Balance Setup Screen opens
    ↓
Shows "How it works" card:
  1. Select your bank
  2. Tap "Check Balance"
  3. Give a missed call
  4. Receive SMS → balance updates automatically
```

### Step 5: Bank Selection
```
User sees bank list:
  - SBI (State Bank of India)
  - Bank of Baroda
  - IOB (Indian Overseas Bank)
  - CUB (City Union Bank)
  - HDFC Bank
  - Axis Bank

User selects their bank
    ↓
"Check Balance" button becomes active
```

### Step 6: Missed Call Action
```
User taps "Check Balance"
    ↓
App opens phone dialer with bank number
    ↓
User makes missed call
    ↓
Call ends immediately (missed call)
    ↓
User can close dialer
```

### Step 7: SMS Arrives (Background)
```
Bank sends SMS:
"Available balance is ₹xxxx"
    ↓
App (in background):
  1. Reads SMS (permission already granted)
  2. Parses balance using BalanceSmsParser
  3. Extracts amount
  4. Saves balance to SharedPreferences
  5. Marks has_completed_bank_setup = true
  6. Shows notification: "🎉 Balance Added Successfully!"
```

### Step 8: User Returns to App
```
User opens Undiyal again
    ↓
AuthGate checks has_completed_bank_setup
    ↓
Setup is complete!
    ↓
Blocked Home Screen is gone
    ↓
Real Home Dashboard appears
    ↓
Balance is shown correctly in Balance Card
```

## 📱 Implementation Details

### Files Created/Modified

**Created:**
1. `lib/screens/launch/launch_screen.dart`
   - Splash screen with animation
   - 3-second delay
   - Navigates to AuthGate

2. `lib/screens/home/blocked_home_screen.dart`
   - Light blue background
   - White circular icon
   - Setup message
   - "Set it up" button
   - No skip option

**Modified:**
1. `lib/app.dart`
   - Changed home from AuthGate to LaunchScreen

2. `lib/screens/auth/auth_gate.dart`
   - Added check for has_completed_bank_setup
   - Shows BlockedHomeScreen if not completed
   - Shows BottomNavigation if completed

3. `lib/services/balance_sms_parser.dart`
   - Added logic to mark has_completed_bank_setup = true
   - When storeBalance() is called

4. `lib/services/sms_expense_service.dart`
   - Added notification when balance is detected
   - Calls NotificationService.showBalanceUpdateNotification()

5. `lib/services/notification_service.dart`
   - Added showBalanceUpdateNotification() method
   - Shows success message with bank and balance

### Key SharedPreferences Keys

```dart
// Authentication
'user_id' - User ID from backend
'user_email' - User email

// Permissions
'has_requested_permissions' - true after permission screen

// Bank Setup
'has_completed_bank_setup' - true after balance SMS received
'bank_balance_SBI' - Balance for SBI
'bank_balance_BOB' - Balance for BOB
'bank_balance_IOB' - Balance for IOB
'bank_balance_CUB' - Balance for CUB
'bank_balance_HDFC' - Balance for HDFC
'bank_balance_AXIS' - Balance for Axis
'bank_balance_last_bank' - Last bank that sent balance
'bank_balance_timestamp' - When balance was last updated
```

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    SPLASH SCREEN (3s)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    LOGIN SCREEN                              │
│  Email: ___________                                          │
│  Password: ________                                          │
│  [Login]                                                     │
│  Don't have account? Sign Up                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                    User taps Sign Up
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    SIGN UP SCREEN                            │
│  Name, Email, Password, College, City, State                 │
│  [Sign Up]                                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                    Submit Success
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              PERMISSION REQUEST SCREEN                       │
│  📱 SMS Access                                               │
│  🔔 Notifications                                            │
│  [Grant Permissions]                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                    Permissions Granted
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              BLOCKED HOME SCREEN                             │
│  (Light Blue Background)                                     │
│                                                              │
│  🏦 Set up your bank balance                                 │
│  Set up your bank balance so Undiyal knows                   │
│  how much you're really working with.                        │
│                                                              │
│  [➡️ Set it up]                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                    User taps "Set it up"
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              BANK BALANCE SETUP SCREEN                       │
│                                                              │
│  How it works:                                               │
│  1. Select your bank                                         │
│  2. Tap "Check Balance"                                      │
│  3. Give a missed call                                       │
│  4. Receive SMS → balance updates                            │
│                                                              │
│  Select Your Bank:                                           │
│  ○ SBI                                                       │
│  ○ Bank of Baroda                                            │
│  ○ IOB                                                       │
│  ○ CUB                                                       │
│  ○ HDFC                                                      │
│  ○ Axis                                                      │
│                                                              │
│  [Check Balance]                                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                    User selects bank & taps button
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    PHONE DIALER                              │
│  Calling: 09223866666 (SBI)                                 │
│  [End Call]                                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                    Missed call made
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              SMS ARRIVES (Background)                        │
│  "Available balance is ₹8,500.00"                            │
│                                                              │
│  App automatically:                                          │
│  ✓ Reads SMS                                                 │
│  ✓ Parses balance                                            │
│  ✓ Saves ₹8,500                                              │
│  ✓ Marks setup complete                                      │
│  ✓ Shows notification                                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                    User opens app again
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    HOME SCREEN                               │
│  (Real Dashboard - No longer blocked)                        │
│                                                              │
│  💵 Balance Card: ₹8,500                                     │
│  📊 Weekly Spending                                          │
│  📝 Recent Transactions                                      │
│  ➕ Quick Add Expense                                        │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Features Implemented

1. **Splash Screen** ✅
   - Animated logo
   - App name and tagline
   - 3-second delay
   - Smooth transition

2. **Blocked Home Screen** ✅
   - Light blue background (#E3F2FD)
   - White circular icon
   - Clear setup message
   - No skip option (mandatory)
   - Navigates to bank setup

3. **Bank Setup Integration** ✅
   - Existing bank setup screen
   - "How it works" instructions
   - Bank selection
   - Dialer integration
   - Rate limiting (3 calls/day per bank)

4. **SMS Background Detection** ✅
   - Automatic balance parsing
   - Marks setup as complete
   - Shows success notification
   - Navigates to home

5. **Smooth Transition** ✅
   - When user returns to app
   - Blocked screen disappears
   - Real home screen appears
   - Balance is displayed

## 🎨 UI/UX Details

### Blocked Home Screen
- **Background:** Light blue (#E3F2FD)
- **Icon:** White circle with money icon
- **Title:** "Set up your bank balance" (28px, bold)
- **Description:** "Set up your bank balance so Undiyal knows how much you're really working with." (16px)
- **Button:** Primary color, rounded, with arrow icon

### Notification
- **Title:** "🎉 Balance Added Successfully!"
- **Message:** "Your [Bank] balance of ₹[Amount] has been added to Undiyal"
- **Priority:** High
- **Icon:** App icon

## 🔧 Testing Checklist

- [ ] Splash screen appears on app launch
- [ ] Login screen shows after splash
- [ ] Sign up flow works
- [ ] Permission request appears
- [ ] Blocked home screen shows after permissions
- [ ] "Set it up" button opens bank setup
- [ ] Bank selection works
- [ ] "Check Balance" opens dialer
- [ ] Missed call can be made
- [ ] SMS is detected in background
- [ ] Balance is parsed correctly
- [ ] Notification appears
- [ ] Setup is marked complete
- [ ] Real home screen appears on next launch
- [ ] Balance is displayed correctly

## 📝 Notes

- User CANNOT skip bank setup (no skip button)
- App works in background to detect SMS
- Notification confirms successful setup
- Balance is stored locally
- Setup only needs to be done once
- User can update balance later from profile

## 🚀 Next Steps

1. Test on physical device
2. Verify SMS detection works
3. Test with different banks
4. Check notification appears
5. Verify smooth transition to home
6. Test rate limiting
7. Handle edge cases (no SMS, wrong number, etc.)

---

**Implementation Complete!** ✅
