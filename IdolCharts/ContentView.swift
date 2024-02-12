import SwiftUI
import Combine

@Observable
final class Model {
    var brand: Brand = .ShinyColors
    var idols: [IdolHeight] = []

    init(brand: Brand) {
        self.brand = brand
    }

    func fetch() {
        Task { @MainActor in
            idols = try await IdolCharts.fetch(brand: brand)
        }
        withObservationTracking { print(brand) } onChange: { [unowned self] in
            self.fetch()
        }
    }
}

extension View {
    @ViewBuilder func `if`(_ condition: Bool, @ViewBuilder transform: (Self) -> some View) -> some View {
        if condition { transform(self) } else { self }
    }
    @ViewBuilder func `ifLet`<T>(_ optional: T?, @ViewBuilder transform: (Self, T) -> some View) -> some View {
        `if`(optional != nil) { transform($0, optional!) }
    }
}

struct ContentView: View {
    @Bindable var model: Model
    @State private var draggedData: NSItemProvider?
    @State private var selectedIdol: IdolHeight?

    var body: some View {
        VStack {
            Picker("Brand", selection: $model.brand) {
                ForEach(Brand.allCases) {
                    Text($0.rawValue)
                }
            }
            .padding()

            IdolHeightView(idols: model.idols, selectedIdol: $selectedIdol)
                .ifLet(selectedIdol) { view, idol in
                    // NOTE: tips: when visionOS simulator stop working on starting drag, try killing SurfBoard process.
                    view.onDrag {
                        NSItemProvider(object: {
                            let activity = NSUserActivity(activityType: IdolChartsApp.lifeSizeIdolHeightActivityType)
                            activity.userInfo!["IdolHeight"] = try! JSONEncoder().encode(idol)
                            return activity
                        }())
                    } preview: {
                        IdolCircle(idol: idol)
                    }
                }
//                .onDrag {
//                    guard let idol = selectedIdol else { return .init() }
//                    print("Starting dragging of \(idol)")
////                    let userActivity = NSUserActivity(activityType: "jp.banjun.exp.idolchart.idolHeight")
////                    userActivity.userInfo?["Info"] = "TODO"
//                    let draggedData = NSItemProvider(object: "Test \(idol.name)" as NSItemProviderWriting)
//                    self.draggedData = draggedData
//                    return draggedData
//                }
        }.task {
            model.fetch()
        }
    }
}

struct IdolCircle: View {
    var idol: IdolHeight

    var body: some View {
        Text(idol.name)
            .padding(8)
            .foregroundStyle(Color.white)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(width: 128, height: 128)
            .background {
                Circle().fill(idol.cgColor.map {Color(cgColor: $0)} ?? .gray)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(Brand.allCases) {
                    ContentView(model: .init(brand: $0))
                }
                .frame(minHeight: 400)
            }
        }
    }
}
