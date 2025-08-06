import SwiftUI
import CoreData

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var userManager = UserManager.shared
    @State private var emailOrMobile: String = ""
    @State private var password: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showSignUp = false
    @State private var showDebugInfo = false // For development purposes
    @State private var isProcess = false // For development purposes
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: [.brown,.cyan,.green],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack(spacing: 20) {
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding(.bottom, 30)
                        .foregroundStyle(Color.white)
                    HStack{
                        TextField("Email or Mobile", text: $emailOrMobile)
                            .foregroundStyle(Color.white.opacity(0.8))
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

                    HStack{
                        SecureField("Password", text: $password)
                            .padding()
                            .foregroundStyle(Color.white.opacity(0.8))

                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.white
                                    .opacity(0.5),
                                lineWidth: 1
                            )
                            
                    }
                    
                    Button(action: login) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button("Create Account") {
                        showSignUp = true
                    }
                    .foregroundColor(.blue)
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    
                }
                
                .padding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    HomeView()
                }
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView()
                }
                .onAppear {

                }
                if isProcess {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .background(Color.white.opacity(0.3))
                }
            }
        }
    }
    
    private func login() {
        // Validate input
        isProcess = true
        guard !emailOrMobile.isEmpty && !password.isEmpty else {
            showError = true
            errorMessage = "Please fill in all fields"
            isProcess = false
            return
        }
        
        // Validate email/mobile format
        let isEmail = emailOrMobile.contains("@")
        if isEmail {
            if !User.validateEmail(emailOrMobile) {
                showError = true
                errorMessage = "Invalid email format"
                isProcess = false
                return
            }
        } else {
            if !User.validateMobile(emailOrMobile) {
                showError = true
                errorMessage = "Invalid mobile number"
                isProcess = false
                return
            }
        }
        
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        
        let predicate: NSPredicate
        if isEmail {
            predicate = NSPredicate(format: "email == %@", emailOrMobile)
        } else {
            predicate = NSPredicate(format: "mobileNo == %@", emailOrMobile)
        }
        request.predicate = predicate
        
        do {
            let users = try viewContext.fetch(request)
            print("Found \(users.count) matching users") // Debug info
            
            if let user = users.first {
                let encryptedPassword = User.encryptPassword(password)
                print("Checking password match") // Debug info
                print("Input (encrypted): \(encryptedPassword)")
                print("Stored: \(user.password ?? "nil")")
                
                if user.password == encryptedPassword {
                    print("Login successful for user: \(user.name ?? "unknown")") // Debug info
                    userManager.login(userEmail: user.email ?? "")
                    showError = false
                    UserDefaults.standard.set(user.email, forKey: "lastLoggedInUser")
                    isProcess = false
                } else {
                    showError = true
                    errorMessage = "Invalid password"
                    isProcess = false
                }
            } else {
                showError = true
                errorMessage = "User not found"
                isProcess = false
            }
        } catch {
            print("CoreData fetch error: \(error)") // Debug info
            showError = true
            errorMessage = "Error checking credentials"
            isProcess = false
        }
    }
    
    private func checkStoredUsers() {
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        do {
            let users = try viewContext.fetch(request)
            print("Total stored users: \(users.count)")
            users.forEach { user in
                print("User: \(user.name ?? "unknown"), Email: \(user.email ?? "unknown"), Mobile: \(user.mobileNo ?? "unknown")")
            }
            showDebugInfo = true
        } catch {
            print("Error fetching users: \(error)")
        }
    }
    
    private var storedUsersDebugView: some View {
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        let users = (try? viewContext.fetch(request)) ?? []
        
        return ForEach(users, id: \.email) { user in
            VStack(alignment: .leading) {
                Text("Name: \(user.name ?? "unknown")")
                Text("Email: \(user.email ?? "unknown")")
                Text("Mobile: \(user.mobileNo ?? "unknown")")
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    LoginView()
}
