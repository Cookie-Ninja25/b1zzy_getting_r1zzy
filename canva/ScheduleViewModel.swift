//
//  ScheduleViewModel.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import UserNotifications

final class ScheduleViewModel: ObservableObject {
    // Shared source of truth used by ContentView + DailyIntakeDynamic
    @Published var items: [MedicineDoc] = []
    @Published var happening: MedicineDoc?
    @Published var upcoming: MedicineDoc?

    private var listener: ListenerRegistration?

    // Prevent duplicate "it's time" notifications once per med per day
    private var lastNotifiedId: String?
    private var lastNotifiedDateKey: String?

    deinit { listener?.remove() }
    init() { listen() }

    // MARK: - Firestore live listener
    func listen() {
        let db = Firestore.firestore()
        listener?.remove()

        listener = db.collection("medicines")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard error == nil, let docs = snapshot?.documents else {
                    self.items = []; self.happening = nil; self.upcoming = nil
                    return
                }

                var rows: [MedicineDoc] = docs.compactMap { d in
                    let data = d.data()
                    let name = data["name"] as? String ?? "Medicine"

                    // MedCategory and TimeOfDay are defined elsewhere in your project
                    let catStr = data["category"] as? String ?? MedCategory.diabetes.rawValue
                    let category = MedCategory(rawValue: catStr) ?? .diabetes

                    let timeStrings = (data["times"] as? [String]) ?? []
                    let times = timeStrings.compactMap { TimeOfDay(rawValue: $0) }

                    return MedicineDoc(
                        id: d.documentID,
                        name: name,
                        category: category,
                        times: times.isEmpty ? [.sunrise] : times
                    )
                }

                // Sort by earliest time-of-day → category → name
                rows.sort {
                    let aP = self.order($0.times.min(by: { self.order($0) < self.order($1) }) ?? .sunrise)
                    let bP = self.order($1.times.min(by: { self.order($0) < self.order($1) }) ?? .sunrise)
                    if aP != bP { return aP < bP }
                    if $0.category.rawValue != $1.category.rawValue {
                        return $0.category.rawValue < $1.category.rawValue
                    }
                    return $0.name < $1.name
                }

                self.items = rows
                self.computeNow()
            }
    }

    // MARK: - Decide what’s happening now & what’s next
    func computeNow(date: Date = Date()) {
        guard !items.isEmpty else { happening = nil; upcoming = nil; return }

        let current = DayPeriod.current(for: date)

        if let idx = items.firstIndex(where: { med in
            med.times.contains { $0.rawValue == current.rawValue.capitalized }
        }) {
            happening = items[idx]
            upcoming  = items.isEmpty ? nil : items[(idx + 1) % items.count]
        } else {
            // Fallback: show first & second
            happening = items.first
            upcoming  = items.count > 1 ? items[1] : nil
        }

        // Fire a local notification if a med just became "Happening" and isn't taken yet
        maybeNotifyNow()
    }

    // MARK: - UI tick (instant)
    func markTaken(_ id: String) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].takenToday = true
        }
        if happening?.id == id { happening?.takenToday = true }
        objectWillChange.send()
    }

    // MARK: - Full “I took it!” flow (non-async, background Firestore writes)
    func takeNow(_ med: MedicineDoc) {
        // 1) Update UI immediately
        markTaken(med.id)

        // 2) Write to Firestore in background
        Task.detached { [med] in
            let db = Firestore.firestore()
            let now = Date()
            let period = DayPeriod.current(for: now).rawValue        // "sunrise" / "midday" / ...
            let dateKey = Self.dayKey(now)                           // "YYYY-MM-DD"

            let intake: [String: Any] = [
                "medicineId": med.id,
                "medicineName": med.name,
                "category": med.category.rawValue,
                "period": period,
                "dateKey": dateKey,
                "takenAt": FieldValue.serverTimestamp()
            ]

            do {
                // Add intake event
                try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                    db.collection("intakes").addDocument(data: intake) { err in
                        if let err = err { cont.resume(throwing: err) }
                        else { cont.resume(returning: ()) }
                    }
                }
                // Update a convenience field on the medicine
                try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                    db.collection("medicines").document(med.id)
                        .updateData(["lastTakenAt": FieldValue.serverTimestamp()]) { err in
                            if let err = err { cont.resume(throwing: err) }
                            else { cont.resume(returning: ()) }
                        }
                }
            } catch {
                // Non-fatal; UI already marked taken
                print("takeNow Firestore write failed:", error.localizedDescription)
            }
        }

        // 3) Advance cards
        DispatchQueue.main.async { [weak self] in
            self?.computeNow()
        }
    }

    // MARK: - Immediate local notification when a med becomes "Happening"
    private func maybeNotifyNow() {
        guard let med = happening else { return }
        guard med.takenToday == false else { return } // don't notify for already taken

        let today = Self.dayKey(Date())
        if lastNotifiedId == med.id, lastNotifiedDateKey == today {
            return // already notified for this med today
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to take your medicine"
        content.body  = "\(med.name) (\(med.category.rawValue))"
        content.sound = .default

        // Trigger immediately (nil trigger posts now)
        let request = UNNotificationRequest(
            identifier: "now-\(med.id)-\(today)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                print("Notification failed:", err.localizedDescription)
            } else {
                self.lastNotifiedId = med.id
                self.lastNotifiedDateKey = today
                print("✅ Notified for \(med.name)")
            }
        }
    }

    // MARK: - Helpers
    private func order(_ p: TimeOfDay) -> Int {
        switch p {
        case .sunrise: return 0
        case .midday:  return 1
        case .sunset:  return 2
        case .night:   return 3
        }
    }

    private static func dayKey(_ d: Date) -> String {
        let f = DateFormatter()
        f.calendar = .current
        f.locale   = .current
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }
}

