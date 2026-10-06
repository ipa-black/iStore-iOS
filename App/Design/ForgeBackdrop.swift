import SwiftUI

/// Technical canvas grid: kept for backward compatibility or optional blueprint cards.
struct GridTexture: View {
    var spacing: CGFloat = 40
    var color: Color = .clear

    var body: some View {
        Canvas { ctx, size in
            guard color != .clear else { return }
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            ctx.stroke(path, with: .color(color), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

/// Primary App Store canvas shared across main tabs.
/// Uses pure systemBackground (White in Light Mode, Pure Black in Dark Mode)
/// to match the native Apple App Store appearance.
struct ForgeBackdrop: View {
    var useGroupedBackground: Bool = false
    var ambientTint: Color? = nil
    var showGrid: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            // الخلفية الأساسية المطابقة لمتجر آبل
            Color(uiColor: useGroupedBackground ? .systemGroupedBackground : .systemBackground)

            // إضاءة علوية اختيارية ناعمة جداً (تستخدم في صفحات تفاصيل التطبيقات إذا توفر tintColor)
            if let ambientTint {
                LinearGradient(
                    colors: [
                        ambientTint.opacity(colorScheme == .dark ? 0.18 : 0.10),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .init(x: 0.5, y: 0.38)
                )
            }

            // الشبكة معطلة افتراضياً للحفاظ على مظهر App Store النظيف
            if showGrid {
                GridTexture(
                    spacing: 40,
                    color: Color.primary.opacity(colorScheme == .dark ? 0.05 : 0.03)
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
