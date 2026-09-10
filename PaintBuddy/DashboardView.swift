import SwiftUI
import BuddyCore
import BuddyUI
import AppKit

private enum DashboardListMode: String, CaseIterable, Identifiable {
    case history
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .history: return "History"
        case .favorites: return "Favorites"
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var store: ColorStore
    @State private var listMode: DashboardListMode = .history
    @State private var showAddFavorite = false
    @State private var manualFavoriteColor = Color.white

    private var selected: ColorHistoryItem? {
        store.item(id: store.selectedId)
    }

    private var listItems: [ColorHistoryItem] {
        switch listMode {
        case .history: return store.items
        case .favorites: return store.favorites
        }
    }

    private var pickDestination: PaintColorPickDestination {
        listMode == .favorites ? .favorites : .history
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: BuddyTheme.Spacing.md) {
                Picker(selection: $listMode) {
                    ForEach(DashboardListMode.allCases) { mode in
                        Text(LocalizedStringKey(mode.title)).tag(mode)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .accessibilityLabel("History or Favorites")
                .accessibilityIdentifier("dashboard-list-mode")

                if listItems.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: listMode == .favorites ? "star" : "paintpalette")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        if listMode == .favorites {
                            Text("No favorites yet")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("No colors yet")
                                .foregroundStyle(.secondary)
                        }
                        if listMode == .favorites {
                            Text("Pick a color, add one manually, or favorite from history")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                            Button("Add Color") {
                                showAddFavorite = true
                            }
                            .accessibilityIdentifier("dashboard-add-favorite-empty")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollViewReader { proxy in
                        List(listItems, selection: $store.selectedId) { item in
                            ColorHistoryRow(item: item)
                                .tag(item.id)
                                .id(item.id)
                                .listRowSeparator(.visible)
                                .listRowSeparatorTint(BuddyTheme.BuddyColor.border.opacity(0.4))
                                .accessibilityIdentifier("history-row")
                                .contextMenu {
                                    Button("Copy") {
                                        store.copyItem(item)
                                    }
                                    if listMode == .history {
                                        Button(store.isFavorite(item) ? "Remove Favorite" : "Favorite") {
                                            store.toggleFavorite(item)
                                        }
                                        Button("Delete", role: .destructive) {
                                            store.delete(item)
                                        }
                                    } else {
                                        Button("Remove Favorite", role: .destructive) {
                                            store.removeFavorite(item)
                                        }
                                    }
                                }
                        }
                        .listStyle(.inset)
                        .accessibilityIdentifier(listMode == .favorites ? "favorites-list" : "history-list")
                        .onChange(of: store.selectedId) { id in
                            focusList(on: id, proxy: proxy)
                        }
                        .onChange(of: store.items.first?.id) { _ in
                            focusList(on: store.selectedId, proxy: proxy)
                        }
                        .onChange(of: store.favorites.first?.id) { _ in
                            focusList(on: store.selectedId, proxy: proxy)
                        }
                    }
                }
            }
            .padding(BuddyTheme.Spacing.lg)
            .background(BuddyTheme.BuddyColor.background)
            .navigationTitle("Colors")
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 420)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        NotificationCenter.default.post(name: .paintToggleFloatingPanel, object: nil)
                    } label: {
                        Image(systemName: "clock")
                    }
                    .help("Floating History")
                    .accessibilityIdentifier("toolbar-floating-palette")

                    Button {
                        NotificationCenter.default.post(name: .paintToggleFloatingFavoritesPanel, object: nil)
                    } label: {
                        Image(systemName: "swatchpalette")
                    }
                    .help("Floating Favorites")
                    .accessibilityIdentifier("toolbar-floating-favorites")

                    BuddySettingsGearButton()
                }
            }
        } detail: {
            Group {
                if let selected {
                    ColorDetailPane(item: selected)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "paintpalette")
                            .font(.largeTitle)
                        Text("Select a color")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        NotificationCenter.postPaintShowColorPicker(destination: pickDestination)
                    } label: {
                        Image(systemName: "eyedropper")
                    }
                    .help(listMode == .favorites ? "Pick Favorite Color" : "Pick Color")
                    .accessibilityIdentifier("toolbar-pick-color")

                    Button {
                        showAddFavorite = true
                    } label: {
                        AddFavoriteSymbol()
                    }
                    .help("Add favorite color")
                    .accessibilityIdentifier("dashboard-add-favorite")
                    .popover(isPresented: $showAddFavorite, arrowEdge: .bottom) {
                        AddFavoriteColorPopover(color: $manualFavoriteColor) { nsColor in
                            store.addFavorite(color: nsColor)
                            listMode = .favorites
                            showAddFavorite = false
                        }
                    }

                    BuddyClearHistoryButton(itemNoun: "colors", style: .toolbar) {
                        store.clearAllHistory()
                    }
                    .disabled(store.items.isEmpty)
                }
            }
        }
    }

    private func focusList(on id: UUID?, proxy: ScrollViewProxy) {
        guard let id else { return }
        if store.items.contains(where: { $0.id == id }) {
            listMode = .history
        } else if store.favorites.contains(where: { $0.id == id }) {
            listMode = .favorites
        } else {
            return
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }
}

struct ColorHistoryRow: View {
    @EnvironmentObject private var store: ColorStore
    let item: ColorHistoryItem

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(nsColor: item.nsColor ?? .gray))
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.5), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.buddyBody)
                    .lineLimit(1)
                Text(item.raw)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)

            if store.isFavorite(item) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Favorite")
            }

            Button {
                store.copyItem(item)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Copy color")
        }
        .padding(.vertical, 2)
    }
}

struct ColorDetailPane: View {
    @EnvironmentObject private var store: ColorStore
    let item: ColorHistoryItem

    private var suggestions: [PaintColorSuggestion] {
        guard let color = item.nsColor else { return [] }
        return PaintColorSuggestions.suggestions(from: color)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BuddyTheme.Spacing.md) {
                ContrastPreviewSwatch(
                    color: item.nsColor ?? .gray,
                    title: item.displayTitle
                )

                HStack(spacing: BuddyTheme.Spacing.sm) {
                    Button("Copy Preferred Format") {
                        store.copyItem(item)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("detail-copy")

                    Button {
                        store.toggleFavorite(item)
                    } label: {
                        Label(
                            store.isFavorite(item) ? "Favorited" : "Favorite",
                            systemImage: store.isFavorite(item) ? "star.fill" : "star"
                        )
                    }
                    .accessibilityIdentifier("detail-favorite")
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: BuddyTheme.Spacing.sm) {
                        CopyableColorValueRow(title: "Hex", value: item.hex) {
                            store.copyItem(item, format: .hex)
                        }
                        CopyableColorValueRow(
                            title: "No #",
                            value: EditorRedactionSettings.hexPlain(fromHex: item.hex)
                        ) {
                            store.copyItem(item, format: .hexPlain)
                        }
                        if let color = item.nsColor {
                            let components = EditorRedactionSettings.rgbaComponents(from: color)
                            CopyableColorValueRow(
                                title: "RGB",
                                value: EditorRedactionSettings.rgbString(from: color),
                                channels: [
                                    ("R", "\(components.r)"),
                                    ("G", "\(components.g)"),
                                    ("B", "\(components.b)")
                                ]
                            ) {
                                store.copyItem(item, format: .rgb)
                            }
                            CopyableColorValueRow(
                                title: "RGBA",
                                value: EditorRedactionSettings.rgbaString(from: color),
                                channels: [
                                    ("R", "\(components.r)"),
                                    ("G", "\(components.g)"),
                                    ("B", "\(components.b)"),
                                    ("A", alphaChannelString(components.a))
                                ]
                            ) {
                                store.copyItem(item, format: .rgba)
                            }
                        }
                        LabeledContent("Captured") {
                            Text(item.raw)
                                .textSelection(.enabled)
                        }
                        LabeledContent("Source") {
                            if item.source == .picker {
                                Text("Color Panel")
                            } else {
                                Text("Clipboard")
                            }
                        }
                    }
                    .font(.buddyBody)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Text("Values")
                }

                if !suggestions.isEmpty {
                    GroupBox {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 72, maximum: 96), spacing: 8)],
                            spacing: 8
                        ) {
                            ForEach(suggestions) { suggestion in
                                SuggestionSwatch(suggestion: suggestion)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Text("Suggestions")
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(item.displayTitle)
    }

    private func alphaChannelString(_ alpha: Double) -> String {
        if abs(alpha - 1) < 0.000_1 { return "1" }
        return String(alpha)
    }
}

private struct ContrastSwatchOption: Identifiable, Equatable {
    let id: String
    let label: String
    let color: Color
}

/// Large selected-color preview with a full-width contrast strip.
private struct ContrastPreviewSwatch: View {
    let color: NSColor
    let title: String

    private let swatchHeight: CGFloat = 160
    private let collapsedStripHeight: CGFloat = 22

    private let options: [ContrastSwatchOption] = [
        .init(id: "black", label: "Black", color: .black),
        .init(id: "white", label: "White", color: .white),
        .init(id: "red", label: "Red", color: Color(red: 1, green: 0.23, blue: 0.19)),
        .init(id: "green", label: "Green", color: Color(red: 0.20, green: 0.78, blue: 0.35)),
        .init(id: "blue", label: "Blue", color: Color(red: 0.0, green: 0.48, blue: 1.0)),
        .init(id: "cyan", label: "Cyan", color: Color(red: 0.20, green: 0.84, blue: 0.90)),
        .init(id: "magenta", label: "Magenta", color: Color(red: 1.0, green: 0.18, blue: 0.57)),
        .init(id: "yellow", label: "Yellow", color: Color(red: 1.0, green: 0.80, blue: 0.0)),
        .init(id: "indigo", label: "Indigo", color: Color(red: 0.35, green: 0.34, blue: 0.84))
    ]

    @State private var isPinned = false
    @State private var isHovered = false

    private var isExpanded: Bool {
        isPinned || isHovered
    }

    var body: some View {
        GeometryReader { geo in
            let stripHeight = isExpanded ? geo.size.height * 0.5 : collapsedStripHeight

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: color))

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        option.color
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .accessibilityLabel(option.label)
                    }
                }
                .frame(height: stripHeight)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.28), value: isExpanded)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.4), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.28)) {
                    isHovered = hovering
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.28)) {
                    isPinned.toggle()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: swatchHeight)
        .help(isPinned ? "Click to collapse contrast colors" : "Hover or click to preview contrast")
        .accessibilityLabel(title)
        .accessibilityHint("Hover or click to show contrast colors at half height")
        .accessibilityValue(isExpanded ? "Contrast preview open" : "")
        .accessibilityAddTraits(.isButton)
        .onChange(of: title) { _ in
            isPinned = false
            isHovered = false
        }
    }
}

private struct SuggestionSwatch: View {
    @EnvironmentObject private var store: ColorStore
    let suggestion: PaintColorSuggestion

    @State private var justCopied = false

    var body: some View {
        Button {
            store.copyString(PaintColorSettings.copyFormat.string(from: suggestion.color))
            justCopied = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                justCopied = false
            }
        } label: {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: suggestion.color))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(BuddyTheme.BuddyColor.border.opacity(0.5), lineWidth: 1)
                    )
                    .overlay {
                        if justCopied {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(.black.opacity(0.45))
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                Text(suggestion.label)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(suggestion.hex)
        .contextMenu {
            Button("Copy") {
                store.copyString(PaintColorSettings.copyFormat.string(from: suggestion.color))
            }
            Button(store.isFavorite(hex: suggestion.hex) ? "Remove Favorite" : "Favorite") {
                if store.isFavorite(hex: suggestion.hex) {
                    store.removeFavorite(hex: suggestion.hex)
                } else {
                    _ = store.addFavorite(color: suggestion.color, raw: suggestion.hex, kind: .hex)
                }
            }
        }
        .accessibilityLabel("\(suggestion.label) \(suggestion.hex)")
        .accessibilityHint("Copies to clipboard")
    }
}

/// Tappable color format value with a trailing copy button. Copy does not add to history.
private struct CopyableColorValueRow: View {
    let title: LocalizedStringKey
    let value: String
    var channels: [(label: LocalizedStringKey, value: String)] = []
    let onCopy: () -> Void

    @EnvironmentObject private var store: ColorStore
    @State private var valueJustCopied = false
    @State private var buttonJustCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: BuddyTheme.Spacing.sm) {
                Text(title)
                    .foregroundStyle(.secondary)
                    .frame(width: 56, alignment: .leading)

                Button(action: copyValue) {
                    HStack(spacing: 4) {
                        if valueJustCopied {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.green)
                        }
                        Text(value)
                            .foregroundStyle(valueJustCopied ? Color.green : Color.primary)
                            .lineLimit(1)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(valueJustCopied ? "Copied" : "Copy \(title)")
                .accessibilityLabel(Text("\(title) \(value)"))
                .accessibilityHint("Copies to clipboard")
                .accessibilityValue(valueJustCopied ? "Copied" : "")

                Button(action: copyButton) {
                    Image(systemName: buttonJustCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(buttonJustCopied ? Color.green : Color.secondary)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(buttonJustCopied ? Text("Copied") : Text("Copy \(title)"))
                .help(buttonJustCopied ? "Copied" : "Copy to clipboard")

                Spacer(minLength: 0)
            }

            if !channels.isEmpty {
                HStack(spacing: 6) {
                    Text("")
                        .frame(width: 56)
                    ForEach(Array(channels.enumerated()), id: \.offset) { _, channel in
                        ChannelCopyChip(label: channel.label, value: channel.value) {
                            store.copyString(channel.value)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func copyValue() {
        onCopy()
        valueJustCopied = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            valueJustCopied = false
        }
    }

    private func copyButton() {
        onCopy()
        buttonJustCopied = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            buttonJustCopied = false
        }
    }
}

private struct ChannelCopyChip: View {
    let label: LocalizedStringKey
    let value: String
    let onCopy: () -> Void

    @State private var justCopied = false

    var body: some View {
        Button {
            onCopy()
            justCopied = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                justCopied = false
            }
        } label: {
            HStack(spacing: 4) {
                Text(label)
                Text(value)
            }
            .font(.caption.monospaced())
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(justCopied ? Color.green.opacity(0.45) : BuddyTheme.BuddyColor.border.opacity(0.25))
            )
        }
        .buttonStyle(.plain)
        .help(justCopied ? "Copied" : "Copy \(label)")
        .accessibilityLabel(Text("Copy \(label) \(value)"))
        .accessibilityValue(justCopied ? "Copied" : "")
    }
}
