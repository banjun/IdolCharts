import SwiftUI

@main
struct IdolChartsApp: App {
    // shoule be in Info.plist/NSUserActivityTypes
    static let lifeSizeIdolHeightActivityType = "jp.banjun.exp.IdolCharts.showIdolHeight"
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some Scene {
        WindowGroup {
            ContentView(model: .init(brand: .ShinyColors))
                .onContinueUserActivity(IdolChartsApp.lifeSizeIdolHeightActivityType) { activity in
                    Task {
                        let idolHeight = activity.userInfo?["IdolHeight"] as? Data
                        // openWindow(id: IdolChartsApp.lifeSizeIdolHeightActivityType, value: idolHeight)
                        await openImmersiveSpace(id: IdolChartsApp.lifeSizeIdolHeightActivityType, value: idolHeight)
                        // TODO: dismiss the window, or handle user activity other than this WindowGroup
                    }
                }
        }

        // this works with openWindow, but we don't use it for now
        // NOTE: window cannot be set on the floor (i.e. set height position)
//        WindowGroup(id: IdolChartsApp.lifeSizeIdolHeightActivityType, for: Data?.self) { $value in
//            if let idol = (value?.flatMap { try? JSONDecoder().decode(IdolHeight.self, from: $0) }) {
//                LifeSizeIdolHeightView(idol: idol)
//            } else {
//                Text("Error decoding value = \(String(describing: value))").font(.extraLargeTitle)
//            }
//        }
//        .windowStyle(.volumetric)
//        .defaultSize(width: 0.5, height: 2, depth: 0.5, in: .meters)
//        .handlesExternalEvents(matching: [IdolChartsApp.lifeSizeIdolHeightActivityType])

        ImmersiveSpace(id: IdolChartsApp.lifeSizeIdolHeightActivityType, for: Data?.self) { $value in
            if let idol = (value?.flatMap { try? JSONDecoder().decode(IdolHeight.self, from: $0) }) {
                LifeSizeIdolHeightView(idol: idol)
            } else {
                Text("Error decoding value = \(String(describing: value))").font(.extraLargeTitle)
            }
        }
    }
}
