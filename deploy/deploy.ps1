# نشر خادم الصندوق على خادم سحابي (Ubuntu) بخطوة واحدة.
#   .\deploy\deploy.ps1                       (يسألك عن العنوان)
#   .\deploy\deploy.ps1 -ServerIp 1.2.3.4 -User ubuntu -KeyPath C:\keys\oracle.key
# آمن للتكرار: إعادة التشغيل تحدّث الخادم وتُبقي المفاتيح والبيانات.
param(
  [string]$ServerIp,
  [string]$User = 'ubuntu',
  [string]$KeyPath,
  [string]$Domain
)
$ErrorActionPreference = 'Stop'
$deployDir = $PSScriptRoot
$root = Split-Path -Parent $deployDir

foreach ($tool in 'ssh', 'tar') {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    throw "الأداة '$tool' غير موجودة. فعّل 'OpenSSH Client' من ميزات ويندوز الاختيارية."
  }
}

if (-not $ServerIp) { $ServerIp = Read-Host 'عنوان IP العام للخادم' }
if (-not $ServerIp) { throw 'عنوان الخادم مطلوب' }
if (-not $PSBoundParameters.ContainsKey('User')) {
  $u = Read-Host "اسم مستخدم SSH [$User] (Oracle/Ubuntu = ubuntu)"
  if ($u) { $User = $u }
}
if (-not $KeyPath) {
  $KeyPath = Read-Host 'مسار ملف مفتاح SSH (Enter لتجاوزه إن كنت تستخدم كلمة مرور)'
}

# ssh يرفض مفتاحاً صلاحياته مفتوحة على ويندوز: ننسخه لمكان محمي
$sshArgs = @('-o', 'StrictHostKeyChecking=accept-new', '-o', 'ServerAliveInterval=30')
if ($KeyPath) {
  $KeyPath = $KeyPath.Trim('"')
  if (-not (Test-Path $KeyPath)) { throw "ملف المفتاح غير موجود: $KeyPath" }
  $sshDir = Join-Path $env:USERPROFILE '.ssh'
  New-Item -ItemType Directory -Force $sshDir | Out-Null
  $safeKey = Join-Path $sshDir 'socialfund_deploy_key'
  Copy-Item $KeyPath $safeKey -Force
  & icacls $safeKey /inheritance:r /grant:r "$($env:USERNAME):(R)" | Out-Null
  $sshArgs += @('-i', $safeKey)
}

# تجهيز حزمة الرفع: الخادم (بلا ملفات التطوير) + ملفات النشر
$stage = Join-Path $env:TEMP ("sf_stage_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force "$stage\server", "$stage\deploy" | Out-Null
& robocopy "$root\SocialFund-Dart-Server" "$stage\server" /E /XD .dart_tool build test .git /XF *.db *.db-shm *.db-wal *.secret /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "فشل تجهيز ملفات الخادم (robocopy $LASTEXITCODE)" }
Copy-Item "$deployDir\docker-compose.yml", "$deployDir\Caddyfile" "$stage\deploy" -Force
# install.sh بنهايات أسطر Unix وبلا BOM وإلا يفشل على لينكس
$sh = (Get-Content "$deployDir\install.sh" -Raw -Encoding UTF8) -replace "`r`n", "`n"
[IO.File]::WriteAllBytes("$stage\deploy\install.sh", (New-Object Text.UTF8Encoding($false)).GetBytes($sh))

# أمر الخادم: فك الحزمة ثم تشغيل التثبيت (بـ sudo إن لم يكن root)
$remote = "rm -rf ~/sf_upload && mkdir -p ~/sf_upload && tar xzf - -C ~/sf_upload && " +
          "if [ `$(id -u) -eq 0 ]; then bash ~/sf_upload/deploy/install.sh '$Domain'; else sudo bash ~/sf_upload/deploy/install.sh '$Domain'; fi"
$batch = Join-Path $env:TEMP 'sf_deploy.cmd'
$line = "tar -czf - -C `"$stage`" . | ssh $($sshArgs -join ' ') $User@$ServerIp `"$remote`" 2>&1"
Set-Content -Path $batch -Value "@echo off`r`n$line" -Encoding ASCII

Write-Host ">> الاتصال بـ $User@$ServerIp ورفع الخادم وتثبيته (قد يطلب كلمة مرور SSH إن لم تستخدم مفتاحاً)..." -ForegroundColor Cyan
$log = Join-Path $deployDir 'last-deploy.log'
& cmd.exe /c $batch | Tee-Object -FilePath $log
$exit = $LASTEXITCODE
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $batch -Force -ErrorAction SilentlyContinue

$text = Get-Content $log -Raw
$m = [regex]::Match($text, '===SOCIALFUND-INFO===(.*?)===END===', 'Singleline')
if (-not $m.Success) {
  Write-Host "`nلم يكتمل التثبيت (رمز الخروج $exit). راجع السجل أعلاه أو الملف: $log" -ForegroundColor Red
  exit 1
}
$info = @{}
foreach ($l in ($m.Groups[1].Value -split "`r?`n")) {
  if ($l -match '^(\w+)=(.*)$') { $info[$Matches[1]] = $Matches[2].Trim() }
}
if ($info['HEALTH'] -ne 'ok') {
  Write-Host "`nالخادم ثُبّت لكنه لا يستجب عبر HTTPS بعد. غالباً لم تُفتح المنافذ 80/443 في لوحة السحابة (انظر deploy\README-AR.md)." -ForegroundColor Yellow
  Write-Host "بعد فتحها أعد تشغيل هذا الملف نفسه." -ForegroundColor Yellow
  exit 2
}

# حفظ المعلومات محلياً (ملف مُتجاهَل في git)
Set-Content -Path (Join-Path $deployDir 'server-url.txt') -Value $info['URL'] -Encoding ASCII
$secretText = @"
عنوان الخادم : $($info['URL'])
المدير       : $($info['ADMIN_USER'])
كلمة المرور  : $($info['ADMIN_PASSWORD'])   (غيّرها بعد أول دخول)
ENCRYPTION_KEY : $($info['ENCRYPTION_KEY'])
JWT_SECRET     : $($info['JWT_SECRET'])

!! احتفظ بنسخة من هذا الملف في مكان آمن خارج هذا الجهاز.
!! ضياع ENCRYPTION_KEY = ضياع الهوية والهاتف المشفّرة نهائياً.
"@
[IO.File]::WriteAllText((Join-Path $deployDir 'server-info.txt'), $secretText, (New-Object Text.UTF8Encoding($true)))

Write-Host "`n==================== تم بنجاح ====================" -ForegroundColor Green
Write-Host "عنوان الخادم : $($info['URL'])"
Write-Host "المدير       : $($info['ADMIN_USER'])"
Write-Host "كلمة المرور  : $($info['ADMIN_PASSWORD'])"
Write-Host "حُفظت المعلومات في: $deployDir\server-info.txt  (احتفظ بنسخة منها خارج هذا الجهاز)"
Write-Host "الخطوة التالية: .\deploy\build-apk.ps1" -ForegroundColor Cyan
