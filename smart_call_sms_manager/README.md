# Smart Call & SMS Manager (Default App Edition)

**WARNING: FOR LOCAL TESTING AND EDUCATIONAL PURPOSES ONLY.**
**DO NOT UPLOAD TO GOOGLE PLAY.**

This application is designed to function as the **Default Phone and SMS App** on an Android device. It uses restricted permissions and internal APIs that are not compliant with standard Play Store policies without specific use-case declarations.

## Features
- **Default Dialer**: Replaces the system phone app.
- **Default SMS**: Replaces the system SMS app.
- **Direct Calling**: Calls are placed immediately via the `role_dialer` privilege.
- **Direct SMS**: Messages are sent immediately via the `default_sms_package` privilege.
- **Real-time Logs**: Reads and writes to the device's actual Call Log and SMS Inbox.

## Installation
1. Build the APK: `flutter build apk`
2. Install via ADB: `flutter install`
3. **Setup**: On first launch, tap "Settings" -> "Set as Default Phone" and "Set as Default SMS".

## Permissions
The app requests:
- `CALL_PHONE`
- `READ_CALL_LOG` / `WRITE_CALL_LOG`
- `SEND_SMS` / `READ_SMS` / `RECEIVE_SMS`
- `READ_PHONE_STATE`

## Architecture
- **Flutter**: UI and Logic.
- **Kotlin**: Native `MethodChannel` implementation for `Telephony` and `RoleManager` APIs.
