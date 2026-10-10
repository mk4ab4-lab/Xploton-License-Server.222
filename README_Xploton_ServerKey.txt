OLX STORE — Xploton online license server (minutes / hours / days)

Files
- tmhak_olx_Xploton_ServerKey.ahk: AutoHotkey v1.1 client with online key checking.
- Xploton_LicenseServer.js: safe license API; logs failed key/device attempts and rate-limits abusive requests.
- Create_Xploton_Key.ps1: creates a time-limited license on your server.
- olx_store_logo.png: optional UI logo.

Duration options supported by the server
- minutes: 1, 5, 10, 30
- hours: 1, 6, 12, 24
- days: 1, 7, 30, 90, 180, 365
The timer starts at the first successful activation. Each key is bound to the first device ID that activates it.

Server setup (Node.js 18+)
1. Upload Xploton_LicenseServer.js to your server and run it with Node.js.
2. Set XPLOT_ADMIN_TOKEN to a random secret of at least 24 characters. Do not put this admin token in the client or publish it.
   Linux example: export XPLOT_ADMIN_TOKEN="use-a-long-random-private-value"; node Xploton_LicenseServer.js
   Windows PowerShell example: $env:XPLOT_ADMIN_TOKEN="use-a-long-random-private-value"; node .\Xploton_LicenseServer.js
3. The app listens on 127.0.0.1:3000. Put it behind a reverse proxy (Caddy, nginx, or your hosting platform) with valid HTTPS, and forward requests to 127.0.0.1:3000.
4. Edit LicenseServerUrl near the top of tmhak_olx_Xploton_ServerKey.ahk to your real HTTPS URL, for example https://license.yourdomain.com. Do not leave YOUR-DOMAIN.example.
5. On Windows, install AutoHotkey v1.1. Keep olx_store_logo.png next to the .ahk file.
6. To create a key, run Create_Xploton_Key.ps1 on a trusted admin computer and provide your server URL and admin token (the prompt hides the token). The generated key is copied to clipboard.

API endpoints
- GET /health
- POST /activate with form fields key and device
- POST /validate with form fields key and device
- POST /admin/create-key with JSON {"unit":"minute","value":5} and header x-admin-token
- POST /admin/revoke-key with JSON {"key":"..."} and header x-admin-token

Safe protection included
- Keys are stored on the server as SHA-256 hashes; the raw license key is only shown when created.
- First activation binds the key to an install ID.
- Failed key/device attempts and revocations are recorded to xploton_server_data/security.log.
- Eight failed attempts from one source in ten minutes trigger a temporary 15-minute block.
- You can revoke a leaked key via /admin/revoke-key.

Important limitations
- This is a starter implementation, not a security audit. Use HTTPS, firewall the Node port, keep the admin token private, back up the xploton_server_data folder, and consider a real database for production.
- Server logging can detect suspicious requests to the license API; it cannot reliably know that somebody is reverse-engineering a copy of the EXE offline. Do not add code that damages another person's computer. This package only logs/blocks/revokes and closes the licensed app when it cannot verify the license.
- The client was not compiled or tested on Windows in this environment. Check it on a test machine before distributing it.
