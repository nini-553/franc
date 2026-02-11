import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/app_init_service.dart';
import 'signup_screen.dart';
import '../../navigation/bottom_nav.dart';
import '../permissions/permission_request_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Map<String, dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkAuthAndPermissions();
  }

  Future<Map<String, dynamic>> _checkAuthAndPermissions() async {
    final userId = await AuthService.getUserId();
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedPermissions = prefs.getBool('has_requested_permissions') ?? false;
    
    return {
      'userId': userId,
      'hasRequestedPermissions': hasRequestedPermissions,
    };
  }

  Future<void> _onPermissionsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_requested_permissions', true);
    
    // Initialize SMS detection after permissions are granted
    await AppInitService.initializeSmsDetection();
    
    // Refresh the state to navigate to home
    setState(() {
      _initFuture = _checkAuthAndPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {
        // While checking, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        final data = snapshot.data;
        final userId = data?['userId'];
        final hasRequestedPermissions = data?['hasRequestedPermissions'] ?? false;

        // If no user, show sign up
        if (userId == null) {
          return const SignUpScreen();
        }

        // If user exists but hasn't been asked for permissions, show permission screen
        if (!hasRequestedPermissions) {
          return PermissionRequestScreen(
            onComplete: _onPermissionsComplete,
          );
        }

        // User is authenticated and permissions have been handled, go to home
        return const BottomNavigation();
      },
    );
  }
}

