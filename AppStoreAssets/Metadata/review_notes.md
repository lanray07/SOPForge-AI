# App Review Notes

## Demo Guidance

SOPForge AI runs with mock AI enabled by default. No backend credentials are required to test the core generation flows.

Suggested review path:

1. Complete onboarding with any business name and business type.
2. Open Dashboard.
3. Tap Generate SOP.
4. Enter a task name, role, tools, safety notes, quality standards, and process notes.
5. Tap Generate SOP.
6. Edit the generated document.
7. Save to Document Library.
8. Open Saved Documents and verify the saved SOP can be edited, duplicated, and exported as PDF.
9. Open Checklist Builder and Training Guide to verify the other mock generation workflows.
10. Open Voice-to-SOP to verify microphone and speech recognition permission flow.

## Account Requirements

No login account is required.

## AI Notes

The app includes `MockAIService` for review and offline-friendly demo use. `RemoteAIService` includes the placeholder backend endpoint:

https://YOUR_BACKEND_URL.com/sopforge-ai

## Subscription Notes

The paywall uses StoreKit 2 scaffolding and the included StoreKit configuration file during development. The free plan is usable without purchase. If paid App Store products are not available in the review environment, paid plan buttons are disabled and the app continues on the free plan without showing an error. Product IDs:

- com.sopforgeai.pro.monthly
- com.sopforgeai.pro.yearly
- com.sopforgeai.business.monthly

## Disclaimer

AI-generated documents must be reviewed before use. The app does not provide legal advice, regulatory certification, engineering certification, medical advice, or a replacement for qualified professionals.
