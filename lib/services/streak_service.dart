import 'transaction_storage_service.dart';

class StreakService {
  /// Calculate current streak and best streak
  /// Returns { 'current': int, 'best': int }
  static Future<Map<String, int>> getStreakData() async {
    final transactions = await TransactionStorageService.getAllTransactions();
    
    if (transactions.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // Extract unique dates (ignoring time)
    final uniqueDates = transactions
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort desc (newest first)

    if (uniqueDates.isEmpty) return {'current': 0, 'best': 0};

    // Calculate Current Streak
    int currentStreak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if we have an entry for today or yesterday to keep streak alive
    bool streakAlive = false;
    if (uniqueDates.contains(today) || uniqueDates.contains(yesterday)) {
        streakAlive = true;
    }
    
    if (!streakAlive) {
        currentStreak = 0;
    } else {
        // Count backwards from today/yesterday
        // We need to find the "start" of the chain
        
        // Simplified Logic: Iterate dates and check continuity
        // Since uniqueDates is sorted desc: [Today, Yesterday, 2 Days Ago...]
        
        // 1. Identify start point (Today or Yesterday)
        int startIndex = 0;
        if (uniqueDates.first == today) {
            currentStreak = 1;
            startIndex = 1; // Start checking from next element
        } else if (uniqueDates.first == yesterday) {
            currentStreak = 1;
            startIndex = 1;
        } else {
            // No transaction today or yesterday -> Streak broken
            currentStreak = 0;
        }

        // 2. Continue counting if streak is active
        if (currentStreak > 0) {
            DateTime lastDate = uniqueDates.first;
            
            for (int i = startIndex; i < uniqueDates.length; i++) {
                final date = uniqueDates[i];
                final diff = lastDate.difference(date).inDays;
                
                if (diff == 1) {
                    currentStreak++;
                    lastDate = date;
                } else {
                    break; // Gap found
                }
            }
        }
    }

    // Calculate Best Streak (All time)
    int bestStreak = 0;
    int tempStreak = 0;
    if (uniqueDates.isNotEmpty) {
        tempStreak = 1;
        bestStreak = 1;
        
        for (int i = 0; i < uniqueDates.length - 1; i++) {
            final date1 = uniqueDates[i];
            final date2 = uniqueDates[i+1]; // Older date
            
            final diff = date1.difference(date2).inDays;
            
            if (diff == 1) {
                tempStreak++;
            } else {
                tempStreak = 1; // Reset
            }
            
            if (tempStreak > bestStreak) {
                bestStreak = tempStreak;
            }
        }
    }

    return {
      'current': currentStreak,
      'best': bestStreak,
    };
  }
}
