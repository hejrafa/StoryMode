# Changelog

## 1.0.2

### Fixes
- Fixed quest state detection for in-progress campaign steps so active quests are no longer incorrectly marked completed.
- Fixed completion handling for final chapter quests by removing cross-chapter completion inference that caused false positives in optional/out-of-order content.
- Fixed left-panel story card selection mapping so each card opens the correct storyline after category layout changes.
- Fixed completed-campaign card rendering and progress consistency so finished stories show complete state across cards, header text, and totals.

### UI
- Added a new `Character Stories` category and moved the Lilian Voss storyline into it.
- Updated journal header copy to show `Your Story` when a storyline is finished (`Your Story So Far` while in progress).

### Packaging
- Bumped addon version to `1.0.2` in `StoryMode.toc` and `StoryMode.lua`.

## 1.0.1

### Heritage Image Corrections
- Fixed heritage story card portraits so race entries no longer reuse stale images from previously viewed stories.
- Fixed heritage chapter portrait rendering logic to prevent question-mark carryover and ensure per-chapter portrait updates apply correctly.
- Corrected portrait source priority for heritage chapters (explicit chapter IDs/icons, then first-quest NPC portrait, then fallback path).
- Corrected multiple race-specific heritage card and chapter image IDs based on validation (including Blood Elf, Orc, Tauren, Gnome, Worgen, Draenei, Pandaren, Night Elf, Dwarf, Dark Iron Dwarf, Goblin, and Forsaken).
- Added/updated explicit heritage chapter portrait mappings where needed to stabilize first chapter visuals.
- Improved heritage card image selection so configured card icons are respected in the list view.

### Packaging
- Bumped addon version to `1.0.1` in `StoryMode.toc` and `StoryMode.lua`.

## 1.0.0

### New
- Added race-based Heritage Armor questlines under the `Identity` category:
  - Blood Elf
  - Dark Iron Dwarf
  - Draenei
  - Dwarf
  - Forsaken
  - Gnome
  - Goblin
  - Human
  - Night Elf
  - Orc
  - Pandaren
  - Tauren
  - Troll
  - Worgen
- Added chapter prerequisite handling so locked chapters now surface the exact required quest.
- Added reputation requirement support on chapters (currently used in Suramar chapters).

### Improved
- Improved next-step tracking so chapter locks and prerequisites are shown clearly in chat guidance.
- Improved chapter detail notes to display unmet prerequisite quests and reputation gates.
- Improved chapter tooltips to include current reputation progress when a chapter has rep requirements.
- Added race filtering so questlines only appear for characters that can actually do them.
- Added fallback chapter generation for lightweight questline data that only defines a start quest.
- Updated category naming from `Class Identity` to `Identity`.

### Data Updates
- Updated Suramar NPC portrait display IDs for better portrait accuracy.
- Added prerequisite requirement for the Rogue campaign chapter **Hiding In Plain Sight** (`Armies of Legionfall`).

### Packaging
- Updated addon version to `1.0.0` in both `StoryMode.toc` and addon defaults.
