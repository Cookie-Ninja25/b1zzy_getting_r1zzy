////
////  MedicineCards.swift
////  canva
////
////  Created by Jerry Jin on 7/9/2025.
////
//
//import Foundation
//import SwiftUI
//
//struct HappeningCardBound: View {
//    let med: MedicineDoc
//    let onTaken: () -> Void
//    let onSnooze: () -> Void
//
//    private let cardWidth: CGFloat = 180
//
//    var body: some View {
//        let v = visual(for: med.category)
//
//        VStack(spacing: 8) {
//            Text("Happening")
//                .font(.caption.bold())
//                .foregroundColor(.white)
//                .padding(.horizontal, 10).padding(.vertical, 4)
//                .background(Color.leaf)
//                .clipShape(Capsule())
//
//            // Category visual
//            Group {
//                if let img = v.imageName, UIImage(named: img) != nil {
//                    Image(img).resizable().scaledToFit().frame(height: 44)
//                } else {
//                    Image(systemName: v.fallbackSymbol)
//                        .font(.system(size: 40, weight: .bold))
//                        .foregroundColor(v.tint)
//                        .frame(height: 44)
//                }
//            }
//
//            Text(med.name)
//                .font(.system(size: 18, weight: .heavy))
//                .foregroundColor(.clay)
//
//            Text(med.category.rawValue)
//                .font(.caption)
//                .foregroundColor(.gray)
//
//            HStack(spacing: 8) {
//                Button(action: onTaken) {
//                    Text("I took it!")
//                        .font(.caption.bold())
//                        .padding(.vertical, 8).frame(maxWidth: .infinity)
//                        .background(Color.leaf.opacity(0.9))
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                Button(action: onSnooze) {
//                    Text("Snooze")
//                        .font(.caption.bold())
//                        .padding(.vertical, 8).frame(maxWidth: .infinity)
//                        .background(Color.gray.opacity(0.2))
//                        .foregroundColor(.clay)
//                        .clipShape(Capsule())
//                }
//            }
//        }
//        .padding(12)
//        .frame(width: cardWidth)
//        .background(Color.cardBg)
//        .cornerRadius(18)
//        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
//    }
//}
//
//struct UpcomingCardBound: View {
//    let med: MedicineDoc
//
//    private let cardWidth: CGFloat = 180
//
//    var body: some View {
//        let v = visual(for: med.category)
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Upcoming")
//                .font(.caption.bold())
//                .foregroundColor(.clay)
//                .padding(.horizontal, 8).padding(.vertical, 2)
//                .background(Color.white)
//                .clipShape(Capsule())
//
//            Text(med.name)
//                .font(.system(size: 18, weight: .heavy))
//                .foregroundColor(.white)
//
//            Text(med.category.rawValue)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.7))
//
//            HStack {
//                Spacer()
//                if let img = v.imageName, UIImage(named: img) != nil {
//                    Image(img).resizable().scaledToFit().frame(height: 30)
//                } else {
//                    Image(systemName: v.fallbackSymbol)
//                        .foregroundColor(.white.opacity(0.9))
//                        .font(.system(size: 20, weight: .bold))
//                }
//            }
//        }
//        .padding(12)
//        .frame(width: cardWidth)
//        .background(Color.clay)
//        .cornerRadius(18)
//        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
//    }
//}
