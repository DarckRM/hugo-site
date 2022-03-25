---
title: "Ubuntu20.04安装Zabbix5.0LTS"
date: 2021-12-20T16:21:34+08:00
description: "Ubuntu20.04安装Zabbix5.0LTS"
draft: true
categories: 学习资料
---

[原文地址](https://blogs.windows.com/windows-insider/2021/12/15/announcing-windows-11-insider-preview-build-22523/)

## TLDR

- ARM64 PC可获取此版本
- 为此版本提供了ISO文件 [下载地址](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso)
- 假日前的最后一个版本，各位2022见！

## 变动和改进

- 我们[在 ALT + TAB](https://blogs.windows.com/windows-insider/2021/11/03/announcing-windows-11-insider-preview-build-22494/)和任务视图中推出了[快照组，](https://blogs.windows.com/windows-insider/2021/11/03/announcing-windows-11-insider-preview-build-22494/)就像您将鼠标悬停在任务栏上打开的应用程序一样，您可以在开发频道中的所有预览体验成员那里看到它们。
- 当在本机上打开资源管理器时，在命令栏中点击“...”可以添加或移除媒体服务器（如果可用）。
- 我们目前的一部分努力在于将一些控制面板的设置项迁移到设置应用中
  - 控制面板中程序和功能的链接现在将打开到设置 > 应用程序 > 已安装的应用程序。编辑：换句话说，链接到页面以卸载或更改您 PC 上的程序。
  - 我们正在将“卸载更新”（用于累积更新等）从“控制面板”移至“设置”>“Windows 更新”>“更新历史记录”下的“设置”中的新页面。

## 修复

**[任务栏]**

- 修复了ARM64 PC上文本输入初始化时会导致Shell无响应的问题。（如开始菜单和搜索框）
- 工具栏的电池图标不会无端的显示超过100%的电量。
- 当打开了过多的应用时，应用图标将不再会与日期时间图片在第二显示器上重合。

**[文件管理器]**

- 做了一些工作来解决在使用F2重命名OneDrive的文件后使用回车键导致键盘失去焦点的问题。

**[聚光灯收藏]**

- 现在在开启[聚光灯收藏](http://aka.ms/wip22518)后,你的第一张图片（在Whitehaven Beach之后）将会更快的加载。
- 在聚光灯收藏的上下文菜单中添加了图标。

