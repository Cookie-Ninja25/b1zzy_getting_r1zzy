import SwiftUI

// MARK: - 4 natural periods covering the full 24h
enum DayPeriod: String, CaseIterable, Identifiable {
    case sunrise, midday, sunset, night
    var id: String { rawValue }

    // Inclusive start, inclusive end (local time). Night wraps past midnight.
    var range: (start: (h: Int, m: Int), end: (h: Int, m: Int)) {
        switch self {
        case .sunrise: return ((5, 0),  (10, 59))   // 05:00–10:59
        case .midday:  return ((11, 0), (16, 59))   // 11:00–16:59
        case .sunset:  return ((17, 0), (20, 59))   // 17:00–20:59
        case .night:   return ((21, 0), (4, 59))    // 21:00–04:59 (wraps)
        }
    }

    static func current(for date: Date = Date(), calendar: Calendar = .current) -> DayPeriod {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        let h = comps.hour ?? 0
        let m = comps.minute ?? 0

        func inRange(_ p: DayPeriod) -> Bool {
            let r = p.range
            let start = r.start.h * 60 + r.start.m
            let end   = r.end.h   * 60 + r.end.m
            let now   = h * 60 + m

            if start <= end {
                return (now >= start && now <= end)
            } else {
                // wrap past midnight
                return (now >= start || now <= end)
            }
        }

        for p in DayPeriod.allCases { if inRange(p) { return p } }
        return .sunrise // fallback
    }

    // icon/emoji for quick visuals
    var icon: String {
        switch self {
        case .sunrise: return "🌅"
        case .midday:  return "🌞"
        case .sunset:  return "🌇"
        case .night:   return "🌙"
        }
    }
}

// MARK: - Donut/Wedge shape
struct DonutWedge: Shape {
    var start: Angle
    var end: Angle
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) * 0.48
        var p = Path()
        p.addArc(center: c, radius: r, startAngle: start, endAngle: end, clockwise: false)
        p.addLine(to: c)
        p.closeSubpath()
        return p
    }
}

// MARK: - Time Wheel
struct TimeWheel: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    // Aesthetic colors
    private let active = Color.ochre
    private let inactive = Color.ochre.opacity(0.25)
    private let ring = Color.black.opacity(0.25)

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                // Outer ring
                Circle()
                    .stroke(ring, lineWidth: 6)

                // Four wedges (starting at top, going clockwise)
                ForEach(0..<4) { i in
                    let start = Angle(degrees: -90 + Double(i) * 90)   // -90° places start at 12 o'clock
                    let end   = Angle(degrees: -90 + Double(i+1) * 90)
                    let thisPeriod: DayPeriod = [.sunrise, .midday, .sunset, .night][i]
                    let isActive = DayPeriod.current(for: now) == thisPeriod

                    DonutWedge(start: start, end: end)
                        .fill(isActive ? active : inactive)
                        .overlay(
                            DonutWedge(start: start, end: end).stroke(ring, lineWidth: 1)
                        )
                }

                // Icons on the four cardinal spots
                VStack {
                    Text(DayPeriod.sunrise.icon).font(.system(size: 28)); Spacer()
                }
                .padding(.top, 12)

                VStack {
                    Spacer(); Text(DayPeriod.sunset.icon).font(.system(size: 28))
                }
                .padding(.bottom, 12)

                HStack {
                    Text(DayPeriod.night.icon).font(.system(size: 28)); Spacer()
                }
                .padding(.leading, 12)

                HStack {
                    Spacer(); Text(DayPeriod.midday.icon).font(.system(size: 28))
                }
                .padding(.trailing, 12)

                // Center totem (dingo)
                Circle()
                    .fill(Color.green.opacity(0.35))
                    .frame(width: size * 0.38, height: size * 0.38)
                    .overlay(
                        Image("dingo")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    )
            }
            .frame(width: size, height: size)
        }
        .onReceive(timer) { now = $0 } // update highlight about every 30s
        .accessibilityLabel(Text("\(DayPeriod.current(for: now).rawValue.capitalized) period is active"))
    }
}

