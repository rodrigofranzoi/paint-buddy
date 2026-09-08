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
| history | Color history | Color history | Clipboard colors land in one tidy history you can search and copy. |
| detail | Hex / RGB / RGBA | Copy any format | Hex, RGB, and RGBA — click a value to copy what you need. |
| palette | Floating palette | Floating palette | Keep swatches always on top while you design or code. |
| formats | Capture formats | Capture your way | Choose which formats to save and how copied colors are formatted. |
| pick | Eyedropper result | Pick from screen | One-shot eyedropper — no Screen Recording permission needed. |
| menubar | Menu bar | Menu bar ready | Recent colors stay one click away — pick, palette, and pause. |
