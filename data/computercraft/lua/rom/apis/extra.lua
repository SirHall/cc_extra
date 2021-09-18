function ServiceName() return "extra_com_request" end
function ServiceResponseName() return "extra_com_response" end
function ServiceHost() return "com" end
function ExtraInternalIDName() return "extra_main_com_id" end

function Init() ComID(true) end

function EnsureOpen()
    if not rednet.isOpen() then
        local modem = peripheral.find("modem")
        if modem == nil then
            error("say Please attach a modem to this computer")
        end
        
        local modemName = peripheral.getName(modem)

        rednet.open(modemName)
    end
end


function ComID(allowSleep)
    allowSleep = allowSleep or false
    EnsureOpen()
    if _G[ExtraInternalIDName()] == nil then
        local attempts = 0
        repeat
            if attempts > 0 then os.sleep(0.1) end
            _G[ExtraInternalIDName()] = rednet.lookup(ServiceName(), ServiceHost())
            attempts = attempts + 1
        until _G[ExtraInternalIDName()] ~= nil or attempts > 500
        if attempts > 500 then
            error("Could not find extra com computer, set one up")
        end
    end

    return _G[ExtraInternalIDName()]
end

function CallRPC(route, req, expectResponse)
    rednet.send(ComID(), {route = route, req = req}, ServiceName())
    if expectResponse then
        -- Probably filter to ensure only the command computer actually responds to prevent malicious attacks
        local id, message = rednet.receive(ServiceResponseName(), 10)
        if not id then error("No reply to " .. route .. " received when expected") end
        return message
    end
end


function Say(msg) CallRPC("Say", {msg = msg}, false) end
function Msg(target, msg) CallRPC("Msg", {msg = msg, target = target}, false) end
function GetPlayers(radius) 
    local x, y, z = gps.locate()
    return CallRPC("GetPlayers", { radius = radius, x = x, y = y, z = z }, true)
end
function Particle(name, x, y, z, dx, dy, dz, speed, count)
    dx = dx or 1
    dy = dy or 1
    dz = dz or 1
    speed = speed or 1
    count = count or 1
    CallRPC(
        "Particle",
        {name = name, x = x, y = y, z = z, dx = dx, dy = dy, dz = dz, speed = speed, count = count},
        false
    )
end