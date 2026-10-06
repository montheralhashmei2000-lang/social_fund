# تشغيل خادم الصندوق (Dart) محلياً على هذا الحاسوب — لشبكة المكتب أو للتطوير.
#   .\deploy\run-local.ps1                      # كلمة مرور المدير تُولَّد وتُحفظ في local-data\admin-password.txt
#   .\deploy\run-local.ps1 -AdminPassword "..." # أو حدّدها بنفسك (8 أحرف فأكثر)
#   .\deploy\run-local.ps1 -Port 8000
# البيانات في local-data\ (قاعدة SQLite + المفاتيح): انسخه كاملاً عند الانتقال إلى الخادم السحابي.
param(
  [string]$AdminPassword = "",
  [int]$Port = 8000
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$server = Join-Path $root "SocialFund-Dart-Server"
$data = Join-Path $root "local-data"
New-Item -ItemType Directory -Force $data | Out-Null

$pwFile = Join-Path $data "admin-password.txt"
if (-not $AdminPassword) {
  if (Test-Path $pwFile) { $AdminPassword = (Get-Content $pwFile -Raw).Trim() }
  else {
    $AdminPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 14 | ForEach-Object { [char]$_ })
    Set-Content -Path $pwFile -Value $AdminPassword -Encoding ascii
  }
}
if ($AdminPassword.Length -lt 8) { throw "كلمة مرور المدير يجب أن تكون 8 أحرف على الأقل" }

$env:DATA_DIR = $data
$env:ADMIN_PASSWORD = $AdminPassword
$env:PORT = "$Port"
$env:ASSETS_DIR = Join-Path $server "assets"

Write-Host ""
Write-Host "اسم المستخدم: admin"
Write-Host "كلمة المرور : $AdminPassword   (محفوظة في $pwFile — يُنصح بتغييرها من التطبيق)"
Write-Host "العناوين لإضافتها في التطبيق (شاشة «الخوادم»):"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match '^(192\.168|10\.|172\.(1[6-9]|2\d|3[01]))\.' } |
  ForEach-Object { Write-Host ("  http://{0}:{1}" -f $_.IPAddress, $Port) }
Write-Host ""
Write-Host "إن لم يتصل الهاتف: اسمح للمنفذ $Port في جدار حماية ويندوز (PowerShell كمسؤول):"
Write-Host "  New-NetFirewallRule -DisplayName 'SocialFund' -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Private"
Write-Host ""

Push-Location $server
try { dart run bin/server.dart } finally { Pop-Location }
