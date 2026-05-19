# Technical Thesis Diagrams

SVG diagram patterns for academic papers and technical documentation — ML architecture, system diagrams, and formal notation. Optimized for print (light background) rather than screen (dark mode).

## When to Use

- Academic thesis/dissertation chapters describing ML/AI systems
- Technical papers with architecture diagrams
- Documentation requiring mathematical notation embedded in diagrams
- Clean, publication-ready visuals (white background, professional typography)

**Difference from main concept-diagrams skill:**
- Main skill: educational visuals, dark mode, broad science topics
- This reference: technical software/ML architecture, light theme, publication-ready

## Design System

### Color Palette (Publication-Ready)

| Purpose | Color | Hex |
|---------|-------|-----|
| Input | Light blue | #E3F2FD / #1976D2 |
| Encoder/Processor | Light green | #C8E6C9 / #388E3C |
| Transformer/Core | Light yellow | #FFF3CD / #FBC02D |
| Output | Light red/pink | #FFEBEE / #C62828 |
| Auxiliary | Light gray | #ECEFF1 / #546E7A |
| Highlight/Active | Bright green | #C8E6C9 / #2E7D32 |

### Typography

- Titles: 14px, bold
- Body text: 12px, normal
- Math/formulas: 11px, italic, monospace font hint

### Box Styles

```svg
<!-- Input box -->
<rect fill="#E3F2FD" stroke="#1976D2" stroke-width="2" rx="5"/>

<!-- Processor box -->
<rect fill="#C8E6C9" stroke="#388E3C" stroke-width="2" rx="5"/>

<!-- Core module (highlighted) -->
<rect fill="#FFF3CD" stroke="#FBC02D" stroke-width="2" rx="5"/>

<!-- Output box -->
<rect fill="#FFEBEE" stroke="#C62828" stroke-width="2" rx="5"/>
```

## Common Architecture Patterns

### 1. Multi-Modal Input → Fusion → Output

```svg
<!-- Left: Multiple inputs -->
<rect x="30" y="70" width="100" height="50" fill="#E3F2FD" stroke="#1976D2" stroke-width="2" rx="5"/>
<text x="80" y="95" text-anchor="middle" font-size="12">RGB Image</text>

<rect x="30" y="150" width="100" height="50" fill="#E3F2FD" stroke="#1976D2" stroke-width="2" rx="5"/>
<text x="80" y="175" text-anchor="middle" font-size="12">Text Input</text>

<!-- Arrows to encoders -->
<line x1="130" y1="95" x2="200" y2="95" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="130" y1="175" x2="200" y2="175" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>

<!-- Encoders -->
<rect x="200" y="70" width="140" height="50" fill="#C8E6C9" stroke="#388E3C" stroke-width="2" rx="5"/>
<text x="270" y="95" text-anchor="middle" font-size="12">Encoder 1</text>

<rect x="200" y="150" width="140" height="50" fill="#C8E6C9" stroke="#388E3C" stroke-width="2" rx="5"/>
<text x="270" y="175" text-anchor="middle" font-size="12">Encoder 2</text>

<!-- Arrows to fusion -->
<line x1="340" y1="95" x2="420" y2="140" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="340" y1="175" x2="420" y2="160" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>

<!-- Fusion module -->
<rect x="420" y="110" width="180" height="80" fill="#FFF3CD" stroke="#FBC02D" stroke-width="2" rx="5"/>
<text x="510" y="145" text-anchor="middle" font-size="14" font-weight="bold">Fusion Module</text>
<text x="510" y="170" text-anchor="middle" font-size="11">Transformer / Core</text>

<!-- Output -->
<line x1="600" y1="150" x2="650" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<rect x="650" y="125" width="120" height="50" fill="#FFEBEE" stroke="#C62828" stroke-width="2" rx="5"/>
<text x="710" y="152" text-anchor="middle" font-size="12">Output</text>
```

### 2. Layered Network with Residual Connections

```svg
<!-- Main flow vertical -->
<rect x="350" y="50" width="200" height="60" fill="#FFF3CD" stroke="#FBC02D" stroke-width="2" rx="5"/>
<text x="450" y="85" text-anchor="middle" font-size="13" font-weight="bold">LayerNorm</text>

<rect x="350" y="140" width="200" height="80" fill="#E8F5E9" stroke="#388E3C" stroke-width="2" rx="5"/>
<text x="450" y="170" text-anchor="middle" font-size="13" font-weight="bold">Attention</text>
<text x="450" y="195" text-anchor="middle" font-size="11">8-Head Cross Attention</text>

<rect x="350" y="260" width="200" height="80" fill="#F3E5F5" stroke="#7B1FA2" stroke-width="2" rx="5"/>
<text x="450" y="290" text-anchor="middle" font-size="13" font-weight="bold">MoE-FFN</text>
<text x="450" y="315" text-anchor="middle" font-size="11">Top-1 Sparse Activation</text>

<!-- Vertical arrows -->
<line x1="450" y1="110" x2="450" y2="140" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="450" y1="220" x2="450" y2="260" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="450" y1="340" x2="450" y2="380" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>

<!-- Residual connection (skip) -->
<path d="M 350 80 Q 250 80 250 220 Q 250 360 350 360" fill="none" stroke="#FF9800" stroke-width="2" stroke-dasharray="6,3"/>
<circle cx="380" cy="360" r="12" fill="#FF9800" stroke="#E65100" stroke-width="1.5"/>
<text x="380" y="365" text-anchor="middle" font-size="14" font-weight="bold" fill="white">+</text>

<!-- Label for residual -->
<text x="250" y="280" text-anchor="middle" font-size="11" fill="#FF9800">Residual Connection</text>
```

### 3. Mixture of Experts (MoE) Router

```svg
<!-- Input -->
<rect x="50" y="120" width="100" height="60" fill="#E3F2FD" stroke="#1976D2" stroke-width="2" rx="5"/>
<text x="100" y="145" text-anchor="middle" font-size="12">Token</text>
<text x="100" y="165" text-anchor="middle" font-size="12" font-style="italic">x</text>

<!-- Router -->
<rect x="220" y="110" width="140" height="80" fill="#FFF3E0" stroke="#F57C00" stroke-width="2" rx="5"/>
<text x="290" y="140" text-anchor="middle" font-size="13" font-weight="bold">Router</text>
<text x="290" y="165" text-anchor="middle" font-size="11">g = W_g · x + ε</text>

<!-- Softmax -->
<rect x="420" y="120" width="100" height="60" fill="#FCE4EC" stroke="#C2185B" stroke-width="2" rx="5"/>
<text x="470" y="150" text-anchor="middle" font-size="13" font-weight="bold">Softmax</text>

<!-- Experts container -->
<rect x="200" y="240" width="500" height="150" fill="#FAFAFA" stroke="#424242" stroke-width="2" stroke-dasharray="8,4" rx="10"/>
<text x="450" y="265" text-anchor="middle" font-size="14" font-weight="bold">N Experts (Sparse Activation)</text>

<!-- Individual experts -->
<rect x="230" y="290" width="100" height="60" fill="#E1F5FE" stroke="#0288D1" stroke-width="2" rx="5"/>
<text x="280" y="320" text-anchor="middle" font-size="12">Expert 1</text>

<rect x="360" y="290" width="100" height="60" fill="#C8E6C9" stroke="#2E7D32" stroke-width="3" rx="5"/>
<text x="410" y="315" text-anchor="middle" font-size="12" font-weight="bold">Expert 2</text>
<text x="410" y="335" text-anchor="middle" font-size="10">(Selected)</text>

<rect x="490" y="290" width="100" height="60" fill="#E1F5FE" stroke="#0288D1" stroke-width="2" rx="5"/>
<text x="540" y="320" text-anchor="middle" font-size="12">Expert 3</text>

<text x="630" y="325" text-anchor="middle" font-size="20" fill="#666">...</text>

<rect x="670" y="290" width="100" height="60" fill="#E1F5FE" stroke="#0288D1" stroke-width="2" rx="5"/>
<text x="720" y="320" text-anchor="middle" font-size="12">Expert N</text>

<!-- Arrows from input to experts (dashed for non-selected) -->
<line x1="150" y1="150" x2="220" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="360" y1="150" x2="420" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
<line x1="520" y1="150" x2="580" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>

<!-- Highlight arrow to selected expert -->
<line x1="640" y1="150" x2="640" y2="220" stroke="#333" stroke-width="2"/>
<line x1="640" y1="220" x2="410" y2="220" stroke="#333" stroke-width="2"/>
<line x1="410" y1="220" x2="410" y2="290" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>

<!-- Output -->
<rect x="360" y="430" width="180" height="60" fill="#FFEBEE" stroke="#C62828" stroke-width="2" rx="5"/>
<text x="450" y="455" text-anchor="middle" font-size="13" font-weight="bold">MoE Output</text>
<text x="450" y="475" text-anchor="middle" font-size="11">p_e* · Expert_e*(x)</text>

<line x1="410" y1="350" x2="410" y2="430" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
```

## Mathematical Notation in Diagrams

For inline math in SVG diagrams:

```svg
<!-- Simple variable -->
<text x="100" y="100" font-size="12" font-style="italic">x</text>

<!-- Superscript -->
<text x="100" y="100" font-size="12">h<tspan dy="-5" font-size="9">(l)</tspan></text>

<!-- Subscript -->
<text x="100" y="100" font-size="12">h<tspan dy="3" font-size="9">a</tspan></text>

<!-- Combined -->
<text x="100" y="100" font-size="12">h<tspan dy="-5" font-size="9">(l)</tspan><tspan dy="8" font-size="9">a</tspan></text>
```

## Arrow Marker Definition

Always include this in `<defs>`:

```svg
<defs>
  <marker id="arrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
  </marker>
</defs>

<!-- Usage -->
<line x1="100" y1="100" x2="200" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
```

## Complete Example: Vision-Language Backbone

See `D:\Code\5.22\fig_2_4_1.svg` for a production-ready example featuring:
- Dual encoder inputs (DINOv2 + SigLIP)
- Transformer backbone
- Multi-layer feature extraction
- Multiple output branches
- Clean mathematical notation

## File Organization

When creating diagrams for a thesis chapter:

```
D:\Code\5.22\
├── 2.4.1_expansion.md       # Text content
├── 2.4.2_expansion.md
├── 2.4.3_expansion.md
├── fig_2_4_1.svg           # Architecture diagram
├── fig_2_4_2.svg
└── fig_2_4_3.svg
```

## Inserting into Word

SVG files can be:
1. Dragged directly into Word document
2. Right-click → "Convert to Shape" for editing
3. Adjust figure numbers and captions in Word

## Validation Checklist

Before finalizing:
- [ ] All boxes have consistent stroke width (2px for thesis diagrams)
- [ ] Arrow markers defined and referenced correctly
- [ ] Text is centered within boxes (`text-anchor="middle"`)
- [ ] No overlapping elements
- [ ] Color scheme consistent across all diagrams in chapter
- [ ] Figure size appropriate for page width (typically 800px max)
- [ ] Captions and references updated in main document
