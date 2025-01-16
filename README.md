# 修复win11 24h2 远程桌面连接花屏问题

Windows11 24h2更新后，电脑远程连接部分老旧windows服务器时有概率出现花屏情况，包括方块状花屏、条形状花屏……
使用老版本（win11 23h2）的远程桌面连接程序进行替换，可以修复这个兼容性问题。
文件提取自win11 22h2专业版，理应适用于win11 24h2版本，其他版本请在备份好文件的情况下酌情尝试。

## 如何使用？

1. 下载压缩包（还没传）或者文件，以如下路径放置
```  
|- Replace.ps1 (脚本文件)
|- System32
   |- mui
      |- mstsc.exe.mui
      |- mstscax.dll.mui
   |- mstsc.exe
   |- mstscax.dll
|- SystemResources
   |- mstsc.exe.mun
   |- mstscax.dll.mun
```
2. 按`win` + `x`，选择 **终端（管理员）** ，把 `Replace.ps1` 路径复制进去执行。或者右键管理员权限执行（我电脑上右键没有管理员权限执行的按钮，很奇怪）

### 文件详情

```
还没计算
```

## 无法替换？

发issue，目前这个脚本没咋在其他环境测试

## 问题以及解决方案来源
[issue - #1 ](https://github.com/Small-tailqwq/fix_Win11_24h2_RDC/issues/1#issuecomment-2594356189)  
[微软社区-更新至WIN11 24H2后，使用远程连接时，显示花屏，更新前连接正常显示](https://answers.microsoft.com/zh-hans/windowsclient/forum/all/%E6%9B%B4%E6%96%B0%E8%87%B3win11/776bec98-0be9-4952-90f8-5432ac9bac25?page=7)

