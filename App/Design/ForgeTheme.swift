import SwiftUI
import UIKit

// MARK: - Color extensions for Adaptive & Hex parsing

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "# "))
        var v: UInt64 = 0
        guard !s.isEmpty, Scanner(string: s).scanHexInt64(&v) else {
            self = .clear
            return
        }
        self.init(
            red:   Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue:  Double(v & 0xFF) / 255
        )
    }

    init(hex: UInt32, alpha: Double = 1) {
        self = Color(hex: String(format: "%06X", hex)).opacity(alpha)
    }

    init(light: String, dark: String) {
        self = Color(UIColor { trait in
            UIColor(Color(hex: trait.userInterfaceStyle == .dark ? dark : light))
        })
    }
}

/// Official Apple App Store Theme Palette (Light & Dark Modes)
/// Replaces the colorless slate-glass palette with native iOS App Store colors,
/// crisp SF Pro typography, and standard 20pt editorial margins.
struct ForgeTheme {
    // Background layers
    let bg: Color           // page background (pure white / pure black)
    let surface: Color      // primary cards (#F2F2F7 / #1C1C1E)
    let surface2: Color     // secondary surface / pill fills (#E5E5EA / #2C2C2E)
    let surface3: Color     // tertiary subtle surface (#F9F9FB / #141416)

    // Text ink (4 levels of Apple HIG hierarchy)
    let ink: Color          // primary label
    let ink2: Color         // secondary label
    let ink3: Color         // tertiary label
    let ink4: Color         // quaternary / disabled label

    // Borders & Dividers
    let rule: Color         // standard App Store hairline separator
    let rule2: Color        // emphasized border

    // Brand / App Store Blue Accent
    let accent: Color
    let accentSoft: Color
    let accentSofter: Color

    // Semantic iOS System Colors
    let good: Color
    let warn: Color
    let bad: Color

    // Layout Spacing
    let pad: CGFloat
    let gap: CGFloat

    let isDark: Bool

    // Accent gradient anchors (App Store Icon Blue Gradient)
    let accentHi: Color
    let accentDeep: Color
    let accentStrong: Color
}

extension ForgeTheme {
    /// Apple App Store Light Theme
    static let light = ForgeTheme(
        bg:        Color(hex: "FFFFFF"),
        surface:   Color(hex: "F2F2F7"),
        surface2:  Color(hex: "E5E5EA"),
        surface3:  Color(hex: "F9F9FB"),
        ink:       Color(hex: "000000"),
        ink2:      Color(hex: "636366"),
        ink3:      Color(hex: "8E8E93"),
        ink4:      Color(hex: "C7C7CC"),
        rule:      Color.black.opacity(0.10),
        rule2:     Color.black.opacity(0.18),
        accent:    Color(hex: "007AFF"),                  // iOS System Blue
        accentSoft:   Color(hex: "007AFF").opacity(0.12),
        accentSofter: Color(hex: "007AFF").opacity(0.07),
        good:      Color(hex: "34C759"),                  // iOS System Green
        warn:      Color(hex: "FF9500"),                  // iOS System Orange
        bad:       Color(hex: "FF3B30"),                  // iOS System Red
        pad: 20, gap: 16,
        isDark: false,
        accentHi:     Color(hex: "26BAFC"),
        accentDeep:   Color(hex: "0062CC"),
        accentStrong: Color(hex: "007AFF")
    )

    /// Apple App Store Dark Theme
    static let dark = ForgeTheme(
        bg:        Color(hex: "000000"),
        surface:   Color(hex: "1C1C1E"),
        surface2:  Color(hex: "2C2C2E"),
        surface3:  Color(hex: "141416"),
        ink:       Color(hex: "FFFFFF"),
        ink2:      Color(hex: "8E8E93"),
        ink3:      Color(hex: "636366"),
        ink4:      Color(hex: "48484A"),
        rule:      Color.white.opacity(0.14),
        rule2:     Color.white.opacity(0.24),
        accent:    Color(hex: "0A84FF"),                  // iOS Dark Mode System Blue
        accentSoft:   Color(hex: "0A84FF").opacity(0.18),
        accentSofter: Color(hex: "0A84FF").opacity(0.10),
        good:      Color(hex: "30D158"),                  // iOS Dark Mode Green
        warn:      Color(hex: "FF9F0A"),                  // iOS Dark Mode Orange
        bad:       Color(hex: "FF453A"),                  // iOS Dark Mode Red
        pad: 20, gap: 16,
        isDark: true,
        accentHi:     Color(hex: "40C8E0"),
        accentDeep:   Color(hex: "0051A8"),
        accentStrong: Color(hex: "0A84FF")
    )

    /// Tint for interactive controls, toggles, and active icons (App Store Blue).
    var controlTint: Color {
        isDark ? Color(hex: "0A84FF") : Color(hex: "007AFF")
    }

    var accentStrongSoft: Color {
        accentStrong.opacity(isDark ? 0.18 : 0.12)
    }

    /// Supporting glyph color — matches App Store blue tint for icons and actions.
    var accent2: Color {
        isDark ? Color(hex: "0A84FF") : Color(hex: "007AFF")
    }
}

// MARK: - Typography (App Store SF Pro Hierarchy)

extension ForgeTheme {
    /// Large titles & section headers — crisp SF Pro Display (matches App Store headers).
    func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Standard SF Pro body & UI typography.
    func sans(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Metadata, version numbers, and badges — converted from monospaced to clean SF Pro
    /// with tabular digits so numbers align cleanly like the official App Store.
    func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default).monospacedDigit()
    }
}

// MARK: - Environment wiring

private struct ForgeThemeKey: EnvironmentKey {
    static let defaultValue: ForgeTheme = .light
}

extension EnvironmentValues {
    var forgeTheme: ForgeTheme {
        get { self[ForgeThemeKey.self] }
        set { self[ForgeThemeKey.self] = newValue }
    }
}

extension View {
    func forgeTheme(_ theme: ForgeTheme) -> some View {
        self.environment(\.forgeTheme, theme)
    }

    func forgeScaledType() -> some View {
        self.dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}
