# 双语 PowerShell 脚本：备份并替换系统文件
# 请以管理员权限运行

# 获取当前脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 创建备份文件夹和时间戳
$BackupDir = Join-Path -Path $ScriptDir -ChildPath "bak"
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BackupPath = Join-Path -Path $BackupDir -ChildPath $TimeStamp
if (-not (Test-Path $BackupDir)) {
  New-Item -ItemType Directory -Path $BackupDir | Out-Null
}
New-Item -ItemType Directory -Path $BackupPath | Out-Null

# 检测语言目录
$PossibleLanguageDirs = @("zh-CN", "en-US", "es-ES", "hi-IN", "ar-SA", "pt-BR", "fr-FR", "ru-RU", "ja-jp", "de-DE")
$MUIPath = $null
$DetectedLanguage = "en"
foreach ($LangDir in $PossibleLanguageDirs) {
  $CurrentPath = "$env:SystemRoot\System32\$LangDir"
  if (Test-Path "$CurrentPath\mstsc.exe.mui") {
    $MUIPath = $CurrentPath
    $DetectedLanguage = $LangDir
    break
  }
}

# 定义输出函数
function Write-Message {
  param (
    [string]$MessageZh,
    [string]$MessageEn,
    [string]$Color = "Yellow"
  )
  if ($DetectedLanguage -eq "zh-CN") {
    Write-Host $MessageZh -ForegroundColor $Color
  }
  else {
    Write-Host $MessageEn -ForegroundColor $Color
  }
}

# 检测语言路径
if (-not $MUIPath) {
  Write-Message `
    -MessageZh "未能找到 mstsc.exe.mui 文件，请检查系统是否支持远程桌面或文件是否存在。" `
    -MessageEn "Failed to find mstsc.exe.mui file. Please check if Remote Desktop is supported or if the file exists." `
    -Color "Red"
  Pause
  Exit
}

Write-Message `
  -MessageZh "检测到语言目录路径：$MUIPath" `
  -MessageEn "Detected language directory path: $MUIPath" `
  -Color "Green"

# 显示脚本开始信息
Write-Message `
  -MessageZh "===============================================`n  自动获取文件权限、备份并替换文件脚本`n===============================================" `
  -MessageEn "===============================================`n  Script: Automatically Obtain Permissions, Backup, and Replace System Files`n===============================================" `
  -Color "Green"

# 备份文件
Write-Message `
  -MessageZh "正在备份系统原版文件至：$BackupPath..." `
  -MessageEn "Backing up original system files to: $BackupPath..." `
  -Color "Yellow"

# 定义需要备份的文件列表
$FilesToBackup = @(
  "$MUIPath\mstsc.exe.mui",
  "$MUIPath\mstscax.dll.mui",
  "$env:SystemRoot\System32\mstsc.exe",
  "$env:SystemRoot\System32\mstscax.dll",
  "$env:SystemRoot\SystemResources\mstsc.exe.mun",
  "$env:SystemRoot\SystemResources\mstscax.dll.mun"
)

foreach ($File in $FilesToBackup) {
  if (Test-Path $File) {
    Copy-Item -Path $File -Destination $BackupPath -Force
    Write-Message `
      -MessageZh "已备份文件：$File" `
      -MessageEn "File backed up: $File" `
      -Color "Green"
  }
  else {
    Write-Message `
      -MessageZh "文件不存在，跳过备份：$File" `
      -MessageEn "File does not exist, skipping backup: $File" `
      -Color "Yellow"
  }
}

Write-Message `
  -MessageZh "系统原版文件已成功备份！" `
  -MessageEn "Original system files backed up successfully!" `
  -Color "Green"

# 停止远程桌面服务
Write-Message `
  -MessageZh "正在停止远程桌面服务..." `
  -MessageEn "Stopping Remote Desktop Service..." `
  -Color "Yellow"
Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue

# 替换文件函数
function Replace-File {
  param (
    [string]$SourceFile,
    [string]$DestinationFile
  )
  if (Test-Path $SourceFile) {
    # 获取文件所有权并授予权限
    Takeown /F $DestinationFile /A > $null
    Cacls $DestinationFile /e /c /g Administrators:F > $null

    # 替换文件
    Copy-Item -Path $SourceFile -Destination $DestinationFile -Force
    Write-Message `
      -MessageZh "已替换文件：$DestinationFile" `
      -MessageEn "File replaced: $DestinationFile" `
      -Color "Green"
  }
  else {
    Write-Message `
      -MessageZh "源文件不存在，跳过替换：$SourceFile" `
      -MessageEn "Source file does not exist, skipping replacement: $SourceFile" `
      -Color "Yellow"
  }
}

Write-Message `
  -MessageZh "正在获取文件权限并替换文件，请稍候..." `
  -MessageEn "Obtaining file permissions and replacing files, please wait..." `
  -Color "Yellow"

# 定义需要替换的文件和目标路径
$FilesToReplace = @(
  @{ Source = "$ScriptDir\System32\mui\mstsc.exe.mui"; Destination = "$MUIPath\mstsc.exe.mui" },
  @{ Source = "$ScriptDir\System32\mui\mstscax.dll.mui"; Destination = "$MUIPath\mstscax.dll.mui" },
  @{ Source = "$ScriptDir\System32\mstsc.exe"; Destination = "$env:SystemRoot\System32\mstsc.exe" },
  @{ Source = "$ScriptDir\System32\mstscax.dll"; Destination = "$env:SystemRoot\System32\mstscax.dll" },
  @{ Source = "$ScriptDir\SystemResources\mstsc.exe.mun"; Destination = "$env:SystemRoot\SystemResources\mstsc.exe.mun" },
  @{ Source = "$ScriptDir\SystemResources\mstscax.dll.mun"; Destination = "$env:SystemRoot\SystemResources\mstscax.dll.mun" }
)

foreach ($File in $FilesToReplace) {
  Replace-File -SourceFile $File.Source -DestinationFile $File.Destination
}

# 重启远程桌面服务
Write-Message `
  -MessageZh "正在重新启动远程桌面服务..." `
  -MessageEn "Restarting Remote Desktop Service..." `
  -Color "Yellow"
Start-Service -Name TermService -ErrorAction SilentlyContinue

Write-Message `
  -MessageZh "===============================================`n文件替换完成，请检查！`n===============================================" `
  -MessageEn "===============================================`nFile replacement completed. Please check!`n===============================================" `
  -Color "Green"
Pause
