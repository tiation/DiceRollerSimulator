# D&D Dice Roller Simulator

A SwiftUI-based iOS application for simulating dice rolls for tabletop role-playing games like Dungeons & Dragons.

## Features

- Support for standard D&D dice types (d4, d6, d8, d10, d12, d20, d100)
- Custom dice with user-defined number of sides
- Roll multiple dice at once (up to 99 of each type)
- Visual dice selection interface with intuitive layout
- Roll history logging
- Responsive UI that works on various iOS device sizes
- Animated dice roll results
- Clean, modern interface with flexible layout grid

## Screenshots

*Screenshots will be added here*

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone this repository
```
git clone https://github.com/tiation/DiceRollerSimulator.git
```

2. Open the project in Xcode
```
cd DiceRollerSimulator
open DiceRollerSimulator.xcodeproj
```

3. Build and run the application on your iOS device or simulator

## Usage

1. Select a die type from the dice selector at the bottom of the screen
2. Use the stepper to choose how many dice you want to roll (1-99)
3. Tap the "Roll" button to roll the selected dice
4. View the results in the grid display
5. Check the history tab to see all previous rolls
6. Use the custom die option (spinning die icon) to create dice with any number of sides

## Project Structure

- `DiceRollerApp.swift` - The main app entry point
- `ContentView.swift` - The primary view containing the dice roller interface
- `FlexibleView.swift` - A custom component for flexible grid layout of dice results

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Created for tabletop RPG enthusiasts
- Built with SwiftUI for a native iOS experience
