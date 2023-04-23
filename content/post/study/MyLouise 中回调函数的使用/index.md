---
title: "MyLouise 中回调函数的使用"
date: 2023-04-12T06:09:05+08:00
description: "使用回调函数完成 Bot 的交互式命令"
draft: false
isCJKLanguage: true
#文章排序权重
weight: 0
---

# 介绍

在为 MyLouise 项目开发插件时，需要和用户进行对话式的交互，因此需要监听 MyLouise 主体的一个消息队列，不同的线程负责监听一个用户的消息，先贴一部分最早的实现代码

```java
// 开启监听模式
CqhttpWSController.startWatch(inMessage.getUser_id());
int interval = 0;
try
{
    while(interval < 5000)
    {
        // 尝试从监听队列获取消息体
        InMessage inMsg = CqhttpWSController.messageMap.get(inMessage.getUser_id());
        if(inMsg != null)
        {
            if(inMsg.getMessage().equals("嗯"))
            {
                outMsg.setMessage("[CQ:at,qq=" + inMessage.getUser_id() + "]请在 15秒 内发送一张图片");
                r.sendMessage(outMsg);
                interval = 0;
                // 清除原有的参数
                CqhttpWSController.messageMap.remove(inMessage.getUser_id());
                while(true)
                {
                    if(interval == 15000)
                    {
                        timer.set(-1);
                        outMsg.setMessage("[CQ:at,qq=" + inMessage.getUser_id() + "]你太久没有理露易丝，已经忘记画图了");
                        r.sendMessage(outMsg);
                        return;
                    }
                    // 尝试从监听队列获取消息体
                    InMessage imgMsg = CqhttpWSController.messageMap.get(inMessage.getUser_id());
                    if(imgMsg != null)
                    {
                        inMessage.setMessage(inMessage.getMessage() + " " + imgMsg.getMessage());
                        break;
                    }
                    Thread.sleep(1000);
                    interval += 1000;
                }
                break;
            }
        }
        Thread.sleep(1000);
        interval += 1000;
    }
}
catch(InterruptedException e)
{
    e.printStackTrace();
}
finally
{
    // 监听计数器减少，移除多余消息
    CqhttpWSController.stopWatch(inMessage.getUser_id());
}
```

代码逻辑相当复杂，我简单解释一下，最顶部是调用 Louise 中心的方法，进入监听模式，这个模式下系统将会捕捉对应 `user_id` 的消息存入一个 Map

然后是一个嵌套循环，最外层是一个持续 5 次的循环，每次耗时 1 秒，每次循环去系统的 Map 中尝试获取对应用户的消息体，如果 5 秒内用户没有发送任何消息则继续后续代码

如果用户发送了消息并且符合校验规则，则清空系统中已经存放的该用户的所有消息，然后开启一个持续 15 秒的循环继续监听该用户的输入，超时则终止代码，如果收到新的消息则继续执行后续代码

## 分析

上面的代码有很多不合理的地方，例如需要手动控制线程的阻塞，需要手动进入监听模式，退出监听模式，如果错误的代码会导致系统的 Map 混乱，对其它依赖于该 Map 的代码单元或是插件造成严重影响

下面介绍一种利用回调函数大量简化代码的写法

```java
message.at(message.getUser_id()).text("如果需要以图作图请回复 嗯").send();
CqhttpWSController.getMessage((value) - >
{
    if(value == null) return;
    if(value.getMessage().equals("嗯"))
    {
        message.text("请在 15 秒内发送图片").send();
        CqhttpWSController.getMessage((value2) - >
        {
            if(value2 != null) inMessage.setMessage(inMessage.getMessage() + " " + value2.getMessage());
            else message.at(message.getUser_id()).text("你太久没有理露易丝，已经忘记画图了").fall();
        }, inMessage.getUser_id(), 15000 L);
    }
}, inMessage.getUser_id(), 5000 L);
```

