import SwiftUI

struct UpgradeBanner: View {
    var title = "Unlock Pro workflows"
    var message = "Unlimited documents, PDF exports, Voice-to-SOP, advanced templates, and training guides."
    var actionTitle = "View plans"
    var action: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(SOPTheme.purple, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(SOPTheme.subtleText)
                    .lineLimit(2)
            }

            Spacer(minLength: 6)

            Button(action: action) {
                Text(actionTitle)
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(SOPTheme.purple)
        }
        .premiumCard()
    }
}
