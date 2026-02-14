# SMS Detection Debug Guide

## Current Issue
App is showing mock data and not detecting/extracting SMS messages.

---

## Root Cause Analysis

### Issue 1: Cleanup Flag Already Set
The `has_cleaned_v2_data` flag was set BEFORE we removed the mock data. This means:
1. App ran once with mock data
2. Cleanup flag was set to `true`
3. We removed mock data code
4. App thinks cleanup is done, but old mock data might still be in storage

### Issue 2: SMS Detection Not Running
SMS detection happens in `initializeSmsDetection()` which is called after permissions are granted. If this isn't running, SMS won't be detected.

---

## Diagnostic Steps

### Step 1: Check if Mock Data Exists
Run this in your app's debug screen or add temporary debug code:

```dart
final prefs = await SharedPreferences.getInstance();
final transactionsJson = prefs.getString('stored_transactions');
debugPrint('Stored transactions: $transactionsJson');
```

**Expected**: Should be empty or null
**If not empty**: Old mock data is still there

### Step 2: Check Cleanup Flag
```dart
final prefs = await SharedPreferences.getInstance();
final hasCleaned = prefs.getBool('has_cleaned_v2_data');
debugPrint('Cleanup flag: $hasCleaned');
```

**Expected**: `true` (but this prevents cleanup from running again)
**Problem**: Flag is set, so cleanup won't run again

### Step 3: Check SMS Permission
```dart
final hasPermission = await SmsExpenseService.hasSmsPermission();
debugPrint('SMS permission granted: $hasPermission');
```

**Expected**: `true`
**If false**: SMS detection won't run

### Step 4: Check if SMS Detection Ran
Look for these debug logs:
```
SMS permission granted, detecting expenses...
Analyzing SMS from last X days (current month)
Found X SMS messages to process
```

**If missing**: SMS detection didn't run

---

## Solutions

### Solution 1: Force Clear All Data (Recommended)
This will completely reset the app:

```bash
# Clear app data
adb shell pm clear com.undiyal.fintracker.deepblue

# Or manually: Settings > Apps > Undiyal > Storage > Clear Data
```

Then:
1. Open app
2. Login/Signup
3. Grant SMS permission
4. App should scan SMS and detect transactions

### Solution 2: Reset Cleanup Flag (Quick Fix)
Add this code temporarily to force cleanup to run again:

**File**: `lib/services/app_init_service.dart`

```dart
static Future<void> initialize() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // TEMPORARY: Force cleanup to run again
    await prefs.setBool('has_cleaned_v2_data', false);
    
    final hasCleaned = prefs.getBool('has_cleaned_v2_data') ?? false;
    // ... rest of code
```

Then rebuild and run the app.

### Solution 3: Manual Cleanup (Developer Option)
Add a button in your debug screen:

```dart
CupertinoButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all data
    await SmsExpenseService.clearAllData();
    
    // Reset cleanup flag
    await prefs.setBool('has_cleaned_v2_data', false);
    
    // Reset bank setup flag
    await prefs.setBool('has_completed_bank_setup', false);
    
    // Reset permission flag
    await prefs.setBool('has_requested_permissions', false);
    
    debugPrint('All data cleared, flags reset');
  },
  child: const Text('Force Reset Everything'),
),
```

---

## Verification Steps

After applying a solution, verify SMS detection is working:

### 1. Check Debug Logs
Look for these logs in order:

```
✓ App initialization complete
✓ SMS permission granted, detecting expenses...
✓ Analyzing SMS from last X days
✓ Found X SMS messages to process
✓ Processing SMS 1/X
✓ Detected balance SMS: BOB - Rs.XXX
✓ Auto-detected transaction: Merchant - ₹XXX
✓ Saved X transactions from SMS
```

### 2. Check Home Screen
- Balance should show real amount from SMS
- Transactions should show real expenses from SMS
- No mock/fake data should appear

### 3. Test with New SMS
1. Give missed call to bank
2. Receive balance SMS
3. Check if balance updates in app
4. Should see notification (if SMS is recent)

---

## Common Issues

### Issue: "No SMS messages found"
**Cause**: No transaction SMS in inbox
**Solution**: 
- Check if you have bank SMS in your inbox
- Try sending a test transaction
- Check SMS permission is granted

### Issue: "SMS detected but not showing in app"
**Cause**: SMS parsing failed
**Solution**:
- Check SMS format matches patterns in `parseSmsForExpense()`
- Add debug logs to see what's being parsed
- Check if SMS is being marked as "ignored" (promotional, OTP, etc.)

### Issue: "Balance not updating"
**Cause**: Balance SMS not recognized
**Solution**:
- Check SMS format matches patterns in `BalanceSmsParser`
- Add your bank's SMS pattern if missing
- Check debug logs for "Detected balance SMS"

### Issue: "Transactions showing but balance is 0"
**Cause**: No balance SMS found
**Solution**:
- Give missed call to bank to get balance SMS
- Check if balance SMS is in inbox
- Verify bank is supported (BOB, SBI, HDFC, AXIS, IOB, CUB)

---

## Testing Checklist

- [ ] Clear app data completely
- [ ] Fresh install and login
- [ ] Grant SMS permission
- [ ] Check debug logs for SMS detection
- [ ] Verify no mock data appears
- [ ] Check balance shows real amount
- [ ] Check transactions show real expenses
- [ ] Send test SMS and verify detection
- [ ] Check notification appears for new SMS
- [ ] Restart app and verify data persists

---

## Debug Commands

### View App Logs
```bash
# Clear logs first
adb logcat -c

# View Flutter logs
adb logcat | findstr "flutter"

# View specific service logs
adb logcat | findstr "SmsExpenseService"
adb logcat | findstr "BalanceSmsParser"
```

### Check App Storage
```bash
# View SharedPreferences
adb shell run-as com.undiyal.fintracker.deepblue cat shared_prefs/FlutterSharedPreferences.xml
```

### Clear App Data
```bash
# Complete reset
adb shell pm clear com.undiyal.fintracker.deepblue

# Or just clear storage
adb shell pm clear-data com.undiyal.fintracker.deepblue
```

---

## Next Steps

1. **Immediate**: Clear app data and test fresh install
2. **If still not working**: Check debug logs to see where SMS detection fails
3. **If SMS not detected**: Verify SMS format matches parsing patterns
4. **If balance not showing**: Check if balance SMS is recognized

---

## Files to Check

- `lib/services/app_init_service.dart` - Initialization and cleanup
- `lib/services/sms_expense_service.dart` - SMS detection and parsing
- `lib/services/balance_sms_parser.dart` - Balance SMS detection
- `lib/screens/auth/auth_gate.dart` - Permission flow
- `lib/services/transaction_storage_service.dart` - Data storage

---

## Contact Points

If SMS detection still doesn't work after these steps:
1. Share debug logs (adb logcat output)
2. Share sample SMS format (redact sensitive info)
3. Share screenshots of home screen
4. Confirm SMS permission is granted in Android settings
