import SwiftUI

struct ExperimentLogTimelineView: View {
    @State private var viewModel = ExperimentLogViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(phaseColor(item.phase))
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(LabTheme.brass, lineWidth: 1))
                            if index < viewModel.items.count - 1 {
                                Rectangle()
                                    .fill(LabTheme.brass.opacity(0.35))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 14)

                        BrassFrame {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.title)
                                        .font(LabTheme.serif.weight(.semibold))
                                        .foregroundStyle(LabTheme.label)
                                    Spacer()
                                    Text(item.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(LabTheme.brass)
                                }
                                Text(item.detail)
                                    .font(.system(.subheadline, design: .serif))
                                    .foregroundStyle(LabTheme.label.opacity(0.8))
                                HStack {
                                    Text(item.phase.label)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(phaseColor(item.phase))
                                    Spacer()
                                    Text("Purity \(Int(item.purity))%")
                                        .font(.caption)
                                        .foregroundStyle(LabTheme.label.opacity(0.7))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 16)
                    }
                }
                if viewModel.items.isEmpty {
                    Text("No reactions logged yet.")
                        .font(LabTheme.serif)
                        .foregroundStyle(LabTheme.label.opacity(0.7))
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle("Experiment Log")
        .labScreenStyle()
        .task { await viewModel.load() }
    }

    private func phaseColor(_ phase: ReactionPhase) -> Color {
        switch phase {
        case .idle: LabTheme.glass
        case .heating: LabTheme.copper
        case .reacting: LabTheme.vialGreen
        case .precipitated: LabTheme.brass
        }
    }
}
