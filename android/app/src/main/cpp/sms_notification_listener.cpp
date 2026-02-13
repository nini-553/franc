#include "sms_notification_listener.h"
#include <jni.h>
#include <android/log.h>
#include <string>

extern "C" {
    // Native FFI functions implementation
    void nativeSmsListenerStart() {
        __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "Starting native SMS listener");
        // Implementation for starting SMS listener would go here
        // This would typically register a BroadcastReceiver for SMS_RECEIVED
    }

    void nativeSmsListenerStop() {
        __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "Stopping native SMS listener");
        // Implementation for stopping SMS listener would go here
        // This would typically unregister the BroadcastReceiver
    }

    void nativeOpenNotificationSettings() {
        __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "Opening notification settings");
        // Implementation for opening notification settings would go here
        // This would use Android Intent to open notification settings
    }
}

JNIEXPORT void JNICALL
Java_com_undiyal_sms_SmsNotificationListener_nativeSmsListenerStart(JNIEnv* env, jobject thiz) {
    __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "JNI: Starting SMS listener");
    nativeSmsListenerStart();
}

JNIEXPORT void JNICALL
Java_com_undiyal_sms_SmsNotificationListener_nativeSmsListenerStop(JNIEnv* env, jobject thiz) {
    __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "JNI: Stopping SMS listener");
    nativeSmsListenerStop();
}

JNIEXPORT void JNICALL
Java_com_undiyal_sms_SmsNotificationListener_nativeOpenNotificationSettings(JNIEnv* env, jobject thiz) {
    __android_log_print(ANDROID_LOG_DEBUG, "SmsNotificationListener", "JNI: Opening notification settings");
    nativeOpenNotificationSettings();
}
