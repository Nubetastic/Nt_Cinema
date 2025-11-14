TicketAddon = {}

TicketAddon.LocationProjection = {
  ["Blackwater"] = "BLACKWATER",
  ["Valentine"] = "VALENTINE",
  ["Saint Denis"] = "SAINTDENIS",
  ["Saint Denis Theater"] = "SAINTDENIS",
  ["Saint Denis Stage"] = "SAINTDENIS",
  ["Saint Denis Cinema"] = "SAINTDENIS"
}
function TicketAddon.ProjectForLocation(loc)
  local name = loc
  if TicketConfig and TicketConfig.TicketVendors and TicketConfig.TicketVendors[loc] and TicketConfig.TicketVendors[loc].LocationName then
    name = TicketConfig.TicketVendors[loc].LocationName
  end
  return TicketAddon.LocationProjection[name] or "VALENTINE"
end
