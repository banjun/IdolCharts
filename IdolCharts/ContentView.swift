import SwiftUI
import Combine

final class Model: ObservableObject {
    @Published var brand: Brand = .ShinyColors
    @Published var idols: [IdolHeight] = []

    private var cancellables: Set<AnyCancellable> = []

    init(brand: Brand) {
        $brand.sink { [unowned self] _ in
            self.fetch()
        }.store(in: &cancellables)
        self.brand = brand
    }

    func fetch() {
        Task {
            let idols = try await IdolCharts.fetch(brand: brand)
            Task { @MainActor in
                self.idols = idols
            }
        }
    }
}

struct ContentView: View {
    @StateObject var model: Model

    var body: some View {
        VStack {
            Picker("Brand", selection: $model.brand) {
                ForEach(Brand.allCases) {
                    Text($0.rawValue)
                }
            }
            .padding()
            IdolHeightView(idols: model.idols)
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
