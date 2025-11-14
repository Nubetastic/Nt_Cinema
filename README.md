# Nt_Cinema — Multiplayer Cinema & Stage Shows for RedM

Multiple Players can purchase and then watch a show together at any cinema in game.
Only those who bought a ticket before the show starts can watch.
Each location has a list of shows that changes every hour.

## Dependencies
- rsg-core
- rsg-menubase
- ox_lib

## How players buy tickets and watch together
1. Go to a ticket vendor.
2. Press the prompt key (default `J`) to open the Show Menu.
3. Select a show to buy a ticket. Price is based on venue type.
4. When the first ticket is bought, that show becomes pinned for the location.
  - Other players can only purchase tickets for the same show.
5. Every player who wants to watch the show needs to buy a ticket.
6. Any ticket holder can choose "Start Show" in the menu to begin for all ticket holders.
7. A one minute heads‑up is sent, then the show runs and ends automatically; sales reopen after the show end.

## Installation
1. Place this resource in your `resources` folder as `Nt_Cinema`.
2. Ensure in `server.cfg`:
   - `ensure Nt_Cinema`

## Configuration
- Prices, show lists, vendor NPCs/locations: `shared/ticketConfig.lua`
  - Show prices: `TicketConfig.ShowPrice` (Cinema/Tent/Stage) (shared/ticketConfig.lua:3)
  - Vendor list and ShowCount/ShowTypes/blips: `TicketConfig.TicketVendors` (shared/ticketConfig.lua:55)
- Default show duration (ms): `TicketAddon.DefaultDuration` (shared/ticketAddon.lua:2)
- Projections per town: `TicketAddon.LocationProjection` (shared/ticketAddon.lua:3)
- Built‑in shows/movies: `shared/config.lua`
- Hourly rotation is scheduled automatically (server/core.lua:53–65, 215–219).

