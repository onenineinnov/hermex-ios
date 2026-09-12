import SwiftUI

/// Shared geometry for Sessions and the text-only Bot composer.
enum ChatComposerMetrics {
    static let cardCornerRadius: CGFloat = 26
    static let actionSize: CGFloat = 44
    static let pillInset: CGFloat = 5
}

struct ChatComposerSurfaceStyle: ViewModifier {
    let isExpanded: Bool

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: isExpanded ? ChatComposerMetrics.cardCornerRadius
                : (ChatComposerMetrics.actionSize + ChatComposerMetrics.pillInset * 2) / 2,
            style: .continuous
        )
    }

    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground), in: shape)
            .overlay(shape.strokeBorder(Color(.separator).opacity(0.55), lineWidth: 1))
            .clipShape(shape)
    }
}

struct ChatComposerActionAppearance {
    let isStop: Bool
    let isDisabled: Bool
    let colorScheme: ColorScheme
    let tintsPrimaryActions: Bool
    let themeHex: String

    private var usesTheme: Bool {
        PrimaryActionTintSettings.usesThemeColor(
            isEnabled: tintsPrimaryActions, controlIsEnabled: !isDisabled
        )
    }

    var background: Color {
        if isStop { return Color.red.opacity(colorScheme == .dark ? 0.22 : 0.14) }
        if usesTheme { return HeaderLogoColor.color(for: themeHex) }
        if isDisabled { return colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.12) }
        return MessagesAppearance.outgoing
    }

    var foreground: Color {
        if isStop { return .red }
        if usesTheme { return HeaderLogoColor.prefersDarkForeground(for: themeHex) ? .black : .white }
        if isDisabled { return Color(.secondaryLabel) }
        return .white
    }
}

/// Conversation colors stay independent of the user's optional action tint.
enum MessagesAppearance {
    static let outgoing = Color(uiColor: UIColor { traits in
        // Deeper blue preserves white text contrast in both appearances.
        if traits.accessibilityContrast == .high {
            return UIColor(red: 0, green: 0.25, blue: 0.65, alpha: 1)
        }
        return UIColor(red: 0, green: 0.36, blue: 0.83, alpha: 1)
    })
    static let incoming = Color(.secondarySystemBackground)
}

struct ConversationAvatar: View {
    let name: String
    var size: CGFloat = 52

    var body: some View {
        Text(Self.initials(for: name))
            .font(.system(size: size * 0.36, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color(.systemGray), in: Circle())
            .accessibilityHidden(true)
    }

    static func initials(for name: String) -> String {
        let words = name.split(whereSeparator: { $0.isWhitespace || $0 == "-" || $0 == "_" })
        let initials = words.prefix(2).compactMap(\.first).map(String.init).joined()
        return initials.isEmpty ? "H" : initials.localizedUppercase
    }
}
