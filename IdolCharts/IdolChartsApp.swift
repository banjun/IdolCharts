import SwiftUI

@main
struct IdolChartsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(model: .init(brand: .ShinyColors))
        }
    }
}
