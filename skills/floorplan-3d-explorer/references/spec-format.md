# 毫米制户型 JSON

模板格式版本为 1。所有坐标、尺寸、高度采用 mm，平面坐标 `[x,z]`，x 向图右、z 向图下；Three.js y 向上。墙端点位于墙中线。旋转为绕向上轴的角度，默认家具正面朝图下。

```json
{
  "version": 1,
  "name": "我的户型",
  "wallHeight": 2800,
  "wallThickness": 180,
  "rooms": [
    {"id":"living","name":"客厅","polygon":[[0,0],[4500,0],[4500,6000],[0,6000]],"floor":"tile","view":{"at":[3000,3000],"lookAt":[1000,4500]}}
  ],
  "walls": [
    {"a":[0,0],"b":[4500,0],"openings":[{"offset":2500,"width":900,"type":"door"}]}
  ],
  "furniture": [
    {"type":"sofa","at":[700,3500],"width":900,"depth":2300,"height":850,"rotation":0}
  ],
  "assumptions": ["墙高 2.8 m 和墙厚 180 mm 为暂定值"]
}
```

`rooms` 至少一个，`id` 唯一。`polygon` 至少 3 个不共线点，按边界顺序，不重复首点；不要自交。`floor` 可为 `tile`、`wood`、`balcony`。`view.at` 应在房间内且避开家具；`lookAt` 是面向的点，两者不能相同。不提供 `view` 时用多边形质心与边界内候选点选择入口，但仍需人工核对狭长或凹形房间。

`walls` 是直线段，可横、竖、斜。可按墙覆盖 `thickness`、`height`。`openings` 的 `offset` 从 `a` 沿墙长量到洞口起点，`width` 为洞宽，不能越界或互相重叠。`type` 为 `door`、`window`、`opening`。默认门/开放洞口 `sill:0, head:2100`，窗 `sill:900, head:2200`；要求 `0≤sill<head≤墙高`。门默认开放，模板不模拟开门扇。

`furniture` 类型：`bed`、`sofa`、`table`、`chair`、`cabinet`、`plant`、`counter`、`sink`、`toilet`。`width/depth/height` 均为正尺寸；可指定 `color`（十六进制颜色）。它们是示意模型，不是 CAD 产品。所有物件中心由 `at` 指定，默认旋转为 0。

可选底图：

```json
"underlay": {"file":"plan.jpg","bounds":[-500,-2000,12500,14000],"opacity":0.65}
```

`file` 相对于 JSON 所在目录，也可使用显式绝对路径；支持 PNG/JPG/WebP。`bounds` 是图像左上角 x/z、覆盖宽度、覆盖进深，采用 mm。构建器把图像字节内嵌，不会上传它。底图不自动识别或校正，需对照墙和门洞核准定位。图像有透视或各轴缩放差异时先说明，不用虚假精度掩盖。

`assumptions` 为字符串列表，直接展示在页面说明中。比例来自估算时必须写明。没有真实北向时不添加指北针，不将模型面积称作实测净面积。
