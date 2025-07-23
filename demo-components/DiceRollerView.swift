import SwiftUI

struct DiceRollerView: View {
    @State private var diceResult: Int = 1
    @State private var isRolling: Bool = false
    @State private var selectedDice: Int = 20
    
    let diceOptions = [4, 6, 8, 10, 12, 20, 100]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("DnD Dice Roller")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Dice Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(diceOptions, id: \.self) { dice in
                        Button(action: {
                            selectedDice = dice
                        }) {
                            Text("d\(dice)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedDice == dice ? .white : .primary)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(selectedDice == dice ? Color.blue : Color.gray.opacity(0.2))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Dice Display
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 150, height: 150)
                    .scaleEffect(isRolling ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isRolling)
                
                Text("\(diceResult)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Roll Button
            Button(action: rollDice) {
                Text("Roll d\(selectedDice)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
            }
            .disabled(isRolling)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func rollDice() {
        isRolling = true
        
        // Animate rolling effect
        let rollDuration = 0.5
        let rollSteps = 10
        let stepDuration = rollDuration / Double(rollSteps)
        
        for i in 0..<rollSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                diceResult = Int.random(in: 1...selectedDice)
                
                if i == rollSteps - 1 {
                    isRolling = false
                }
            }
        }
    }
}

struct DiceRollerView_Previews: PreviewProvider {
    static var previews: some View {
        DiceRollerView()
    }
}
