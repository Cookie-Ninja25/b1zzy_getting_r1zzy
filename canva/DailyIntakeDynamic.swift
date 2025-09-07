//
//  DailyIntakeDynamic.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI

// Helper: Sunrise → Midday → Sunset → Night (used for small subtitle)
func periodOrder(_ p: TimeOfDay) -> Int {
    switch p {
    case .sunrise: return 0
    case .midday:  return 1
    case .sunset:  return 2
    case .night:   return 3
    }
}

// MARK: - View bound to ScheduleViewModel (single source of truth)
struct DailyIntakeDynamic: View {
    @ObservedObject var vm: ScheduleViewModel   // pass the SAME instance from ContentView

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.ochre)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 12) {
                // Title chip
                Text("Daily Intake")
                    .font(.footnote.bold())
                    .foregroundColor(.clay)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.top, 10)

                // Rows
                VStack(alignment: .leading, spacing: 14) {
                    // Use indices to create writable bindings into vm.items
                    ForEach(vm.items.indices, id: \.self) { idx in
                        let med = vm.items[idx]
                        IntakeRow(
                            checked: Binding(
                                get: { vm.items[idx].takenToday },
                                set: { newVal in
                                    vm.items[idx].takenToday = newVal
                                    // Optional: persist per-day status to Firestore if you add a field
                                }
                            ),
                            title: med.name,
                            period: med.times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
                        )
                    }

                    if vm.items.isEmpty {
                        Text("No medicines yet.\nAdd one to see it here.")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                    }
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }
}

// MARK: - Row with checkbox
private struct IntakeRow: View {
    @Binding var checked: Bool
    let title: String
    let period: TimeOfDay

    var body: some View {
        HStack(spacing: 10) {
            CheckBox(checked: $checked)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                Text(period.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { checked.toggle() }
    }
}

// MARK: - Reusable CheckBox
struct CheckBox: View {
    @Binding var checked: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: 24, height: 24)
                .background(checked ? Color.white.opacity(0.15) : Color.clear)
                .cornerRadius(5)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onTapGesture { checked.toggle() }
    }
}

