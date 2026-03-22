import SwiftUI

struct SampleView: View {
    @State private var username = ""
    @State private var isError = false

    var body: some View {
        VStack(spacing: 16) {
            // ❌ Image without accessibilityLabel
            Image("hero-banner")
                .resizable()
                .frame(height: 200)

            // ❌ Hardcoded font size instead of dynamic type
            Text("Welcome Back")
                .font(.system(size: 28, weight: .bold))

            // ❌ Color-only error indicator
            TextField("Username", text: $username)
                .foregroundColor(isError ? .red : .primary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            // ❌ No label on text field (just placeholder)
            TextField("Enter your email", text: .constant(""))
                .padding()

            // ❌ Button too small for touch target
            Button("Submit") {
                print("tapped")
            }
            .frame(width: 30, height: 20)

            // ❌ Tap gesture without keyboard equivalent
            Text("Terms of Service")
                .foregroundColor(.blue)
                .onTapGesture {
                    print("open terms")
                }

            // ✅ Correct: accessible image
            Image(systemName: "checkmark.circle")
                .accessibilityLabel("Success indicator")

            // ✅ Correct: dynamic type
            Text("This uses dynamic type")
                .font(.body)

            // ✅ Correct: proper button size
            Button("Accessible Button") {
                print("tapped")
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding()
    }
}
