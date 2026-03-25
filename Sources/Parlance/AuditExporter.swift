import AppKit
import os.log
import ParlanceKit
import UniformTypeIdentifiers

private let logger = Logger(subsystem: "business.parlance.xcode", category: "Export")

enum AuditExporter {

    // MARK: - Public entry points

    static func exportCSV(summary: AuditSummary) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "parlance-audit-\(datestamp()).csv"
        panel.allowedContentTypes = [.commaSeparatedText]
        guard panel.runModal() == .OK, let url = panel.url else { return }

        var lines = ["Rule,Severity,Line,Message,Fix Suggestion"]
        for r in summary.results {
            let lineNum = r.line.map { String($0) } ?? ""
            lines.append([
                csvEscape(r.ruleName),
                csvEscape(r.severity.rawValue),
                lineNum,
                csvEscape(r.message),
                csvEscape(r.fixSuggestion)
            ].joined(separator: ","))
        }
        try? lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    static func exportPDF(summary: AuditSummary) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "parlance-audit-\(datestamp()).pdf"
        panel.allowedContentTypes = [.pdf]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? buildPDF(summary: summary).write(to: url)
    }

    // MARK: - PDF generation

    // All geometry in native PDF coordinates: origin bottom-left, y increases upward.
    private static let pageW: CGFloat = 595
    private static let pageH: CGFloat = 842
    private static let margin: CGFloat = 48
    private static var contentW: CGFloat { pageW - margin * 2 }

    // Palette
    private static let clrError    = NSColor(red: 0.600, green: 0.106, blue: 0.106, alpha: 1) // #991b1b
    private static let clrWarning  = NSColor(red: 0.522, green: 0.302, blue: 0.055, alpha: 1) // #854d0e
    private static let clrInfo     = NSColor(red: 0.086, green: 0.396, blue: 0.204, alpha: 1) // #166534
    private static let clrAccent   = NSColor(red: 0.498, green: 0.467, blue: 0.867, alpha: 1) // #7F77DD
    private static let clrText     = NSColor(red: 0.102, green: 0.102, blue: 0.102, alpha: 1) // #1a1a1a
    private static let clrSec      = NSColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1) // #555555
    private static let clrBorder   = NSColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1) // #d4d4d4
    private static let clrRowBg    = NSColor(white: 0.97, alpha: 1)

    private static func buildPDF(summary: AuditSummary) -> Data {
        let output = NSMutableData()
        var box = CGRect(x: 0, y: 0, width: pageW, height: pageH)
        guard let consumer = CGDataConsumer(data: output),
              let ctx = CGContext(consumer: consumer, mediaBox: &box, nil) else { return Data() }

        let results = summary.results
        var resultIdx = 0
        var pageNum = 0
        let rowH: CGFloat = 64
        let footerReserve: CGFloat = 32

        let dateStr = DateFormatter.localizedString(
            from: summary.timestamp, dateStyle: .long, timeStyle: .none)

        logger.debug("Building PDF with \(results.count) results")

        repeat {
            pageNum += 1
            ctx.beginPDFPage(nil)

            // Set NSGraphicsContext so NSAttributedString.draw works in a CGPDFContext.
            // flipped: true = y=0 is TOP of page. We also apply a matching CTM flip so
            // all CGContext calls (fill, stroke, ellipse) use the same top-down coordinate space.
            let nsContext = NSGraphicsContext(cgContext: ctx, flipped: true)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = nsContext
            ctx.translateBy(x: 0, y: pageH)
            ctx.scaleBy(x: 1, y: -1)

            // cursorY is y measured from the TOP of the page, increasing downward.
            var cursorY: CGFloat = 0

            // ── Header bar ─────────────────────────────────────────────────────────
            let headerH: CGFloat = 36
            fill(ctx, rect(cursorY, w: pageW, h: headerH), color: clrAccent)
            text("Parlance — SwiftUI Accessibility Audit",
                 ctx, r: rect(cursorY + 10, x: margin, w: contentW, h: 16),
                 font: .boldSystemFont(ofSize: 12), color: .white)
            cursorY += headerH + 6

            // ── Date ──────────────────────────────────────────────────────────────
            text(dateStr, ctx, r: rect(cursorY, x: margin, w: contentW, h: 12),
                 font: .systemFont(ofSize: 9), color: clrSec)
            cursorY += 20

            // ── Summary chips (page 1 only) ───────────────────────────────────────
            if pageNum == 1 {
                cursorY += 6
                let chipW = (contentW - 16) / 3
                let chipH: CGFloat = 46
                let chips: [(String, String, NSColor)] = [
                    ("Errors",   "\(summary.errors)",   clrError),
                    ("Warnings", "\(summary.warnings)", clrWarning),
                    ("Score",    "\(summary.score)",    clrAccent)
                ]
                for (i, (label, value, color)) in chips.enumerated() {
                    let cx = margin + CGFloat(i) * (chipW + 8)
                    stroke(ctx, rect(cursorY, x: cx, w: chipW, h: chipH), color: clrBorder, lw: 0.5)
                    text(value, ctx, r: rect(cursorY + 7, x: cx, w: chipW, h: 18),
                         font: .boldSystemFont(ofSize: 14), color: color, align: .center)
                    text(label, ctx, r: rect(cursorY + 28, x: cx, w: chipW, h: 12),
                         font: .systemFont(ofSize: 8), color: clrSec, align: .center)
                }
                cursorY += chipH + 14

                // Section divider
                fill(ctx, rect(cursorY, x: margin, w: contentW, h: 18),
                     color: NSColor(white: 0.95, alpha: 1))
                text("FINDINGS", ctx, r: rect(cursorY + 4, x: margin + 6, w: contentW, h: 11),
                     font: .boldSystemFont(ofSize: 8), color: clrSec)
                cursorY += 25
            } else {
                text("Findings (continued)", ctx,
                     r: rect(cursorY, x: margin, w: contentW, h: 14),
                     font: .boldSystemFont(ofSize: 10), color: clrText)
                cursorY += 22
            }

            // ── Findings rows ────────────────────────────────────────────────────
            while resultIdx < results.count {
                guard cursorY + rowH + footerReserve <= pageH else { break }
                let r = results[resultIdx]
                let dotClr = severityColor(r.severity)

                // Alternating row bg
                if resultIdx.isMultiple(of: 2) {
                    fill(ctx, rect(cursorY, x: margin, w: contentW, h: rowH), color: clrRowBg)
                }
                stroke(ctx, rect(cursorY, x: margin, w: contentW, h: rowH), color: clrBorder, lw: 0.5)

                // Severity dot
                let dotRect = rect(cursorY + 9, x: margin + 8, w: 7, h: 7)
                ctx.setFillColor(dotClr.cgColor)
                ctx.fillEllipse(in: dotRect)

                // Severity label
                text(r.severity.rawValue.uppercased(), ctx,
                     r: rect(cursorY + 8, x: margin + 20, w: 48, h: 10),
                     font: .boldSystemFont(ofSize: 7), color: dotClr)

                // WCAG badge — right aligned
                text("WCAG \(r.wcagCriterion) \(r.wcagLevel)", ctx,
                     r: rect(cursorY + 8, x: margin, w: contentW - 8, h: 10),
                     font: .systemFont(ofSize: 7), color: clrSec, align: .right)

                // Rule name + line ref
                let lineRef = r.line.map { " · Line \($0)" } ?? ""
                text("\(r.ruleName)\(lineRef)", ctx,
                     r: rect(cursorY + 21, x: margin + 8, w: contentW - 16, h: 13),
                     font: .boldSystemFont(ofSize: 9), color: clrText)

                // Message
                text(r.message, ctx,
                     r: rect(cursorY + 36, x: margin + 8, w: contentW - 16, h: 12),
                     font: .systemFont(ofSize: 8), color: clrSec)

                // Fix suggestion
                text("Fix: \(r.fixSuggestion)", ctx,
                     r: rect(cursorY + 50, x: margin + 8, w: contentW - 16, h: 11),
                     font: NSFont(name: "Helvetica Oblique", size: 7.5) ?? .systemFont(ofSize: 7.5),
                     color: clrSec)

                cursorY += rowH + 1
                resultIdx += 1
            }

            // Empty state
            if pageNum == 1 && results.isEmpty {
                text("No accessibility issues found.", ctx,
                     r: rect(cursorY + 16, x: margin, w: contentW, h: 16),
                     font: .systemFont(ofSize: 11), color: clrText)
            }

            // ── Footer ───────────────────────────────────────────────────────────
            // footerY is the from-top y of the footer line (near the bottom of the page).
            let footerY = pageH - margin - 12
            ctx.setStrokeColor(clrBorder.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: margin, y: footerY))
            ctx.addLine(to: CGPoint(x: margin + contentW, y: footerY))
            ctx.strokePath()

            text("Exported from Parlance Xcode Extension — parlance.business",
                 ctx, r: rect(footerY + 2, x: margin, w: contentW - 50, h: 10),
                 font: .systemFont(ofSize: 7), color: clrSec)
            text("Page \(pageNum)",
                 ctx, r: rect(footerY + 2, x: margin, w: contentW, h: 10),
                 font: .systemFont(ofSize: 7), color: clrSec, align: .right)

            NSGraphicsContext.restoreGraphicsState()
            ctx.endPDFPage()
        } while resultIdx < results.count

        ctx.closePDF()
        return output as Data
    }

    // MARK: - Drawing primitives

    /// Returns a CGRect in flipped (top-down) coordinates.
    /// `yFromTop` is measured from the top of the page downward (y=0 is top).
    private static func rect(_ yFromTop: CGFloat, x: CGFloat = 0,
                              w: CGFloat = pageW, h: CGFloat) -> CGRect {
        CGRect(x: x, y: yFromTop, width: w, height: h)
    }

    /// Draws `string` in `r` using the current flipped NSGraphicsContext.
    /// Coordinates are top-down (y=0 is top of page).
    private static func text(_ string: String, _ ctx: CGContext, r: CGRect,
                              font: NSFont, color: NSColor,
                              align: NSTextAlignment = .left) {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        style.lineBreakMode = .byTruncatingTail
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: color, .paragraphStyle: style
        ]
        NSAttributedString(string: string, attributes: attrs).draw(in: r)
    }

    private static func fill(_ ctx: CGContext, _ r: CGRect, color: NSColor) {
        ctx.setFillColor(color.cgColor)
        ctx.fill(r)
    }

    private static func stroke(_ ctx: CGContext, _ r: CGRect, color: NSColor, lw: CGFloat) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(lw)
        ctx.stroke(r)
    }

    // MARK: - Helpers

    private static func severityColor(_ s: Severity) -> NSColor {
        switch s {
        case .error:   return clrError
        case .warning: return clrWarning
        case .info:    return clrInfo
        }
    }

    private static func csvEscape(_ s: String) -> String {
        "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func datestamp() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
