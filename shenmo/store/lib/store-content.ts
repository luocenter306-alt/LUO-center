export const defaultCategories=['AI 对话','AI 绘画','AI 视频','AI 编程','办公效率','设计工具','音视频','远程安装','数字商品'];
export const defaultSiteConfig={version:'initial',brandName:'神墨',heroTitle:'装好 AI，\n即刻开始。',heroSubtitle:'从环境配置，到你的第一次使用。',heroDescription:'主打远程部署与使用指导，具体范围以服务说明为准。',primaryLabel:'预约远程安装',catalogLabel:'浏览商品与服务',installationLabel:'安装服务',hotLabel:'热门商品',installationTitle:'安装这件事，交给我们。',hotTitle:'热门商品，为你精选。',showStage:true,showSelection:true,showGuide:true,hotLimit:4,hiddenProductIds:[] as string[],productOrder:[] as string[],steps:['选择安装服务','支付并填写预约','管理员安排工程师','追踪进度，安心验收'],navigation:[{id:'home',label:'首页',enabled:true},{id:'catalog',label:'商品与服务',enabled:true},{id:'agent',label:'会员中心',enabled:true},{id:'help',label:'帮助中心',enabled:true}]};
export type SiteConfig=typeof defaultSiteConfig;
export const defaultAnnouncement={
 title:'Prome AI 店铺公告', enabled:true, version:'prome-20261016-v1',
 body:`【来源说明】以下为 Prome 上游店铺公告，仅适用于其店铺和对应商品，不代表神墨的交付、退款或代理承诺。神墨首页主推远程安装与使用指导，会员渠道充值与安装服务属于不同服务。

在线客服与服务时间
Prome 公告说明：请点击其网站右下角客服图标。每日 10:00 — 次日 00:00。建议 Ctrl+D 收藏店铺，方便再次访问。

发货与售后
标注“自动发货”的商品，公告称支持 24 小时自动发货；标注“在线发货”的商品需要人工处理。上游公告称：未使用卡密可 24 小时秒退，余额可随时提现。具体适用条件请向上游客服确认，神墨订单按神墨商品说明和售后流程处理。
下单前请完整阅读商品介绍。上游按商品介绍提供售后；遇到问题请联系其在线客服。售后仅处理购买服务相关问题，不发送无关推广信息、不额外引流，保障用户与代理推广体验。

批发与代理合作
上游商务微信：ljc086114（批发 / 合作 / 商务，售后请勿联系）。
上游公告称支持推广合作，绑定订单后可持续获得收益；支付 199 元可升级其店铺代理。此为 Prome 代理权益，非神墨代理费用或收益承诺。详情请访问上游店铺核实。
上游自述日销约 10 万，欢迎 AI 领域 KOL、达人及同行交流合作；该数据未经神墨核实。

服务范围说明
Prome 公告说明：其会员渠道充值服务主要面向海外用户、留学生及境外学习 / 工作场景，暂不支持中国大陆地区用户购买或使用。页面内容仅供学习与交流，请遵守所在地法律法规及相关平台服务条款。`
};
