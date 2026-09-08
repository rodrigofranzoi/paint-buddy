# Firebase

Add a real `PaintBuddy/Resources/GoogleService-Info.plist` from Firebase Console (`com.buddy.paint`), list it in `project.yml` resources, then:

```bash
./scripts/link-firebase.sh
```

A placeholder template lives at `GoogleService-Info.plist.sample` (do not ship with a fake `GOOGLE_APP_ID`).
