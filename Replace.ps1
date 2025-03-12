# 双语 PowerShell 脚本：备份并替换系统文件
# 请以管理员权限运行

# 获取当前脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 定义基本系统路径变量
$SystemDrive = $env:SystemDrive
$SystemRoot = $env:SystemRoot
$System32Path = Join-Path $SystemRoot "System32"
$SysWOW64Path = Join-Path $SystemRoot "SysWOW64"
$SysResourcesPath = Join-Path $SystemRoot "SystemResources"

# 获取系统安装的 UI 语言（作为默认参考）
$InstalledLang = [System.Globalization.CultureInfo]::InstalledUICulture.Name
# 初始化 DetectedLanguage 变量，后续会根据实际情况赋值
$DetectedLanguage = $null

# 定义输出函数（根据语言提示中文或英文）
function Write-Message {
  param (
    [string]$MessageZh,
    [string]$MessageEn,
    [string]$Color = "Yellow"
  )
  # 如果尚未确定 DetectedLanguage，则根据 InstalledLang 判断
  if (($DetectedLanguage -eq "zh-CN") -or (($DetectedLanguage -eq $null) -and ($InstalledLang -eq "zh-CN"))) {
    Write-Host $MessageZh -ForegroundColor $Color
  }
  else {
    Write-Host $MessageEn -ForegroundColor $Color
  }
}

# 创建备份文件夹和时间戳
$BackupDir = Join-Path $ScriptDir "bak"
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BackupPath = Join-Path $BackupDir $TimeStamp
if (-not (Test-Path $BackupDir)) {
  New-Item -ItemType Directory -Path $BackupDir | Out-Null
}
New-Item -ItemType Directory -Path $BackupPath | Out-Null

# -------------------- 系统语言检测 --------------------
# 优先使用 .NET 获取系统安装的 UI 语言
$Sys32LangPathCandidate = Join-Path $System32Path $InstalledLang
if (Test-Path (Join-Path $Sys32LangPathCandidate "mstsc.exe.mui")) {
  $DetectedLanguage = $InstalledLang
}
else {
  # 使用双语输出提示
  $msgZh = "使用 .NET 获取的系统语言 ($InstalledLang) 在 $System32Path 下未找到 mstsc.exe.mui 文件，尝试采用备选列表查找…"
  $msgEn = "The system language detected via .NET ($InstalledLang) did not yield mstsc.exe.mui in $System32Path; trying backup language list search..."
  Write-Message -MessageZh $msgZh -MessageEn $msgEn -Color "Yellow"

  # 采用备选列表查找已有的语言目录（例如 zh-CN, en-US 等）
  $PossibleLanguageDirs = @("zh-CN", "en-US", "es-ES", "hi-IN", "ar-SA", "pt-BR", "fr-FR", "ru-RU", "ja-jp", "de-DE")
  foreach ($Lang in $PossibleLanguageDirs) {
    $CurrentLangPath = Join-Path $System32Path $Lang
    if (Test-Path (Join-Path $CurrentLangPath "mstsc.exe.mui")) {
      $DetectedLanguage = $Lang
      break
    }
  }
  if (-not $DetectedLanguage) {
    $msgZh = "未能找到 mstsc.exe.mui 文件，请检查系统是否支持远程桌面或相关文件是否存在。"
    $msgEn = "Could not locate mstsc.exe.mui. Please check if the system supports Remote Desktop or if the corresponding files exist."
    Write-Message -MessageZh $msgZh -MessageEn $msgEn -Color "Red"
    Pause
    Exit
  }
}

# 定义语言相关路径
$Sys32LanguagePath = Join-Path $System32Path $DetectedLanguage
$WbemPath = Join-Path $SysWOW64Path "wbem"
$WbemLanguagePath = Join-Path $WbemPath $DetectedLanguage

# 输出检测到的语言目录信息
Write-Message -MessageZh "检测到语言目录：$Sys32LanguagePath" -MessageEn "Detected language directory: $Sys32LanguagePath" -Color "Green"

$header1Zh = "===============================================`n  自动获取权限、备份并替换系统文件脚本`n==============================================="
$header1En = "===============================================`n  Script: Obtain Permissions, Backup, and Replace System Files Automatically`n==============================================="
Write-Message -MessageZh $header1Zh -MessageEn $header1En -Color "Green"

Write-Message -MessageZh "正在备份系统文件至：$BackupPath ..." -MessageEn "Backing up system files to: $BackupPath ..." -Color "Yellow"

# 定义待备份文件列表（绝对路径）
$FilesToBackup = @(
  # System32 语言目录下的文件（例如 C:\Windows\System32\en-US\mstsc.exe.mui）
    (Join-Path $Sys32LanguagePath "mstsc.exe.mui"),
    (Join-Path $Sys32LanguagePath "mstscax.dll.mui"),
  # System32 下的文件
    (Join-Path $System32Path "mstsc.exe"),
    (Join-Path $System32Path "mstscax.dll"),
  # 系统资源目录下的文件
    (Join-Path $SysResourcesPath "mstsc.exe.mun"),
    (Join-Path $SysResourcesPath "mstscax.dll.mun"),
  # SysWOW64 下的文件
    (Join-Path $SysWOW64Path "mstscax.dll"),
  # SysWOW64\wbem 下的文件
    (Join-Path $WbemPath "mstscax.mof"),
    (Join-Path $WbemLanguagePath "mstscax.mfl")
)

foreach ($File in $FilesToBackup) {
  if (Test-Path $File) {
    # 计算相对于系统盘根目录的相对路径
    $RelativePath = $File.Substring($SystemDrive.Length + 1)
    # 目标备份文件的完整路径：在备份目录下保留原有目录结构
    $DestFile = Join-Path $BackupPath $RelativePath
    # 确保目标目录存在
    $DestDir = Split-Path -Path $DestFile
    if (-not (Test-Path $DestDir)) {
      New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Copy-Item -Path $File -Destination $DestFile -Force
    Write-Message -MessageZh "已备份：$File 至 $DestFile" -MessageEn "Backed up: $File to $DestFile" -Color "Green"
  }
  else {
    Write-Message -MessageZh "文件不存在，跳过备份：$File" -MessageEn "File not found, skipping backup: $File" -Color "Yellow"
  }
}

Write-Message -MessageZh "系统文件备份完成！" -MessageEn "System files backup completed!" -Color "Green"
Write-Message -MessageZh "正在停止远程桌面服务..." -MessageEn "Stopping Remote Desktop Service..." -Color "Yellow"
Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue

# 替换文件函数：自动获取权限、检测目录并替换文件
function Replace-File {
  param (
    [string]$SourceFile,
    [string]$DestinationFile
  )
  if (Test-Path $SourceFile) {
    # 如果目标目录不存在则创建
    $DestDir = Split-Path -Path $DestinationFile
    if (-not (Test-Path $DestDir)) {
      New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    # 获取目标文件所有权并设置权限
    Takeown /F $DestinationFile /A > $null
    Cacls $DestinationFile /e /c /g Administrators:F > $null

    # 替换文件
    Copy-Item -Path $SourceFile -Destination $DestinationFile -Force
    Write-Message -MessageZh "文件替换成功：$DestinationFile" -MessageEn "File replaced: $DestinationFile" -Color "Green"
  }
  else {
    Write-Message -MessageZh "源文件不存在，跳过替换：$SourceFile" -MessageEn "Source file does not exist, skipping replacement: $SourceFile" -Color "Yellow"
  }
}

Write-Message -MessageZh "开始替换文件，请稍候..." -MessageEn "Replacing files, please wait..." -Color "Yellow"

$FilesToReplace = @(
  # 替换 System32 语言目录下的 mstsc.exe.mui 与 mstscax.dll.mui
  @{ Source = "$ScriptDir\System32\mui\mstsc.exe.mui"; Destination = (Join-Path $Sys32LanguagePath "mstsc.exe.mui") },
  @{ Source = "$ScriptDir\System32\mui\mstscax.dll.mui"; Destination = (Join-Path $Sys32LanguagePath "mstscax.dll.mui") },
  # 替换 System32 下的 mstsc.exe 与 mstscax.dll
  @{ Source = "$ScriptDir\System32\mstsc.exe"; Destination = (Join-Path $System32Path "mstsc.exe") },
  @{ Source = "$ScriptDir\System32\mstscax.dll"; Destination = (Join-Path $System32Path "mstscax.dll") },
  # 替换系统资源目录下的文件
  @{ Source = "$ScriptDir\SystemResources\mstsc.exe.mun"; Destination = (Join-Path $SysResourcesPath "mstsc.exe.mun") },
  @{ Source = "$ScriptDir\SystemResources\mstscax.dll.mun"; Destination = (Join-Path $SysResourcesPath "mstscax.dll.mun") },
  # 替换 SysWOW64 下的 mstscax.dll
  @{ Source = "$ScriptDir\SysWOW64\mstscax.dll"; Destination = (Join-Path $SysWOW64Path "mstscax.dll") },
  # 替换 SysWOW64\wbem 下的 mstscax.mof
  @{ Source = "$ScriptDir\SysWOW64\wbem\mstscax.mof"; Destination = (Join-Path $WbemPath "mstscax.mof") },
  # 替换 SysWOW64\wbem 下语言目录中的 mstscax.mfl
  @{ Source = "$ScriptDir\SysWOW64\wbem\zh-CN\mstscax.mfl"; Destination = (Join-Path $WbemLanguagePath "mstscax.mfl") }
)

foreach ($Entry in $FilesToReplace) {
  Replace-File -SourceFile $Entry.Source -DestinationFile $Entry.Destination
}

Write-Message -MessageZh "正在重新启动远程桌面服务..." -MessageEn "Restarting Remote Desktop Service..." -Color "Yellow"
Start-Service -Name TermService -ErrorAction SilentlyContinue

$footer1Zh = "===============================================`n文件替换完成，请检查！`n==============================================="
$footer1En = "===============================================`nFile replacement completed. Please check!`n==============================================="
Write-Message -MessageZh $footer1Zh -MessageEn $footer1En -Color "Green"
Pause