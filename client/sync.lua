RegisterNetEvent('nt_cinema_tickets:startShow')
AddEventHandler('nt_cinema_tickets:startShow', function(loc, showId, startAt, endAt)
  if Globals and Globals.Shows and Globals.Shows[showId] then
    StartShow(showId)
  else
    local town = TicketAddon.ProjectForLocation(loc)
    StartShow('MOVIE', town, showId)
  end
end)

RegisterNetEvent('nt_cinema_tickets:showEnded')
AddEventHandler('nt_cinema_tickets:showEnded', function(loc) end)
