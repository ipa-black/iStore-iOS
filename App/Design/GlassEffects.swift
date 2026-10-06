import SwiftUI
import UIKit

// MARK: - Centralized Apple App Store Surface System

enum GlassRole: Sendable {
    case hero
    case card
    case button
    case capsule
    case icon
    case badge
    case tabBar
    case toolbarButton
    case listRow
    case composer
    case composerField

    /// Standard Apple App Store continuous corner radii
    var cornerRadius: CGFloat {
        switch self {
        case .hero: return 16
        case .card, .listRow: return 14
        case .button: return 14
        case .composer: return 20
        case .composerField: return 12
        case .capsule, .badge: return 999
        case .icon, .toolbarButton: return 10
        case .tabBar: return 24
        }
    }

    var isInteractive: Bool {
        switch self {
        case .button, .capsule, .icon, .badge, .toolbarButton, .tabBar, .composer, .composerField: return true
        case .hero, .card, .listRow: return false
        }
    }

    var materialOpacity: Double {
        switch self {
        case .hero, .card, .listRow: return 1.0
        case .button: return 1.0
        case .composer: return 0.95
        case .composerField: return 1.0
        case .capsule, .icon, .badge, .toolbarButton, .tabBar: return 0.90
        }
    }
}

private struct GlassSurfaceModifier: ViewModifier {
    let role: GlassRole
    let cornerRadius: CGFloat?

    @Environment(\.colorScheme) private var colorScheme

    @ViewBuilder
    func body(content: Content) -> some View {
        let radius = cornerRadius ?? role.cornerRadius
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        switch role {
        case .hero:
            // بطاقات العرض الكبيرة في تبويب Today بمتجر آبل
            content
                .background(
                    shape.fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .clipShape(shape)
                .overlay {
                    shape.stroke(Color.primary.opacity(0.07), lineWidth: 0.5)
                        .allowsHitTesting(false)
                }
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.30 : 0.08),
                    radius: 14,
                    y: 6
                )

        case .card, .listRow:
            // بطاقات الأقسام وصفوف التطبيقات في App Store
            content
                .background(
                    shape.fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .clipShape(shape)
                .overlay {
                    shape.stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
                        .allowsHitTesting(false)
                }

        case .composerField:
            // شريط البحث وحقول الإدخال المطابقة لـ App Store Search Bar
            content
                .background(
                    shape.fill(Color(uiColor: .tertiarySystemFill))
                )
                .clipShape(shape)

        case .button, .capsule, .badge, .icon:
            // الأزرار الثانوية والشارات والكبسولات الرمادية الناعمة
            content
                .background(
                    shape.fill(Color(uiColor: .tertiarySystemFill))
                )
                .clipShape(shape)

        case .tabBar, .composer, .toolbarButton:
            // أشرطة الأدوات العائمة بتضبيب iOS الأصلي النظيف
            content
                .background(.regularMaterial, in: shape)
                .overlay {
                    shape.stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        .allowsHitTesting(false)
                }
        }
    }
}

extension View {
    /// Unified App Store surface primitive (replaces translucent glass with native App Store cards & fills).
    func glassSurface(
        _ role: GlassRole = .card,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(GlassSurfaceModifier(role: role, cornerRadius: cornerRadius))
    }
}

// MARK: - Shape-Based Surface Variants

extension View {
    /// Clean App Store secondary fill or subtle material in an arbitrary shape.
    func fClearGlass<S: InsettableShape>(
        in shape: S,
        interactive: Bool = false,
        showRim: Bool = true,
        useRegularInteractiveGlass: Bool = false
    ) -> some View {
        modifier(ShapeGlassSurfaceModifier(
            shape: shape,
            role: interactive ? (useRegularInteractiveGlass ? .button : .toolbarButton) : .capsule,
            showRim: showRim
        ))
    }

    /// App Store "GET" / action pill fill.
    func fPrimaryActionGlass<S: InsettableShape>(in shape: S) -> some View {
        modifier(PrimaryActionGlassModifier(shape: shape))
    }

    /// Native iOS frosted floating navigation button (e.g., Back / Close circle in App Store).
    func fNavigationGlass<S: InsettableShape>(in shape: S) -> some View {
        modifier(NavigationGlassModifier(shape: shape))
    }

    /// Card-style App Store surface.
    func fGlass(cornerRadius: CGFloat = 14) -> some View {
        glassSurface(.card, cornerRadius: cornerRadius)
    }

    /// Capsule variant of `fGlass`.
    func fGlassCapsule() -> some View {
        modifier(ShapeGlassSurfaceModifier(shape: Capsule(), role: .capsule, showRim: false))
    }
}

private struct PrimaryActionGlassModifier<S: InsettableShape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .tertiarySystemFill), in: shape)
    }
}

private struct NavigationGlassModifier<S: InsettableShape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: shape)
            .overlay {
                shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

private struct ShapeGlassSurfaceModifier<S: InsettableShape>: ViewModifier {
    let shape: S
    let role: GlassRole
    let showRim: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        switch role {
        case .toolbarButton, .tabBar:
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    if showRim {
                        shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                            .allowsHitTesting(false)
                    }
                }
        default:
            content
                .background(Color(uiColor: .tertiarySystemFill), in: shape)
                .overlay {
                    if showRim {
                        shape.strokeBorder(Color.primary.opacity(0.05), lineWidth: 0.5)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

// MARK: - Container Wrapper (Backward Compatible)

struct FGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        content()
    }
}

// MARK: - Working Shimmer Effect (Used for Skeleton Loading Placeholders)

extension View {
    func shimmer(
        isActive: Bool = true,
        duration: Double = 1.4,
        intensity: Double = 0.45
    ) -> some View {
        modifier(ShimmerModifier(isActive: isActive, duration: duration, intensity: intensity))
    }
}

private struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    let duration: Double
    let intensity: Double

    @State private var phase: CGFloat = -1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive, !reduceMotion {
                    GeometryReader { geo in
                        let width = geo.size.width
                        let bandWidth = width * 0.65
                        LinearGradient(
                            stops: [
                                .init(color: .clear,                    location: 0.0),
                                .init(color: .white.opacity(intensity), location: 0.5),
                                .init(color: .clear,                    location: 1.0),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: bandWidth)
                        .offset(x: phase * (width + bandWidth))
                        .blendMode(.softLight)
                    }
                    .allowsHitTesting(false)
                }
            }
            .mask(content)
            .onAppear {
                guard isActive, !reduceMotion else { return }
                withAnimation(
                    .linear(duration: duration).repeatForever(autoreverses: false)
                ) { phase = 1.0 }
            }
            .onChange(of: isActive) { nowActive in
                if nowActive, !reduceMotion {
                    phase = -1.0
                    withAnimation(
                        .linear(duration: duration).repeatForever(autoreverses: false)
                    ) { phase = 1.0 }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) { phase = -1.0 }
                }
            }
    }
}

// MARK: - App Store Sheet Presentation

extension View {
    /// Standard Apple App Store modal sheet presentation (solid grouped background + visible grabber).
    func liquidGlassSheet() -> some View {
        presentationBackground(Color(uiColor: .systemGroupedBackground))
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Borderless Card / Pill Fill (Replaces Milky Glass)

private struct MilkGlassSurfaceModifier<S: InsettableShape>: ViewModifier {
    let shape: S
    let interactive: Bool

    func body(content: Content) -> some View {
        let fillColor = interactive
            ? Color(uiColor: .tertiarySystemFill)
            : Color(uiColor: .secondarySystemGroupedBackground)

        content
            .background(fillColor, in: shape)
            .clipShape(shape)
    }
}

extension View {
    /// Clean borderless App Store fill (replaces milky glass).
    func fMilkGlass<S: InsettableShape>(in shape: S, interactive: Bool = false) -> some View {
        modifier(MilkGlassSurfaceModifier(shape: shape, interactive: interactive))
    }
}
