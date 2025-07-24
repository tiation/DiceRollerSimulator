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
            PlayerView()
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
            DungeonMasterView()
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
            GeneralDiceView(quickRollManager: quickRollManager)
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

struct GeneralDiceView: View {
    @ObservedObject var quickRollManager: QuickRollManager
    
    var body: some View {
        VStack {
            Text("🎲 General Dice Roller")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Quick access to all dice rolling functions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(DiceType.allCases, id: \.self) { diceType in
                        Button(action: {
                            // Roll action placeholder
                        }) {
                            VStack {
                                Image(systemName: "dice.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                Text(diceType.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                Text("Custom Die Roller")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack {
                    Text("Custom Die (d\(quickRollManager.customDieSides))")
                        .font(.subheadline)
                    Spacer()
                    Button("Roll") {
                        // Custom roll action placeholder
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.gray.opacity(0.02)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
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
    @State private var customDiceConfigs: [CustomDiceConfig] = {
        var configs: [CustomDiceConfig] = []
        for i in 1...25 {
            configs.append(CustomDiceConfig(
                id: i,
                name: "Custom Roll \(i)",
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

    var body: some View {
        VStack {
            Text("⚔️ Player Dice Configuration")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            List {
                ForEach($customDiceConfigs) { $config in
                    CustomDiceRowView(config: $config) { result in
                        let rollDescription = "\(config.name): \(result) (\(config.diceType.rawValue)\(config.modifier >= 0 ? "+" : "")\(config.modifier))"
                        lastRollResult = rollDescription
                        showingRollResult = true
                        rollHistory.insert(rollDescription, at: 0)

                        // Keep only last 50 rolls
                        if rollHistory.count > 50 {
                            rollHistory = Array(rollHistory.prefix(50))
                        }
                    }
                    .listRowBackground(Color.blue.opacity(0.2))
                }
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                showingHistory = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Roll History (\(rollHistory.count))")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.05), Color.gray.opacity(0.02)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Roll Result", isPresented: $showingRollResult) {
            Button("OK") { }
        } message: {
            Text(lastRollResult)
        }
        .sheet(isPresented: $showingHistory) {
            DMHistoryView(rollHistory: rollHistory)
        }
    }
}

struct DungeonMasterView: View {
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
            // Lord of the Rings themed header
            VStack(spacing: 8) {
                Text("🧙‍♂️ Dungeon Master")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
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
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.purple.opacity(0.6),
                                Color.black.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            .padding(.bottom)
            
            // Custom Dice List with enhanced styling
            List {
                ForEach($customDiceConfigs) { $config in
                    DungeonMasterDiceRowView(config: $config) { result in
                        performRoll(for: config, result: result)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.2),
                                        Color.black.opacity(0.3)
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
                    .padding(.vertical, 2)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            
            // Enhanced Roll History Button
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
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.8),
                            Color.orange.opacity(0.7),
                            Color.red.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .red.opacity(0.4), radius: 6, x: 0, y: 3)
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
                
                // Enhanced Name field with Middle-earth styling
                TextField("Fate Roll Name", text: $config.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                            )
                    )
                
                Spacer()
                
                // Enhanced Quick Info with rune-like styling
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(config.diceType.rawValue)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("\(config.modifier >= 0 ? "+" : "")\(config.modifier)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Enhanced Roll Button with Ring of Power styling
                Button(action: {
                    let baseRoll = Int.random(in: 1...config.diceType.sides)
                    let finalResult = baseRoll + config.modifier
                    onRoll(finalResult)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.8),
                                        Color.orange.opacity(0.9),
                                        Color.red.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: .orange.opacity(0.6), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "dice.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                }
                .scaleEffect(isExpanded ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if userType == .player {
                PlayerTabView(rollLogger: rollLogger, quickRollManager: quickRollManager)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Player")
                    }
                    .tag(0)
            } else {
                DungeonMasterTabView(rollLogger: rollLogger, quickRollManager: quickRollManager)
                    .tabItem {
                        Image(systemName: "crown.fill")
                        Text("Dungeon Master")
                    }
                    .tag(0)
            }
            
            LogTabView(rollLogger: rollLogger)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Log")
                }
                .tag(1)
            
            GeneralDiceTabView(rollLogger: rollLogger, quickRollManager: quickRollManager)
                .tabItem {
                    Image(systemName: "dice.fill")
                    Text("General Dice")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
