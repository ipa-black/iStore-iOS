import SwiftUI

/// Homepage / Library header mark — Styled after the official Apple App Store icon
/// (Apple blue gradient squircle + crisp white emblem + subtle specular rim).
struct ForgeGlassLogoView: View {
    var size: CGFloat = 60
    var symbolName: String = "bag.fill"

    var body: some View {
        let cornerRadius = size * 0.225
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            // التدرج الأزرق الرسمي لأيقونة Apple App Store
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.73, blue: 0.99),
                    Color(red: 0.04, green: 0.44, blue: 0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // إضاءة علوية ناعمة تعطي عمق أيقونات iOS الأصلية
            LinearGradient(
                colors: [
                    Color.white.opacity(0.22),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )

            // رمز المتجر باللون الأبيض النقي
            Image(systemName: symbolName)
                .font(.system(size: size * 0.44, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.12), radius: 3, y: 1.5)
        }
        .frame(width: size, height: size)
        .clipShape(shape)
        .overlay {
            shape.stroke(Color.white.opacity(0.24), lineWidth: AppStroke.hairline)
        }
        .shadow(
            color: Color(red: 0.04, green: 0.44, blue: 0.92).opacity(0.25),
            radius: size * 0.16,
            y: size * 0.08
        )
        .accessibilityLabel("iStore")
    }
}
