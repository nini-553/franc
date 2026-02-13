# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-keep interface com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**
-keep class com.baseflow.permissionhandler.PermissionHandlerPlugin { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter SMS Inbox
-keep class com.shounakmulay.** { *; }
-keep class com.shounakmulay.flutter_sms_inbox.** { *; }
-dontwarn com.shounakmulay.flutter_sms_inbox.**

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Home Widget
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**

# HTTP
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# General Flutter
-keep class com.google.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent R8 from stripping necessary classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Exceptions
-keepattributes SourceFile
-keepattributes LineNumberTable

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Gson (if used by any plugin)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp (used by http plugin)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Android components
-keep class * extends android.app.Activity
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.content.ContentProvider

# Keep widget provider
-keep class com.undiyal.fintracker.deepblue.UndiyalWidgetProvider { *; }

# Google Play Core (for deferred components compatibility)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
