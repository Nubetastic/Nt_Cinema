local RSGCore = exports['rsg-core']:GetCoreObject()
local Vendors = {}
local SpawnedPeds = {}

local function startNpcAction(ped, loc)
  if not TicketConfig or not TicketConfig.NPCActions or #TicketConfig.NPCActions == 0 then return end
  local act = TicketConfig.NPCActions[math.random(1, #TicketConfig.NPCActions)]
  if type(act) == 'string' then
    -- try scenario in place first
    if TaskStartScenarioInPlace then
      TaskStartScenarioInPlace(ped, act, -1, true, false, false, false)
    else
      local hash = GetHashKey(act)
      Citizen.InvokeNative(0x4D1F61FC34AF3CD1, ped, hash, -1, true, false, 0, false)
    end
  end
end

local function despawnLocalVendor(loc)
  local ped = SpawnedPeds[loc]
  if ped and DoesEntityExist(ped) then
    ClearPedTasksImmediately(ped, true, true)
    DeleteEntity(ped)
  end
  SpawnedPeds[loc] = nil
end

local function spawnLocalVendor(loc, data)
  if SpawnedPeds[loc] and DoesEntityExist(SpawnedPeds[loc]) then return end
  if not data.NPC_Cords or not data.NPC_Model then return end
  local model = type(data.NPC_Model) == 'string' and GetHashKey(data.NPC_Model) or data.NPC_Model
  RequestModel(model)
  while not HasModelLoaded(model) do Wait(10) end
  local ped = CreatePed(model, data.NPC_Cords.x, data.NPC_Cords.y, data.NPC_Cords.z - 1.0, data.NPC_Cords.w or 0.0, false, false, false, false)
  Wait(100)
  SetEntityAlpha(ped, 255, false)
  Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
  SetEntityAsMissionEntity(ped, true, true)
  SetEntityCanBeDamaged(ped, false)
  SetEntityInvincible(ped, true)
  FreezeEntityPosition(ped, false)
  SetPedCanBeTargetted(ped, false)
  SetEntityAsMissionEntity(ped, true, true)
  SpawnedPeds[loc] = ped
  startNpcAction(ped, loc)
  --SetModelAsNoLongerNeeded(model)
end

Citizen.CreateThread(function()
  Citizen.Wait(500)
  if not TicketConfig or not TicketConfig.TicketVendors then return end
  for loc,data in pairs(TicketConfig.TicketVendors) do
    Vendors[loc] = { showType = data.ShowTypes }
    local promptId = 'Cinema_'..loc
    exports['rsg-core']:createPrompt(promptId, data.Promp_Cords, RSGCore.Shared.Keybinds['J'], 'Show Menu', { type = 'client', event = 'nt_cinema_tickets:open', args = { loc } })
    if data.showblip and data.NPC_Cords then
      local blip = N_0x554d9d53f696d002(0xB04092F8, data.NPC_Cords.x, data.NPC_Cords.y, data.NPC_Cords.z)
      SetBlipSprite(blip, `blip_ambient_theatre`, 1)
      SetBlipScale(blip, 0.2)
      Citizen.InvokeNative(0x9CB1A1623062F402, blip, data.LocationName or loc)
    end
  end
  while true do
    local ply = PlayerPedId()
    local ppos = GetEntityCoords(ply)
    local sd = (TicketConfig and TicketConfig.SpawnDistance) or 40.0
    local dd = sd + 15.0
    for loc,data in pairs(TicketConfig.TicketVendors) do
      local ped = SpawnedPeds[loc]
      local dist = #(ppos - vector3(data.NPC_Cords.x, data.NPC_Cords.y, data.NPC_Cords.z))
      if dist <= sd then
        if not ped or not DoesEntityExist(ped) then
          spawnLocalVendor(loc, data)
        end
      elseif dist >= dd then
        if ped and DoesEntityExist(ped) then
          despawnLocalVendor(loc)
        end
      end
    end
    Citizen.Wait(250)
  end
end)

RegisterNetEvent('nt_cinema_tickets:open')
AddEventHandler('nt_cinema_tickets:open', function(arg)
  local loc = type(arg) == 'table' and arg[1] or arg
  TriggerServerEvent('nt_cinema_tickets:requestMenuState', loc)
end)

RegisterNetEvent('nt_cinema_tickets:menuState')
AddEventHandler('nt_cinema_tickets:menuState', function(loc, state)
  local data = TicketConfig and TicketConfig.TicketVendors and TicketConfig.TicketVendors[loc]
  if not data then return end
  local showType = data.ShowTypes
  local price = TicketConfig.ShowPrice[showType] or 0
  local MenuData = exports['rsg-menubase']:GetMenuData()
  MenuData.CloseAll()
  if state.status == 'running' then
    local mins = state.nextShowInMinutes
    local desc = 'Show running here'
    if mins ~= nil then desc = ('Show running here. Next show in %d minutes'):format(mins) end
    TriggerEvent('ox_lib:notify', { title = 'Busy', description = desc, type = 'inform', duration = 4000 })
    return
  end
  if state.status == 'sales_open' then
    local elements = {}
    local list = state.shows or {}
    for _,s in ipairs(list) do
      table.insert(elements, { label = s..' - $ '..price, value = { action = 'buy', show = s } })
    end
    MenuData.Open('default', GetCurrentResourceName(), 'cinema_ticket_menu', { title = 'Cinema Shows', subtext = loc, align = 'top-left', elements = elements }, function(d, m)
      if not d.current or not d.current.value then return end
      if d.current.value.action == 'buy' then
        TriggerServerEvent('nt_cinema_tickets:buyTicket', loc, d.current.value.show)
      end
      m.close()
    end, function(d, m)
      m.close()
    end, function(d, m) end)
    return
  end
  if state.status == 'pinned' then
    local elements = {}
    if state.youHaveTicket then
      table.insert(elements, { label = 'Start Show', value = { action = 'start' } })
    else
      table.insert(elements, { label = (state.pinnedShowId or '')..' - $ '..price, value = { action = 'buy_pinned' } })
    end
    MenuData.Open('default', GetCurrentResourceName(), 'cinema_ticket_menu_pinned', { title = state.pinnedShowId or 'Pinned Show', subtext = loc, align = 'top-left', elements = elements }, function(d, m)
      if not d.current or not d.current.value then return end
      local v = d.current.value
      if v.action == 'start' then
        TriggerServerEvent('nt_cinema_tickets:tryStartPinnedShow', loc)
      elseif v.action == 'buy_pinned' then
        TriggerServerEvent('nt_cinema_tickets:buyTicket', loc, state.pinnedShowId)
      end
      m.close()
    end, function(d, m)
      m.close()
    end, function(d, m) end)
    return
  end
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  for loc,ped in pairs(SpawnedPeds) do
    if DoesEntityExist(ped) then DeleteEntity(ped) end
  end
end)
