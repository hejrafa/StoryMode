# Changelog

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
