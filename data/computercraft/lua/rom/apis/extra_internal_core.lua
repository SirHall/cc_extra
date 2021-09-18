

function Exec()
    -- Initialize
    local modem = peripheral.find("modem")
    if modem == nil then
        print("Please attach an ender modem to the extra_internal_core computer")
        return
    end
    
    local modemName = peripheral.getName(modem)


    rednet.open(modemName)
    rednet.host(extra.ServiceName(), extra.ServiceHost())

    while true do
        local clientID, msg, protocol = rednet.receive(extra.ServiceName())
        local response = nil
        
        local ok, err = pcall(function () response = RouteEvent(clientID, msg) end)

        if not ok then
            printError(err)
            rednet.send(clientID, nil, extra.ServiceResponseName())
        elseif response ~= nil then
            rednet.send(clientID, response, extra.ServiceResponseName())
        end
    end
end

function RouteEvent(clientID, msg)
    local route = msg.route -- The function being called by the client
    local req = msg.req -- The data the client sent in the request

    if route == "Say" then return extra_internal_requests.Say(req, clientID)
    elseif route == "Msg" then return extra_internal_requests.Msg(req, clientID)
    elseif route == "GetPlayers" then return extra_internal_requests.GetPlayers(req, clientID)
    elseif route == "Particle" then return extra_internal_requests.Particle(req, clientID)
    end
end

-- Allow this to also detect turtles
function ComputerAtPos(compID, x, y, z)
    local blockData = commands.getBlockInfo(x, y, z)
    return blockData.nbt ~= nil and blockData.nbt.ComputerId == compID and blockData.nbt.On == 1 
end