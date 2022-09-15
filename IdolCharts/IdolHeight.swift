import Foundation
import SwiftSparql
import CoreGraphics

struct IdolHeight: Codable {
    var name: String
    var height: Double
    var color: String?
    var age: String?
}

extension IdolHeight {
    var cgColor: CGColor? {
        guard let hex = (color.flatMap {Int($0, radix: 16)}) else { return nil }
        return CGColor(srgbRed: CGFloat(hex >> 16 & 0xff) / 255,
                       green: CGFloat(hex >> 8 & 0xff) / 255,
                       blue: CGFloat(hex >> 0 & 0xff) / 255,
                       alpha: 1)
    }
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
        limit: 1000)
    return try await Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: query).fetch()
}
