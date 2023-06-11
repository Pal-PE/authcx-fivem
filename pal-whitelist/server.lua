-- Function to check if the player is whitelisted
function CheckWhitelist(deferrals, identifiers, name)
    -- Handle identifiers
    local identifiersString = ""
    for i = 1, #identifiers do
        -- Steam
        if string.find(identifiers[i], "steam:") then
            identifiersString = identifiersString .. "&steam=" .. tonumber(string.sub(identifiers[i], string.len("steam:") + 1, string.len(identifiers[i])), 16)
        end
        -- FiveM
        if string.find(identifiers[i], "license:")  then
            identifiersString = identifiersString .. "&fivem=" .. string.sub(identifiers[i], string.len("license:") + 1, string.len(identifiers[i]))
        end
        -- Discord
        if string.find(identifiers[i], "discord:")  then
            identifiersString = identifiersString .. "&discord=" .. string.sub(identifiers[i], string.len("discord:") + 1, string.len(identifiers[i]))
        end
    end
    -- Check with API if player should be allowed
    local url = "https://authcx-api.herokuapp.com/whitelist/check/fivem/?token=" .. Config.token .. identifiersString
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            print()
            deferrals.done()
        else
            deferrals.done(Config.rejection)
        end
    end, "GET", "", {})
end

-- Event triggered when a player joins the server
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()
    deferrals.update("Contacting AuthCx API..")
    Citizen.Wait(1000)
    CheckWhitelist(deferrals, identifiers, name)
end)