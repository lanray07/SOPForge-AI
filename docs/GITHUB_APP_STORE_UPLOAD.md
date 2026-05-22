# GitHub App Store Connect Upload

This repo includes a manual GitHub Actions workflow for archiving SOPForge AI and uploading the build to App Store Connect:

`.github/workflows/app-store-upload.yml`

## Required GitHub Secrets

Add these under GitHub repo > Settings > Secrets and variables > Actions > New repository secret.

### APPLE_TEAM_ID

Your Apple Developer Team ID.

Find it in Apple Developer > Membership details.

### ASC_KEY_ID or APP_STORE_CONNECT_API_KEY_ID

The App Store Connect API key ID.

### ASC_ISSUER_ID or APP_STORE_CONNECT_ISSUER_ID

The App Store Connect API issuer ID.

### ASC_PRIVATE_KEY_BASE64 or APP_STORE_CONNECT_API_PRIVATE_KEY

The `.p8` private key encoded as base64, or the raw `.p8` private key content.

PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\AuthKey_XXXXXXXXXX.p8"))
```

macOS:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

Paste the output into the GitHub secret value.

If you use the raw `.p8` content instead, paste it into `APP_STORE_CONNECT_API_PRIVATE_KEY`. Multiline private keys and keys containing escaped `\n` line breaks are both supported by the workflow.

## App Store Connect API Key

Create a Team API key in App Store Connect:

1. Open App Store Connect.
2. Go to Users and Access.
3. Open the Integrations tab.
4. Select App Store Connect API.
5. Generate a Team Key with an appropriate role, typically App Manager or Admin for upload workflows.
6. Download the `.p8` private key once and store it securely.

## Run the Upload

1. Open GitHub > Actions.
2. Select `Upload Build to App Store Connect`.
3. Click `Run workflow`.
4. Enter:
   - `marketing_version`: `1.0`
   - `build_number`: a new integer, for example `1`, `2`, `3`
5. Run the workflow.

The workflow archives the app using Xcode on GitHub's macOS runner and uploads it to App Store Connect.

## Important Notes

- The app record must already exist in App Store Connect with bundle ID `com.sopforge.ai`.
- The explicit App ID must already exist in Certificates, Identifiers & Profiles.
- The workflow uses automatic signing with `-allowProvisioningUpdates`.
- Do not commit API keys, certificates, provisioning profiles, passwords, or `.p8` files to the repo.
- If the upload succeeds, the build can take several minutes to appear in App Store Connect.
