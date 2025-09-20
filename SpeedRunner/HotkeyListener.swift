import SwiftUI
import AppKit

struct HotkeyListener: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var globalMonitor: Any?

    var body: some View {
        EmptyView()
            .onAppear {
                globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
                    guard let chars = event.charactersIgnoringModifiers else { return }
                    if chars == "=" { timerModel.splitOrStart() }
                    else if chars == "-" { timerModel.reset() }
                }
            }
            .onDisappear {
                if let m = globalMonitor { NSEvent.removeMonitor(m) }
            }
    }
}
