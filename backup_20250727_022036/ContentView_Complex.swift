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
            VStack {
                // Dice type selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Dice Type:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // First row: d4, d6, d8, d10
                    HStack(spacing: 12) {
                        ForEach([4, 6, 8, 10], id: \.self) { diceType in
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
                    }
                    .padding(.horizontal)
                    
                    // Second row: d12, d20, d100 + custom spinning die
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedDiceType = 12
                        }) {
                            Text("d12")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 65, height: 55)
                                .background(selectedDiceType == 12 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedDiceType == 12 ? .white : .primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            selectedDiceType = 20
                        }) {
                            Text("d20")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 65, height: 55)
                                .background(selectedDiceType == 20 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedDiceType == 20 ? .white : .primary)
                                .cornerRadius(12)
                        }
                        
                        // Spinning custom die
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
                        
                        Button(action: {
                            selectedDiceType = 100
                        }) {
                            Text("d100")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 65, height: 55)
                                .background(selectedDiceType == 100 ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedDiceType == 100 ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
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
                
                // Number of dice picker
                VStack(alignment: .leading) {
                    Text("Number of Dice:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        
                        // Stepper buttons
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
                        .padding(.trailing, 8)
                        
                        // Display current number with slight visual enhancement
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
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                
                // Current roll display
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        // Adjust height based on content
                        .frame(minHeight: 200, maxHeight: 300)
                    
                    if rollResults.isEmpty {
                        Text("Roll some dice to see results!")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Latest Roll: \(rollResults[0].numberOfDice)d\(rollResults[0].diceType)")
                                    .font(.headline)
                                
                                // Results label and values in one view
                                VStack(alignment: .leading, spacing: 10) {
                                    // Adaptive results grid using FlexibleView
                                    VStack(alignment: .leading) {
                                        Text("Results:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        // Grid layout with fixed column sizes for consistent display and left alignment
                                        let columnCount = min(6, getOptimalColumnCount(for: rollResults[0].results.count))
                                        let columns = Array(repeating: GridItem(.fixed(46), spacing: 10), count: columnCount)
                                        
                                        HStack {
                                            Text("Results: \(rollResults[0].results.count) dice")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                        }
                                        
                                        // Ensure vertical scrolling for all dice results
                                        ScrollView(.vertical, showsIndicators: true) {
                                            LazyVGrid(columns: columns, spacing: 8, alignment: .leading) {
                                                ForEach(rollResults[0].results.indices, id: \.self) { index in
                                                    Text("\(rollResults[0].results[index])")
                                                        .font(.system(size: 16, weight: .medium))
                                                        .frame(width: 46, height: 46)
                                                        .background(Color.blue.opacity(0.1))
                                                        .cornerRadius(6)
                                                }
                                            }
                                            .padding(4)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        // Adjust height dynamically based on content, but cap at reasonable maximum
                                        .frame(minHeight: 100, maxHeight: 350)
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                Text("Total: \(rollResults[0].total)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding(.top, 2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                
                // Dice visualization
                if !rollResults.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(rollResults[0].results.indices, id: \.self) { index in
                                DiceView(diceType: rollResults[0].diceType, number: rollResults[0].results[index])
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(isRolling ? 360 : 0))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                            .opacity(0.4)
                                    )
                            }
                        }
                        .padding()
                    }
                    .frame(height: 80)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Roll button
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
                .padding()
                
                // History button
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
            .navigationTitle("D&D Dice Roller")
            .navigationBarItems(
                trailing: Button(action: {
                    showingStore = true
                }) {
                    Image(systemName: "bag.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            )
            .sheet(isPresented: $showingHistorySheet) {
                RollHistoryView(rolls: rollResults)
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
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

// Helper function to calculate optimal column count for grid layouts
func getOptimalColumnCount(for itemCount: Int) -> Int {
    // For small rolls, use appropriate column count
    if itemCount <= 3 {
        return max(1, itemCount)
    }
    
    // For d100 and large numbers of dice, prioritize columns of 4-6 for readability
    // This creates rows that are balanced and fit well on mobile screens
    if itemCount > 20 {
        // For large numbers, using 4-6 columns ensures readability
        // while maintaining even distribution
        return 6
    }
    
    // Special cases for common dice quantities to ensure even distribution
    switch itemCount {
    case 4: return 2      // 2×2 grid
    case 6: return 3      // 2×3 grid
    case 8: return 4      // 2×4 grid
    case 9: return 3      // 3×3 grid
    case 10: return 5     // 2×5 grid
    case 12: return 4     // 3×4 grid
    case 16: return 4     // 4×4 grid
    case 20: return 5     // 4×5 grid
    default:
        // For other smaller numbers, calculate best fit
        let sqrt = Int(Double(itemCount).squareRoot())
        if sqrt * sqrt == itemCount {
            return sqrt // Perfect square
        } else if itemCount <= 12 {
            return min(4, itemCount) // Small grid, max 4 columns
        } else {
            return min(6, (itemCount + 3) / 4) // Reasonable column count
        }
    }
}

struct RollHistoryView: View {
    let rolls: [DiceRoll]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            // Main vertical scroll view for the entire history
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 16) {
                    if rolls.isEmpty {
                        Text("No rolls yet. Roll some dice!")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }
                    ForEach(rolls) { roll in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(roll.numberOfDice)d\(roll.diceType)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("Total: \(roll.total)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            // Date, time, and dice count for better context
                            HStack {
                                Text(roll.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if roll.results.count > 10 {
                                    Text("\(roll.results.count) dice")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.bottom, 4)
                            
// Roll results section with full scrolling capabilities
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Rolls:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    // Indicator of result count for large rolls
                                    if roll.results.count > 20 {
                                        Text("\(roll.results.count) results")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Fixed column grid with guaranteed even layout and left alignment
                                let columnCount = min(6, getOptimalColumnCount(for: roll.results.count))
                                let columns = Array(repeating: 
                                    GridItem(.fixed(40), spacing: 10), 
                                    count: columnCount)
                                
                                // Allow vertical scrolling for large dice rolls
                                ScrollView(.vertical, showsIndicators: true) {
                                    LazyVGrid(columns: columns, spacing: 8, alignment: .leading) {
                                        ForEach(roll.results.indices, id: \.self) { index in
                                            Text("\(roll.results[index])")
                                                .font(.system(size: 14, weight: .medium))
                                                .frame(width: 40, height: 40)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(6)
                                        }
                                    }
                                    .padding(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                // Adjust height based on the number of dice rolled
                                .frame(height: min(300, CGFloat((roll.results.count + columnCount - 1) / columnCount) * 48))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Roll History")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DiceView: View {
    let diceType: Int
    let number: Int
    
    init(diceType: Int, number: Int) {
        self.diceType = diceType
        self.number = number
    }
    
    // For backward compatibility
    init(number: Int) {
        self.diceType = 6
        self.number = number
    }
    
    var body: some View {
        ZStack {
            // Different shapes for different dice
            Group {
                switch diceType {
                case 4: // Tetrahedron
                    Triangle()
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                case 8: // Octahedron
                    Diamond()
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                case 10, 100: // Pentagonal trapezohedron
                    Pentagon()
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                case 12: // Dodecahedron
                    RegularPolygon(sides: 5)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                case 20: // Icosahedron
                    RegularPolygon(sides: 3)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.degrees(180))
                default: // d6 - cube
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            
            // Number display
            Text("\(number)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

enum DotPosition {
    case topLeft, topRight, middleLeft, middleRight, bottomLeft, bottomRight, center
}

struct DiceDot: View {
    let position: DotPosition
    
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 20, height: 20)
            .position(positionForDot())
    }
    
    private func positionForDot() -> CGPoint {
        switch position {
        case .topLeft:
            return CGPoint(x: 40, y: 40)
        case .topRight:
            return CGPoint(x: 110, y: 40)
        case .middleLeft:
            return CGPoint(x: 40, y: 75)
        case .middleRight:
            return CGPoint(x: 110, y: 75)
        case .bottomLeft:
            return CGPoint(x: 40, y: 110)
        case .bottomRight:
            return CGPoint(x: 110, y: 110)
        case .center:
            return CGPoint(x: 75, y: 75)
        }
    }
}

// Custom shapes for different dice types
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Pentagon: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let sides = 5
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
