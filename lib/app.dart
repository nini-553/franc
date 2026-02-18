import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/launch/launch_screen.dart';
import 'theme/app_colors.dart';
import 'utils/globals.dart';

class UndiyalApp extends StatelessWidget {
  const UndiyalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Undiyal',
      theme: CupertinoThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.textPrimary,
          textStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      navigatorKey: navigatorKey,
      home: const LaunchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}