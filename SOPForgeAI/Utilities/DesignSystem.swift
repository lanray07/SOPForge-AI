import SwiftUI

enum SOPTheme {
    static let accent = Color(red: 0.18, green: 0.32, blue: 0.95)
    static let purple = Color(red: 0.52, green: 0.31, blue: 0.88)
    static let charcoal = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let success = Color(red: 0.05, green: 0.55, blue: 0.38)
    static let warning = Color(red: 0.92, green: 0.47, blue: 0.16)

    static var groupedBackground: Color { Color(.systemGroupedBackground) }
    static var cardBackground: Color { Color(.secondarySystemGroupedBackground) }
    static var subtleText: Color { Color(.secondaryLabel) }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(SOPTheme.accent.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(SOPTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(SOPTheme.accent.opacity(configuration.isPressed ? 0.16 : 0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension View {
    func premiumCard() -> some View {
        padding(16)
            .background(SOPTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension Date {
    var shortDocumentDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}
