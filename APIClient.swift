import Foundation
import UIKit

// MARK: - API Client
class APIClient {
    private let baseURL: String
    private let session: URLSession
    
    init() {
        #if DEBUG
        self.baseURL = "http://localhost:3000/api/v1"
        #else
        self.baseURL = "https://your-production-api.com/api/v1"
        #endif
        
        self.session = URLSession.shared
    }
    
    // MARK: - Stripe API Calls
    func createStripeCustomer(_ request: CreateCustomerRequest) async throws -> CreateCustomerResponse {
        let url = URL(string: "\(baseURL)/stripe/create-customer")!
        return try await post(url: url, body: request)
    }
    
    func createPaymentIntent(_ request: PaymentIntentRequest) async throws -> PaymentIntentResponse {
        let url = URL(string: "\(baseURL)/stripe/create-payment-intent")!
        return try await post(url: url, body: request)
    }
    
    func createSubscription(_ request: SubscriptionRequest) async throws -> SubscriptionResponse {
        let url = URL(string: "\(baseURL)/stripe/create-subscription")!
        return try await post(url: url, body: request)
    }
    
    func getProducts() async throws -> ProductsResponse {
        let url = URL(string: "\(baseURL)/stripe/products")!
        return try await get(url: url)
    }
    
    // MARK: - User API Calls
    func registerUser(_ request: RegisterUserRequest) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/users/register")!
        return try await post(url: url, body: request)
    }
    
    func loginUser(_ request: LoginUserRequest) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/users/login")!
        return try await post(url: url, body: request)
    }
    
    func guestLogin(_ request: GuestLoginRequest) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/users/guest-login")!
        return try await post(url: url, body: request)
    }
    
    // MARK: - Analytics API Calls
    func trackDiceRoll(userId: String, diceType: String, result: [Int], timestamp: Date) async {
        let request = DiceRollAnalyticsRequest(
            userId: userId,
            diceType: diceType,
            result: result,
            timestamp: timestamp
        )
        
        let url = URL(string: "\(baseURL)/analytics/dice-roll")!
        do {
            let _: EmptyResponse = try await post(url: url, body: request)
        } catch {
            print("❌ Failed to track dice roll: \(error)")
        }
    }
    
    func trackPurchase(userId: String, productId: String, amount: Double, timestamp: Date) async {
        let request = PurchaseAnalyticsRequest(
            userId: userId,
            productId: productId,
            amount: amount,
            timestamp: timestamp
        )
        
        let url = URL(string: "\(baseURL)/analytics/purchase")!
        do {
            let _: EmptyResponse = try await post(url: url, body: request)
        } catch {
            print("❌ Failed to track purchase: \(error)")
        }
    }
    
    func trackSession(userId: String, sessionDuration: TimeInterval, screenTime: TimeInterval, timestamp: Date) async {
        let request = SessionAnalyticsRequest(
            userId: userId,
            sessionDuration: sessionDuration,
            screenTime: screenTime,
            timestamp: timestamp
        )
        
        let url = URL(string: "\(baseURL)/analytics/session")!
        do {
            let _: EmptyResponse = try await post(url: url, body: request)
        } catch {
            print("❌ Failed to track session: \(error)")
        }
    }
    
    // MARK: - Apple API Calls
    func verifyAppleReceipt(_ request: AppleReceiptRequest) async throws -> AppleReceiptResponse {
        let url = URL(string: "\(baseURL)/apple/verify-receipt")!
        return try await post(url: url, body: request)
    }
    
    func appleSignIn(_ request: AppleSignInRequest) async throws -> AppleSignInResponse {
        let url = URL(string: "\(baseURL)/apple/signin")!
        return try await post(url: url, body: request)
    }
    
    // MARK: - Generic HTTP Methods
    private func get<T: Codable>(url: URL) async throws -> T {
        let request = createRequest(url: url, method: "GET")
        return try await performRequest(request)
    }
    
    private func post<T: Codable, U: Codable>(url: URL, body: T) async throws -> U {
        var request = createRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await performRequest(request)
    }
    
    private func createRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication header if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorData["error"] as? String {
                throw APIError.serverError(errorMessage)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ JSON decoding error: \(error)")
            print("❌ Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error with code: \(code)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Request Models
struct CreateCustomerRequest: Codable {
    let email: String?
    let name: String?
    let deviceId: String
}

struct PaymentIntentRequest: Codable {
    let productId: String
    let customerId: String
}

struct SubscriptionRequest: Codable {
    let customerId: String
    let productId: String
}

struct RegisterUserRequest: Codable {
    let email: String
    let password: String
    let deviceId: String
}

struct LoginUserRequest: Codable {
    let email: String
    let password: String
}

struct GuestLoginRequest: Codable {
    let deviceId: String
}

struct DiceRollAnalyticsRequest: Codable {
    let userId: String
    let diceType: String
    let result: [Int]
    let timestamp: Date
}

struct PurchaseAnalyticsRequest: Codable {
    let userId: String
    let productId: String
    let amount: Double
    let timestamp: Date
}

struct SessionAnalyticsRequest: Codable {
    let userId: String
    let sessionDuration: TimeInterval
    let screenTime: TimeInterval
    let timestamp: Date
}

struct AppleReceiptRequest: Codable {
    let receiptData: String
    let transactionId: String
}

struct AppleSignInRequest: Codable {
    let identityToken: String
    let authorizationCode: String
}

// MARK: - Response Models
struct CreateCustomerResponse: Codable {
    let success: Bool
    let customer: StripeCustomer
}

struct StripeCustomer: Codable {
    let id: String
    let email: String?
}

struct PaymentIntentResponse: Codable {
    let success: Bool
    let clientSecret: String
    let product: BackendProduct
}

struct BackendProduct: Codable {
    let name: String
    let price: Int
    let description: String
    let type: String
}

struct SubscriptionResponse: Codable {
    let success: Bool
    let subscription: StripeSubscription
}

struct StripeSubscription: Codable {
    let id: String
    let status: String
    let current_period_end: TimeInterval
}

struct AuthResponse: Codable {
    let success: Bool
    let user: User
    let token: String
}

struct User: Codable {
    let id: Int
    let email: String?
    let deviceId: String
    let isGuest: Bool?
}

struct ProductsResponse: Codable {
    let success: Bool
    let products: [BackendProduct]
}

struct AppleReceiptResponse: Codable {
    let success: Bool
    let purchase: ApplePurchase?
}

struct ApplePurchase: Codable {
    let product_id: String
    let transaction_id: String
    let purchase_date: String
    let expires_date: String?
}

struct AppleSignInResponse: Codable {
    let success: Bool
    let user: AppleUser
}

struct AppleUser: Codable {
    let id: String
    let email: String?
    let email_verified: Bool?
}

struct EmptyResponse: Codable {
    let success: Bool
    let message: String?
}
