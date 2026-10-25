
CasinoTurtle = CasinoTurtle or {}

CasinoTurtle.History = {
    entries = {},
    filter = "",
    page = 1,
    pageSize = 12
}

-- Guarda una tirada válida en memoria.
function CasinoTurtle.History:Record(
    playerName, roll, minRoll, maxRoll, gameId
)
    table.insert(self.entries, {
        player = playerName,
        roll = roll,
        minRoll = minRoll or 1,
        maxRoll = maxRoll,
        game = gameId or "unknown"
    })

    self:Refresh()
end

-- Devuelve las tiradas que coinciden con el filtro.
function CasinoTurtle.History:GetFilteredEntries()
    local result = {}
    local filter = string.lower(self.filter or "")
    local i
    local entry

    for i = 1, table.getn(self.entries) do
        entry = self.entries[i]

        if filter == ""
            or string.find(
                string.lower(entry.player),
                filter,
                1,
                true
            )
        then
            table.insert(result, entry)
        end
    end

    return result
end

function CasinoTurtle.History:SetFilter(value)
    self.filter = string.gsub(value or "", "^%s*(.-)%s*$", "%1")
    self.page = 1
    self:Refresh()
end

function CasinoTurtle.History:ShowAll()
    self.filter = ""

    if self.filterBox then
        self.filterBox:SetText("")
    end

    self.page = 1
    self:Refresh()
end

function CasinoTurtle.History:Create(mainFrame)
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", nil, UIParent)
    self.frame = frame

    frame:SetWidth(350)
    frame:SetHeight(420)
    frame:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", 5, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture(0, 0, 0, 0.90)

    local title = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalLarge"
    )
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)
    title:SetText("Historial de tiradas")

    local filterLabel = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormal"
    )
    filterLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -48)
    filterLabel:SetText("Filtrar jugador:")

    local filterBox = CreateFrame(
        "EditBox", nil, frame, "InputBoxTemplate"
    )
    self.filterBox = filterBox

    filterBox:SetWidth(145)
    filterBox:SetHeight(24)
    filterBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 120, -44)
    filterBox:SetAutoFocus(false)
    filterBox:SetScript("OnEnterPressed", function()
        CasinoTurtle.History:SetFilter(filterBox:GetText())
        filterBox:ClearFocus()
    end)

    local filterButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    filterButton:SetWidth(65)
    filterButton:SetHeight(22)
    filterButton:SetPoint("LEFT", filterBox, "RIGHT", 5, 0)
    filterButton:SetText("Filtrar")
    filterButton:SetScript("OnClick", function()
        CasinoTurtle.History:SetFilter(filterBox:GetText())
    end)

    local allButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    allButton:SetWidth(85)
    allButton:SetHeight(22)
    allButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -78)
    allButton:SetText("Mostrar todos")
    allButton:SetScript("OnClick", function()
        CasinoTurtle.History:ShowAll()
    end)

    self.statusText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontHighlightSmall"
    )
    self.statusText:SetPoint("LEFT", allButton, "RIGHT", 10, 0)

    self.rows = {}

    local i
    for i = 1, self.pageSize do
        local row = frame:CreateFontString(
            nil, "OVERLAY", "GameFontHighlightSmall"
        )

        row:SetPoint(
            "TOPLEFT", frame, "TOPLEFT",
            15, -115 - ((i - 1) * 20)
        )

        row:SetWidth(320)
        row:SetJustifyH("LEFT")
        row:SetText("")

        self.rows[i] = row
    end

    local previousButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.previousButton = previousButton
    previousButton:SetWidth(100)
    previousButton:SetHeight(24)
    previousButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 12)
    previousButton:SetText("Anterior")
    previousButton:SetScript("OnClick", function()
        if CasinoTurtle.History.page > 1 then
            CasinoTurtle.History.page =
                CasinoTurtle.History.page - 1
            CasinoTurtle.History:Refresh()
        end
    end)

    local nextButton = CreateFrame(
        "Button", nil, frame, "UIPanelButtonTemplate"
    )
    self.nextButton = nextButton
    nextButton:SetWidth(100)
    nextButton:SetHeight(24)
    nextButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 12)
    nextButton:SetText("Siguiente")
    nextButton:SetScript("OnClick", function()
        local entries = CasinoTurtle.History:GetFilteredEntries()
        local maxPage = math.max(
            1,
            math.ceil(table.getn(entries) /
                CasinoTurtle.History.pageSize)
        )

        if CasinoTurtle.History.page < maxPage then
            CasinoTurtle.History.page =
                CasinoTurtle.History.page + 1
            CasinoTurtle.History:Refresh()
        end
    end)

    frame:Hide()
    self:Refresh()
end

function CasinoTurtle.History:Refresh()
    if not self.frame then
        return
    end

    local entries = self:GetFilteredEntries()
    local total = table.getn(entries)
    local maxPage = math.max(
        1,
        math.ceil(total / self.pageSize)
    )

    if self.page > maxPage then
        self.page = maxPage
    end

    local first = (self.page - 1) * self.pageSize + 1
    local last = math.min(first + self.pageSize - 1, total)

    local i
    local entry
    local rowIndex = 1

    for i = first, last do
        entry = entries[i]

        self.rows[rowIndex]:SetText(
            entry.player .. "  |  " ..
            entry.roll .. "  (" ..
            entry.minRoll .. "-" .. entry.maxRoll .. ")"
        )

        rowIndex = rowIndex + 1
    end

    for i = rowIndex, self.pageSize do
        self.rows[i]:SetText("")
    end

    self.statusText:SetText(
        "Registros: " .. total ..
        " | Página " .. self.page .. "/" .. maxPage
    )

    if self.previousButton then
        if self.page > 1 then
            self.previousButton:Enable()
        else
            self.previousButton:Disable()
        end
    end

    if self.nextButton then
        if self.page < maxPage then
            self.nextButton:Enable()
        else
            self.nextButton:Disable()
        end
    end
end

function CasinoTurtle.History:Toggle()
    if not self.frame then
        return
    end

    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        self:Refresh()
    end
end
