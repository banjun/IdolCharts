//
//  ContentView.swift
//  IdolCharts
//
//  Created by BAN Jun on 2022/06/08.
//

import SwiftUI
import Charts
import SwiftSparql

struct IdolHeight: Codable {
    var name: String
    var height: Double
    var color: String?
    var age: String?
}
extension IdolHeight {
    var nsColor: NSColor? {
        guard let hex = (color.flatMap {Int($0, radix: 16)}) else { return nil }
        return NSColor(
            calibratedRed: CGFloat(hex >> 16 & 0xff) / 255,
            green: CGFloat(hex >> 8 & 0xff) / 255,
            blue: CGFloat(hex >> 0 & 0xff) / 255,
            alpha: 1)}
}

let varS = Var("s")
let varName = Var("name")
let varHeight = Var("height")
let varColor = Var("color")
let varAge = Var("age")

let query = SelectQuery(
    where: WhereClause(patterns:
        subject(varS)
            .rdfTypeIsImasIdol()
            .imasBrand(is: .literal("ShinyColors", lang: "en"))
            .rdfsLabel(is: varName)
            .schemaHeight(is: varHeight)
            .optional { $0
                .imasColor(is: varColor)
                .foafAge(is: varAge)
            }
            .triples),
//    having: [.logical(varHeight <= 149)],
    order: [.by(varHeight)],
    limit: 100)

func fetch() async throws -> [IdolHeight] {
    try await withCheckedThrowingContinuation { c in
        Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: query)
            .fetch()
            .onComplete {
                c.resume(with: $0)
            }
    }
}

struct ContentView: View {
    @State var idols: [IdolHeight] = []

    var body: some View {
        VStack {
//            ScrollView(.horizontal) {
                Chart(idols, id: \.name) { idol in
                    BarMark(
                        x: .value("name", idol.name),
                        y: .value("height", idol.height))
                    .foregroundStyle(idol.nsColor.map {Color(nsColor :$0)} ?? Color.black)
                }
                .chartXAxis {
                    AxisMarks { value in
                        let text = idols[value.index].name
                        AxisValueLabel(text.reduce(into: "") {$0 += "\n" + String($1)}, collisionResolution: .greedy, orientation: .angle(.degrees(45)))
                    }
                }
//                .frame(minWidth: 1200)
//            }
        }.onAppear {
            Task {
                self.idols = try await fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
