import SwiftUI
import StoreKit

struct StoreView: View {
    @StateObject private var paymentManager = PaymentManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showingRestoreAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if paymentManager.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $selectedTab) {
                        // Dice Packs Tab
                        DicePacksView(paymentManager: paymentManager)
                            .tabItem {
                                Image(systemName: "dice.fill")
                                Text("Dice Packs")
                            }
                            .tag(0)
                        
                        // Features Tab
                        FeaturesView(paymentManager: paymentManager)
                            .tabItem {
                                Image(systemName: "star.fill")
                                Text("Features")
                            }
                            .tag(1)
                        
                        // Subscription Tab
                        SubscriptionView(paymentManager: paymentManager)
                            .tabItem {
                                Image(systemName: "crown.fill")
                                Text("Pro")
                            }
                            .tag(2)
                    }
                }
                
                if let errorMessage = paymentManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                }
            }
            .navigationTitle("Dice Store")
            .navigationBarItems(
                leading: Button("Restore") {
                    Task {
                        await paymentManager.restorePurchases()
                        showingRestoreAlert = true
                    }
                },
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .alert("Purchases Restored", isPresented: $showingRestoreAlert) {
                Button("OK") { }
            } message: {
                Text("Your previous purchases have been restored.")
            }
        }
        .task {
            await paymentManager.loadProducts()
        }
    }
}

// MARK: - Dice Packs View
struct DicePacksView: View {
    @ObservedObject var paymentManager: PaymentManager
    
    private let dicePackIds = ["premium_dice_pack_1", "premium_dice_pack_2", "premium_dice_pack_3"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dicePackIds, id: \.self) { productId in
                    if let product = paymentManager.getProduct(for: productId) {
                        DicePackCard(product: product, paymentManager: paymentManager)
                    } else {
                        ProductPlaceholder(title: productId.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Features View
struct FeaturesView: View {
    @ObservedObject var paymentManager: PaymentManager
    
    private let featureIds = ["advanced_stats", "custom_dice_creator", "data_export", "remove_ads"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(featureIds, id: \.self) { productId in
                    if let product = paymentManager.getProduct(for: productId) {
                        FeatureCard(product: product, paymentManager: paymentManager)
                    } else {
                        ProductPlaceholder(title: productId.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Subscription View
struct SubscriptionView: View {
    @ObservedObject var paymentManager: PaymentManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Pro subscription header
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                    
                    Text("DiceRoller Pro")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Unlock the full potential of your dice rolling experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Pro features list
                VStack(alignment: .leading, spacing: 16) {
                    ProFeatureRow(icon: "dice.fill", title: "Unlimited Dice", subtitle: "Roll as many dice as you want")
                    ProFeatureRow(icon: "paintbrush.fill", title: "Premium Themes", subtitle: "Access to all dice skins and themes")
                    ProFeatureRow(icon: "chart.bar.fill", title: "Advanced Analytics", subtitle: "Detailed statistics and insights")
                    ProFeatureRow(icon: "square.and.arrow.up.fill", title: "Data Export", subtitle: "Export your roll history")
                    ProFeatureRow(icon: "rectangle.slash.fill", title: "No Ads", subtitle: "Enjoy an ad-free experience")
                    ProFeatureRow(icon: "icloud.fill", title: "Cloud Sync", subtitle: "Sync across all your devices")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Subscription card
                if let product = paymentManager.getProduct(for: "pro_subscription") {
                    SubscriptionCard(product: product, paymentManager: paymentManager)
                } else {
                    ProductPlaceholder(title: "Pro Subscription")
                }
                
                // Trial info
                VStack(spacing: 8) {
                    Text("Start your free trial today!")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("7 days free, then $2.99/month. Cancel anytime.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .padding()
        }
    }
}

// MARK: - Product Cards
struct DicePackCard: View {
    let product: Product
    @ObservedObject var paymentManager: PaymentManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    if paymentManager.hasProduct(product.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            if !paymentManager.hasProduct(product.id) {
                Button(action: {
                    Task {
                        await paymentManager.purchaseProduct(product)
                    }
                }) {
                    Text("Buy Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(paymentManager.isLoading)
            } else {
                Button(action: {}) {
                    Text("Purchased")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                .disabled(true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct FeatureCard: View {
    let product: Product
    @ObservedObject var paymentManager: PaymentManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    if paymentManager.hasProduct(product.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            if !paymentManager.hasProduct(product.id) {
                Button(action: {
                    Task {
                        await paymentManager.purchaseProduct(product)
                    }
                }) {
                    Text("Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(paymentManager.isLoading)
            } else {
                Button(action: {}) {
                    Text("Purchased")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                .disabled(true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SubscriptionCard: View {
    let product: Product
    @ObservedObject var paymentManager: PaymentManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("All premium features included")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("per month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                Task {
                    await paymentManager.createSubscription(productId: product.id)
                }
            }) {
                Text("Start Free Trial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(paymentManager.isLoading)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow, lineWidth: 2)
        )
    }
}

// MARK: - Helper Views
struct ProductPlaceholder: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
