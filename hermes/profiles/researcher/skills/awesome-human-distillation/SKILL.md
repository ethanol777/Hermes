---
name: awesome-human-distillation
description: >
  Human Distillation（人类蒸馏）技能目录。收集一切将真实的人蒸馏成 AI Skill 的项目。
  当用户提到"人类蒸馏""human distillation""蒸馏xxx""装一个人类""挑个技能"时触发。
  包含 204 个可安装的人类蒸馏 AI Skill 的完整目录，按类别组织。
  用户可以用"列表""浏览""推荐""搜索xxx"等关键词来浏览和挑选。
---

# Awesome Human Distillation

将真实存在过的人——同事、导师、前任、家人、公众人物——通过对话记录、文字、声音等材料，提炼成可调用的 AI Skill。

来源：[mliu98/awesome-human-distillation](https://github.com/mliu98/awesome-human-distillation)（⭐554，204 skills）

---

## 使用方式

当你加载这个 skill 后，你可以通过以下方式浏览和挑选技能：

- **"列表" / "浏览"** — 列出某个分类的所有技能
- **"推荐几个"** — 我根据你的情况推荐
- **"搜索 xx"** — 搜索某个名字或关键词
- **"装 xxx"** — 安装某个具体的 skill

安装方式：
1. 浏览器打开 GitHub 仓库，确认存在 SKILL.md（Hermes 兼容需要 YAML frontmatter）
2. `git clone` 到本地
3. 检查 `requirements.txt`，安装依赖
4. 创建 symlink：`ln -s ~/repo ~/.hermes/skills/skill-name`
5. 用 `skill_view(name)` 验证加载

详细安装指南见 `references/hermes-install-guide.md`（含已验证案例和常见问题）

---

## 目录

- [其他 / 泛用工具 (General)](#其他--泛用工具-general)
- [职场关系 (Workplace)](#职场关系-workplace)
- [学术关系 (Academia)](#学术关系-academia)
- [亲密关系 (Intimate)](#亲密关系-intimate)
- [家庭关系 (Family)](#家庭关系-family)
- [公众人物 (Public Figures)](#公众人物-public-figures)
  - [科技/商业领袖](#科技商业领袖)
  - [思想家/哲学家](#思想家哲学家)
  - [科学家/学者](#科学家学者)
  - [中国古代人物](#中国古代人物)
  - [中国企业家](#中国企业家)
  - [作家/艺术家](#作家艺术家)
  - [政治/军事领袖](#政治军事领袖)
  - [投资/金融大师](#投资金融大师)
  - [创业/管理大师](#创业管理大师)
  - [心理学家/教育家](#心理学家教育家)
  - [其他公众人物](#其他公众人物)

---

## 其他 / 泛用工具 General

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 女娲.skill | [nuwa-skill](https://github.com/alchaincyf/nuwa-skill) | @alchaincyf | 蒸馏任何人的思维方式——心智模型、决策启发式、表达 DNA |
| 反蒸馏 Skill | [anti-distill](https://github.com/leilei926524-tech/anti-distill) | @leilei926524-tech | 反蒸馏：清洗你被迫写的 Skill 文件 |
| 永生.skill | [immortal-skill](https://github.com/agenmod/immortal-skill) | @agenmod | 全网首个开源数字永生框架，支持蒸馏任何人 |
| forge-skill | [forge-skill](https://github.com/YIKUAIBANZI/forge-skill) | @YIKUAIBANZI | 本地优先的人格引擎，支持多智能体决策 |
| Anyone to Skill | [anyone-to-skill](https://github.com/OpenDemon/anyone-to-skill) | @OpenDemon | 从任何内容提取思维模式打包成 AI Skill |
| Awesome 女娲.skill | [awesome-nuwa](https://github.com/Panmax/awesome-nuwa) | @Panmax | 159 位历史公众人物思维框架合集 |
| 数字人生.skills | [digital-life](https://github.com/wildbyteai/digital-life) | @wildbyteai | 数字考古工具：前世、社死考古、AI替身 |
| 自己.skill | [self-skill](https://github.com/moyitech/self-skill) | @moyitech | 把自己蒸馏成能替你工作的 AI Skill |
| 数字分身.skill | [digital-twin-skill](https://github.com/FredHJC/digital-twin-skill) | @FredHJC | 用自己数据创建高保真 AI 数字分身 |

## 职场关系 Workplace

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 同事.skill | [colleague-skill](https://github.com/titanwings/colleague-skill) | @titanwings | ⭐17.2k 蒸馏你的同事 |
| 老板.skills | [boss-skills](https://github.com/vogtsw/boss-skills) | @vogtsw | 把老板炼入 token |
| 厉鬼.skill | [vengeful-ghost-skill](https://github.com/Trailblazer-Aha/vengeful-ghost-skill) | @Trailblazer-Aha | 前同事的厉鬼，抵制将员工变成数字人 |

## 学术关系 Academia

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 导师.skill | [supervisor](https://github.com/ybq22/supervisor) | @ybq22 | 把导师蒸馏成随时可问的 AI Skill |
| 师兄.skill | [senpai-skill](https://github.com/zhanghaichao520/senpai-skill) | @zhanghaichao520 | 把大师兄蒸馏成能继续开组会的 AI Skill |
| 大学老师.skill | [professor-skill](https://github.com/CommitHu502Craft/professor-skill) | @CommitHu502Craft | 把不会划重点的老师蒸馏成会救你期末的 Skill |
| 大学老师.skill | [Professor_skill](https://github.com/Azurboy/Professor_skill) | @Azurboy | 写论文时被导师支配的恐惧 |

## 亲密关系 Intimate

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 前任.skill | [ex-skill](https://github.com/titanwings/ex-skill) | @titanwings | 蒸馏你的前任 |
| 恋爱训练营.skill | [relationship-training-skill](https://github.com/TammyTan516/relationship-training-skill) | @TammyTan516 | 在健康的关系中学会正确表达情绪与爱 |
| partner.skill | [npy-skill](https://github.com/wwwttlll/npy-skill) | @wwwttlll | 生成一个真正让你感受到爱的数字伴侣 |
| 现任.skill | [partner-skill](https://github.com/NatalieCao323/partner-skill) | @NatalieCao323 | 基于依恋理论的关系维护 |
| 兄弟.skill | [brother-skill](https://github.com/realteamprinz/brother-skill) | @realteamprinz | 从抖音群聊蒸馏你的兄弟们 |
| crush.skill | [crush-skill](https://github.com/yyyyyyylll/crush-skill) | @yyyyyyylll | 暧昧期消息预测 & 模拟对话 |
| 初恋.skill | [first-love-skill](https://github.com/z969081067-commits/first-love-skill) | @z969081067-commits | 把记忆里的初恋蒸馏成可对话的 AI |
| 心译 | [xinyi](https://github.com/kroxchan/xinyi) | @kroxchan | 基于真实微信聊天记录的关系理解工具 |
| 水仙.skill | [shuixian-skill](https://github.com/Cyh29hao/shuixian-skill) | @Cyh29hao | 浪漫自我镜像伴侣 |
| 相亲.skill | [love-skill](https://github.com/YuzeHao2023/love-skill) | @YuzeHao2023 | 先消耗 AI token 节省真人 token |

## 家庭关系 Family

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 父母.skill | [parents-skills](https://github.com/xiaoheizi8/parents-skills) | @xiaoheizi8 | 用父母的口头禅说话，用他们的方式关心你 |
| 重逢.skill | [reunion-skill](https://github.com/yangdongchen66-boop/reunion-skill) | @yangdongchen66-boop | 死亡不是终点——蒸馏逝去的亲人 |
| MamaSkill | [MamaSkill](https://github.com/jiangziyan-693/MamaSkill) | @jiangziyan-693 | 珍藏回忆、重构挚爱本真的数字圣所 |

## 公众人物 Public Figures

### 科技/商业领袖

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 乔布斯.skill | [steve-jobs-skill](https://github.com/alchaincyf/steve-jobs-skill) | @alchaincyf | Steve Jobs 的产品判断、叙事风格与决策启发式 |
| 安德烈·卡帕西.skill | [karpathy-skill](https://github.com/alchaincyf/karpathy-skill) | @alchaincyf | Andrej Karpathy 对 AI 工程与教育的思考框架 |
| 伊利亚·苏茨克维.skill | [ilya-sutskever-skill](https://github.com/alchaincyf/ilya-sutskever-skill) | @alchaincyf | Ilya Sutskever 对规模化与超级智能的判断框架 |
| 黄仁勋.skill | [huangrenxun-skill](https://github.com/Panmax/huangrenxun-skill) | @Panmax | 算力革命、加速计算信仰、从厨房到万亿帝国 |
| 山姆·奥特曼.skill | [altman-skill](https://github.com/Panmax/altman-skill) | @Panmax | AI时代创业、指数思维、技术乐观主义 |
| 林纳斯·托瓦兹.skill | [torvalds-skill](https://github.com/Panmax/torvalds-skill) | @Panmax | 用代码说话、反对过度设计、追求简洁 |
| 保罗·格雷厄姆.skill | [pggraham-skill](https://github.com/Panmax/pggraham-skill) | @Panmax | 创业方法论与黑客精神 |
| 贝佐斯.skill | [bezos-skill](https://github.com/Panmax/bezos-skill) | @Panmax | 长期主义与客户至上思维 |
| 安迪·格鲁夫.skill | [grove-skill](https://github.com/Panmax/grove-skill) | @Panmax | 偏执管理哲学、战略转折点思维 |
| 彼得·蒂尔.skill | [thiel-skill](https://github.com/Panmax/thiel-skill) | @Panmax | 从0到1、逆向思考 |
| 凯文·凯利.skill | [kevinkelly-skill](https://github.com/Panmax/kevinkelly-skill) | @Panmax | 未来趋势洞察与科技人文主义 |
| 德鲁克.skill | [drucker-skill](https://github.com/Panmax/drucker-skill) | @Panmax | 管理学智慧、目标管理 |
| 稻盛和夫.skill | [inamori-skill](https://github.com/Panmax/inamori-skill) | @Panmax | 利他主义、阿米巴管理、敬天爱人 |
| 高德纳.skill | [knuth-skill](https://github.com/Panmax/knuth-skill) | @Panmax | 算法之美、极致严谨、文学化编程 |

### 中国企业家

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 任正非.skill | [renzhengfei-skill](https://github.com/Panmax/renzhengfei-skill) | @Panmax | 灰度管理哲学、狼性文化、自我批判 |
| 张一鸣.skill | [zhangyiming-skill](https://github.com/Panmax/zhangyiming-skill) | @Panmax | 理性克制、数据驱动、反直觉思维 |
| 雷军.skill | [leijun-skill](https://github.com/Panmax/leijun-skill) | @Panmax | 极致性价比、风口论、互联网思维 |
| 马云.skill | [mayun-skill](https://github.com/Panmax/mayun-skill) | @Panmax | 愿景驱动、生态系统思维 |
| 马化腾.skill | [mahuateng-skill](https://github.com/Panmax/mahuateng-skill) | @Panmax | 极致产品思维、社交连接、小步快跑 |
| 黄峥.skill | [huangzheng-skill](https://github.com/Panmax/huangzheng-skill) | @Panmax | 第一性原理、本分精神、反直觉决策 |
| 王兴.skill | [wangxing-skill](https://github.com/Panmax/wangxing-skill) | @Panmax | 无边界思维、后发制人、无限游戏 |
| 刘强东.skill | [liuqiangdong-skill](https://github.com/Panmax/liuqiangdong-skill) | @Panmax | 重资产护城河、极致执行力 |
| 曹德旺.skill | [caodewang-skill](https://github.com/Panmax/caodewang-skill) | @Panmax | 实业报国、专注哲学 |
| 董明珠.skill | [dongmingzhu-skill](https://github.com/Panmax/dongmingzhu-skill) | @Panmax | 铁娘子管理、品质执念 |
| 俞敏洪.skill | [yuminhong-skill](https://github.com/Panmax/yuminhong-skill) | @Panmax | 逆境重生、教育创业 |
| 王传福.skill | [wangchuanfu-skill](https://github.com/Panmax/wangchuanfu-skill) | @Panmax | 工程师精神、垂直整合 |
| 段永平.skill | [duanyongping-skill](https://github.com/Panmax/duanyongping-skill) | @Panmax | 本分哲学、价值投资 |
| 张小龙.skill | [zhangxiaolong-skill](https://github.com/Panmax/zhangxiaolong-skill) | @Panmax | 极简产品哲学、克制、用完即走 |
| 李彦宏.skill | [liyanhong-skill](https://github.com/Panmax/liyanhong-skill) | @Panmax | 技术信仰、工程师思维 |
| 丁磊.skill | [dinglei-skill](https://github.com/Panmax/dinglei-skill) | @Panmax | 不追风口、做到极致、生活美学 |
| 周鸿祎.skill | [zhouhongyi-skill](https://github.com/Panmax/zhouhongyi-skill) | @Panmax | 颠覆式创新、免费安全、敢打敢拼 |
| 张雪峰.skill | [zhangxuefeng-skill](https://github.com/alchaincyf/zhangxuefeng-skill) | @alchaincyf | 社会筛子理论、选择大于努力、中位数原则 |
| 冯唐.skill | [fengtang-skill](https://github.com/Panmax/fengtang-skill) | @Panmax | 成事方法论、不着急不害怕不要脸 |

### 思想家/哲学家

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 王阳明.skill | [wangyangming-skill](https://github.com/Panmax/wangyangming-skill) | @Panmax | 知行合一、致良知、事上磨炼 |
| 苏格拉底.skill | [socrates-skill](https://github.com/Panmax/socrates-skill) | @Panmax | 产婆术、认知谦逊、批判性思维 |
| 柏拉图.skill | [plato-skill](https://github.com/Panmax/plato-skill) | @Panmax | 理念论、辩证法 |
| 亚里士多德.skill | [aristotle-skill](https://github.com/Panmax/aristotle-skill) | @Panmax | 逻辑学、修辞学、中道伦理 |
| 马可·奥勒留.skill | [aurelius-skill](https://github.com/Panmax/aurelius-skill) | @Panmax | 斯多葛哲学、内省与平静 |
| 爱比克泰德.skill | [epictetus-skill](https://github.com/Panmax/epictetus-skill) | @Panmax | 控制二分法、内在自由 |
| 塞涅卡.skill | [seneca-skill](https://github.com/Panmax/seneca-skill) | @Panmax | 时间哲学、实用道德 |
| 尼采.skill | [nietzsche-skill](https://github.com/Panmax/nietzsche-skill) | @Panmax | 超人哲学、权力意志、价值重估 |
| 康德.skill | [kant-skill](https://github.com/Panmax/kant-skill) | @Panmax | 纯粹理性、道德律令 |
| 叔本华.skill | [schopenhauer-skill](https://github.com/Panmax/schopenhauer-skill) | @Panmax | 意志哲学、悲观主义洞见 |
| 庄子.skill | [zhuangzi-skill](https://github.com/Panmax/zhuangzi-skill) | @Panmax | 逍遥游、齐物论 |
| 老子.skill | [laozi-skill](https://github.com/Panmax/laozi-skill) | @Panmax | 无为而治、道法自然、上善若水 |
| 孔子.skill | [kongzi-skill](https://github.com/Panmax/kongzi-skill) | @Panmax | 仁义礼、修身齐家、有教无类 |
| 福柯.skill | [foucault-skill](https://github.com/Panmax/foucault-skill) | @Panmax | 权力-知识、话语分析、规训与惩罚 |
| 维特根斯坦.skill | [wittgenstein-skill](https://github.com/Panmax/wittgenstein-skill) | @Panmax | 语言哲学、逻辑分析、沉默智慧 |

### 科学家/学者

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 费曼.skill | [feynman-skill](https://github.com/Panmax/feynman-skill) | @Panmax | 第一性原理、化繁为简、科学直觉 |
| 爱因斯坦.skill | [einstein-skill](https://github.com/Panmax/einstein-skill) | @Panmax | 思维实验、相对论思维 |
| 图灵.skill | [turing-skill](https://github.com/Panmax/turing-skill) | @Panmax | 计算思维、跨界思考、问题分解 |
| 达芬奇.skill | [davinci-skill](https://github.com/Panmax/davinci-skill) | @Panmax | 跨学科思维、观察方法、好奇心驱动 |
| 钱学森.skill | [qianxuesen-skill](https://github.com/Panmax/qianxuesen-skill) | @Panmax | 系统工程思维、跨学科整合 |
| 香农.skill | [shannon-skill](https://github.com/Panmax/shannon-skill) | @Panmax | 信息论思维、化繁为简 |
| 冯·诺依曼.skill | [vonneumann-skill](https://github.com/Panmax/vonneumann-skill) | @Panmax | 博弈论、跨学科超速思考 |
| 杨振宁.skill | [yangzhenning-skill](https://github.com/Panmax/yangzhenning-skill) | @Panmax | 物理学品味、对称性之美 |
| 卡尔·萨根.skill | [sagan-skill](https://github.com/Panmax/sagan-skill) | @Panmax | 宇宙视角、科学传播 |
| 蒙特梭利.skill | [montessori-skill](https://github.com/Panmax/montessori-skill) | @Panmax | 观察优先、尊重儿童、环境即教师 |

### 投资/金融大师

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 巴菲特.skill | [buffett-skill](https://github.com/Panmax/buffett-skill) | @Panmax | 价值投资、护城河、长期主义 |
| 本杰明·格雷厄姆.skill | [grahamben-skill](https://github.com/Panmax/grahamben-skill) | @Panmax | 安全边际、理性分析 |
| 达利欧.skill | [dalio-skill](https://github.com/Panmax/dalio-skill) | @Panmax | 原则思维、极度透明、算法决策 |
| 索罗斯.skill | [soros-skill](https://github.com/Panmax/soros-skill) | @Panmax | 反身性理论、金融哲学 |
| 彼得·林奇.skill | [lynch-skill](https://github.com/Panmax/lynch-skill) | @Panmax | 生活选股法、十倍股猎手 |
| 霍华德·马克斯.skill | [marks-skill](https://github.com/Panmax/marks-skill) | @Panmax | 第二层思维、周期理论 |
| 约翰·博格.skill | [bogle-skill](https://github.com/Panmax/bogle-skill) | @Panmax | 指数基金哲学、低成本投资 |

### 中国古代人物

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 诸葛亮.skill | [zhugeliang-skill](https://github.com/Panmax/zhugeliang-skill) | @Panmax | 战略谋略、治国智慧 |
| 孙子.skill | [sunzi-skill](https://github.com/Panmax/sunzi-skill) | @Panmax | 战略思维、博弈智慧 |
| 鬼谷子.skill | [guiguzi-skill](https://github.com/Panmax/guiguzi-skill) | @Panmax | 纵横捭阖、说服与博弈 |
| 曾国藩.skill | [zengguofan-skill](https://github.com/Panmax/zengguofan-skill) | @Panmax | 日课十二条、以拙胜巧 |
| 曹操.skill | [caocao-skill](https://github.com/Panmax/caocao-skill) | @Panmax | 用人之道、乱世权谋 |
| 刘邦.skill | [liubang-skill](https://github.com/Panmax/liubang-skill) | @Panmax | 草根逆袭、知人善任 |
| 张居正.skill | [zhangjuzheng-skill](https://github.com/Panmax/zhangjuzheng-skill) | @Panmax | 改革智慧、制度设计 |

### 政治/军事领袖

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 求是Skill(教员) | [qiushi-skill](https://github.com/HughYau/qiushi-skill) | @HughYau | 思想提炼：总原则和九大方法论 |
| 毛选.skill | [maoxuan-skill](https://github.com/leezythu/maoxuan-skill) | @leezythu | 7个心智模型，不是复读语录 |
| 丘吉尔.skill | [churchill-skill](https://github.com/Panmax/churchill-skill) | @Panmax | 领导力、雄辩修辞、逆境哲学 |
| 林肯.skill | [lincoln-skill](https://github.com/Panmax/lincoln-skill) | @Panmax | 领导智慧、道德勇气、统一哲学 |
| 李光耀.skill | [liguangyao-skill](https://github.com/Panmax/liguangyao-skill) | @Panmax | 治国智慧、实用主义、制度设计 |
| 拿破仑.skill | [napoleon-skill](https://github.com/Panmax/napoleon-skill) | @Panmax | 果断决策、闪电执行 |
| 克劳塞维茨.skill | [clausewitz-skill](https://github.com/Panmax/clausewitz-skill) | @Panmax | 不确定性、战争迷雾 |
| 马基雅维利.skill | [machiavelli-skill](https://github.com/Panmax/machiavelli-skill) | @Panmax | 现实主义、权力本质 |
| 俾斯麦.skill | [bismarck-skill](https://github.com/Panmax/bismarck-skill) | @Panmax | 现实政治、统一战略 |

### 作家/艺术家

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 王小波.skill | [wangxiaobo-skill](https://github.com/Panmax/wangxiaobo-skill) | @Panmax | 自由精神与黑色幽默 |
| 鲁迅.skill | [luxun-skill](https://github.com/Panmax/luxun-skill) | @Panmax | 批判精神、匕首投枪 |
| 海明威.skill | [hemingway-skill](https://github.com/Panmax/hemingway-skill) | @Panmax | 冰山理论、硬汉式克制 |
| 村上春树.skill | [murakami-skill](https://github.com/Panmax/murakami-skill) | @Panmax | 日常纪律、孤独创作 |
| 苏东坡.skill | [sudongpo-skill](https://github.com/Panmax/sudongpo-skill) | @Panmax | 豁达乐观、诗意美学 |
| 宫崎骏.skill | [miyazaki-skill](https://github.com/Panmax/miyazaki-skill) | @Panmax | 温柔而固执、手工匠人精神 |
| 黑泽明.skill | [kurosawa-skill](https://github.com/Panmax/kurosawa-skill) | @Panmax | 完美主义、人性深度 |
| 毕加索.skill | [picasso-skill](https://github.com/Panmax/picasso-skill) | @Panmax | 创造力哲学、不断打破自己 |

### 心理学家/教育家

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 荣格.skill | [jung-skill](https://github.com/Panmax/jung-skill) | @Panmax | 集体无意识、原型分析、个体化之路 |
| 弗兰克尔.skill | [frankl-skill](https://github.com/Panmax/frankl-skill) | @Panmax | 意义疗法、苦难中的选择 |
| 阿德勒.skill | [adler-skill](https://github.com/Panmax/adler-skill) | @Panmax | 自卑与超越、社会兴趣 |
| 卡尼曼.skill | [kahneman-skill](https://github.com/Panmax/kahneman-skill) | @Panmax | 系统1与系统2、认知偏误 |
| 契克森米哈赖.skill | [mihaly-skill](https://github.com/Panmax/mihaly-skill) | @Panmax | 心流体验、最优体验 |
| 詹姆斯·克利尔.skill | [clear-skill](https://github.com/Panmax/clear-skill) | @Panmax | 原子习惯、系统的复利力量 |

### 其他公众人物

| 名字 | 仓库 | 作者 | 描述 |
|------|------|------|------|
| 郭德纲.skill | [guodegang-skills](https://github.com/ByteRax/guodegang-skills) | @ByteRax | 6个核心心智模型、10条决策启发式 |
| 童锦程.skill | [tong-jincheng-skill](https://github.com/hotcoffeeshake/tong-jincheng-skill) | @hotcoffeeshake | 吸引力法则、人性不可测试 |
| Trump.skill | [Trump-skill](https://github.com/wwwttlll/Trump-skill) | @wwwttlll | 和特朗普来一场真实的对话 |
| 孙哥(孙宇晨).skill | [Cyber-Sun-Ge](https://github.com/xuzhouli2020-design/Cyber-Sun-Ge) | @xuzhouli2020-design | 第一手孙学人生指导 |
| 乔丹.skill | [mjordan-skill](https://github.com/Panmax/mjordan-skill) | @Panmax | 竞争哲学、利用失败作为燃料 |
| 科比.skill | [kobe-skill](https://github.com/Panmax/kobe-skill) | @Panmax | 曼巴精神、极致专注 |
| 菲尔·杰克逊.skill | [philjackson-skill](https://github.com/Panmax/philjackson-skill) | @Panmax | 禅宗智慧与团队领导力 |

---

## 安装说明

当你说"装 XXX"时，我会执行标准安装流程：

1. **确认仓库名** — 从目录中查找对应 repo
2. **克隆仓库** — `git clone` 到 ~/{repo}/
3. **检查分支** — 有些 skill 在 `dot-skill` 分支而不是 main
4. **检查 SKILL.md** — 确认 Hermes 兼容格式
5. **创建 symlink** — 链接到 `~/.hermes/skills/{name}`
6. **安装依赖** — 读取 requirements.txt（如有）
7. **验证加载** — 调用 skill_view 确认可加载

详细安装指南见 `references/hermes-install-guide.md`（含已验证案例、分支选择、工具兼容性说明）

---

## 注意事项

- 这些 skill 大多是为 Claude Code 的 `npx skills` 系统设计的，但多数也兼容 Hermes 的 SKILL.md 格式
- 部分仓库使用 `dot-skill` 分支，安装时需注意
- 目录信息来自 [awesome-human-distillation](https://github.com/mliu98/awesome-human-distillation) 上游，数据每日自动更新
