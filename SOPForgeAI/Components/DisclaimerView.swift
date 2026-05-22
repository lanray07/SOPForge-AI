import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Review required", systemImage: "exclamationmark.shield")
                .font(.headline)

            ForEach(AppConfiguration.disclaimerBullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(SOPTheme.warning)
                    Text(bullet)
                        .font(.footnote)
                        .foregroundStyle(SOPTheme.subtleText)
                }
            }
        }
        .premiumCard()
    }
}
