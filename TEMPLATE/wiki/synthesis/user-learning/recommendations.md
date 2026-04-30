---
name: synthesis/user-learning/recommendations
description: 用户个性化学习推荐
type: synthesis
tags: [learning, recommendations]
created: "{{DATE}}"
updated: "{{DATE}}"
status: draft
---

# 学习推荐

> 基于用户查询历史和知识缺口自动生成

## 待探索主题

### 高频但未深入
- (分析后填充)

### 遗忘复习
- (超过 7 天未访问的主题)

### 前置知识缺失
- (用户询问的主题但缺少基础概念)

## 推荐理由

系统根据以下信号生成推荐:
1. 查询频率 > 3 次但未创建概念页
2. 连续询问相关主题（可能存在前置知识缺口）
3. 长时间未访问曾关注的主题

## 响应格式

当检测到以上模式时，主动向用户提议:

```
💡 建议: 似乎你对 [主题 A] 感兴趣，但 Wiki 中还没有相关基础概念页。
是否要我创建一个？
```

## 更新日志

- {{DATE}}: 初始化推荐系统