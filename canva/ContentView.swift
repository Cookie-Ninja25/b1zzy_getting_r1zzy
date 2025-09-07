//
//  ContentView.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Theme Colors
extension Color {
    static let cocoa   = Color(red: 38/255,  green: 16/255,  blue: 8/255)    // dark bg
    static let cardBg  = Color.white
    static let leaf    = Color(red: 119/255, green: 171/255, blue: 73/255)   // green
    static let ochre   = Color(red: 191/255, green: 106/255, blue: 27/255)   // orange
    static let clay    = Color(red: 96/255,  green: 54/255,  blue: 20/255)   // brown
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var scheduleVM = ScheduleViewModel()
    @State private var mood = "Extremely Happy"

    var body: some View {
        ZStack {
            Color.cocoa.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text(DayPeriod.current().rawValue.capitalized)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.ochre)

                    Text("Keep your dingo strong today")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    // Cycle Wheel
                    TimeWheel()
                        .frame(width: 240, height: 240)

                    // Mood card
                    StatusCard(mood: mood)

                    // Two-column layout
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 12) {
                            // Happening card
                            if let happening = scheduleVM.happening {
                                HappeningCardBound(
                                    med: happening,
                                    onTaken: { scheduleVM.takeNow(happening) },
                                    onSnooze: { /* TODO: implement snooze later */ }
                                )
                            }

                            // Upcoming card
                            if let upcoming = scheduleVM.upcoming {
                                UpcomingCardBound(med: upcoming)
                            }
                        }

                        // Daily Intake list bound to the same VM
                        DailyIntakeDynamic(vm: scheduleVM)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    var mood: String
    var body: some View {
        HStack {
            Image("dingo")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text("My dingo is feeling...")
                .font(.subheadline)
            Spacer()
            Text(mood)
                .font(.footnote.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.leaf)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.cardBg)
        .cornerRadius(14)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

