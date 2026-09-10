# Screenshots — Paint Buddy

```
docs/screenshots/{locale}/raw/      # real app window captures
docs/screenshots/{locale}/banners/ # framed 1280×800 marketing images
docs/screenshots/mock-content.md
```

Locales: `en`, `de`, `nl`, `pt`, `es`, `fr`, `it`, `ar`, `zh`, `ru`, `ja`.

## Capture real UI

```bash
# Builds Paint Buddy, seeds demo colors, captures every locale, then frames banners
./shared-buddy/scripts/marketing/capture_real_screenshots.sh paint

# Or all Buddy apps:
./shared-buddy/scripts/marketing/capture_real_screenshots.sh all
```

Each launch uses `-BuddyMarketingCapture` + `-AppleLanguages '(xx)'`.

Frame existing raws only:

```bash
python3 shared-buddy/scripts/marketing/generate_marketing_banners.py --frame-only --app paint
```

Banner size: **1280×800**. Brand frame uses the Paint Buddy violet / lavender / lilac icon gradient.

## App Store order

| # | ID | Banner title (en) |
|---|----|-------------------|
| 1 | palette | Floating History |
| 2 | menubar | Menu bar ready |
| 3 | favorites | Floating Favorites |
| 4 | history | History & Favorites |
| 5 | detail | Copy any channel |
| 6 | pick | Pick from screen |

`formats` (Capture your way) is captured for docs but **not** uploaded to App Store Connect.

## Required shots

| ID | Feature | Banner title (en) | Banner description (en) |
|----|---------|-------------------|-------------------------|
| palette | Floating History | Floating History | Keep recent swatches always on top — grid, list, or detailed with channel chips. |
| menubar | Menu bar | Menu bar ready | Recent colors one click away — pick, History, Favorites, and pause. |
| favorites | Floating Favorites | Floating Favorites | A second always-on panel just for starred colors you reuse all day. |
| history | History \| Favorites | History & Favorites | Clipboard colors land in History — switch to Favorites for pinned swatches. |
| detail | Values + suggestions | Copy any channel | Hex, RGB, RGBA, and R/G/B/A chips — plus suggested relatives to try next. |
| pick | Eyedropper result | Pick from screen | One-shot eyedropper into History or Favorites — no Screen Recording needed. |
| formats | Capture formats *(docs only)* | Capture your way | Choose which formats to save and how copied colors are formatted — even hex without #. |
