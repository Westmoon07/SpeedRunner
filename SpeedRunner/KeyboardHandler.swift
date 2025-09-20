//
//  KeyboardHandler.swift
//  SpeedRunner
//
//  Created by Mackenzie Williams on 20/9/2025.
//


import SwiftUI
import AppKit

struct KeyboardHandler: NSViewRepresentable {
    var onKeyDown: (String) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if let chars = event.charactersIgnoringModifiers {
                onKeyDown(chars)
            }
            return event
        }
        context.coordinator.monitor = monitor
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let monitor = coordinator.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    class Coordinator {
        var monitor: Any?
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}
