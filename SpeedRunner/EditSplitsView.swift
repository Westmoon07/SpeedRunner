import SwiftUI

struct EditSplitsView: View {
    @Binding var splits: [Split]
    @EnvironmentObject var timerModel: TimerModel
    @Environment(\.dismiss) private var dismiss
    @State private var newSplitName = ""

    var body: some View {
        VStack {
            Text("Edit Splits").font(.headline).padding()
            List {
                ForEach($splits, id: \.id) { $split in
                    HStack {
                        TextField("Split name", text: $split.name)
                        Spacer()
                        Button(role: .destructive) {
                            if let idx = splits.firstIndex(where: { $0.id == split.id }) {
                                splits.remove(at: idx)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { idx in splits.remove(atOffsets: idx) }
            }

            HStack {
                TextField("New split name", text: $newSplitName)
                Button("Add") {
                    let trimmed = newSplitName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    splits.append(Split(name: trimmed))
                    newSplitName = ""
                }
                .disabled(newSplitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 420, height: 480)
    }
}
