# Store Copy — Paint Buddy

Supported locales: `en`, `nl`, `pt`, `es`, `fr`, `it`, `ar`, `zh`, `ru`, `ja`.

## Legal URLs (App Store Connect)

- App Store ID: _(assign after first Connect listing; update `BuddyLegalURLs.appStoreID`)_
- Privacy: https://rodrigofranzoi.github.io/paint-buddy/privacy.html
- Terms: https://rodrigofranzoi.github.io/paint-buddy/terms.html
- Rate / write review: _(available once App Store ID is set)_

## What's New (all locales)

Initial release.

---

## App Review Notes (Apple)

Paste into App Store Connect → App Review Information → Notes.

```
Paint Buddy is a macOS menu-bar (agent) app. There is no Dock icon by default (LSUIElement).

NO LOGIN / DEMO ACCOUNT REQUIRED.

How to review:
1. Launch the app. Look for the paintpalette icon in the macOS menu bar.
2. Click the menu bar icon to open the recent-colors popover.
3. Copy a color string (e.g. #7C3AED, rgb(124,58,237), or a CSS name like tomato) — it should appear in Recent.
4. Click Pick Color (eyedropper): the cursor changes; click once on screen to save a color (NSColorSampler — one-shot, not continuous sampling).
5. Open the main window from the menu bar controls, or toggle Palette for the always-on-top floating panel.
6. Click a swatch / row to copy in the preferred format (Settings → Preferences).
7. Settings (gear): capture formats (hex / rgb / rgba / named / tuple), copy format, history limits, pause monitoring, launch at login, appearance / accent.
8. Pause from the menu bar, then resume. Clear history from the popover or Settings.

Permissions / entitlements:
- No Screen Recording entitlement.
- Clipboard: reads pasteboard text locally only to detect color tokens (hex, rgb, rgba, named CSS colors, tuples).
- Network client: Firebase Analytics & Crashlytics only.
- Export compliance: exempt — HTTPS/TLS only (ITSAppUsesNonExemptEncryption = false).

Privacy:
- Color history stays on device (UserDefaults / JSON). Never uploaded.
- Analytics/Crashlytics do not include clipboard or color payloads.

Contact: use the App Store Connect account owner email if anything is unclear.
```

---

## TestFlight Notes

### Beta App Description

Paste into TestFlight → Test Information → Beta App Description.

```
Paint Buddy captures colors from your clipboard (hex, rgb, rgba, named) and keeps them in the menu bar, a main window, and an always-on-top floating palette. Pick new colors with a one-shot eyedropper — no Screen Recording.
```

### What to Test

Paste into TestFlight → Test Information → What to Test.

```
Thanks for testing Paint Buddy!

Please try:
• Menu bar icon → recent colors popover → Open / Settings
• Copy color strings: #FF5733, rgb(255,87,51), rgba(...), tomato, (0.5, 0.2, 0.8)
• Pick Color (eyedropper): click once to sample a screen color into history
• Floating Palette: toggle always-on-top panel; try list vs grid if available
• Click a color to copy; change preferred copy format in Settings
• Toggle which formats are captured (hex / rgb / rgba / named / tuple)
• Pause monitoring from the menu bar, copy a color (should not save), then resume
• History limits and Clear all colors
• Launch at login and appearance / accent

Report crashes, localization issues, and anything confusing in the palette or history.

No account needed. All color data stays on your Mac.
```

### Beta App Review (TestFlight)

Same content as **App Review Notes** above if Apple requests Beta App Review Information. No demo account.

---

## English (`en`)

**Name:** Paint Buddy  
**Subtitle:** Color history for Mac  
**Keywords:** color,picker,hex,rgb,rgba,palette,clipboard,designer,developer,eyedropper  
**Promotional Text:** Capture clipboard colors, pick with the eyedropper, and keep a floating palette nearby — hex, rgb, rgba & named colors in the menu bar.

**Description:**

Paint Buddy watches your clipboard for colors — hex, rgb, rgba, named CSS colors, and simple tuples — and keeps a tidy history in the menu bar.

Open the main window or an always-on-top floating palette when you need your swatches nearby. Pick a new color with a one-shot eyedropper (no Screen Recording). Choose which formats to save and how copied colors are formatted.

Pause monitoring when you need privacy. Launch at login if you like. Colors stay on your Mac.

---

## Dutch (`nl`)

**Name:** Paint Buddy  
**Subtitle:** Kleurenhistorie voor Mac  
**Keywords:** kleur,picker,hex,rgb,rgba,palet,klembord,designer,developer,pipet  
**Promotional Text:** Vang kleuren uit het klembord, kies met de pipet en houd een zwevend palet bij de hand — hex, rgb, rgba en benoemde kleuren in de menubalk.

**Description:**

Paint Buddy volgt je klembord op kleuren — hex, rgb, rgba, CSS-kleurnamen en eenvoudige tuples — en bewaart een nette geschiedenis in de menubalk.

Open het hoofdvenster of een altijd-bovenste zwevend palet wanneer je swatches nodig hebt. Kies een nieuwe kleur met een eenmalige pipet (geen schermopname). Stel in welke formaten worden opgeslagen en hoe gekopieerde kleuren worden geformatteerd.

Pauzeer monitoring wanneer je privacy nodig hebt. Start bij inloggen als je wilt. Kleuren blijven op je Mac.

---

## Portuguese (`pt`)

**Name:** Paint Buddy  
**Subtitle:** Histórico de cores no Mac  
**Keywords:** cor,seletor,hex,rgb,rgba,paleta,área de transferência,designer,developer,conta-gotas  
**Promotional Text:** Capture cores da área de transferência, escolha com o conta-gotas e mantenha uma paleta flutuante por perto — hex, rgb, rgba e nomes na barra de menus.

**Description:**

O Paint Buddy observa a área de transferência por cores — hex, rgb, rgba, nomes CSS e tuplos simples — e mantém um histórico organizado na barra de menus.

Abra a janela principal ou uma paleta flutuante sempre no topo quando precisar dos swatches. Escolha uma nova cor com um conta-gotas de um clique (sem gravação de ecrã). Defina que formatos guardar e como as cores copiadas são formatadas.

Pause a monitorização quando precisar de privacidade. Inicie no login se quiser. As cores ficam no seu Mac.

---

## Spanish (`es`)

**Name:** Paint Buddy  
**Subtitle:** Historial de color para Mac  
**Keywords:** color,selector,hex,rgb,rgba,paleta,portapapeles,diseñador,developer,cuentagotas  
**Promotional Text:** Captura colores del portapapeles, elige con el cuentagotas y mantén una paleta flotante cerca — hex, rgb, rgba y nombres en la barra de menús.

**Description:**

Paint Buddy vigila el portapapeles en busca de colores — hex, rgb, rgba, nombres CSS y tuplas simples — y guarda un historial ordenado en la barra de menús.

Abre la ventana principal o una paleta flotante siempre encima cuando necesites tus muestras. Elige un color nuevo con un cuentagotas de un clic (sin grabación de pantalla). Elige qué formatos guardar y cómo se formatean los colores copiados.

Pausa la monitorización cuando necesites privacidad. Inicia al iniciar sesión si quieres. Los colores permanecen en tu Mac.

---

## French (`fr`)

**Name:** Paint Buddy  
**Subtitle:** Historique de couleurs Mac  
**Keywords:** couleur,pipette,hex,rgb,rgba,palette,presse-papiers,designer,développeur,eyedropper  
**Promotional Text:** Capturez les couleurs du presse-papiers, prélevez à la pipette et gardez une palette flottante à portée — hex, rgb, rgba et noms dans la barre de menus.

**Description:**

Paint Buddy surveille votre presse-papiers pour les couleurs — hex, rgb, rgba, noms CSS et tuples simples — et conserve un historique clair dans la barre de menus.

Ouvrez la fenêtre principale ou une palette flottante toujours au premier plan quand vous avez besoin de vos nuancier. Prélevez une nouvelle couleur avec une pipette en un clic (sans enregistrement d’écran). Choisissez les formats à enregistrer et le format de copie.

Mettez la surveillance en pause pour plus d’intimité. Lancez au démarrage si vous le souhaitez. Les couleurs restent sur votre Mac.

---

## Italian (`it`)

**Name:** Paint Buddy  
**Subtitle:** Cronologia colori per Mac  
**Keywords:** colore,selettore,hex,rgb,rgba,palette,appunti,designer,developer,contagocce  
**Promotional Text:** Cattura i colori dagli appunti, scegli con il contagocce e tieni una palette flottante a portata — hex, rgb, rgba e nomi nella barra dei menu.

**Description:**

Paint Buddy controlla gli appunti alla ricerca di colori — hex, rgb, rgba, nomi CSS e tuple semplici — e mantiene una cronologia ordinata nella barra dei menu.

Apri la finestra principale o una palette flottante sempre in primo piano quando ti servono i campioni. Scegli un nuovo colore con un contagocce monouso (nessuna registrazione dello schermo). Scegli quali formati salvare e come formattare i colori copiati.

Metti in pausa il monitoraggio quando serve privacy. Avvia all’accesso se vuoi. I colori restano sul Mac.

---

## Arabic (`ar`)

**Name:** Paint Buddy  
**Subtitle:** سجل الألوان لـ Mac  
**Keywords:** لون,منتقي,hex,rgb,rgba,لوحة,حافظة,مصمم,مطور,قطارة  
**Promotional Text:** التقط الألوان من الحافظة، اختر بالقطارة، واحتفظ بلوحة عائمة قريبة — hex وrgb وrgba والأسماء في شريط القوائم.

**Description:**

يراقب Paint Buddy حافظتك بحثًا عن الألوان — hex وrgb وrgba وأسماء CSS والصفوف البسيطة — ويحفظ سجلًا مرتبًا في شريط القوائم.

افتح النافذة الرئيسية أو لوحة عائمة دائمًا في المقدمة عندما تحتاج إلى العينات. اختر لونًا جديدًا بقطارة بنقرة واحدة (بدون تسجيل الشاشة). حدد الصيغ التي تُحفظ وكيفية تنسيق الألوان المنسوخة.

أوقف المراقبة مؤقتًا عند الحاجة إلى الخصوصية. شغّل عند تسجيل الدخول إن أردت. تبقى الألوان على جهاز Mac.

---

## Chinese Simplified (`zh`)

**Name:** Paint Buddy  
**Subtitle:** Mac 颜色历史  
**Keywords:** 颜色,取色,hex,rgb,rgba,色板,剪贴板,设计师,开发者,吸管  
**Promotional Text:** 从剪贴板捕获颜色，用吸管取色，并保持浮动色板随时可用——hex、rgb、rgba 与命名色都在菜单栏。

**Description:**

Paint Buddy 会监视剪贴板中的颜色——hex、rgb、rgba、CSS 命名色以及简单元组——并在菜单栏保留整洁的历史记录。

需要色样时，打开主窗口或始终置顶的浮动色板。用一键吸管选取新颜色（无需屏幕录制）。可配置要保存的格式以及复制时的颜色格式。

需要隐私时可暂停监视。可选择登录时启动。颜色仅保存在你的 Mac 上。

---

## Russian (`ru`)

**Name:** Paint Buddy  
**Subtitle:** История цветов для Mac  
**Keywords:** цвет,пипетка,hex,rgb,rgba,палитра,буфер,дизайнер,разработчик,eyedropper  
**Promotional Text:** Ловите цвета из буфера, берите пипеткой и держите плавающую палитру рядом — hex, rgb, rgba и имена в меню.

**Description:**

Paint Buddy следит за буфером обмена на предмет цветов — hex, rgb, rgba, CSS-имена и простые кортежи — и хранит аккуратную историю в меню.

Откройте главное окно или плавающую палитру поверх всех окон, когда нужны образцы. Выберите новый цвет одноразовой пипеткой (без записи экрана). Настройте, какие форматы сохранять и как форматировать скопированные цвета.

Приостановите мониторинг, когда нужна приватность. Запуск при входе — по желанию. Цвета остаются на вашем Mac.

---

## Japanese (`ja`)

**Name:** Paint Buddy  
**Subtitle:** Macのカラー履歴  
**Keywords:** カラー,ピッカー,hex,rgb,rgba,パレット,クリップボード,デザイナー,開発者,スポイト  
**Promotional Text:** クリップボードから色を取り込み、スポイトで選び、フローティングパレットを手元に — hex / rgb / rgba / 名前付きカラーがメニューバーに。

**Description:**

Paint Buddy はクリップボード上の色 — hex、rgb、rgba、CSS の色名、簡単なタプル — を監視し、メニューバーに整理された履歴を残します。

スウォッチが必要なときはメインウィンドウか常時最前面のフローティングパレットを開きます。ワンショットのスポイトで新しい色を取得（画面収録は不要）。保存する形式とコピー時の書式を選べます。

プライバシーが必要なときは監視を一時停止。ログイン時起動も可能。色データは Mac 上に残ります。

---

## Google Play

N/A — macOS only.
