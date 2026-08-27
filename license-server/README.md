# Ocean Launcher License Server

This service creates reseller keys and validates activations for the iOS app. It does not store raw keys. Put it behind an HTTPS reverse proxy before using it outside local development.

## Run

PowerShell:

```powershell
$env:ADMIN_TOKEN = "use-a-long-random-secret-here"
npm start
```

Create one lifetime key from an administrator machine:

```powershell
$headers = @{ "x-admin-token" = $env:ADMIN_TOKEN }
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8787/admin/keys -Headers $headers
```

The response contains the raw key once. Give it to the reseller or customer and do not save it in GitHub.

The app calls `POST /v1/activate` with `key`, `deviceId`, and `appVersion`. The server returns `valid`, `licenseId`, `plan`, and `expiresAt`.

Set `OceanLicenseAPIURL` in `Natives/Info.plist` to the deployed HTTPS URL, for example `https://licenses.example.com/v1/activate`.
