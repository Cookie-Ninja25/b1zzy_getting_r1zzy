//
//  AddMedicineView.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Supporting types
enum MedType: String, CaseIterable, Identifiable {
    case tablet = "Tablet", capsule = "Capsule", liquid = "Liquid", inhaler = "Inhaler", injection = "Injection"
    var id: String { rawValue }
}

enum Frequency: String, CaseIterable, Identifiable {
    case daily = "Daily", every2ndDay = "Every 2nd day", weekly = "Weekly", prn = "As needed"
    var id: String { rawValue }
}

enum TimeOfDay: String, CaseIterable, Identifiable {
    case sunrise = "Sunrise", midday = "Midday", sunset = "Sunset", night = "Night"
    var id: String { rawValue }
}

/// New: Medicine categories (instead of “strength”)
enum MedCategory: String, CaseIterable, Identifiable {
    case diabetes = "Diabetes Medicine"
    case vitamins = "Vitamin Supplements"
    case bloodPressure = "Blood Pressure Medicine"
    case antibiotics = "Antibiotics"
    case antidepressants = "Antidepressants"

    var id: String { rawValue }
}

// MARK: - View
struct AddMedicineView: View {
    // Basics
    @State private var name: String = ""
    @State private var medType: MedType = .tablet
    @State private var category: MedCategory = .diabetes   // dropdown

    // Schedule
    @State private var frequency: Frequency = .daily
    @State private var perIntake: Int = 1
    @State private var timesSelected: Set<TimeOfDay> = [.sunrise]

    // Reminder
    @State private var reminderTone: String = "Chime"
    @State private var reminderVolume: Double = 0.6

    // UX
    @State private var isSaving = false
    @State private var saveMessage: String?

    var body: some View {
        ZStack {
            Color.cocoa.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // Title
                    VStack(spacing: 4) {
                        Text("Add Medicine")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.ochre)
                        Text("Keep your dingo strong")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)

                    // Wheel (placeholder / reuse your CycleWheel)
                    CycleWheel()
                        .frame(width: 220, height: 220)
                        .frame(maxWidth: .infinity)

                    // Basics
                    GroupBoxLabel("Medicine basics")

                    RoundedSection {
                        HStack {
                            LabeledTextField(title: "Medicine name", text: $name, placeholder: "Metformin")

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Form")
                                    .font(.headline)
                                    .foregroundColor(.cardBg.opacity(0.9))
                                Picker("Form", selection: $medType) {
                                    ForEach(MedType.allCases) { t in Text(t.rawValue).tag(t) }
                                }
                                .pickerStyle(.menu)
                                .tint(.cardBg)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Type of Medicine")
                                .font(.headline)
                                .foregroundColor(.cardBg.opacity(0.9))
                            Picker("Category", selection: $category) {
                                ForEach(MedCategory.allCases) { c in Text(c.rawValue).tag(c) }
                            }
                            .pickerStyle(.menu)
                            .tint(.cardBg)
                        }
                    }

                    // Schedule
                    GroupBoxLabel("Schedule")

                    RoundedSection {
                        HStack {
                            Text("Frequency")
                                .font(.headline).foregroundColor(.cardBg.opacity(0.9))
                            Spacer()
                            Picker("Frequency", selection: $frequency) {
                                ForEach(Frequency.allCases) { f in Text(f.rawValue).tag(f) }
                            }
                            .pickerStyle(.menu)
                            .tint(.cardBg)
                        }

                        HStack(spacing: 12) {
                            Text("How many per intake")
                                .font(.headline).foregroundColor(.cardBg.opacity(0.9))
                            Spacer()
                            Stepper(value: $perIntake, in: 1...6) {
                                Text("\(perIntake)")
                                    .font(.headline).foregroundColor(.cardBg)
                                    .frame(width: 30)
                            }
                        }

                        FlowChips(
                            all: TimeOfDay.allCases,
                            selection: $timesSelected
                        )
                    }

                    // Reminder
                    GroupBoxLabel("Reminder")

                    RoundedSection {
                        HStack {
                            Picker("Tone", selection: $reminderTone) {
                                Text("Chime").tag("Chime")
                                Text("Drum").tag("Drum")
                                Text("Birdsong").tag("Birdsong")
                            }
                            .pickerStyle(.menu)
                            .tint(.cardBg)

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("Volume").font(.subheadline).foregroundColor(.cardBg.opacity(0.9))
                                Slider(value: $reminderVolume, in: 0...1)
                            }
                        }
                    }

                    // Save button
                    Button {
                        Task { await saveMedicine() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            Text(isSaving ? "Saving…" : "Save Medicine")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.leaf)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty)

                    if let msg = saveMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Add")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Save to Firestore
    private func saveMedicine() async {
        isSaving = true
        saveMessage = nil

        let db = Firestore.firestore()
        let doc: [String: Any] = [
            "name": name,
            "form": medType.rawValue,
            "category": category.rawValue,   // NEW
            "frequency": frequency.rawValue,
            "perIntake": perIntake,
            "times": Array(timesSelected.map { $0.rawValue }),
            "reminderTone": reminderTone,
            "reminderVolume": reminderVolume,
            "createdAt": Timestamp(date: Date()),
            "ownerId": "dev" // replace with auth later
        ]

        do {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                db.collection("medicines").addDocument(data: doc) { error in
                    if let error = error { cont.resume(throwing: error) }
                    else { cont.resume() }
                }
            }
            saveMessage = "✅ Saved \(name)."
        } catch {
            saveMessage = "❌ Save failed: \(error.localizedDescription)"
        }
        isSaving = false
    }
}

// MARK: - Small UI helpers
private struct RoundedSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .background(Color.clay.opacity(0.55))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

private struct GroupBoxLabel: View {
    var title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.title3.bold())
            .foregroundColor(.cardBg)
            .padding(.top, 8)
    }
}

private struct LabeledTextField: View {
    var title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.cardBg.opacity(0.9))
            }
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color.cocoa.opacity(0.6))
                .foregroundColor(.cardBg)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

private struct FlowChips: View {
    let all: [TimeOfDay]
    @Binding var selection: Set<TimeOfDay>

    var body: some View {
        HStack(spacing: 10) {
            ForEach(all) { t in
                let isOn = selection.contains(t)
                Text(t.rawValue)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(isOn ? chipColor(t) : Color.cocoa.opacity(0.6))
                    .foregroundColor(isOn ? .white : .cardBg)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if isOn { selection.remove(t) } else { selection.insert(t) }
                    }
            }
        }
    }

    private func chipColor(_ t: TimeOfDay) -> Color {
        switch t {
        case .sunrise: return Color(red: 135/255, green: 155/255, blue: 110/255)
        case .midday:  return .ochre
        case .sunset:  return Color(red: 224/255, green: 193/255, blue: 116/255)
        case .night:   return Color(red: 68/255,  green: 98/255,  blue: 138/255)
        }
    }
}

