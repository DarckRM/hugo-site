---
title: "使用 Github Action 完成 Maven 项目部署运行"
date: 2023-09-02T21:50:42+08:00
draft: true
categories: 教程分享
image: http://lights.rmdarck.icu/img/20230902233507.png
description: 此前一直有知道 CI/CD 之类的工作流名词，因为觉得会很麻烦所以并未深入了解，但是由于最近入职的公司项目有用阿里的云效平台提供的自动化工作流操作，实际使用上感觉非常方便，所以想了想还是决定学习一下，在自己的项目上使用该篇文章将以自己写的 Java Maven 项目完成自动编译并且部署到服务器运行的流程
---

## 介绍

Github Action 不做太多介绍了，简单来说是一个 CI/CD 工具，它的特殊之处在于可以在 `workflow` 文件中引用 Github 上开源的一些 Action，即 Action 复用，让整个 Workflow 的编写可以非常灵活且强大，具体的 Workflow 语法建议参考官方文档 [Using workflows](https://docs.github.com/en/actions/using-workflows)

项目使用的 Maven 做包管理，上传到仓库的部分需要 `pom.xml` 文件，用来打包应用，下图是项目 `main` 分支的文件结构

![](http://lights.rmdarck.icu/img/20230903004004.png)

现在需要做的是，当我 `push` 或者 `pull request` 提交的时候，检测 `checkout main` 分支的代码是否变动了 `src/**` 或者 `pom.xml`，如果发生变动则执行 `workflow`

## 创建一个工作流

在项目顶部的 Tab 中找到 Actions 一项，此处开始创建工作流，下面是一些编写好的 `workflow` 运行的概览

![image-20230903004957216](http://lights.rmdarck.icu/img/image-20230903004957216.png)

在 Choose a workflow 页面中会有一些预置的 `workflow` 给你挑选，一般会根据你项目的类型自动推荐一些，比如我这里就推荐了一些 Java 相关的 `workflow` ，就选这个 `Java with Maven` 作为基础，然后再进去修改

![image-20230903005308773](http://lights.rmdarck.icu/img/image-20230903005308773.png)

在 Workflow 的编写界面可以看出 Workflow 是存储在项目目录下 `.github/workflows` 目录下，以 `.yml` 结尾的文件，Github 如果发现该目录下有以 `.yml` 结尾的文件就会尝试执行，这里你可以选择给 `workflow`文件改名，在右边有一些推荐的 `action` 你可以直接点击它们查看用例，中间是 `workflow` 的编写处，具体语法见第一节的官方文档，写的很详细，不予赘述

![image-20230903005747939](http://lights.rmdarck.icu/img/image-20230903005747939.png)

## 编写 Workflow

对 Workflow 的需求有 `特定情况触发 workflow` `编译打包项目并缓存结果` `上传编译后的文件到服务器` `在服务器上运行项目` 下面是整个编写好后的 `workflow` 文件

```yaml
name: Java CI with Maven

on:
  push:
    branches: [ "main" ]
    paths:
      - .github/workflows/maven.yml
      - src/**
      - pom.xml
  pull_request:
    branches: [ "main" ]
    paths:
      - .github/workflows/maven.yml
      - src/**
      - pom.xml

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 19
      uses: actions/setup-java@v3
      with:
        java-version: '19'
        distribution: 'temurin'
        cache: maven
    
    - name: Build with Maven
      run: mvn -B package --file pom.xml -Dmaven.test.skip=true
    - uses: actions/cache@v3
      with:
        path: ~/.m2
        key: ${{ hashFiles('pom.xml') }}

    - name: Deploy to server
      uses: garygrossgarten/github-action-scp@release
      with:
        local: target/louise-0.1.7-dev.jar
        remote: /home/darcklh/qqbot/MyLouise/louise-0.1.7-dev.jar
        host: ${{ secrets.AZURE_HOST }}
        username: ${{ secrets.AZURE_USERNAME }}
        privateKey: ${{ secrets.AZURE_SSH_KEY }}
    - name: Run App
      if: always()
      uses: fifsky/ssh-action@master
      with:
        command: cd /home/darcklh/qqbot/MyLouise && ./restart.sh ./louise-0.1.7-dev.jar &
        host: ${{ secrets.AZURE_HOST }}
        user: ${{ secrets.AZURE_USERNAME }}
        key: ${{ secrets.AZURE_SSH_KEY }}
        args: "-tt"
        
    # Optional: Uploads the full dependency graph to GitHub to improve the quality of Dependabot alerts this repository can receive
    - name: Update dependency graph
      uses: advanced-security/maven-dependency-submission-action@571e99aab1055c2e71a1e2309b9691de18d6b7d6
      with:
        token: ${{ secrets.ACCESS_TOKEN }}
```

### 特定情况触发 workflow

第一节是给 `workflow` 命名，第二节指定响应事件 `on.<events>` 对于 `<push|pull_request>` 事件可以选择对应事件的 `branch` 或者忽略某个 `branch` 并且 `branch` 可以通过数组形式传入多个，如 `on.<push|pull_request>.<branches|branches-ignore>`，然后通过 `on.<push|pull_request>.paths` 可以指定响应哪些文件，此处路径上下文是项目根目录，结合示例的目录结构排除掉这些文件，这里我把 `workflow` 文件本身也排除掉了，主要不想每次改一点 `workflow` 就执行一次

### 编译打包项目

第三节定义任务，所有任务以 `job.<job_id>` 区分，此处指定一个名为 `build` 的任务，`runs_on` 指定 `workflow` 的运行环境，可以选择 Windows 或者 Linux 系统，具体参加官方文档，我选的 `ubuntu-latest` 

`job.<job_id>.steps` 里面定义步骤，按流程执行，第一步是使用一个开放的 Action `actions/checkout@v3` 来检出代码到定义的运行环境

> `action` 也是可以用仓库定义的，可以像引用仓库一样引用 `action`，引用的 `action` 使用 `uses` 来执行，在下面填写该 `action` 可能会用到的键值对

下一步是 `Set up JDK 19 ` ，在此处指定项目需要的 `jdk` 版本

然后是 `Build with Maven` 这里用 `run` 表示在运行环境下的 `shell` 中执行命令，编译完成后使用公共 Action `actions/cache@v3` 缓存此次运行的结果，`with` 代表传入该 `action` 的参数，这里传入了 `pom.xml` 的 hash 值，用来在该 `action` 内部判断是否命中缓存

### 上传编译后的文件到服务器

这一步为 `Deploy to server` 用到了 `garygrossgarten/github-action-scp@release` 这个 Action，是用来 scp 到服务器的，看它需要的具体参数

```yaml
        local: target/louise-0.1.7-dev.jar
        remote: /home/darcklh/qqbot/MyLouise/louise-0.1.7-dev.jar
        host: ${{ secrets.AZURE_HOST }}
        username: ${{ secrets.AZURE_USERNAME }}
        privateKey: ${{ secrets.AZURE_SSH_KEY }}
```

| key        | value                                             | info                                              |
| ---------- | ------------------------------------------------- | ------------------------------------------------- |
| local      | target/louise-0.1.7-dev.jar                       | 上一步打包后需要上传的目标，可为目录              |
| remote     | /home/darcklh/qqbot/MyLouise/louise-0.1.7-dev.jar | 远程目标，建议使用绝对路径，会自动创建目录        |
| host       | ${{ secrets.AZURE_HOST }}                         | 远程主机                                          |
| username   | ${{ secrets.AZURE_USERNAME }}                     | 登录用户                                          |
| privateKey | ${{ secrets.AZURE_SSH_KEY }}                      | 如果不使用私钥也可以改为 `password` 传递 ssh 密码 |

解释一下 `${{}}` 语法，这是 `workflow` 防止敏感信息泄露做的项目级变量引用，在仓库的顶部 Tab 中找到 Settings，然后在左侧边栏找到 `Secrets and variables` 然后在 `Actions` 项中添加 `secret` 即可在 `workflow` 中按照语法去引用了

![image-20230903014503091](http://lights.rmdarck.icu/img/image-20230903014503091.png)

### 在服务器上运行项目

这一步为 `Run App`，`if` 可以传递一些函数或变量判断是否执行，其实和上一个 `action` 差不多，这里额外传递了 `command` 项，也就是登录上服务器后执行的命令，可以在服务器上提前编写好脚本，然后在这里调用该脚本即可

最后那个 `Update dependency graph` 是可选的，好像是会变更你仓库的 `dependency graph` 不过要完成这个操作需要你的 Github App Token，这里就不介绍怎么创建了，也很简单，Google 一下

## 结束

编写完成后，你可以尝试向你的监听分支 Push 一些提交测试一下，所有的 Workflow 运行记录都将在 Actions 页查看到，我只能说这一套操作对于开发来说确实优雅不少，以前提交了代码苦哈哈的用 Idea 执行打包，然后害得用 Windows Terminal 执行 SCP，最后还要 SSH 服务器手动执行脚本，尽管用上了很多半自动方案，但是比起这个 Action 来说还是逊色太多

## 奖励

感谢你的阅读

![](http://lights.rmdarck.icu/img/paimon_and_lumine.png)
