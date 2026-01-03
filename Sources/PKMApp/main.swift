import AppKit
import SwiftUI

// Main entry point for menu bar app
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy to accessory (hides from dock)
app.setActivationPolicy(.accessory)

// Run the app
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
