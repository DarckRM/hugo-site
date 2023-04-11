---
title: "在VUE3中使用路由监听实现WebSocket连接的断开"
date: 2022-04-19T00:26:00+08:00
description: "在开发MyLouise前端部分的时候用到了WebSocket实现日志的实时输出，但是在前端切换路由过后，WebSocket连接并不会主动断开，Interval函数会不停的访问空WebSocket对象的data属性，导致在控制台输出大量错误日志，这篇文章记录了如何修复这个问题的过程"
draft: true
categories: 学习资料
---

## 背景

首先介绍功能背景

为了实现后端的日志能够实时输出到前端，我在后端写了一个线程用于循环读取项目产生的日志文件，每当文件有新的一行添加时，就会使用WebSocket连接向前端发送格式化为HTML格式的字符串，前端再利用VUE3的MVVW模型实现数据视图的实时更新

为了达到这个效果，前端需要在打开日志页面时，向后端发起建立WebSocket协议的请求，并且启动后端的日志输出线程，向建立的WebSocket连接输出消息，然后在切换页面时停止前端的Interval函数和后端输出日志的线程。

## 初期方案

```vue
<template>
    <n-card title="输出">
        <div v-html="terminal_output"></div>
        <WebSocket ref="webSocket" client_name="terminal_info" data=""></WebSocket>
        <n-button @click="displayLog">显示日志</n-button>
        <n-button @click="clear">停止输出</n-button>
    </n-card>
</template>
<script>
    import WebSocket from '../components/websocket/WebSocket.vue'
	import { defineComponent } from 'vue'
    export default defineComponent({
        data() {
            return {
                terminal_output: ''
            }
        },
        methods: {
            displayLog() {
                this.terminal_output = this.$refs.webSocket.data
                setInterval(this.displayLog, 1000)
                this.clear()
            },
            clear() {
                this.displayLog = null
                clearInterval(this.displayLog)
            }
        }
    })
</script>
```

解释一下上面的简化代码，`n-card`里第一行是一个div框，绑定了`v-html`属性，用来渲染后端输出的日志信息

接着是import进来的`WebSocket`组件，定义了两个props属性，`client_name`和`data`，前者表示和后端简历连接的连接名（便于组件服用）
