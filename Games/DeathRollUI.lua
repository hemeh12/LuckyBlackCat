CasinoTurtle = CasinoTurtle or {}
CasinoTurtle.Games = CasinoTurtle.Games or {}

local DeathRollUI = {}

DeathRollUI.rows = {}

function DeathRollUI:Create(parent)
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", nil, parent)
    self.frame = frame

    frame:SetWidth(370)
    frame:SetHeight(420)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
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

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Death Roll")

    local nameInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    self.nameInput = nameInput
    nameInput:SetWidth(155)
    nameInput:SetHeight(24)
    nameInput:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -48)
    nameInput:SetAutoFocus(false)
    nameInput:SetText("")

    local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    addButton:SetWidth(75)
    addButton:SetHeight(24)
    addButton:SetPoint("LEFT", nameInput, "RIGHT", 8, 0)
    addButton:SetText("Agregar")

    addButton:SetScript("OnClick", function()
        local targetName

        if UnitExists("target") and UnitIsPlayer("target") then
            targetName = UnitName("target")
        end

        CasinoTurtle:AddPlayer(targetName or nameInput:GetText())
        nameInput:SetText("")
        nameInput:ClearFocus()
    end)

    nameInput:SetScript("OnEnterPressed", function()
        CasinoTurtle:AddPlayer(nameInput:GetText())
        nameInput:SetText("")
        nameInput:ClearFocus()
    end)

    local removeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    removeButton:SetWidth(75)
    removeButton:SetHeight(24)
    removeButton:SetPoint("LEFT", addButton, "RIGHT", 5, 0)
    removeButton:SetText("Retirar")

    removeButton:SetScript("OnClick", function()
        CasinoTurtle:RemovePlayer(nameInput:GetText())
        nameInput:SetText("")
        nameInput:ClearFocus()
    end)

    local historyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.historyButton = historyButton
    historyButton:SetWidth(90)
    historyButton:SetHeight(24)
    historyButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -75)
    historyButton:SetText("Historial")

    historyButton:SetScript("OnClick", function()
        if CasinoTurtle.History then
            CasinoTurtle.History:Toggle()
        end
    end)

    local activeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.activeText = activeText
    activeText:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -85)

    local lastRollText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.lastRollText = lastRollText
    lastRollText:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -105)
    lastRollText:SetWidth(330)
    lastRollText:SetJustifyH("LEFT")
    lastRollText:SetText("Última tirada: ninguna")

    local headerName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerName:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -135)
    headerName:SetText("Jugador")

    local headerRoll = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerRoll:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -135)
    headerRoll:SetText("Última tirada")

    local headerStatus = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerStatus:SetPoint("TOPLEFT", frame, "TOPLEFT", 285, -135)
    headerStatus:SetText("Estado")

    local i
    for i = 1, 10 do
        local row = CreateFrame("Frame", nil, frame)

        row:SetWidth(330)
        row:SetHeight(20)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -158 - ((i - 1) * 22))

        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.name:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.name:SetWidth(165)
        row.name:SetJustifyH("LEFT")

        row.roll = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.roll:SetPoint("LEFT", row, "LEFT", 170, 0)
        row.roll:SetWidth(70)
        row.roll:SetJustifyH("LEFT")

        row.status = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.status:SetPoint("LEFT", row, "LEFT", 265, 0)
        row.status:SetWidth(65)
        row.status:SetJustifyH("LEFT")

        row:Hide()
        self.rows[i] = row
    end

    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetWidth(160)
    resetButton:SetHeight(25)
    resetButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    resetButton:SetText("Nueva partida")

    resetButton:SetScript("OnClick", function()
        CasinoTurtle:ResetSession()
    end)

    self.resetButton = resetButton

    local menuButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    menuButton:SetWidth(120)
    menuButton:SetHeight(25)
    menuButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 12)
    menuButton:SetText("Volver al menú")

    menuButton:SetScript("OnClick", function()
        DeathRollUI:Hide()

        if CasinoTurtle.UI and CasinoTurtle.UI.frame then
            CasinoTurtle.UI.frame:Show()
            CasinoTurtle.UI:Refresh()
        end
    end)

    self:Refresh()

    if CasinoTurtle.History then
        CasinoTurtle.History:Create(frame)
    end
end

function DeathRollUI:Show()
    if self.frame then
        self.frame:Show()
        self:Refresh()
    end
end

function DeathRollUI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function DeathRollUI:Refresh()
    if not self.frame then
        return
    end

    self.activeText:SetText("En partida: " .. CasinoTurtle.activeCount)

    if CasinoTurtle.lastRollPlayer and CasinoTurtle.lastRollValue ~= nil then
        self.lastRollText:SetText("Última tirada: " .. CasinoTurtle.lastRollPlayer .. " -> " ..
                                      CasinoTurtle.lastRollValue)
    else
        self.lastRollText:SetText("Última tirada: ninguna")
    end

    local players = {}
    local key
    local player

    for key, player in pairs(CasinoTurtle.players) do
        table.insert(players, player)
    end

    table.sort(players, function(a, b)
        return string.lower(a.name) < string.lower(b.name)
    end)

    local i
    local row

    for i = 1, 10 do
        row = self.rows[i]

        if players[i] then
            player = players[i]

            row.name:SetText(player.name)
            row.roll:SetText(player.lastRoll and tostring(player.lastRoll) or "-")

            if player.eliminated then
                row.status:SetText("Eliminado")
                row.name:SetTextColor(0.9, 0.3, 0.3)
                row.roll:SetTextColor(0.9, 0.3, 0.3)
                row.status:SetTextColor(0.9, 0.3, 0.3)
            elseif player.lastRoll then
                row.status:SetText("Activo")
                row.name:SetTextColor(0.3, 1, 0.3)
                row.roll:SetTextColor(1, 1, 1)
                row.status:SetTextColor(0.3, 1, 0.3)
            else
                row.status:SetText("Sin tirar")
                row.name:SetTextColor(1, 1, 1)
                row.roll:SetTextColor(1, 1, 1)
                row.status:SetTextColor(0.8, 0.8, 0.8)
            end

            row:Show()
        else
            row:Hide()
        end
    end

    if table.getn(players) > 10 then
        self.activeText:SetText("En partida: " .. CasinoTurtle.activeCount .. " | Mostrando 10 jugadores")
    end
end

-- Registrar la interfaz en el objeto del juego.
if CasinoTurtle.Games.DeathRoll then
    CasinoTurtle.Games.DeathRoll.UI = DeathRollUI
end
