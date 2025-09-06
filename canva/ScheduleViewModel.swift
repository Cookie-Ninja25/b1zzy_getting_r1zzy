////
////  ScheduleViewModel.swift
////  canva
////
////  Created by Jerry Jin on 7/9/2025.
////
//
//import Foundation
//import SwiftUI
//import FirebaseFirestore
//
//// Sort order helper for time-of-day
//func periodOrder(_ p: TimeOfDay) -> Int {
//    switch p {
//    case .sunrise: return 0
//    case .midday:  return 1
//    case .sunset:  return 2
//    case .night:   return 3
//    }
//}
//
//// Firestore model
//struct MedicineDoc: Identifiable, Equatable {
//    let id: String
//    let name: String
//    let category: MedCategory
//    let times: [TimeOfDay]
//    var form: MedType = .tablet
//    var takenToday: Bool = false
//}
//
//final class ScheduleViewModel: ObservableObject {
//    @Published var items: [MedicineDoc] = []
//    @Published var happening: MedicineDoc?
//    @Published var upcoming: MedicineDoc?
//
//    private var listener: ListenerRegistration?
//
//    deinit { listener?.remove() }
//
//    init() {
//        listen()
//    }
//
//    func listen() {
//        let db = Firestore.firestore()
//        listener?.remove()
//        listener = db.collection("medicines")
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self else { return }
//                guard error == nil, let docs = snapshot?.documents else {
//                    self.items = []; self.happening = nil; self.upcoming = nil
//                    return
//                }
//
//                var rows: [MedicineDoc] = docs.compactMap { d in
//                    let data = d.data()
//                    let name = data["name"] as? String ?? "Medicine"
//                    let cat  = MedCategory(rawValue: data["category"] as? String ?? "") ?? .diabetes
//                    let form = MedType(rawValue: data["form"] as? String ?? "") ?? .tablet
//                    let timeStrings = (data["times"] as? [String]) ?? []
//                    let times = timeStrings.compactMap { TimeOfDay(rawValue: $0) }
//                    return MedicineDoc(id: d.documentID, name: name, category: cat, times: times.isEmpty ? [.sunrise] : times, form: form)
//                }
//
//                // Sort by earliest chosen period → then category → then name
//                rows.sort {
//                    let aP = $0.times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
//                    let bP = $1.times.min(by: { periodOrder($0) < periodOrder($1) }) ?? .sunrise
//                    if periodOrder(aP) != periodOrder(bP) {
//                        return periodOrder(aP) < periodOrder(bP)
//                    }
//                    if $0.category.rawValue != $1.category.rawValue {
//                        return $0.category.rawValue < $1.category.rawValue
//                    }
//                    return $0.name < $1.name
//                }
//
//                self.items = rows
//                self.computeNow()
//            }
//    }
//
//    // Compute happening & upcoming from the current time period
//    func computeNow(date: Date = Date()) {
//        guard !items.isEmpty else { happening = nil; upcoming = nil; return }
//
//        let currentPeriod = DayPeriod.current(for: date) // from your wheel code
//        // pick the first medicine that includes the currentPeriod
//        if let idx = items.firstIndex(where: { $0.times.contains(where: { $0.rawValue == currentPeriod.rawValue.capitalized }) }) {
//            happening = items[idx]
//            upcoming = items[(idx + 1) % items.count]
//            return
//        }
//
//        // Otherwise fallback: the first medicine by sort order
//        happening = items.first
//        upcoming = (items.count > 1) ? items[1] : nil
//    }
//
//    // Mark taken (MVP: local UI only; wire to Firestore later if you like)
//    func markTaken(_ id: String) {
//        if let idx = items.firstIndex(where: { $0.id == id }) {
//            items[idx].takenToday = true
//        }
//        // also tick happening if it matches
//        if happening?.id == id {
//            happening?.takenToday = true
//        }
//        objectWillChange.send()
//    }
//}
