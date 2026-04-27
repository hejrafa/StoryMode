# Story Mode

Story Mode is a World of Warcraft addon for following memorable quest stories from start to finish. It lays out each adventure chapter by chapter, explains where you are in the narrative, tracks what your character has already done, and gives you a practical next step when the quest chain gets messy.

Version 1.5.0 expands the addon into a richer story companion: **The Master of Revendreth** is now included, **The Klaxxi** is back in the Epic Storylines list, Adventure pages have large Blizzard cover art, and the Journal tab now brings completed chapter recaps together with faction reputation progress.

Pairs well with [Dialogue UI](https://www.curseforge.com/wow/addons/dialogue-ui) for a more cinematic questing experience.

---

## What It Does

- **Browse curated adventures** across expansions, grouped into Epic Storylines, Character Stories, Short Stories, and Identity.
- **Follow chapter-by-chapter guidance** with story summaries, recaps, key characters, quest lists, and the next available step.
- **Track real progress** with logic for completed quests, active quests, optional steps, hidden steps, replayable chapters, faction variants, class restrictions, and race restrictions.
- **Use one-click waypoints** through TomTom to head straight to the next quest objective.
- **Read the Journal** to revisit completed chapter recaps and see related faction reputation progress.
- **Check achievements** with story-relevant achievement lists and faction-aware achievement variants.
- **See completion banners** when quests, chapters, and full adventures finish.
- **Get actionable hints** on gated chapters, including prerequisites such as class, faction, heritage, or loyalist requirements.

---

## Version 1.5.0

### New and Updated Content

- **The Master of Revendreth** - a full seven-chapter Shadowlands storyline covering Darkhaven, the Court of Harvesters, the Accuser, the Penitent Hunt, Theotar, Prince Renathal, Sire Denathrius, and the anima being sent to the Maw.
- **The Klaxxi** - restored to Epic Storylines and positioned after The Jade Forest for a stronger Mists of Pandaria story path.
- **The Jade Forest** - updated with the dungeon finale quest **Deep Doubts, Deep Wisdom** and corrected Temple of the Jade Serpent chapter data.
- **Faction reputation data** - added across the current story set so Journal pages can show related factions beside chapter recaps.
- **Story-relevant achievements** - cleaned up to focus on meaningful story completions, normal dungeon and raid clears, and normal boss kills where appropriate.

### UI and Journal Changes

- The first detail tab is now **Adventure**, with completed chapter recaps moved into a dedicated **Journal** tab.
- Adventure pages now use large Blizzard loading screen or Encounter Journal cover art with title overlays.
- The left adventure list now highlights the selected story with its cover image.
- Completed adventure badges use a cleaner ribbon treatment.
- Journal pages include faction cards with circular reputation progress, standing text, hover states, and tooltips.
- Chapter hints now appear only where they are useful and explain what to do next instead of pointing at old version requirements.

---

## Campaigns

### Epic Storylines

| Adventure | Expansion | Notes |
|---|---|---|
| The Frozen Throne | Wrath of the Lich King | Northrend war campaign, Wrathgate fallout, Icecrown, and Frozen Halls |
| The Jade Forest | Mists of Pandaria | Alliance and Horde openings, shared zone chapters, and Temple of the Jade Serpent finale |
| The Klaxxi | Mists of Pandaria | Dread Wastes, the paragons, amber, and the Heart of Fear |
| Insurrection | Legion | Suramar and the Nightfallen rebellion |
| The Dark Heart of Nazmir | Battle for Azeroth | Horde-only Nazmir campaign |
| The Master of Revendreth | Shadowlands | Revendreth zone campaign and Denathrius's betrayal |
| The Witchwood of Drustvar | Battle for Azeroth | Alliance-only Drustvar campaign |

### Character Stories

| Character | Adventure | Expansion |
|---|---|---|
| Sylvanas Windrunner | The Banshee Queen | Wrath of the Lich King to Dragonflight |
| Jaina Proudmoore | Daughter of the Sea | Battle for Azeroth |
| Lilian Voss | The Forsaken Daughter | Cataclysm to Battle for Azeroth |

### Short Stories

| Adventure | Expansion | Notes |
|---|---|---|
| A Tea Party | Battle for Azeroth | A compact Drustvar side story |

### Identity

Story Mode includes all 12 Legion class order hall campaigns. Your character only sees the campaign for their class.

| Class | Campaign |
|---|---|
| Death Knight | Deathlord's Campaign |
| Demon Hunter | Slayer's Campaign |
| Druid | Archdruid's Campaign |
| Hunter | Huntmaster's Campaign |
| Mage | Archmage's Campaign |
| Monk | Grandmaster's Campaign |
| Paladin | Highlord's Campaign |
| Priest | High Priest's Campaign |
| Rogue | Shadowblade's Campaign |
| Shaman | Farseer's Campaign |
| Warlock | Netherlord's Campaign |
| Warrior | Battlelord's Campaign |

Story Mode also includes 14 heritage armor questlines. These appear only for matching races and factions:

Heritage of the Sin'dorei, Heritage o' the Dark Iron, Heritage of the Draenei, Heritage of the Bronzebeard, Heritage of the Forsaken, Heritage of Gnomeregan, Heritage of Kezan, Lion's Heritage, Heritage of the Kaldorei, Heritage of Draenor, Pandaren Heritage, Heritage of the Shu'halo, Heritage of the Darkspear, and Heritage of Gilneas.

---

## Usage

Open Story Mode:

```text
/sm
```

Track your next quest directly from chat:

```text
/sm track
```

You can also open the **World Map** and click the **Story Mode** tab on the side panel.

Story Mode works best with [TomTom](https://www.curseforge.com/wow/addons/tomtom) installed for waypoint arrows. Without TomTom, the addon still shows the relevant quest and location context.

---

## Installation

1. Download or clone this repository.
2. Place the `StoryMode` folder in:

```text
World of Warcraft/_retail_/Interface/AddOns/
```

3. Restart WoW or run `/reload`.
4. Open Story Mode with `/sm`.

---

## Author

Rafael Polutta - [GitHub](https://github.com/hejrafa)
