# Nt_Cinema — Multiplayer Cinema & Stage Shows for RedM

A lightweight RedM resource that spawns ticket vendors, sells show tickets, and lets players watch synchronized theater or magic lantern movies together. Shows rotate hourly and can be started by any ticket holder.

## Dependencies
- rsg-core (prompts, player/money APIs)
- rsg-menubase (menus)
- ox_lib (notifications)
- RedM (rdr3)

## How players buy tickets and watch together
1. Go to a ticket vendor blip/NPC (e.g., Blackwater, Valentine, Saint Denis) defined in `TicketConfig.TicketVendors` (shared/ticketConfig.lua:55).
2. Press the prompt key (default `J`) to open the Show Menu (client/vendor.lua:32).
3. Select a show to buy a ticket. Price is based on venue type (client/vendor.lua:64, server/core.lua:67–71, 184–196).
4. When the first ticket is bought, that show becomes pinned for the location (server/core.lua:190–193).
5. Every player who wants to watch the show needs to buy a ticket.
6. Any ticket holder can choose "Start Show" in the menu to begin for all ticket holders (client/vendor.lua:77–91, server/core.lua:198–213).
7. A 15s heads‑up is sent, then the show runs and ends automatically; sales reopen after (server/core.lua:120–149).
8. Ticket sales become locked until the show ends.

## Installation
1. Place this resource in your `resources` folder as `Nt_Cinema`.
2. Ensure required deps start before it in `server.cfg`:
   - `ensure Nt_Cinema`

## Configuration
- Prices, show lists, vendor NPCs/locations: `shared/ticketConfig.lua`
  - Show prices: `TicketConfig.ShowPrice` (Cinema/Tent/Stage) (shared/ticketConfig.lua:3)
  - Vendor list and ShowCount/ShowTypes/blips: `TicketConfig.TicketVendors` (shared/ticketConfig.lua:55)
- Default show duration (ms): `TicketAddon.DefaultDuration` (shared/ticketAddon.lua:2)
- Projections per town: `TicketAddon.LocationProjection` (shared/ticketAddon.lua:3)
- Built‑in shows/movies: `shared/config.lua`
- Hourly rotation is scheduled automatically (server/core.lua:53–65, 215–219).

