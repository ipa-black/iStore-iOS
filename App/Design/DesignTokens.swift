import SwiftUI

// MARK: - Shared Semantic Design Tokens (App Store Edition)

enum AppSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    /// الهامش الأفقي القياسي لشاشات App Store (20pt)
    static let screenHorizontal: CGFloat = 20
    static let xLarge: CGFloat = 24
    static let xxLarge: CGFloat = 32
}

enum AppRadius {
    static let pill: CGFloat = 999
    static let control: CGFloat = 12
    static let heroCard: CGFloat = 16
    static let card: CGFloat = 20
    static let panel: CGFloat = 24

    /// حساب انحناء أيقونة آبل الرسمي (Squircle ~22.5% من حجم الأيقونة)
    static func appIcon(for size: CGFloat) -> CGFloat {
        size * 0.225
    }
}

enum AppTypography {
    static let eyebrow: Font = .system(size: 11, weight: .bold)
    static let secondary: Font = .system(size: 13, weight: .regular)
    static let body: Font = .system(size: 16, weight: .medium)
    static let title: Font = .system(size: 20, weight: .bold)

    // خطوط خاصة بهوية App Store
    static let sectionHeader: Font = .system(size: 22, weight: .bold)
    static let heroTitle: Font = .system(size: 24, weight: .bold)
    static let pillButton: Font = .system(size: 15, weight: .bold)
    static let microCaption: Font = .system(size: 8.5, weight: .medium)
    static let statValue: Font = .system(size: 19, weight: .bold, design: .rounded)
}

enum AppStroke {
    static let hairline: CGFloat = 0.5
    static let regular: CGFloat = 1
}

enum AppShadow {
    static let panelColor = Color.black.opacity(0.14)
    static let panelRadius: CGFloat = 18
    static let panelY: CGFloat = 8

    static let cardColor = Color.black.opacity(0.10)
    static let cardRadius: CGFloat = 14
    static let cardY: CGFloat = 6
}

enum AppColors {
    static let storeBlue = Color(uiColor: .systemBlue)
    static let pillGray = Color(uiColor: .secondarySystemFill)
    static let cardSurface = Color(uiColor: .secondarySystemGroupedBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let separator = Color.primary.opacity(0.12)
}

enum AppAnimation {
    static let quick = Animation.easeOut(duration: 0.16)
    static let state = Animation.spring(response: 0.34, dampingFraction: 0.84)
}

// MARK: - App Panel Background (Backward Compatible)

struct AppPanelBackground: ViewModifier {
    var cornerRadius: CGFloat = AppRadius.panel

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                if reduceTransparency {
                    shape.fill(Color(uiColor: .secondarySystemBackground))
                } else {
                    shape.fill(.regularMaterial)
                }
            }
            .overlay {
                shape.stroke(
                    AppColors.separator,
                    lineWidth: AppStroke.hairline
                )
            }
            .shadow(color: AppShadow.panelColor, radius: AppShadow.panelRadius, y: AppShadow.panelY)
    }
}

// MARK: - App Store Specific Modifiers & Styles

/// يطبّق شكل أيقونة App Store الرسمي مع الإطار الحدي الرفيع (0.5pt)
struct AppStoreIconModifier: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        let radius = AppRadius.appIcon(for: size)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        content
            .frame(width: size, height: size)
            .clipShape(shape)
            .overlay {
                shape.stroke(AppColors.separator, lineWidth: AppStroke.hairline)
            }
    }
}

/// يطبّق ستايل بطاقات تبويب "اليوم" (Today Hero Cards) في App Store
struct AppStoreHeroCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppRadius.heroCard

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(AppColors.cardSurface)
            .clipShape(shape)
            .overlay {
                shape.stroke(AppColors.separator, lineWidth: AppStroke.hairline)
            }
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, y: AppShadow.cardY)
    }
}

/// تأثير الضغط لزر "احصل" الكبسولي وبطاقات العرض مثل App Store
struct AppStorePressButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(AppAnimation.quick, value: configuration.isPressed)
    }
}

/// ترويسة الأقسام القياسية في App Store (العنوان + زر عرض الكل الاختياري)
struct AppStoreSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(AppTypography.sectionHeader)
                    .foregroundStyle(.primary)

                Spacer()

                if let actionTitle, let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.storeBlue)
                    }
                    .buttonStyle(.plain)
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(AppTypography.secondary)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func appPanel(cornerRadius: CGFloat = AppRadius.panel) -> some View {
        modifier(AppPanelBackground(cornerRadius: cornerRadius))
    }

    func minimumInteractiveSize() -> some View {
        frame(minWidth: 44, minHeight: 44)
    }

    /// يحول أي صورة أو View إلى أيقونة مطابقة لمعايير App Store
    func appStoreIcon(size: CGFloat = 62) -> some View {
        modifier(AppStoreIconModifier(size: size))
    }

    /// يغلف الـ View داخل بطاقة App Store بارزة بظلال ناعمة
    func appStoreHeroCard(cornerRadius: CGFloat = AppRadius.heroCard) -> some View {
        modifier(AppStoreHeroCardModifier(cornerRadius: cornerRadius))
    }

    /// خط فاصل مطابق لقوائم App Store يبدأ من بعد أيقونة التطبيق
    func appStoreRowDivider(leadingInset: CGFloat = 74) -> some View {
        overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, leadingInset)
        }
    }
}
