import SwiftUI

struct DiceRoll: Identifiable {
    let id = UUID()
    let diceType: Int
    let numberOfDice: Int
    let results: [Int]
    let total: Int
    let timestamp: Date
    
    var description: String {
        let diceDescription = numberOfDice > 1 ? "\(numberOfDice)d\(diceType)" : "d\(diceType)"
        return "\(diceDescription): \(results.map { String($0) }.joined(separator: ", ")) = \(total)"
    }
}

struct ContentView: View {
    @State private var selectedDiceType = 20
    @State private var numberOfDice = 1
    @State private var isRolling = false
    @State private var rollResults: [DiceRoll] = []
    @State private var showingHistorySheet = false
    @State private var customDiceType = 0
    @State private var customDiceSidesText = ""
    @State private var showCustomDiceAlert = false
    @State private var isSpinningDie = false
    @State private var spinAngle: Double = 0
    @State private var showingStore = false
    @StateObject private var paymentManager = PaymentManager()
    @StateObject private var analyticsManager = AnalyticsManager()
    
    let availableDice = [4, 6, 8, 10, 12, 20, 100]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Dice type selection
                    diceTypeSelection
                    
                    // Number of dice picker
                    numberOfDiceSection
                    
                    // Current roll display
                    currentRollDisplay
                    
                    // Roll button
                    rollButton
                    
                    // History button
                    historyButton
                }
                .padding()
            }
            .navigationTitle("D&D Dice Roller")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingStore = true }) {
                        Image(systemName: "bag.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingHistorySheet) {
                RollHistoryView(rolls: rollResults)
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
        }
    }
    
    var diceTypeSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dice Type:")
                .font(.headline)
            
            // First row: d4, d6, d8, d10
            HStack(spacing: 12) {
                ForEach([4, 6, 8, 10], id: \.self) { diceType in
                    diceButton(for: diceType)
                }
            }
            
            // Second row: d12, d20, d100 + custom
            HStack(spacing: 12) {
                diceButton(for: 12)
                diceButton(for: 20)
                customDiceButton
                diceButton(for: 100)
            }
        }
        .alert("Custom Die", isPresented: $showCustomDiceAlert) {
            TextField("Number of sides (2-1000)", text: $customDiceSidesText)
                .keyboardType(.numberPad)
            Button("OK") {
                if let sides = Int(customDiceSidesText), sides >= 2, sides <= 1000 {
                    customDiceType = sides
                    selectedDiceType = customDiceType
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the number of sides for your custom die")
        }
    }
    
    func diceButton(for diceType: Int) -> some View {
        Button(action: {
            selectedDiceType = diceType
        }) {
            Text("d\(diceType)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 65, height: 55)
                .background(selectedDiceType == diceType ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(selectedDiceType == diceType ? .white : .primary)
                .cornerRadius(12)
        }
    }
    
    var customDiceButton: some View {
        Button(action: {
            showCustomDiceAlert = true
        }) {
            ZStack {
                RegularPolygon(sides: 20)
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .rotation3DEffect(
                        .degrees(isSpinningDie ? spinAngle : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .onAppear {
                        isSpinningDie = true
                        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                            spinAngle = 360
                        }
                    }
                Text("?")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: 65, height: 55)
            .background(selectedDiceType == customDiceType ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(selectedDiceType == customDiceType ? .white : .primary)
            .cornerRadius(12)
        }
    }
    
    var numberOfDiceSection: some View {
        VStack(alignment: .leading) {
            Text("Number of Dice:")
                .font(.headline)
            
            HStack {
                Spacer()
                
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
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 60)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: {
                    if numberOfDice < 99 {
                        numberOfDice += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(numberOfDice < 99 ? .blue : .gray)
                }
                .disabled(numberOfDice >= 99)
                
                Spacer()
            }
        }
    }
    
    var currentRollDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
            
            if rollResults.isEmpty {
                Text("Roll some dice to see results!")
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 10) {
                    Text("Latest Roll: \(rollResults[0].numberOfDice)d\(rollResults[0].diceType)")
                        .font(.headline)
                    
                    Text("Results: \(rollResults[0].results.map { String($0) }.joined(separator: ", "))")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Text("Total: \(rollResults[0].total)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
            }
        }
    }
    
    var rollButton: some View {
        Button(action: rollDice) {
            Text("Roll \(numberOfDice > 1 ? "\(numberOfDice)" : "") d\(selectedDiceType)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .disabled(isRolling)
    }
    
    var historyButton: some View {
        Button(action: {
            showingHistorySheet = true
        }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text("View Roll History")
            }
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
        }
    }
    
    func rollDice() {
        isRolling = true
        
        // Animate
        withAnimation(Animation.easeInOut(duration: 0.5).repeatCount(3)) {
            isRolling = true
        }
        
        // Calculate roll after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
            isRolling = false
            
            // Track dice roll analytics
            Task {
                await analyticsManager.trackDiceRoll(
                    diceType: "d\(selectedDiceType)",
                    result: results,
                    timestamp: Date()
                )
            }
        }
    }
}

struct RollHistoryView: View {
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

struct RegularPolygon: Shape {
    var sides: Int
    
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let angle = 2 * Double.pi / Double(sides)
            let startAngle = -Double.pi / 2
            
            for i in 0..<sides {
                let currentAngle = startAngle + Double(i) * angle
                let x = center.x + radius * cos(currentAngle)
                let y = center.y + radius * sin(currentAngle)
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
