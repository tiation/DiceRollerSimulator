import SwiftUI

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let itemSpacing: CGFloat = spacing
        
        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            ForEach(Array(data.enumerated()), id: \.element) { index, element in
                content(element)
                    .alignmentGuide(alignment, computeValue: { dimension in
                        // Check if this item would exceed the view's width
                        let isNewRow = (width + dimension.width + (index < data.count - 1 ? itemSpacing : 0)) > geometry.size.width
                        if isNewRow {
                            width = 0
                            height -= dimension.height + itemSpacing
                        }
                        
                        let result = width
                        
                        if index == data.count - 1 {
                            width = 0 // Reset for next layout pass
                        } else {
                            width += dimension.width + itemSpacing
                        }
                        
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { dimension in
                        let result = height
                        
                        if index == data.count - 1 {
                            height = 0 // Reset for next layout pass
                        }
                        
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    @State private var totalHeight: CGFloat = .zero
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
