#!/bin/bash
# Full type-check of the iOS app without Xcode: copy the sources, strip the
# #Preview macros (no plugin available), shim the iOS-only system colours, and
# type-check against the macOS SDK. Files whose macros need Xcode plugins
# (SwiftData @Model/@Query) are excluded - an error in a batch suppresses the
# other files in that batch, so they must be out of the way for the rest to be
# genuinely checked.
set -e
SRC=/Users/Admin/Swift/EPFLearn/EPFLearn
WORK="${TMPDIR:-/tmp}/epflearn-typecheck"
python3 - "$SRC" "$WORK" <<'PY'
import os, re, shutil, sys
src, out = sys.argv[1], sys.argv[2]
shutil.rmtree(out, ignore_errors=True); os.makedirs(out)
# GaussView uses .pickerStyle(.wheel), which exists on iOS but not macOS.
skip = {"QuizResultRecord.swift", "ContentView.swift", "SettingsView.swift",
        "QuizResult.swift", "EPFLearnApp.swift",
        # UIColor(dynamicProvider:) has no NSColor equivalent to shim.
        "ImageSpaceView.swift",
        # MessageUI / MFMailComposeViewController is iOS-only, no macOS shim.
        "FeedbackView.swift",
        # UIApplication / UIKit notification delegate, iOS-only.
        "RateAppManager.swift"}
def strip_previews(s):
    res, i = [], 0
    while True:
        m = re.search(r'#Preview[^\n{]*\{', s[i:])
        if not m:
            res.append(s[i:]); break
        res.append(s[i:i+m.start()])
        k = i + m.end() - 1; depth = 0
        while k < len(s):
            if s[k] == '{': depth += 1
            elif s[k] == '}':
                depth -= 1
                if depth == 0: break
            k += 1
        i = k + 1
    return ''.join(res)
for root, _, files in os.walk(src):
    for fn in files:
        if fn.endswith(".swift") and fn not in skip:
            p = os.path.join(root, fn)
            body = strip_previews(open(p).read())
            # iOS-only chrome that has no macOS spelling; swapped for an
            # equivalent that type-checks, never for anything type-bearing.
            body = body.replace(".pickerStyle(.wheel)", ".pickerStyle(.automatic)")
            body = re.sub(r"\n\s*\.navigationBarTitleDisplayMode\([^)]*\)", "", body)
            body = body.replace("placement: .navigationBarTrailing", "placement: .automatic")
            body = body.replace(".navigationBarTitleDisplayMode(.inline)", "")
            open(os.path.join(out, p.replace("/", "__")), "w").write(body)
open(os.path.join(out, "zz__shim.swift"), "w").write('''
import SwiftUI
import AppKit
typealias UIColor = NSColor
extension NSColor {
    static var label: NSColor { .labelColor }
    static var secondaryLabel: NSColor { .secondaryLabelColor }
    static var separator: NSColor { .separatorColor }
    static var systemBackground: NSColor { .windowBackgroundColor }
    static var systemGroupedBackground: NSColor { .windowBackgroundColor }
    static var secondarySystemBackground: NSColor { .underPageBackgroundColor }
    static var secondarySystemGroupedBackground: NSColor { .underPageBackgroundColor }
    static var tertiarySystemBackground: NSColor { .controlBackgroundColor }
}

// Stands in for the one excluded view so its call sites still resolve.
struct ImageSpaceView: View { var body: some View { EmptyView() } }
''')
PY
cd "$WORK"
xcrun swiftc -typecheck -target arm64-apple-macos26.0 *.swift 2>&1 | sed 's/^EPFLearn__//;s/__/\//g'
