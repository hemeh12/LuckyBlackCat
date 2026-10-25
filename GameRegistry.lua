
CasinoTurtle = CasinoTurtle or {}

CasinoTurtle.GameRegistry = {
    games = {},
    currentGameId = nil,
    currentUI = nil
}

function CasinoTurtle.GameRegistry:Register(game)
    if not game or not game.id or not game.name then
        CasinoTurtle:Print("No se pudo registrar un juego.")
        return false
    end

    self.games[game.id] = game
    return true
end

function CasinoTurtle.GameRegistry:Get(gameId)
    return self.games[gameId]
end

function CasinoTurtle.GameRegistry:GetCurrent()
    if not self.currentGameId then
        return nil
    end

    return self.games[self.currentGameId]
end

function CasinoTurtle.GameRegistry:Select(gameId)
    local game = self:Get(gameId)

    if not game then
        CasinoTurtle:Print("Juego no encontrado: " .. tostring(gameId))
        return false
    end

    self.currentGameId = gameId
    CasinoTurtle:Print("Juego seleccionado: " .. game.name)
    return true
end

function CasinoTurtle.GameRegistry:OpenCurrentUI(parent)
    local game = self:GetCurrent()

    if not game then
        CasinoTurtle:Print("No hay ningún juego seleccionado.")
        return false
    end

    if not game.UI or not game.UI.Create then
        CasinoTurtle:Print("La interfaz de " .. game.name .. " aún no está disponible.")
        return false
    end

    if self.currentUI and self.currentUI.Hide then
        self.currentUI:Hide()
    end

    self.currentUI = game.UI

    if not game.UI.frame then
        game.UI:Create(parent)
    end

    if game.UI.Show then
        game.UI:Show()
    end

    return true
end

function CasinoTurtle.GameRegistry:List()
    CasinoTurtle:Print("Juegos disponibles:")

    local gameId
    local game

    for gameId, game in pairs(self.games) do
        local selected = ""

        if gameId == self.currentGameId then
            selected = " (seleccionado)"
        end

        CasinoTurtle:Print("- " .. game.name .. " [" .. gameId .. "]" .. selected)
    end
end

-- Registrar Death Roll como primer juego.
if CasinoTurtle.Games and CasinoTurtle.Games.DeathRoll then
    CasinoTurtle.GameRegistry:Register(CasinoTurtle.Games.DeathRoll)
    CasinoTurtle.GameRegistry:Select("deathroll")
end
