# Undiyal App - End-to-End User Flow Documentation

## 📱 Complete User Journey

### 1. App Launch (main.dart)
```
User opens app
    ↓
WidgetsFlutterBinding.ensureInitialized()
    ↓
Load .env file (API keys, config)
    ↓
AppInitService.initialize()
    - Initialize notification service
    - Setup basic services (NO permission requests)
    ↓
Launch UndiyalApp (app.dart)
    ↓
Navigate to AuthGate
```

### 2. Authentication Gate (auth_gate.dart)

#### Flow Decision Tree:
```
AuthGate checks:
    ├─ Is user logged in? (userId exists?)
    │   ├─ NO → Show SignUpScreen
    │   └─ YES → Continue to next check
    │
    ├─ Is biometric enabled AND required?
    │   ├─ YES → Show Biometric Auth Screen
    │   │   ├─ Auth Success → Continue
    │   │   └─ Auth Failed → Show error, allow logout
    │   └─ NO → Continue to next check
    │
    ├─ Has requested permissions?
    │   ├─ NO → Show PermissionRequestScreen
    │   │   ├─ Grant → Navigate to SMS Notification Settings
    │   │   └─ Skip → Navigate to SMS Notification Settings
    │   └─ YES → Continue to next check
    │
    ├─ Has completed bank setup?
    │   ├─ NO → Show BankBalanceSetupScreen
    │   │   ├─ Complete → Navigate to Home
    │   │   └─ Skip → Navigate to Home
    │   └─ YES → Navigate to Home (BottomNavigation)
```

### 3. First-Time User Flow (New User)

#### Step 1: Sign Up
**Screen:** `SignUpScreen`
- User enters:
  - Full Name
  - Email
  - Password
  - College
  - City
  - State
- Calls `AuthService.signUp()`
- Saves user_id and email locally
- Saves profile name via `ProfileService`
- **Navigation:** Automatically goes to AuthGate → Permission Screen

#### Step 2: Permission Request
**Screen:** `PermissionRequestScreen`
- Requests critical permissions:
  - ✅ SMS (READ_SMS, RECEIVE_SMS) - For transaction detection
  - ✅ Notifications (POST_NOTIFICATIONS) - For expense alerts
- User can:
  - Grant all permissions
  - Skip for now (app still works with limited features)
- **Navigation:** → SMS Notification Settings Screen

#### Step 3: SMS Notification Settings
**Screen:** `SmsNotificationSettingsScreen`
- Configure real-time SMS detection
- Enable/disable SMS notification listener
- Option to open system settings for notification access
- **Navigation:** → Bank Balance Setup Screen

#### Step 4: Bank Balance Setup (Optional)
**Screen:** `BankBalanceSetupScreen`
- Select bank from list:
  - SBI, Bank of Baroda, IOB, CUB, HDFC, Axis
- Tap to call bank's balance inquiry number
- Rate limiting: Max 3 calls per bank per day
- User can:
  - Complete setup (call bank)
  - Skip setup (can do later)
- **Navigation:** → Home Screen (BottomNavigation)

### 4. Returning User Flow

#### With Biometric Enabled:
```
App Launch
    ↓
AuthGate
    ↓
Biometric Auth Screen
    ├─ Authenticate → Home
    └─ Fail → Show error, allow logout
```

#### Without Biometric:
```
App Launch
    ↓
AuthGate
    ↓
Home Screen (BottomNavigation)
```

### 5. Main App Screens (BottomNavigation)

#### Tab 1: Home Screen
**Features:**
- Balance card showing current balance
- Weekly spending summary
- Recent transactions list
- Quick add expense button
- Category breakdown

**Actions:**
- View balance
- See recent transactions
- Quick add expense
- Navigate to transaction details

#### Tab 2: Analytics Screen
**Features:**
- Spending trends
- Category-wise breakdown
- Monthly/weekly comparisons
- Charts and graphs

**Actions:**
- View spending patterns
- Filter by date range
- Analyze categories

#### Tab 3: Add Expense Screen
**Features:**
- Three options:
  1. Scan Receipt (Camera)
  2. Choose from Gallery
  3. Manual Entry

**Actions:**
- Take photo of receipt → Review Receipt Screen
- Select image from gallery → Review Receipt Screen
- Manual entry → Manual Entry Screen

#### Tab 4: Transaction History Screen
**Features:**
- Complete transaction list
- Search functionality
- Filter by category
- Sort options
- Grouped by date

**Actions:**
- View all transactions
- Search transactions
- Filter by category
- Tap to view details

#### Tab 5: Profile Screen
**Features:**
- User profile information
- Settings:
  - Biometric authentication
  - SMS notification settings
  - Bank balance setup
  - Subscription management
- Logout option

**Actions:**
- Edit profile
- Enable/disable biometric
- Configure SMS settings
- Manage subscription
- Logout

### 6. Add Expense Flows

#### Flow A: Scan Receipt
```
Add Expense Screen
    ↓
Tap "Scan Receipt"
    ↓
Request Camera Permission (if not granted)
    ↓
Open Camera
    ↓
Take Photo
    ↓
ReviewReceiptScreen
    ├─ AI extracts: amount, merchant, date
    ├─ User can edit details
    ├─ Select category
    └─ Save
        ↓
    Transaction saved
        ↓
    Navigate back to Home
```

#### Flow B: Manual Entry
```
Add Expense Screen
    ↓
Tap "Manual Entry"
    ↓
ManualEntryScreen
    ├─ Enter amount
    ├─ Enter merchant
    ├─ Select category
    ├─ Select payment method
    ├─ Select date
    └─ Save
        ↓
    Transaction saved
        ↓
    Navigate back to Home
```

#### Flow C: Auto-Detection (Background)
```
SMS Received (Bank transaction)
    ↓
SMS Notification Listener (if enabled)
    OR
SMS Inbox Scanner (periodic)
    ↓
Parse SMS for transaction details
    ├─ Amount
    ├─ Merchant
    ├─ Date
    ├─ Reference number
    └─ Payment method
        ↓
    High Confidence?
        ├─ YES → Auto-save transaction
        └─ NO → Show notification
            ↓
        User taps notification
            ↓
        ManualEntryScreen (pre-filled)
            ↓
        User confirms/edits
            ↓
        Save transaction
```

### 7. Transaction Detail Flow
```
Transaction List/Home Screen
    ↓
Tap on transaction
    ↓
TransactionDetailScreen
    ├─ View full details
    ├─ Edit transaction
    ├─ Delete transaction
    └─ View receipt (if available)
```

### 8. Settings & Configuration Flows

#### Biometric Setup
```
Profile Screen
    ↓
Tap "Biometric Authentication"
    ↓
Check device support
    ├─ Supported → Enable/Disable toggle
    └─ Not Supported → Show message
```

#### SMS Notification Settings
```
Profile Screen
    ↓
Tap "SMS Notification Settings"
    ↓
SmsNotificationSettingsScreen
    ├─ Enable/Disable listener
    ├─ View status
    └─ Open system settings
```

#### Bank Balance Setup
```
Profile Screen
    ↓
Tap "Bank Balance Setup"
    ↓
BankBalanceSetupScreen
    ├─ Select bank
    ├─ Call balance inquiry
    └─ Rate limiting check
```

### 9. Logout Flow
```
Profile Screen
    ↓
Tap "Logout"
    ↓
Confirmation dialog
    ├─ Cancel → Stay logged in
    └─ Confirm → Clear user data
        ↓
    Navigate to SignUpScreen
```

## 🔄 Background Processes

### SMS Detection Service
- **Trigger:** App launch, periodic checks, real-time listener
- **Process:**
  1. Check SMS permission
  2. Read recent SMS messages
  3. Parse for transaction keywords
  4. Extract transaction details
  5. Check for duplicates
  6. Save or notify user
- **Frequency:** 
  - Real-time (if listener enabled)
  - On app launch
  - Manual refresh

### Notification Service
- **Trigger:** Low confidence transaction detected
- **Process:**
  1. Create friendly notification
  2. Include transaction amount
  3. Tap to open ManualEntryScreen
  4. Pre-fill transaction details

### Balance Sync Service
- **Trigger:** User calls bank balance inquiry
- **Process:**
  1. Wait for SMS response
  2. Parse balance from SMS
  3. Update local balance
  4. Sync to backend

## 🔐 Permission Handling

### Critical Permissions (Requested on First Launch)
1. **SMS (READ_SMS, RECEIVE_SMS)**
   - Purpose: Auto-detect transactions
   - When: Permission Request Screen
   - Fallback: Manual entry only

2. **Notifications (POST_NOTIFICATIONS)**
   - Purpose: Alert for undetected expenses
   - When: Permission Request Screen
   - Fallback: No alerts

### On-Demand Permissions
1. **Camera**
   - Purpose: Scan receipts
   - When: User taps "Scan Receipt"
   - Fallback: Choose from gallery or manual entry

2. **Photos/Storage**
   - Purpose: Select receipt images
   - When: User taps "Choose from Gallery"
   - Fallback: Camera or manual entry

3. **Biometric**
   - Purpose: Secure app access
   - When: User enables in settings
   - Fallback: No biometric auth

## 📊 Data Flow

### Local Storage (SharedPreferences)
- User ID
- Email
- Profile name
- Permission flags
- Bank setup status
- Biometric settings
- SMS notification settings
- Processed SMS IDs
- Transactions (cached)

### Backend Sync
- User authentication
- Profile data
- Transactions
- Analytics data
- Subscription status

## ⚠️ Error Handling

### Network Errors
- Show error message
- Retry option
- Offline mode (local data only)

### Permission Denied
- Show explanation
- Offer to open settings
- Provide alternative flow

### SMS Parsing Errors
- Log error
- Show notification for manual entry
- Don't crash app

### Camera/Gallery Errors
- Show error message
- Offer alternative method
- Fallback to manual entry

## 🎯 Key User Paths

### Path 1: Quick Add Expense (Manual)
```
Home → Add Tab → Manual Entry → Fill Details → Save → Home
Time: ~30 seconds
```

### Path 2: Scan Receipt
```
Home → Add Tab → Scan Receipt → Camera → Take Photo → Review → Save → Home
Time: ~45 seconds
```

### Path 3: View Transaction History
```
Home → History Tab → View List → Tap Transaction → View Details
Time: ~15 seconds
```

### Path 4: Check Analytics
```
Home → Analytics Tab → View Charts → Filter by Date/Category
Time: ~20 seconds
```

### Path 5: Auto-Detected Transaction
```
SMS Received → Auto-detected → Saved → Notification (optional) → View in Home
Time: Instant (background)
```

## ✅ Flow Completeness Checklist

- [x] User can sign up
- [x] User can log in
- [x] User can grant permissions
- [x] User can skip permissions
- [x] User can set up bank balance
- [x] User can skip bank setup
- [x] User can add expense manually
- [x] User can scan receipt
- [x] User can view transactions
- [x] User can view analytics
- [x] User can edit profile
- [x] User can enable biometric
- [x] User can configure SMS settings
- [x] User can logout
- [x] App auto-detects SMS transactions
- [x] App shows notifications for low-confidence transactions
- [x] App syncs data to backend
- [x] App works offline (limited features)
- [x] App handles permission denials gracefully
- [x] App handles errors without crashing

## 🚀 Next Steps for Enhancement

1. **Onboarding Tutorial**
   - Add first-time user guide
   - Show feature highlights
   - Interactive walkthrough

2. **Search & Filters**
   - Advanced search in transactions
   - Multiple filter options
   - Save filter presets

3. **Budgets & Goals**
   - Set monthly budgets
   - Category-wise limits
   - Savings goals

4. **Recurring Transactions**
   - Detect recurring expenses
   - Set up automatic entries
   - Subscription tracking

5. **Export & Reports**
   - Export transactions (CSV, PDF)
   - Monthly reports
   - Tax summaries

6. **Multi-Bank Support**
   - Link multiple bank accounts
   - Consolidated view
   - Account switching

7. **Widgets**
   - Home screen widget
   - Quick add expense widget
   - Balance widget

8. **Dark Mode**
   - Theme switching
   - Auto dark mode
   - Custom themes
