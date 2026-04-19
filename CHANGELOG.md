# Changelog

## 1.3.5

### Content
- Corrected notes for the three removed limited-time chapters in the Banshee Queen storyline (March on Darkshore, Burning of Teldrassil, Death Rising) — they now honestly state the quests are no longer in-game and point players to the recap text instead of sending them to Zidormi

---

## 1.3.4

### Fixes
- Fixed a bug where quests after an in-progress quest were falsely marked "effectively complete" when a later quest in the same chapter had been flagged done (e.g. by a previous run or a warbound flag from another character) — the chain inference now stops if any earlier quest is still in the player's log
- Fixed all chapters in the Banshee Queen storyline showing as complete while the player was actively questing through them

### Content
- Rewrote all chapter requirement messages to be actionable — version numbers (8.0.1, 8.1, 9.0.1, etc.) replaced with plain instructions: where to go, who to talk to, what to complete
- Updated generated lock messages: "Requires campaign quest: X" → "Pick up X from NPC to unlock this chapter"; "Requires previous quest: X" → "Complete X first to continue the story"; level gates now read "You need to reach level X" instead of "Requires level X"

---

## 1.3.2

### Fixes
- Fixed persistent taint errors ("secret number value") when hovering world-quest POIs — replaced the private `GameTooltip` frame with a plain `BackdropTemplate` frame that has no connection to the GameTooltip C layer, eliminating both the `EmbeddedItemTooltip` and `MoneyFrame` taint chains for good
- Fixed tooltip crash (`GetWordWrap` nil value) caused by FontString not exposing that method — wrap state is now tracked in a parallel table
- Fixed Lua "more than 200 local variables" error — tooltip helpers are scoped inside a `do/end` block

### Polish
- Tooltip minimum width raised to 220px; minimap tooltip sizes to content only

---

## 1.3.1

### Fixes
- Corrected addon name casing: "StoryMode" → "Story Mode" in all user-facing chat messages and tooltips
- Minimap button tooltip now reads "Click to open" instead of "Click to toggle"

### Organisation
- Moved **Daughter of the Sea** (Jaina) and **Sylvanas** from Epic Storylines → Character Stories
- Zone labels on story cards now show at most two zones (truncated with … when there are more)

---

## 1.3.0

### New Content
- Added a new Epic Storyline: **Daughter of the Sea** (Jaina Proudmoore) — four chapters spanning Battle for Azeroth
  - A Nation Divided — Jaina returns to Kul Tiras in chains
  - Enemies Within — Priscilla Ashvane's conspiracy in Tiragarde Sound
  - The Pride of Kul Tiras — recovering the lost fleet across four dungeons; Jaina becomes Lord Admiral
  - The Fog of War — Jaina leads the Alliance assault on Zuldazar (8.1)
- Added new **Short Stories** category
- Added first Short Story: **A Tea Party** (Drustvar) — Abby Lewis's tea party in Glenbrook Homestead

### Fixes
- Fixed `EmbeddedItemTooltip` taint error ("secret number value") when hovering world quest POIs — StoryMode now uses a private `GameTooltip` frame and no longer touches the shared global
- Fixed ping frame strata (`TOOLTIP` → `HIGH`) to prevent world map frame layout interference
- Fixed Lilian Voss — The Marshal's Grave: "Operation: Grave Digger" and "Operation: Water Wise" moved to optional and no longer block chapter entry; chains now start from the correct in-zone quest

---

## 1.2.3

### Fixes
- Fixed MoneyFrame taint error ("secret number value") when hovering world quest POIs or bag items while StoryMode is loaded — tooltip now uses a named `GameTooltip` frame instead of the shared global
- Fixed scrollbar position in the detail pane — shifted 8px to align correctly within the panel
- Added 2px inset around right-panel content so text no longer sits flush against the border

### Content
- Added Nighthold achievement (42030) to the Insurrection (Suramar) achievements list
- Marked Drustvar as Alliance-only — Horde players cannot access the full zone storyline without Chromie Time

---

## 1.2.2

### Fixes
- Fixed completed quests showing stale `0/N` objective counters in tooltips — objectives are now hidden for completed quests
- Fixed detail pane content being clipped by 8px on the right and bottom edges
- Removed reputation indicators from chapter notes, quest lock tooltips, and track-node hover tooltips

### Content
- Added achievement 42628 to the Insurrection (Suramar) achievements list

### Organisation
- Moved all data files into category subfolders: `Heritage/`, `Campaigns/`, `Storylines/`
- Updated `StoryMode.toc` load order to reflect new paths

---

## 1.2.1

### Fixes
- Replaced custom tooltip implementation with native `GameTooltip` — eliminates clipping, missing titles, and incorrect sizing
- Marked "Feed Valtrois" in Suramar's Feeding Shal'Aran chapter as optional — no longer blocks chapter completion or shows as "not yet available" when skipped
- Added generic `optional = true` quest flag support: optional quests are excluded from chapter progress totals and rendered with a distinct dimmed style

---

## 1.2.0

### New Content
- Added a new Epic Storyline: **The Banshee Queen** (Sylvanas Windrunner) — seven chapters spanning Battle for Azeroth and Shadowlands
  - The March on Darkshore (War of Thorns, Week 1)
  - The Burning of Teldrassil (War of Thorns, Week 2)
  - The Battle for Lordaeron
  - The Fate of Saurfang (8.1)
  - Before the Gates of Orgrimmar — Mak'gora (8.2.5)
  - Death Rising — pre-patch Scourge invasion and Helm shattering
  - Judgment — Sylvanas faces Tyrande's verdict in Zereth Mortis (9.2)

### Fixes
- Fixed wrong achievements showing in Suramar Insurrection — removed chapter-level achievement IDs (10757–10766) that pointed to unrelated content (cooking achievements, Azsuna quests)
- Fixed duplicate "Might of Dragonblight" in The Frozen Throne — Alliance (35) and Horde (1359) are faction variants of the same achievement; removed both
- Trimmed Suramar to five core chapters — removed five side recruitment chapters (Moon Guard Stronghold, Tidying Tel'anor, Breaking The Lightbreaker, Jandvik's Jarl, Eminent Grow-main)
- Achievements tab is now hidden for story chains that have no associated achievements; switching to such a chain while on the tab falls back to Story

### Improvements
- Achievement row tooltip now shows full description, all criteria with completion icons, reward text, and earned date
- Clicking an achievement row opens the Achievement UI, navigates to that achievement, and closes the StoryMode window
- All twelve Legion class campaigns now include four shared cross-class achievements: Glory of the Legion Hero (10746), Breaching the Tomb (10994), Legionfall Commander (11171), Defender of the Broken Isles (11223)
- Rogue class campaign additionally includes Hidden Potential of the Shadowblade (42295)
- Added heritage achievements: Forsaken — Return to Lordaeron (15579), Worgen — Reclamation of Gilneas (19719)
- Row hover now shows a subtle gradient fade instead of the default highlight texture
- Section divider gradient opacity reduced from 0.8 → 0.2
- Achievement icon border switched to `talents-node-square-gray` atlas, tinted gold

### Packaging
- Bumped addon version to `1.2.0`
- Added `SylvanasData.lua` to load order in `StoryMode.toc`

---

## 1.1.0

### New
- Added a major new Epic Storyline: **The Frozen Throne** (Arthas Menethil)
- Added a dedicated campaign data module: `FrozenThroneData.lua`
- Added broad Wrath narrative coverage including:
  - Culling of Stratholme
  - Wrathgate arc and Dragonblight prelude quests
  - Core Icecrown war chapters
  - Frozen Halls lead-in through Halls of Reflection

### Data Updates
- Expanded quest coverage for the Arthas campaign to include narrative prerequisites and faction variants where applicable
- Removed the non-narrative completionist ledger chapter to keep the campaign story-focused
- Updated key NPC portrait display IDs for accuracy: High Commander Halford Wyrmbane, Crusade Commander Entari, Thassarian, Matthias Lehner

### UI / Organization
- Registered **The Frozen Throne** under `Epic Storylines`
- Updated campaign listing documentation in `README.md`

### Packaging
- Bumped addon version to `1.1.0`
- Added `FrozenThroneData.lua` to load order in `StoryMode.toc`

---

## 1.0.2

### Fixes
- Fixed quest state detection for in-progress campaign steps so active quests are no longer incorrectly marked completed
- Fixed completion handling for final chapter quests by removing cross-chapter completion inference that caused false positives in optional/out-of-order content
- Fixed left-panel story card selection mapping so each card opens the correct storyline after category layout changes
- Fixed completed-campaign card rendering and progress consistency so finished stories show complete state across cards, header text, and totals

### UI
- Added a new `Character Stories` category and moved the Lilian Voss storyline into it
- Updated journal header copy to show `Your Story` when a storyline is finished (`Your Story So Far` while in progress)

### Packaging
- Bumped addon version to `1.0.2`

---

## 1.0.1

### Heritage Image Corrections
- Fixed heritage story card portraits so race entries no longer reuse stale images from previously viewed stories
- Fixed heritage chapter portrait rendering logic to prevent question-mark carryover and ensure per-chapter portrait updates apply correctly
- Corrected portrait source priority for heritage chapters (explicit chapter IDs/icons, then first-quest NPC portrait, then fallback path)
- Corrected multiple race-specific heritage card and chapter image IDs based on validation (Blood Elf, Orc, Tauren, Gnome, Worgen, Draenei, Pandaren, Night Elf, Dwarf, Dark Iron Dwarf, Goblin, Forsaken)
- Added/updated explicit heritage chapter portrait mappings where needed to stabilize first chapter visuals
- Improved heritage card image selection so configured card icons are respected in the list view

### Packaging
- Bumped addon version to `1.0.1`

---

## 1.0.0

### New
- Added race-based Heritage Armor questlines under the `Identity` category: Blood Elf, Dark Iron Dwarf, Draenei, Dwarf, Forsaken, Gnome, Goblin, Human, Night Elf, Orc, Pandaren, Tauren, Troll, Worgen
- Added chapter prerequisite handling so locked chapters now surface the exact required quest
- Added reputation requirement support on chapters (currently used in Suramar chapters)

### Improved
- Improved next-step tracking so chapter locks and prerequisites are shown clearly in chat guidance
- Improved chapter detail notes to display unmet prerequisite quests and reputation gates
- Improved chapter tooltips to include current reputation progress when a chapter has rep requirements
- Added race filtering so questlines only appear for characters that can actually do them
- Added fallback chapter generation for lightweight questline data that only defines a start quest
- Updated category naming from `Class Identity` to `Identity`

### Data Updates
- Updated Suramar NPC portrait display IDs for better portrait accuracy
- Added prerequisite requirement for the Rogue campaign chapter **Hiding In Plain Sight** (`Armies of Legionfall`)

### Packaging
- Updated addon version to `1.0.0`
