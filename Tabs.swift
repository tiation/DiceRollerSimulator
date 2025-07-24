import SwiftUI

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
