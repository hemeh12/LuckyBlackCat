
CasinoTurtle = CasinoTurtle or {}
CasinoTurtle.UI = CasinoTurtle.UI or {}

local UI = CasinoTurtle.UI

UI.selectedGameId = UI.selectedGameId or "deathroll"

-- Aplica la configuracion elegida antes de crear una sala.
function UI:ApplySettings()
    local registry = CasinoTurtle.GameRegistry
    local session = CasinoTurtle.Session

    if not registry or not session then
        CasinoTurtle:Print("No se pudo continuar: faltan modulos.")
        return false
    end

    local game = registry:Get(self.selectedGameId)

    if not game then
        CasinoTurtle:Print("Selecciona un juego valido.")
        return false
    end

    if self.bettingCheck and self.bettingCheck:GetChecked() then
        local fee = tonumber(self.feeInput:GetText())

        if not fee or fee < 0 or fee ~= math.floor(fee) then
            CasinoTurtle:Print("Introduce una tarifa valida en oro.")
            return false
        end

        if not session:SetEntryFee(fee) then
            return false
        end

        session:SetBettingEnabled(true)
    else
        session:SetBettingEnabled(false)
    end

    if not registry:Select(self.selectedGameId) then
        return false
    end

    return true
end

function UI:Create()
    if self.frame then
        self.frame:Show()
        self:Refresh()
        return
    end

    local frame = CreateFrame("Frame", "CasinoTurtleMainFrame", UIParent)
    self.frame = frame

    frame:SetWidth(340)
    frame:SetHeight(390)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)

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

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)

    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)

    -- Titulo
    local title = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalLarge"
    )
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("CasinoTurtle")

    -- Cerrar
    local closeButton = CreateFrame(
        "Button", nil, frame, "UIPanelCloseButton"
    )
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Juego seleccionado
    local gameLabel = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    gameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -55)
    gameLabel:SetText("Juego seleccionado:")

    local gameName = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlightLarge"
    )
    self.gameName = gameName
    gameName:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -80)
    gameName:SetWidth(220)
    gameName:SetJustifyH("LEFT")

    local gameButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.gameButton = gameButton
    gameButton:SetWidth(85)
    gameButton:SetHeight(24)
    gameButton:SetPoint("LEFT", gameName, "RIGHT", 5, 0)
    gameButton:SetText("Cambiar")

    gameButton:SetScript("OnClick", function()
        local registry = CasinoTurtle.GameRegistry

        if not registry then
            CasinoTurtle:Print(
                "El registro de juegos no esta disponible."
            )
            return
        end

        local ids = {}
        local id
        local game

        for id, game in pairs(registry.games) do
            table.insert(ids, id)
        end

        table.sort(ids)

        if table.getn(ids) == 0 then
            CasinoTurtle:Print("No hay juegos registrados.")
            return
        end

        local currentIndex = 1
        local i

        for i = 1, table.getn(ids) do
            if ids[i] == self.selectedGameId then
                currentIndex = i
                break
            end
        end

        currentIndex = currentIndex + 1

        if currentIndex > table.getn(ids) then
            currentIndex = 1
        end

        self.selectedGameId = ids[currentIndex]
        self:Refresh()
    end)

    -- Modalidad
    local modeLabel = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    modeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -125)
    modeLabel:SetText("Modalidad de partida:")

    local freeCheck = CreateFrame(
        "CheckButton", nil, frame, "UICheckButtonTemplate"
    )
    self.freeCheck = freeCheck
    freeCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -145)

    local freeText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlight"
    )
    freeText:SetPoint("LEFT", freeCheck, "RIGHT", 0, 0)
    freeText:SetText("Gratis")

    local bettingCheck = CreateFrame(
        "CheckButton", nil, frame, "UICheckButtonTemplate"
    )
    self.bettingCheck = bettingCheck
    bettingCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 145, -145)

    local bettingText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlight"
    )
    bettingText:SetPoint("LEFT", bettingCheck, "RIGHT", 0, 0)
    bettingText:SetText("Con apuesta")

    local feeLabel = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    feeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -195)
    feeLabel:SetText("Tarifa de entrada (oro por jugador):")

    local feeInput = CreateFrame(
        "EditBox", nil, frame, "InputBoxTemplate"
    )
    self.feeInput = feeInput
    feeInput:SetWidth(70)
    feeInput:SetHeight(24)
    feeInput:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -218)
    feeInput:SetAutoFocus(false)
    feeInput:SetNumeric(true)
    feeInput:SetText(
        tostring(CasinoTurtle.Session.entryFee or 5)
    )

    local feeHelp = frame:CreateFontString(
        nil, "OVERLAY", "GameFontDisableSmall"
    )
    feeHelp:SetPoint("LEFT", feeInput, "RIGHT", 10, 0)
    feeHelp:SetText("Entrega manual del oro.")

    local function UpdateMode()
        if freeCheck:GetChecked() then
            bettingCheck:SetChecked(false)
            feeInput:Disable()
        else
            bettingCheck:SetChecked(true)
            feeInput:Enable()
        end
    end

    freeCheck:SetScript("OnClick", function()
        freeCheck:SetChecked(true)
        bettingCheck:SetChecked(false)
        UpdateMode()
    end)

    bettingCheck:SetScript("OnClick", function()
        bettingCheck:SetChecked(true)
        freeCheck:SetChecked(false)
        UpdateMode()
    end)

    -- Crear partida como host
    local createButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.createButton = createButton
    createButton:SetWidth(180)
    createButton:SetHeight(30)
    createButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 18)
    createButton:SetText("Crear partida")

    createButton:SetScript("OnClick", function()
        if not self:ApplySettings() then
            return
        end

        local multiplayer = CasinoTurtle.Multiplayer

        if not multiplayer then
            CasinoTurtle:Print(
                "El sistema multijugador no esta disponible."
            )
            return
        end

        multiplayer:CreateHostSession()

        if multiplayer.role == "host" then
            frame:Hide()

            if CasinoTurtle.MultiplayerUI then
                CasinoTurtle.MultiplayerUI:Show()
            end
        end
    end)

    -- Unirse por codigo
    local codeLabel = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    codeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -265)
    codeLabel:SetText("O unete a una partida existente:")

    local codeInput = CreateFrame(
        "EditBox", nil, frame, "InputBoxTemplate"
    )
    self.codeInput = codeInput
    codeInput:SetWidth(85)
    codeInput:SetHeight(24)
    codeInput:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -285)
    codeInput:SetAutoFocus(false)
    codeInput:SetNumeric(true)
    codeInput:SetMaxLetters(6)
    codeInput:SetText("")

    local joinButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.joinButton = joinButton
    joinButton:SetWidth(120)
    joinButton:SetHeight(26)
    joinButton:SetPoint("LEFT", codeInput, "RIGHT", 12, 0)
    joinButton:SetText("Unirse por codigo")

    joinButton:SetScript("OnClick", function()
        local multiplayer = CasinoTurtle.Multiplayer

        if not multiplayer then
            CasinoTurtle:Print(
                "El sistema multijugador no esta disponible."
            )
            return
        end

        local code = codeInput:GetText()

        if not code or string.len(code) ~= 6 then
            CasinoTurtle:Print(
                "Introduce el codigo de seis digitos."
            )
            return
        end

        multiplayer:JoinSession(code)

        if multiplayer.role == "joining" then
            frame:Hide()

            if CasinoTurtle.MultiplayerUI then
                CasinoTurtle.MultiplayerUI:Show()
            end
        end
    end)

    -- Estado inicial de las opciones
    if CasinoTurtle.Session.bettingEnabled then
        bettingCheck:SetChecked(true)
        freeCheck:SetChecked(false)
    else
        freeCheck:SetChecked(true)
        bettingCheck:SetChecked(false)
    end

    UpdateMode()
    self:Refresh()
end

function UI:Refresh()
    if not self.frame then
        return
    end

    local registry = CasinoTurtle.GameRegistry
    local game

    if registry then
        game = registry:Get(self.selectedGameId)

        if not game then
            game = registry:GetCurrent()

            if game then
                self.selectedGameId = game.id
            end
        end
    end

    if game then
        self.gameName:SetText(game.name)
    else
        self.gameName:SetText("Ningun juego disponible")
    end

    if self.feeInput and CasinoTurtle.Session then
        self.feeInput:SetText(
            tostring(CasinoTurtle.Session.entryFee or 5)
        )
    end
end
