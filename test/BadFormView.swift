import SwiftUI

struct BadFormView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agree = false

    var body: some View {
        // ❌ No heading traits on the title
        Text("Create Account")
            .font(.system(size: 24, weight: .bold))

        // ❌ Form fields without labels
        VStack(spacing: 12) {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)

            // ❌ Color-only state indicator
            Circle()
                .fill(password.count >= 8 ? Color.green : Color.red)
                .frame(width: 12, height: 12)

            // ❌ No focus management in form

            // ❌ Tiny toggle touch target
            Toggle("I agree", isOn: $agree)
                .frame(width: 60)

            // ❌ Custom button without accessibility action
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("Continue")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
            .onTapGesture {
                print("continue")
            }
        }
        .padding()
    }
}
