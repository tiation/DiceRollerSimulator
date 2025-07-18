import Foundation
import StoreKit
import Combine

// MARK: - Payment Manager
@MainActor
class PaymentManager: NSObject, ObservableObject {
    @Published var availableProducts: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stripeCustomerId: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiClient = APIClient()
    
    // Product IDs matching backend configuration
    private let productIDs: Set<String> = [
        "premium_dice_pack_1",
        "premium_dice_pack_2", 
        "premium_dice_pack_3",
        "advanced_stats",
        "custom_dice_creator",
        "data_export",
        "remove_ads",
        "pro_subscription"
    ]
    
    override init() {
        super.init()
        
        // Start listening for store changes
        SKPaymentQueue.default().add(self)
        
        // Load products and check purchase status
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            availableProducts = try await Product.products(for: productIDs)
            print("✅ Loaded \(availableProducts.count) products")
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Methods
    func purchaseProduct(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await handleSuccessfulPurchase(transaction)
                await transaction.finish()
                
            case .userCancelled:
                print("User cancelled purchase")
                
            case .pending:
                print("Purchase pending")
                
            @unknown default:
                print("Unknown purchase result")
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("❌ Purchase error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Stripe Integration
    func createStripeCustomer(email: String? = nil) async {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        let customerData = CreateCustomerRequest(
            email: email,
            name: nil,
            deviceId: deviceId
        )
        
        do {
            let response = try await apiClient.createStripeCustomer(customerData)
            stripeCustomerId = response.customer.id
            print("✅ Created Stripe customer: \(response.customer.id)")
        } catch {
            print("❌ Failed to create Stripe customer: \(error)")
        }
    }
    
    func purchaseWithStripe(productId: String) async {
        guard let customerId = stripeCustomerId else {
            await createStripeCustomer()
            guard let customerId = stripeCustomerId else {
                errorMessage = "Failed to create customer"
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = PaymentIntentRequest(
                productId: productId,
                customerId: customerId
            )
            
            let response = try await apiClient.createPaymentIntent(request)
            
            // Here you would integrate with Stripe iOS SDK
            // For now, we'll simulate successful payment
            print("✅ Payment intent created: \(response.clientSecret)")
            
            // Add to purchased products
            purchasedProducts.insert(productId)
            
        } catch {
            errorMessage = "Stripe payment failed: \(error.localizedDescription)"
            print("❌ Stripe payment error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Subscription Management
    func createSubscription(productId: String) async {
        guard let customerId = stripeCustomerId else {
            await createStripeCustomer()
            guard let customerId = stripeCustomerId else {
                errorMessage = "Failed to create customer"
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = SubscriptionRequest(
                customerId: customerId,
                productId: productId
            )
            
            let response = try await apiClient.createSubscription(request)
            print("✅ Subscription created: \(response.subscription.id)")
            
        } catch {
            errorMessage = "Subscription creation failed: \(error.localizedDescription)"
            print("❌ Subscription error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: Transaction) async {
        purchasedProducts.insert(transaction.productID)
        
        // Track analytics
        await apiClient.trackPurchase(
            userId: getUserId(),
            productId: transaction.productID,
            amount: 0, // Will be filled from product info
            timestamp: Date()
        )
        
        print("✅ Purchase successful: \(transaction.productID)")
    }
    
    // MARK: - Purchase Status Check
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedProducts.insert(transaction.productID)
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    private func getUserId() -> String {
        // Get user ID from your auth system or use device ID
        return UIDevice.current.identifierForVendor?.uuidString ?? "anonymous"
    }
    
    func hasProduct(_ productId: String) -> Bool {
        return purchasedProducts.contains(productId)
    }
    
    func getProduct(for id: String) -> Product? {
        return availableProducts.first { $0.id == id }
    }
}

// MARK: - SKPaymentTransactionObserver
extension PaymentManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // Handle legacy StoreKit transactions if needed
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Legacy purchase successful: \(transaction.payment.productIdentifier)")
                queue.finishTransaction(transaction)
            case .failed:
                print("Legacy purchase failed: \(transaction.error?.localizedDescription ?? "Unknown error")")
                queue.finishTransaction(transaction)
            case .restored:
                print("Legacy purchase restored: \(transaction.payment.productIdentifier)")
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
    }
}

// MARK: - Payment Error
enum PaymentError: Error, LocalizedError {
    case unverifiedTransaction
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            return "The transaction could not be verified"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
