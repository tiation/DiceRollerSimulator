import Foundation
import UIKit

@MainActor
class AnalyticsManager: ObservableObject {
    private let apiClient = APIClient()
    private var sessionStartTime: Date?
    private var appDidBecomeActiveTime: Date?
    
    init() {
        sessionStartTime = Date()
        setupNotifications()
    }
    
    // MARK: - Notification Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        appDidBecomeActiveTime = Date()
        sessionStartTime = Date()
    }
    
    @objc private func appWillResignActive() {
        Task {
            await trackSession()
        }
    }
    
    // MARK: - Analytics Tracking
    func trackDiceRoll(diceType: String, result: [Int], timestamp: Date) async {
        let userId = getUserId()
        
        await apiClient.trackDiceRoll(
            userId: userId,
            diceType: diceType,
            result: result,
            timestamp: timestamp
        )
        
        print("📊 Tracked dice roll: \(diceType), results: \(result)")
    }
    
    func trackPurchase(productId: String, amount: Double, timestamp: Date) async {
        let userId = getUserId()
        
        await apiClient.trackPurchase(
            userId: userId,
            productId: productId,
            amount: amount,
            timestamp: timestamp
        )
        
        print("💰 Tracked purchase: \(productId), amount: \(amount)")
    }
    
    func trackSession() async {
        guard let sessionStart = sessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(sessionStart)
        let screenTime = sessionDuration // Simplified - in real app, track actual screen time
        let userId = getUserId()
        
        await apiClient.trackSession(
            userId: userId,
            sessionDuration: sessionDuration,
            screenTime: screenTime,
            timestamp: Date()
        )
        
        print("⏱️ Tracked session: \(sessionDuration) seconds")
    }
    
    // MARK: - User Event Tracking
    func trackCustomEvent(eventName: String, parameters: [String: Any] = [:]) {
        print("🎯 Custom event: \(eventName), parameters: \(parameters)")
        
        // In a real app, you would send this to your analytics service
        // For now, we'll just log it
        let eventData = [
            "event": eventName,
            "parameters": parameters,
            "timestamp": Date().timeIntervalSince1970,
            "userId": getUserId()
        ] as [String: Any]
        
        // Store locally or send to analytics service
        storeEvent(eventData)
    }
    
    func trackScreenView(screenName: String) {
        trackCustomEvent(eventName: "screen_view", parameters: ["screen_name": screenName])
    }
    
    func trackButtonTap(buttonName: String, screen: String) {
        trackCustomEvent(eventName: "button_tap", parameters: [
            "button_name": buttonName,
            "screen": screen
        ])
    }
    
    func trackDiceTypeSelection(diceType: String) {
        trackCustomEvent(eventName: "dice_type_selected", parameters: ["dice_type": diceType])
    }
    
    func trackStoreVisit() {
        trackCustomEvent(eventName: "store_visit")
    }
    
    func trackPurchaseAttempt(productId: String) {
        trackCustomEvent(eventName: "purchase_attempt", parameters: ["product_id": productId])
    }
    
    func trackPurchaseSuccess(productId: String, amount: Double) {
        trackCustomEvent(eventName: "purchase_success", parameters: [
            "product_id": productId,
            "amount": amount
        ])
        
        Task {
            await trackPurchase(productId: productId, amount: amount, timestamp: Date())
        }
    }
    
    func trackPurchaseFailure(productId: String, error: String) {
        trackCustomEvent(eventName: "purchase_failure", parameters: [
            "product_id": productId,
            "error": error
        ])
    }
    
    // MARK: - User Properties
    func setUserProperty(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: "analytics_\(key)")
        print("👤 Set user property: \(key) = \(value)")
    }
    
    func getUserProperty(key: String) -> String? {
        return UserDefaults.standard.string(forKey: "analytics_\(key)")
    }
    
    // MARK: - Helper Methods
    private func getUserId() -> String {
        // Check if we have a stored user ID
        if let userId = UserDefaults.standard.string(forKey: "analytics_user_id") {
            return userId
        }
        
        // Generate a new user ID using device identifier
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(deviceId, forKey: "analytics_user_id")
        return deviceId
    }
    
    private func storeEvent(_ event: [String: Any]) {
        // In a real app, you would batch these events and send them to your analytics service
        // For now, we'll store them locally
        
        var storedEvents = UserDefaults.standard.array(forKey: "analytics_events") as? [[String: Any]] ?? []
        storedEvents.append(event)
        
        // Keep only the last 1000 events
        if storedEvents.count > 1000 {
            storedEvents = Array(storedEvents.suffix(1000))
        }
        
        UserDefaults.standard.set(storedEvents, forKey: "analytics_events")
    }
    
    // MARK: - Analytics Summary
    func getAnalyticsSummary() -> [String: Any] {
        let events = UserDefaults.standard.array(forKey: "analytics_events") as? [[String: Any]] ?? []
        
        var summary: [String: Any] = [:]
        
        // Count events by type
        var eventCounts: [String: Int] = [:]
        for event in events {
            if let eventName = event["event"] as? String {
                eventCounts[eventName, default: 0] += 1
            }
        }
        
        summary["event_counts"] = eventCounts
        summary["total_events"] = events.count
        summary["user_id"] = getUserId()
        summary["session_count"] = UserDefaults.standard.integer(forKey: "analytics_session_count")
        
        return summary
    }
    
    // MARK: - Privacy
    func optOut() {
        UserDefaults.standard.set(true, forKey: "analytics_opted_out")
        print("🔒 Analytics opted out")
    }
    
    func optIn() {
        UserDefaults.standard.set(false, forKey: "analytics_opted_out")
        print("🔓 Analytics opted in")
    }
    
    func isOptedOut() -> Bool {
        return UserDefaults.standard.bool(forKey: "analytics_opted_out")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Analytics Extensions
extension AnalyticsManager {
    
    // DiceRollerSimulator specific analytics
    func trackDiceRollWithDetails(diceType: String, numberOfDice: Int, results: [Int], total: Int) {
        let parameters: [String: Any] = [
            "dice_type": diceType,
            "number_of_dice": numberOfDice,
            "total": total,
            "results_count": results.count,
            "average_result": results.reduce(0, +) / results.count
        ]
        
        trackCustomEvent(eventName: "dice_roll_detailed", parameters: parameters)
        
        Task {
            await trackDiceRoll(diceType: diceType, result: results, timestamp: Date())
        }
    }
    
    func trackCustomDiceUsage(sides: Int) {
        trackCustomEvent(eventName: "custom_dice_usage", parameters: ["sides": sides])
    }
    
    func trackHistoryViewed(rollCount: Int) {
        trackCustomEvent(eventName: "history_viewed", parameters: ["roll_count": rollCount])
    }
    
    func trackAppLaunch() {
        let launchCount = UserDefaults.standard.integer(forKey: "analytics_launch_count") + 1
        UserDefaults.standard.set(launchCount, forKey: "analytics_launch_count")
        
        trackCustomEvent(eventName: "app_launch", parameters: ["launch_count": launchCount])
    }
}
