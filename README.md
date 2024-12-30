# Fixing Screen Distortion Issues with Remote Desktop Connection on Windows 11 24H2

After updating to Windows 11 24H2, there is a chance of screen distortion, including blocky distortion and striped distortion, when using Remote Desktop to connect to some older Windows servers.

Replacing the Remote Desktop connection program with an older version (from Windows 11 23H2) can fix this compatibility issue. The files are extracted from the Professional edition of Windows 11 23H2 and should be applicable to the 24H2 version. For other versions, please back up your files before attempting to replace them.

## How to Use

1. Download the replacement files.

2. Verify the file integrity (e.g., MD5 or SHA256 checksum).

3. Backup the following files in the 

   ```
   C:\Windows\System32
   ```

    directory:

   - `mstsc.exe`
   - `mstscax.dll`

4. Replace the original files with the downloaded versions.

### File Details

```
File Name: mstsc.exe  
File Version: 10.0.22621.3374  
Modified Time: 2024-12-23 10:35:29  
MD5: 7c3fd090bc7115a9ddc3ea05a8f9b4e7  
SHA256: c41ed3b92297e870bc56a2643f5a15a62ee79a905a31a0c7935cbb7ee94bbae0  

File Name: mstscax.dll  
File Version: 10.0.22621.3447  
Modified Time: 2024-12-23 10:36:04  
MD5: d5afc6b75eb4a794da4df8094b7bb974  
SHA256: 0a39a3d5c382fbea260d80b2cfca3278660194b932894565a0fb695946dde9bf  
```

## Unable to Replace the Files?

If you are unable to replace the files, open Command Prompt (CMD) with administrator privileges and run the following commands to gain the necessary permissions:

```cmd
takeown /f C:\Windows\System32\mstsc.exe /a
Cacls C:\Windows\System32\mstsc.exe /e /c /g Administrators:F  
takeown /f C:\Windows\System32\mstscax.dll /a
Cacls C:\Windows\System32\mstscax.dll /e /c /g Administrators:F
regsvr32 C:\Windows\System32\mstscax.dll
```

## Source of the Issue and Solution

The issue appears to be caused by a compatibility problem between the Remote Desktop client in Windows 11 24H2 and older Windows servers. By replacing the updated Remote Desktop files with those from Windows 11 23H2, the problem can be resolved.

**Source of the solution:**
 [Microsoft Community - After updating to Windows 11 24H2, Remote Desktop displays screen distortion, but it was normal before the update](https://answers.microsoft.com/zh-hans/windowsclient/forum/all/更新至win11/776bec98-0be9-4952-90f8-5432ac9bac25?page=7)

> *Translated with GPT-4o*



# 修复win11 24h2 远程桌面连接花屏问题

Windows11 24h2更新后，电脑远程连接部分老旧windows服务器时有概率出现花屏情况，包括方块状花屏、条形状花屏……
使用老版本（win11 23h2）的远程桌面连接程序进行替换，可以修复这个兼容性问题。
文件提取自win11 23h2专业版，理应适用于win11 24h2版本，其他版本请在备份好文件的情况下酌情尝试。

## 如何使用？

1. 下载文件并校验文件完整性（如 MD5 或 SHA256 校验码）。
2. 备份 C:\Windows\System32 目录下的以下文件：
   - `mstsc.exe`
   - `mstscax.dll`
3. 将原文件替换为下载的文件即可

### 文件详情

```
文件名称: mstsc.exe
文件版本: 10.0.22621.3374
修改时间: 2024年12月23日，10:35:29
MD5: 7c3fd090bc7115a9ddc3ea05a8f9b4e7
SHA256: c41ed3b92297e870bc56a2643f5a15a62ee79a905a31a0c7935cbb7ee94bbae0

文件名称: mstscax.dll
文件版本: 10.0.22621.3447
修改时间: 2024年12月23日，10:36:04
MD5: d5afc6b75eb4a794da4df8094b7bb974
SHA256: 0a39a3d5c382fbea260d80b2cfca3278660194b932894565a0fb695946dde9bf
```

## 无法替换？

如无法替换文件，请以管理员权限打开 CMD，运行如下命令获取文件的访问权限：
```cmd
takeown /f C:\Windows\System32\mstsc.exe /a
Cacls C:\Windows\System32\mstsc.exe /e /c /g Administrators:F
takeown /f C:\Windows\System32\mstscax.dll /a
Cacls C:\Windows\System32\mstscax.dll /e /c /g Administrators:F
regsvr32 C:\Windows\System32\mstscax.dll
```

## 问题以及解决方案来源

[微软社区-更新至WIN11 24H2后，使用远程连接时，显示花屏，更新前连接正常显示](https://answers.microsoft.com/zh-hans/windowsclient/forum/all/%E6%9B%B4%E6%96%B0%E8%87%B3win11/776bec98-0be9-4952-90f8-5432ac9bac25?page=7)
