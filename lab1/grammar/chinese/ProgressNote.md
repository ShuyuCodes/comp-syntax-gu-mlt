# GF Lab 1 — Chinese Grammar: Progress Note

**Date:** November 2026  
**Branch:** `chinese-grammar-practice`

## 1. 已完成的修改 | Changes Made

1. **Noun morphology（名词形态）**
   - 将 `Noun` 简化为 `{s : Str}`。
   - 中文名词不需要像英语一样区分单复数词形。

2. **Verb morphology（动词形态）**
   - 将 `Verb` 简化为 `{s : Str}`。
   - 移除了英语式的时态、人称和数的动词变化。

3. **Verb2（及物动词）**
   - 在 `Verb` 基础上增加字段 `c`，用于保存额外的介词或补语标记。

4. **VP structure（动词短语结构）**
   - 增加 `beforeVerb`，用于存放动词前的状语。
   - 实现 `AdvVP`，使副词能够出现在动词前面。

5. **Chinese word order（中文语序）**
   - `AdjCN`：形容词在名词前。
   - `ComplV2`：动词后接宾语。
   - `PrepNP`：支持 NP 前后的介词性成分，例如「在房间里」「和他一起」。
   - `PredVPS`：组合主语和谓语。

6. **Pronouns and determiners（代词与限定词）**
   - 中文代词的 `Nom` 和 `Acc` 使用相同形式。
   - 简化限定词和名词短语结构，暂不处理量词。

7. **Adjective predicates（形容词谓语）**
   - 使用空动词处理中文形容词谓语，暂不引入系词「是」。

8. **Testing（测试）**
   - 成功编译 `MicroLangChi.gf`。
   - 成功随机生成 20 个句子。
   - 通过 4 项定向测试：主谓结构、及物动词、介词短语、副词位置。

## 2. 不足与未来改进 | Future Improvements

这些是当前简化语法的局限，不是必须马上完成的任务。

| Priority | Area | Possible improvement |
|---|---|---|
| High | Classifiers 量词 | 实现「一本书」「一个人」等结构 |
| High | Adjective predicates 形容词谓语 | 改进「她红」等不自然表达，研究「很」的使用 |
| Medium | Adverbial ordering 状语顺序 | 区分时间、频率、方式和地点状语 |
| Medium | Prepositional constructions 介词结构 | 扩展「给、对、从、把」等结构 |
| Low | Agreement 一致关系 | 检查 `Agreement` 是否需要保留或进一步使用 |
| Low | Verb complements 动词补语 | 扩展结果补语、趋向补语等结构 |
| Low | Semantic compatibility 语义兼容性 | 减少随机生成的不自然句子 |
| Medium | RGL compatibility | 进一步检查与 Resource Grammar Library 的兼容性 |

## 3. 目前的结论 | Current Status

已经完成一个能够正常编译、生成句子并通过基础定向测试的简化中文 grammar。

**Decision:** 暂时停止扩展，保留当前版本作为 Lab 1 的基础成果。以后根据课程需要再改进，不追求一次实现完整的现代汉语语法。