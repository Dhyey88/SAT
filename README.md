# 📱 SAT App — Native iOS Application

**SAT App** (Shree Anandpur Trust) is a high-performance, production-grade, 100% native Pure Swift iOS application built for trust accounting, branch billing, donation management, and supplier agent portals.

---

## 📌 App Specifications & Version Details

| Property | Details |
| :--- | :--- |
| **App Name** | **SAT App** (Shree Anandpur Trust) |
| **Bundle Identifier** | `com.dhyey.sat2` |
| **App Version** | `1.0.0` |
| **Build Number** | `1` |
| **Minimum iOS Version** | **iOS 14.0+** (Supports 98%+ of all active iOS devices) |
| **Recommended iOS Version** | **iOS 17.0+ / iOS 18.0+** |
| **Tested Devices** | iPhone 15, iPhone 15 Pro, iPhone 14, iPad (iOS 17/18) |
| **Primary Language** | **Pure Swift 5.9+** (100% Native UIKit & WebKit) |
| **External Dependencies** | **0 (Zero)** — Pure Apple frameworks (No bloated CocoaPods/SPM) |
| **Compiled App Size** | **~3.1 MB** (Ultra-lightweight & fast loading) |
| **Supported Orientations** | Portrait (`UIInterfaceOrientationPortrait`) |

---

## 🎨 Design & Exact Website Match Theme

The iOS application is styled with an exact 1-to-1 match to the web portal (`matrix-login.css`, `login.blade.php`, `payer.blade.php`), replacing dull black screens with a crisp, high-contrast, modern interface:

* **Screen Background:** Website Slate Charcoal (`#2E363F`)
* **Input Fields:** **Crisp Pure White (`#FFFFFF`)** with dark charcoal text (`#2E363F`) and subtle border (`#DAE0E9`)
* **User ID Badge:** Website Brand Green (`#28B779` — `.bg_lg`)
* **Password Badge:** Website Amber Gold (`#FFB848` — `.bg_ly`)
* **Login Button:** Solid Emerald Green (`#28B779` — `.btn-success`)
* **Tutorial Link:** Web Sky Blue (`#27A9E3` — `.bg_lb`)
* **Reset Password Link:** Web Terracotta Orange (`#DA542E` — `.bg_lo`)
* **Google Login Button:** Google Brand Red (`#EA4335`)
* **App Icon:** Official Trust Emblem (*श्री परमहंस अद्वैत मत - श्री आनन्दपुर धाम*) 1024x1024 24bpp RGB without alpha (Apple `actool` compliant).

---

## 🚀 Key Features & Architecture

### 1. 🔐 Native Authentication & Role Lock
* **HO User Static Configuration:** Streamlined UI with `login_by: "ho_user"` statically configured for instant HO User authentication.
* **Inline Password Toggle:** Integrated "Show / Hide" button directly inside the password field.
* **Smart Keyboard Handling:**
  * Background tap gesture to dismiss keyboard instantly.
  * Dynamic keyboard avoidance (`keyboardWillShow`/`keyboardWillHide`) ensuring the "Login ➔" button is always visible.
  * Native return key navigation (Next ➔ Go).

### 2. ⚡ Direct 1-Tap Google Account Chooser
* Native Google Account Chooser bottom sheet listing all saved/entered Gmail accounts (e.g. `monaligadhiya576@gmail.com`).
* Instant 1-tap login via `POST /api/social-login` without typing.
* Automatic local caching (`UserDefaults`) remembering previously used accounts.
* "➕ Use another account..." option for logging in with additional accounts.

### 3. 🔑 3-Step Password Recovery Modal (`ResetPasswordViewController`)
* **Step 1:** Email submission & instant OTP dispatch (`POST /api/forgot-password`).
* **Step 2:** 6-digit OTP verification (`POST /api/otp-verification`).
* **Step 3:** Secure new password entry and confirmation (`POST /api/resent-password`).

### 4. 📝 In-App New User Registration (`SignUpViewController`)
* Native registration form collecting First Name, Last Name, Mobile, Email, and Password via `POST /api/register`.
* Pre-fills the login field upon successful registration.

### 5. 🌐 Hybrid Web Bridge & Dashboard Session (`WebViewController`)
* Automatic authenticated session handoff: `https://test.enin.io/app-supplier-agent?user_id={userId}`.
* Cookie & session synchronization using `WKHTTPCookieStore` and `WKProcessPool`.
* Native pull-to-refresh (`UIRefreshControl`) and smooth progress indicator (`UIProgressView`).
* Universal URL Scheme Handler:
  * `tel:` ➔ Opens native Phone dialer
  * `mailto:` ➔ Opens Apple Mail
  * `whatsapp:` ➔ Opens WhatsApp Messenger
  * `upi:` ➔ Opens payment apps (Google Pay, PhonePe, Paytm, BHIM)

### 6. 📡 Real-Time Offline Resilience (`NWPathMonitor`)
* Continuous network path monitoring.
* Displays a native full-screen offline overlay with an animated retry mechanism whenever connectivity drops, preventing broken web error pages (Apple App Store Guideline 4.2 compliant).

---

## 🔌 REST API Integration Reference

| Action | HTTP Method | Endpoint | Key Parameters |
| :--- | :--- | :--- | :--- |
| **Standard Login** | `POST` | `/api/login` | `email`, `password`, `login_by: "ho_user"`, `device_type: "1"`, `mobile_device_id: "SAT_IOS_DEVICE"` |
| **Google Social Login** | `POST` | `/api/social-login` | `provider: "google"`, `provider_id`, `email`, `device_type: "1"` |
| **Forgot Password** | `POST` | `/api/forgot-password` | `email`, `device_type: "1"` |
| **OTP Verification** | `POST` | `/api/otp-verification` | `email`, `otp`, `device_type: "1"` |
| **Reset Password** | `POST` | `/api/resent-password` | `email`, `otp`, `password`, `confirm_password` |
| **New User Registration** | `POST` | `/api/register` | `first_name`, `last_name`, `email`, `mobile`, `password`, `confirm_password` |
| **Device Support & Help** | `POST` | `/api/get-device-help` | `device_type: "1"` |

*Note: All API requests include the required header `access-token: piggyC@ins2019` and `Content-Type: application/x-www-form-urlencoded`.*

---

## 🛠️ Project Structure

```text
ios-swift/
├── project.yml                     # XcodeGen project specification
├── .github/workflows/
│   └── build-ios.yml              # Cloud Mac GitHub Actions CI/CD pipeline
├── App/
│   ├── AppDelegate.swift           # Application lifecycle & configuration
│   ├── SceneDelegate.swift         # Window & Scene management
│   ├── LoginViewController.swift   # Main Login, Google Account Chooser & Auth
│   ├── ResetPasswordViewController.swift # 3-step OTP recovery flow
│   ├── SignUpViewController.swift  # New user registration modal
│   ├── WebViewController.swift     # WKWebView dashboard & bridge
│   ├── Info.plist                  # Camera/Photo permissions & Bundle config
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/     # 1024x1024 24bpp RGB Trust Emblem App Icon
└── README.md                       # This documentation file
```

---

## 📲 Sideloading & Installation (Windows / Sideloadly)

1. Connect your iPhone 15 to your PC via USB and unlock the screen.
2. Open **Sideloadly (v0.60+)**.
3. Drag the latest `.ipa` from your Desktop into Sideloadly:
   * `SATApp_v1.0.2_WebTheme.ipa`
4. Enter your Apple ID (`dhyeykhanpara18@gmail.com`).
5. **Important:** Under *Advanced Options*, ensure **"Automatic bundle ID"** is **UNCHECKED** (keeps `com.dhyey.sat2` to prevent error 9401).
6. Click **Start** to install.
7. On your iPhone, navigate to **Settings > General > VPN & Device Management**, tap your developer certificate, and tap **"Trust"**.

---

## ☁️ Cloud Mac CI/CD & Git Repositories

* **Company GitLab Repository (Primary Remote):**  
  [https://gitlab.latitudetechnolabs.com/DhyeyKhanpara/sat-ios-swift](https://gitlab.latitudetechnolabs.com/DhyeyKhanpara/sat-ios-swift)
* **Cloud Mac Build Repository (GitHub Actions):**  
  [https://github.com/Dhyey88/SAT](https://github.com/Dhyey88/SAT)

Pushing changes automatically triggers the Cloud Mac runner (`macos-latest`), compiles the project using `xcodegen` & `xcodebuild`, packages `SATApp.ipa`, and produces artifacts in under 50 seconds.
