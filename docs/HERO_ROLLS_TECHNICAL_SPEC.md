# Hero Rolls Technical Specification
## Dice Rolling Mechanics for Players

### Table of Contents
1. [Overview](#overview)
2. [Basic Dice Rolling](#basic-dice-rolling)
3. [Roll Modifiers](#roll-modifiers)
4. [Advanced Mechanics](#advanced-mechanics)
5. [Roll Types](#roll-types)
6. [Quick Rolls](#quick-rolls)
7. [Visual & Audio Feedback](#visual--audio-feedback)

---

## Overview

Hero Rolls are the player-focused dice rolling system in Dice of Middle-Earth. Each Hero Roll represents a heroic action, ability check, or combat maneuver that your character performs during gameplay.

### Core Components
- **Dice Type**: The shape of die being rolled (d4, d6, d8, d10, d12, d20, d100)
- **Number of Dice**: How many dice of that type to roll simultaneously
- **Modifier**: A flat bonus or penalty added to the total
- **Roll Name**: Custom label for your roll (e.g., "Longsword Attack", "Stealth Check")

---

## Basic Dice Rolling

### Standard Roll Process
1. **Dice Selection**: Choose from standard D&D dice types
   - `d4`: 4-sided die (1-4)
   - `d6`: 6-sided die (1-6)
   - `d8`: 8-sided die (1-8)
   - `d10`: 10-sided die (1-10)
   - `d12`: 12-sided die (1-12)
   - `d20`: 20-sided die (1-20) - Primary die for most checks
   - `d100`: Percentile die (1-100)

2. **Roll Calculation**:
   ```
   Final Result = (Sum of all dice rolled) + Modifier
   ```

### Example Calculations
- **1d20+5**: Roll one 20-sided die, add 5
  - Roll: 14
  - Final: 14 + 5 = 19

- **3d6+2**: Roll three 6-sided dice, add 2
  - Rolls: 4, 2, 6
  - Sum: 12
  - Final: 12 + 2 = 14

---

## Roll Modifiers

### Basic Modifier (-10 to +10)
The modifier represents your character's skill, abilities, or situational bonuses/penalties.

**Positive Modifiers (+1 to +10)**:
- Represent proficiency, strength, magical enhancements
- Example: +3 from Strength bonus, +2 from proficiency

**Negative Modifiers (-1 to -10)**:
- Represent penalties, difficult conditions, or weaknesses
- Example: -2 from exhaustion, -1 from difficult terrain

### Per-Die Min/Max Modifiers
Advanced feature that ensures each individual die meets minimum or maximum thresholds.

**Minimum Modifier** (useMinimum = true):
- Forces each die to be at least (1 + minMaxModifier)
- Example: d20 with +3 minimum modifier
  - Roll of 2 becomes 4 (1+3)
  - Roll of 15 remains 15

**Maximum Modifier** (useMinimum = false):
- Caps each die at (max face value + minMaxModifier)
- Example: d20 with -3 maximum modifier
  - Roll of 20 becomes 17 (20-3)
  - Roll of 10 remains 10

---

## Advanced Mechanics

### 1. Advantage/Disadvantage (D20 Only)

**Advantage Mode**:
- Roll 2d20, keep the HIGHER result
- Used when circumstances favor success
- Example: Rolling with advantage
  - Rolls: 8, 15
  - Keep: 15
  - Add modifier for final result

**Disadvantage Mode**:
- Roll 2d20, keep the LOWER result
- Used when circumstances hinder success
- Example: Rolling with disadvantage
  - Rolls: 8, 15
  - Keep: 8
  - Add modifier for final result

### 2. Drop/Keep Mechanics (Multiple Dice Only)

**Drop Lowest**:
- Roll X dice, remove the lowest Y results
- Common notation: 4d6 drop lowest 1
- Example: Rolling 4d6, drop lowest
  - Rolls: 2, 4, 5, 6
  - Drop: 2
  - Keep: 4, 5, 6
  - Sum: 15

**Drop Highest**:
- Roll X dice, remove the highest Y results
- Less common, used for specific mechanics
- Example: Rolling 4d6, drop highest
  - Rolls: 2, 4, 5, 6
  - Drop: 6
  - Keep: 2, 4, 5
  - Sum: 11

### 3. Reroll Mechanics

**Reroll Lowest** (Instead of Drop):
- Identifies lowest dice and rolls them again
- Can be set to reroll once or until threshold met
- Example: 3d6, reroll lowest 1
  - Initial rolls: 1, 3, 5
  - Reroll the 1: gets 4
  - Final rolls: 4, 3, 5
  - Sum: 12

**Reroll Threshold**:
- Reroll any die that rolls ≤ threshold value
- Example: Reroll 1s and 2s
  - Roll: 1, 2, 5, 6
  - Reroll 1 → 4
  - Reroll 2 → 3
  - Final: 4, 3, 5, 6

**Reroll Options**:
- `rerollOnce`: true = reroll each die only once
- `rerollOnce`: false = keep rerolling until above threshold

---

## Roll Types

Each roll can be categorized for different game mechanics:

### 1. **Normal Roll**
- Standard dice roll without special rules
- Used for general purposes

### 2. **Attack Roll**
- Determines if an attack hits
- Usually 1d20 + modifiers vs. target's AC
- Natural 20 = Critical Hit
- Natural 1 = Critical Miss

### 3. **Damage Roll**
- Calculates damage dealt
- Various dice combinations (1d8+3, 2d6+5, etc.)
- Critical hits often double dice

### 4. **Healing Roll**
- Calculates hit points restored
- Similar to damage but for recovery

### 5. **Ability Check**
- Tests character skills/abilities
- 1d20 + ability modifier + proficiency (if applicable)
- Examples: Athletics, Stealth, Perception

### 6. **Saving Throw**
- Resists effects or damage
- 1d20 + ability modifier + proficiency (if proficient)
- Common saves: Dexterity, Wisdom, Constitution

### 7. **Initiative Roll**
- Determines turn order in combat
- 1d20 + Dexterity modifier
- Higher results act first

---

## Quick Rolls

Pre-configured rolls for common actions:

### Default Quick Rolls Include:
- **d20 Attack**: Basic attack roll
- **d20 Save**: Generic saving throw
- **d20 Check**: Generic ability check
- **Initiative**: Combat turn order
- **Common Damage**: 1d6, 1d8, 2d6, etc.
- **Skill Checks**: Stealth, Perception, Athletics, etc.

### Custom Quick Rolls
Players can create custom quick rolls for:
- Frequently used weapon attacks
- Spell damage combinations
- Character-specific abilities

---

## Visual & Audio Feedback

### Roll Animation Process
1. **Initiation**: Tap roll button
2. **Animation**: Dice spin animation (0.6 seconds)
3. **Sound Effect**: "RPG_Dice_Rolling" audio plays
4. **Result Display**: Final result shown with breakdown

### Result Information Display
```
⚔️ [Roll Name]: [Final Result]
- Individual rolls shown in brackets [3, 5, 6]
- Dropped dice shown as (dropped: 1, 2)
- Rerolled dice shown as (rerolled: 1 → 4)
- Base total and modifier clearly separated
```

### Color Coding
- **Red Theme**: Hero/Player rolls
- **Normal Text**: Standard rolls
- **Highlighted**: Critical successes/failures
- **Faded**: Dropped or unused dice

---

## Examples of Complex Rolls

### Example 1: Rogue's Sneak Attack
**Configuration**:
- Name: "Sneak Attack"
- Dice: 3d6 (multiple d6s for sneak attack damage)
- Modifier: +4 (from Dexterity)
- Type: Damage

**Roll Process**:
1. Roll 3d6: [4, 2, 6]
2. Sum: 12
3. Add modifier: 12 + 4 = 16 damage

### Example 2: Ability Score Generation
**Configuration**:
- Name: "Ability Score"
- Dice: 4d6
- Drop Lowest: 1
- Modifier: 0

**Roll Process**:
1. Roll 4d6: [2, 4, 5, 6]
2. Drop lowest (2): [4, 5, 6]
3. Sum: 15
4. Final ability score: 15

### Example 3: Great Weapon Fighting
**Configuration**:
- Name: "Greatsword"
- Dice: 2d6
- Reroll 1s and 2s (once)
- Modifier: +5

**Roll Process**:
1. Initial roll: [1, 2]
2. Reroll 1 → 5
3. Reroll 2 → 4
4. Final dice: [5, 4]
5. Sum: 9 + 5 = 14 damage

---

## Best Practices

1. **Name Your Rolls**: Use descriptive names for easy identification
2. **Organize by Frequency**: Keep most-used rolls at the top
3. **Set Appropriate Modifiers**: Update modifiers when your character levels up
4. **Use Roll Types**: Properly categorize rolls for accurate history tracking
5. **Quick Rolls for Speed**: Set up quick rolls for combat efficiency

---

## Technical Limits

- **Maximum Dice**: 99 dice per roll
- **Modifier Range**: -10 to +10
- **Custom Names**: Unlimited character length
- **Roll History**: Stores last 100 rolls
- **Quick Rolls**: Unlimited custom quick rolls

This comprehensive system ensures that every heroic action your character takes is accurately and fairly resolved through the dice!
