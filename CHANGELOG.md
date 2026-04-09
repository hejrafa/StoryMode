# Changelog

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
