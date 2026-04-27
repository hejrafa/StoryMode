# Changelog

## 1.5.0

### Maintenance
- Bumped addon version to `1.5.0`
- Updated addon metadata with the plain **Story Mode** title, refreshed notes text, and the new addon icon asset
- Split quest progress helpers and waypoint tracking helpers out of `StoryMode.lua` into `Core/Progress.lua` and `Core/Tracking.lua`
- Cleaned storyline achievement lists to keep story-relevant achievements only, using normal/base dungeon and raid clears plus normal boss kills where applicable
- Cleaned chapter hint behavior so notes only appear on gated/squared chapters with actionable unlock steps; removed misleading legacy Wrath notes
- Added gated hints for Rogue "Hiding In Plain Sight" and the Forsaken loyalist epilogue so squared chapters always explain their prerequisite
- Added faction-aware achievement selection so faction-specific story achievements, including The Jade Forest's Upjade Complete, resolve to the player's faction variant

### Content
- **The Master of Revendreth** — new epic storyline for the Revendreth zone (Shadowlands). Covers the full seven-chapter zone campaign: arrival in Darkhaven, Denathrius and the Court of Harvesters, the Accuser, the Penitent Hunt, Theotar and the Ember Ward, Prince Renathal's rescue, and the reveal that Denathrius is funneling anima to the Maw
- Added Revendreth story and chapter portraits using verified display IDs for Denathrius, Rendle, the Accuser, the Fearstalker, Theotar, and Prince Renathal
- Added Revendreth-related achievements for Loremaster, Sojourner, Halls of Atonement, Sanguine Depths, and Castle Nathria
- Refreshed story, campaign, and heritage descriptions and linked each track to a thematically matching Encounter Journal cover source
- Re-enabled **The Klaxxi** in Epic Storylines and positioned it after **The Jade Forest**
- Fixed **The Klaxxi** starting guidance so "Begin This Story" points to Bowmistress Li on the Serpent's Spine instead of opening the Dread Wastes map without a waypoint, added a first-chapter note about the wall/rope route and Zidormi phasing, and set Bowmistress Li as the first chapter portrait
- Added faction reputation data to story journals across the current story set, including The Klaxxi, Jade Forest, Suramar, BfA zone stories, Revendreth, Frozen Throne, Lilian Voss, Sylvanas, and A Tea Party
- Added the Jade Forest dungeon finale quest **Deep Doubts, Deep Wisdom** and corrected **Restoring Jade's Purity** to Priestess Summerpetal, including her chapter portrait display ID

### UI
- Removed the portrait border from the Introduction card so only the flame icon is shown
- Adjusted the left story list scroll area to use the full panel height with only border-width top/bottom padding
- Greyed incomplete achievement borders while keeping the square frame crisp and layered above the icon
- Renamed the first detail tab to Adventure and moved completed chapter recaps into a new Journal tab after Progress
- Swapped Adventure cover art to use high-resolution dungeon and raid loading screen textures when a matching instance loading screen is available, falling back to Encounter Journal art otherwise
- Added large Adventure cover art sourced from Blizzard's Encounter Journal images for story, campaign, and heritage pages, with a soft fade mask and title overlay
- Updated the left adventure list cards to show the selected adventure's cover image as the active card background, with white title text, yellow zone text, and no separate custom gradient overlay
- Replaced the left adventure completion badge with a Housing Dashboard-style ribbon using Blizzard's task flag and checkmark atlases
- Fixed the Jade Forest "Orchard and Quarry" chapter portrait so it uses Old Man Misteye instead of falling through to Shao the Defiant
- Fixed the Jade Forest "The Temple of the Jade Serpent" chapter portrait so it uses Foreman Raike's verified display ID
- Added Journal faction cards with Housing Dashboard card art, circular reputation progress, faction standing text, hover states, and reputation tooltips
- Added a "Factions" section heading to the Journal tab and removed the Journal/Achievements hero title block for a cleaner content-first layout
- Removed the Progress tab portrait while keeping the story title and tightened its title, summary, and chapter-track spacing
- Replaced the intro page flame icon with custom Story Mode hero art, refreshed the intro copy, and updated the intro card to use the custom addon icon
- Updated the left intro divider to greet the current character by name
- Updated the minimap button to use the custom addon icon without the fake shadow layer
- Hid the detail scrollbar when the active view has no scrollable overflow
- Limited the left Achievements section to four icons per row and centered the grid
- Added a start-quest coordinate fallback so stories with `startMapID`, `startX`, and `startY` can still set a native waypoint when a specific NPC location is missing

---

## 1.4.0

### Fixes
- Fixed taint propagation from the Track button — resolved `attempt to perform arithmetic on a secret number value` error originating from Blizzard_MoneyFrame when hovering world-quest tooltips. Track now routes through a secure macro (`SecureActionButtonTemplate`) so OpenWorldMap, quest watch, and waypoint calls execute in a trusted context
- Fixed `Cannot anchor protected frames to regions` error — the secure overlay is now a sibling of sTrackBtn (parented to detailChild) rather than a child of it, so sTrackBtn itself remains anchor-eligible for FontString layout
- Combat guard on UI toggle — attempting to open or close Story Mode while in combat now shows an error hint at the top of the screen instead of silently failing or tainting the frame
- **Quest counts now match chapter sums** — story card totals were inflated because `GetCampaignProgress` counted every raw quest regardless of faction, optional, or hidden status. Now applies the same three filters as chapter progress: `IsQuestForPlayer`, `not q.optional`, `not ShouldHideQuest`
- **Story complete banner now fires reliably** — the chapter/story completion check was running synchronously on `QUEST_TURNED_IN` before `IsQuestFlaggedCompleted` was guaranteed to be updated; moved inside the existing 0.1s timer
- **Story card checkmark updates live** — checkmark on the left panel story card was only set at window build time and required a `/reload` to appear after finishing a story; now updated immediately when the story completes
- **Story complete detection no longer blocked by loreOnly/achievement chapters** — `allDone` check was treating chapters with `t == 0` (no trackable quests) as incomplete; skips them correctly now
- Fixed achievement tooltip rewards that return boolean values from Blizzard's API, preventing a crash when hovering achievements such as Temple of the Jade Serpent Guild Run
- Restored visible hover feedback on dimmed chapter nodes and the Continue Story button

### New
- **Replayable chapters** — chapters marked `replayable = true` show a "Mark as Played" button backed by `StoryModeDB.playedChapters`; hides quest cards and the achievement row so the button is the sole interaction. Applied to "The Battle for Lordaeron" (Archivist Sylvia replay)
- `ShouldHideQuest` helper — `showIf` / `hideIf` conditions now filter quest cards and progress counting, not just completion checks

### Maintenance
- Split self-contained systems out of `StoryMode.lua` into `Core/SavedVariables.lua` and focused `UI/*` modules for the private tooltip, minimap button, and completion banners. This reduces the main Lua chunk's local-variable count and prevents WoW's Lua 5.1 `main function has more than 200 local variables` load error from recurring during small refactors

### Content
- **The Jade Forest** — new epic storyline for the Jade Forest zone (Mists of Pandaria), rebuilt as a full guided campaign with separate Alliance and Horde openings, faction-specific quest flow, shared Dawn's Blossom / Tian Monastery / Jade Serpent chapters, zone achievements, and a Temple of the Jade Serpent dungeon finale using the dungeon achievement art
- **The Klaxxi** — new epic storyline for the Dread Wastes zone (Mists of Pandaria). Five chapters: awakening the first paragons at Klaxxi'vess, amber crafting at Kypari Zar, Skeer the Bloodseeker and Kaz'tik's kunchong, the maritime chaos of Soggy's Gamble, and the final assault on the Heart of Fear. Includes a note on the SoO betrayal payoff
- **The Dark Heart of Nazmir** — new Horde-only epic storyline for the Nazmir zone (Battle for Azeroth). Covers all 8 achievement chapters: meeting Bwonsamdi and forging the pact for one million souls, the bat loa Hir'eek's corruption, Torga's death, Krag'wa in Gloom Hollow, the Titan Keeper facility and G'huun containment, and the final assault on Grand Ma'da Ateena. Parallel to The Witchwood of Drustvar
- **Sylvanas — The Banshee Queen** extended through Dragonflight 10.1.7: added "Stay of Execution", "Breaking the Cycle", "What Comes After", "The Long Hunt", and "A Chilling Summons" chapters; Shadowlands intro now has separate Horde/Alliance entry quests with faction filtering
- **Lilian Voss** — added "What Comes After" chapter covering the Horde Council formation quests (including The Hidden Need, 57376); updated BfA portrait to display ID 85799
- **The Frozen Throne** — Saronite Mines chapter updated to use Darkspeaker R'khem; added Intelligence Gathering and The Grand Admiral's Plan chest quests; significant quest chain expansion
- **Jade Forest, Allies of the Forest** — corrected first Horde quest giver from Shademaster Kiryn to Sergeant Gorrok; added Gorrok to `npcDisplayIDs` (39047); extended chapter recap with bridge into Chapter 3

---

## 1.3.4

### Fixes
- Fixed quest cards for mixed Alliance/Horde chapters — opposing-faction quests are now hidden and the positioning chain skips them cleanly
- Fixed Tides of Vengeance achievement in Lilian Voss showing the Alliance variant — corrected to Horde (13466)
- Removed a misidentified Quel'delar quest from the Banshee Queen Frozen Halls chapter
- Changed chapter icon from 30721 to 341221

### New
- Per-quest faction filtering — quests tagged `faction = "Alliance"` or `faction = "Horde"` are invisible to the opposing side in progress tracking, next-quest suggestions, and the quest card list
- All faction variants in The Frozen Throne are now tagged (Dragonblight prelude, Angrathar, Icecrown Vanguard, Gates of Icecrown, Sindragosa's Fall, Frozen Halls arc)
- Broken Shore chapter (Banshee Queen) expanded from 2 to 6 quests — added the Legion Returns muster quest and three optional Illidari follow-up quests in Orgrimmar
- Per-chapter faction filtering — chapters tagged `faction` are only shown to matching faction players

### Content
- Updated Frozen Halls entry note — no Chromie Time needed, just land in Northrend Dalaran
- Updated Broken Shore entry note — removed "Horde only" since Alliance players won't see this storyline anyway
- Added achievements across all storylines: Suramar (Nighthold wings + prestige kills + Glory meta), Lilian Voss (Scarlet dungeons + bonus achievements + BfA war campaign), Banshee Queen (Frozen Halls dungeons + bonus + BfA campaign + Zereth Mortis), Jaina (Kul Tiras zone story + four dungeons + Battle of Dazar'alor), Drustvar (Waycrest Manor dungeon completions + bonus)
- **The Frozen Throne (Arthas) rebuild** — restructured the entire storyline:
  - Restructured chapters 1-7: Recruiting the Taunka, Destroy the Nerubians, Annexing the Taunka, The Forsaken Plague, The Red Dragonflight, Victory Over the Scourge, The Betrayal
  - Added full Dragonblight Alliance campaign (Wintergarde) with its own chapter and separate Alliance versions of Red Dragonflight and Victory Over the Scourge
  - Removed obsolete "The Betrayal" chapter (quests no longer obtainable)
  - Added portraitDisplayID to each chapter and story-level chapterDisplayIDs table for faction-split portrait rendering
  - Updated chapter portraits: Emissary Brighthoof (23805) for Recruiting the Taunka, Overlord Agmar (23806) for Nerubians/Chapters 2/5, Icemist (23976) for Annexing, Middleton (23875) for Forsaken Plague, Saurfang (23034) for Victory Over Scourge, Fordragon (24879) for Alliance chapters, Foehammer (24351) for Dragonblight Campaign
  - Rewrote all chapter recaps in narrative style matching the Banshee Queen storyline
  - Recaps now include the Forsaken betrayal and blight attack at the Wrathgate

---

## 1.3.3

### Fixes
- Fixed quests falsely marked complete while actively in-progress — chain inference now stops if any earlier quest is still in the player's log
- Fixed all Banshee Queen chapters showing as complete during active questing
- Fixed quest card checkmarks not updating until `/reload` — detail panel now re-renders immediately on `QUEST_TURNED_IN`

### Content
- **The Banshee Queen (Sylvanas) full rebuild** — removed three unplayable limited-time chapters and a fabricated chapter with made-up quest IDs; replaced with four fully playable chapters spanning five expansions:
  - **The Frozen Halls** (Wrath) — Forge of Souls → Pit of Saron → Halls of Reflection dungeon chain
  - **The War for Silverpine** (Cataclysm) — Forsaken march into Silverpine; Sylvanas raises the dead against Garrosh's orders
  - **Cities in Dust** (Cataclysm) — Ruins of Gilneas campaign and Godfrey's resurrection
  - **The Broken Shore** (Legion) — Vol'jin names Sylvanas Warchief in his final moments
- Extended **Testing Loyalties** chapter (Lilian Voss) — added six quests following "Under False Colors" through the Warfang Hold summit
- Rewrote all chapter requirement messages to be actionable — version numbers replaced with plain instructions on where to go and what to do

### New
- Story completion screen: when the final chapter of a storyline is finished, a center-screen message fades in with the story title and "Story Finished", with gold gradient lines above and below
- Quest and chapter completion banners fire on `QUEST_TURNED_IN` in real time
- Test commands: `/sm banner`, `/sm chapter`, `/sm complete`

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
