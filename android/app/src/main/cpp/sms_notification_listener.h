// sms_notification_listener.h
#ifndef SMS_NOTIFICATION_LISTENER_H
#define SMS_NOTIFICATION_LISTENER_H

#ifdef __cplusplus
extern "C" {
#endif

// FFI functions exposed to Dart
void nativeSmsListenerStart();
void nativeSmsListenerStop();
void nativeOpenNotificationSettings();

#ifdef __cplusplus
}
#endif

#endif // SMS_NOTIFICATION_LISTENER_H
