# Testing

## Unit

```bash
ln -sfn ../../shared-buddy Vendor/shared-buddy
xcodegen generate
xcodebuild -scheme PaintBuddy -destination 'platform=macOS' test CODE_SIGNING_ALLOWED=NO -only-testing:PaintBuddyTests
```

## Manual

1. Copy `#FF5733` → appears in menu bar / history
2. Disable RGB capture in Settings → `rgb(1,2,3)` is ignored; hex still saved
3. Open floating palette → stays above other apps
4. Pick a color from Color Panel → history updates and preferred format is copied
5. Pause → clipboard colors are not saved
