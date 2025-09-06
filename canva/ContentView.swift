//
//  ContentView.swift
//  canva
//
//  Created by Jerry Jin on 6/9/2025.
//

// HealingOnCountryApp.swift
// iOS 15+ SwiftUI single-file MVP

import SwiftUI
import UserNotifications

// MARK: - Models

enum CycleKey: String, CaseIterable, Identifiable, Codable {
    case sunrise, midday, sunset, night
    var id: String { rawValue }
    var label: String {
        switch self {
        case .sunrise: return "Sunrise"
        case .midday:  return "Midday"
        case .sunset:  return "Sunset"
        case .night:   return "Night"
        }
    }
    var emoji: String {
        switch self {
        case .sunrise: return "🌅"
        case .midday:  return "🌞"
        case .sunset:  return "🌄"
        case .night:   return "🌙"
        }
    }
    var notifyHour: Int {
        switch self {
        case .sunrise: return 8
        case .midday:  return 12
        case .sunset:  return 18
        case .night:   return 22
        }
    }
}

enum Totem: String, CaseIterable, Identifiable, Codable {
    case turtle, river, wind, fire, tree, bird
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .turtle: return "🐢"
        case .river:  return "💧"
        case .wind:   return "🌬️"
        case .fire:   return "🔥"
        case .tree:   return "🌳"
        case .bird:   return "🕊️"
        }
    }
    var display: String { emoji + " " + rawValue.capitalized }
}

struct Medicine: Identifiable, Codable {
    var id: UUID = .init()
    var totem: Totem
    var cycles: [CycleKey]
    var strength: Int = 60
}

// MARK: - Storage

final class Store: ObservableObject {
    @Published var meds: [Medicine] = [] { didSet { save() } }
    private let key = "meds_v1"

    init() { load() }

    func add(totem: Totem, cycles: [CycleKey]) {
        meds.append(Medicine(totem: totem, cycles: cycles))
    }
    func take(_ med: Medicine) {
        if let idx = meds.firstIndex(where: { $0.id == med.id }) {
            meds[idx].strength = min(100, meds[idx].strength + 10)
        }
    }
    func miss(_ med: Medicine) {
        if let idx = meds.firstIndex(where: { $0.id == med.id }) {
            meds[idx].strength = max(0, meds[idx].strength - 10)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(meds) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let m = try? JSONDecoder().decode([Medicine].self, from: data) {
            meds = m
        }
    }
}

// MARK: - Notifications

struct NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func scheduleDaily(cycle: CycleKey, id: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(cycle.label) medicine"
        content.body  = "Strengthen your totem now."
        content.sound = .default

        var dc = DateComponents()
        dc.hour = cycle.notifyHour
        dc.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let request = UNNotificationRequest(identifier: "cycle-\(cycle.rawValue)-\(id)",
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    static func clearAll() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}

// MARK: - View

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var selectedTotem: Totem = .turtle
    @State private var selectedCycles: Set<CycleKey> = [.sunrise, .sunset]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(CycleKey.allCases) { c in
                        VStack(spacing: 6) {
                            Text(c.emoji).font(.system(size: 28))
                            Text(c.label).font(.caption).opacity(0.9)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Medicine").bold()
                    Picker("Totem", selection: $selectedTotem) {
                        ForEach(Totem.allCases) { t in
                            Text(t.display).tag(t)
                        }
                    }
                    .pickerStyle(.menu)

                    HStack {
                        ForEach(CycleKey.allCases) { c in
                            Button {
                                if selectedCycles.contains(c) {
                                    selectedCycles.remove(c)
                                } else {
                                    selectedCycles.insert(c)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(c.emoji)
                                    Text(c.label).font(.caption2)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(selectedCycles.contains(c)
                                    ? Color.green.opacity(0.25)
                                    : Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                    }

                    Button {
                        let cycles = Array(selectedCycles)
                        store.add(totem: selectedTotem, cycles: cycles)
                        if let newId = store.meds.last?.id.uuidString {
                            for c in cycles { NotificationManager.scheduleDaily(cycle: c, id: newId) }
                        }
                    } label: {
                        Label("Add to Today", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(12)
                    }
                }

                List {
                    ForEach(store.meds) { med in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(med.totem.emoji).font(.title2)
                                Text(med.totem.rawValue.capitalized).bold()
                                Spacer()
                                Text("Strength \(med.strength)")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            Text("Cycles: " + med.cycles.map { $0.label }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Button { store.take(med) } label: {
                                    Label("I took it", systemImage: "checkmark.circle.fill")
                                }
                                .buttonStyle(.borderedProminent)

                                Button(role: .destructive) { store.miss(med) } label: {
                                    Label("Missed", systemImage: "xmark.circle.fill")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .padding()
            .navigationTitle("Healing on Country")
            .onAppear { NotificationManager.requestPermission() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        NotificationManager.clearAll()
                    } label: {
                        Image(systemName: "bell.slash")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
