
CasinoTurtle = CasinoTurtle or {}

CasinoTurtle.MultiplayerUI = {}
local MultiplayerUI = CasinoTurtle.MultiplayerUI

MultiplayerUI.memberRows = {}
MultiplayerUI.requestRows = {}

function MultiplayerUI:Create()
    if self.frame then
        return
    end

    local frame = CreateFrame(
        "Frame",
        "CasinoTurtleLobbyFrame",
        UIParent
    )

    self.frame = frame

    frame:SetWidth(370)
    frame:SetHeight(410)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)

    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })

    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.95)

    local title = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalLarge"
    )
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Sala multijugador")

    local closeButton = CreateFrame(
        "Button", nil, frame, "UIPanelCloseButton"
    )
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)

    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local roleText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlight"
    )
    self.roleText = roleText
    roleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45)
    roleText:SetWidth(330)
    roleText:SetJustifyH("LEFT")

    local codeText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    self.codeText = codeText
    codeText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -70)
    codeText:SetWidth(330)
    codeText:SetJustifyH("LEFT")

    local statusText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlight"
    )
    self.statusText = statusText
    statusText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -95)
    statusText:SetWidth(330)
    statusText:SetJustifyH("LEFT")

    local memberTitle = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    memberTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -125)
    memberTitle:SetText("Participantes")

    local i

    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, frame)
        row:SetWidth(325)
        row:SetHeight(20)
        row:SetPoint(
            "TOPLEFT", frame, "TOPLEFT",
            22, -147 - ((i - 1) * 21)
        )

        row.name = row:CreateFontString(
            nil, "OVERLAY", "GameFontHighlight"
        )
        row.name:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.name:SetWidth(285)
        row.name:SetJustifyH("LEFT")

        row:Hide()
        self.memberRows[i] = row
    end

    local requestTitle = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    self.requestTitle = requestTitle
    requestTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -320)
    requestTitle:SetText("Solicitudes pendientes")

    for i = 1, 3 do
        local row = CreateFrame("Frame", nil, frame)
        row:SetWidth(325)
        row:SetHeight(24)
        row:SetPoint(
            "TOPLEFT", frame, "TOPLEFT",
            22, -342 - ((i - 1) * 25)
        )

        row.name = row:CreateFontString(
            nil, "OVERLAY", "GameFontHighlight"
        )
        row.name:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.name:SetWidth(190)
        row.name:SetJustifyH("LEFT")

        row.accept = CreateFrame(
            "Button", nil, row, "UIPanelButtonTemplate"
        )
        row.accept:SetWidth(65)
        row.accept:SetHeight(22)
        row.accept:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.accept:SetText("Aceptar")

        row.reject = CreateFrame(
            "Button", nil, row, "UIPanelButtonTemplate"
        )
        row.reject:SetWidth(65)
        row.reject:SetHeight(22)
        row.reject:SetPoint("RIGHT", row.accept, "LEFT", -3, 0)
        row.reject:SetText("Rechazar")

        row:Hide()
        self.requestRows[i] = row
    end

    local startButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.startButton = startButton
    startButton:SetWidth(150)
    startButton:SetHeight(26)
    startButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    startButton:SetText("Iniciar partida")

    startButton:SetScript("OnClick", function()
        local multiplayer = CasinoTurtle.Multiplayer

        if multiplayer and multiplayer.StartGame then
            multiplayer:StartGame()
        else
            CasinoTurtle:Print(
                "El inicio multijugador aún no está conectado."
            )
        end
    end)

    self:Refresh()
end

function MultiplayerUI:Show()
    if not self.frame then
        self:Create()
    end

    self.frame:Show()
    self:Refresh()
end

function MultiplayerUI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function MultiplayerUI:Refresh()
    if not self.frame then
        return
    end

    local multiplayer = CasinoTurtle.Multiplayer

    if not multiplayer then
        self.roleText:SetText("Sistema multijugador no disponible.")
        return
    end

    if multiplayer.role == "host" then
        self.roleText:SetText("Rol: HOST")
        self.codeText:SetText(
            "Código de partida: " .. tostring(multiplayer.code or "-")
        )
        self.statusText:SetText(
            "Acepta a tus amigos y pulsa Iniciar partida."
        )
        self.startButton:Show()
        self.requestTitle:Show()

    elseif multiplayer.role == "joining" then
        self.roleText:SetText("Rol: INVITADO")
        self.codeText:SetText(
            "Código: " .. tostring(multiplayer.code or "-")
        )
        self.statusText:SetText("Esperando aprobación del host...")
        self.startButton:Hide()
        self.requestTitle:Hide()

    elseif multiplayer.role == "guest" then
        self.roleText:SetText(
            "Rol: INVITADO | Host: " ..
            tostring(multiplayer.hostName or "-")
        )
        self.codeText:SetText(
            "Código de partida: " .. tostring(multiplayer.code or "-")
        )
        self.statusText:SetText(
            "Esperando a que el host inicie la partida."
        )
        self.startButton:Hide()
        self.requestTitle:Hide()

    else
        self.roleText:SetText("No estás en una partida.")
        self.codeText:SetText("")
        self.statusText:SetText(
            "Crea una partida o únete mediante un código."
        )
        self.startButton:Hide()
        self.requestTitle:Hide()
    end

    local members = {}
    local key
    local name

    for key, name in pairs(multiplayer.members or {}) do
        table.insert(members, name)
    end

    table.sort(members)

    local i
    local row

    for i = 1, 8 do
        row = self.memberRows[i]

        if members[i] then
            row.name:SetText(members[i])
            row:Show()
        else
            row:Hide()
        end
    end

    local requests = {}

    for key, name in pairs(multiplayer.pendingRequests or {}) do
        table.insert(requests, {
            key = key,
            name = name
        })
    end

    table.sort(requests, function(a, b)
        return a.name < b.name
    end)

    for i = 1, 3 do
        row = self.requestRows[i]

        if requests[i] and multiplayer.role == "host" then
            local requestName = requests[i].name

            row.name:SetText(requestName)

            row.accept:SetScript("OnClick", function()
                multiplayer:AcceptRequest(requestName)
                self:Refresh()
            end)

            row.reject:SetScript("OnClick", function()
                multiplayer:RejectRequest(requestName)
                self:Refresh()
            end)

            row:Show()
        else
            row:Hide()
        end
    end
end
