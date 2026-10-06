import SwiftUI
import UIKit
import AVFoundation

// MARK: - Tactile Press Style (App Store Smooth Spring)

struct GlassTactileButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.80), value: configuration.isPressed)
    }
}

// MARK: - Text Primitives (Adapted from Mono/Technical to SF Rounded & SF Pro)

/// Clean metadata caption (replaces raw technical monospace with App Store rounded/clean type).
struct MonoText: View {
    let text: String
    var size: CGFloat = 11
    var weight: Font.Weight = .medium
    var color: Color? = nil
    var tracking: CGFloat = 0

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundColor(color ?? T.ink2)
            .tracking(tracking)
    }
}

/// Section header label styled after App Store category & group headers.
struct CaptionText: View {
    let text: String
    var color: Color? = nil

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(color ?? Color(uiColor: .secondaryLabel))
    }
}

// MARK: - Buttons

/// Primary action button — Apple App Store solid blue CTA button.
struct GlassPrimaryButton: View {
    let label: String
    var systemImage: String? = nil
    var action: () -> Void = {}
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(LocalizedStringKey(label))
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .systemBlue))
            )
            .opacity(disabled ? 0.45 : 1)
        }
        .buttonStyle(GlassTactileButtonStyle())
        .disabled(disabled)
    }
}

/// Secondary action button — Clean App Store grouped card row button.
struct GlassSecondaryButton: View {
    let label: String
    var systemImage: String? = nil
    var destructive: Bool = false
    var action: () -> Void = {}

    @Environment(\.forgeTheme) private var T

    var body: some View {
        let tintColor: Color = destructive ? Color(uiColor: .systemRed) : Color(uiColor: .systemBlue)

        Button(action: action) {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tintColor)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(tintColor.opacity(0.12))
                        )
                }
                Text(LocalizedStringKey(label))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(destructive ? Color(uiColor: .systemRed) : T.ink)
                Spacer(minLength: 0)
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: AppStroke.hairline)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(GlassTactileButtonStyle())
    }
}

// MARK: - Section & Rows (App Store Grouped Card Chrome)

struct GlassSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    @Environment(\.forgeTheme) private var T

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(T.ink)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 0) { content() }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.07), lineWidth: AppStroke.hairline)
                }
        }
        .padding(.horizontal, T.pad)
        .padding(.top, 20)
    }
}

/// Hairline inset divider matching native iOS & App Store lists.
struct GlassRowDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 16)
    }
}

/// Row inside a GlassSection.
struct GlassRow<Trailing: View>: View {
    let label: String
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.forgeTheme) private var T

    var body: some View {
        HStack(spacing: 12) {
            Text(LocalizedStringKey(label))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(T.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

/// File-picker row styled with an iOS settings icon badge.
struct GlassFileRow: View {
    let icon: String
    let label: String
    let file: URL?
    let action: () -> Void

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(uiColor: .systemBlue))
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(uiColor: .systemBlue).opacity(0.12))
                    )

                Text(LocalizedStringKey(label))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(T.ink)
                    .lineLimit(1)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Text(LocalizedStringKey(file?.lastPathComponent ?? "Choose…"))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(file == nil ? Color(uiColor: .secondaryLabel) : Color(uiColor: .systemBlue))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 150, alignment: .trailing)

                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(GlassTactileButtonStyle())
    }
}

/// Text-input row.
struct GlassInputRow: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    @Environment(\.forgeTheme) private var T

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(uiColor: .systemBlue))
                .frame(width: 24)

            Text(LocalizedStringKey(label))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(T.ink)

            Spacer(minLength: 8)

            Group {
                if isSecure {
                    SecureField(LocalizedStringKey(placeholder), text: $text)
                } else {
                    TextField(LocalizedStringKey(placeholder), text: $text)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(T.ink)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 180)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

/// Toggle row.
struct GlassToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    @Environment(\.forgeTheme) private var T

    var body: some View {
        HStack(spacing: 12) {
            Text(LocalizedStringKey(label))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(T.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            GlassToggle(isOn: $isOn)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

/// Native-proportioned iOS switch toggle.
struct GlassToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .tint(Color(uiColor: .systemGreen))
    }
}

// MARK: - Small Primitives

/// Status pill — Clean App Store rounded badge.
struct GlassStatusPill: View {
    let text: String
    let color: Color

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Text(LocalizedStringKey(text))
            .textCase(.uppercase)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
                Capsule().fill(color.opacity(T.isDark ? 0.18 : 0.12))
            }
    }
}

/// Soft rounded metadata tag (e.g. version or bundle ID).
struct GlassTag: View {
    let text: String
    var size: CGFloat = 11

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundColor(Color(uiColor: .secondaryLabel))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(uiColor: .tertiarySystemFill))
            )
    }
}

// MARK: - App Store "GET / OPEN" Control & Circular Download Ring

@MainActor
private final class InstallSoundPlayer {
    static let shared = InstallSoundPlayer()
    private var player: AVAudioPlayer?

    func play() {
        guard let url = Bundle.main.url(forResource: "InstallConfirm", withExtension: "wav") else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0.72
            player?.prepareToPlay()
            player?.play()
        } catch {
            // Sound is decorative; never interrupt or fail the install action.
        }
    }
}

enum ForgeInteractionFeedback {
    @MainActor
    static func playPressSound() {
        InstallSoundPlayer.shared.play()
    }

    @MainActor
    static func playLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.42)
    }
}

/// Authentic App Store circular download indicator with center stop square.
struct InstallLoadingAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    let color: Color

    init(color: Color = Color(uiColor: .systemBlue)) {
        self.color = color
    }

    var body: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(color.opacity(0.22), lineWidth: 2.5)

            // Spinning progress arc
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                .animation(
                    reduceMotion ? nil : .linear(duration: 0.9).repeatForever(autoreverses: false),
                    value: isSpinning
                )

            // Iconic App Store stop square in the center
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .frame(width: 28, height: 28)
        .frame(width: 74, height: 30)
        .onAppear { isSpinning = !reduceMotion }
        .onDisappear { isSpinning = false }
        .accessibilityLabel("Loading")
    }
}

/// Native Apple App Store "GET" / "احصل" pill button.
struct GlassGetButton: View {
    let isLoading: Bool
    let isInstalled: Bool
    let disabled: Bool
    var emphasizesText = false
    let action: () -> Void

    @Environment(\.forgeTheme) private var T
    @AppStorage("app.language") private var languageCode = AppLanguage.english.rawValue
    @State private var hapticPulse = 0

    var body: some View {
        let isArabic = languageCode == AppLanguage.arabic.rawValue
        let buttonTitle = isArabic
            ? (isInstalled ? "فتح" : "احصل")
            : (isInstalled ? "OPEN" : "GET")

        Button {
            guard !disabled else { return }
            hapticPulse &+= 1
            ForgeInteractionFeedback.playLightHaptic()
            if !isInstalled {
                playDownloadStartSound()
            }
            action()
        } label: {
            Group {
                if isLoading {
                    InstallLoadingAnimation(color: emphasizesText ? .white : Color(uiColor: .systemBlue))
                } else {
                    Text(buttonTitle)
                        .font(.system(size: isArabic ? 14 : 13.5, weight: .bold))
                        .foregroundColor(
                            emphasizesText
                                ? .white
                                : Color(uiColor: .systemBlue)
                        )
                        .frame(width: 74, height: 30)
                        .background {
                            if emphasizesText {
                                Capsule().fill(.white.opacity(0.24))
                            } else {
                                Capsule().fill(Color(uiColor: .tertiarySystemFill))
                            }
                        }
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(GlassTactileButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.45 : 1)
        .animation(.easeInOut(duration: 0.18), value: isLoading)
    }

    private func playDownloadStartSound() {
        ForgeInteractionFeedback.playPressSound()
    }
}

// MARK: - Navigation Back Control (App Store Circular Floating Button)

struct GlassBackButton: View {
    let action: () -> Void
    var symbolName = "chevron.backward"
    var mirrorsInRTL = true

    @Environment(\.forgeTheme) private var T

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .flipsForRightToLeftLayoutDirection(mirrorsInRTL)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle().stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .buttonStyle(GlassTactileButtonStyle())
        .accessibilityLabel("Back")
    }
}

struct DirectionalGlassBackButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            GlassBackButton(
                action: action,
                symbolName: "chevron.right",
                mirrorsInRTL: false
            )
            .zIndex(100)
        }
        .environment(\.layoutDirection, .leftToRight)
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func floatingGlassBackButton(action: @escaping () -> Void) -> some View {
        overlay {
            ZStack(alignment: .topTrailing) {
                Color.clear
                GlassBackButton(
                    action: action,
                    symbolName: "chevron.right",
                    mirrorsInRTL: false
                )
                .padding(.top, 10)
                .padding(.trailing, 14)
                .zIndex(1_000)
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}
