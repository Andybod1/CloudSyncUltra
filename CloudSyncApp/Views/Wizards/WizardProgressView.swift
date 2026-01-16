//
//  WizardProgressView.swift
//  CloudSyncApp
//
//  Step progress indicator for wizard flows
//

import SwiftUI

/// Visual progress indicator showing steps in a wizard flow
struct WizardProgressView: View {
    let steps: [String]
    let currentStep: Int

    private let stepCircleSize: CGFloat = 30
    private let lineHeight: CGFloat = 2

    var body: some View {
        VStack(spacing: 8) {
            // Circles with connecting lines
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let stepSpacing = totalWidth / CGFloat(max(steps.count - 1, 1))

                ZStack {
                    // Background line (behind circles)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: lineHeight)
                        .frame(width: totalWidth - stepCircleSize)
                        .position(x: totalWidth / 2, y: stepCircleSize / 2)

                    // Progress line (behind circles)
                    if currentStep > 0 {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(height: lineHeight)
                            .frame(width: stepSpacing * CGFloat(currentStep))
                            .position(x: stepSpacing * CGFloat(currentStep) / 2, y: stepCircleSize / 2)
                            .animation(.easeInOut, value: currentStep)
                    }

                    // Circle indicators on top
                    HStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, _ in
                            ZStack {
                                Circle()
                                    .fill(stepColor(for: index))
                                    .frame(width: stepCircleSize, height: stepCircleSize)

                                if index < currentStep {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(index == currentStep ? .white : .gray)
                                }
                            }

                            if index < steps.count - 1 {
                                Spacer()
                            }
                        }
                    }
                }
            }
            .frame(height: stepCircleSize)

            // Labels below the circles
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text(step)
                        .font(.caption)
                        .fontWeight(index == currentStep ? .semibold : .regular)
                        .foregroundColor(stepLabelColor(for: index))
                        .multilineTextAlignment(.center)
                        .fixedSize()

                    if index < steps.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        .frame(height: stepCircleSize + 30)
    }

    private func stepColor(for index: Int) -> Color {
        if index < currentStep {
            return Color.green
        } else if index == currentStep {
            return Color.accentColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private func stepLabelColor(for index: Int) -> Color {
        if index <= currentStep {
            return Color.primary
        } else {
            return Color.secondary
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        WizardProgressView(
            steps: ["Choose Provider", "Configure", "Test", "Success"],
            currentStep: 0
        )
        .padding()

        WizardProgressView(
            steps: ["Choose Provider", "Configure", "Test", "Success"],
            currentStep: 2
        )
        .padding()

        WizardProgressView(
            steps: ["Choose Provider", "Configure", "Test", "Success"],
            currentStep: 3
        )
        .padding()
    }
    .frame(width: 600)
}