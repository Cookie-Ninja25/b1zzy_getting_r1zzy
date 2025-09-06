//
//  CategoryAssets.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI

struct CategoryVisual {
    let imageName: String?    // asset name if available
    let fallbackSymbol: String
    let tint: Color
}

func visual(for category: MedCategory) -> CategoryVisual {
    switch category {
    case .diabetes:
        return .init(imageName: "river", fallbackSymbol: "wind", tint: Color(red: 130/255, green: 170/255, blue: 210/255))
    case .vitamins:
        return .init(imageName: "leaf", fallbackSymbol: "leaf.fill", tint: Color(red: 110/255, green: 170/255, blue: 100/255))
    case .bloodPressure:
        return .init(imageName: "sunsetFire", fallbackSymbol: "flame.fill", tint: Color(red: 220/255, green: 120/255, blue: 60/255))
    case .antibiotics:
        return .init(imageName: "turtle", fallbackSymbol: "tortoise.fill", tint: Color(red: 90/255, green: 150/255, blue: 130/255))
    case .antidepressants:
        return .init(imageName: "moonSpirit", fallbackSymbol: "moon.stars.fill", tint: Color(red: 160/255, green: 140/255, blue: 220/255))
    }
}
