function Say(req, clientID)
    commands.exec("say " .. req.msg)
end

function Msg(req, clientID)
    commands.exec("msg " .. req.target .. " " .. req.msg)
end

function GetPlayers(req, clientID)
    
    local radius = req.radius
    local x = req.x
    local y = req.y
    local z = req.z
    if radius > 64 then radius = 64 end
    if radius < 1 then radius = 1 end

    if not extra_internal_core.ComputerAtPos(clientID, x, y, z) then
        return {}
    end
    
    if x then x = "x="..x else x = "" end
    if y then y = ",y="..y else y = "" end
    if z then z = ",z="..z else z = "" end
    local command = "xp add @a["..x..y..z..(",distance=.."..radius).."] 0"
    local state, result = commands.exec(command)
    local players = {}

    local dig = "(%-?[%d%.]+)d"
    local matchCoords = "[%w :]+%[" .. dig .. ", " .. dig .. ", " .. dig .. "%]"
    
    for i, v in ipairs(result) do
        local playerName = string.match(v, "Gave 0 experience points to (%w+)")
        local _, playerDat = commands.exec("data get entity " .. playerName .. " Pos")
        local px, py, pz = string.match(playerDat[1], matchCoords)
        table.insert(players, {name = playerName, dx = px - req.x, dy = py - req.y, dz = pz - req.z})
    end
    return players
end

function Particle(req, clientID)
    local success, result = commands.particle(req.name, req.x, req.y, req.z, req.dx, req.dy, req.dz, req.speed, req.count)
    if not success then
        printError(result)
    end
end