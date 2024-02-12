import SwiftUI
import RealityKit

struct LifeSizeIdolHeightView: View {
    var idol: IdolHeight
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.physicalMetrics) private var physicalMetrics

    var body: some View {
        RealityView { content, attachments in
//            let barMaterials: [any RealityKit.Material] = [RealityKit.Material.Color(idol)]
//            let idolColorMaterial = PhysicallyBasedMaterial()
//            idolColorMaterial.baseColor = physical
//            let bar = ModelEntity(mesh: .generateBox(width: 0.5, height: .init(idol.height), depth: 0.5), materials: [PhysicallyBasedMaterial().baseColor])
//            content.add(bar)

            let idol = attachments.entity(for: "idol")!
            idol.setPosition(.init(x: 0.5, y: 0, z: -1), relativeTo: nil)
            content.add(idol)

            let dismiss = attachments.entity(for: "dismiss")!
            dismiss.setPosition(.init(x: -0.5, y: 0, z: -0.5), relativeTo: nil)
            content.add(dismiss)
        } attachments: {
            Attachment(id: "idol") {
                AnyView(BottomAlignedLayout(avoidClippingByDoubleHeight: true) {
                    HeightView(idol: idol)
                })
            }

            Attachment(id: "dismiss") {
                AnyView(BottomAlignedLayout(avoidClippingByDoubleHeight: true) {
                    Button("Dismiss") {
                        Task { await dismissImmersiveSpace() }
                    }
                    .frame(height: physicalMetrics.convert(149, from: .centimeters))
                })
            }
        }
    }

    struct HeightView: View {
        var idol: IdolHeight
        @Environment(\.physicalMetrics) private var physicalMetrics

        var body: some View {
            ZStack {
                VStack {
                    Text("\(Int(idol.height)) cm")
                        .font(.largeTitle)
                        .padding()
                        .glassBackgroundEffect()
                    RoundedRectangle(cornerRadius: physicalMetrics.convert(10, from: .centimeters))
                        .fill(Color(idol))
                        .frame(width: physicalMetrics.convert(50, from: .centimeters),
                               height: physicalMetrics.convert(idol.height, from: .centimeters))
//                        .frame(depth: physicalMetrics.convert(50, from: .centimeters))
                }
                Text(idol.name)
                    .font(.extraLargeTitle)
            }
        }
    }
}

#Preview {
    LifeSizeIdolHeightView(idol: IdolHeight(name: "橘ありす", height: 141, color: "5881C1"))
}
