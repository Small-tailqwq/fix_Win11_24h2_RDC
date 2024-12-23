# Fixing screen distortion issues with Remote Desktop connection on Windows 11 24H2

After updating to Windows 11 24H2, there is a chance of screen distortion, including blocky distortion and striped distortion, when using Remote Desktop to connect to some older Windows servers.

Replacing the Remote Desktop connection program with an older version (from Windows 11 23H2) can fix this compatibility issue. The files are extracted from the Professional edition of Windows 11 23H2 and should be applicable to the 24H2 version. For other versions, please backup your files before attempting to replace them.

## Unable to replace?

Open Command Prompt (CMD) with administrator privileges and run the following commands:

```cmd
takeown /f C:\Windows\System32\mstsc.exe /a
Cacls C:\Windows\System32\mstsc.exe /e /c /g Administrators:F  
takeown /f C:\Windows\System32\mstscax.dll /a
Cacls C:\Windows\System32\mstscax.dll /e /c /g Administrators:F
regsvr32 C:\Windows\System32\mstscax.dll
```

## Source of the issue and solution

[Microsoft Community - After updating to Windows 11 24H2, Remote Desktop displays screen distortion, but it was normal before the update](https://answers.microsoft.com/zh-hans/windowsclient/forum/all/%E6%9B%B4%E6%96%B0%E8%87%B3win11/776bec98-0be9-4952-90f8-5432ac9bac25?page=7)

# 修复win11 24h2 远程桌面连接花屏问题
windows11 24h2更新后，电脑远程连接部分老旧windows服务器时有概率出现花屏情况，包括方块装花屏、条形装花屏……
使用老版本（win11 23h2）的远程桌面连接程序进行替换，可以修复这个兼容性问题。
文件提取自win11 23h2专业版，理应适用于win11 24h2版本，其他版本请在备份好文件的情况下酌情尝试。

## 无法替换？

使用管理员权限打开 CMD，运行如下命令
```cmd
takeown /f C:\Windows\System32\mstsc.exe /a
Cacls C:\Windows\System32\mstsc.exe /e /c /g Administrators:F
takeown /f C:\Windows\System32\mstscax.dll /a
Cacls C:\Windows\System32\mstscax.dll /e /c /g Administrators:F
regsvr32 C:\Windows\System32\mstscax.dll
```

## 问题以及解决方案来源

[微软社区-更新至WIN11 24H2后，使用远程连接时，显示花屏，更新前连接正常显示](https://answers.microsoft.com/zh-hans/windowsclient/forum/all/%E6%9B%B4%E6%96%B0%E8%87%B3win11/776bec98-0be9-4952-90f8-5432ac9bac25?page=7)
