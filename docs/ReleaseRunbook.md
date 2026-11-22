# Mellow Mind — Release Runbook

## Current Status

The iOS source is English-only and the local structural validator passes. This development environment is Windows and has no Xcode, `xcodebuild`, `codesign`, or App Store Connect tooling. Therefore:

- No local Xcode build has been run.
- No IPA has been produced or signed locally.
- No physical-device acceptance test has been completed here.
- No App Store submission has been made.
- The GitHub Actions workflow is ready, but remains unvalidated until it runs on a macOS runner with real Apple signing secrets.

## Required Repository Secrets

Configure these in GitHub → Settings → Secrets and variables → Actions:

| Secret | Purpose |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `APP_BUNDLE_ID` | Final unique Bundle ID, for example `com.yourcompany.mellowmind` |
| `BUILD_CERTIFICATE_BASE64` | Base64 of the exported `.p12` Apple Distribution certificate |
| `P12_PASSWORD` | Password for the `.p12` |
| `PROVISIONING_PROFILE_BASE64` | Base64 of the App Store provisioning profile |
| `KEYCHAIN_PASSWORD` | Password for the temporary CI keychain |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect issuer ID |
| `ASC_PRIVATE_KEY_BASE64` | Base64 of the `.p8` App Store Connect API private key |

Never commit certificates, profiles, passwords, private keys, or keychain exports.

Optional variables:

- `APP_SCHEME` — defaults to `MellowMind`
- `APP_EXPORT_METHOD` — defaults to `app-store-connect`
- `UPLOAD_TO_TESTFLIGHT` — set to `true` to upload after export

## Preparing Signing Assets

On a trusted Mac with Xcode:

1. Create an Apple Distribution certificate in the Apple Developer portal or Xcode.
2. Export the certificate as a password-protected `.p12`.
3. Create an App Store provisioning profile for the final Bundle ID.
4. Base64-encode both files without line wrapping.
5. Store the encoded values and passwords only as GitHub Actions secrets.

Example macOS commands:

```bash
base64 -i distribution.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
base64 -i AuthKey_ABC123.p8 | pbcopy
```

## GitHub Actions Release Path

The workflow is `.github/workflows/ios-build.yml`.

It performs:

1. Checkout on a macOS runner.
2. Source validation with `node Tools/validate_sources.mjs`.
3. A repository-wide fail-fast check for Chinese text.
4. Temporary keychain creation and certificate/profile import.
5. `xcodebuild archive`.
6. `ExportOptions.plist` generation.
7. `xcodebuild -exportArchive`.
8. IPA artifact upload.
9. Optional App Store Connect upload using the API key.

The workflow does not echo secrets and removes its temporary keychain at the end.

Manual local equivalent, for a Mac:

```bash
node Tools/validate_sources.mjs

xcodebuild archive \
  -project MellowMind.xcodeproj \
  -scheme MellowMind \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/MellowMind.xcarchive \
  DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
  PRODUCT_BUNDLE_IDENTIFIER="$APP_BUNDLE_ID" \
  CODE_SIGN_STYLE=Manual \
  PRODUCT_BUNDLE_IDENTIFIER="$APP_BUNDLE_ID"

xcodebuild -exportArchive \
  -archivePath build/MellowMind.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist build/ExportOptions.plist
```

## App Store Connect Setup

1. Create the app record with the final Bundle ID and English (U.S.) primary language.
2. Set the primary category to Lifestyle and secondary category to Health & Fitness.
3. Complete the age-rating questionnaire; the intended rating is 4+.
4. Create the four StoreKit products using the exact IDs in `MellowMind/Services/StoreProductIDs.swift`.
5. Configure the subscription group, price, renewal period, localized display names, descriptions, and review screenshots.
6. Add the public Privacy Policy, Terms of Use, and Support URLs.
7. Replace the placeholder URLs in `docs/AppStoreMetadata.md` and `MellowMind/DesignSystem/AppTheme.swift`.
8. Complete App Privacy declarations for local storage and StoreKit purchases. Do not declare ad tracking or third-party analytics.
9. Upload build metadata from `docs/AppStoreMetadata.md`.
10. Attach review notes explaining local-first behavior, the absence of public UGC, the wellness positioning, StoreKit behavior, and the fixed disclaimer.

## StoreKit Configuration

Products:

- `com.mellowmind.iap.tarot.skinpack`
- `com.mellowmind.iap.tube.skinpack`
- `com.mellowmind.iap.unlimited.wishseals`
- `com.mellowmind.iap.dailyreport.monthly`

Verify in sandbox:

- Product loading
- Purchase success
- User cancellation
- Pending transaction
- Restore Purchases
- Subscription renewal/cancellation visibility
- Entitlement persistence after relaunch
- No paywall blocking of core features

## Physical-Device Acceptance Matrix

Test on at least one notched iPhone and one current simulator:

- First-launch onboarding, date mapping, card flip, and slide-to-unlock
- Profile edit and persistence after relaunch
- Hold-to-charge, shuffle, manual card choice, 3D flip, haptics, and swipe-to-cleanse
- Palms-together hold, real shake, assistive shake, manual wish-slip draw, and haptics
- Wish-wall post, anonymous toggle, like, comment, report, hide, and delete
- Sealed wish creation, AES-GCM encryption, countdown, unlock, reflection, and deletion
- Daily check-in, streak, skin unlock, and collection save/delete
- Tree Hollow local reply and crisis-language routing
- Anxiety Sorter with all categories and health disclaimer
- All four audio tracks, pause/resume, next track, volume, and interruption recovery
- Dark mode, light mode, Dynamic Type, VoiceOver labels, and Reduce Motion behavior
- Notification permission allowed/denied and sealed-wish reminder
- Motion permission text and behavior
- Clear all local data and clear wish/journal data
- StoreKit sandbox purchase, restore, and subscription management links

## Compliance Gates

Before submission:

- The final binary contains no Chinese UI text.
- `CFBundleDevelopmentRegion` is `en_US` and Chinese known regions are absent.
- Every reflection screen shows the fixed English disclaimer.
- No screen makes medical, diagnosis, treatment, wealth, relationship, fate, or future-outcome claims.
- No ad SDK or tracking SDK is linked.
- The privacy policy and terms are publicly reachable.
- Data deletion works and is disclosed.
- StoreKit products, Restore Purchases, and Manage Subscription are visible.
- The review note explains the app’s wellness positioning and local-first design.
- App Store screenshots and metadata are English-only.
- A signed IPA has passed TestFlight installation on at least one physical device.

## Go / No-Go

**Go** only when the macOS workflow completes with real signing credentials, the IPA installs through TestFlight, StoreKit sandbox tests pass, and physical-device acceptance is complete.

**No-Go** if signing fails, the IPA cannot be archived/exported, StoreKit products are missing, the app has Chinese text, the disclosure pages are unreachable, or any predictive/medical claim appears in the binary or metadata.
