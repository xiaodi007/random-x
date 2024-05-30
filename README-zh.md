# `randomX` 模块

## 概述

`randomX` 模块提供了从向量中进行随机选择以及加权选择的功能。它的设计目的是帮助你随机，或根据分配的权重选择一个或多个元素，在需要考虑选择概率的场景中非常有用。

## 函数

```move
choice: 从给定的元素向量中随机选择一个元素。
choices: 从给定的元素向量中随机选择多个元素。
weighted_choice: 从给定的元素向量中根据权重向量随机选择一个元素。
weighted_choices: 从给定的元素向量中根据权重向量随机选择多个元素。
random_permutation: 生成给定向量的随机排列。可以用来打乱元素的顺序。
weighted_random_permutation: 生成基于权重的向量的随机排列。
sample_without_replacement: 从向量中不放回地抽取多个样本。
weighted_sample_without_replacement: 从向量中根据权重不放回地抽取多个样本。
```