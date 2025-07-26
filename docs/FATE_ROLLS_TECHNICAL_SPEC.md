# Fate Rolls Technical Specification
## Dice Rolling Mechanics for Dungeon Masters

### Table of Contents
1. [Overview](#overview)
2. [Core Mechanics](#core-mechanics)
3. [Advanced DM Features](#advanced-dm-features)
4. [Fate Weaving Tools](#fate-weaving-tools)
5. [Roll Types & Applications](#roll-types--applications)
6. [Quick Rolls for DMs](#quick-rolls-for-dms)
7. [Visual & Audio Experience](#visual--audio-experience)
8. [Practical Examples](#practical-examples)

---

## Overview

Fate Rolls are the Dungeon Master's toolkit for weaving narrative destiny and controlling the flow of the game. Unlike Hero Rolls, Fate Rolls focus on behind-the-screen mechanics, NPC actions, and world events that shape the adventure.

### Core Philosophy
- **Narrative Control**: Shape story outcomes through dice
- **Flexibility**: Quickly adapt to player actions
- **Fairness**: Transparent mechanics for all to see
- **Efficiency**: Rapid resolution of multiple checks

### Key Differences from Hero Rolls
- **Purple/Mystical Theme**: Visual distinction from player rolls
- **Fate-Oriented Naming**: "Fate Roll" instead of "Hero Roll"
- **DM-Specific Features**: Tools for managing NPCs and encounters
- **Broader Application**: Environmental effects, random encounters, NPC decisions

---

## Core Mechanics

### Basic Fate Roll Structure
```
Fate Roll = (Dice Results) + Modifier + DM Narrative Interpretation
```

### Standard Dice Types
All standard D&D dice are available:
- `d4`: Minor effects, small damage
- `d6`: Standard damage, common checks  
- `d8`: Medium damage, specialized checks
- `d10`: Higher damage, percentile components
- `d12`: Heavy damage, rare checks
- `d20`: Primary resolution die
- `d100`: Percentile rolls for tables/events

### Multiple Dice Handling
DMs often roll multiple dice for groups:
- **Example**: 5 goblins attacking = 5d20 simultaneously
- **Batch Processing**: See all results at once
- **Quick Decisions**: Rapidly determine hits/misses

---

## Advanced DM Features

### 1. Advantage/Disadvantage Management

**Bulk Advantage/Disadvantage**:
- Apply to multiple creatures at once
- Example: All enemies have disadvantage due to darkness
- Visual indicator shows which rolls used adv/disadv

**Conditional Application**:
- Set conditions that trigger advantage
- Example: "Advantage when target is prone"

### 2. Complex Drop/Keep Mechanics

**Drop Mechanics for Groups**:
- **Minion Rules**: Drop lowest for weak enemies
- **Elite Enemies**: Drop highest to make challenging but fair
- **Swarm Mechanics**: Variable drop based on swarm size

**Examples**:
- **Goblin Squad** (5d20, drop lowest 2): Represents disorganized attacks
- **Elite Guard** (3d20, keep highest): Represents training and precision

### 3. Reroll Systems

**Legendary Resistance Simulation**:
- Reroll failed saves for boss monsters
- Limited uses tracked automatically

**Lucky Enemies**:
- NPCs with luck points can reroll
- DM sets reroll conditions

**Environmental Rerolls**:
- Unstable ground: Reroll 1s (they slip)
- Divine favor: Reroll failed saves once

---

## Fate Weaving Tools

### 1. Random Encounter Rolls

**Encounter Check** (d20 or d100):
- Low rolls = No encounter
- Mid rolls = Minor encounter  
- High rolls = Major encounter
- Natural 20 = Special/unique encounter

**Encounter Difficulty** (2d6):
- 2-3: Easy encounter
- 4-5: Medium encounter
- 6-8: Hard encounter
- 9-11: Deadly encounter
- 12: Legendary encounter

### 2. NPC Reaction Rolls

**Initial Reaction** (2d6 + Charisma):
- 2-3: Hostile
- 4-5: Unfriendly
- 6-8: Neutral
- 9-10: Friendly
- 11-12: Helpful

**Morale Checks** (d20):
- DC 10: Continue fighting
- DC 15: Retreat orderly
- DC 20: Fight to the death

### 3. Environmental Effects

**Weather Generation** (d20):
- 1-5: Clear
- 6-10: Cloudy
- 11-14: Light precipitation
- 15-18: Heavy precipitation
- 19-20: Extreme weather

**Hazard Activation** (d6):
- 1-2: No effect this round
- 3-4: Minor effect
- 5-6: Major effect

---

## Roll Types & Applications

### 1. **Normal Fate Roll**
- General purpose DM rolls
- NPC skill checks
- Random determinations

### 2. **NPC Attack Rolls**
- Multiple enemies attacking
- Batch processing capabilities
- Quick hit/miss determination

### 3. **Damage Rolls**
- Enemy damage calculations
- Environmental damage
- Trap damage

### 4. **Saving Throws**
- NPC saves against player abilities
- Environmental save DCs
- Mass saving throws

### 5. **Initiative Rolls**
- Roll for groups of enemies
- Quick combat setup
- Modified group initiative

### 6. **Ability Checks**
- NPC skill attempts
- Contested rolls
- Group checks (e.g., group stealth)

### 7. **Special DM Rolls**
- **Treasure Generation**: Random loot
- **Random Tables**: Any percentile table
- **Divine Intervention**: Deity response
- **Wild Magic**: Surge effects

---

## Quick Rolls for DMs

### Pre-Configured DM Quick Rolls

**Combat Management**:
- **Mob Attack**: 5d20 for group attacks
- **AoE Save**: 6d20 for area effects
- **Mass Damage**: 8d6 for fireball, etc.

**Exploration**:
- **Perception Check**: Group perception
- **Stealth Check**: Enemy stealth
- **Trap Check**: Trap activation

**Social Encounters**:
- **Reaction Roll**: 2d6+modifier
- **Insight Contest**: NPC deception
- **Persuasion DC**: Set difficulty

**Environmental**:
- **Weather Check**: Daily weather
- **Random Encounter**: Hourly checks
- **Resource Depletion**: Survival checks

### Custom Quick Roll Examples

**Boss Legendary Action**:
- Name: "Dragon Breath"
- Dice: 12d6
- Type: Damage
- Modifier: +0

**Minion Swarm**:
- Name: "Kobold Pack"
- Dice: 6d20
- Drop Lowest: 2
- Modifier: +2

---

## Visual & Audio Experience

### DM-Specific Interface

**Color Scheme**:
- **Purple/Mystical**: Primary theme
- **Orange Accents**: Important information
- **Dark Background**: Easy on eyes during long sessions

### Roll Animations
1. **Mystical Effects**: Ethereal dice spinning
2. **Fate Weaving**: Visual threads connecting dice
3. **Sound**: "dice_shaking_waiting_Screen" for anticipation
4. **Result Reveal**: Dramatic presentation

### Result Display Format
```
🔮 [Fate Roll Name]: [Final Result]
- All rolls: [15, 8, 12, 3, 19]
- Active rolls: [15, 12, 19] 
- Dropped/Unused: (dropped: 3, 8)
- Modifiers applied: +3
- Special conditions noted
```

---

## Practical Examples

### Example 1: Goblin Ambush
**Setup**: 6 goblins attack the party

**Configuration**:
- Name: "Goblin Ambush"
- Dice: 6d20
- Modifier: +4 (attack bonus)
- Drop Lowest: 1 (one goblin trips)

**Process**:
1. Roll 6d20: [3, 15, 8, 19, 12, 7]
2. Drop lowest (3): [15, 8, 19, 12, 7]
3. Add +4 to each: [19, 12, 23, 16, 11]
4. Compare to player ACs

### Example 2: Dragon's Lair Save
**Setup**: Party triggers ancient trap, all must save

**Configuration**:
- Name: "Ancient Rune Trap"
- Dice: 5d20 (5 party members)
- DC: 15 Wisdom save
- Advantage for those with magic items

**Process**:
1. Roll base saves: [10, 14, 8, 17, 12]
2. Reroll for advantage (2 players): [10→16, 8→13]
3. Final saves: [16, 14, 13, 17, 12]
4. Successes: 2 pass, 3 fail

### Example 3: Town Reaction
**Setup**: Party enters new town with bad reputation

**Configuration**:
- Name: "Town Reception"
- Dice: 2d6
- Modifier: -2 (bad reputation)
- Type: Reaction roll

**Process**:
1. Roll 2d6: [4, 3] = 7
2. Add modifier: 7 - 2 = 5
3. Result: Unfriendly reception
4. NPCs are suspicious but not hostile

### Example 4: Treasure Hoard
**Setup**: Rolling for treasure in dragon's hoard

**Configuration**:
- Name: "Dragon Hoard"
- Multiple rolls:
  - Gold: 6d6 × 100
  - Gems: 3d6
  - Magic items: 1d100

**Process**:
1. Gold: [4,6,2,5,3,4] = 2,400 gp
2. Gems: [5,3,6] = 14 gems
3. Magic item: 73 = Rare weapon

---

## Best Practices for DMs

### 1. **Pre-Session Setup**
- Configure common encounter rolls
- Set up boss abilities
- Prepare environmental checks

### 2. **During Combat**
- Use batch rolling for multiple enemies
- Quick Rolls for common attacks
- Track special abilities separately

### 3. **Narrative Integration**
- Let dice inspire story moments
- Use failed rolls for complications
- Build tension with visible rolling

### 4. **Efficiency Tips**
- Group similar creatures
- Pre-calculate common modifiers
- Use Quick Rolls extensively

### 5. **Fairness & Transparency**
- Roll openly when appropriate
- Explain special mechanics
- Let players see boss rolls

---

## Advanced DM Techniques

### 1. **Degrees of Success**
Using roll margins for narrative:
- **Fail by 10+**: Critical failure
- **Fail by 5-9**: Failure with complication
- **Fail by 1-4**: Simple failure
- **Success by 1-4**: Simple success
- **Success by 5-9**: Success with benefit
- **Success by 10+**: Critical success

### 2. **Scaled Encounters**
Adjusting difficulty on the fly:
- Add/remove dice from pools
- Modify drop/keep numbers
- Adjust modifiers mid-combat

### 3. **Narrative Dice Pools**
Building tension with accumulating dice:
- Start with 1d6 for danger level
- Add 1d6 each failed check
- Roll pool when threshold reached

---

## Technical Specifications

### Limits & Ranges
- **Maximum Dice**: 99 per roll
- **Modifier Range**: -10 to +10
- **Drop/Reroll**: Up to (total dice - 1)
- **History Storage**: Last 50 DM rolls
- **Quick Rolls**: Unlimited custom configurations

### Performance Optimizations
- Batch processing for multiple rolls
- Efficient animation for large dice pools
- Quick result calculation
- Minimal UI updates during rolling

---

## Conclusion

Fate Rolls provide Dungeon Masters with a comprehensive, flexible, and efficient system for managing all aspects of game resolution. From single NPC checks to massive battlefield calculations, the system scales to meet any narrative need while maintaining the mystique and drama essential to great storytelling.

The power to weave fate lies in your hands—use it wisely!
