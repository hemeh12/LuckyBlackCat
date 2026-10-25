CasinoTurtle = CasinoTurtle or {}
CasinoTurtle.Games = CasinoTurtle.Games or {}

local DeathRoll = {}

DeathRoll.id = "deathroll"
DeathRoll.name = "Death Roll"

-- Registra una tirada de Death Roll.
function DeathRoll:RecordRoll(name, roll, rollMax, rollMin)
    if not CasinoTurtle.sessionActive then
        return
    end

    local key = CasinoTurtle:NormalizeName(name)
    if not key then
        return
    end

    local player = CasinoTurtle.players[key]

    if not player or player.eliminated then
        return
    end

    if CasinoTurtle.Session and not CasinoTurtle.Session:CanPlay(player.name) then

        CasinoTurtle:Print(player.name .. " no puede tirar: debe aceptar y confirmar la entrada.")

        return
    end

    -- La primera tirada establece el límite inicial.
    if not CasinoTurtle.currentRollLimit then
        if roll == 1 then
            CasinoTurtle:Print("La tirada inicial no puede ser 1.")
            return
        end

        player.lastRoll = roll
        CasinoTurtle.lastRollPlayer = player.name
        CasinoTurtle.lastRollValue = roll
        CasinoTurtle.currentRollLimit = roll

        if CasinoTurtle.History then
            CasinoTurtle.History:Record(player.name, roll, rollMin, rollMax, "deathroll")
        end

        CasinoTurtle:UpdateActiveCount()
        CasinoTurtle:RefreshUI()
        return
    end

    -- La tirada debe utilizar el límite vigente.
    if rollMax ~= CasinoTurtle.currentRollLimit then
        CasinoTurtle:Print(player.name .. ": tirada ignorada. El límite actual es " .. CasinoTurtle.currentRollLimit ..
                               ".")
        return
    end

    if roll < 1 or roll > CasinoTurtle.currentRollLimit then
        return
    end

    player.lastRoll = roll
    CasinoTurtle.lastRollPlayer = player.name
    CasinoTurtle.lastRollValue = roll

    if CasinoTurtle.History then
        CasinoTurtle.History:Record(player.name, roll, rollMin, rollMax, "deathroll")
    end

    if roll == 1 then
        player.eliminated = true
        CasinoTurtle.sessionActive = false
        CasinoTurtle:Print(player.name .. " ha perdido la partida.")
    else
        CasinoTurtle.currentRollLimit = roll
    end

    CasinoTurtle:UpdateActiveCount()
    CasinoTurtle:RefreshUI()
end
function DeathRoll:Reset()
    CasinoTurtle.currentRollLimit = nil
end
CasinoTurtle.Games.DeathRoll = DeathRoll
