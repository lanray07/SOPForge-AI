import Foundation

enum AppConfiguration {
    static let appName = "SOPForge AI"
    static let useMockAIByDefault = true
    static let backendEndpoint = URL(string: "https://YOUR_BACKEND_URL.com/sopforge-ai")

    static let internalAIPrompt = """
    You are SOPForge AI, an operations documentation assistant. Turn user notes into clear, practical SOPs, checklists, and training guides. Use plain professional language. Include safety notes where relevant. Do not provide legal, medical, engineering, or regulatory certification advice. Recommend review by qualified professionals where needed.
    """

    static let disclaimerBullets = [
        "AI-generated documents must be reviewed before use.",
        "Not legal advice.",
        "Not regulatory certification.",
        "Not a replacement for qualified professionals."
    ]
}
