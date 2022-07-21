//
//  ContentView.swift
//  IdolCharts
//
//  Created by BAN Jun on 2022/06/08.
//

import SwiftUI
import Charts
import SwiftSparql
import Combine

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

enum Brand: String, CaseIterable, Identifiable {
    var id: Self { self }
    case _765AS = "765AS"
    case CinderellaGirls
    case MillionLive
    case SideM
    case ShinyColors
}

func fetch(brand: Brand) async throws -> [IdolHeight] {
    let varS = Var("s")
    let varName = Var("name")
    let varHeight = Var("height")
    let varColor = Var("color")
    let varAge = Var("age")
    let query = SelectQuery(
        where: WhereClause(patterns:
            subject(varS)
                .rdfTypeIsImasIdol()
                .imasBrand(is: .literal(brand.rawValue, lang: "en"))
                .rdfsLabel(is: varName)
                .schemaHeight(is: varHeight)
                .optional { $0
                    .imasColor(is: varColor)
                    .foafAge(is: varAge)
                }
                .triples),
    //    having: [.logical(varHeight <= 149)],
        order: [.by(varHeight)],
        limit: 52)
    return try await Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: query).fetch()
}

final class Model: ObservableObject {
    @Published var brand: Brand = .ShinyColors
    @Published var idols: [IdolHeight] = []

    private var cancellables: Set<AnyCancellable> = []

    init() {
        $brand.prepend(brand).sink { [unowned self] _ in
            self.fetch()
        }.store(in: &cancellables)
    }

    func fetch() {
        Task {
            let idols = try await IdolCharts.fetch(brand: brand)
            await MainActor.run {
                self.idols = idols
            }
        }
    }
}

struct ContentView: View {
    @StateObject var model: Model = .init()

    var body: some View {
        VStack {
            Picker("Brand", selection: $model.brand) {
                ForEach(Brand.allCases) {
                    Text($0.rawValue)
                }
            }
            IdolHeightView(idols: model.idols)
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
