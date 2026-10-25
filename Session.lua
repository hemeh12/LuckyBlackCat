CasinoTurtle = CasinoTurtle or {}

CasinoTurtle.Session = {
    bettingEnabled = false,
    entryFee = 5
}

local Session = CasinoTurtle.Session

-- Inicializa el estado de entrada de un jugador.
function Session:InitializePlayer(player)
    if not player then
        return
    end

    if self.bettingEnabled then
        player.entryAccepted = false
        player.entryPaid = false
    else
        player.entryAccepted = true
        player.entryPaid = true
    end
end

-- Activa o desactiva las apuestas.
function Session:SetBettingEnabled(enabled)
    self.bettingEnabled = enabled and true or false

    local key
    local player

    for key, player in pairs(CasinoTurtle.players) do
        self:InitializePlayer(player)
    end

    CasinoTurtle:RefreshUI()

    if self.bettingEnabled then
        CasinoTurtle:Print("Apuestas activadas. Tarifa: " .. self.entryFee .. " oro.")
    else
        CasinoTurtle:Print("Partida gratuita. No hay tarifa de entrada.")
    end
end

-- Establece la tarifa en oro entero.
function Session:SetEntryFee(amount)
    amount = tonumber(amount)

    if not amount or amount < 0 or amount ~= math.floor(amount) then
        CasinoTurtle:Print("La tarifa debe ser un numero entero de oro.")
        return false
    end

    self.entryFee = amount

    CasinoTurtle:Print("Tarifa de entrada: " .. amount .. " oro.")
    CasinoTurtle:RefreshUI()

    return true
end

-- Un jugador acepta la tarifa.
function Session:AcceptEntry(name)
    local key = CasinoTurtle:NormalizeName(name)
    local player = key and CasinoTurtle.players[key]

    if not player then
        CasinoTurtle:Print("Jugador no registrado.")
        return false
    end

    if not self.bettingEnabled then
        player.entryAccepted = true
        player.entryPaid = true
        CasinoTurtle:Print(player.name .. " puede participar en la partida gratuita.")
        return true
    end

    player.entryAccepted = true
    player.entryPaid = false

    CasinoTurtle:Print(player.name .. " ha aceptado la entrada de " .. self.entryFee .. " oro. Falta registrar el pago.")

    CasinoTurtle:RefreshUI()
    return true
end

-- Registra la declaración de que el jugador ya entregó el oro.
-- Esto no verifica una transferencia real dentro de WoW.
function Session:DeclarePayment(name)
    local key = CasinoTurtle:NormalizeName(name)
    local player = key and CasinoTurtle.players[key]

    if not player then
        CasinoTurtle:Print("Jugador no registrado.")
        return false
    end

    if not self.bettingEnabled then
        CasinoTurtle:Print("La partida es gratuita.")
        return false
    end

    if not player.entryAccepted then
        CasinoTurtle:Print("El jugador debe aceptar la entrada primero.")
        return false
    end

    player.entryPaid = true

    CasinoTurtle:Print(player.name .. " figura como entrada pagada.")

    CasinoTurtle:RefreshUI()
    return true
end

-- Comprueba si un jugador está habilitado para jugar.
function Session:CanPlay(name)
    local key = CasinoTurtle:NormalizeName(name)
    local player = key and CasinoTurtle.players[key]

    if not player or player.eliminated then
        return false
    end

    if not self.bettingEnabled then
        return true
    end

    return player.entryAccepted and player.entryPaid
end

-- Calcula los participantes pagados y el pozo estimado.
function Session:GetPot()
    local paidCount = 0
    local key
    local player

    for key, player in pairs(CasinoTurtle.players) do
        if player.entryAccepted and player.entryPaid then
            paidCount = paidCount + 1
        end
    end

    if not self.bettingEnabled then
        return 0, paidCount
    end

    return paidCount * self.entryFee, paidCount
end
