import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var showMillis = false

    var body: some View {
        let liveTime: TimeInterval? = {
            guard timerModel.isRunning, timerModel.currentSplitIndex < timerModel.splits.count else { return nil }
            let previousSplitTime = timerModel.splits.prefix(timerModel.currentSplitIndex).compactMap { $0.time }.last ?? 0
            return timerModel.elapsed - previousSplitTime
        }()

        return VStack(spacing: 8) {
            // Main elapsed timer
            Text(showMillis ? timerModel.formattedTime : timerModel.formattedTimeNoCentis)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundColor(timerModel.isPaused ? .red : .primary) // Show red when paused
                .padding(.top, 8)
                .onTapGesture { showMillis.toggle() }

            // Current split live time
            if let liveTime = liveTime {
                Text(showMillis ? timerModel.format(time: liveTime) : timerModel.formatNoCentis(time: liveTime))
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundColor(.orange)
            }

            // Split list
            List {
                ForEach(timerModel.splits.indices, id: \.self) { i in
                    HStack {
                        Text(timerModel.splits[i].name)
                            .frame(width: 180, alignment: .leading)
                            .foregroundColor(.primary)
                        Spacer()
                        if let t = timerModel.splits[i].time {
                            Text(showMillis ? timerModel.format(time: t) : timerModel.formatNoCentis(time: t))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                        } else {
                            Text("--:--")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { idx in timerModel.splits.remove(atOffsets: idx) }
            }
            .frame(maxHeight: 220)

            // Buttons
            HStack(spacing: 12) {
                Button(action: { timerModel.splitOrStart() }) {
                    Text(timerModel.isRunning ? "Split" : "Start")
                        .frame(minWidth: 80)
                }.keyboardShortcut("=", modifiers: [])

                Button(action: { timerModel.reset() }) {
                    Text("Reset").frame(minWidth: 80)
                }.keyboardShortcut("-", modifiers: [])
            }
            .padding(8)
        }
        .padding(8)
        .frame(width: 420)
        // Listen for \ key
        .background(KeyboardHandler { key in
            if key == "\\" { timerModel.togglePause() }
        })
    }
}
