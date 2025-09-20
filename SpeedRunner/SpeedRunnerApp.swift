import SwiftUI
import AppKit

@main
struct SpeedrunTimerApp: App {
    @StateObject private var timerModel = TimerModel()
    @State private var settingsWindow: NSWindow?
    @State private var editSplitsWindow: NSWindow?

    var body: some Scene {
        MenuBarExtra {
            VStack(spacing: 0) {
                TimerView().environmentObject(timerModel)
                Divider()
                VStack(spacing: 6) {
                    Button("Edit Splits") { openEditSplitsWindow() }
                    Button("Settings") { openSettingsWindow() }
                    Divider()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                }
                .padding([.leading, .trailing], 8)
                HotkeyListener().environmentObject(timerModel)
            }
        } label: {
            HStack(spacing: 6) {
                Text(menuBarTitle)
                Image(systemName: "stopwatch")
            }
        }
    }

    private var menuBarTitle: String {
        let timePart = timerModel.formattedTimeNoCentis
        let splitPart: String
        if timerModel.isRunning {
            if timerModel.currentSplitIndex < timerModel.splits.count {
                splitPart = timerModel.splits[timerModel.currentSplitIndex].name
            } else {
                splitPart = "Done"
            }
        } else {
            splitPart = timerModel.splits.isEmpty
                ? ""
                : timerModel.splits[timerModel.currentSplitIndex < timerModel.splits.count ? timerModel.currentSplitIndex : timerModel.splits.count-1].name
        }

        switch timerModel.displayMode {
        case .total:
            return timePart
        case .split:
            return splitPart
        case .both:
            return "\(timePart) | \(splitPart)"
        }
    }

    private func openEditSplitsWindow() {
        if editSplitsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            window.title = "Edit Splits"
            let root = EditSplitsView(splits: Binding(get: { timerModel.splits }, set: { timerModel.splits = $0 }))
                .environmentObject(timerModel)
            window.contentView = NSHostingView(rootView: root)
            window.center()
            window.makeKeyAndOrderFront(nil)
            window.isReleasedWhenClosed = false
            editSplitsWindow = window
        } else {
            editSplitsWindow?.makeKeyAndOrderFront(nil)
        }
    }

    private func openSettingsWindow() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false)
            window.title = "Settings"
            let root = SettingsView().environmentObject(timerModel)
            window.contentView = NSHostingView(rootView: root)
            window.center()
            window.makeKeyAndOrderFront(nil)
            window.isReleasedWhenClosed = false
            settingsWindow = window
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }
}
