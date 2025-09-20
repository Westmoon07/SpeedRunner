import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerModel: TimerModel

    var body: some View {
        Form {
            Section(header: Text("Menu Bar Display")) {
                Picker("Display Mode", selection: $timerModel.displayMode) {
                    Text("Total Time").tag(DisplayMode.total)
                    Text("Split Name").tag(DisplayMode.split)
                    Text("Both").tag(DisplayMode.both)
                }
                .pickerStyle(.radioGroup)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
