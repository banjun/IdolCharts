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
