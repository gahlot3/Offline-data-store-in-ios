//
//  TheDemoAppTests.swift
//  TheDemoAppTests
//
//  Created by Emizen on 06/08/25.
//

import Testing
import XCTest

@testable import TheDemoApp

struct TheDemoAppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}


class LoginViewModel {
    func validateEmail(_ email: String) -> Bool {
     
        return email.range(of: "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil
    }
    
    func validateCredentials(email: String, password: String) -> Bool {
           return email.contains("@") && password.count >= 6
       }
}

final class LoginViewModelTestes: XCTestCase {
    var viewModel: LoginViewModel!

    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testValidEmail() {
           XCTAssertTrue(viewModel.validateEmail("test@example.com"))
       }

    func testInvalidEmail() {
            XCTAssertFalse(viewModel.validateEmail("invalid-email"))
        }

}
