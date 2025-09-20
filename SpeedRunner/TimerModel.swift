import Foundation
import Combine

enum DisplayMode: String, CaseIterable, Codable {
    case total, split, both
}

class TimerModel: ObservableObject {
    @Published var splits: [Split] = []
    @Published var currentSplitIndex: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var startTime: Date? = nil
    @Published var elapsed: TimeInterval = 0
    @Published var displayMode: DisplayMode = .both

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private var pauseTime: TimeInterval = 0

    private let splitsKey = "speedrun.splits.v6"
    private let settingsKey = "speedrun.settings.v6"

    init() {
        loadSplits()
        loadSettings()
        setupObservers()
    }

    private func setupObservers() {
        $splits
            .sink { [weak self] _ in self?.saveSplits() }
            .store(in: &cancellables)

        $displayMode
            .sink { [weak self] _ in self?.saveSettings() }
            .store(in: &cancellables)
    }

    func splitOrStart() {
        if !isRunning { start() } else { split() }
    }

    func start() {
        isRunning = true
        isPaused = false
        startTime = Date()
        currentSplitIndex = 0
        pauseTime = 0

        for i in splits.indices { splits[i].time = nil }

        startTimer()
    }

    func split() {
        guard currentSplitIndex < splits.count else { return }
        splits[currentSplitIndex].time = elapsed
        currentSplitIndex += 1
        if currentSplitIndex >= splits.count {
            isRunning = false
            timer?.invalidate()
        }
    }

    func reset() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        startTime = nil
        elapsed = 0
        currentSplitIndex = 0
        pauseTime = 0
        for i in splits.indices { splits[i].time = nil }
    }

    func togglePause() {
        guard isRunning else { return }
        if isPaused {
            // Resume
            startTime = Date().addingTimeInterval(-pauseTime)
            startTimer()
            isPaused = false
        } else {
            // Pause
            pauseTime = elapsed
            timer?.invalidate()
            isPaused = true
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            DispatchQueue.main.async {
                self.elapsed = Date().timeIntervalSince(start)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    var formattedTime: String { format(time: elapsed) }

    var formattedTimeNoCentis: String {
        let minutes = Int(elapsed / 60)
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func format(time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) % 60
        let centis = Int((time - floor(time)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centis)
    }

    func formatNoCentis(time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func saveSplits() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(splits) {
            UserDefaults.standard.set(data, forKey: splitsKey)
        }
    }

    private func loadSplits() {
        if let data = UserDefaults.standard.data(forKey: splitsKey),
           let decoded = try? JSONDecoder().decode([Split].self, from: data) {
            splits = decoded
        }
        if splits.isEmpty {
            splits = [
                Split(name: "Level 1"),
                Split(name: "Level 2"),
                Split(name: "Boss"),
                Split(name: "Finale")
            ]
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(displayMode.rawValue, forKey: settingsKey)
    }

    private func loadSettings() {
        if let raw = UserDefaults.standard.string(forKey: settingsKey),
           let mode = DisplayMode(rawValue: raw) {
            displayMode = mode
        }
    }
}
