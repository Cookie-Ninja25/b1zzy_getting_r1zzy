import SwiftUI
import FirebaseFirestore

// MARK: - Models
struct Intake: Identifiable {
    let id = UUID()
    var name: String
    var taken: Bool
}

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
    @State private var hasRun = false

    @State private var mood = "Extremely Happy"
    @State private var happeningTitle = "Clear Wind"
    @State private var happeningSub   = "Diabetes Medicine"
    @State private var upcomingTitle  = "Strong River"
    @State private var upcomingSub    = "Vitamin Supplements"
    @State private var intakes: [Intake] = [
        .init(name: "Diabetes Medicine", taken: true),
        .init(name: "Vitamin Supplements", taken: true),
        .init(name: "Blood Pressure Medicine", taken: false),
        .init(name: "Antibiotics", taken: false),
        .init(name: "Antidepressants", taken: false)
    ]

    var body: some View {
//        VStack(spacing: 16) {
//             Text("Firestore Connectivity Test")
//               .font(.headline)
//
//             Button("Write Test User") {
//               Task { await fh_writeTestUser() }
//             }
//
//             Button("Read Test User") {
//               Task { await fh_readTestUser() }
//             }
//           }
//           .padding()
//           .task {
//             // Auto-run once on first appearance (optional)
//             guard !hasRun else { return }
//             hasRun = true
//             await fh_writeTestUser()
//             await fh_readTestUser()
//           }

        ZStack {
            Color.cocoa.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Debug/test panel (optional)
//                    Group {
//                        Text("Hello, Firestore")
//                            .font(.footnote).foregroundColor(.white.opacity(0.7))
//                        Button("Write Test User to Firestore") {
//                            //testFirestoreWrite()   // non-async test call
//                        }
//                        .font(.caption.bold())
//                        .padding(.horizontal, 10).padding(.vertical, 6)
//                        .background(Color.leaf).foregroundColor(.white)
//                        .clipShape(Capsule())
//                    }
//                    .padding(.top, 8)

                    // Header
                    Text("Sunrise")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.ochre)

                    Text("Keep your dingo strong today")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    // Cycle Wheel
                    CycleWheel()
                        .frame(width: 240, height: 240)

                    // Mood card
                    StatusCard(mood: mood)

                    // Two-column section:
                    // Left = Happening over Upcoming (same width)
                    // Right = Daily Intake (fills remaining space)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 12) {
                            HappeningCard(
                                title: happeningTitle,
                                subtitle: happeningSub,
                                onTaken: { /* mark taken */ },
                                onSnooze: { /* snooze */ }
                            )
                            UpcomingCard(title: upcomingTitle, subtitle: upcomingSub)
                        }

                        DailyIntake(intakes: $intakes)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        // If you want to run automatically at launch too:
        // .onAppear { testFirestoreWrite() }
    }
}

// MARK: - Firestore test helpers

/// Simple completion-based write (works with current Firebase Firestore on iOS)
//func testFirestoreWrite() {
//    let db = Firestore.firestore()
//    db.collection("users").addDocument(data: [
//        "displayName": "Swift Test User",
//        "createdAt": Timestamp(date: Date())
//    ]) { error in
//        if let error = error {
//            print("Error writing document: \(error)")
//        } else {
//            print("Document successfully written!")
//        }
//    }
//}

/*
// If you prefer async/await, you can wrap the addDocument in a continuation:
func testFirestoreWriteAsync() async {
    let db = Firestore.firestore()
    let data: [String: Any] = [
        "displayName": "Swift Test User (async)",
        "createdAt": Timestamp(date: Date())
    ]

    do {
        _ = try await withCheckedThrowingContinuation { continuation in
            var ref: DocumentReference?
            ref = db.collection("users").addDocument(data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ref)
                }
            }
        }
        print("Async document successfully written!")
    } catch {
        print("Async write failed: \(error)")
    }
}
*/

// MARK: - Cycle Wheel
struct CycleWheel: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.ochre.opacity(0.3))
            Circle().stroke(Color.black.opacity(0.3), lineWidth: 3)

            VStack { Text("🌅").font(.title); Spacer() }
                .padding(.top, 16)

            VStack { Spacer(); Text("🌄").font(.title) }
                .padding(.bottom, 16)

            HStack { Text("🌙").font(.title); Spacer(); Text("🌞").font(.title) }
                .padding(.horizontal, 24)

            // Center dingo image
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Image("dingo")
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(6)
                )
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

// MARK: - Happening Card (fixed width)
struct HappeningCard: View {
    var title: String
    var subtitle: String
    var onTaken: () -> Void
    var onSnooze: () -> Void

    private let cardWidth: CGFloat = 180

    var body: some View {
        VStack(spacing: 8) {
            Text("Happening")
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.leaf)
                .clipShape(Capsule())

            Image("dingo") // replace with specific art when available
                .resizable().scaledToFit().frame(height: 44)

            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.clay)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                Button(action: onTaken) {
                    Text("I took it!")
                        .font(.caption.bold())
                        .padding(.vertical, 8).frame(maxWidth: .infinity)
                        .background(Color.leaf.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                Button(action: onSnooze) {
                    Text("Snooze")
                        .font(.caption.bold())
                        .padding(.vertical, 8).frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.clay)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .frame(width: cardWidth)
        .background(Color.cardBg)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }
}

// MARK: - Upcoming Card (same width as Happening, stacked beneath)
struct UpcomingCard: View {
    var title: String
    var subtitle: String

    private let cardWidth: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Upcoming")
                .font(.caption.bold())
                .foregroundColor(.clay)
                .padding(.horizontal, 8).padding(.vertical, 2)
                .background(Color.white)
                .clipShape(Capsule())

            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            HStack {
                Spacer()
                Image("dingo") // placeholder; swap to river art later
                    .resizable().scaledToFit().frame(height: 30)
            }
        }
        .padding(12)
        .frame(width: cardWidth)
        .background(Color.clay)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - Daily Intake (fills right column)
struct DailyIntake: View {
    @Binding var intakes: [Intake]

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.ochre)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 12) {
                Text("Daily Intake")
                    .font(.footnote.bold())
                    .foregroundColor(.clay)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach($intakes) { $item in
                        HStack(spacing: 8) {
                            CheckBox(checked: $item.taken)
                            Text(item.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

struct CheckBox: View {
    @Binding var checked: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: 22, height: 22)
                .background(checked ? Color.white.opacity(0.15) : Color.clear)
                .cornerRadius(5)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onTapGesture { checked.toggle() } // no animation for compatibility
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

