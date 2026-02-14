# Notification Spam Fix

## Date: February 14, 2026

## Problem
User was receiving multiple "Balance Added Successfully" notifications with different amounts (₹100, ₹1000, ₹60, ₹210, ₹150) when the app scanned old SMS messages.

### Root Cause
When the app scanned SMS messages during initialization, it was:
1. Finding ALL old balance SMS messages (5-10 messages)
2. Calling `storeBalance()` for EACH message
3. Each `storeBalance()` call triggered a notification
4. Result: User got spammed with 5-10 notifications at once

### Why the 5-Minute Check Didn't Work
The 5-minute time check was added, but it was checking AFTER storing the balance. The issue was that we were processing every single balance SMS individually, even old ones.

---

## Solution

### Changed Approach
Instead of processing each balance SMS immediately, we now:
1. **Collect** all balance SMS messages during the scan
2. **Sort** them by date (most recent first)
3. **Store** only the MOST RECENT balance
4. **Notify** only if that most recent SMS is within 5 minutes

### Code Changes

**File**: `lib/services/sms_expense_service.dart`

#### Before (Lines 96-150)
```dart
// 4a. Check for BALANCE SMS first
final balanceData = BalanceSmsParser.parseBalanceSms(body, sender);
if (balanceData != null) {
  debugPrint('✓ Detected balance SMS: ${balanceData['bank']} - Rs.${balanceData['balance']}');
  balanceCount++;
  await BalanceSmsParser.storeBalance(  // ❌ Stored EVERY balance SMS
    balanceData['bank'] as String,
    balanceData['balance'] as double,
  );
  await _markSmsAsProcessed(message.id.toString());
  
  // Only show notification for recent SMS (within last 5 minutes)
  final smsDate = message.date ?? DateTime.now();
  final now = DateTime.now();
  final difference = now.difference(smsDate);
  
  if (difference.inMinutes <= 5) {
    debugPrint('Showing notification for recent balance SMS');
    await NotificationService.showBalanceUpdateNotification(  // ❌ Sent notification for EACH
      bank: balanceData['bank'] as String,
      balance: balanceData['balance'] as double,
    );
  }
  continue;
}
```

#### After (Lines 96-180)
```dart
// 3. Process messages - COLLECT ALL TRANSACTIONS
List<Transaction> detectedTransactions = [];
List<Map<String, dynamic>> balanceMessages = []; // ✅ Collect balance SMS
int processedCount = 0;
int skippedCount = 0;
int balanceCount = 0;
int expenseCount = 0;

for (var message in messages) {
  // ... processing logic ...
  
  // 4a. Check for BALANCE SMS first - COLLECT, don't process yet
  final balanceData = BalanceSmsParser.parseBalanceSms(body, sender);
  if (balanceData != null) {
    debugPrint('✓ Detected balance SMS: ${balanceData['bank']} - Rs.${balanceData['balance']}');
    balanceCount++;
    
    // ✅ Add to collection with timestamp
    balanceMessages.add({
      'bank': balanceData['bank'],
      'balance': balanceData['balance'],
      'date': message.date ?? DateTime.now(),
      'smsId': message.id.toString(),
    });
    
    await _markSmsAsProcessed(message.id.toString());
    continue;
  }
}

// ✅ 5. Process balance messages - only store and notify for the MOST RECENT one
if (balanceMessages.isNotEmpty) {
  // Sort by date (most recent first)
  balanceMessages.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  
  final mostRecent = balanceMessages.first;
  final bank = mostRecent['bank'] as String;
  final balance = mostRecent['balance'] as double;
  final smsDate = mostRecent['date'] as DateTime;
  
  debugPrint('Processing most recent balance SMS: $bank - Rs.$balance');
  
  // Store the balance (only once!)
  await BalanceSmsParser.storeBalance(bank, balance);
  
  // Only show notification if it's recent (within 5 minutes)
  final now = DateTime.now();
  final difference = now.difference(smsDate);
  
  if (difference.inMinutes <= 5) {
    debugPrint('Showing notification for recent balance SMS');
    await NotificationService.showBalanceUpdateNotification(
      bank: bank,
      balance: balance,
    );
    
    // Navigate to home if navigator is available
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  } else {
    debugPrint('Skipping notification for old balance SMS (${difference.inMinutes} minutes old)');
  }
  
  debugPrint('Ignored ${balanceMessages.length - 1} older balance SMS messages');
}
```

---

## How It Works Now

### Scenario 1: Fresh Install (User just gave SMS permission)
1. App scans last 50 SMS messages
2. Finds 5 old balance SMS messages:
   - ₹100 (3 days ago)
   - ₹1000 (2 days ago)
   - ₹60 (1 day ago)
   - ₹210 (12 hours ago)
   - ₹150 (6 hours ago)
3. Sorts them by date → ₹150 is most recent
4. Stores only ₹150 as the balance
5. Checks time: 6 hours ago > 5 minutes → NO notification
6. Result: Balance updated silently, no spam

### Scenario 2: New Balance SMS Arrives
1. User gives missed call to bank
2. Bank sends balance SMS (just now)
3. App detects it immediately
4. Stores the balance
5. Checks time: 0 minutes ago < 5 minutes → SHOW notification
6. Result: User gets ONE notification for the fresh SMS

### Scenario 3: App Restart
1. App scans SMS again
2. All SMS are already marked as "processed"
3. Skips all of them
4. Result: No duplicate notifications

---

## Benefits

✅ **No More Spam**: Only ONE notification per app session
✅ **Most Recent Balance**: Always shows the latest balance, not old ones
✅ **Silent Updates**: Old balance SMS update the balance without notifying
✅ **Fresh Notifications**: New SMS (within 5 minutes) still trigger notifications
✅ **Efficient**: Processes all SMS in one pass, then decides what to notify

---

## Testing Recommendations

### Test Case 1: Fresh Install
1. Clear app data
2. Login/signup
3. Grant SMS permission
4. Expected: Balance updates silently, no notifications

### Test Case 2: New Balance SMS
1. Give missed call to bank
2. Wait for SMS
3. Expected: ONE notification appears

### Test Case 3: App Restart
1. Close and reopen app
2. Expected: No duplicate notifications

### Test Case 4: Multiple Banks
1. Have balance SMS from different banks
2. Expected: Shows most recent balance from most recent bank

---

## Related Files
- `lib/services/sms_expense_service.dart` - Main fix
- `lib/services/balance_sms_parser.dart` - Balance detection
- `lib/services/notification_service.dart` - Notification display
- `lib/services/sms_notification_listener.dart` - Real-time SMS listener

---

## Notes
- The fix maintains the 5-minute threshold for notifications
- Old balance SMS are still processed (balance is updated)
- Only the notification is suppressed for old messages
- Real-time SMS listener (for new incoming SMS) is unaffected
