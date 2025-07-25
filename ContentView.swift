import SwiftUI
import Foundation

struct DiceRoll: Identifiable, Codable {
    let id = UUID()
    let diceType: Int
    let numberOfDice: Int
    let results: [Int]
    let total: Int
    let modifier: Int
    let finalTotal: Int
    let rollType: RollType
    let description: String
    let timestamp: Date
}

enum RollType: String, CaseIterable, Codable {
    case normal = "Normal"
    case advantage = "Advantage"
    case disadvantage = "Disadvantage"
    case damage = "Damage"
    case healing = "Healing"
    case initiative = "Initiative"
    case abilityCheck = "Ability Check"
    case savingThrow = "Saving Throw"
    case attackRoll = "Attack Roll"
}

enum DiceType: String, CaseIterable, Codable {
    case d4 = "d4"
    case d6 = "d6"
    case d8 = "d8"
    case d10 = "d10"
    case d12 = "d12"
    case d20 = "d20"
    case d100 = "d100"
    
    var sides: Int {
        switch self {
        case .d4: return 4
        case .d6: return 6
        case .d8: return 8
        case .d10: return 10
        case .d12: return 12
        case .d20: return 20
        case .d100: return 100
        }
    }
}

struct QuickRoll: Identifiable, Codable {
    let id = UUID()
    let name: String
    let dice: Int
    let sides: Int
    let modifier: Int
    let rollType: RollType
    let description: String
    let isDefault: Bool
    
    init(name: String, dice: Int, sides: Int, modifier: Int, rollType: RollType, description: String, isDefault: Bool = false) {
        self.name = name
        self.dice = dice
        self.sides = sides
        self.modifier = modifier
        self.rollType = rollType
        self.description = description
        self.isDefault = isDefault
    }
}

class RollLogger: ObservableObject {
    @Published var rolls: [DiceRoll] = []
    private let userDefaults = UserDefaults.standard
    private let rollsKey = "SavedDiceRolls"
    
    init() {
        loadRolls()
    }
    
    func addRoll(_ roll: DiceRoll) {
        rolls.insert(roll, at: 0)
        // Keep only last 100 rolls
        if rolls.count > 100 {
            rolls = Array(rolls.prefix(100))
        }
        saveRolls()
    }
    
    func clearRolls() {
        rolls.removeAll()
        saveRolls()
    }
    
    private func saveRolls() {
        if let encoded = try? JSONEncoder().encode(rolls) {
            userDefaults.set(encoded, forKey: rollsKey)
        }
    }
    
    private func loadRolls() {
        if let data = userDefaults.data(forKey: rollsKey),
           let decoded = try? JSONDecoder().decode([DiceRoll].self, from: data) {
            rolls = decoded
        }
    }
}

class QuickRollManager: ObservableObject {
    @Published var featuredQuickRolls: [QuickRoll] = []
    @Published var allQuickRolls: [QuickRoll] = []
    @Published var customDieSides: Int = 2
    
    private let userDefaults = UserDefaults.standard
    private let featuredRollsKey = "FeaturedQuickRolls"
    private let allRollsKey = "AllQuickRolls"
    private let customDieKey = "CustomDieSides"
    
    private let defaultQuickRolls = [
        QuickRoll(name: "d20 Attack", dice: 1, sides: 20, modifier: 0, rollType: .attackRoll, description: "Attack Roll", isDefault: true),
        QuickRoll(name: "d20 Save", dice: 1, sides: 20, modifier: 0, rollType: .savingThrow, description: "Saving Throw", isDefault: true),
        QuickRoll(name: "d20 Check", dice: 1, sides: 20, modifier: 0, rollType: .abilityCheck, description: "Ability Check", isDefault: true),
        QuickRoll(name: "Initiative", dice: 1, sides: 20, modifier: 0, rollType: .initiative, description: "Initiative", isDefault: true),
        QuickRoll(name: "1d8 Damage", dice: 1, sides: 8, modifier: 0, rollType: .damage, description: "1d8 Damage", isDefault: true),
        QuickRoll(name: "1d6 Damage", dice: 1, sides: 6, modifier: 0, rollType: .damage, description: "1d6 Damage", isDefault: true),
        QuickRoll(name: "2d6 Damage", dice: 2, sides: 6, modifier: 0, rollType: .damage, description: "2d6 Damage", isDefault: true),
        QuickRoll(name: "1d4 Healing", dice: 1, sides: 4, modifier: 0, rollType: .healing, description: "1d4 Healing", isDefault: true),
        QuickRoll(name: "Death Save", dice: 1, sides: 20, modifier: 0, rollType: .savingThrow, description: "Death Saving Throw", isDefault: true),
        QuickRoll(name: "1d12 Damage", dice: 1, sides: 12, modifier: 0, rollType: .damage, description: "1d12 Damage", isDefault: true),
        QuickRoll(name: "2d8 Damage", dice: 2, sides: 8, modifier: 0, rollType: .damage, description: "2d8 Damage", isDefault: true),
        QuickRoll(name: "Concentration", dice: 1, sides: 20, modifier: 0, rollType: .abilityCheck, description: "Concentration Check", isDefault: true)
    ]
    
    init() {
        loadQuickRolls()
        loadCustomDie()
    }
    
    func addCustomRoll(_ roll: QuickRoll) {
        allQuickRolls.append(roll)
        saveQuickRolls()
    }
    
    func removeCustomRoll(_ roll: QuickRoll) {
        allQuickRolls.removeAll { $0.id == roll.id }
        featuredQuickRolls.removeAll { $0.id == roll.id }
        saveQuickRolls()
    }
    
    func swapToFeatured(_ roll: QuickRoll, at index: Int) {
        if index < featuredQuickRolls.count {
            featuredQuickRolls[index] = roll
        } else {
            featuredQuickRolls.append(roll)
        }
        saveQuickRolls()
    }
    
    func updateCustomDie(_ sides: Int) {
        customDieSides = sides
        userDefaults.set(sides, forKey: customDieKey)
    }
    
    private func saveQuickRolls() {
        if let featuredEncoded = try? JSONEncoder().encode(featuredQuickRolls) {
            userDefaults.set(featuredEncoded, forKey: featuredRollsKey)
        }
        if let allEncoded = try? JSONEncoder().encode(allQuickRolls) {
            userDefaults.set(allEncoded, forKey: allRollsKey)
        }
    }
    
    private func loadQuickRolls() {
        // Load all quick rolls or set defaults
        if let data = userDefaults.data(forKey: allRollsKey),
           let decoded = try? JSONDecoder().decode([QuickRoll].self, from: data) {
            allQuickRolls = decoded
        } else {
            allQuickRolls = defaultQuickRolls
            saveQuickRolls() // Save defaults on first run
        }
        
        // Load featured quick rolls or set defaults
        if let data = userDefaults.data(forKey: featuredRollsKey),
           let decoded = try? JSONDecoder().decode([QuickRoll].self, from: data),
           !decoded.isEmpty {
            featuredQuickRolls = decoded
        } else {
            // Always ensure we have 4 featured quick rolls
            featuredQuickRolls = Array(allQuickRolls.prefix(4))
            saveQuickRolls() // Save defaults on first run or if empty
        }
    }
    
    private func loadCustomDie() {
        let storedValue = userDefaults.integer(forKey: customDieKey)
        if storedValue == 0 {
            // First time loading, set default
            customDieSides = 6
            userDefaults.set(6, forKey: customDieKey)
        } else {
            customDieSides = storedValue
        }
        
        // Ensure minimum value
        if customDieSides < 2 {
            customDieSides = 2
            userDefaults.set(2, forKey: customDieKey)
        }
    }
}

struct PlayerTabView: View {
    @ObservedObject var rollLogger: RollLogger
    @ObservedObject var quickRollManager: QuickRollManager

    var body: some View {
        NavigationView {
            PlayerView(rollLogger: rollLogger)
                .navigationTitle("Player")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DungeonMasterTabView: View {
    @ObservedObject var rollLogger: RollLogger
    @ObservedObject var quickRollManager: QuickRollManager

    var body: some View {
        NavigationView {
            DungeonMasterView(rollLogger: rollLogger)
                .navigationTitle("Dungeon Master")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LogTabView: View {
    @ObservedObject var rollLogger: RollLogger

    var body: some View {
        NavigationView {
            LogListView(rolls: rollLogger.rolls)
                .navigationTitle("Log")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GeneralDiceTabView: View {
    @ObservedObject var rollLogger: RollLogger
    @ObservedObject var quickRollManager: QuickRollManager

    var body: some View {
        NavigationView {
            GeneralDiceView(rollLogger: rollLogger, quickRollManager: quickRollManager)
                .navigationTitle("General Dice")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LogListView: View {
    let rolls: [DiceRoll]
    
    var body: some View {
        List(rolls) { roll in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(roll.rollType.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(roll.numberOfDice)d\(roll.diceType)\(roll.modifier != 0 ? (roll.modifier > 0 ? "+\(roll.modifier)" : "\(roll.modifier)") : "")")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text("\(roll.finalTotal)")
                        .fontWeight(.bold)
                        .foregroundColor(roll.rollType == .damage ? .red : (roll.rollType == .healing ? .green : .blue))
                        .font(.title2)
                }
                
                if !roll.description.isEmpty {
                    Text(roll.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Rolls: \(roll.results.map { String($0) }.joined(separator: ", "))")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if roll.modifier != 0 {
                    Text("Base: \(roll.total) | Modifier: \(roll.modifier >= 0 ? "+" : "")\(roll.modifier)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(roll.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}
struct RollHistoryRowView: View {
    let roll: DiceRoll
    
    var body: some View {
        HStack(spacing: 12) {
            // Roll Type Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: rollTypeColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: rollTypeIcon)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
            
            // Roll Details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(roll.numberOfDice)d\(roll.diceType)\(roll.modifier != 0 ? (roll.modifier > 0 ? "+\(roll.modifier)" : "\(roll.modifier)") : "")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(roll.finalTotal)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(rollTypeColors.first ?? .blue)
                }
                
                if !roll.description.isEmpty {
                    Text(roll.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("[\(roll.results.map { String($0) }.joined(separator: ", "))]")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(roll.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var rollTypeColors: [Color] {
        switch roll.rollType {
        case .damage:
            return [.red, .orange]
        case .healing:
            return [.green, .mint]
        case .attackRoll:
            return [.red, .pink]
        case .savingThrow:
            return [.blue, .cyan]
        case .abilityCheck:
            return [.purple, .blue]
        case .initiative:
            return [.yellow, .orange]
        default:
            return [.blue, .cyan]
        }
    }
    
    private var rollTypeIcon: String {
        switch roll.rollType {
        case .damage:
            return "sword.fill"
        case .healing:
            return "heart.fill"
        case .attackRoll:
            return "target"
        case .savingThrow:
            return "shield.fill"
        case .abilityCheck:
            return "checkmark.circle.fill"
        case .initiative:
            return "bolt.fill"
        default:
            return "dice.fill"
        }
    }
}

struct GeneralDiceView: View {
    @ObservedObject var rollLogger: RollLogger
    @ObservedObject var quickRollManager: QuickRollManager
    
    @State private var selectedDice: DiceType = .d6
    @State private var numberOfDice: Int = 1
    @State private var modifier: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header and Controls Section
            VStack {
                Text("🎲 General Dice Roller")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Quick access to all dice rolling functions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Picker("Dice Type", selection: $selectedDice) {
                    ForEach(DiceType.allCases, id: \.self) { diceType in
                        Text(diceType.rawValue).tag(diceType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                HStack {
                    Text("Number of Dice")
                    Spacer()
                    Stepper(value: $numberOfDice, in: 1...10) {
                        Text("\(numberOfDice)")
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Modifier")
                    Spacer()
                    Stepper(value: $modifier, in: -10...10) {
                        Text("\(modifier)")
                    }
                }
                .padding(.horizontal)
                
                Button("Roll") {
                    rollDice()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.gray.opacity(0.02)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Divider
            Divider()
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.blue.opacity(0.5), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.vertical, 8)
            
            // Roll History Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Recent Rolls (\(rollLogger.rolls.count))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    if !rollLogger.rolls.isEmpty {
                        Button("Clear All") {
                            rollLogger.clearRolls()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Scrollable Roll History
                if rollLogger.rolls.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "dice")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No rolls yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Start rolling dice to see your history here!")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(rollLogger.rolls.prefix(20)) { roll in // Show last 20 rolls
                                RollHistoryRowView(roll: roll)
                                    .padding(.horizontal)
                            }
                            
                            if rollLogger.rolls.count > 20 {
                                Text("... and \(rollLogger.rolls.count - 20) more rolls")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .italic()
                                    .padding(.top, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isPresented: $rollResultPresented) {
            Alert(title: Text("Dice Roll Result"), message: Text(rollResultMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    @State private var rollResultPresented: Bool = false
    @State private var rollResultMessage: String = ""
    
    private func rollDice() {
        let results: [Int] = (0..<numberOfDice).map { _ in Int.random(in: 1...selectedDice.sides) }
        let total = results.reduce(0, +)
        let finalTotal = total + modifier
        rollResultMessage = "You rolled: \(results.map { String($0) }.joined(separator: ", "))\nTotal: \(finalTotal)"
        rollResultPresented = true
        
        let roll = DiceRoll(
            diceType: selectedDice.sides, 
            numberOfDice: numberOfDice, 
            results: results, 
            total: total, 
            modifier: modifier, 
            finalTotal: finalTotal, 
            rollType: .normal, 
            description: "General Dice Roll", 
            timestamp: Date()
        )
        rollLogger.addRoll(roll)
    }
}

struct ContentView: View {
    enum UserType {
        case player, dungeonMaster
    }
    
    @State private var selectedUserType: UserType? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Lord of the Rings inspired title
                Text("🧙‍♂️ Dice of Middle-earth")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                Text("Choose Your Path")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                VStack(spacing: 20) {
                    Button(action: {
                        selectedUserType = .player
                    }) {
                        VStack {
                            Text("⚔️")
                                .font(.system(size: 40))
                            Text("Player")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Hero of the Realm")
                                .font(.caption)
                        }
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: selectedUserType == .player ? 10 : 5)
                        .scaleEffect(selectedUserType == .player ? 1.05 : 1.0)
                    }
                    
                    Button(action: {
                        selectedUserType = .dungeonMaster
                    }) {
                        VStack {
                            Text("🧙‍♂️")
                                .font(.system(size: 40))
                            Text("Dungeon Master")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Weaver of Fates")
                                .font(.caption)
                        }
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: selectedUserType == .dungeonMaster ? 10 : 5)
                        .scaleEffect(selectedUserType == .dungeonMaster ? 1.05 : 1.0)
                    }
                }
                .padding(.horizontal, 30)
                
                if let userType = selectedUserType {
                    NavigationLink(
                        destination: UserDetailsView(userType: userType),
                        label: {
                            Text("Enter the Adventure")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.05), Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .animation(.easeInOut(duration: 0.3), value: selectedUserType)
    }
}

struct HistoryView: View {
    let rolls: [DiceRoll]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(rolls) { roll in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(roll.rollType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(roll.numberOfDice)d\(roll.diceType)\(roll.modifier != 0 ? (roll.modifier > 0 ? "+\(roll.modifier)" : "\(roll.modifier)") : "")")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text("\(roll.finalTotal)")
                            .fontWeight(.bold)
                            .foregroundColor(roll.rollType == .damage ? .red : (roll.rollType == .healing ? .green : .blue))
                            .font(.title2)
                    }
                    
                    if !roll.description.isEmpty {
                        Text(roll.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Rolls: \(roll.results.map { String($0) }.joined(separator: ", "))")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    if roll.modifier != 0 {
                        Text("Base: \(roll.total) | Modifier: \(roll.modifier >= 0 ? "+" : "")\(roll.modifier)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(roll.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Roll Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct QuickRollsView: View {
    @ObservedObject var quickRollManager: QuickRollManager
    let onRoll: (QuickRoll) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(quickRollManager.allQuickRolls) { quickRoll in
                HStack {
                    Button(action: {
                        onRoll(quickRoll)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(quickRoll.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(quickRoll.dice)d\(quickRoll.sides)\(quickRoll.modifier != 0 ? (quickRoll.modifier > 0 ? "+\(quickRoll.modifier)" : "\(quickRoll.modifier)") : "")")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Text(quickRoll.rollType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Menu {
                        ForEach(0..<4, id: \.self) { index in
                            Button("Set as Quick Roll \(index + 1)") {
                                quickRollManager.swapToFeatured(quickRoll, at: index)
                            }
                        }
                        
                        if !quickRoll.isDefault {
                            Button("Delete", role: .destructive) {
                                quickRollManager.removeCustomRoll(quickRoll)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("All Quick Rolls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct CustomRollEditorView: View {
    @ObservedObject var quickRollManager: QuickRollManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rollName = ""
    @State private var diceCount = 1
    @State private var diceSides = 20
    @State private var modifier = 0
    @State private var rollType = RollType.normal
    @State private var description = ""
    @State private var customDieSides = 6
    @State private var isEditingCustomRoll = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Custom Die Settings") {
                    HStack {
                        Text("Custom Die Sides:")
                        Spacer()
                        Stepper("\(customDieSides)", value: $customDieSides, in: 2...1000)
                            .onAppear {
                                customDieSides = quickRollManager.customDieSides
                            }
                    }
                    
                    Button("Update Custom Die") {
                        quickRollManager.updateCustomDie(customDieSides)
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Create Custom Quick Roll") {
                    TextField("Roll Name", text: $rollName)
                    
                    HStack {
                        Text("Number of Dice:")
                        Spacer()
                        Stepper("\(diceCount)", value: $diceCount, in: 1...20)
                    }
                    
                    HStack {
                        Text("Die Sides:")
                        Spacer()
                        Stepper("\(diceSides)", value: $diceSides, in: 2...1000)
                    }
                    
                    HStack {
                        Text("Modifier:")
                        Spacer()
                        Stepper("\(modifier >= 0 ? "+" : "")\(modifier)", value: $modifier, in: -50...50)
                    }
                    
                    Picker("Roll Type", selection: $rollType) {
                        ForEach(RollType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Description (Optional)", text: $description)
                    
                    Button("Add Custom Roll") {
                        let newRoll = QuickRoll(
                            name: rollName.isEmpty ? "\(diceCount)d\(diceSides)" : rollName,
                            dice: diceCount,
                            sides: diceSides,
                            modifier: modifier,
                            rollType: rollType,
                            description: description.isEmpty ? "\(diceCount)d\(diceSides)" : description,
                            isDefault: false
                        )
                        quickRollManager.addCustomRoll(newRoll)
                        
                        // Reset form
                        rollName = ""
                        diceCount = 1
                        diceSides = 20
                        modifier = 0
                        rollType = .normal
                        description = ""
                    }
                    .disabled(rollName.isEmpty && description.isEmpty)
                    .foregroundColor(.green)
                }
            }
            .navigationTitle("Custom Rolls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct QuickRollEditorView: View {
    @ObservedObject var quickRollManager: QuickRollManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSlotIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Quick Roll Buttons")
                    .font(.headline)
                    .padding()
                
                Text(selectedSlotIndex == nil ? "First, tap one of your current quick roll slots to replace" : "Now tap a roll below to replace slot \(selectedSlotIndex! + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                
                List {
                    Section("Current Quick Rolls (Tap to Edit)") {
                        ForEach(Array(quickRollManager.featuredQuickRolls.enumerated()), id: \.element.id) { index, quickRoll in
                            Button(action: {
                                selectedSlotIndex = index
                            }) {
                                HStack {
                                    Text("\(index + 1). \(quickRoll.name)")
                                        .font(.headline)
                                        .foregroundColor(selectedSlotIndex == index ? .white : .primary)
                                    Spacer()
                                    Text("\(quickRoll.dice)d\(quickRoll.sides)\(quickRoll.modifier != 0 ? (quickRoll.modifier > 0 ? "+\(quickRoll.modifier)" : "\(quickRoll.modifier)") : "")")
                                        .font(.subheadline)
                                        .foregroundColor(selectedSlotIndex == index ? .white : .blue)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(selectedSlotIndex == index ? Color.blue : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Section(selectedSlotIndex == nil ? "Available Rolls" : "Replace Slot \(selectedSlotIndex! + 1) With:") {
                        ForEach(quickRollManager.allQuickRolls) { quickRoll in
                            Button(action: {
                                if let index = selectedSlotIndex {
                                    quickRollManager.swapToFeatured(quickRoll, at: index)
                                    selectedSlotIndex = nil // Reset selection after replacement
                                }
                            }) {
                                HStack {
                                    Text(quickRoll.name)
                                        .foregroundColor(selectedSlotIndex == nil ? .secondary : .primary)
                                    Spacer()
                                    Text("\(quickRoll.dice)d\(quickRoll.sides)\(quickRoll.modifier != 0 ? (quickRoll.modifier > 0 ? "+\(quickRoll.modifier)" : "\(quickRoll.modifier)") : "")")
                                        .font(.subheadline)
                                        .foregroundColor(selectedSlotIndex == nil ? .secondary : .blue)
                                }
                            }
                            .disabled(selectedSlotIndex == nil)
                        }
                    }
                }
            }
            .navigationTitle("Quick Roll Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedSlotIndex != nil {
                        Button("Cancel") {
                            selectedSlotIndex = nil
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}



struct PlayerView: View {
    @ObservedObject var rollLogger: RollLogger
    
    @State private var customDiceConfigs: [CustomDiceConfig] = {
        var configs: [CustomDiceConfig] = []
        for i in 1...25 {
            configs.append(CustomDiceConfig(
                id: i,
                name: "Hero Roll \(i)",
                diceType: .d20,
                modifier: 0,
                rollType: .normal
            ))
        }
        return configs
    }()
    
    @State private var showingRollResult = false
    @State private var lastRollResult = ""
    @State private var showingHistory = false
    @State private var selectedRowId: Int? = nil
    @State private var showingRollAnimation = false
    @State private var showingCustomModal = false
    @State private var lastRollDetails: RollResultDetails?
    @State private var showingDiceSetup = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("⚔️ Player")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.top)
                
                Text("✨ Hero of the Realm ✨")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.red.opacity(0.9))
                    .italic()
                
                Text("Forge your destiny with these sacred dice")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            .padding(.bottom)
            
            // Dice List
            List {
                ForEach($customDiceConfigs) { $config in
                    PlayerDiceRowView(
                        config: $config,
                        isSelected: selectedRowId == config.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedRowId = config.id
                            }
                            // Clear selection after 0.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRowId = nil
                                }
                            }
                        }
                    ) { baseRoll, finalResult in
                        // Set row selection immediately
                        selectedRowId = config.id
                        
                        // Show roll animation first
                        showingRollAnimation = true
                        
                        // Add to rollLogger
                        let diceRoll = DiceRoll(
                            diceType: config.diceType.sides,
                            numberOfDice: 1,
                            results: [baseRoll],
                            total: baseRoll,
                            modifier: config.modifier,
                            finalTotal: finalResult,
                            rollType: config.rollType,
                            description: config.name,
                            timestamp: Date()
                        )
                        rollLogger.addRoll(diceRoll)
                        
                        // After animation, show result
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showingRollAnimation = false
                            lastRollResult = "⚔️ \(config.name): \(finalResult) (\(config.diceType.rawValue)\(config.modifier >= 0 ? "+" : "")\(config.modifier))"
                            showingRollResult = true
                            
                            // Clear selection after result appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRowId = nil
                                }
                            }
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: selectedRowId == config.id ? 
                                        [Color.red.opacity(0.3), Color.orange.opacity(0.2)] :
                                        [Color.red.opacity(0.1), Color.red.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedRowId == config.id ? Color.red.opacity(0.8) : Color.red.opacity(0.2),
                                        lineWidth: selectedRowId == config.id ? 2 : 1
                                    )
                            )
                    )
                    .listRowSeparator(.hidden)
                    .scaleEffect(selectedRowId == config.id ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selectedRowId == config.id)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    showingDiceSetup = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .font(.system(size: 16))
                        Text("Setup")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showingHistory = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "scroll")
                            .font(.system(size: 16))
                        Text("Chronicle")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("(\(rollLogger.rolls.count))")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.red.opacity(0.4),
                    Color.black.opacity(0.8),
                    Color.red.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .alert("The Dice Have Spoken!", isPresented: $showingRollResult) {
            Button("So it is written") { 
                showingRollAnimation = false
            }
        } message: {
            Text(lastRollResult)
                .font(.headline)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(rolls: rollLogger.rolls)
        }
        .sheet(isPresented: $showingDiceSetup) {
            DiceSetupView(configs: $customDiceConfigs)
        }
        .overlay(
            // Roll animation overlay
            showingRollAnimation ? 
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(showingRollAnimation ? 360 : 0))
                            .animation(
                                .easeInOut(duration: 0.6).repeatCount(2, autoreverses: false),
                                value: showingRollAnimation
                            )
                        Text("⚔️ Rolling... ⚔️")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    )
                    Spacer()
                }
                Spacer()
            }
            : nil
        )
    }
}

struct DungeonMasterView: View {
    @ObservedObject var rollLogger: RollLogger
    
    @State private var customDiceConfigs: [CustomDiceConfig] = {
        var configs: [CustomDiceConfig] = []
        for i in 1...25 {
            configs.append(CustomDiceConfig(
                id: i,
                name: "Fate Roll \(i)",
                diceType: .d20,
                modifier: 0,
                rollType: .normal
            ))
        }
        return configs
    }()
    
    @State private var showingRollResult = false
    @State private var lastRollResult = ""
    @State private var rollHistory: [String] = []
    @State private var showingHistory = false
    @State private var showingRollAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("🧙‍♂️ Dungeon Master")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.top)
                
                Text("✨ Weaver of Fates ✨")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange.opacity(0.9))
                    .italic()
                
                Text("The power of Middle-earth flows through these dice")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom)
            
            // Dice List
            List {
                ForEach($customDiceConfigs) { $config in
                    DungeonMasterDiceRowView(config: $config) { result in
                        performRoll(for: config, result: result)
                    }
                    .listRowBackground(Color.purple.opacity(0.2))
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 2)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            
            // History Button
            Button(action: {
                showingHistory = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "scroll")
                        .font(.system(size: 18))
                    Text("Chronicle of Rolls")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("(\(rollHistory.count))")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(Color.red.opacity(0.7))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.purple.opacity(0.4),
                    Color.black.opacity(0.8),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .alert("The Dice Have Spoken!", isPresented: $showingRollResult) {
            Button("So it is written") { 
                showingRollAnimation = false
            }
        } message: {
            Text(lastRollResult)
                .font(.headline)
        }
        .sheet(isPresented: $showingHistory) {
            DMHistoryView(rollHistory: rollHistory)
        }
        .overlay(
            // Roll animation overlay
            showingRollAnimation ? 
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(showingRollAnimation ? 360 : 0))
                            .animation(
                                .easeInOut(duration: 0.8).repeatCount(2, autoreverses: false),
                                value: showingRollAnimation
                            )
                        Text("✨ Rolling... ✨")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.purple, lineWidth: 2)
                            )
                    )
                    Spacer()
                }
                Spacer()
            }
            : nil
        )
    }
    
    private func performRoll(for config: CustomDiceConfig, result: Int) {
        showingRollAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            let rollDescription = "⚔️ \(config.name): \(result) (\(config.diceType.rawValue)\(config.modifier >= 0 ? "+" : "")\(config.modifier))"
            lastRollResult = rollDescription
            showingRollAnimation = false
            showingRollResult = true
            rollHistory.insert(rollDescription, at: 0)
            
            // Keep only last 50 rolls
            if rollHistory.count > 50 {
                rollHistory = Array(rollHistory.prefix(50))
            }
        }
    }
}

struct RollResultDetails {
    let rollName: String
    let diceType: DiceType
    let modifier: Int
    let baseRoll: Int
    let finalResult: Int
    let rollType: RollType
    let timestamp: Date
    
    var displayText: String {
        return "\(rollName)\n\(diceType.rawValue)\(modifier >= 0 ? "+" : "")\(modifier)\nRolled: \(baseRoll)\nFinal: \(finalResult)"
    }
}

struct CustomDiceConfig: Identifiable {
    let id: Int
    var name: String
    var diceType: DiceType
    var modifier: Int
    var rollType: RollType
}

struct DungeonMasterDiceRowView: View {
    @Binding var config: CustomDiceConfig
    let onRoll: (Int) -> Void
    
    @State private var isExpanded = false
    @State private var isSelected = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Enhanced Row Header with Name and Roll Button
            HStack(spacing: 12) {
                // Expand/Collapse Button with mystical styling
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .font(.system(size: 16))
                        .shadow(color: .orange.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(isExpanded ? "Collapse dice settings" : "Expand dice settings")
                
                // Enhanced Name field with hero styling
                TextField("Hero Roll Name", text: $config.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .accessibilityLabel("Roll name: \(config.name)")
                
                Spacer()
                
                // Enhanced Quick Info with readable styling
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(config.diceType.rawValue)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Dice: \(config.diceType.rawValue), Modifier: \(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                
                // Enhanced Roll Button with hero styling
                Button(action: {
                    if !isExpanded {
                        // Set selected state briefly to show visual feedback
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isSelected = true
                        }
                        
                        let baseRoll = Int.random(in: 1...config.diceType.sides)
                        let finalResult = baseRoll + config.modifier
                        onRoll(finalResult)
                        
                        // Clear selection after brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isSelected = false
                            }
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isExpanded ? 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                        isSelected ? 
                                            [Color.red.opacity(0.9), Color.orange.opacity(0.8)] :
                                            [Color.red.opacity(0.7), Color.red.opacity(0.5)]
                                    ),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isSelected ? 44 : 40, height: isSelected ? 44 : 40)
                            .shadow(color: isExpanded ? .clear : isSelected ? .red.opacity(0.6) : .red.opacity(0.3), radius: isSelected ? 6 : 4, x: 0, y: 2)
                        
                        Image(systemName: isExpanded ? "gearshape.fill" : "dice.fill")
                            .foregroundColor(isExpanded ? .gray : .white)
                            .font(.system(size: isSelected ? 20 : 18, weight: .bold))
                            .shadow(color: isExpanded ? .clear : .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                }
                .disabled(isExpanded)
                .scaleEffect(isSelected ? 1.1 : (isExpanded ? 1.05 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
                .accessibilityLabel(isExpanded ? "Dice settings mode" : "Roll \(config.name)")
                .accessibilityHint(isExpanded ? "Dice is in settings mode" : "Tap to roll dice")
            }
            
            // Enhanced Expanded Configuration Options
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.purple.opacity(0.5), Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    // Enhanced Dice Type Selection
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "die.face.1")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text("Dice of Fate")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(DiceType.allCases, id: \.self) { diceType in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            config.diceType = diceType
                                        }
                                    }) {
                                        Text(diceType.rawValue)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(config.diceType == diceType ? .black : .white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(
                                                        config.diceType == diceType ?
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ) :
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black.opacity(0.5)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(
                                                        config.diceType == diceType ? Color.orange.opacity(0.8) : Color.purple.opacity(0.4),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .shadow(
                                                color: config.diceType == diceType ? .orange.opacity(0.4) : .clear,
                                                radius: 3,
                                                x: 0,
                                                y: 2
                                            )
                                    }
                                    .scaleEffect(config.diceType == diceType ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: config.diceType == diceType)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    // Enhanced Modifier with ancient rune styling
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "plus.forwardslash.minus")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text("Power Modifier")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                if config.modifier > -10 {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        config.modifier -= 1
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.orange.opacity(0.6)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 32, height: 32)
                                        .shadow(color: .red.opacity(0.4), radius: 2, x: 0, y: 1)
                                    
                                    Image(systemName: "minus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            
                            Text("\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(minWidth: 50)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.5))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .purple.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            Button(action: {
                                if config.modifier < 10 {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        config.modifier += 1
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 32, height: 32)
                                        .shadow(color: .green.opacity(0.4), radius: 2, x: 0, y: 1)
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Enhanced Roll Type with mystical styling
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text("Type of Magic")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        Picker("Roll Type", selection: $config.rollType) {
                            ForEach(RollType.allCases, id: \.self) { rollType in
                                Text(rollType.rawValue).tag(rollType)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple.opacity(0.4), Color.black.opacity(0.6)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(.leading, 24)
                .padding(.trailing, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.clear)
    }
}

struct CustomDiceRowView: View {
    @Binding var config: CustomDiceConfig
    let onRoll: (Int) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row Header with Name and Roll Button
            HStack {
                // Expand/Collapse Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
                
                // Name (editable)
                TextField("Roll Name", text: $config.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // Quick Info
                Text("\(config.diceType.rawValue)\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Roll Button
                Button(action: {
                    let baseRoll = Int.random(in: 1...config.diceType.sides)
                    let finalResult = baseRoll + config.modifier
                    onRoll(finalResult)
                }) {
                    Image(systemName: "dice.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(8)
                        .background(Color.red.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            
            // Expanded Configuration Options
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.gray)
                    
                    // Dice Type Selection
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dice Type")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DiceType.allCases, id: \.self) { diceType in
                                    Button(action: {
                                        config.diceType = diceType
                                    }) {
                                        Text(diceType.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(config.diceType == diceType ? .black : .white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(config.diceType == diceType ? Color.white : Color.purple.opacity(0.3))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Modifier
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Modifier")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Button(action: {
                                if config.modifier > -10 {
                                    config.modifier -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Text("\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: {
                                if config.modifier < 10 {
                                    config.modifier += 1
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Roll Type
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Roll Type")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Picker("Roll Type", selection: $config.rollType) {
                            ForEach(RollType.allCases, id: \.self) { rollType in
                                Text(rollType.rawValue).tag(rollType)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(Color.purple.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
                .padding(.leading, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .background(Color.black)
    }
}

struct LogView: View {
    @ObservedObject var rollLogger: RollLogger
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "scroll")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("📜 Roll Chronicle")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("\(rollLogger.rolls.count) fates have been recorded")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.8),
                                    Color.purple.opacity(0.4),
                                    Color.black.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Roll history list
                if rollLogger.rolls.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "dice")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No rolls yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Start rolling some dice to see your history here!")
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                } else {
                    List(rollLogger.rolls) { roll in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(roll.rollType.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(roll.numberOfDice)d\(roll.diceType)\(roll.modifier != 0 ? (roll.modifier > 0 ? "+\(roll.modifier)" : "\(roll.modifier)") : "")")
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                Text("\(roll.finalTotal)")
                                    .fontWeight(.bold)
                                    .foregroundColor(roll.rollType == .damage ? .red : (roll.rollType == .healing ? .green : .blue))
                                    .font(.title2)
                            }
                            
                            if !roll.description.isEmpty {
                                Text(roll.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Rolls: \(roll.results.map { String($0) }.joined(separator: ", "))")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if roll.modifier != 0 {
                                Text("Base: \(roll.total) | Modifier: \(roll.modifier >= 0 ? "+" : "")\(roll.modifier)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(roll.timestamp, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.purple.opacity(0.2),
                                            Color.black.opacity(0.4),
                                            Color.purple.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.3),
                        Color.black.opacity(0.8),
                        Color.purple.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
        }
    }
}

struct DMHistoryView: View {
    let rollHistory: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced header with Lord of the Rings theming
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "scroll")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("📜 Chronicle of Rolls")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("\(rollHistory.count) fates have been sealed")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.8),
                                    Color.purple.opacity(0.4),
                                    Color.black.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Enhanced roll history list
                List(rollHistory, id: \.self) { roll in
                    HStack(spacing: 12) {
                        // Mystical bullet point
                        Image(systemName: "sparkles")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                            .frame(width: 16)
                        
                        Text(roll)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(2)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.2),
                                        Color.black.opacity(0.4),
                                        Color.purple.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.3),
                        Color.black.opacity(0.8),
                        Color.purple.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                Text("Close")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.red.opacity(0.7), Color.orange.opacity(0.6)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: .red.opacity(0.4), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    Spacer()
                },
                alignment: .top
            )
        }
    }
}

struct UserDetailsView: View {
    let userType: ContentView.UserType
    @StateObject private var rollLogger = RollLogger()
    @StateObject private var quickRollManager = QuickRollManager()
    @State private var selectedTab = 0
    @State private var currentUserType: ContentView.UserType
    
    init(userType: ContentView.UserType) {
        self.userType = userType
        self._currentUserType = State(initialValue: userType)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Role View with Swipe Navigation
            ZStack {
                if currentUserType == .player {
                    PlayerView(rollLogger: rollLogger)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    DungeonMasterView(rollLogger: rollLogger)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        withAnimation(.easeInOut(duration: 0.3)) {
                if gesture.translation.width > 100 {
                                // Swipe right - go to Player
                                currentUserType = .player
                            } else if gesture.translation.width < -100 {
                                // Swipe left - go to Dungeon Master
                                currentUserType = .dungeonMaster
                            }
                        }
                    }
            )
            .tabItem {
                VStack {
                    Image(systemName: currentUserType == .player ? "person.fill" : "crown.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: selectedTab == 0 ? (currentUserType == .player ? [.red, .orange] : [.purple, .blue]) : [.gray],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(currentUserType == .player ? "Player" : "Dungeon Master")
                        .font(.caption)
                        .fontWeight(selectedTab == 0 ? .bold : .medium)
                }
            }
            .tag(0)
            
            LogView(rollLogger: rollLogger)
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "scroll.fill" : "scroll")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: selectedTab == 1 ? [.green, .teal] : [.gray],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Chronicle")
                            .font(.caption)
                            .fontWeight(selectedTab == 1 ? .bold : .medium)
                    }
                }
                .tag(1)
            
            GeneralDiceTabView(rollLogger: rollLogger, quickRollManager: quickRollManager)
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "dice.fill" : "dice")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: selectedTab == 2 ? [.blue, .cyan] : [.gray],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("General Dice")
                            .font(.caption2)
                            .fontWeight(selectedTab == 2 ? .bold : .medium)
                    }
                }
                .tag(2)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .animation(.easeInOut(duration: 0.3), value: currentUserType)
    }
}

struct StoreTabView: View {
    @State private var selectedItems: Set<StoreItem> = []
    @State private var showingPurchaseConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("🏪 Adventurer's Shop")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top)
                    
                    Text("✨ Mystical Items & Enhancements ✨")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange.opacity(0.9))
                        .italic()
                    
                    Text("Enhance your dice rolling experience with magical items")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .padding(.bottom)
                
                // Store Items List
                List(StoreItem.allItems) { item in
                    StoreItemRowView(item: item, isSelected: selectedItems.contains(item)) {
                        if selectedItems.contains(item) {
                            selectedItems.remove(item)
                        } else {
                            selectedItems.insert(item)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.yellow.opacity(0.1),
                                        Color.orange.opacity(0.05),
                                        Color.yellow.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 2)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                
                // Purchase Button
                if !selectedItems.isEmpty {
                    Button(action: {
                        showingPurchaseConfirmation = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 18))
                            Text("Purchase Items (\(selectedItems.count))")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("💰 \(totalCost)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                colors: [.green.opacity(0.8), .teal.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(0.05),
                        Color.orange.opacity(0.03),
                        Color.yellow.opacity(0.02),
                        Color.orange.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Purchase Successful!", isPresented: $showingPurchaseConfirmation) {
                Button("Excellent!") {
                    selectedItems.removeAll()
                }
            } message: {
                Text("Your magical items have been added to your inventory!")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedItems.count)
    }
    
    private var totalCost: Int {
        selectedItems.reduce(0) { $0 + $1.cost }
    }
}

struct StoreItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let cost: Int
    let icon: String
    let rarity: ItemRarity
    
    enum ItemRarity: String, CaseIterable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
    }
    
    static let allItems: [StoreItem] = [
        StoreItem(name: "Lucky Charm", description: "Increases critical hit chance on d20 rolls", cost: 50, icon: "star.fill", rarity: .common),
        StoreItem(name: "Dragon Scale Dice", description: "Premium dice set with enhanced rolling animations", cost: 150, icon: "flame.fill", rarity: .rare),
        StoreItem(name: "Wizard's Focus", description: "Reduces fumble chance and adds magical sparkles", cost: 200, icon: "wand.and.stars", rarity: .epic),
        StoreItem(name: "Ancient Tome", description: "Unlocks historical roll tracking and analytics", cost: 100, icon: "book.closed.fill", rarity: .uncommon),
        StoreItem(name: "Ring of Fortune", description: "Legendary item that affects all dice rolls", cost: 500, icon: "circle.fill", rarity: .legendary),
        StoreItem(name: "Crystal Dice Set", description: "Beautiful transparent dice with light effects", cost: 120, icon: "diamond.fill", rarity: .rare),
        StoreItem(name: "Adventurer's Pack", description: "Bundle of useful items for new players", cost: 75, icon: "backpack.fill", rarity: .common),
        StoreItem(name: "Mystic Symbols", description: "Custom dice face symbols and themes", cost: 80, icon: "symbol", rarity: .uncommon)
    ]
}

struct StoreItemRowView: View {
    let item: StoreItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Item Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [item.rarity.color.opacity(0.8), item.rarity.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: item.rarity.color.opacity(0.4), radius: 3, x: 0, y: 2)
                
                Image(systemName: item.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(item.rarity.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(item.rarity.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(item.rarity.color.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(item.rarity.color.opacity(0.4), lineWidth: 1)
                                )
                        )
                }
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("💰 \(item.cost) Gold")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Button(action: onToggle) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                            .foregroundColor(isSelected ? .green : .blue)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.green.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct EnhancedCustomDiceRowView: View {
    @Binding var config: CustomDiceConfig
    let isSelected: Bool
    let onTap: () -> Void
    let onRoll: (Int, Int) -> Void // baseRoll, finalResult
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row Header with Name and Roll Button
            HStack {
                // Expand/Collapse Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                        .shadow(color: isSelected ? .red.opacity(0.5) : .clear, radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Name (editable)
                TextField("Roll Name", text: $config.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .shadow(color: isSelected ? .red.opacity(0.3) : .clear, radius: 1)
                
                Spacer()
                
                // Quick Info
                Text("\(config.diceType.rawValue)\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .gray)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                // Enhanced Roll Button
                Button(action: {
                    // Only roll if not expanded for editing
                    if !isExpanded {
                        onTap()
                        let baseRoll = Int.random(in: 1...config.diceType.sides)
                        let finalResult = baseRoll + config.modifier
                        onRoll(baseRoll, finalResult)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isExpanded ? 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                        isSelected ? 
                                            [Color.red.opacity(0.9), Color.orange.opacity(0.8)] :
                                            [Color.red.opacity(0.7), Color.red.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
                            .shadow(color: isExpanded ? .clear : isSelected ? .red.opacity(0.6) : .red.opacity(0.3), radius: isSelected ? 6 : 3)
                        
                        Image(systemName: isExpanded ? "gearshape.fill" : "dice.fill")
                            .foregroundColor(isExpanded ? .gray : .white)
                            .font(.system(size: isSelected ? 20 : 16, weight: .bold))
                            .shadow(color: isExpanded ? .clear : .black.opacity(0.3), radius: 1)
                    }
                }
                .disabled(isExpanded)
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            
            // Expanded Configuration Options
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(
                            LinearGradient(
                                colors: [Color.clear, Color.red.opacity(0.5), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Dice Type Selection
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dice Type")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DiceType.allCases, id: \.self) { diceType in
                                    Button(action: {
                                        config.diceType = diceType
                                    }) {
                                        Text(diceType.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(config.diceType == diceType ? .black : .white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                config.diceType == diceType ? 
                                                    LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                    LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .cornerRadius(15)
                                            .shadow(color: config.diceType == diceType ? .red.opacity(0.4) : .clear, radius: 2)
                                    }
                                    .scaleEffect(config.diceType == diceType ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: config.diceType == diceType)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Modifier
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Modifier")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Button(action: {
                                if config.modifier > -10 {
                                    config.modifier -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Text("\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.black.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            
                            Button(action: {
                                if config.modifier < 10 {
                                    config.modifier += 1
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.green.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Roll Type
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Roll Type")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Picker("Roll Type", selection: $config.rollType) {
                            ForEach(RollType.allCases, id: \.self) { rollType in
                                Text(rollType.rawValue).tag(rollType)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.leading, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct PlayerRollResultModal: View {
    let rollDetails: RollResultDetails
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Text("⚔️ Roll Result ⚔️")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(rollDetails.rollName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
            
            // Main Result Display
            VStack(spacing: 20) {
                // Dice Visual
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.red.opacity(0.8), Color.orange.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        Text(rollDetails.diceType.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                // Roll Details
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Base Roll")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(rollDetails.baseRoll)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        if rollDetails.modifier != 0 {
                            Image(systemName: rollDetails.modifier > 0 ? "plus" : "minus")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Modifier")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(abs(rollDetails.modifier))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(rollDetails.modifier > 0 ? .green : .red)
                            }
                        }
                    }
                    
                    Divider()
                        .background(
                            LinearGradient(
                                colors: [Color.clear, Color.red.opacity(0.5), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Final Result
                    VStack(spacing: 8) {
                        Text("Final Result")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(rollDetails.finalResult)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .red.opacity(0.3), radius: 2)
                    }
                    
                    // Roll Type Badge
                    Text(rollDetails.rollType.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Close Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Glory Achieved!")
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(
                        LinearGradient(
                            colors: [.red.opacity(0.8), .orange.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .red.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .padding(.bottom, 30)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.red.opacity(0.05), Color.orange.opacity(0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct PlayerDiceRowView: View {
    @Binding var config: CustomDiceConfig
    let isSelected: Bool
    let onTap: () -> Void
    let onRoll: (Int, Int) -> Void // baseRoll, finalResult
    
    @State private var isExpanded = false
    
    var body: some View {
        EnhancedCustomDiceRowView(
            config: $config,
            isSelected: isSelected,
            onTap: onTap,
            onRoll: onRoll
        )
    }
}

struct DiceSetupView: View {
    @Binding var configs: [CustomDiceConfig]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach($configs) { $config in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Roll Name", text: $config.name)
                            .font(.headline)
                        
                        HStack {
                            Text("Dice Type:")
                            Spacer()
                            Picker("Dice Type", selection: $config.diceType) {
                                ForEach(DiceType.allCases, id: \.self) { diceType in
                                    Text(diceType.rawValue).tag(diceType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Modifier:")
                            Spacer()
                            Stepper("\(config.modifier >= 0 ? "+" : "")\(config.modifier)", value: $config.modifier, in: -10...10)
                        }
                        
                        HStack {
                            Text("Roll Type:")
                            Spacer()
                            Picker("Roll Type", selection: $config.rollType) {
                                ForEach(RollType.allCases, id: \.self) { rollType in
                                    Text(rollType.rawValue).tag(rollType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Dice Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
