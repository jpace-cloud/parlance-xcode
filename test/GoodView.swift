import SwiftUI

struct GoodView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // ✅ Dynamic type heading with trait
            Text("Search products")
                .font(.title)
                .accessibilityAddTraits(.isHeader)

            // ✅ Labelled text field with focus management
            VStack(alignment: .leading, spacing: 4) {
                Text("Search")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Search products...", text: $searchText)
                    .focused($isSearchFocused)
                    .accessibilityLabel("Search products")
                    .frame(minHeight: 44)
            }

            // ✅ Accessible image
            Image("product-photo")
                .resizable()
                .frame(height: 200)
                .accessibilityLabel("Product photograph showing the item from the front")

            // ✅ Decorative image marked correctly
            Image("decorative-divider")
                .accessibilityHidden(true)

            // ✅ Proper button with adequate size
            Button(action: { print("added") }) {
                Label("Add to cart", systemImage: "cart.badge.plus")
            }
            .frame(minWidth: 44, minHeight: 44)

            // ✅ Status with text AND color
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("In stock")
                    .font(.body)
                    .foregroundStyle(.green)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Product status: In stock")
        }
        .padding()
    }
}
