---
title: "C Sharp中GDI打印源码的重构"
date: 2022-05-23T11:19:10+08:00
description: "文章描述信息"
draft: false
isCJKLanguage: true
#文章排序权重
mermaid: true
---

{{ <mermaid> }}
classDiagram
	  EmrDocument o-- Element
      Element<|..Hr
      Element<|..Line
      Element<|..Paragraph
      Element<|..Table
      Table o-- Cell
      Element<|..ListElement
      ListElement<|--UnorderedListElement
      ListElement<|--OrderedListElement
      class EmrDocument {
      	+List~Element~ Elements
      	+Header Header
      	+Footer Footer
      	#int ptr
      	#bool init
      	+Parse(string)$ EmrDocument
      	+GetNextElement(Element) bool
      	+Back()
      	#Init(Graphics)
      	#Print(Graphics) bool
      }
{{ </mermaid> }}