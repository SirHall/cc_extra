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
        if playerName ~= nil then
            local _, playerDat = commands.exec("data get entity " .. playerName .. " Pos")
            local px, py, pz = string.match(playerDat[1], matchCoords)
            table.insert(players, {name = playerName, dx = px - req.x, dy = py - req.y, dz = pz - req.z})
        end
    end
    return players
end

function Particle(req, clientID)
    local success, result = commands.particle(req.name, req.x, req.y, req.z, req.dx, req.dy, req.dz, req.speed, req.count)
    if not success then
        printError(result)
    end
end

-- Ideas:
-- Ability to launch potions from a connected inventory
-- Ability to launch arrows from a connected inventory
-- Ability to launch ender pearl for player within a certain radius? (very abusable)
-- Get blocks in vicinity of computer
-- Place block
-- Read NBT data in as a table from some blocks around the computer?
-- Read NBT tag data from surrounding entities?
-- Get surrounding entities
-- Expanded chat-related stuff
-- Minecart ticketing system by attaching an nbt tag to minecart entities?
-- Time of day (unless this is already built in)
-- A* pathfinder for turtles
-- Computer self destruction
-- Launch TNT using TNT in inventory?
-- Summon lightning? :D
-- Flip levers, press buttons
-- Interact with player/entity inventories
-- Some mob spawning mechanism?
-- Get entity attributes

-- Misc
-- Energy system based on time spent waiting (Compute units)?
-- These energy points can be moved between computers
-- These points are used to do most of the special stuff in this datapack
-- extra.gather(timeToGather)
-- 'timeToGather' determines for how long the computer will sleep
-- The higher 'timeToGather' is set, the more compute units are earned per second (with diminishing returns)
-- However - you only earn these computer units at the end of the timer, meaning you should choose a reasonable value
-- This should be rather low - requiring lot's of computers? (Lag?)