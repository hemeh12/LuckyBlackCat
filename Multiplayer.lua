CasinoTurtle = CasinoTurtle or {}

CasinoTurtle.Multiplayer = {
    prefix = "CTCasino",
    role = "none",
    code = nil,
    hostName = nil,
    pendingRequests = {},
    members = {}
}

local Multiplayer = CasinoTurtle.Multiplayer

function Multiplayer:RefreshLobby()
    if CasinoTurtle.MultiplayerUI then
        CasinoTurtle.MultiplayerUI:Refresh()
    end
end

function Multiplayer:BroadcastMembers()
    local key
    local name

    for key, name in pairs(self.members) do
        self:Send("MEMBER:" .. self.code .. ":" .. name)
    end
end

function Multiplayer:StartGame()
    if self.role ~= "host" then
        CasinoTurtle:Print("Solo el host puede iniciar la partida.")
        return
    end

    local registry = CasinoTurtle.GameRegistry
    local game = registry and registry:GetCurrent()

    if not game then
        CasinoTurtle:Print("No hay un juego seleccionado.")
        return
    end

    self:Send("START:" .. self.code .. ":" .. game.id)

    if registry:OpenCurrentUI(UIParent) then
        self:RefreshLobby()

        if CasinoTurtle.MultiplayerUI then
            CasinoTurtle.MultiplayerUI:Hide()
        end

        if CasinoTurtle.UI and CasinoTurtle.UI.frame then
            CasinoTurtle.UI.frame:Hide()
        end
    end
end

function Multiplayer:GetChannel()
    if GetNumRaidMembers and GetNumRaidMembers() > 0 then
        return "RAID"
    end

    if GetNumPartyMembers and GetNumPartyMembers() > 0 then
        return "PARTY"
    end

    return nil
end

function Multiplayer:Send(message)
    local channel = self:GetChannel()

    if not channel then
        CasinoTurtle:Print("Debes estar en un grupo para comunicarte con otros jugadores.")
        return false
    end

    if not SendAddonMessage then
        CasinoTurtle:Print("Este cliente no dispone de SendAddonMessage.")
        return false
    end

    SendAddonMessage(self.prefix, message, channel)
    return true
end

function Multiplayer:CreateHostSession()
    if self.role == "host" then
        CasinoTurtle:Print("Ya eres el host de una partida.")
        return
    end

    local code = tostring(math.random(100000, 999999))

    self.role = "host"
    self.code = code
    self.hostName = UnitName("player")
    self.pendingRequests = {}
    self.members = {}

    local playerKey = CasinoTurtle:NormalizeName(self.hostName)
    self.members[playerKey] = self.hostName

    CasinoTurtle:Print("Partida creada.")
    CasinoTurtle:Print("Código de la partida: " .. code)
    CasinoTurtle:Print("Comparte el código con tus amigos y acepta sus solicitudes con /ctaccept.")

    self:RefreshLobby()

    if CasinoTurtle.MultiplayerUI then
        CasinoTurtle.MultiplayerUI:Show()
    end
end

function Multiplayer:JoinSession(code)
    code = string.gsub(code or "", "%s+", "")

    if string.len(code) ~= 6 or not tonumber(code) then
        CasinoTurtle:Print("Uso correcto: /ctjoin CODIGO")
        return
    end

    if self.role == "host" then
        CasinoTurtle:Print("No puedes unirte a otra partida mientras eres host.")
        return
    end

    self.code = code
    self.role = "joining"
    self.hostName = nil

    if self:Send("JOIN:" .. code) then
        CasinoTurtle:Print("Solicitud enviada. Esperando la aprobación del host...")
        self:RefreshLobby()

        if CasinoTurtle.MultiplayerUI then
            CasinoTurtle.MultiplayerUI:Show()
        end

    else
        self.role = "none"
        self.code = nil
    end
end


function Multiplayer:AcceptRequest(name)
    if self.role ~= "host" then
        CasinoTurtle:Print("Solo el host puede aceptar jugadores.")
        return
    end

    local key = CasinoTurtle:NormalizeName(name)

    if not key or not self.pendingRequests[key] then
        CasinoTurtle:Print("No existe una solicitud pendiente de ese jugador.")
        return
    end

    local targetName = self.pendingRequests[key]
    local message = "ACCEPT:" .. self.code .. ":" .. targetName

    if self:Send(message) then
        self.members[key] = targetName
        self.pendingRequests[key] = nil

        if not CasinoTurtle.players[key] then
            CasinoTurtle:AddPlayer(targetName)
        end

        local session = CasinoTurtle.Session
        if session then
            self:Send(
                "CONFIG:" .. self.code .. ":" ..
                tostring(session.bettingEnabled) .. ":" ..
                tostring(session.entryFee)
            )
        end

        self:BroadcastMembers()
        self:RefreshLobby()

        CasinoTurtle:Print(
            targetName .. " ha sido aceptado en la partida."
        )
    end
end


function Multiplayer:RejectRequest(name)
    if self.role ~= "host" then
        CasinoTurtle:Print("Solo el host puede rechazar jugadores.")
        return
    end

    local key = CasinoTurtle:NormalizeName(name)

    if not key or not self.pendingRequests[key] then
        CasinoTurtle:Print("No existe una solicitud pendiente de ese jugador.")
        return
    end

    local targetName = self.pendingRequests[key]

    if self:Send("REJECT:" .. self.code .. ":" .. targetName) then
        self.pendingRequests[key] = nil
        CasinoTurtle:Print("Solicitud rechazada: " .. targetName)
    end
end


function Multiplayer:HandleMessage(message, sender)
    if not message or not sender then
        return
    end

    local action, code, data = string.match(
        message, "^([^:]+):([^:]+):?(.*)$"
    )

    if not action then
        return
    end

    local senderKey = CasinoTurtle:NormalizeName(sender)
    local localName = CasinoTurtle:NormalizeName(UnitName("player"))

    if action == "JOIN" then
        if self.role ~= "host" or code ~= self.code then
            return
        end

        if senderKey == localName then
            return
        end

        if self.members[senderKey] then
            CasinoTurtle:Print(sender .. " ya pertenece a la partida.")
            return
        end

        self.pendingRequests[senderKey] = sender
        CasinoTurtle:Print(
            sender .. " solicita unirse. Revisa la sala multijugador."
        )
        self:RefreshLobby()

    elseif action == "ACCEPT" then
        if self.role ~= "joining" or code ~= self.code then
            return
        end

        if CasinoTurtle:NormalizeName(data) ~= localName then
            return
        end

        self.role = "guest"
        self.hostName = sender

        CasinoTurtle:Print(
            "Solicitud aceptada. Tu host es " .. sender .. "."
        )
        self:RefreshLobby()

    elseif action == "REJECT" then
        if self.role ~= "joining" or code ~= self.code then
            return
        end

        if CasinoTurtle:NormalizeName(data) ~= localName then
            return
        end

        self.role = "none"
        self.code = nil
        self.hostName = nil

        CasinoTurtle:Print("El host ha rechazado tu solicitud.")
        self:RefreshLobby()

    elseif action == "CONFIG" then
        if self.role ~= "guest" or code ~= self.code then
            return
        end

        if CasinoTurtle:NormalizeName(sender) ~=
            CasinoTurtle:NormalizeName(self.hostName) then
            return
        end

        local enabled, fee = string.match(
            data, "^([^:]+):?(.*)$"
        )

        local session = CasinoTurtle.Session

        if session then
            session.bettingEnabled = enabled == "true"
            session.entryFee = tonumber(fee) or session.entryFee

            local key
            local player

            for key, player in pairs(CasinoTurtle.players) do
                session:InitializePlayer(player)
            end
        end

        self:RefreshLobby()

    elseif action == "MEMBER" then
        if code ~= self.code then
            return
        end

        if self.role ~= "host" and self.role ~= "guest" then
            return
        end

        if self.role == "guest" and
            CasinoTurtle:NormalizeName(sender) ~=
            CasinoTurtle:NormalizeName(self.hostName) then
            return
        end

        local memberKey = CasinoTurtle:NormalizeName(data)

        if memberKey and data ~= "" then
            self.members[memberKey] = data

            if self.role == "guest" and
                not CasinoTurtle.players[memberKey] then
                CasinoTurtle:AddPlayer(data)
            end
        end

        self:RefreshLobby()

    elseif action == "START" then
        if self.role ~= "guest" or code ~= self.code then
            return
        end

        if CasinoTurtle:NormalizeName(sender) ~=
            CasinoTurtle:NormalizeName(self.hostName) then
            return
        end

        local registry = CasinoTurtle.GameRegistry
        if not registry or not registry:Select(data) then
            CasinoTurtle:Print(
                "No tienes instalado el juego seleccionado por el host."
            )
            return
        end

        if registry:OpenCurrentUI(UIParent) then
            if CasinoTurtle.MultiplayerUI then
                CasinoTurtle.MultiplayerUI:Hide()
            end

            if CasinoTurtle.UI and CasinoTurtle.UI.frame then
                CasinoTurtle.UI.frame:Hide()
            end
        end
    end
end


function Multiplayer:LeaveSession()
    self.role = "none"
    self.code = nil
    self.hostName = nil
    self.pendingRequests = {}
    self.members = {}

    CasinoTurtle:Print("Has salido de la sesión multijugador.")
end

-- Recibir mensajes enviados por otros clientes del addon.
local multiplayerFrame = CreateFrame("Frame")
multiplayerFrame:RegisterEvent("CHAT_MSG_ADDON")

multiplayerFrame:SetScript("OnEvent", function()
    if arg1 ~= Multiplayer.prefix then
        return
    end

    Multiplayer:HandleMessage(arg2, arg4)
end)

-- Registrar el prefijo cuando esta función esté disponible.
if RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(Multiplayer.prefix)
end

-- Comandos de prueba para host e invitados.
SLASH_CASINOTURTLEHOST1 = "/cthost"
SlashCmdList["CASINOTURTLEHOST"] = function()
    Multiplayer:CreateHostSession()
end

SLASH_CASINOTURTLEJOIN1 = "/ctjoin"
SlashCmdList["CASINOTURTLEJOIN"] = function(message)
    Multiplayer:JoinSession(message)
end

SLASH_CASINOTURTLEACCEPT1 = "/ctaccept"
SlashCmdList["CASINOTURTLEACCEPT"] = function(message)
    Multiplayer:AcceptRequest(message)
end

SLASH_CASINOTURTLEREJECT1 = "/ctreject"
SlashCmdList["CASINOTURTLEREJECT"] = function(message)
    Multiplayer:RejectRequest(message)
end

SLASH_CASINOTURTLELEAVE1 = "/ctleave"
SlashCmdList["CASINOTURTLELEAVE"] = function()
    Multiplayer:LeaveSession()
end
