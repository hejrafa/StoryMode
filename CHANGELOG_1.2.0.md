# StoryMode — Changelog 1.1.0 → 1.2.0

## New Content

### Sylvanas Windrunner: The Banshee Queen
A new Epic Storyline spanning Battle for Azeroth and Shadowlands. Seven chapters, 55 quests.

- **The March on Darkshore** — The Horde's drive through Ashenvale toward Teldrassil (War of Thorns, Week 1)
- **The Burning of Teldrassil** — Saurfang's refusal, Sylvanas's order, the world tree burns (War of Thorns, Week 2)
- **The Battle for Lordaeron** — The siege, the Blight, the abandoned city
- **The Fate of Saurfang** — Nathanos hunts the High Overlord through enemy territory (8.1)
- **Before the Gates of Orgrimmar** — The War Campaign finale and Mak'gora (8.2.5)
- **Death Rising** — Pre-patch Scourge invasion; Sylvanas shatters the Helm of Domination
- **Judgment** — Sylvanas regains her soul in Zereth Mortis and faces Tyrande's verdict (9.2)

---

## Fixes

### Suramar — trimmed to core chapters
Removed five side recruitment chapters that were padding the chain:
- Moon Guard Stronghold
- Tidying Tel'anor
- Breaking The Lightbreaker
- Jandvik's Jarl
- Eminent Grow-main

Kept all five core Suramar chapters and all nine Insurrection chapters.

### Suramar — wrong achievements removed
Chapter-level `achievementID` fields (IDs 10757–10766) pointed to unrelated achievements (cooking, Azsuna). Removed all chapter-level IDs. Top-level achievements now: Lockdown! (10617), Insurrection (11124), Good Suramaritan (11340).

### The Frozen Throne — duplicate achievement removed
"Might of Dragonblight" appeared twice (Alliance ID 35 and Horde ID 1359 are faction variants of the same achievement). Both removed. Final achievement list: Veteran of the Wrathgate (547), Icecrown: The Final Goal (40), Loremaster of Northrend (41).

### Achievement tab hidden when no achievements exist
Story chains with no associated achievements no longer show the Achievements tab. Switching to a chain with no achievements while on that tab now falls back to the Story tab.

---

## Improvements

### Achievement row — enhanced tooltip
Hovering an achievement row now shows:
- Full description
- Completion date (if earned)
- All criteria with green ✓ / red ✗ icons
- Reward text

### Achievement row — click to open Achievement log
Clicking an achievement row opens the Achievement UI, navigates to that achievement, and closes the StoryMode window.

### Class campaign achievements expanded
All twelve Legion class campaigns now include four shared cross-class achievements:
- Glory of the Legion Hero (10746)
- Breaching the Tomb (10994)
- Legionfall Commander (11171)
- Defender of the Broken Isles (11223)

Rogue additionally receives Hidden Potential of the Shadowblade (42295).

### Heritage armor achievements added
- Forsaken Heritage Armor: Return to Lordaeron (15579)
- Worgen Heritage Armor: Reclamation of Gilneas (19719)

### UI — row hover fade
Achievement rows now show a subtle left–right gradient highlight on hover instead of the default highlight texture.

### UI — divider opacity
Section divider gradient opacity reduced from 0.8 → 0.2 for a lighter, less intrusive look.

### UI — icon border
Switched to `talents-node-square-gray` atlas for the achievement icon border, tinted gold. Matches the Talent tree node style.

---

## Version bump
`StoryMode.toc`: `1.1.0` → `1.2.0`
