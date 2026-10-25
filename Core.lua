CasinoTurtle = {}
CasinoTurtle.players = {}
CasinoTurtle.activeCount = 0
CasinoTurtle.sessionActive = true
CasinoTurtle.lastRollPlayer = nil
CasinoTurtle.lastRollValue = nil
CasinoTurtle.currentRollLimit = nil
CasinoTurtle.lastRollPlayer = nil
CasinoTurtle.lastRollValue = nil

function CasinoTurtle:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffCasinoTurtle:|r " .. message)
end

function CasinoTurtle:NormalizeName(name)
    if not name then
        return nil
    end

    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    if name == "" then
        return nil
    end

    return string.lower(name)
end

function CasinoTurtle:UpdateActiveCount()
    local count = 0
    local key
    local player

    for key, player in pairs(self.players) do
        if not player.eliminated then
            count = count + 1
        end
    end

    self.activeCount = count
end

function CasinoTurtle:RefreshUI()
    local registry = self.GameRegistry
    local game = registry and registry:GetCurrent()

    if game and game.UI and game.UI.Refresh then
        game.UI:Refresh()
    end

    -- Mantener actualizada la ventana principal si lo necesita.
    if self.UI and self.UI.Refresh then
        self.UI:Refresh()
    end
end

function CasinoTurtle:ResetSession()
    local key
    local player

    for key, player in pairs(self.players) do
        player.lastRoll = nil
        player.eliminated = false
    end
    self.lastRollPlayer = nil

    self.lastRollValue = nil

    self.sessionActive = true

    local registry = self.GameRegistry

    if registry then
        local game = registry:GetCurrent()

        if game and game.Reset then
            game:Reset()
        end
    end

    self:UpdateActiveCount()
    self:RefreshUI()
    self:Print("Nueva partida iniciada.")
end

function CasinoTurtle:ToggleWindow()
    if not self.UI or not self.UI.frame then
        return
    end

    if self.UI.frame:IsShown() then
        self.UI.frame:Hide()
    else
        self.UI.frame:Show()
    end
end

SLASH_CASINOTURTLE1 = "/casino"
SLASH_CASINOTURTLE2 = "/ct"

SlashCmdList["CASINOTURTLE"] = function(message)
    message = message or ""

    local command, argument = string.match(message, "^%s*(%S+)%s*(.-)%s*$")

    command = string.lower(command or "")
    argument = string.lower(argument or "")

    if command == "reset" then
        CasinoTurtle:ResetSession()

    elseif command == "games" then
        CasinoTurtle.GameRegistry:List()

    elseif command == "game" then
        if argument == "" then
            local game = CasinoTurtle.GameRegistry:GetCurrent()

            if game then
                CasinoTurtle:Print("Juego actual: " .. game.name)
            else
                CasinoTurtle:Print("No hay ningún juego seleccionado.")
            end
        else
            CasinoTurtle.GameRegistry:Select(argument)
        end

    elseif command == "apuestas" then
        if argument == "on" or argument == "si" then
            CasinoTurtle.Session:SetBettingEnabled(true)
        elseif argument == "off" or argument == "no" then
            CasinoTurtle.Session:SetBettingEnabled(false)
        else
            CasinoTurtle:Print("Usa /casino apuestas on o /casino apuestas off.")
        end

    elseif command == "tarifa" then
        CasinoTurtle.Session:SetEntryFee(argument)

    elseif command == "entrada" then
        local playerName, action = string.match(argument, "^(.-)%s+(%S+)$")

        if not playerName or playerName == "" then
            CasinoTurtle:Print("Usa /casino entrada Nombre aceptar o /casino entrada Nombre pagado.")
        elseif action == "aceptar" then
            CasinoTurtle.Session:AcceptEntry(playerName)
        elseif action == "pagado" then
            CasinoTurtle.Session:DeclarePayment(playerName)
        else
            CasinoTurtle:Print("Accion no reconocida.")
        end

    elseif command == "pozo" then
        local pot, count = CasinoTurtle.Session:GetPot()

        if CasinoTurtle.Session.bettingEnabled then
            CasinoTurtle:Print("Entradas confirmadas: " .. count .. " | Pozo estimado: " .. pot .. " oro.")
        else
            CasinoTurtle:Print("Partida gratuita | Participantes registrados: " .. count)
        end

    else
        CasinoTurtle:ToggleWindow()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")

eventFrame:SetScript("OnEvent", function()
    if not CasinoTurtleDB then
        CasinoTurtleDB = {}
    end

    if not CasinoTurtleDB.position then
        CasinoTurtleDB.position = {
            point = "CENTER",
            x = 0,
            y = 0
        }
    end

    if CasinoTurtle.UI and CasinoTurtle.UI.Create then
        CasinoTurtle.UI:Create()
    end

    CasinoTurtle:Print("Cargado. Escribe /casino para abrir la ventana.")

    eventFrame:UnregisterEvent("VARIABLES_LOADED")
end)
