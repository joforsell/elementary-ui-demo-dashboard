import Elementary
import ElementaryUI

/// Type-safe CSS helpers for common styling patterns.
///
/// ## Disclaimer
/// This is a half-assed, AI assisted attempt at making common CSS rules type safe and enabling member access. Doesn't it look just a little more Swifty though?
///
/// Sincere apologies to anyone who actually knows CSS and has to tread through this, though it's completely optional of course!

// MARK: - ColorToken

/// Typed CSS color variable tokens matching the `--color-*` design tokens in ContentView.
public enum ColorToken: String {
    case bg
    case bgSecondary = "bg-secondary"
    case border
    case text
    case textMuted = "text-muted"
    case textSecondary = "text-secondary"
    case accent
    case error

    /// CSS value for use in inline styles, e.g. in batched `.styles(...)`.
    public var css: String { "var(--color-\(rawValue))" }
}

// MARK: - Length

/// A CSS length or keyword value usable wherever a CSS `<length-percentage>` or `auto` is valid.
///
/// rem/em values are stored as ten-thousandths (×10000) of a unit to avoid
/// Double → String interpolation, which is unreliable in the embedded Wasm toolchain.
/// Use the static factory methods `.rem(_:)` and `.em(_:)` which accept `Double`.
public enum Length {
    case auto
    case px(Int)
    /// Stored as ten-thousandths of a rem (e.g. 1.25rem → 12500).
    case rem(Int)
    /// Stored as ten-thousandths of an em (e.g. -0.02em → -200).
    case em(Int)
    case percent(Int)
    case vh(Int)
    case vw(Int)
    case _raw(String)

    var css: String {
        switch self {
        case .auto:              return "auto"
        case let .px(n):         return "\(n)px"
        case let .rem(n):        return fractionalCSS(n, scale: 10000, unit: "rem")
        case let .em(n):         return fractionalCSS(n, scale: 10000, unit: "em")
        case let .percent(n):    return "\(n)%"
        case let .vh(n):         return "\(n)vh"
        case let .vw(n):         return "\(n)vw"
        case let ._raw(s):       return s
        }
    }

    public static func rem(_ value: Double) -> Length { .rem(Int((value * 10000).rounded())) }
    public static func em(_ value: Double) -> Length  { .em(Int((value * 10000).rounded())) }

    static func clamp(min: Length, ideal: Length, max: Length) -> Length {
        ._raw("clamp(\(min.css),\(ideal.css),\(max.css))")
    }
}

/// Converts a scaled integer back to a CSS decimal string without using Double interpolation.
/// e.g. scale=10000, n=12500 → "1.25", n=10000 → "1", n=-200 → "-0.02"
private func fractionalCSS(_ n: Int, scale: Int, unit: String) -> String {
    let whole = n / scale
    let frac  = n % scale
    guard frac != 0 else { return "\(whole)\(unit)" }
    let negative = n < 0
    let absWhole = negative ? -whole : whole
    let absFrac  = negative ? -frac  : frac
    let sign     = negative ? "-" : ""
    // Format fractional part with correct decimal places (scale has 4 digits → 4 decimal places).
    // Pad with leading zeros then trim trailing zeros so 200 → "02" (for 0.02), 7500 → "75" (for 0.75).
    let decimalDigits = 4
    var temp = absFrac
    var fracDigits = 0
    while temp > 0 { fracDigits += 1; temp /= 10 }
    if fracDigits == 0 { fracDigits = 1 }
    let padCount = decimalDigits - fracDigits
    let padded = (padCount > 0 ? String(repeating: "0", count: padCount) : "") + String(absFrac)
    var trimEnd = padded.count
    while trimEnd > 1 && padded[padded.index(padded.startIndex, offsetBy: trimEnd - 1)] == "0" {
        trimEnd -= 1
    }
    let fracStr = trimEnd > 0 ? String(padded.prefix(trimEnd)) : "0"
    return "\(sign)\(absWhole).\(fracStr)\(unit)"
}

// MARK: - Supporting enums

public enum Display: String {
    case flex, block, grid, none
    case inlineFlex = "inline-flex"
    case inlineBlock = "inline-block"
}

public enum AlignItems: String {
    case center, start, end, stretch, baseline
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
}

public enum JustifyContent: String {
    case center, start, end, stretch
    case spaceBetween = "space-between"
    case spaceAround = "space-around"
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
}

public enum TextAlign: String {
    case left, right, center, justify
}

public enum TextTransform: String {
    case uppercase, lowercase, capitalize, none
}

public enum Cursor: String {
    case pointer, auto, none
    case notAllowed = "not-allowed"
    case grab, grabbing
    case crosshair, wait
}

public enum BorderValue {
    case none
    case solid(width: Int, color: ColorToken)

    static func solid(color: ColorToken) -> BorderValue { .solid(width: 1, color: color) }

    var css: String {
        switch self {
        case .none: return "none"
        case let .solid(width, color): return "\(width)px solid var(--color-\(color.rawValue))"
        }
    }
}

public enum OutlineValue {
    case none
    case auto

    var css: String {
        switch self {
        case .none: return "none"
        case .auto: return "auto"
        }
    }
}

public enum ShadowColor {
    /// alpha is stored as ten-thousandths (e.g. 0.12 → 1200).
    case rgb(r: Int, g: Int, b: Int, alpha: Int)
    case token(ColorToken)

    public static func rgb(r: Int, g: Int, b: Int, alpha: Double) -> ShadowColor {
        .rgb(r: r, g: g, b: b, alpha: Int((alpha * 10000).rounded()))
    }

    var css: String {
        switch self {
        case let .rgb(r, g, b, alpha): return "rgba(\(r),\(g),\(b),\(fractionalCSS(alpha, scale: 10000, unit: "")))"
        case let .token(token):        return "var(--color-\(token.rawValue))"
        }
    }
}

public enum FontWeight: CustomStringConvertible {
    case thin, extraLight, light, regular, medium, semiBold, bold, extraBold, black
    case numeric(Int)

    public var description: String {
        switch self {
        case .thin:       return "100"
        case .extraLight: return "200"
        case .light:      return "300"
        case .regular:    return "400"
        case .medium:     return "500"
        case .semiBold:   return "600"
        case .bold:       return "700"
        case .extraBold:  return "800"
        case .black:      return "900"
        case .numeric(let n): return "\(n)"
        }
    }
}

// MARK: - Type-safe style declarations (WASM-safe single attribute)

/// Padding: one value (all), two (v h), three (t h b), four (t r b l), or one edge.
public enum PaddingValue {
    case all(Length)
    case two(Length, Length)
    case three(Length, Length, Length)
    case four(Length, Length, Length, Length)
    case top(Length), bottom(Length), left(Length), right(Length)
    var css: String {
        switch self {
        case .all(let a): return "padding:\(a.css)"
        case .two(let a, let b): return "padding:\(a.css) \(b.css)"
        case .three(let a, let b, let c): return "padding:\(a.css) \(b.css) \(c.css)"
        case .four(let a, let b, let c, let d): return "padding:\(a.css) \(b.css) \(c.css) \(d.css)"
        case .top(let v): return "padding-top:\(v.css)"
        case .bottom(let v): return "padding-bottom:\(v.css)"
        case .left(let v): return "padding-left:\(v.css)"
        case .right(let v): return "padding-right:\(v.css)"
        }
    }
}

/// Margin: one value (all), two (v h), three (t h b), four (t r b l), or one edge.
public enum MarginValue {
    case all(Length)
    case two(Length, Length)
    case three(Length, Length, Length)
    case four(Length, Length, Length, Length)
    case top(Length), bottom(Length), left(Length), right(Length)
    var css: String {
        switch self {
        case .all(let a): return "margin:\(a.css)"
        case .two(let a, let b): return "margin:\(a.css) \(b.css)"
        case .three(let a, let b, let c): return "margin:\(a.css) \(b.css) \(c.css)"
        case .four(let a, let b, let c, let d): return "margin:\(a.css) \(b.css) \(c.css) \(d.css)"
        case .top(let v): return "margin-top:\(v.css)"
        case .bottom(let v): return "margin-bottom:\(v.css)"
        case .left(let v): return "margin-left:\(v.css)"
        case .right(let v): return "margin-right:\(v.css)"
        }
    }
}

/// A single CSS declaration with the correct value type for each property.
/// Use with `.styles { ... }` to apply many styles in one attribute and avoid deep generic nesting in WASM.
public enum StyleDeclaration {
    case padding(PaddingValue)
    case margin(MarginValue)
    case width(Length)
    case height(Length)
    case minWidth(Length)
    case maxWidth(Length)
    case minHeight(Length)
    case maxHeight(Length)
    case borderRadius(Length)
    case fontSize(Length)
    case fontWeight(FontWeight)
    case fontDisplay
    case color(ColorToken)
    case textAlign(TextAlign)
    case letterSpacing(Length)
    case lineHeight(Double)
    case textTransform(TextTransform)
    case display(Display)
    case alignItems(AlignItems)
    case justifyContent(JustifyContent)
    case backgroundColor(ColorToken)
    case border(BorderValue)
    case outline(OutlineValue)
    case cursor(Cursor)
    case boxShadow(x: Int, y: Int, blur: Int, spread: Int, color: ShadowColor)
    /// One-off CSS property (e.g. "border-bottom", "opacity") when no typed case exists.
    case custom(key: String, value: String)

    var cssFragment: String {
        switch self {
        case .padding(let p): return p.css
        case .margin(let m): return m.css
        case .width(let v): return "width:\(v.css)"
        case .height(let v): return "height:\(v.css)"
        case .minWidth(let v): return "min-width:\(v.css)"
        case .maxWidth(let v): return "max-width:\(v.css)"
        case .minHeight(let v): return "min-height:\(v.css)"
        case .maxHeight(let v): return "max-height:\(v.css)"
        case .borderRadius(let v): return "border-radius:\(v.css)"
        case .fontSize(let v): return "font-size:\(v.css)"
        case .fontWeight(let w): return "font-weight:\(w.description)"
        case .fontDisplay: return "font-family:var(--font-display)"
        case .color(let t): return "color:\(t.css)"
        case .textAlign(let a): return "text-align:\(a.rawValue)"
        case .letterSpacing(let v): return "letter-spacing:\(v.css)"
        case .lineHeight(let v):
            let n = Int((v * 10000).rounded())
            return "line-height:\(fractionalCSS(n, scale: 10000, unit: ""))"
        case .textTransform(let t): return "text-transform:\(t.rawValue)"
        case .display(let d): return "display:\(d.rawValue)"
        case .alignItems(let a): return "align-items:\(a.rawValue)"
        case .justifyContent(let j): return "justify-content:\(j.rawValue)"
        case .backgroundColor(let t): return "background-color:\(t.css)"
        case .border(let b): return "border:\(b.css)"
        case .outline(let o): return "outline:\(o.css)"
        case .cursor(let c): return "cursor:\(c.rawValue)"
        case .boxShadow(let x, let y, let blur, let spread, let color):
            return "box-shadow:\(x)px \(y)px \(blur)px \(spread)px \(color.css)"
        case .custom(let key, let value): return "\(key):\(value)"
        }
    }
}

// MARK: - Variadic convenience (padding/margin with 1–4 Lengths)

public extension StyleDeclaration {
    /// Padding: 1 value (all edges), or 2/3/4 values (CSS shorthand). True variadic – try building for WASM.
    static func padding(_ lengths: Length...) -> StyleDeclaration {
        switch lengths.count {
        case 0: return .padding(.all(.px(0)))
        case 1: return .padding(.all(lengths[0]))
        case 2: return .padding(.two(lengths[0], lengths[1]))
        case 3: return .padding(.three(lengths[0], lengths[1], lengths[2]))
        default: return .padding(.four(lengths[0], lengths[1], lengths[2], lengths[3]))
        }
    }

    /// Margin: 1 value (all edges), or 2/3/4 values (CSS shorthand). True variadic – try building for WASM.
    static func margin(_ lengths: Length...) -> StyleDeclaration {
        switch lengths.count {
        case 0: return .margin(.all(.px(0)))
        case 1: return .margin(.all(lengths[0]))
        case 2: return .margin(.two(lengths[0], lengths[1]))
        case 3: return .margin(.three(lengths[0], lengths[1], lengths[2]))
        default: return .margin(.four(lengths[0], lengths[1], lengths[2], lengths[3]))
        }
    }
}

// MARK: - View modifiers (chainable, SwiftUI-style)

public extension View where Tag: HTMLTrait.Attributes.Global {

    // MARK: Batched style (WASM-safe: one attributes layer per element)

    /// Applies multiple type-safe style declarations in a single `style` attribute (variadic).
    /// e.g. `.styles(.fontSize(.rem(1)), .color(.text), .margin(.px(0), .auto))`
    func styles(_ declarations: StyleDeclaration...) -> some View<Tag> {
        let merged = declarations.map(\.cssFragment).joined(separator: "; ")
        return attributes(.style(merged))
    }

    /// Applies style declarations from a dynamic array (e.g. built in a loop or conditionally).
    func styles(_ declarations: [StyleDeclaration]) -> some View<Tag> {
        let merged = declarations.map(\.cssFragment).joined(separator: "; ")
        return attributes(.style(merged))
    }

    /// Applies raw key-value CSS in a single `style` attribute (use when no typed declaration exists).
    func styles(_ pairs: KeyValuePairs<String, String>) -> some View<Tag> {
        let merged = pairs.map { "\($0.key):\($0.value)" }.joined(separator: "; ")
        return attributes(.style(merged))
    }

    // MARK: Spacing

    /// Sets a single `padding-*` edge. e.g. `.padding(top: .rem(1))`, `.padding(bottom: .rem(0.5))`
    func padding(top value: Length) -> some View<Tag> { attributes(.style("padding-top:\(value.css)")) }
    func padding(bottom value: Length) -> some View<Tag> { attributes(.style("padding-bottom:\(value.css)")) }
    func padding(left value: Length) -> some View<Tag> { attributes(.style("padding-left:\(value.css)")) }
    func padding(right value: Length) -> some View<Tag> { attributes(.style("padding-right:\(value.css)")) }

    /// Sets `padding`. e.g. `.padding(.rem(1.5))` or `.padding(.rem(0.75), .rem(1))`
    func padding(_ a: Length) -> some View<Tag> { attributes(.style("padding:\(a.css)")) }
    func padding(_ a: Length, _ b: Length) -> some View<Tag> { attributes(.style("padding:\(a.css) \(b.css)")) }
    func padding(_ a: Length, _ b: Length, _ c: Length) -> some View<Tag> { attributes(.style("padding:\(a.css) \(b.css) \(c.css)")) }
    func padding(_ a: Length, _ b: Length, _ c: Length, _ d: Length) -> some View<Tag> { attributes(.style("padding:\(a.css) \(b.css) \(c.css) \(d.css)")) }

    /// Sets a single `margin-*` edge. e.g. `.margin(top: .rem(1))`, `.margin(bottom: .rem(0.5))`
    func margin(top value: Length) -> some View<Tag> { attributes(.style("margin-top:\(value.css)")) }
    func margin(bottom value: Length) -> some View<Tag> { attributes(.style("margin-bottom:\(value.css)")) }
    func margin(left value: Length) -> some View<Tag> { attributes(.style("margin-left:\(value.css)")) }
    func margin(right value: Length) -> some View<Tag> { attributes(.style("margin-right:\(value.css)")) }

    /// Sets `margin`. e.g. `.margin(.px(0), .auto)` or `.margin(.rem(1))`
    func margin(_ a: Length) -> some View<Tag> { attributes(.style("margin:\(a.css)")) }
    func margin(_ a: Length, _ b: Length) -> some View<Tag> { attributes(.style("margin:\(a.css) \(b.css)")) }
    func margin(_ a: Length, _ b: Length, _ c: Length) -> some View<Tag> { attributes(.style("margin:\(a.css) \(b.css) \(c.css)")) }
    func margin(_ a: Length, _ b: Length, _ c: Length, _ d: Length) -> some View<Tag> { attributes(.style("margin:\(a.css) \(b.css) \(c.css) \(d.css)")) }

    // MARK: Sizing

    /// Sets `width`. e.g. `.width(.percent(100))` or `.width(.px(380))`
    func width(_ value: Length) -> some View<Tag> {
        attributes(.style("width:\(value.css)"))
    }

    /// Sets `height`. e.g. `.height(.px(80))`
    func height(_ value: Length) -> some View<Tag> {
        attributes(.style("height:\(value.css)"))
    }

    /// Sets `min-width`. e.g. `.minWidth(.px(200))`
    func minWidth(_ value: Length) -> some View<Tag> {
        attributes(.style("min-width:\(value.css)"))
    }

    /// Sets `max-width`. e.g. `.maxWidth(.px(1000))`
    func maxWidth(_ value: Length) -> some View<Tag> {
        attributes(.style("max-width:\(value.css)"))
    }

    /// Sets `min-height`. e.g. `.minHeight(.vh(100))`
    func minHeight(_ value: Length) -> some View<Tag> {
        attributes(.style("min-height:\(value.css)"))
    }

    /// Sets `max-height`. e.g. `.maxHeight(.px(400))`
    func maxHeight(_ value: Length) -> some View<Tag> {
        attributes(.style("max-height:\(value.css)"))
    }

    /// Sets `border-radius`. e.g. `.borderRadius(.px(12))`
    func borderRadius(_ value: Length) -> some View<Tag> {
        attributes(.style("border-radius:\(value.css)"))
    }

    // MARK: Typography

    /// Sets `font-size`. e.g. `.fontSize(.rem(1))`
    func fontSize(_ value: Length) -> some View<Tag> {
        attributes(.style("font-size:\(value.css)"))
    }

    /// Sets `font-weight` using a named or numeric weight.
    func fontWeight(_ weight: FontWeight) -> some View<Tag> {
        attributes(.style("font-weight:\(weight)"))
    }

    /// Applies the display font family (`var(--font-display)`).
    func fontDisplay() -> some View<Tag> {
        attributes(.style("font-family:var(--font-display)"))
    }

    /// Sets `color` to a CSS variable token. e.g. `.color(.text)` → `color: var(--color-text)`
    func color(_ token: ColorToken) -> some View<Tag> {
        attributes(.style("color:var(--color-\(token.rawValue))"))
    }

    /// Sets `text-align`. e.g. `.textAlign(.center)`
    func textAlign(_ alignment: TextAlign) -> some View<Tag> {
        attributes(.style("text-align:\(alignment.rawValue)"))
    }

    /// Sets `letter-spacing`. e.g. `.letterSpacing(.em(-0.02))`
    func letterSpacing(_ value: Length) -> some View<Tag> {
        attributes(.style("letter-spacing:\(value.css)"))
    }

    /// Sets `line-height` to a unitless value. Pass ten-thousandths (e.g. 1.1 → use `.lineHeight(1.1)`).
    func lineHeight(_ value: Double) -> some View<Tag> {
        let n = Int((value * 10000).rounded())
        return attributes(.style("line-height:\(fractionalCSS(n, scale: 10000, unit: ""))"))
    }

    /// Sets `text-transform`. e.g. `.textTransform(.uppercase)`
    func textTransform(_ transform: TextTransform) -> some View<Tag> {
        attributes(.style("text-transform:\(transform.rawValue)"))
    }

    // MARK: Layout

    /// Sets `display`. e.g. `.display(.flex)`
    func display(_ value: Display) -> some View<Tag> {
        attributes(.style("display:\(value.rawValue)"))
    }

    /// Sets `align-items`. e.g. `.alignItems(.center)`
    func alignItems(_ value: AlignItems) -> some View<Tag> {
        attributes(.style("align-items:\(value.rawValue)"))
    }

    /// Sets `justify-content`. e.g. `.justifyContent(.spaceBetween)`
    func justifyContent(_ value: JustifyContent) -> some View<Tag> {
        attributes(.style("justify-content:\(value.rawValue)"))
    }

    // MARK: Background & Borders

    /// Sets `background-color` to a CSS variable token.
    func backgroundColor(_ token: ColorToken) -> some View<Tag> {
        attributes(.style("background-color:var(--color-\(token.rawValue))"))
    }

    /// Sets `border`. e.g. `.border(.none)` or `.border(.solid(color: .border))`
    func border(_ value: BorderValue) -> some View<Tag> {
        attributes(.style("border:\(value.css)"))
    }

    /// Sets `outline`. e.g. `.outline(.none)`
    func outline(_ value: OutlineValue) -> some View<Tag> {
        attributes(.style("outline:\(value.css)"))
    }

    /// Sets `cursor`. e.g. `.cursor(.pointer)`
    func cursor(_ value: Cursor) -> some View<Tag> {
        attributes(.style("cursor:\(value.rawValue)"))
    }

    /// Sets `box-shadow`. e.g. `.boxShadow(y: 4, blur: 16, color: .rgb(r: 0, g: 0, b: 0, alpha: 0.12))`
    func boxShadow(x: Int = 0, y: Int = 0, blur: Int = 0, spread: Int = 0, color: ShadowColor) -> some View<Tag> {
        attributes(.style("box-shadow:\(x)px \(y)px \(blur)px \(spread)px \(color.css)"))
    }
}
