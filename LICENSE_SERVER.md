# Ocean Launcher license server

The app reads `OceanLicenseAPIURL` from `Natives/Info.plist` and sends an HTTPS `POST` request. Replace the example URL with your reseller endpoint before releasing the app.

Request body:

```json
{
  "key": "RESELLER-KEY",
  "deviceId": "identifier-for-vendor",
  "appVersion": "1.0"
}
```

A successful response must be HTTP 2xx and contain:

```json
{
  "valid": true,
  "licenseId": "server-generated-id",
  "plan": "Lifetime",
  "expiresAt": null
}
```

For a time-limited license, return `expiresAt` as a display string such as `2027-08-27`. For a lifetime license, omit `expiresAt` or return `null` and use `plan: "Lifetime"`.

Do not put reseller keys, signing secrets, or a universal lifetime key in the iOS app. Generate and revoke keys on the server, rate-limit activation attempts, bind activations to a device policy, and keep the server endpoint on HTTPS.
