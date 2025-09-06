//
//  DailyIntakeDynamic.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Order helper (Sunrise → Midday → Sunset → Night)
func periodOrder(_ p: TimeOfDay) -> Int {
    switch p {
    case .sunrise: return 0
    case .midday:  return 1
    case .sunset:  return 2
    case .night:   return 3
    }
}

// MARK: - Firestore model
struct MedicineDoc: Identifiable {
    let id: String
    let name: String
    let category: MedCategory
    let times: [TimeOfDay]
    var takenToday: Bool = false   // local UI state for MVP
}

final class DailyIntakeVM: ObservableObject {
    @Published var rows: [MedicineDoc] = []
    private var listener: ListenerRegistration?

    init() { listen() }

    deinit { listener?.remove() }

    func listen() {
        let db = Firestore.firestore()
        listener?.remove()
        listener = db.collection("medicines")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let _ = err { self.rows = []; return }
                let docs = snap?.documents ?? []

                self.rows = docs.compactMap { d in
                    let data = d.data()

                    let name = data["name"] as? String ?? "Medicine"
                    let catStr = data["category"] as? String ?? MedCategory.diabetes.rawValue
                    let category = MedCategory(rawValue: catStr) ?? .diabetes

                    let timeStrings = (data["times"] as? [String]) ?? []
                    let times = timeStrings.compactMap { TimeOfDay(rawValue: $0) }
                    return MedicineDoc(id: d.documentID, name: name, category: category, times: times.isEmpty ? [.sunrise] : times)
                }
                // Sort by earliest selected time period; then by category/name
                self.rows.sort {
                    let aP = $0.times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
                    let bP = $1.times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
                    if periodOrder(aP) != periodOrder(bP) {
                        return periodOrder(aP) < periodOrder(bP)
                    }
                    // secondary sort – category, name
                    if $0.category.rawValue != $1.category.rawValue {
                        return $0.category.rawValue < $1.category.rawValue
                    }
                    return $0.name < $1.name
                }
            }
    }
}

// MARK: - View
struct DailyIntakeDynamic: View {
    @StateObject private var vm = DailyIntakeVM()

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
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.top, 10)

                // Sorted rows
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(vm.rows.indices, id: \.self) { idx in
                        IntakeRow(
                            checked: Binding(
                                get: { vm.rows[idx].takenToday },
                                set: { vm.rows[idx].takenToday = $0 }
                            ),
                            title: vm.rows[idx].category.rawValue,
                            period: vm.rows[idx].times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
                        )
                    }

                    if vm.rows.isEmpty {
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
                // Small subtitle showing which period this row belongs to
                Text(period.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { checked.toggle() }
    }
}

// (re-use your existing CheckBox view)
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
