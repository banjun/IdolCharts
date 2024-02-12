import SwiftUI
import Charts

struct IdolHeightView: View {
    var idols: [IdolHeight] = []
    @Binding var selectedIdol: IdolHeight?

    var body: some View {
        let chart = Chart(idols, id: \.name) { idol in
            let color = idol.cgColor.map {Color(cgColor: $0)} ?? Color.clear
            let isSelected = idol.name == selectedIdol?.name
            BarMark(
                x: .value("name", idol.name),
                y: .value("height", idol.height))
            .foregroundStyle(LinearGradient(colors: [color.opacity(0.75), color], startPoint: .init(x: 0, y: 1), endPoint: .init(x: 0, y: 0.25)))
            .cornerRadius(4)
            .annotation(position: .top) {
                Text(String(Int(idol.height))).font(.system(size: isSelected ? 20 : 8))
            }
        }
            .ignoresSafeArea()
            .chartXAxis {
                AxisMarks { value in
                    let text = idols[value.index].name
                    AxisValueLabel(text, orientation: .vertical)
                }
            }
        // chartXSelection behaves like DragGesture
        // .chartXSelection(value: $selectedName)
        if #available(iOS 17, macOS 14, visionOS 1, *) {
            return GeometryReader { g in
                chart.chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: min(idols.count, Int(g.size.width / 20)))
                    .chartGesture { proxy in
                        SpatialTapGesture().onEnded { value in
                            guard let plotFrame = proxy.plotFrame else { return }
                            let origin = g[plotFrame].origin
                            let location = CGPoint(x: value.location.x - origin.x, y: value.location.y - origin.y)
                            if let name = proxy.value(atX: location.x, as: String.self) {
                                // returned height value(at:) or value(atY:) locates gesture location, not the idol height
                                print("Location: \(name)")
                                selectedIdol = idols.first { $0.name == name }
                                // proxy.selectXValue(at: location.x)
                                // print("Location: \(name), \(height)")
                            }
                        }
                    }
                }
        } else {
            return ScrollView(.horizontal, showsIndicators: false) {
                chart.frame(minWidth: 20 * CGFloat(idols.count))
                    .padding()
            }
        }
    }
}

struct IdolHeightView_Previews: PreviewProvider {
    static var previews: some View {
        IdolHeightView(idols: [
            IdolHeight(name: "橘ありす", height: 141, color: "5881C1"),
            IdolHeight(name: "橘ありす+10", height: 151, color: "666666"),
            IdolHeight(name: "橘ありす+20", height: 161, color: "666666"),
            IdolHeight(name: "橘ありす+30", height: 171, color: "666666"),
            IdolHeight(name: "橘ありす+40", height: 181, color: "666666"),
        ], selectedIdol: .constant(nil))
    }
}
