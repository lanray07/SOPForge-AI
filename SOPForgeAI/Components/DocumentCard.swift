import SwiftUI

struct DocumentCard: View {
    var title: String
    var subtitle: String
    var category: String
    var systemImage: String
    var tint: Color = SOPTheme.accent
    var footer: String?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    Text(category)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tint.opacity(0.10), in: Capsule())
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SOPTheme.subtleText)
                    .lineLimit(2)

                if let footer {
                    Text(footer)
                        .font(.caption)
                        .foregroundStyle(SOPTheme.subtleText)
                }
            }
        }
        .premiumCard()
    }
}

#Preview {
    DocumentCard(
        title: "Opening Procedure SOP",
        subtitle: "Version 1 | Updated today",
        category: "SOP",
        systemImage: "doc.text.fill",
        footer: "Cleaning Company"
    )
    .padding()
}
