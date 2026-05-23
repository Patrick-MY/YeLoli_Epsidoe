# 《叶罗丽好朋友》GitHub 任务看板

用途：在 GitHub 仓库中追踪项目任务、负责人、状态和下一步。  
维护原则：**Codex 只维护 Issue，GitHub Project Board 自动展示 Issue 状态**。详细规则见 [GITHUB_看板维护方案.md](E:/Work/叶罗丽/叶罗丽好朋友/GITHUB_看板维护方案.md)。

当前重点：第 8 集测试集《旧玩具也想我》一审反馈后的确认与返修。

## 当前状态总览

第 8 集全片初版已经完成，并已收到 2026-05-23 甲方一审反馈。  
一审反馈已拆解到镜头级：59 个 cut 为 `反馈后待修`，26 个 cut 为 `待确认`。当前核心状态是：**等待熊同步甲方确认问题，并由我方根据甲方参考补齐旧玩具单体资产设定**。

## 看板状态

| 状态 | 任务 | 负责人 | 说明 | 完成标准 |
|---|---|---|---|---|
| 已完成 | [#2 第 8 集全片初版反馈](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/2) | 熊 | 2026-05-23 已收到一审反馈，已整理为一审总反馈文档。 | 甲方反馈已收到，并同步给项目负责人。 |
| 待开始 | [#3 旧玩具单体资产](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/3) | 我 / 熊 | 甲方不会提供旧玩具单体资产，改为我方根据甲方参考和现有旧玩具群像补齐小熊、小兔、布娃娃设定；完成后由熊提交甲方审核。 | 单体设定制作完成、放入项目资产目录，并经甲方审核通过。 |
| 已完成 | [#5 逐镜头修改任务拆解](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/5) | 我 | 已根据一审总反馈，把意见拆到第 8 集 85 个 cut：59 个待修，26 个待确认。 | 单集镜头表、项目总表、TODO 均完成更新。 |
| 待开始，依赖 #8 / #3 | [#6 修改版镜头生成](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/6) | 我 / 熊 | 等甲方确认问题与关键资产状态明确后开始。 | 所有待修镜头状态更新为通过或待合成。 |
| 待开始，依赖 #6 | [#7 修改版剪辑合成](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/7) | Esdeath | 只有修改镜头完成后才进入后期剪辑合成。 | 修改版成片输出完成。 |
| 待审核 / 待确认 | [#8 一审待甲方确认问题同步](https://github.com/Patrick-MY/YeLoli_Epsidoe/issues/8) | 熊 | 26 个待确认 cut 已整理为问题表，等待熊同步甲方并回传结果。 | 收到甲方明确答复，并写回镜头制作进度表。 |

## 看板维护规则

- 新任务优先建 GitHub Issue，不直接手动拖 Project Board。
- Project Board 只作为 Issue 状态的展示层。
- 不需要制作的资产不放入看板，只记录在 [资产设定表.md](E:/Work/叶罗丽/叶罗丽好朋友/资产设定表.md)。
- 甲方提供资料只保存在本地 `0.甲方提供资料/`，不得上传 GitHub。
- 每次更新进度后，需要同步更新本文件、`PROJECT_PROGRESS.md` 和相关制作表。

## 角色分工

| 成员 | 负责内容 |
|---|---|
| 吴 | 剧本转视频生成提示词；镜头生成。 |
| 我 | 镜头生成；项目进度和流程管理；反馈后拆解修改任务。 |
| 熊 | 镜头生成；甲方沟通；同步反馈、素材和资产审核意见。 |
| Esdeath | 后期剪辑合成。 |

## GitHub 权限说明

当前已通过网页登录状态创建 GitHub Issues，用于追踪具体任务。  
GitHub Connector 创建 Issue 仍返回 `Resource not accessible by integration`，说明 App/API 写权限仍不完整；目前可用网页登录方式维护 Issue，SSH 推送仓库文件正常。

## 当前已启用的 Project 自动化

- `Auto-add to project`：已开启，过滤器为 `is:issue is:open`。
- `Item added to project`：已开启，新项目自动进入 `待开始`。
- `Item closed`：已开启，Issue 关闭后自动进入 `已完成`。
- 更细的 `待确认`、`待审核`、`修改中` 状态暂时由 Issue 内容/标签表达，并由 Codex 在更新任务后做看板校验。

## 当前统一列名

GitHub Project Board 当前统一使用中文列名：

`待开始`、`进行中`、`已完成`、`待审核`、`修改中`、`归档`。

原英文列 `To-do`、`Working`、`Done` 已分别改为 `待开始`、`进行中`、`已完成`；空的重复列 `完成` 已删除。
