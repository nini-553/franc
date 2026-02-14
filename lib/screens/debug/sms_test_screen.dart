import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/sms_expense_service.dart';
import '../../services/balance_sms_parser.dart';
import '../../services/app_init_service.dart';
import '../../utils/dev_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple test screen to verify SMS detection is working
class SmsTestScreen extends StatefulWidget {
  const SmsTestScreen({super.key});

  @override
  State<SmsTestScreen> createState() => _SmsTestScreenState();
}

class _SmsTestScreenState extends State<SmsTestScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SMS Detection Test'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SMS Detection Diagnostic',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Status display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              
              // Test buttons
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _checkPermission,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text('1. Check SMS Permission'),
              ),
              const SizedBox(height: 12),
              
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _checkStoredData,
                child: const Text('2. Check Stored Data'),
              ),
              const SizedBox(height: 12),
              
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _runSmsDetection,
                child: const Text('3. Run SMS Detection'),
              ),
              const SizedBox(height: 12),
              
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _checkBalance,
                child: const Text('4. Check Balance'),
              ),
              const SizedBox(height: 20),
              
              // Cleanup buttons
              CupertinoButton(
                onPressed: _isLoading ? null : _forceCleanup,
                child: const Text(
                  'Force Cleanup (Clear All Data)',
                  style: TextStyle(color: CupertinoColors.systemOrange),
                ),
              ),
              const SizedBox(height: 8),
              
              CupertinoButton(
                onPressed: _isLoading ? null : _resetEverything,
                child: const Text(
                  'Reset Everything',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking SMS permission...';
    });

    try {
      final hasPermission = await SmsExpenseService.hasSmsPermission();
      setState(() {
        _status = hasPermission
            ? '✓ SMS permission granted'
            : '✗ SMS permission NOT granted\nGo to Settings > Permissions > SMS';
      });
    } catch (e) {
      setState(() {
        _status = '✗ Error checking permission: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStoredData() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking stored data...';
    });

    try {
      final transactions = await SmsExpenseService.getStoredTransactions();
      final prefs = await SharedPreferences.getInstance();
      final hasCleaned = prefs.getBool('has_cleaned_v2_data') ?? false;
      final hasSetup = prefs.getBool('has_completed_bank_setup') ?? false;
      
      setState(() {
        _status = '''
Stored Transactions: ${transactions.length}
Cleanup Flag: $hasCleaned
Bank Setup Complete: $hasSetup

${transactions.isEmpty ? 'No transactions stored' : 'Transactions:'}
${transactions.take(5).map((tx) => '- ${tx.merchant}: ₹${tx.amount}').join('\n')}
${transactions.length > 5 ? '\n... and ${transactions.length - 5} more' : ''}
''';
      });
    } catch (e) {
      setState(() {
        _status = '✗ Error checking data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runSmsDetection() async {
    setState(() {
      _isLoading = true;
      _status = 'Running SMS detection...\nCheck debug logs for details';
    });

    try {
      await AppInitService.initializeSmsDetection();
      
      final transactions = await SmsExpenseService.getStoredTransactions();
      setState(() {
        _status = '''
✓ SMS detection complete!

Found ${transactions.length} transactions
Check debug logs (adb logcat) for details

${transactions.isEmpty ? 'No transactions detected' : 'Recent transactions:'}
${transactions.take(5).map((tx) => '- ${tx.merchant}: ₹${tx.amount}').join('\n')}
''';
      });
    } catch (e) {
      setState(() {
        _status = '✗ Error running detection: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkBalance() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking balance...';
    });

    try {
      final balanceData = await BalanceSmsParser.getLastBalance();
      
      if (balanceData != null) {
        final bank = balanceData['bank'];
        final balance = balanceData['balance'];
        final timestamp = balanceData['timestamp'];
        
        setState(() {
          _status = '''
✓ Balance found!

Bank: ${BalanceSmsParser.getBankFullName(bank)}
Balance: ₹$balance
Last updated: ${timestamp ?? 'Unknown'}
''';
        });
      } else {
        setState(() {
          _status = '''
✗ No balance found

Possible reasons:
1. No balance SMS in inbox
2. Balance SMS format not recognized
3. Need to give missed call to bank

Try: Give missed call to your bank's balance check number
''';
        });
      }
    } catch (e) {
      setState(() {
        _status = '✗ Error checking balance: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forceCleanup() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Force Cleanup'),
        content: const Text(
          'This will remove all stored transactions and reset the cleanup flag. '
          'The app will scan SMS again on next launch.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cleanup'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Running force cleanup...';
      });

      try {
        await DevTools.forceCleanup();
        setState(() {
          _status = '''
✓ Force cleanup complete!

All transaction data cleared
Cleanup flag reset

Restart the app to scan SMS again
''';
        });
      } catch (e) {
        setState(() {
          _status = '✗ Error during cleanup: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetEverything() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Everything'),
        content: const Text(
          'This will clear ALL app data including login, permissions, and transactions. '
          'You will need to login again.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Resetting everything...';
      });

      try {
        await DevTools.clearAllData();
        setState(() {
          _status = '''
✓ Everything reset!

Restart the app to start fresh
You will need to login again
''';
        });
      } catch (e) {
        setState(() {
          _status = '✗ Error during reset: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
