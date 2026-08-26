# SAT App (Pure Swift 100% Native iOS App)

Lightweight (~5 MB), production-grade pure Swift iOS application for SAT App.

---

## Features
- **Native UIKit Login Screen**: Matches web UI with logo, "Login By" selector (HO User, Branch Incharge, Rahbar), and Email/Password fields.
- **Direct REST API Integration**: Calls `https://test.enin.io/api/login` with `access-token: piggyC@ins2019`.
- **Auto-Session Web Bridge**: Automatically logs into the web dashboard via `https://test.enin.io/app-supplier-agent?user_id={userId}`.
- **Native Offline Support**: Real-time `NWPathMonitor` detection with native "No Internet Connection" screen and retry button (fully App Store Guideline 4.2 compliant).
- **Pull to Refresh & Progress Bar**: Native `UIRefreshControl` and `UIProgressView`.
- **External URL Schemes**: Supports `tel:`, `mailto:`, `whatsapp:`, `upi:`.
- **App Store Compliant**: Camera/Photo descriptions and full safe-area support for iPhone 15 Dynamic Island.
