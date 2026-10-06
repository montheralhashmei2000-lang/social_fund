# بناء APK موقَّع متصل بخادمك — بخطوة واحدة.
#   .\deploy\build-apk.ps1                     (يقرأ العنوان من deploy\server-url.txt)
#   .\deploy\build-apk.ps1 -ApiUrl https://my.server
param([string]$ApiUrl)
$ErrorActionPreference = 'Stop'
$deployDir = $PSScriptRoot
$root = Split-Path -Parent $deployDir
$app = Join-Path $root 'mobile_app'
$android = Join-Path $app 'android'
$secrets = Join-Path $deployDir 'secrets'

if (-not $ApiUrl) {
  $f = Join-Path $deployDir 'server-url.txt'
  if (Test-Path $f) { $ApiUrl = (Get-Content $f -Raw).Trim() }
}
if (-not $ApiUrl) { throw 'لا يوجد عنوان خادم. شغّل deploy.ps1 أولاً أو مرّر -ApiUrl https://...' }
if ($ApiUrl -notmatch '^https://') { throw "العنوان يجب أن يبدأ بـ https:// (أندرويد يمنع HTTP في نسخة الإصدار): $ApiUrl" }

# ---- مفتاح التوقيع: يُنشأ مرة واحدة في عمر التطبيق ----
$props = Join-Path $android 'key.properties'
$jks = Join-Path $android 'upload-keystore.jks'
New-Item -ItemType Directory -Force $secrets | Out-Null
if (-not (Test-Path $props)) {
  if ((Test-Path "$secrets\upload-keystore.jks") -and (Test-Path "$secrets\key.properties")) {
    Write-Host '>> استعادة مفتاح التوقيع من النسخة الاحتياطية' -ForegroundColor Cyan
    Copy-Item "$secrets\upload-keystore.jks" $jks -Force
    Copy-Item "$secrets\key.properties" $props -Force
  } else {
    $keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
    if (-not $keytool -and $env:JAVA_HOME) { $keytool = Join-Path $env:JAVA_HOME 'bin\keytool.exe' }
    if (-not $keytool -or -not (Test-Path $keytool)) { throw 'لم أجد keytool. ثبّت JDK 17 أو Android Studio.' }
    function New-Pass { -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object { [char]$_ }) }
    $pass = New-Pass
    Write-Host '>> إنشاء مفتاح التوقيع (مرة واحدة)' -ForegroundColor Cyan
    & $keytool -genkeypair -v -keystore $jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
      -alias upload -storepass $pass -keypass $pass `
      -dname 'CN=Social Fund, O=Social Fund, C=YE' | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $jks)) { throw 'فشل إنشاء مفتاح التوقيع' }
    $jksPath = ($jks -replace '\\', '/')
    Set-Content -Path $props -Encoding ASCII -Value @"
storePassword=$pass
keyPassword=$pass
keyAlias=upload
storeFile=$jksPath
"@
    Copy-Item $jks "$secrets\upload-keystore.jks" -Force
    Copy-Item $props "$secrets\key.properties" -Force
    Write-Host "!! نسخة المفتاح وكلمته في: $secrets" -ForegroundColor Yellow
    Write-Host '!! انسخ هذا المجلد إلى مكان آمن خارج الجهاز: ضياعه يمنعك من تحديث التطبيق مستقبلاً.' -ForegroundColor Yellow
  }
}

# ---- البناء ----
Push-Location $app
try {
  Write-Host '>> flutter pub get' -ForegroundColor Cyan
  & flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'فشل flutter pub get' }
  Write-Host ">> بناء APK متصل بـ $ApiUrl (الأول يستغرق وقتاً)" -ForegroundColor Cyan
  & flutter build apk --release "--dart-define=API_BASE_URL=$ApiUrl" '--dart-define=APP_ENV=production'
  if ($LASTEXITCODE -ne 0) { throw 'فشل بناء APK. راجع الأخطاء أعلاه.' }
} finally { Pop-Location }

$built = Join-Path $app 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $built)) { throw "لم يُنتَج الملف المتوقع: $built" }
$out = Join-Path $deployDir 'SocialFund.apk'
Copy-Item $built $out -Force
$mb = [math]::Round((Get-Item $out).Length / 1MB, 1)
Write-Host "`n==================== تم بنجاح ====================" -ForegroundColor Green
Write-Host "الملف: $out  ($mb MB)"
Write-Host 'انقله إلى الهاتف وثبّته (فعّل «التثبيت من مصادر غير معروفة»).'
