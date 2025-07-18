import SwiftUI

struct DiceRoll: Identifiable {
    let id = UUID()
    let diceType: Int
    let numberOfDice: Int
    let results: [Int]
    let total: Int
    let timestamp: Date
}

struct ContentView: View {
    @State private var selectedDiceType = 20
    @State private var numberOfDice = 1
    @State private var isRolling = false
    @State private var rollResults: [DiceRoll] = []
    @State private var showingHistorySheet = false
    
    let availableDice = [4, 6, 8, 10, 12, 20, 100]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("🎲 Dice Roller")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Dice type selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose Dice Type:")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(availableDice, id: \.self) { diceType in
                                Button(action: {
                                    selectedDiceType = diceType
                                }) {
                                    Text("d\(diceType)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedDiceType == diceType ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(selectedDiceType == diceType ? .white : .primary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Number of dice
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Dice:")
                            .font(.headline)
                        
                        HStack {
                            Button(action: {
                                if numberOfDice > 1 {
                                    numberOfDice -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(numberOfDice > 1 ? .blue : .gray)
                            }
                            .disabled(numberOfDice <= 1)
                            
                            Text("\(numberOfDice)")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: 80)
                            
                            Button(action: {
                                if numberOfDice < 10 {
                                    numberOfDice += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(numberOfDice < 10 ? .blue : .gray)
                            }
                            .disabled(numberOfDice >= 10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Roll button
                    Button(action: rollDice) {
                        Text("Roll \(numberOfDice)d\(selectedDiceType)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isRolling ? Color.gray : Color.blue)
                            .cornerRadius(15)
                    }
                    .disabled(isRolling)
                    .padding(.horizontal)
                    
                    // Results
                    if !rollResults.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Latest Roll:")
                                .font(.headline)
                            
                            let latestRoll = rollResults[0]
                            
                            Text("Results: \(latestRoll.results.map { String($0) }.joined(separator: ", "))")
                                .font(.body)
                            
                            Text("Total: \(latestRoll.total)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // History button
                    if !rollResults.isEmpty {
                        Button(action: {
                            showingHistorySheet = true
                        }) {
                            Text("View History (\(rollResults.count) rolls)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dice Roller")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingHistorySheet) {
                HistoryView(rolls: rollResults)
            }
        }
    }
    
    func rollDice() {
        isRolling = true
        
        // Simulate rolling animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let results = (0..<numberOfDice).map { _ in Int.random(in: 1...selectedDiceType) }
            let total = results.reduce(0, +)
            
            let newRoll = DiceRoll(
                diceType: selectedDiceType,
                numberOfDice: numberOfDice,
                results: results,
                total: total,
                timestamp: Date()
            )
            
            rollResults.insert(newRoll, at: 0)
            
            // Keep only last 50 rolls
            if rollResults.count > 50 {
                rollResults.removeLast()
            }
            
            isRolling = false
        }
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
                        Text("\(roll.numberOfDice)d\(roll.diceType)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Total: \(roll.total)")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Text("Results: \(roll.results.map { String($0) }.joined(separator: ", "))")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(roll.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Roll History")
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
