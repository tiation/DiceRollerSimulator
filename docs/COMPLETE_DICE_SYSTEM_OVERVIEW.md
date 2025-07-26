# Complete Dice Rolling System Overview
## Dice of Middle-Earth - Comprehensive Technical Guide

### Table of Contents
1. [System Introduction](#system-introduction)
2. [Universal Mechanics](#universal-mechanics)
3. [Hero Rolls (Players)](#hero-rolls-players)
4. [Fate Rolls (Dungeon Masters)](#fate-rolls-dungeon-masters)
5. [Quick Reference Tables](#quick-reference-tables)
6. [Advanced Formulas](#advanced-formulas)
7. [Edge Cases & Rules](#edge-cases--rules)

---

## System Introduction

Dice of Middle-Earth implements a comprehensive dice rolling system designed to handle every possible dice mechanic in Dungeons & Dragons 5th Edition and beyond. The system is split into two specialized interfaces:

- **Hero Rolls**: Player-focused interface with red theming
- **Fate Rolls**: DM-focused interface with purple theming

Both systems share core mechanics while offering role-specific features.

---

## Universal Mechanics

### Core Dice Formula
```
Final Result = Σ(Kept Dice) + Total Modifier
```

Where:
- **Kept Dice** = All rolled dice - dropped dice
- **Total Modifier** = Base modifier + situational modifiers

### Dice Resolution Pipeline

1. **Initial Roll Phase**
   - Generate random numbers for each die
   - Apply per-die modifications (min/max)

2. **Manipulation Phase**
   - Apply advantage/disadvantage (d20 only)
   - Process drops/keeps
   - Execute rerolls

3. **Calculation Phase**
   - Sum kept dice
   - Add modifiers
   - Display results

### Random Number Generation
- **True Random**: Each die uses system random generation
- **Range**: 1 to (number of sides) inclusive
- **No Weighting**: Fair probability distribution

---

## Hero Rolls (Players)

### Complete Feature Set

#### 1. Standard Rolling
- **Single Die**: 1dX + modifier
- **Multiple Dice**: NdX + modifier
- **Mixed Pools**: Not supported (use multiple rolls)

#### 2. Advantage/Disadvantage (d20 only)
```
Advantage: result = max(roll1, roll2) + modifier
Disadvantage: result = min(roll1, roll2) + modifier
```

#### 3. Drop/Keep Mechanics
```
Drop Lowest N: Remove N smallest values before summing
Drop Highest N: Remove N largest values before summing
Keep Highest N: Equivalent to drop lowest (total - N)
Keep Lowest N: Equivalent to drop highest (total - N)
```

#### 4. Reroll Mechanics
```
Reroll Once: if (die ≤ threshold) { reroll once }
Reroll Infinite: while (die ≤ threshold) { reroll }
```

#### 5. Per-Die Modifiers
```
Minimum: die_result = max(die_result, 1 + modifier)
Maximum: die_result = min(die_result, sides + modifier)
```

### Hero Roll Configuration Options

| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Name | Text | "Hero Roll X" | Custom roll label |
| Dice Type | d4-d100 | d20 | Shape of dice |
| Number | 1-99 | 1 | Quantity to roll |
| Modifier | -10 to +10 | 0 | Flat bonus/penalty |
| Drop/Keep | 0 to (N-1) | 0 | Dice manipulation |
| Reroll Target | 1-19 | 1 | Reroll if ≤ this |
| Min/Max Mod | -6 to +6 | 0 | Per-die adjustment |
| Advantage | On/Off | Off | 2d20 keep high/low |

---

## Fate Rolls (Dungeon Masters)

### Complete Feature Set

All Hero Roll features plus:

#### 1. Batch Rolling
- Roll for multiple creatures simultaneously
- Individual modifiers per creature
- Group advantage/disadvantage

#### 2. Narrative Tools
- Degrees of success calculation
- Margin tracking for contests
- Critical range customization

#### 3. Table Integration
- Percentile table lookups
- Weighted random events
- Cascading roll chains

### Fate Roll Special Applications

| Use Case | Dice Config | Special Rules |
|----------|-------------|---------------|
| Mob Attacks | Xd20+Y | Drop lowest for chaos |
| Elite Units | 3d20 keep 1 | Simulates training |
| Swarm Damage | Xd6 | X = swarm size/5 |
| Morale Check | 1d20+Wis | DC based on losses |
| Reaction Roll | 2d6+Cha | Fixed result table |
| Treasure | Variable | Multiple roll types |

---

## Quick Reference Tables

### Standard Dice Probabilities

| Die Type | Average | Min | Max | Crit (5%) |
|----------|---------|-----|-----|-----------|
| d4 | 2.5 | 1 | 4 | N/A |
| d6 | 3.5 | 1 | 6 | N/A |
| d8 | 4.5 | 1 | 8 | N/A |
| d10 | 5.5 | 1 | 10 | N/A |
| d12 | 6.5 | 1 | 12 | N/A |
| d20 | 10.5 | 1 | 20 | 20 |
| d100 | 50.5 | 1 | 100 | 95-100 |

### Advantage/Disadvantage Statistics (d20)

| Target DC | Normal | Advantage | Disadvantage |
|-----------|---------|-----------|--------------|
| 5 | 80% | 96% | 64% |
| 10 | 55% | 79.75% | 30.25% |
| 15 | 30% | 51% | 9% |
| 20 | 5% | 9.75% | 0.25% |

### Multiple Dice Averages

| Dice | Average | Reliable Range (68%) |
|------|---------|---------------------|
| 2d6 | 7 | 5-9 |
| 3d6 | 10.5 | 8-13 |
| 4d6 | 14 | 10-18 |
| 2d10 | 11 | 7-15 |
| 2d20 | 21 | 13-29 |

---

## Advanced Formulas

### Complex Roll Calculations

#### Great Weapon Fighting (Reroll 1s and 2s once)
```
foreach die in dice_pool:
    if die.value <= 2:
        die.value = roll_new()
    total += die.value
final = total + modifier
```

#### Elven Accuracy (Super Advantage)
```
rolls = [d20(), d20(), d20()]
result = max(rolls) + modifier
```

#### Halfling Lucky (Reroll natural 1s)
```
if die.value == 1:
    die.value = roll_new()
    # Can still be 1
```

#### Savage Attacker (Reroll damage once, keep higher)
```
roll1 = sum(dice_pool)
roll2 = sum(dice_pool)
total = max(roll1, roll2) + modifier
```

### Statistical Formulas

#### Expected Value with Drop Lowest
```
E[XdY drop lowest Z] = Y * (X-Z) * (X-Z+1) / (2X-2Z+1)
```

#### Probability of Meeting DC with Advantage
```
P(success) = 1 - P(fail)²
P(fail) = (DC - modifier - 1) / 20
```

#### Average Damage Over Time
```
DPR = (hit_chance * average_damage) + (crit_chance * crit_damage)
```

---

## Edge Cases & Rules

### Critical Rules

1. **Natural 20 (d20 only)**
   - Always succeeds on attacks
   - Doubles damage dice
   - No auto-success on skills/saves

2. **Natural 1 (d20 only)**
   - Always fails on attacks
   - No additional penalty
   - No auto-fail on skills/saves

### Modifier Stacking

1. **Same Type Don't Stack**
   - Multiple enhancement bonuses → use highest
   - Multiple circumstance bonuses → use highest

2. **Different Types Stack**
   - Enhancement + Circumstance + Competence = Total

### Reroll Precedence

Order of operations:
1. Per-die minimums/maximums
2. Advantage/Disadvantage
3. Drop/Keep mechanics
4. Reroll mechanics
5. Final modifier

### System Limits

| Component | Maximum | Notes |
|-----------|---------|-------|
| Dice per roll | 99 | Performance limit |
| Modifier range | ±10 | Game balance |
| Drop/Keep | N-1 | Must keep 1 die |
| Reroll iterations | 100 | Prevent infinite loops |
| Roll history | 100 | Memory management |
| Custom sides | 999 | Practical limit |

### Special Interactions

#### Advantage + Reroll
- Roll 2d20 first
- Apply reroll to chosen die
- Cannot reroll the dropped die

#### Multiple Drops
- Process drops simultaneously
- Cannot drop same die twice
- Ties broken by position

#### Modifier Conflicts
- Min/Max modifiers apply first
- Then standard modifiers
- Prevents impossible values

---

## Conclusion

This dice system provides complete coverage of all D&D 5e mechanics and extends beyond to support homebrew and variant rules. The dual interface (Hero/Fate) ensures both players and DMs have optimized tools for their specific needs while maintaining consistency in core mechanics.

For detailed examples and specific use cases, refer to:
- [Hero Rolls Technical Specification](./HERO_ROLLS_TECHNICAL_SPEC.md)
- [Fate Rolls Technical Specification](./FATE_ROLLS_TECHNICAL_SPEC.md)

Remember: The dice are tools for storytelling. Use them to create memorable moments!
