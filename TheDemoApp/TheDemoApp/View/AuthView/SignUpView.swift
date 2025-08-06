import SwiftUI
import CoreData

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name = ""
    @State private var mobile = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var signUpComplete = false
    @State private var isProcess = false
    @State private var showSuccess = false
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [.brown,.cyan,.green],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            ScrollView{
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .padding(.bottom, 30)
                    
                    VStack(alignment: .leading,spacing: 2) {
                        Text("Enter name:")
                        HStack{
                            TextField("Name", text: $name)
                                .padding()
                                .font(.system(size: 17,weight: .semibold))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.white
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        }
                    }
                    VStack(alignment: .leading,spacing: 2) {
                        Text("Enter mobile number:")
                        HStack{
                            TextField("Mobile", text: $mobile)
                                .font(.system(size: 17,weight: .semibold))
                                .keyboardType(.phonePad)
                                .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.white
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        }
                    }
                    
                    VStack(alignment: .leading,spacing: 2) {
                        Text("Enter email:")
                        HStack{
                            TextField("Email", text: $email)
                                .font(.system(size: 17,weight: .semibold))
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.white
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        }
                    }
                    
                    VStack(alignment: .leading,spacing: 2) {
                        Text("Enter password:")
                        HStack{
                            SecureField("Password", text: $password)
                                .font(.system(size: 17,weight: .semibold))
                                .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.white
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        }
                        
                    }
                    
                    VStack(alignment: .leading,spacing: 2) {
                        Text("Confirm password:")
                        HStack{
                            SecureField("Confirm Password", text: $confirmPassword)
                                .font(.system(size: 17,weight: .semibold))
                                .padding()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.white
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        }
                        
                    }
                    Button(action: signUp) {
                        Text("Sign Up")
                            .font(.system(size: 17,weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal)
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            if isProcess {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .background(Color.white.opacity(0.3))
            }
            
            if showSuccess {
                VStack{
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Sign Up successful!")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
            }
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private func signUp() {
        
        guard !name.isEmpty, !mobile.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showError = true
            errorMessage = "Please fill in all fields"
            
            return
        }
        
        
        guard password == confirmPassword else {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        
        guard User.validateEmail(email) else {
            showError = true
            errorMessage = "Invalid email format"
            return
        }
        
        // Validate mobile
        guard User.validateMobile(mobile) else {
            showError = true
            errorMessage = "Invalid mobile number"
            return
        }
        
        // Validate password
        guard User.validatePassword(password, userName: name) else {
            showError = true
            errorMessage = "Password must be 8-15 characters, start with lowercase, contain 2 uppercase letters, 2 digits, 1 special character, and not contain your name"
            return
        }
        
        // Check if user already exists
        if CoreDataManager.shared.userExists(email: email) {
            showError = true
            errorMessage = "User with this email already exists"
            return
        }
        
        isProcess = true
        // Create new user in CoreData
        let newUser = Users(context: CoreDataManager.shared.context)
        newUser.name = name
        newUser.email = email
        newUser.mobileNo = mobile
        newUser.password = User.encryptPassword(password)
        
        // Save to CoreData
        do {
            try CoreDataManager.shared.context.save()
            withAnimation(.spring()) {
                showSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut) {
                    showSuccess = false
                    dismiss()
                }
            }
            
            isProcess = false
        } catch {
            showError = true
            errorMessage = "Error saving user data. Please try again."
            isProcess = false
        }
    }
}

#Preview {
    SignUpView()
}
