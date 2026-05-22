import Foundation
import UIKit

struct PDFExportPayload {
    var businessName: String
    var title: String
    var version: Int
    var dateCreated: Date
    var content: String
    var checklist: [String]
    var safetyNotes: String
}

enum PDFExporter {
    static func export(payload: PDFExportPayload) throws -> URL {
        let fileName = "\(sanitize(payload.title))-\(UUID().uuidString.prefix(8)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        try renderer.writePDF(to: url) { context in
            let margin: CGFloat = 44
            let contentWidth = pageBounds.width - (margin * 2)
            var y = margin

            func newPage() {
                context.beginPage()
                y = margin
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 10) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 4
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
                let height = ceil((text as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                ).height)

                if y + height + spacing > pageBounds.height - margin {
                    newPage()
                }

                (text as NSString).draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                y += height + spacing
            }

            func drawRule() {
                if y + 20 > pageBounds.height - margin {
                    newPage()
                }
                context.cgContext.setStrokeColor(UIColor.systemGray4.cgColor)
                context.cgContext.setLineWidth(1)
                context.cgContext.move(to: CGPoint(x: margin, y: y))
                context.cgContext.addLine(to: CGPoint(x: pageBounds.width - margin, y: y))
                context.cgContext.strokePath()
                y += 18
            }

            context.beginPage()
            drawText(AppConfiguration.appName, font: .systemFont(ofSize: 13, weight: .semibold), color: .systemBlue, spacing: 5)
            drawText(payload.title, font: .systemFont(ofSize: 28, weight: .bold), spacing: 8)
            drawText("Business: \(payload.businessName.isEmpty ? "Business name" : payload.businessName)", font: .systemFont(ofSize: 11, weight: .regular), color: .secondaryLabel, spacing: 4)
            drawText("Version \(payload.version) | Created \(payload.dateCreated.formatted(date: .abbreviated, time: .omitted))", font: .systemFont(ofSize: 11, weight: .regular), color: .secondaryLabel, spacing: 14)
            drawRule()

            drawText("Procedure", font: .systemFont(ofSize: 18, weight: .bold), spacing: 6)
            drawText(payload.content, font: .systemFont(ofSize: 11, weight: .regular), spacing: 14)

            if !payload.checklist.isEmpty {
                drawText("Checklist", font: .systemFont(ofSize: 18, weight: .bold), spacing: 6)
                let checklist = payload.checklist.enumerated().map { index, item in "\(index + 1). \(item)" }.joined(separator: "\n")
                drawText(checklist, font: .systemFont(ofSize: 11, weight: .regular), spacing: 14)
            }

            drawText("Safety Notes", font: .systemFont(ofSize: 18, weight: .bold), spacing: 6)
            drawText(payload.safetyNotes.isEmpty ? "Review this document for task-specific safety notes before use." : payload.safetyNotes, font: .systemFont(ofSize: 11, weight: .regular), spacing: 14)

            drawText("Signature Area", font: .systemFont(ofSize: 18, weight: .bold), spacing: 8)
            drawText("Supervisor: ________________________________\nSignature: __________________________________\nDate: ______________________________________", font: .systemFont(ofSize: 11, weight: .regular), spacing: 14)

            drawText("Disclaimer", font: .systemFont(ofSize: 18, weight: .bold), spacing: 6)
            drawText(AppConfiguration.disclaimerBullets.joined(separator: "\n"), font: .systemFont(ofSize: 10, weight: .regular), color: .secondaryLabel, spacing: 0)
        }

        return url
    }

    private static func sanitize(_ title: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return title
            .replacingOccurrences(of: " ", with: "-")
            .unicodeScalars
            .filter { allowed.contains($0) }
            .map(String.init)
            .joined()
            .prefix(60)
            .description
    }
}
