# Firebase

Paint Buddy is registered on the shared **Buddy Suite** Firebase project (`buddy-suite-macos`, Spark / free).

| | |
|--|--|
| Bundle ID | `com.buddy.paint` |
| App ID | `1:304015834291:ios:07b94751c2e069953844c6` |
| Products | Analytics + Crashlytics |
| Config | `PaintBuddy/Resources/GoogleService-Info.plist` |

`BuddyFirebase.configure()` runs in `PaintBuddyApp.init()`. The plist is copied into the app via XcodeGen (`buildPhase: resources`).

```bash
ln -sfn ../../shared-buddy Vendor/shared-buddy
xcodegen generate
open PaintBuddy.xcodeproj
```

After a clean Run, the Xcode console should show `[BuddyFirebase] app_launch` (not “Skipping configure”). For realtime Analytics while developing, add `-FIRDebugEnabled` to the scheme and open **DebugView** in the Firebase console.
