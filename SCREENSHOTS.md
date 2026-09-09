# Screenshots — Paint Buddy

```
docs/screenshots/{locale}/raw/      # real app window captures
docs/screenshots/{locale}/banners/ # framed 1280×800 marketing images
docs/screenshots/mock-content.md
```

Locales: `en`, `nl`, `pt`, `es`, `fr`, `it`, `ar`, `zh`, `ru`, `ja`.

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

## Required shots

| ID | Feature | Banner title (en) | Banner description (en) |
|----|---------|-------------------|-------------------------|
| history | History \| Favorites | History & Favorites | Clipboard colors land in History — switch to Favorites for pinned swatches. |
| detail | Values + suggestions | Copy any channel | Hex, RGB, RGBA, and R/G/B/A chips — plus suggested relatives to try next. |
| palette | Floating History | Floating History | Keep recent swatches always on top — grid, list, or detailed with channel chips. |
| favorites | Floating Favorites | Floating Favorites | A second always-on panel just for starred colors you reuse all day. |
| formats | Capture formats | Capture your way | Choose which formats to save and how copied colors are formatted — even hex without #. |
| pick | Eyedropper result | Pick from screen | One-shot eyedropper into History or Favorites — no Screen Recording needed. |
| menubar | Menu bar | Menu bar ready | Recent colors one click away — pick, History, Favorites, and pause. |
