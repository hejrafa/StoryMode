# Story Mode

**Story Mode** turns World of Warcraft's best quest chains into guided adventures you can actually follow.

Azeroth has memorable stories hidden in old quest hubs, faction branches, dungeon finales, attunements, class quests, and chains that are easy to outlevel or abandon halfway through. Story Mode gives those adventures a proper journal: cover art, chapters, progress, recaps, and a clear next step when you are ready to continue.

The current content focus is **Classic Era and Burning Crusade Classic**. Retail still works and still includes the existing Retail campaigns, class order hall stories, and heritage questlines, but the addon is being curated first around the old-world stories that benefit most from a cleaner journal.

## Why This Exists

Classic questing can feel wonderful when you follow the text, but the game rarely presents those stories as complete arcs. A mystery might start in one zone, move through a dungeon, ask for a letter drop, and end in a city several levels later. Story Mode keeps that shape visible without turning the game into an autopilot route.

It is not a leveling guide and it is not trying to list every quest. It is a curated story companion for chains that are memorable, atmospheric, important to Warcraft's larger continuity, or simply worth reading again.

## What It Adds In Game

- A Story Mode journal opened from `/sm`, the minimap button, the addon compartment, or the World Map side panel.
- Curated story cards grouped into Stories, Epic Stories, Short Stories, Character Stories, and Identity.
- Cover art, suggested levels, character restrictions, completion state, and active-story pinning.
- Chapter pages with setup text, summaries, recaps, key characters, quest cards, and progress.
- A **Begin This Story** / **Continue Story** flow that finds the next relevant quest.
- Native quest tracking, quest-log opening, map guidance, and pickup hints depending on what the client supports.
- Clickable story and quest chat links for sharing with other Story Mode users.
- Completion banners for quests, chapters, and full stories.
- Localized addon UI and story text for English, German, Spanish, French, Brazilian Portuguese, and Russian.

## Classic Era And TBC Stories

Story Mode currently includes these Classic/TBC-safe adventures.

**Stories**

- The Defias Brotherhood
- Arugal and Shadowfang Keep
- A New Plague
- The Tower of Althalaxx
- The Long Watch
- Raene's Cleansing
- Battle of Hillsbrad
- Saving Yenniku
- The Missing Diplomat
- The Princess of Ironforge

**Epic Stories**

- The Scarlet Crusade
- The Battle of Darrowshire
- A Tale of Sorrow
- The Drakefire Amulet
- The Brazier of Invocation
- The Scepter of the Shifting Sands

**Short Stories**

- Hogger
- Lost in Battle
- The Agamand Family
- A King's Tribute
- Cortello's Riddle
- Linken's Adventure
- The Missing Courier

**Identity**

- Classic class quest chains for druids, hunters, mages, paladins, priests, rogues, shamans, warlocks, and warriors

## Great First Adventures

If you want to see the addon at its best, try one of these:

- **Alliance Classic:** The Defias Brotherhood, The Long Watch, The Missing Diplomat, The Princess of Ironforge, A King's Tribute
- **Horde Classic:** The Scarlet Crusade, A New Plague, Battle of Hillsbrad, Saving Yenniku, Lost in Battle
- **Cross-faction Classic:** The Drakefire Amulet, A Tale of Sorrow, The Battle of Darrowshire, The Brazier of Invocation, The Scepter of the Shifting Sands
- **Short Classic tales:** Hogger, Cortello's Riddle, Linken's Adventure, The Agamand Family, The Missing Courier
- **Class identity:** your Classic class quest chains, shown only when they apply to your character

## Retail Support

Retail support remains available through the same addon. Retail characters can still see the curated Retail story set when eligible, including:

- The Frozen Throne
- What Is Worth Fighting For
- Insurrection
- The Dark Heart of Nazmir
- The Master of Revendreth
- The Witchwood of Drustvar
- The Banshee Queen
- Daughter of the Sea
- The Forsaken Daughter
- A Tea Party
- Legion class order hall campaigns
- Heritage armor questlines

Retail-only content is hidden automatically on Classic Era and TBC clients.

## Slash Commands

Open Story Mode:

```text
/sm
/storymode
```

Track the next quest in your selected story:

```text
/sm track
```

Open the loading-screen cover browser:

```text
/sm loadingscreens
```

## Supported Clients

Story Mode uses one shared codebase with client-specific TOCs:

- `StoryMode.toc` for Retail.
- `StoryMode_Vanilla.toc` for Classic Era.
- `StoryMode_TBC.toc` for Burning Crusade Classic and compatible Anniversary-era installs.

Client, faction, race, class, level, and quest availability are checked before stories appear, so the journal should stay relevant to the character you are playing.

## Installation

The easiest install path is the published addon page:

- [Story Mode on CurseForge](https://www.curseforge.com/wow/addons/storymode)

For a manual install, place this repository's `StoryMode` folder inside the matching WoW addon folder:

```text
World of Warcraft/_retail_/Interface/AddOns/
World of Warcraft/_classic_era_/Interface/AddOns/
World of Warcraft/_anniversary_/Interface/AddOns/
```

Restart WoW or run `/reload`, then open Story Mode with `/sm`.

## Repository Guide

- `StoryMode.toc`, `StoryMode_Vanilla.toc`, and `StoryMode_TBC.toc` hold client metadata and load order.
- `Code/` contains runtime Lua and XML.
- `Code/Core/Compatibility.lua` keeps client API differences contained.
- `Code/Core/Registry.lua` owns story registration, category assignment, and character/client filtering.
- `Code/Core/Tracking.lua` owns quest tracking, map guidance, and ping behavior.
- `Code/UI/` contains focused UI modules such as the story list, tooltip, minimap button, banners, and loading-screen browser.
- `Data/` contains questline datasets grouped by story type.
- `Locales/` contains English source strings and supported locale overrides.
- `Art/` contains addon-owned icons, hero art, masks, and UI assets.
- `_Dev/tools/` contains local audit and release-maintenance scripts that are not loaded by WoW.
- `DESCRIPTION.md` is the CurseForge-style addon listing copy.
- `CHANGELOG.md` records release notes and maintenance history.

## Adding Content

New stories should be added as data files under `Data/`, assigned a category in `Code/Core/Registry.lua`, and loaded from each relevant TOC.

If a story should only appear on certain game clients, add a `gameVersions` table to the dataset:

```lua
gameVersions = { classicEra = true, tbc = true }
```

When adding or editing story text, update `Locales/enUS.lua` first so the other locale files can override the same keys cleanly.

Useful local checks:

```bash
node _Dev/tools/check-core-behavior.mjs .
node _Dev/tools/localization-audit.mjs .
node _Dev/tools/localization-prose-quality-pass.mjs .
node _Dev/tools/recap-coverage.mjs . --strict
node _Dev/tools/validate-story-data.mjs .
```

## Release Publishing

GitHub Actions packages Story Mode when a version tag is pushed. The workflow validates TOC and changelog metadata, builds the addon zip with the BigWigs WoW Packager, creates a GitHub release, and uploads the same package to CurseForge and Wago.

Repository secrets required in GitHub:

- `CF_API_KEY`: CurseForge API token.
- `CF_PROJECT_ID`: CurseForge project ID from the project's About section.
- `WAGO_API_TOKEN`: Wago Addons API token.
- `WAGO_PROJECT_ID`: Wago project ID from the Wago developer dashboard.

Release flow:

```bash
node _Dev/tools/prepare-release.mjs <version>
git add StoryMode.toc StoryMode_Vanilla.toc StoryMode_TBC.toc CHANGELOG.md
git commit -m "Release <version>"
git tag v<version>
git push origin main v<version>
```

The package rules live in `.pkgmeta`. Development tools, workflow files, and local audit caches are excluded from release zips.

## Author

Rafael Polutta - [GitHub](https://github.com/hejrafa)
