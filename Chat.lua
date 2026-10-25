CasinoTurtle.Chat = {}

function CasinoTurtle.Chat:ParseRoll(message)
    if not message then
        return nil, nil, nil
    end

    local name, roll, minRoll, maxRoll

    -- Tirada de otro jugador
    name, roll, minRoll, maxRoll = string.match(message, "^(.+) rolls (%d+) %((%d+)%-(%d+)%)")

    if name and roll then
        return name, tonumber(roll), tonumber(minRoll), tonumber(maxRoll)
    end

    -- Tirada propia
    roll, minRoll, maxRoll = string.match(message, "^You roll (%d+) %((%d+)%-(%d+)%)")

    if roll then
        return UnitName("player"), tonumber(roll), tonumber(minRoll), tonumber(maxRoll)
    end

    return nil, nil, nil, nil
end

function CasinoTurtle.Chat:OnSystemMessage(message)
    local name, roll, minRoll, maxRoll = self:ParseRoll(message)

    if not name or not roll or not maxRoll then
        return
    end

    local registry = CasinoTurtle.GameRegistry

    if not registry then
        return
    end

    local game = registry:GetCurrent()

    if game and game.RecordRoll then
        game:RecordRoll(name, roll, maxRoll, minRoll)
    end
end

local chatFrame = CreateFrame("Frame")
chatFrame:RegisterEvent("CHAT_MSG_SYSTEM")

chatFrame:SetScript("OnEvent", function()
    CasinoTurtle.Chat:OnSystemMessage(arg1)
end)
