import Foundation
import CoreData

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var isLoggedIn: Bool = false
    
    private init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        if let userEmail = UserDefaults.standard.string(forKey: "lastLoggedInUser") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    func login(userEmail: String) {
        UserDefaults.standard.set(userEmail, forKey: "lastLoggedInUser")
        isLoggedIn = true
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUser")
        isLoggedIn = false
    }
}