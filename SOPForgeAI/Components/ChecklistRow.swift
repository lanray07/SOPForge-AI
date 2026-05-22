import SwiftUI

struct ChecklistRow: View {
    @Binding var text: String
    var index: Int
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(SOPTheme.accent, in: Circle())

            TextField("Checklist item", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...3)

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Delete checklist item")
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
