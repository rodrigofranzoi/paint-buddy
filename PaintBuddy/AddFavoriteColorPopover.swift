import SwiftUI
import AppKit
import BuddyCore
import BuddyUI

struct AddFavoriteColorPopover: View {
    @Binding var color: Color
    let onAdd: (NSColor) -> Void

    @State private var hexField = ""
    @State private var rgbaField = ""
    @State private var invalidHint: String?

    var body: some View {
        VStack(alignment: .leading, spacing: BuddyTheme.Spacing.sm) {
            Text("Add Favorite")
                .font(.headline)

            ColorPicker("Color", selection: $color, supportsOpacity: true)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: color) { _ in
                    syncFields(from: NSColor(color))
                    invalidHint = nil
                }

            VStack(alignment: .leading, spacing: BuddyTheme.Spacing.xs) {
                Text("Hex")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("#RRGGBB or RRGGBB", text: $hexField)
                    .textFieldStyle(.roundedBorder)
                    .font(.body.monospaced())
                    .onSubmit { applyToken(hexField) }
                    .accessibilityIdentifier("add-favorite-hex")
            }

            VStack(alignment: .leading, spacing: BuddyTheme.Spacing.xs) {
                Text("RGBA")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("rgba(r, g, b, a)", text: $rgbaField)
                    .textFieldStyle(.roundedBorder)
                    .font(.body.monospaced())
                    .onSubmit { applyToken(rgbaField) }
                    .accessibilityIdentifier("add-favorite-rgba")
            }

            if let invalidHint {
                Text(invalidHint)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Add to Favorites") {
                commitAdd()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
            .accessibilityIdentifier("add-favorite-confirm")
        }
        .padding()
        .frame(minWidth: 240)
        .onAppear {
            syncFields(from: NSColor(color))
        }
    }

    private func syncFields(from nsColor: NSColor) {
        hexField = EditorRedactionSettings.hex(from: nsColor)
        rgbaField = EditorRedactionSettings.rgbaString(from: nsColor)
    }

    @discardableResult
    private func applyToken(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            invalidHint = "Enter a hex or rgba color"
            return false
        }
        guard let nsColor = EditorRedactionSettings.nsColor(fromColorToken: trimmed) else {
            invalidHint = "Unrecognized color"
            return false
        }
        color = Color(nsColor: nsColor)
        syncFields(from: nsColor)
        invalidHint = nil
        return true
    }

    private func commitAdd() {
        let hexTrimmed = hexField.trimmingCharacters(in: .whitespacesAndNewlines)
        let rgbaTrimmed = rgbaField.trimmingCharacters(in: .whitespacesAndNewlines)

        if !hexTrimmed.isEmpty,
           let fromHex = EditorRedactionSettings.nsColor(fromColorToken: hexTrimmed) {
            color = Color(nsColor: fromHex)
            onAdd(fromHex)
            return
        }
        if !rgbaTrimmed.isEmpty,
           let fromRGBA = EditorRedactionSettings.nsColor(fromColorToken: rgbaTrimmed) {
            color = Color(nsColor: fromRGBA)
            onAdd(fromRGBA)
            return
        }

        if hexTrimmed.isEmpty && rgbaTrimmed.isEmpty {
            invalidHint = nil
            onAdd(NSColor(color))
            return
        }
        invalidHint = "Unrecognized color"
    }
}

/// macOS 13-safe stand-in for `star.badge.plus` (SF Symbols 5+ / macOS 14+).
struct AddFavoriteSymbol: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "star")
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 8, weight: .bold))
                .background(
                    Circle()
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .padding(-1)
                )
                .offset(x: 4, y: 3)
        }
        .frame(width: 20, height: 16)
        .accessibilityHidden(true)
    }
}
