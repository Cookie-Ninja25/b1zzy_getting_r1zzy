//
//  MedicineModels.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
//
//  MedicineModels.swift
//  canva
//
//  Shared app models
//

import Foundation

// Uses existing enums:
// - MedCategory (in CategoryAssets.swift)
// - TimeOfDay   (in AddMedicineView.swift)

struct MedicineDoc: Identifiable, Equatable {
    let id: String
    let name: String
    let category: MedCategory
    let times: [TimeOfDay]
    var takenToday: Bool = false   // local UI flag for today
}
