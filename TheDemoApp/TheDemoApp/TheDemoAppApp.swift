import SwiftUI
import CoreData

@main
struct TheDemoAppApp: App {
    let persistenceController = CoreDataManager.shared
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userManager.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
