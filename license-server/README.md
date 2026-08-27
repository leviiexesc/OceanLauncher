# Ocean Launcher License Server

This service creates reseller keys and validates activations for the iOS app. It does not store raw keys. Put it behind an HTTPS reverse proxy before using it outside local development.

## Run

PowerShell:

```powershell
$env:ADMIN_TOKEN = "use-a-long-random-secret-here"
$env:HOST = "0.0.0.0"
npm start
```

For local Wi-Fi testing, the current example app endpoint is `http://192.168.100.8:8787/v1/activate`. Your iPhone and computer must be on the same Wi-Fi network, and Windows Firewall must allow inbound TCP port 8787. Replace the IP when your network changes. Use a public HTTPS deployment for release.

Create one lifetime key from an administrator machine:

```powershell
$headers = @{ "x-admin-token" = $env:ADMIN_TOKEN }
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8787/admin/keys -Headers $headers
```

The response contains the raw key once. Give it to the reseller or customer and do not save it in GitHub.

The app calls `POST /v1/activate` with `key`, `deviceId`, and `appVersion`. The server returns `valid`, `licenseId`, `plan`, and `expiresAt`.

Set `OceanLicenseAPIURL` in `Natives/Info.plist` to the deployed HTTPS URL, for example `https://licenses.example.com/v1/activate`.
