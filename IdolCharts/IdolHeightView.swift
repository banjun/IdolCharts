import SwiftUI
import Charts

struct IdolHeightView: View {
    var idols: [IdolHeight] = []

    var body: some View {
//        ScrollView(.horizontal) {
            Chart(idols, id: \.name) { idol in
                BarMark(
                    x: .value("name", idol.name),
                    y: .value("height", idol.height))
                .foregroundStyle(idol.nsColor.map {Color(nsColor :$0)} ?? Color.black)
            }
            .chartXAxis {
                AxisMarks { value in
                    let text = idols[value.index].name
                    AxisValueLabel(text, orientation: .vertical)
                }
            }
            .frame(minWidth: 512)
//        }
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
        .padding()
    }
}
