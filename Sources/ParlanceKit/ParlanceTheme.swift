import SwiftUI
import AppKit

// MARK: - Parlance brand palette
//
// Designed to match the parlance platform visual language — clean, functional
// colour, light and dark mode equally first-class.
//
// Primary    indigo/violet  #5b46e0 (light) / #9a87f0 (dark)
// Pass       green          #2f9e5e (light) / #4ac882 (dark)
// Fail       red            #d6453a (light) / #f07068 (dark)
// Warning    amber          #e0a23a (light) / #f0bc5e (dark)
// Pending    blue-grey      #6b86b3 (light) / #8fa8d0 (dark)
//
// Use Color.parlance.* everywhere in UI targets.
// Do NOT use raw hex literals in view code — always go through this namespace.

public enum ParlanceTheme {

    // MARK: Brand primary

    /// Indigo/violet accent — use as tint, selected-tab indicator, primary CTA.
    public static var primary: Color {
        Color(NSColor(name: "ParlancePrimary") { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(r: 154, g: 135, b: 240) // #9a87f0
                : NSColor(r: 91,  g: 70,  b: 224) // #5b46e0
        })
    }

    // MARK: Status / severity

    /// Pass / success green — WCAG pass, "active" contract status.
    public static var pass: Color {
        Color(NSColor(name: "ParlancePass") { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(r: 74,  g: 200, b: 130) // #4ac882
                : NSColor(r: 47,  g: 158, b: 94)  // #2f9e5e
        })
    }

    /// Fail / critical red — WCAG error, severity .error, "deprecated" status.
    public static var fail: Color {
        Color(NSColor(name: "ParlanceFail") { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(r: 240, g: 112, b: 104) // #f07068
                : NSColor(r: 214, g: 69,  b: 58)  // #d6453a
        })
    }

    /// Warning / medium amber — WCAG warning, severity .warning, "draft" status.
    public static var warning: Color {
        Color(NSColor(name: "ParlanceWarning") { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(r: 240, g: 188, b: 94)  // #f0bc5e
                : NSColor(r: 224, g: 162, b: 58)  // #e0a23a
        })
    }

    /// Pending / info blue-grey — severity .info, "proposed" status.
    public static var pending: Color {
        Color(NSColor(name: "ParlancePending") { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(r: 143, g: 168, b: 208) // #8fa8d0
                : NSColor(r: 107, g: 134, b: 179) // #6b86b3
        })
    }
}

// MARK: - Convenience accessor on Color

public extension Color {
    /// Access the brand palette via `Color.parlance.primary`, `.fail`, etc.
    enum parlance {
        public static var primary: Color { ParlanceTheme.primary }
        public static var pass: Color    { ParlanceTheme.pass }
        public static var fail: Color    { ParlanceTheme.fail }
        public static var warning: Color { ParlanceTheme.warning }
        public static var pending: Color { ParlanceTheme.pending }
    }
}

// MARK: - Private NSColor RGB helper

private extension NSColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(srgbRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}
