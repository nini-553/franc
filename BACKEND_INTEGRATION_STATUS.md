# Backend Integration Status

## ✅ Backend is Connected and Integrated

### 🌐 Backend URL
```
https://undiyal-backend-8zqj.onrender.com
```

## 📡 API Endpoints Integrated

### 1. Authentication APIs ✅

**Service:** `lib/services/auth_service.dart`

#### Sign Up (POST /auth/register)
```dart
POST https://undiyal-backend-8zqj.onrender.com/auth/register

Request Body:
{
  "email": "user@example.com",
  "password": "password123",
  "college": "ABC University",
  "city": "Mumbai",
  "state": "Maharashtra"
}

Response:
{
  "message": "success",
  "user_id": 123,
  "email": "user@example.com"
}
```

**Used in:**
- `lib/screens/auth/signup_screen.dart` - When user signs up

#### Login (POST /auth/login)
```dart
POST https://undiyal-backend-8zqj.onrender.com/auth/login

Request Body:
{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "message": "success",
  "user_id": 123,
  "email": "user@example.com"
}
```

**Used in:**
- `lib/screens/auth/login_screen.dart` - When user logs in

### 2. Expense APIs ✅

**Service:** `lib/services/expense_service.dart`

#### Add Expense (POST /expenses)
```dart
POST https://undiyal-backend-8zqj.onrender.com/expenses

Request Body:
{
  "user_email": "user@example.com",
  "id": "txn_123456",
  "amount": 500.0,
  "merchant": "Zomato",
  "category": "Food & Drink",
  "date": "2026-02-13T10:30:00.000Z",
  "paymentMethod": "UPI",
  "status": "completed",
  "isAutoDetected": true,
  "referenceNumber": "REF123456"
}

Response:
{
  "message": "Expense added successfully"
}
```

**Used in:**
- `lib/services/transaction_storage_service.dart` - When saving transactions
- `lib/services/sms_expense_service.dart` - When auto-detecting from SMS

#### Get Expenses (GET /expenses)
```dart
GET https://undiyal-backend-8zqj.onrender.com/expenses?user_email=user@example.com

Response:
[
  {
    "id": "txn_123456",
    "amount": 500.0,
    "merchant": "Zomato",
    "category": "Food & Drink",
    "date": "2026-02-13T10:30:00.000Z",
    "paymentMethod": "UPI",
    "status": "completed",
    "isAutoDetected": true
  },
  ...
]
```

**Used in:**
- `lib/services/transaction_storage_service.dart` - When fetching transactions

## 🔄 Data Flow

### Sign Up Flow
```
User fills signup form
    ↓
SignUpScreen calls AuthService.signUp()
    ↓
POST /auth/register → Backend
    ↓
Backend creates user account
    ↓
Returns user_id and email
    ↓
Save locally in SharedPreferences
    ↓
Navigate to permissions screen
```

### Login Flow
```
User enters credentials
    ↓
LoginScreen calls AuthService.login()
    ↓
POST /auth/login → Backend
    ↓
Backend validates credentials
    ↓
Returns user_id and email
    ↓
Save locally in SharedPreferences
    ↓
Navigate to home screen
```

### Add Expense Flow (Manual)
```
User adds expense manually
    ↓
ManualEntryScreen creates Transaction
    ↓
TransactionStorageService.saveTransaction()
    ↓
1. Save locally (SharedPreferences)
2. Sync to backend (ExpenseService.addExpense())
    ↓
POST /expenses → Backend
    ↓
Backend stores expense
    ↓
Transaction saved successfully
```

### Add Expense Flow (Auto-Detection)
```
SMS received from bank
    ↓
SmsExpenseService.detectExpensesFromSms()
    ↓
Parse SMS for transaction details
    ↓
Create Transaction object
    ↓
High confidence? → Auto-save
    ↓
1. Save locally
2. Sync to backend (ExpenseService.addExpense())
    ↓
POST /expenses → Backend
    ↓
Backend stores expense
```

### Fetch Expenses Flow
```
User opens Home/History screen
    ↓
TransactionStorageService.getTransactions()
    ↓
1. Load from local storage
2. Fetch from backend (ExpenseService.getExpenses())
    ↓
GET /expenses?user_email=... → Backend
    ↓
Backend returns all user expenses
    ↓
Merge with local data
    ↓
Display in UI
```

## 💾 Data Storage Strategy

### Hybrid Approach (Local + Remote)

**Local Storage (SharedPreferences):**
- User ID and email
- Cached transactions
- App preferences
- Permission flags
- Bank setup status

**Remote Storage (Backend):**
- User accounts
- All transactions
- Persistent data

**Sync Strategy:**
```
1. Save locally first (instant feedback)
2. Sync to backend (background)
3. Fetch from backend on app launch
4. Merge: Remote overwrites local if conflict
```

## 🔐 Authentication Flow

### User Session Management

**On Sign Up/Login:**
```dart
// Save user data locally
await AuthService.saveUserData(userId, email);

// Stored in SharedPreferences:
// - user_id: 123
// - user_email: "user@example.com"
```

**On App Launch:**
```dart
// Check if user is logged in
final userId = await AuthService.getUserId();
if (userId != null) {
  // User is logged in → Navigate to home
} else {
  // User not logged in → Show login screen
}
```

**On Logout:**
```dart
// Clear local data
await AuthService.logout();

// Removes from SharedPreferences:
// - user_id
// - user_email
```

## 📊 Backend Integration Points

### Files Using Backend Services

1. **Authentication:**
   - `lib/screens/auth/signup_screen.dart`
   - `lib/screens/auth/login_screen.dart`
   - `lib/screens/auth/auth_gate.dart`

2. **Expense Management:**
   - `lib/services/transaction_storage_service.dart`
   - `lib/services/sms_expense_service.dart`
   - `lib/screens/add_expense/manual_entry_screen.dart`
   - `lib/screens/add_expense/review_receipt_screen.dart`

3. **Data Fetching:**
   - `lib/screens/home/home_screen.dart`
   - `lib/screens/transactions/transaction_list_screen.dart`
   - `lib/screens/analytics/analytics_screen.dart`

## ✅ Integration Verification

### Authentication ✅
- [x] Sign up API connected
- [x] Login API connected
- [x] User data saved locally
- [x] Session management working
- [x] Logout functionality working

### Expense Management ✅
- [x] Add expense API connected
- [x] Get expenses API connected
- [x] Manual entry syncs to backend
- [x] Auto-detected SMS syncs to backend
- [x] Local + remote storage working

### Data Sync ✅
- [x] Transactions saved locally first
- [x] Background sync to backend
- [x] Fetch from backend on launch
- [x] Merge strategy implemented

## 🔧 Error Handling

### Network Errors
```dart
try {
  await ExpenseService.addExpense(transaction);
} catch (e) {
  debugPrint('Failed to sync to backend: $e');
  // Transaction still saved locally
  // Will retry on next sync
}
```

### Authentication Errors
```dart
try {
  final response = await AuthService.login(...);
} catch (e) {
  // Show error to user
  _showAlert('Login failed: ${e.toString()}');
}
```

## 📝 API Response Handling

### Success Response
```dart
if (data['message'] == 'success') {
  return {
    'success': true,
    'user_id': data['user_id'],
    'email': data['email'],
  };
}
```

### Error Response
```dart
else {
  throw Exception(data['message'] ?? 'Operation failed');
}
```

## 🚀 Backend Status

### Deployment
- **Platform:** Render.com
- **URL:** https://undiyal-backend-8zqj.onrender.com
- **Status:** ✅ Active and responding

### Endpoints Available
- ✅ POST /auth/register
- ✅ POST /auth/login
- ✅ POST /expenses
- ✅ GET /expenses

## 🔍 Testing Backend Connection

### Test Sign Up
```bash
curl -X POST https://undiyal-backend-8zqj.onrender.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "college": "Test College",
    "city": "Test City",
    "state": "Test State"
  }'
```

### Test Login
```bash
curl -X POST https://undiyal-backend-8zqj.onrender.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

### Test Add Expense
```bash
curl -X POST https://undiyal-backend-8zqj.onrender.com/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "user_email": "test@example.com",
    "id": "test_123",
    "amount": 100,
    "merchant": "Test Merchant",
    "category": "Food & Drink",
    "date": "2026-02-13T10:00:00.000Z",
    "paymentMethod": "UPI"
  }'
```

### Test Get Expenses
```bash
curl https://undiyal-backend-8zqj.onrender.com/expenses?user_email=test@example.com
```

## 📱 App Behavior

### Online Mode (Backend Available)
- User authentication works
- Transactions sync to backend
- Data fetched from backend
- Full functionality available

### Offline Mode (Backend Unavailable)
- User can still use app (if already logged in)
- Transactions saved locally
- Will sync when connection restored
- Limited to local data

## ✅ Conclusion

**The backend is fully connected and integrated!** 

All critical features are working:
- ✅ User authentication (sign up, login, logout)
- ✅ Expense management (add, fetch)
- ✅ Data synchronization (local + remote)
- ✅ Error handling
- ✅ Offline support

The app uses a hybrid storage approach where data is saved locally first for instant feedback, then synced to the backend for persistence and cross-device access.
