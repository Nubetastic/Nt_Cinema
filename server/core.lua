local RSGCore = exports['rsg-core']:GetCoreObject()
local locationState = {}
local availableShows = {}
local nextRotateAt = nil

local function getCitizenId(src)
  local p = RSGCore.Functions.GetPlayer(src)
  if p and p.PlayerData and p.PlayerData.citizenid then return p.PlayerData.citizenid end
  if p and p.PlayerData and p.PlayerData.citizenId then return p.PlayerData.citizenId end
  return tostring(src)
end

local function ensureLoc(loc)
  if not locationState[loc] then
    locationState[loc] = { status = 'sales_open', pinnedShowId = nil, ticketHolders = {}, timer = nil, startAt = nil, endAt = nil }
  end
  return locationState[loc]
end

local function isShowAllowed(loc, showId)
  if not TicketConfig or not TicketConfig.TicketVendors or not TicketConfig.ShowList then return false end
  local data = TicketConfig.TicketVendors[loc]
  if not data then return false end
  local list = TicketConfig.ShowList[data.ShowTypes] or {}
  for _,s in ipairs(list) do if s == showId then return true end end
  return false
end

local function pickForLocation(loc)
  local data = TicketConfig.TicketVendors[loc]
  if not data then return {} end
  local t = data.ShowTypes
  local all = TicketConfig.ShowList[t] or {}
  local copy = {}
  for i=1,#all do copy[i]=all[i] end
  local count = math.min(data.ShowCount or 3, #copy)
  local sel = {}
  for i=1,count do
    local idx = math.random(1,#copy)
    sel[#sel+1] = copy[idx]
    table.remove(copy, idx)
  end
  return sel
end

local function rotateAll()
  if not TicketConfig or not TicketConfig.TicketVendors then return end
  for loc,_ in pairs(TicketConfig.TicketVendors) do
    availableShows[loc] = pickForLocation(loc)
  end
end

local function scheduleHourly()
  local now = os.time()
  local t = os.date('*t', now)
  t.min = 0
  t.sec = 0
  local nextHour = os.time(t) + 3600
  nextRotateAt = nextHour
  local delay = (nextHour - now) * 1000
  SetTimeout(delay, function()
    rotateAll()
    scheduleHourly()
  end)
end

local function priceFor(loc)
  local data = TicketConfig.TicketVendors[loc]
  local t = data and data.ShowTypes or 'Cinema'
  return TicketConfig.ShowPrice[t] or 0
end

local function charge(src, amount)
  local p = RSGCore.Functions.GetPlayer(src)
  if not p then return false end
  if p.Functions.GetMoney('cash') < amount then return false end
  p.Functions.RemoveMoney('cash', amount, 'cinema-ticket')
  return true
end

local function sendMenuStateFor(src, loc)
  local st = ensureLoc(loc)
  if not availableShows[loc] then
    rotateAll()
  end
  local cid = getCitizenId(src)
  local you = st.ticketHolders[cid] == true
  local canStart = st.status == 'pinned' and you
  local payload = { status = st.status, pinnedShowId = st.pinnedShowId, youHaveTicket = you, canStart = canStart }
  if st.status == 'sales_open' then
    payload.shows = availableShows[loc] or {}
    payload.nextRotateAt = nextRotateAt
  end
  TriggerClientEvent('nt_cinema_tickets:menuState', src, loc, payload)
end

local function broadcastShowEnded(loc)
  TriggerClientEvent('nt_cinema_tickets:showEnded', -1, loc)
end

local function computePayload(loc, showId)
  if Globals and Globals.Shows and Globals.Shows[showId] then
    return showId
  else
    local town = TicketAddon.ProjectForLocation(loc)
    return { name = showId, town = town }
  end
end

local function startShow(loc, showId)
  local st = ensureLoc(loc)
  st.status = 'running'
  st.pinnedShowId = st.pinnedShowId or showId
  local preHolders = {}
  for _,src in ipairs(RSGCore.Functions.GetPlayers()) do
    local cid = getCitizenId(src)
    if st.ticketHolders[cid] then preHolders[#preHolders+1] = src end
  end
  for _,src in ipairs(preHolders) do
    TriggerClientEvent('ox_lib:notify', src, { title = 'Show Starting Soon', description = 'Take your seats. Starting in 15 seconds', type = 'inform', duration = 5000 })
  end 
  SetTimeout(15000, function()
    st.startAt = GetGameTimer()
    st.endAt = st.startAt + (TicketAddon.DefaultDuration or 300000)
    local payload = computePayload(loc, showId)
    local holders = {}
    for _,src in ipairs(RSGCore.Functions.GetPlayers()) do
      local cid = getCitizenId(src)
      if st.ticketHolders[cid] then holders[#holders+1] = src end
    end
    for _,src in ipairs(holders) do
      TriggerClientEvent('ox_lib:notify', src, { title = 'Show Starting', description = 'Enjoy the show', type = 'success', duration = 5000 })
      TriggerClientEvent('nt_cinema_tickets:startShow', src, loc, showId, st.startAt, st.endAt)
    end
    if st.timer then
      if st.timer.cancel then st.timer:cancel() end
      st.timer = nil
    end
    SetTimeout(TicketAddon.DefaultDuration or 300000, function()
      local s = ensureLoc(loc)
      s.status = 'sales_open'
      s.pinnedShowId = nil
      s.ticketHolders = {}
      s.timer = nil
      s.startAt = nil
      s.endAt = nil
      broadcastShowEnded(loc)
    end)
  end)
end

RegisterNetEvent('nt_cinema_tickets:requestMenuState')
AddEventHandler('nt_cinema_tickets:requestMenuState', function(loc)
  local src = source
  if not loc then return end
  sendMenuStateFor(src, loc)
end)

RegisterNetEvent('nt_cinema_tickets:buyTicket')
AddEventHandler('nt_cinema_tickets:buyTicket', function(loc, showId)
  local src = source
  if not loc or not showId then return end
  local st = ensureLoc(loc)
  if st.status == 'running' then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Busy', description = 'Show already running', type = 'error', duration = 5000 })
    return
  end
  if not isShowAllowed(loc, showId) then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Unavailable', description = 'Show unavailable', type = 'error', duration = 5000 })
    return
  end
  if st.status == 'sales_open' then
    if not availableShows[loc] or #availableShows[loc] == 0 then rotateAll() end
    local ok = false
    for _,s in ipairs(availableShows[loc] or {}) do if s == showId then ok = true break end end
    if not ok then
      TriggerClientEvent('ox_lib:notify', src, { title = 'Rotation', description = 'Not in current selection', type = 'error', duration = 4000 })
      return
    end
  elseif st.status == 'pinned' and st.pinnedShowId ~= showId then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Pinned', description = 'Different show pinned here', type = 'error', duration = 5000 })
    return
  end
  local price = priceFor(loc)
  if not charge(src, price) then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Payment Failed', description = 'Insufficient funds', type = 'error', duration = 5000 })
    return
  end
  local cid = getCitizenId(src)
  if st.status == 'sales_open' then
    st.status = 'pinned'
    st.pinnedShowId = showId
  end
  st.ticketHolders[cid] = true
  TriggerClientEvent('ox_lib:notify', src, { title = 'Ticket Purchased', description = 'Select Start Show to begin for all ticket holders', type = 'success', duration = 5000 })
end)

RegisterNetEvent('nt_cinema_tickets:tryStartPinnedShow')
AddEventHandler('nt_cinema_tickets:tryStartPinnedShow', function(loc)
  local src = source
  if not loc then return end
  local st = ensureLoc(loc)
  local cid = getCitizenId(src)
  if st.status ~= 'pinned' then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Unavailable', description = 'No pinned show to start', type = 'error', duration = 4000 })
    return
  end
  if not st.ticketHolders[cid] then
    TriggerClientEvent('ox_lib:notify', src, { title = 'Ticket Required', description = 'You must have a ticket', type = 'error', duration = 4000 })
    return
  end
  startShow(loc, st.pinnedShowId)
end)

CreateThread(function()
  Citizen.Wait(1000)
  rotateAll()
  scheduleHourly()
end)
