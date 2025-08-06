import Foundation
import CryptoKit

struct User: Codable {
    var name: String
    var email: String
    var mobile: String
    var password: String
    
    static func encryptPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^(?=.{4,25}@)[A-Za-z0-9+_.-]+@(?=.{4,25})[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validateMobile(_ mobile: String) -> Bool {
        // Indian mobile numbers:
        // 1. Must be exactly 10 digits
        // 2. Must start with 6, 7, 8, or 9
        // 3. No special characters or spaces allowed
        let mobileRegex = "^[6-9][0-9]{9}$"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        
        // First remove any spaces or special characters
        let cleanedNumber = mobile.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Check if the cleaned number matches Indian mobile format
        return mobilePredicate.evaluate(with: cleanedNumber)
    }
    
    static func validatePassword(_ password: String, userName: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z].*[A-Z])(?=.*\\d.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,15}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let containsName = password.lowercased().contains(userName.lowercased())
        return passwordPredicate.evaluate(with: password) && !containsName
    }
}
