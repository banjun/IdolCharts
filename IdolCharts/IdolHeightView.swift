import SwiftUI
import Charts

struct IdolHeightView: View {
    var idols: [IdolHeight] = []

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart(idols, id: \.name) { idol in
                let color = idol.cgColor.map {Color(cgColor: $0)} ?? Color.clear
                BarMark(
                    x: .value("name", idol.name),
                    y: .value("height", idol.height))
                .foregroundStyle(LinearGradient(colors: [color.opacity(0.75), color], startPoint: .init(x: 0, y: 1), endPoint: .init(x: 0, y: 0.25)))
                .cornerRadius(4)
                .annotation(position: .top) {
                    Text(String(Int(idol.height))).font(.system(size: 8))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    let text = idols[value.index].name
                    AxisValueLabel(text, orientation: .vertical)
                }
            }
            .frame(minWidth: 20 * CGFloat(idols.count))
            .padding()
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
        ])
    }
}
