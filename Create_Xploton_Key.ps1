$ErrorActionPreference = 'Stop'
$server = Read-Host 'HTTPS license server base URL (e.g. https://license.example.com)'
$secureToken = Read-Host 'Admin token' -AsSecureString
$tokenPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
try { $token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPtr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPtr) }
Write-Host 'Duration units: minute, hour, day'
$unit = (Read-Host 'Unit').Trim().ToLowerInvariant()
$valueText = Read-Host 'Value (minute: 1/5/10/30; hour: 1/6/12/24; day: 1/7/30/90/180/365)'
$value = 0
if (-not [int]::TryParse($valueText, [ref]$value)) { throw 'Duration value must be an integer.' }
$body = @{ unit = $unit; value = $value } | ConvertTo-Json
$result = Invoke-RestMethod -Uri ($server.TrimEnd('/') + '/admin/create-key') -Method Post -Headers @{ 'x-admin-token' = $token } -ContentType 'application/json' -Body $body
Write-Host ''
Write-Host ('KEY: ' + $result.key) -ForegroundColor Green
Write-Host ('Duration: ' + $result.duration) -ForegroundColor Cyan
Write-Host 'The validity period starts at first activation.'
Set-Clipboard -Value $result.key
Write-Host 'Key copied to clipboard.'
