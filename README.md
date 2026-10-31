# ASTinyPlates

An **Azeroth Survivors** addon that declutters the screen by shrinking nameplates of regular mobs, while keeping the ones that matter — bosses and guardians — easy to read.

## Features

- **Tiny regular plates** – ordinary mob nameplates are shrunk to half size.
- **Full-size boss and guardian plates** – these keep their normal size and show:
  - a name label
  - a status bar
  - debuff icons with timers
- **Works with UI replacements** – tested with the default UI and with SDUI.

## Screenshots

**Default (vanilla) UI** – regular mobs get small bars, while the Qiraji Champion keeps a full-size plate with name, status bar and debuff icon.

![ASTinyPlates with the default UI](.media/vanilla.png)

**With SurvivorsDragonUI** – the same behaviour with the SDUI UI replacement; the Anubisath Sentinel plate shows its name, status bar and a debuff icon.

![ASTinyPlates with SDUI](.media/sdui.png)

## Installation

1. Download the latest version from the [Releases](../../releases) page.
2. Copy the `ASTinyPlates` folder into `Interface/AddOns`.
3. Restart the game (or reload the UI) and make sure the addon is enabled.

## Known Quirks

- If an Elite and Guardian of the same mob is present at the same time, the Elite will show the debuffs of the Guardian.
- Elites do not show their debuffs, due to missing GUID.
- Plates of Guardians may appear as shrunken for a quick second when first viewed.

## Commands

| Command | Description |
| --- | --- |
| `/astpdebug` | Prints debug information about the visible boss/guardian nameplates to the chat frame. |

## Releases

Releases are published automatically on GitHub Releases whenever a pull request is merged into `main` (see [`.github/workflows/release.yml`](.github/workflows/release.yml)).

## How it works, quick TLDR

ASTinyPlates will draw placeholders on-top of regular nameplates and hide the real ones, as scaling the original plates proved to cause issues.
All plates are by default shrunken, where they're then checked against the zone's Guardians and Bosses, in order to tell if the nameplate belongs to one of those.

## AI Usage

ASTinyPlates is created using GitHub Copilot (Claude Sonnet 5.5), since I'm not very knowledgeable in Lua nor the 1.12 WoW API
