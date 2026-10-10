XPLOTON LICENSE SERVER — RAILWAY

Files at repository root:
- server.js
- package.json
- .gitignore

Railway setup:
1. Deploy this folder's contents from a GitHub repository (files must be at repository root).
2. Railway > service > Variables: add XPLOT_ADMIN_TOKEN with a private random value of at least 32 characters. Never put it in GitHub or the AHK client, and never share it.
3. Railway > Settings > Networking > Generate Domain to create the HTTPS URL.
4. Railway > Settings/Volumes: create a persistent volume mounted at /app/xploton_server_data so licenses survive redeploys.
5. Check Deployments logs. A successful deploy should stay running. /health should return JSON when the domain is ready.

Important:
- The service intentionally exits if XPLOT_ADMIN_TOKEN is missing or shorter than 24 characters. This is required configuration, not a code defect.
- Set the real HTTPS domain in tmhak_olx_Xploton_ServerKey.ahk before building/using the client.
- Do not expose XPLOT_ADMIN_TOKEN. It is an administrative secret.
- Test the AHK client on Windows; it is not executed by Railway.
