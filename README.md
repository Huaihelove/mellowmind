# Mellow Mind

Mellow Mind is an English-only SwiftUI wellness app for emotional reflection, personality-based self-understanding, and everyday stress relief. It combines a local personality profile, tarot-inspired mood cards, healing wish rituals, a daily mood almanac, and a private healing space.

> **Positioning:** mood journal, personality-reflection, and stress-relief tool. The app does not provide fortune-telling, divination, fate judgment, future prediction, medical diagnosis, or treatment.

> All reflection screens display the required footer: "Disclaimer: All content is for personality reference and emotional comfort only. It is not a fortune-telling service and cannot predict the future."

## Current Status

The source and resources are present and pass the local structural validator. This repository is developed on Windows, where Xcode and the Swift toolchain are unavailable, so a local `xcodebuild` build cannot be run here. The GitHub Actions workflow archives and exports the IPA on a macOS runner once the required Apple signing secrets are configured.

The web prototype under `Demo/` is not part of the iOS target and is not submitted to the App Store.

## Requirements

- iOS 17 or later
- Xcode with an iOS 17+ SDK
- An Apple Developer team, distribution certificate, provisioning profile, and App Store Connect app record
- A unique Bundle ID
- Four products configured in App Store Connect

## Quick Start

1. Open `MellowMind.xcodeproj` in Xcode.
2. Set your development team and replace the Bundle ID `com.mellowmind.app` with your own unique identifier.
3. Update the Bundle ID, product identifiers, and Universal Links/contact values as needed in:
   - `Tools/generate_xcodeproj.mjs`
   - `MellowMind/Services/StoreProductIDs.swift`
   - `MellowMind/DesignSystem/AppTheme.swift`
   - `MellowMind/Configuration/Products.storekit`
4. Run the app on an iPhone or simulator with iOS 17+.
5. Verify motion, haptics, audio, notifications, StoreKit sandbox purchases, Restore Purchases, and data deletion on a physical device.

Local source validation:

```bash
node Tools/validate_sources.mjs
```

The validator checks Swift delimiter balance, StoreKit product IDs, PBX references, required interaction tokens, English-only text, and the Info.plist development region. It is not a Swift compiler and cannot replace `xcodebuild`.

## Project Structure

```text
MellowMind/
  App/                 App entry, shell, root routing, and navigation
  Components/          Shared controls, compliance footer, particles, 3D flip, gestures
  Configuration/       StoreKit configuration
  DesignSystem/        Colors, typography, spacing, app copy, compliance strings
  Models/              SwiftData models and content value types
  Resources/           Assets, icon, launch colors, and local audio
  Services/            Personality, tarot, wish, almanac, AI-companion, audio, skin,
                       encryption, motion, haptics, StoreKit, and data services
  ViewModels/          MVVM state and business orchestration
  Views/               Onboarding, home, profile, tarot, wish, space, collection,
                       settings, legal, and store screens
MellowMind.xcodeproj/
Tools/                 Xcode project and asset generators, source validator
docs/                  App Store metadata and release runbook
Demo/                  English web prototype and production screenshots
.github/workflows/     macOS archive/export workflow
```

## Core Modules

- **Multi-dimensional personality profile:** blood type, Western zodiac, Chinese zodiac, three-part personality reflection, daily strengths, and emotional self-care guidance. Stored locally with SwiftData and editable.
- **Gentle mood cards:** hold-to-charge, manual shuffle, free card selection, 3D flip, haptics, swipe-to-cleanse interaction, and a daily emotional keyword. Three fixed reflection sections only.
- **Healing wish slips:** palms-together hold, shake detection with an assistive fallback, manual upward draw, five positive themes, wish wall, encrypted sealed wishes, and daily check-in.
- **Daily Emotional Almanac:** relaxation index, overthinking-avoidance guidance, small decompression actions, Chinese-zodiac mindset reminder, personality-strength suggestion, blood-type care tip, and premium report framework.
- **Healing Space:** local Tree Hollow companion, personality-aware anxiety sorter, bundled relaxation audio, and saved-card collection.
- **Growth and skins:** daily check-ins and wish accumulation unlock free skins; StoreKit 2 unlocks premium card and wish-tube skins.
- **Privacy:** local-first SwiftData storage, AES-GCM sealed wishes with a Keychain key, in-app data deletion, no account, no ads, and no third-party analytics SDK.

## StoreKit 2 Products

- `com.mellowmind.iap.tarot.skinpack` — non-consumable tarot card-skin pack
- `com.mellowmind.iap.tube.skinpack` — non-consumable wish-tube skin pack
- `com.mellowmind.iap.unlimited.wishseals` — non-consumable unlimited sealed wishes
- `com.mellowmind.iap.dailyreport.monthly` — auto-renewing monthly premium report

The local configuration is `MellowMind/Configuration/Products.storekit`. Before release, create matching products in App Store Connect and complete pricing, subscription group, localized display names/descriptions, privacy URLs, and terms URLs.

Restore Purchases and Manage Subscription are available from the settings and store surfaces.

## Audio and Visual Assets

All four relaxation tracks are bundled locally:

- `cloud_rain.wav` — cloud rain
- `moon_breath.wav` — moonlight breath
- `quiet_stream.wav` — quiet stream
- `soft_hearth.wav` — late-night hearth

The audio player needs no microphone or media-library permission. The icon, launch background, accent color, star particles, card-flip animations, and wish-tube interactions are implemented in the project. No ad SDK is included.

## Apple Compliance Checklist

- Age rating: 4+ in App Store Connect.
- Primary category: Lifestyle. Secondary: Health & Fitness.
- No medical claims, diagnosis, or treatment claims.
- No fortune-telling, divination, fate judgment, or future prediction.
- The fixed disclaimer appears on every reflection surface.
- No splash ads, pop-up ads, or ad SDK.
- No public networked user-generated content in this version.
- Local-first data, in-app deletion, privacy policy, terms, and disclaimer pages.
- StoreKit 2 with Restore Purchases and subscription management.

## CI Release Path

The workflow at `.github/workflows/ios-build.yml`:

1. Runs on a macOS GitHub runner.
2. Installs the project and validates sources.
3. Fails if any Chinese text remains.
4. Imports the distribution certificate and provisioning profile into a temporary keychain.
5. Runs `xcodebuild archive`.
6. Generates `ExportOptions.plist` and exports an IPA.
7. Uploads the IPA as a build artifact.
8. Optionally uploads the IPA to TestFlight/App Store Connect using an App Store Connect API key.

Required repository secrets are documented in `docs/ReleaseRunbook.md`. Never commit certificates, provisioning profiles, passwords, or API private keys.

## Verification Limitations

Passing `node Tools/validate_sources.mjs` confirms source structure and repository policy, not a successful iOS build. Xcode compilation, signing, StoreKit sandbox behavior, motion/haptic behavior, and App Store review remain to be verified on macOS and a physical device.
