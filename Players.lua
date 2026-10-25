function CasinoTurtle:AddPlayer(name)
    name = string.gsub(name or "", "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    if name == "" then
        self:Print("Escribe el nombre de un jugador.")
        return false
    end

    local key = self:NormalizeName(name)

    if self.players[key] then
        self:Print(name .. " ya está registrado.")
        return false
    end

    self.players[key] = {
        name = name,
        lastRoll = nil,
        eliminated = false
    }

    -- Inicializar los datos de entrada para la partida
    if self.Session then
        self.Session:InitializePlayer(self.players[key])
    end

    self:UpdateActiveCount()
    self:RefreshUI()
    self:Print(name .. " añadido a la partida.")

    return true
end

function CasinoTurtle:RemovePlayer(name)
    local key = self:NormalizeName(name)

    if not key or not self.players[key] then
        self:Print("Ese jugador no está registrado.")
        return false
    end

    self.players[key] = nil

    self:UpdateActiveCount()
    self:RefreshUI()
    self:Print("Jugador retirado de la lista.")

    return true
end

