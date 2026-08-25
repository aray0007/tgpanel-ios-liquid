#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/TGPanelApp.xcodeproj"
SCHEME="${SCHEME:-TGPanelApp}"
CONFIGURATION="${CONFIGURATION:-Release}"
BUNDLE_ID="${BUNDLE_ID:-com.example.TGPanel}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/build}"
ARCHIVE_PATH="$OUTPUT_DIR/$SCHEME.xcarchive"
EXPORT_DIR="$OUTPUT_DIR/export"
KEYCHAIN_PATH="${KEYCHAIN_PATH:-$HOME/Library/Keychains/tgpanel-signing.keychain-db}"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-$(uuidgen)}"

: "${CERTIFICATE_PATH:?Set CERTIFICATE_PATH to a .p12/.pfx signing certificate}"
: "${CERTIFICATE_PASSWORD:?Set CERTIFICATE_PASSWORD without printing it}"
: "${PROVISIONING_PROFILE_PATH:?Set PROVISIONING_PROFILE_PATH to a .mobileprovision file}"

mkdir -p "$OUTPUT_DIR"
rm -rf "$ARCHIVE_PATH" "$EXPORT_DIR"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH" 2>/dev/null || true
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$CERTIFICATE_PATH" -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH" login.keychain-db
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROFILE_DIR"
PROFILE_PLIST="$OUTPUT_DIR/profile.plist"
security cms -D -i "$PROVISIONING_PROFILE_PATH" > "$PROFILE_PLIST"
PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$PROFILE_PLIST")"
PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$PROFILE_PLIST")"
TEAM_ID="${TEAM_ID:-$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$PROFILE_PLIST")}"
PROFILE_APP_ID="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$PROFILE_PLIST")"
PROFILE_BUNDLE_ID="${PROFILE_APP_ID#*.}"
case "$PROFILE_BUNDLE_ID" in
  *\*) : ;;
  "$BUNDLE_ID") : ;;
  *) printf 'Provisioning profile App ID %s does not match BUNDLE_ID %s\n' "$PROFILE_BUNDLE_ID" "$BUNDLE_ID" >&2; exit 2 ;;
esac
cp "$PROVISIONING_PROFILE_PATH" "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"

if [[ -z "${CODE_SIGN_IDENTITY:-}" ]]; then
  CODE_SIGN_IDENTITY="$(security find-identity -v -p codesigning "$KEYCHAIN_PATH" | awk -F '\"' 'NR==1 {print $2}')"
fi
if [[ -z "$CODE_SIGN_IDENTITY" ]]; then
  printf 'No code-signing identity found in imported certificate\n' >&2
  exit 2
fi

xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$OUTPUT_DIR/derived-data" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}" \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
  OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN_PATH" \
  | tee "$OUTPUT_DIR/archive.log"

cat > "$OUTPUT_DIR/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>${EXPORT_METHOD:-ad-hoc}</string>
<key>signingStyle</key><string>manual</string>
<key>teamID</key><string>$TEAM_ID</string>
<key>provisioningProfiles</key><dict><key>$BUNDLE_ID</key><string>$PROFILE_NAME</string></dict>
<key>stripSwiftSymbols</key><true/>
<key>compileBitcode</key><false/>
</dict></plist>
PLIST

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$OUTPUT_DIR/ExportOptions.plist" \
  | tee "$OUTPUT_DIR/export.log"

cp "$EXPORT_DIR/$SCHEME.ipa" "$OUTPUT_DIR/TGPanelApp.ipa"
printf 'IPA created at %s\n' "$OUTPUT_DIR/TGPanelApp.ipa"
