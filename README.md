# Story Mode

**Story Mode** is a World of Warcraft addon for players who want to experience Azeroth's quest stories in a clearer, more intentional order.

It turns scattered quest chains into guided adventures with chapter progress, story context, next-step tracking, cover art, achievements, faction reputation notes, and one-click map guidance.

It pairs especially well with [Dialogue UI](https://www.curseforge.com/wow/addons/dialogue-ui), because the whole point is to make old quest text feel worth reading again.

## Why This Exists

WoW has wonderful stories, but they are often buried inside old quest hubs, faction variants, dungeon finales, achievement criteria, and patch-era prerequisites. Story Mode gives those stories a clean table of contents, a readable journal, and a practical "what do I do next?" button while still letting the game be the game.

The addon is curated rather than exhaustive. It is not trying to replace a leveling guide. It is for stories that are memorable, atmospheric, important to Warcraft's larger continuity, or just unusually good.

## What Story Mode Does

- Curates major zone stories, character arcs, class campaigns, heritage armor quests, and selected short stories.
- Breaks each adventure into readable chapters with summaries, recaps, key characters, and quest flow.
- Finds your real next quest by skipping completed, hidden, optional, or faction-ineligible steps.
- Tracks chapter, story, achievement, and reputation progress in one place.
- Filters class, race, faction, and client-specific content so your character sees stories they can actually play.
- Sends you toward the next objective with WoW's built-in quest tracking, user waypoints, and world map pins where available.
- Shows completion banners when quests, chapters, and full stories finish.

## Supported Clients

Story Mode currently supports Retail, Classic Era, and Burning Crusade Classic from one shared codebase.

- Retail loads through `StoryMode.toc`.
- Classic Era loads through `StoryMode_Vanilla.toc`.
- Burning Crusade Classic loads through `StoryMode_TBC.toc`.

Classic Era and TBC use the same addon shell as Retail, but later-expansion adventures are hidden automatically. Classic/TBC-specific datasets can opt in with `gameVersions`, as **The Defias Brotherhood** does.

## Included Adventures

**Epic Storylines**

- **The Defias Brotherhood**: Classic Alliance Westfall investigation, Deadmines finale, Unsent Letter, Stockade riot, and Stormwind aftermath.
- **The Frozen Throne**: Northrend war campaign, Wrathgate fallout, Icecrown, and Frozen Halls.
- **What Is Worth Fighting For**: The Jade Forest campaign with Alliance and Horde openings, shared zone chapters, and Temple of the Jade Serpent finale.
- **Insurrection**: Suramar and the Nightfallen rebellion.
- **The Dark Heart of Nazmir**: Horde-only Nazmir campaign.
- **The Master of Revendreth**: Revendreth zone campaign and Denathrius's betrayal.
- **The Witchwood of Drustvar**: Alliance-only Drustvar campaign.

**Character Stories**

- **The Banshee Queen**: Sylvanas Windrunner's arc from Wrath of the Lich King through later expansions.
- **Daughter of the Sea**: Jaina Proudmoore's Battle for Azeroth story.
- **The Forsaken Daughter**: Lilian Voss across Tirisfal, the Scarlet Crusade, and the Horde war campaign.

**Short Stories**

- **A Tea Party**: a compact Drustvar side story that starts sweet and ends badly.

**Identity**

Story Mode includes all 12 Legion class order hall campaigns. Your character only sees the campaign for their class.

It also includes 14 heritage armor questlines. These appear only for matching races and factions: Blood Elf, Dark Iron Dwarf, Draenei, Dwarf, Forsaken, Gnome, Goblin, Human, Night Elf, Orc, Pandaren, Tauren, Troll, and Worgen.

## Usage

Open Story Mode with:

```text
/sm
```

Track your next quest directly from chat with:

```text
/sm track
```

You can also open the **World Map** and click the **Story Mode** tab on the side panel.

When a quest is already in your log, Story Mode uses WoW's native quest tracking where possible. When it is not, it opens the relevant map and sets a native waypoint if the client supports it. On older clients, it falls back to the best available map and tracking APIs.

## Installation

Download or clone this repository, then place the `StoryMode` folder inside the matching client addon folder:

```text
World of Warcraft/_retail_/Interface/AddOns/
World of Warcraft/_classic_era_/Interface/AddOns/
World of Warcraft/_anniversary_/Interface/AddOns/
```

Restart WoW or run `/reload`, then open Story Mode with `/sm`.

## Repository Guide

The repository is structured so game-version support, localization, and future content additions can grow without turning the root folder into a junk drawer.

- `StoryMode.toc`, `StoryMode_Vanilla.toc`, and `StoryMode_TBC.toc` hold client-specific metadata and shared load order.
- `Code/` contains runtime Lua and XML. `Code/Core/Compatibility.lua` is where client API fallbacks live.
- `Data/` contains questline datasets grouped by story type.
- `Locales/` loads English UI and content strings through `Localization.xml` and `enUS.lua`, ready for future locale files.
- `Art/` contains addon-owned icons, hero art, masks, and future visual assets.
- `_Dev/tools/` contains local audit and maintenance scripts that are not loaded by WoW.
- `DESCRIPTION.md` is the shorter addon listing text.
- `CHANGELOG.md` records release notes and maintenance history.

## Content Notes

New stories should be added as data files under `Data/`, then registered in `Code/StoryMode.lua` and loaded from each TOC. If a story should only appear on certain game clients, add a `gameVersions` table to the dataset.

Current localization uses English source strings as keys. When adding or editing dataset text, update `Locales/enUS.lua` so future locale files can override the same content cleanly.

## Author

Rafael Polutta - [GitHub](https://github.com/hejrafa)
