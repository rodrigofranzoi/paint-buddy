# Store Copy — Paint Buddy

Supported locales: `en`, `de`, `nl`, `pt`, `es`, `fr`, `it`, `ar`, `zh`, `ru`, `ja`.

## App Store Connect — naming (Guideline 5.2.5)

**Use exactly:** `Paint Buddy`  
**Do not use:** `Paint Buddy for Mac`, `… for macOS`, or any name that includes Apple product terms (`Mac`, `macOS`, `iPhone`, etc.).

Binary display name (`CFBundleDisplayName` / `CFBundleName`) is already `Paint Buddy`. Keep App Store Connect **Name** and on-device name aligned — never append “for Mac”.

## Legal URLs (App Store Connect)

- App Store ID: `6809586126`
- Privacy: https://rodrigofranzoi.github.io/paint-buddy/privacy.html
- Terms: https://rodrigofranzoi.github.io/paint-buddy/terms.html
- Rate / write review: https://apps.apple.com/app/id6809586126?action=write-review

## What's New (all locales)

Initial release.

---

## App Review Notes (Apple)

Paste into App Store Connect → App Review Information → Notes.

```
Paint Buddy is a macOS menu-bar (agent) app. There is no Dock icon by default (LSUIElement). Opening the main window temporarily shows a Dock icon (menu-bar pin otherwise).

NO LOGIN / DEMO ACCOUNT REQUIRED.

Launch at login: OFF by default. On first launch the app opens the main window and shows a consent popup (Not Now / Open at Login).
It only registers as a Login Item if the user chooses Open at Login. Later launches stay menu-bar only. Change anytime in Settings → Preferences → Startup (Guideline 2.4.5(iii)).

How to review:
1. Launch the app. Look for the paintpalette icon in the macOS menu bar.
2. Click the menu bar icon to open the recent-colors popover.
3. Copy a color string (e.g. #7C3AED, rgb(124,58,237), or a CSS name like tomato) — it should appear in Recent.
4. Click Pick Color (eyedropper): the cursor changes; click once on screen to save a color (NSColorSampler — one-shot, not continuous sampling).
5. Open the main window: switch History | Favorites. Star a color, or add one with + (Color Picker + hex/rgba fields).
6. Toggle Floating History and Floating Favorites (always-on-top). Try grid / list / detailed layouts and swatch size.
7. In detailed floating rows or the main detail pane: copy preferred format, Hex, and R/G/B/A channel chips. Try Suggestions swatches.
8. Settings (gear): capture formats, preferred copy format (incl. hex without #), history limits, Support → Rate, pause, optional launch at login, appearance / accent.
9. Pause from the menu bar, then resume. Clear history from Settings.

Permissions / entitlements:
- No Screen Recording entitlement.
- Clipboard: reads pasteboard text locally only to detect color tokens (hex, rgb, rgba, named CSS colors, tuples).
- Network client: Firebase Analytics & Crashlytics only.
- Export compliance: exempt — HTTPS/TLS only (ITSAppUsesNonExemptEncryption = false).

Privacy:
- Color history and favorites stay on device (UserDefaults / JSON). Never uploaded.
- Analytics/Crashlytics do not include clipboard or color payloads.

Contact: use the App Store Connect account owner email if anything is unclear.
```

---

## TestFlight Notes

### Beta App Description

Paste into TestFlight → Test Information → Beta App Description.

```
Paint Buddy captures colors from your clipboard (hex, rgb, rgba, named, tuples) and keeps History + Favorites in the menu bar, main window, and dual always-on-top floating panels. One-shot eyedropper, channel copy, and color suggestions — no Screen Recording.
```

### What to Test

Paste into TestFlight → Test Information → What to Test.

```
Thanks for testing Paint Buddy!

Please try:
• Menu bar icon → recent colors → Open / Rate / Settings
• Copy color strings: #FF5733, rgb(255,87,51), rgba(...), tomato, (0.5, 0.2, 0.8)
• Pick Color (eyedropper): click once to sample into history or favorites
• Main window History | Favorites; + to add a favorite manually
• Floating History + Floating Favorites: grid / list / detailed; swatch size; Hex & R/G/B/A chips
• Favorite from context menu or detail pane; suggestions under the selected color
• Preferred copy format (incl. hex without #); per-channel copy
• Toggle capture formats; pause monitoring; history limits; Clear all colors
• Launch at login and appearance / accent

Report crashes, localization issues, and anything confusing in the palettes or history.

No account needed. All color data stays on your Mac.
```

### Beta App Review (TestFlight)

Same content as **App Review Notes** above if Apple requests Beta App Review Information. No demo account.

---

## Feature highlights (for listing / ASO)

Use across subtitle, promotional text, and description:

- Clipboard color capture: hex, rgb, rgba, named CSS, tuples
- Menu bar recent colors + Open / Pick / History / Favorites / Pause
- Main window with History | Favorites, detail values, suggestions
- Dual always-on-top floating panels (History + Favorites)
- Floating layouts: grid, list, detailed (Hex + R/G/B/A chips)
- One-shot eyedropper (no Screen Recording)
- Preferred copy format including hex without #
- Per-channel copy; star favorites; add favorite manually
- Pause monitoring, launch at login, appearance / accent, Rate App

---

## English (`en`)

**Name:** Paint Buddy  
**Subtitle:** Color history & favorites  
**Keywords:** color,hex,rgb,rgba,palette,favorites,clipboard,eyedropper,designer,developer  
**Promotional Text:** Capture clipboard colors, pin Favorites, and keep dual floating palettes on top — hex, RGB, channels & suggestions in the menu bar.

**Description:**

Paint Buddy watches your clipboard for colors — hex, rgb, rgba, named CSS colors, and simple tuples — and keeps a tidy History in the menu bar.

Open the main window to browse History or Favorites, copy Hex / RGB / RGBA or individual R, G, B, A channels, and explore suggested darker, lighter, and harmony colors. Pick from the screen with a one-shot eyedropper (no Screen Recording).

Keep Floating History and Floating Favorites always on top while you design or code. Switch grid, list, or detailed layouts, resize swatches, and copy preferred formats — including hex without the #.

Pause monitoring when you need privacy. Launch at login if you like. Rate the app from Settings when it helps your workflow. Colors stay on your Mac.

---

## German (`de`)

**Name:** Paint Buddy  
**Subtitle:** Farbhistorie & Favoriten  
**Keywords:** Farbe,hex,rgb,rgba,Palette,Favoriten,Zwischenablage,Pipette,Designer,Entwickler  
**Promotional Text:** Zwischenablage-Farben erfassen, Favoriten pinnen und duale schwebende Paletten oben halten — Hex, RGB, Kanäle & Vorschläge in der Menüleiste.

**Description:**

Paint Buddy überwacht Ihre Zwischenablage auf Farben — Hex, RGB, RGBA, benannte CSS-Farben und einfache Tupel — und hält eine übersichtliche Historie in der Menüleiste bereit.

Öffnen Sie das Hauptfenster, um Historie oder Favoriten zu durchsuchen, Hex / RGB / RGBA oder einzelne R-, G-, B-, A-Kanäle zu kopieren und vorgeschlagene dunklere, hellere und Harmonie-Farben zu erkunden. Farben vom Bildschirm mit einer Einmal-Pipette aufnehmen (ohne Bildschirmaufzeichnung).

Halten Sie schwebende Historie und schwebende Favoriten immer im Vordergrund, während Sie designen oder programmieren. Wechseln Sie zwischen Raster-, Listen- und Detailansicht, passen Sie Swatch-Größen an und kopieren Sie bevorzugte Formate — inklusive Hex ohne #.

Pausieren Sie die Überwachung, wenn Sie Privatsphäre brauchen. Optionaler Start bei Anmeldung. Bewerten Sie die App in den Einstellungen, wenn sie Ihren Workflow unterstützt. Farben bleiben auf Ihrem Mac.

---

## Dutch (`nl`)

**Name:** Paint Buddy  
**Subtitle:** Kleurenhistorie & favorieten  
**Keywords:** kleur,hex,rgb,rgba,palet,favorieten,klembord,pipet,designer,developer  
**Promotional Text:** Vang klembordkleuren, pin Favorieten en houd twee zwevende paletten bovenaan — hex, RGB, kanalen & suggesties in de menubalk.

**Description:**

Paint Buddy volgt je klembord op kleuren — hex, rgb, rgba, CSS-kleurnamen en eenvoudige tuples — en bewaart een nette Geschiedenis in de menubalk.

Open het hoofdvenster voor Geschiedenis of Favorieten, kopieer Hex / RGB / RGBA of aparte R-, G-, B- en A-kanalen, en ontdek voorgestelde donkerdere, lichtere en harmoniekleuren. Kies van het scherm met een eenmalige pipet (geen schermopname).

Houd Zwevende Geschiedenis en Zwevende Favorieten altijd bovenaan terwijl je ontwerpt of codeert. Wissel raster, lijst of detail, pas swatchgrootte aan en kopieer je voorkeursformaat — inclusief hex zonder #.

Pauzeer monitoring voor privacy. Start bij inloggen als je wilt. Beoordeel de app in Instellingen als die je helpt. Kleuren blijven op je Mac.

---

## Portuguese (`pt`)

**Name:** Paint Buddy  
**Subtitle:** Histórico e favoritos de cor  
**Keywords:** cor,hex,rgb,rgba,paleta,favoritos,clipboard,conta-gotas,designer,developer  
**Promotional Text:** Capture cores da área de transferência, fixe Favoritos e mantenha duas paletas flutuantes no topo — hex, RGB, canais e sugestões na barra de menus.

**Description:**

O Paint Buddy observa a área de transferência por cores — hex, rgb, rgba, nomes CSS e tuplos simples — e mantém um Histórico organizado na barra de menus.

Abra a janela principal para Histórico ou Favoritos, copie Hex / RGB / RGBA ou canais R, G, B e A, e explore sugestões mais escuras, claras e em harmonia. Escolha no ecrã com um conta-gotas de um clique (sem gravação de ecrã).

Mantenha Histórico flutuante e Favoritos flutuantes sempre no topo enquanto desenha ou programa. Alterne grelha, lista ou detalhado, ajuste o tamanho dos swatches e copie o formato preferido — incluindo hex sem #.

Pause a monitorização para privacidade. Inicie no login se quiser. Avalie a app nas Definições se ajudar o seu fluxo. As cores ficam no seu Mac.

---

## Spanish (`es`)

**Name:** Paint Buddy  
**Subtitle:** Historial y favoritos de color  
**Keywords:** color,hex,rgb,rgba,paleta,favoritos,portapapeles,cuentagotas,diseñador,developer  
**Promotional Text:** Captura colores del portapapeles, fija Favoritos y mantén dos paletas flotantes arriba — hex, RGB, canales y sugerencias en la barra de menús.

**Description:**

Paint Buddy vigila el portapapeles en busca de colores — hex, rgb, rgba, nombres CSS y tuplas simples — y guarda un Historial ordenado en la barra de menús.

Abre la ventana principal para Historial o Favoritos, copia Hex / RGB / RGBA o canales R, G, B y A, y explora sugerencias más oscuras, claras y armónicas. Elige de la pantalla con un cuentagotas de un clic (sin grabación de pantalla).

Mantén Historial flotante y Favoritos flotantes siempre encima mientras diseñas o programas. Cambia entre cuadrícula, lista o detalle, ajusta el tamaño de las muestras y copia el formato preferido — incluido hex sin #.

Pausa la monitorización para privacidad. Inicia al iniciar sesión si quieres. Valora la app en Ajustes si te ayuda. Los colores permanecen en tu Mac.

---

## French (`fr`)

**Name:** Paint Buddy  
**Subtitle:** Historique & favoris couleur  
**Keywords:** couleur,hex,rgb,rgba,palette,favoris,presse-papiers,pipette,designer,développeur  
**Promotional Text:** Capturez les couleurs du presse-papiers, épinglez des Favoris et gardez deux palettes flottantes au premier plan — hex, RGB, canaux et suggestions dans la barre de menus.

**Description:**

Paint Buddy surveille votre presse-papiers pour les couleurs — hex, rgb, rgba, noms CSS et tuples simples — et conserve un Historique clair dans la barre de menus.

Ouvrez la fenêtre principale pour Historique ou Favoris, copiez Hex / RGB / RGBA ou les canaux R, G, B et A, et explorez des suggestions plus sombres, plus claires et harmoniques. Prélevez à l’écran avec une pipette en un clic (sans enregistrement d’écran).

Gardez l’Historique flottant et les Favoris flottants toujours au premier plan pendant que vous dessinez ou codez. Passez en grille, liste ou détaillé, ajustez la taille des pastilles et copiez le format préféré — y compris hex sans #.

Mettez la surveillance en pause pour plus d’intimité. Lancez au démarrage si vous le souhaitez. Notez l’app dans Réglages si elle vous aide. Les couleurs restent sur votre Mac.

---

## Italian (`it`)

**Name:** Paint Buddy  
**Subtitle:** Cronologia e preferiti colore  
**Keywords:** colore,hex,rgb,rgba,palette,preferiti,appunti,contagocce,designer,developer  
**Promotional Text:** Cattura i colori dagli appunti, fissa i Preferiti e tieni due palette flottanti in primo piano — hex, RGB, canali e suggerimenti nella barra dei menu.

**Description:**

Paint Buddy controlla gli appunti alla ricerca di colori — hex, rgb, rgba, nomi CSS e tuple semplici — e mantiene una Cronologia ordinata nella barra dei menu.

Apri la finestra principale per Cronologia o Preferiti, copia Hex / RGB / RGBA o i canali R, G, B e A, ed esplora suggerimenti più scuri, chiari e in armonia. Scegli dallo schermo con un contagocce monouso (nessuna registrazione dello schermo).

Tieni Cronologia flottante e Preferiti flottanti sempre in primo piano mentre progetti o programmi. Passa tra griglia, elenco o dettagliato, regola la dimensione dei campioni e copia il formato preferito — incluso hex senza #.

Metti in pausa il monitoraggio per la privacy. Avvia all’accesso se vuoi. Valuta l’app in Impostazioni se ti aiuta. I colori restano sul Mac.

---

## Arabic (`ar`)

**Name:** Paint Buddy  
**Subtitle:** سجل الألوان والمفضلات  
**Keywords:** لون,hex,rgb,rgba,لوحة,مفضلة,حافظة,قطارة,مصمم,مطور  
**Promotional Text:** التقط ألوان الحافظة، ثبّت المفضلات، واحتفظ بلوحتين عائمتين في المقدمة — hex وRGB والقنوات والاقتراحات في شريط القوائم.

**Description:**

يراقب Paint Buddy حافظتك بحثًا عن الألوان — hex وrgb وrgba وأسماء CSS والصفوف البسيطة — ويحفظ سجلًا مرتبًا في شريط القوائم.

افتح النافذة الرئيسية للسجل أو المفضلات، وانسخ Hex / RGB / RGBA أو قنوات R وG وB وA، واستكشف اقتراحات أغمق وأفتح وتناغمية. التقط من الشاشة بقطارة بنقرة واحدة (بدون تسجيل الشاشة).

أبقِ السجل العائم والمفضلات العائمة دائمًا في المقدمة أثناء التصميم أو البرمجة. بدّل بين الشبكة والقائمة والتفصيلي، واضبط حجم العينات، وانسخ التنسيق المفضّل — بما في ذلك hex بدون #.

أوقف المراقبة مؤقتًا للخصوصية. شغّل عند تسجيل الدخول إن أردت. قيّم التطبيق من الإعدادات إن ساعدك. تبقى الألوان على جهاز Mac.

---

## Chinese Simplified (`zh`)

**Name:** Paint Buddy  
**Subtitle:** 颜色历史与收藏  
**Keywords:** 颜色,hex,rgb,rgba,色板,收藏,剪贴板,吸管,设计师,开发者  
**Promotional Text:** 从剪贴板捕获颜色、固定收藏，并保持双浮动色板置顶——菜单栏即可使用 hex、RGB、通道与配色建议。

**Description:**

Paint Buddy 会监视剪贴板中的颜色——hex、rgb、rgba、CSS 命名色以及简单元组——并在菜单栏保留整洁的历史记录。

打开主窗口浏览历史或收藏，复制 Hex / RGB / RGBA 或单独的 R、G、B、A 通道，并探索更深、更浅与和谐的配色建议。用一键吸管从屏幕取色（无需屏幕录制）。

设计或写代码时，让浮动历史与浮动收藏始终置顶。切换网格、列表或详细布局，调整色块大小，并按偏好格式复制——包括不带 # 的 hex。

需要隐私时可暂停监视。可选择登录时启动。若觉得好用，可在设置中评分。颜色仅保存在你的 Mac 上。

---

## Russian (`ru`)

**Name:** Paint Buddy  
**Subtitle:** История и избранные цвета  
**Keywords:** цвет,hex,rgb,rgba,палитра,избранное,буфер,пипетка,дизайнер,разработчик  
**Promotional Text:** Ловите цвета из буфера, закрепляйте Избранное и держите две плавающие палитры сверху — hex, RGB, каналы и подсказки в меню.

**Description:**

Paint Buddy следит за буфером обмена на предмет цветов — hex, rgb, rgba, CSS-имена и простые кортежи — и хранит аккуратную Историю в меню.

Откройте главное окно для Истории или Избранного, копируйте Hex / RGB / RGBA или каналы R, G, B и A и изучайте более тёмные, светлые и гармоничные подсказки. Берите цвет с экрана одноразовой пипеткой (без записи экрана).

Держите плавающую Историю и плавающее Избранное поверх окон, пока дизайните или пишете код. Переключайте сетку, список или подробный вид, меняйте размер образцов и копируйте предпочитаемый формат — включая hex без #.

Приостановите мониторинг ради приватности. Запуск при входе — по желанию. Оцените приложение в Настройках, если оно помогает. Цвета остаются на вашем Mac.

---

## Japanese (`ja`)

**Name:** Paint Buddy  
**Subtitle:** カラー履歴とお気に入り  
**Keywords:** カラー,hex,rgb,rgba,パレット,お気に入り,クリップボード,スポイト,デザイナー,開発者  
**Promotional Text:** クリップボードから色を取り込み、お気に入りを固定。二重のフローティングパレットを前面に — hex / RGB / チャンネル / 提案がメニューバーに。

**Description:**

Paint Buddy はクリップボード上の色 — hex、rgb、rgba、CSS の色名、簡単なタプル — を監視し、メニューバーに整理された履歴を残します。

メインウィンドウで履歴またはお気に入りを開き、Hex / RGB / RGBA や R・G・B・A チャンネルをコピーし、より暗い・明るい・調和の提案を試せます。ワンショットのスポイトで画面から取得（画面収録は不要）。

デザインやコーディング中はフローティング履歴とフローティングお気に入りを常に前面に。グリッド / リスト / 詳細を切り替え、スウォッチサイズを変え、# なし hex を含む好みの形式でコピーできます。

プライバシーが必要なときは監視を一時停止。ログイン時起動も可能。役立つときは設定から評価を。色データは Mac 上に残ります。

---

## Google Play

N/A — macOS only.
