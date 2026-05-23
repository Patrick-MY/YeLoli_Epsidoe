#!/usr/bin/env node
// 合并 Issue #72/73/74 为商场场景全局设定 Issue
// 用法: GH_TOKEN=ghp_xxx node tools/合并商场Issues.mjs

const TOKEN = process.env.GH_TOKEN;
if (!TOKEN) {
  console.error('请设置 GH_TOKEN 环境变量');
  process.exit(1);
}

const OWNER = 'Patrick-MY';
const REPO = 'YeLoli_Epsidoe';
const API = 'https://api.github.com/repos/' + OWNER + '/' + REPO;

async function api(method, path, body) {
  const opts = {
    method,
    headers: {
      'Authorization': 'token ' + TOKEN,
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
  };
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(API + path, opts);
  if (!res.ok) {
    const err = await res.text();
    throw new Error(method + ' ' + path + ' ' + res.status + ' ' + res.statusText + ': ' + err);
  }
  return res.json();
}

async function main() {
  // 1. Create merged Issue
  const newIssue = await api('POST', '/issues', {
    title: '【资产】制作商场场景全局设定（SCN-001/002/003）',
    body: [
      '## 合并说明',
      '',
      '原 Issue #72（SCN-001 商场环境）、#73（SCN-002 商场内部店铺）、#74（SCN-003 商场玩具替换参考）合并为本 Issue。三个 SCN 统一作为商场场景设定处理。',
      '',
      '## 资产信息',
      '',
      '- **资产ID**: SCN-001 / SCN-002 / SCN-003',
      '- **资产名称**: 商场场景全局设定（环境 + 内部店铺 + 玩具替换参考）',
      '- **类型**: 场景',
      '- **当前状态**: 待甲方审核（首版参考图已在 `6.待审核内容/商场.png`）',
      '',
      '## 修改要求',
      '',
      '- 中央雕塑更换为玩具城堡造型（玩具房间风格），参考"叶罗丽琉璃花城"多层城堡',
      '- 货架商品全部替换为甲方产品表商品（萌萌萌、怪兽快跑等）',
      '- 店铺陈列和商品按甲方产品替换，与商场整体统一风格',
      '- 参考 `0.甲方提供资料/20260523/产品图/`',
      '',
      '## 需要补充的视图',
      '',
      '当前 `6.待审核内容/商场.png` 为首版参考图，还需补充以下视图：',
      '',
      '1. **全景俯视图** — 商场整体布局俯瞰，标注各区域位置',
      '2. **九宫格图** — 分区域拆解商场各部分细节',
      '3. **多角度参考** — 入口、中央雕塑、货架区、收银台等不同角度',
      '',
      '参考 SCN-004 思思卧室的交付标准（甲方审核通过时含 13 张多角度参考）。',
      '',
      '## 影响镜头',
      '',
      'EP08 Sc01：S-01 至 S-04（商场 + 玩具货架）',
      '',
      '## 关联文档',
      '',
      '- [资产设定表](资产设定表.md)',
      '- [一审需修改镜头清单](5.分镜头提示词/EP08/第8集_旧玩具也想我_一审需修改镜头清单.md)',
      '- [TODO](TODO.md)',
    ].join('\n'),
    labels: ['第8集', '资产', '修改中'],
  });

  console.log('CREATED #' + newIssue.number + ': ' + newIssue.title);
  console.log('URL: ' + newIssue.html_url);

  // 2. Close old Issues
  const oldNums = [72, 73, 74];
  const notes = {
    72: '原 SCN-001 商场环境内容已纳入合并 Issue。',
    73: '原 SCN-002 商场内部店铺内容已纳入合并 Issue。',
    74: '原 SCN-003 商场玩具替换参考内容已纳入合并 Issue。',
  };
  for (const n of oldNums) {
    await api('PATCH', '/issues/' + n, {
      state: 'closed',
      state_reason: 'not_planned',
      body: '已合并到 #' + newIssue.number + ' 【资产】制作商场场景全局设定（SCN-001/002/003）。\n\n---\n\n' + notes[n],
    });
    console.log('CLOSED #' + n);
  }

  // 3. Print new issue number for local doc updates
  console.log('\nNEW_ISSUE_NUMBER=' + newIssue.number);
}
main().catch(err => {
  console.error('FAILED:', err.message);
  process.exit(1);
});
