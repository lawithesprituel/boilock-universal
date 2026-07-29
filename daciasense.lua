--[[
    ╔════════════════════════════════════════════════╗
    ║           DaciaSense UI Library                ║
    ║     GameSense (CS2) Style UI for Roblox        ║
    ║                                                ║
    ║     Toggle: Delete Key                         ║
    ╚════════════════════════════════════════════════╝
    
    Usage:
        local DaciaSense = loadstring(...)()
        local Window = DaciaSense:CreateWindow("daciasense")
        local Tab = Window:AddTab("Aimbot")
        local Main = Tab:AddLeftGroup("Main")
        Main:AddCheckbox({Text = "Enabled", Default = false, Callback = function(v) end})
        Main:AddSlider({Text = "FOV", Min = 0, Max = 360, Default = 120, Callback = function(v) end})
]]

local Library = {}
Library.Flags = {}
Library.ToggleKey = Enum.KeyCode.Delete
Library.Toggled = true
Library.ScreenGui = nil
Library._connections = {}
Library._activePopup = nil
Library._popupClose = nil

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════
-- THEME (GameSense CS2 Palette)
-- ═══════════════════════════════════════════
local T = {
    WindowBg       = Color3.fromRGB(22, 22, 30),
    WindowBorder   = Color3.fromRGB(48, 48, 58),
    
    SidebarBg      = Color3.fromRGB(18, 18, 26),
    SidebarHover   = Color3.fromRGB(28, 28, 38),
    SidebarActive  = Color3.fromRGB(32, 32, 44),
    SidebarLine    = Color3.fromRGB(38, 38, 50),
    
    TabNormal      = Color3.fromRGB(110, 110, 130),
    TabHover       = Color3.fromRGB(160, 160, 175),
    TabActive      = Color3.fromRGB(210, 210, 220),
    
    GroupBorder    = Color3.fromRGB(118, 125, 38),
    GroupTitle     = Color3.fromRGB(195, 195, 200),
    
    Accent         = Color3.fromRGB(123, 163, 40),
    AccentDark     = Color3.fromRGB(95, 130, 30),
    AccentHover    = Color3.fromRGB(140, 180, 50),
    
    TextPrimary    = Color3.fromRGB(195, 195, 200),
    TextSecondary  = Color3.fromRGB(140, 140, 155),
    TextDim        = Color3.fromRGB(95, 95, 115),
    
    CheckboxBg     = Color3.fromRGB(48, 48, 60),
    CheckboxHover  = Color3.fromRGB(62, 62, 76),
    SliderBg       = Color3.fromRGB(48, 48, 60),
    SliderFill     = Color3.fromRGB(123, 163, 40),
    DropdownBg     = Color3.fromRGB(32, 32, 42),
    DropdownHover  = Color3.fromRGB(44, 44, 58),
    DropdownBorder = Color3.fromRGB(55, 55, 68),
    ButtonBg       = Color3.fromRGB(38, 38, 50),
    ButtonHover    = Color3.fromRGB(52, 52, 66),
    InputBg        = Color3.fromRGB(30, 30, 40),
    InputBorder    = Color3.fromRGB(55, 55, 68),
    ListBg         = Color3.fromRGB(24, 24, 34),
    ListHover      = Color3.fromRGB(34, 34, 46),
    ListSelected   = Color3.fromRGB(42, 42, 56),
    ScrollBar      = Color3.fromRGB(58, 58, 72),
    Separator      = Color3.fromRGB(48, 48, 60),
}

-- ═══════════════════════════════════════════
-- CONSTANTS
-- ═══════════════════════════════════════════
local SIDEBAR_W    = 48
local FONT         = Enum.Font.Code
local FONT_UI      = Enum.Font.Gotham
local FONT_BOLD    = Enum.Font.GothamBold
local TEXT_SIZE    = 13
local SMALL_TEXT   = 11
local ELEMENT_PAD  = 4
local GROUP_PAD_X  = 10
local GROUP_PAD_TOP = 16
local GROUP_PAD_BOT = 10

-- ═══════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function tween(obj, props, dur)
    local tw = TweenService:Create(obj, TweenInfo.new(dur or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function addConnection(conn)
    table.insert(Library._connections, conn)
    return conn
end

local function closeActivePopup()
    if Library._popupClose then
        Library._popupClose()
        Library._popupClose = nil
    end
end

-- ═══════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════
function Library:CreateWindow(title)
    title = title or "daciasense"

    -- ScreenGui
    local gui = create("ScreenGui", {
        Name = "DaciaSense",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    if syn and syn.protect_gui then syn.protect_gui(gui) end
    if gethui then gui.Parent = gethui() else gui.Parent = playerGui end
    Library.ScreenGui = gui

    -- Outer border frame
    local outer = create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 780, 0, 480),
        Position = UDim2.new(0.5, -390, 0.5, -240),
        BackgroundColor3 = T.WindowBorder,
        BorderSizePixel = 0,
        Parent = gui,
    })

    -- Inner frame (1px inset from border)
    local inner = create("Frame", {
        Name = "Inner",
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = T.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = outer,
    })

    -- Top accent line (signature GameSense green bar)
    local accentLine = create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = inner,
    })

    -- ─── SIDEBAR ───
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SIDEBAR_W, 1, -2),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = T.SidebarBg,
        BorderSizePixel = 0,
        Parent = inner,
    })

    -- Sidebar right separator line
    create("Frame", {
        Name = "SidebarLine",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.SidebarLine,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    -- Brand area (drag handle + logo)
    local brandArea = create("TextButton", {
        Name = "Brand",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = sidebar,
    })

    create("TextLabel", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "DS",
        TextColor3 = T.Accent,
        Font = FONT_BOLD,
        TextSize = 16,
        Parent = brandArea,
    })

    -- Tab button container
    local tabContainer = create("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabContainer,
    })

    -- ─── CONTENT AREA ───
    local contentArea = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -(SIDEBAR_W + 1), 1, -2),
        Position = UDim2.new(0, SIDEBAR_W + 1, 0, 2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = inner,
    })

    -- ─── DRAGGING ───
    local dragging, dragStart, frameStart = false, nil, nil

    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = outer.Position
            local changed
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changed then changed:Disconnect() end
                end
            end)
        end
    end

    brandArea.InputBegan:Connect(startDrag)
    accentLine.InputBegan:Connect(startDrag)

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            outer.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end))

    -- ─── TOGGLE (Delete Key) ───
    addConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.ToggleKey then
            Library.Toggled = not Library.Toggled
            gui.Enabled = Library.Toggled
            if not Library.Toggled then
                closeActivePopup()
            end
        end
    end))

    -- ─── WINDOW OBJECT ───
    local window = {
        gui = gui,
        outer = outer,
        inner = inner,
        contentArea = contentArea,
        tabContainer = tabContainer,
        tabs = {},
        activeTab = nil,
    }

    function window:SelectTab(tab)
        if self.activeTab == tab then return end
        closeActivePopup()

        if self.activeTab then
            self.activeTab.page.Visible = false
            tween(self.activeTab.button, {BackgroundColor3 = T.SidebarBg}, 0.1)
            self.activeTab.indicator.Visible = false
            self.activeTab.iconLabel.TextColor3 = T.TabNormal
        end

        self.activeTab = tab
        tab.page.Visible = true
        tween(tab.button, {BackgroundColor3 = T.SidebarActive}, 0.1)
        tab.indicator.Visible = true
        tab.iconLabel.TextColor3 = T.TabActive
    end

    function window:AddTab(name, icon)
        local tabObj = {}
        tabObj.name = name

        -- Sidebar tab button
        local btn = create("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = T.SidebarBg,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #self.tabs + 1,
            Parent = tabContainer,
        })

        -- Active indicator (left green bar)
        local indicator = create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0.55, 0),
            Position = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3 = T.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = btn,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = indicator })

        -- Icon label
        local iconText = icon or string.upper(string.sub(name, 1, 2))
        local iconLabel = create("TextLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = iconText,
            TextColor3 = T.TabNormal,
            Font = FONT_BOLD,
            TextSize = 15,
            Parent = btn,
        })

        tabObj.button = btn
        tabObj.indicator = indicator
        tabObj.iconLabel = iconLabel

        -- Content page
        local page = create("Frame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = contentArea,
        })

        -- Left column (scrollable)
        local leftCol = create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -6, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.ScrollBar,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = page,
        })
        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = leftCol,
        })

        -- Right column (scrollable)
        local rightCol = create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -6, 1, -8),
            Position = UDim2.new(0.5, 2, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.ScrollBar,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = page,
        })
        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = rightCol,
        })

        tabObj.page = page
        tabObj.leftColumn = leftCol
        tabObj.rightColumn = rightCol
        tabObj._leftOrder = 0
        tabObj._rightOrder = 0

        -- Tab button hover/click
        btn.MouseEnter:Connect(function()
            if self.activeTab ~= tabObj then
                tween(btn, {BackgroundColor3 = T.SidebarHover}, 0.08)
                tween(iconLabel, {TextColor3 = T.TabHover}, 0.08)
            end
        end)
        btn.MouseLeave:Connect(function()
            if self.activeTab ~= tabObj then
                tween(btn, {BackgroundColor3 = T.SidebarBg}, 0.08)
                tween(iconLabel, {TextColor3 = T.TabNormal}, 0.08)
            end
        end)
        btn.MouseButton1Click:Connect(function()
            self:SelectTab(tabObj)
        end)

        table.insert(self.tabs, tabObj)

        -- Auto-select first tab
        if #self.tabs == 1 then
            self:SelectTab(tabObj)
        end

        -- ─── GROUP CREATION ───
        function tabObj:AddLeftGroup(name)
            self._leftOrder = self._leftOrder + 1
            return Library:_CreateGroup(name, leftCol, self._leftOrder)
        end

        function tabObj:AddRightGroup(name)
            self._rightOrder = self._rightOrder + 1
            return Library:_CreateGroup(name, rightCol, self._rightOrder)
        end

        return tabObj
    end

    function window:Destroy()
        for _, conn in pairs(Library._connections) do
            pcall(function() conn:Disconnect() end)
        end
        Library._connections = {}
        closeActivePopup()
        gui:Destroy()
        Library.ScreenGui = nil
    end

    return window
end

-- ═══════════════════════════════════════════
-- GROUP
-- ═══════════════════════════════════════════
function Library:_CreateGroup(name, column, order)
    local group = {}
    group._order = 0

    -- Group frame (auto-sizes vertically)
    local groupFrame = create("Frame", {
        Name = "Group_" .. name,
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        LayoutOrder = order,
        Parent = column,
    })

    -- Border (lime/olive green - signature GameSense look)
    create("UIStroke", {
        Color = T.GroupBorder,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = groupFrame,
    })

    -- Title label (breaks the top border - fieldset/legend style)
    create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 0, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 10, 0, -7),
        BackgroundColor3 = T.WindowBg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "  " .. name .. "  ",
        TextColor3 = T.GroupTitle,
        Font = FONT,
        TextSize = 12,
        ZIndex = 3,
        Parent = groupFrame,
    })

    -- Content container (elements go here)
    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -(GROUP_PAD_X * 2), 0, 0),
        Position = UDim2.new(0, GROUP_PAD_X, 0, GROUP_PAD_TOP),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = groupFrame,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, ELEMENT_PAD),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content,
    })

    -- Bottom spacer (padding below last element)
    create("Frame", {
        Name = "BottomPad",
        Size = UDim2.new(1, 0, 0, GROUP_PAD_BOT),
        BackgroundTransparency = 1,
        LayoutOrder = 99999,
        Parent = content,
    })

    group.frame = groupFrame
    group.content = content

    function group:_next()
        self._order = self._order + 1
        return self._order
    end

    -- ═══════════════════════════════════════
    -- CHECKBOX
    -- ═══════════════════════════════════════
    function group:AddCheckbox(cfg)
        local text = cfg.Text or "Checkbox"
        local default = cfg.Default or false
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local textColor = cfg.Color

        local elem = { Value = default }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Checkbox square
        local box = create("Frame", {
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(0, 0, 0.5, -6),
            BackgroundColor3 = default and T.Accent or T.CheckboxBg,
            BorderSizePixel = 0,
            Parent = frame,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = box })
        create("UIStroke", {
            Color = Color3.fromRGB(38, 38, 48),
            Thickness = 1,
            Parent = box,
        })

        -- Checkmark (small inner frame, visible when checked)
        local checkmark = create("Frame", {
            Size = UDim2.new(0, 7, 0, 7),
            Position = UDim2.new(0.5, -3, 0.5, -3),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = default and 0.15 or 1,
            BorderSizePixel = 0,
            Parent = box,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = checkmark })

        -- Label
        local label = create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = textColor or T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        -- Click area
        local clickBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 2,
            Parent = frame,
        })

        local function updateVisual()
            tween(box, { BackgroundColor3 = elem.Value and T.Accent or T.CheckboxBg }, 0.1)
            checkmark.BackgroundTransparency = elem.Value and 0.15 or 1
        end

        clickBtn.MouseButton1Click:Connect(function()
            elem.Value = not elem.Value
            updateVisual()
            callback(elem.Value)
        end)

        clickBtn.MouseEnter:Connect(function()
            if not elem.Value then
                tween(box, { BackgroundColor3 = T.CheckboxHover }, 0.08)
            end
        end)
        clickBtn.MouseLeave:Connect(function()
            if not elem.Value then
                tween(box, { BackgroundColor3 = T.CheckboxBg }, 0.08)
            end
        end)

        function elem:Set(val)
            self.Value = val
            updateVisual()
            callback(val)
        end
        function elem:Get() return self.Value end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- SLIDER
    -- ═══════════════════════════════════════
    function group:AddSlider(cfg)
        local text = cfg.Text or "Slider"
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local default = math.clamp(cfg.Default or min, min, max)
        local rounding = cfg.Rounding or 0
        local suffix = cfg.Suffix or "%"
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag

        local elem = { Value = default }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Label (left)
        create("TextLabel", {
            Size = UDim2.new(0.6, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        -- Value label (right)
        local valLabel = create("TextLabel", {
            Size = UDim2.new(0.4, 0, 0, 15),
            Position = UDim2.new(0.6, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default) .. suffix,
            TextColor3 = T.Accent,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = frame,
        })

        -- Bar background
        local barBg = create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 21),
            BackgroundColor3 = T.SliderBg,
            BorderSizePixel = 0,
            Parent = frame,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = barBg })

        -- Bar fill
        local pct = (default - min) / math.max(max - min, 0.001)
        local barFill = create("Frame", {
            Size = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = T.SliderFill,
            BorderSizePixel = 0,
            Parent = barBg,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = barFill })

        -- Interaction
        local sliderDragging = false

        local function updateSlider(inputX)
            local absX = barBg.AbsolutePosition.X
            local absW = barBg.AbsoluteSize.X
            local relX = math.clamp((inputX - absX) / math.max(absW, 1), 0, 1)

            local rawVal = min + (max - min) * relX
            if rounding == 0 then
                rawVal = math.floor(rawVal + 0.5)
            else
                local mult = 10 ^ rounding
                rawVal = math.floor(rawVal * mult + 0.5) / mult
            end
            rawVal = math.clamp(rawVal, min, max)

            elem.Value = rawVal
            local displayPct = (rawVal - min) / math.max(max - min, 0.001)
            barFill.Size = UDim2.new(displayPct, 0, 1, 0)
            valLabel.Text = tostring(rawVal) .. suffix
            callback(rawVal)
        end

        -- Click area over the bar
        local barClick = create("TextButton", {
            Size = UDim2.new(1, 6, 0, 14),
            Position = UDim2.new(0, -3, 0, 16),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 2,
            Parent = frame,
        })

        barClick.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderDragging = true
                updateSlider(input.Position.X)
            end
        end)
        barClick.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderDragging = false
            end
        end)

        addConnection(UserInputService.InputChanged:Connect(function(input)
            if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end))

        addConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliderDragging = false
            end
        end))

        function elem:Set(val)
            self.Value = math.clamp(val, min, max)
            local dp = (self.Value - min) / math.max(max - min, 0.001)
            barFill.Size = UDim2.new(dp, 0, 1, 0)
            valLabel.Text = tostring(self.Value) .. suffix
            callback(self.Value)
        end
        function elem:Get() return self.Value end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- DROPDOWN
    -- ═══════════════════════════════════════
    function group:AddDropdown(cfg)
        local text = cfg.Text or "Dropdown"
        local items = cfg.Items or {}
        local default = cfg.Default or (items[1] or "")
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag
        local multi = cfg.Multi or false

        local elem = { Value = multi and (cfg.Default or {}) or default, Open = false }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Label
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        -- Dropdown button
        local dropBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 16),
            BackgroundColor3 = T.DropdownBg,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = FONT,
            TextSize = 12,
            TextColor3 = T.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = frame,
        })
        create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = dropBtn })
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 20),
            Parent = dropBtn,
        })

        -- Arrow
        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = T.TextDim,
            Font = FONT,
            TextSize = 9,
            Parent = dropBtn,
        })

        local function getDisplayText()
            if multi then
                local sel = {}
                for _, item in ipairs(items) do
                    if elem.Value[item] then table.insert(sel, item) end
                end
                return #sel > 0 and table.concat(sel, ", ") or "None"
            else
                return tostring(elem.Value)
            end
        end
        dropBtn.Text = getDisplayText()

        -- Dropdown list (created/destroyed on open/close)
        local listFrame, catcher

        local function closeDrop()
            if listFrame then listFrame:Destroy(); listFrame = nil end
            if catcher then catcher:Destroy(); catcher = nil end
            elem.Open = false
            arrow.Text = "▼"
            if Library._popupClose == closeDrop then Library._popupClose = nil end
        end

        local function openDrop()
            closeActivePopup()
            elem.Open = true
            arrow.Text = "▲"
            Library._popupClose = closeDrop

            -- Full-screen click catcher
            catcher = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 100,
                Parent = Library.ScreenGui,
            })
            catcher.MouseButton1Click:Connect(closeDrop)

            local absPos = dropBtn.AbsolutePosition
            local absSize = dropBtn.AbsoluteSize
            local listH = math.min(#items * 20, 200)

            listFrame = create("Frame", {
                Size = UDim2.new(0, absSize.X, 0, listH),
                Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 1),
                BackgroundColor3 = T.DropdownBg,
                BorderSizePixel = 0,
                ZIndex = 101,
                ClipsDescendants = true,
                Parent = Library.ScreenGui,
            })
            create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = listFrame })

            local scroll = create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.ScrollBar,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 102,
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                Parent = listFrame,
            })
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
                Parent = scroll,
            })

            for i, item in ipairs(items) do
                local isSelected = multi and elem.Value[item] or (elem.Value == item)
                local itemBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = isSelected and T.DropdownHover or T.DropdownBg,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "  " .. item,
                    TextColor3 = isSelected and T.Accent or T.TextPrimary,
                    Font = FONT,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 103,
                    LayoutOrder = i,
                    Parent = scroll,
                })

                itemBtn.MouseEnter:Connect(function()
                    tween(itemBtn, { BackgroundColor3 = T.DropdownHover }, 0.06)
                end)
                itemBtn.MouseLeave:Connect(function()
                    local sel = multi and elem.Value[item] or (elem.Value == item)
                    tween(itemBtn, { BackgroundColor3 = sel and T.DropdownHover or T.DropdownBg }, 0.06)
                end)

                itemBtn.MouseButton1Click:Connect(function()
                    if multi then
                        elem.Value[item] = not elem.Value[item]
                        local sel = elem.Value[item]
                        itemBtn.BackgroundColor3 = sel and T.DropdownHover or T.DropdownBg
                        itemBtn.TextColor3 = sel and T.Accent or T.TextPrimary
                        dropBtn.Text = getDisplayText()
                        callback(elem.Value)
                    else
                        elem.Value = item
                        dropBtn.Text = getDisplayText()
                        callback(item)
                        closeDrop()
                    end
                end)
            end
        end

        dropBtn.MouseButton1Click:Connect(function()
            if elem.Open then closeDrop() else openDrop() end
        end)

        dropBtn.MouseEnter:Connect(function()
            tween(dropBtn, { BackgroundColor3 = T.DropdownHover }, 0.08)
        end)
        dropBtn.MouseLeave:Connect(function()
            tween(dropBtn, { BackgroundColor3 = T.DropdownBg }, 0.08)
        end)

        function elem:Set(val)
            self.Value = val
            dropBtn.Text = getDisplayText()
            callback(val)
        end
        function elem:Get() return self.Value end
        function elem:SetItems(newItems)
            items = newItems
            if self.Open then closeDrop() end
        end
        function elem:Refresh()
            dropBtn.Text = getDisplayText()
        end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- BUTTON
    -- ═══════════════════════════════════════
    function group:AddButton(cfg)
        local text = cfg.Text or "Button"
        local callback = cfg.Callback or function() end

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 1),
            BackgroundColor3 = T.ButtonBg,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            Parent = frame,
        })
        create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = btn })

        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = T.ButtonHover }, 0.08)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = T.ButtonBg }, 0.08)
        end)
        btn.MouseButton1Click:Connect(function()
            -- Click flash
            btn.BackgroundColor3 = T.Accent
            btn.TextColor3 = Color3.new(1, 1, 1)
            task.delay(0.12, function()
                tween(btn, { BackgroundColor3 = T.ButtonBg, TextColor3 = T.TextPrimary }, 0.12)
            end)
            callback()
        end)

        return {}
    end

    -- ═══════════════════════════════════════
    -- KEYBIND
    -- ═══════════════════════════════════════
    function group:AddKeybind(cfg)
        local text = cfg.Text or "Hotkey"
        local default = cfg.Default or Enum.KeyCode.Unknown
        local callback = cfg.Callback or function() end
        local changedCallback = cfg.ChangedCallback or function() end
        local flag = cfg.Flag

        local elem = { Value = default, Listening = false }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Label
        create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        local function keyName(key)
            if key == Enum.KeyCode.Unknown then return "[-]" end
            local n = key.Name
            -- Shorten common names
            local shorts = {
                LeftShift = "LSh", RightShift = "RSh",
                LeftControl = "LCt", RightControl = "RCt",
                LeftAlt = "LAl", RightAlt = "RAl",
                MouseButton1 = "M1", MouseButton2 = "M2",
                MouseButton3 = "M3", Backspace = "Bks",
                CapsLock = "Cap", Delete = "Del", Insert = "Ins",
            }
            n = shorts[n] or n
            if #n > 4 then n = string.sub(n, 1, 3) end
            return "[" .. n .. "]"
        end

        -- Key button
        local keyBtn = create("TextButton", {
            Size = UDim2.new(0, 42, 0, 16),
            Position = UDim2.new(1, -42, 0.5, -8),
            BackgroundColor3 = T.DropdownBg,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = keyName(default),
            TextColor3 = T.TextDim,
            Font = FONT,
            TextSize = SMALL_TEXT,
            Parent = frame,
        })
        create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = keyBtn })

        keyBtn.MouseButton1Click:Connect(function()
            elem.Listening = true
            keyBtn.Text = "[...]"
            keyBtn.TextColor3 = T.Accent
        end)

        addConnection(UserInputService.InputBegan:Connect(function(input, processed)
            if not elem.Listening then
                -- Check if bound key is pressed
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == elem.Value then
                    callback(elem.Value)
                end
                return
            end

            if input.UserInputType == Enum.UserInputType.Keyboard then
                elem.Listening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    elem.Value = Enum.KeyCode.Unknown
                else
                    elem.Value = input.KeyCode
                end
                keyBtn.Text = keyName(elem.Value)
                keyBtn.TextColor3 = T.TextDim
                changedCallback(elem.Value)
            end
        end))

        function elem:Set(key)
            self.Value = key
            keyBtn.Text = keyName(key)
            changedCallback(key)
        end
        function elem:Get() return self.Value end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- COLOR PICKER
    -- ═══════════════════════════════════════
    function group:AddColorPicker(cfg)
        local text = cfg.Text or "Color"
        local default = cfg.Default or Color3.new(0, 0, 0)
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag

        local h, s, v = Color3.toHSV(default)
        local elem = { Value = default, H = h, S = s, V = v, Open = false }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Label
        create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        -- Color swatch button
        local swatch = create("TextButton", {
            Size = UDim2.new(0, 26, 0, 13),
            Position = UDim2.new(1, -26, 0.5, -6),
            BackgroundColor3 = default,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Parent = frame,
        })
        create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = swatch })
        create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = swatch })

        -- Popup
        local popup, catcherFrame, moveConn

        local function closeCP()
            if popup then popup:Destroy(); popup = nil end
            if catcherFrame then catcherFrame:Destroy(); catcherFrame = nil end
            if moveConn then moveConn:Disconnect(); moveConn = nil end
            elem.Open = false
            if Library._popupClose == closeCP then Library._popupClose = nil end
        end

        local function openCP()
            closeActivePopup()
            elem.Open = true
            Library._popupClose = closeCP

            -- Click catcher
            catcherFrame = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 100,
                Parent = Library.ScreenGui,
            })
            catcherFrame.MouseButton1Click:Connect(closeCP)

            local swPos = swatch.AbsolutePosition

            popup = create("Frame", {
                Size = UDim2.new(0, 200, 0, 170),
                Position = UDim2.new(0, swPos.X - 174, 0, swPos.Y + 18),
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BorderSizePixel = 0,
                ZIndex = 101,
                Parent = Library.ScreenGui,
            })
            create("UIStroke", { Color = T.DropdownBorder, Thickness = 1, Parent = popup })
            create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = popup })

            -- SV Area (140 x 140)
            local svArea = create("Frame", {
                Size = UDim2.new(0, 140, 0, 140),
                Position = UDim2.new(0, 8, 0, 8),
                BackgroundColor3 = Color3.fromHSV(elem.H, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 102,
                ClipsDescendants = true,
                Parent = popup,
            })

            -- White gradient (saturation: left white → right color)
            local whiteLayer = create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 103,
                Parent = svArea,
            })
            create("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = whiteLayer,
            })

            -- Black gradient (value: top bright → bottom dark)
            local blackLayer = create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 104,
                Parent = svArea,
            })
            create("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Rotation = 90,
                Parent = blackLayer,
            })

            -- SV Cursor
            local svCursor = create("Frame", {
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(elem.S, -4, 1 - elem.V, -4),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 106,
                Parent = svArea,
            })
            create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
            create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = svCursor })

            -- Hue Bar (vertical, 20px wide)
            local hueBar = create("Frame", {
                Size = UDim2.new(0, 20, 0, 140),
                Position = UDim2.new(0, 160, 0, 8),
                BorderSizePixel = 0,
                ZIndex = 102,
                ClipsDescendants = true,
                BackgroundColor3 = Color3.new(1, 0, 0),
                Parent = popup,
            })
            create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.000, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                    ColorSequenceKeypoint.new(0.500, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                    ColorSequenceKeypoint.new(1.000, Color3.fromHSV(0.999, 1, 1)),
                }),
                Rotation = 90,
                Parent = hueBar,
            })

            -- Hue cursor
            local hueCursor = create("Frame", {
                Size = UDim2.new(1, 4, 0, 4),
                Position = UDim2.new(0, -2, elem.H, -2),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 106,
                Parent = hueBar,
            })
            create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Parent = hueCursor })

            -- Preview swatch in popup
            local preview = create("Frame", {
                Size = UDim2.new(0, 20, 0, 12),
                Position = UDim2.new(0, 160, 0, 155),
                BackgroundColor3 = elem.Value,
                BorderSizePixel = 0,
                ZIndex = 102,
                Parent = popup,
            })
            create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = preview })

            -- Interaction
            local svDrag, hueDrag = false, false

            local function updateColor()
                elem.Value = Color3.fromHSV(elem.H, elem.S, elem.V)
                swatch.BackgroundColor3 = elem.Value
                svArea.BackgroundColor3 = Color3.fromHSV(elem.H, 1, 1)
                svCursor.Position = UDim2.new(elem.S, -4, 1 - elem.V, -4)
                hueCursor.Position = UDim2.new(0, -2, elem.H, -2)
                preview.BackgroundColor3 = elem.Value
                callback(elem.Value)
            end

            -- SV interaction area
            local svBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 105,
                Parent = svArea,
            })
            svBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDrag = true
                    local rx = math.clamp((input.Position.X - svArea.AbsolutePosition.X) / svArea.AbsoluteSize.X, 0, 1)
                    local ry = math.clamp((input.Position.Y - svArea.AbsolutePosition.Y) / svArea.AbsoluteSize.Y, 0, 1)
                    elem.S = rx
                    elem.V = 1 - ry
                    updateColor()
                end
            end)
            svBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDrag = false
                end
            end)

            -- Hue interaction area
            local hueBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 105,
                Parent = hueBar,
            })
            hueBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = true
                    local ry = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
                    elem.H = ry
                    updateColor()
                end
            end)
            hueBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = false
                end
            end)

            moveConn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if svDrag then
                    local rx = math.clamp((input.Position.X - svArea.AbsolutePosition.X) / svArea.AbsoluteSize.X, 0, 1)
                    local ry = math.clamp((input.Position.Y - svArea.AbsolutePosition.Y) / svArea.AbsoluteSize.Y, 0, 1)
                    elem.S = rx
                    elem.V = 1 - ry
                    updateColor()
                end
                if hueDrag then
                    local ry = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
                    elem.H = ry
                    updateColor()
                end
            end)
        end

        swatch.MouseButton1Click:Connect(function()
            if elem.Open then closeCP() else openCP() end
        end)

        function elem:Set(color)
            self.Value = color
            self.H, self.S, self.V = Color3.toHSV(color)
            swatch.BackgroundColor3 = color
            callback(color)
        end
        function elem:Get() return self.Value end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- TEXTBOX
    -- ═══════════════════════════════════════
    function group:AddTextbox(cfg)
        local text = cfg.Text or "Text field"
        local default = cfg.Default or ""
        local placeholder = cfg.Placeholder or ""
        local callback = cfg.Callback or function() end
        local flag = cfg.Flag

        local elem = { Value = default }

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        -- Label
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = T.TextPrimary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })

        -- Input frame
        local inputFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 16),
            BackgroundColor3 = T.InputBg,
            BorderSizePixel = 0,
            Parent = frame,
        })
        local inputStroke = create("UIStroke", {
            Color = T.InputBorder,
            Thickness = 1,
            Parent = inputFrame,
        })

        local textBox = create("TextBox", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Font = FONT,
            TextSize = 12,
            Text = default,
            TextColor3 = T.TextPrimary,
            PlaceholderText = placeholder,
            PlaceholderColor3 = T.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = inputFrame,
        })

        textBox.Focused:Connect(function()
            tween(inputStroke, { Color = T.Accent }, 0.1)
        end)
        textBox.FocusLost:Connect(function(enter)
            tween(inputStroke, { Color = T.InputBorder }, 0.1)
            elem.Value = textBox.Text
            callback(textBox.Text)
        end)

        function elem:Set(val)
            self.Value = val
            textBox.Text = val
            callback(val)
        end
        function elem:Get() return self.Value end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- LISTBOX
    -- ═══════════════════════════════════════
    function group:AddListbox(cfg)
        local text = cfg.Text or ""
        local items = cfg.Items or {}
        local default = cfg.Default
        local callback = cfg.Callback or function() end
        local height = cfg.Height or 150
        local flag = cfg.Flag

        local elem = { Value = default }

        local totalH = height + (text ~= "" and 16 or 0)
        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, totalH),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        local yOff = 0
        if text ~= "" then
            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = T.TextPrimary,
                Font = FONT,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            yOff = 16
        end

        local listScroll = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, height),
            Position = UDim2.new(0, 0, 0, yOff),
            BackgroundColor3 = T.ListBg,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.ScrollBar,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = frame,
        })
        create("UIStroke", { Color = T.InputBorder, Thickness = 1, Parent = listScroll })
        create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
            Parent = listScroll,
        })

        local itemBtns = {}

        local function buildList()
            for _, b in pairs(itemBtns) do b:Destroy() end
            itemBtns = {}

            for i, item in ipairs(items) do
                local isSel = (tostring(item) == tostring(elem.Value))
                local itemBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = isSel and T.ListSelected or T.ListBg,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "   " .. tostring(item),
                    TextColor3 = isSel and T.Accent or T.TextPrimary,
                    Font = FONT,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = i,
                    Parent = listScroll,
                })

                itemBtn.MouseEnter:Connect(function()
                    if tostring(item) ~= tostring(elem.Value) then
                        tween(itemBtn, { BackgroundColor3 = T.ListHover }, 0.06)
                    end
                end)
                itemBtn.MouseLeave:Connect(function()
                    if tostring(item) ~= tostring(elem.Value) then
                        tween(itemBtn, { BackgroundColor3 = T.ListBg }, 0.06)
                    end
                end)

                itemBtn.MouseButton1Click:Connect(function()
                    -- Deselect all
                    for _, b in pairs(itemBtns) do
                        b.BackgroundColor3 = T.ListBg
                        b.TextColor3 = T.TextPrimary
                    end
                    elem.Value = item
                    itemBtn.BackgroundColor3 = T.ListSelected
                    itemBtn.TextColor3 = T.Accent
                    callback(item)
                end)

                table.insert(itemBtns, itemBtn)
            end
        end
        buildList()

        function elem:Set(val)
            self.Value = val
            buildList()
            callback(val)
        end
        function elem:Get() return self.Value end
        function elem:SetItems(newItems)
            items = newItems
            buildList()
        end

        if flag then Library.Flags[flag] = elem end
        return elem
    end

    -- ═══════════════════════════════════════
    -- LABEL
    -- ═══════════════════════════════════════
    function group:AddLabel(text, color)
        local lbl = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = color or T.TextSecondary,
            Font = FONT,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self:_next(),
            Parent = content,
        })

        local elem = {}
        function elem:Set(newText) lbl.Text = newText end
        function elem:SetColor(c) lbl.TextColor3 = c end
        return elem
    end

    -- ═══════════════════════════════════════
    -- SEPARATOR
    -- ═══════════════════════════════════════
    function group:AddSeparator()
        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 8),
            BackgroundTransparency = 1,
            LayoutOrder = self:_next(),
            Parent = content,
        })
        create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.Separator,
            BorderSizePixel = 0,
            Parent = frame,
        })
        return {}
    end

    -- ═══════════════════════════════════════
    -- MULTI DROPDOWN (convenience alias)
    -- ═══════════════════════════════════════
    function group:AddMultiDropdown(cfg)
        cfg.Multi = true
        return self:AddDropdown(cfg)
    end

    return group
end

-- ═══════════════════════════════════════════
-- LIBRARY UTILITIES
-- ═══════════════════════════════════════════
function Library:SetToggleKey(key)
    Library.ToggleKey = key
end

function Library:GetFlag(flag)
    local f = Library.Flags[flag]
    if f then return f:Get() end
    return nil
end

function Library:Destroy()
    for _, conn in pairs(Library._connections) do
        pcall(function() conn:Disconnect() end)
    end
    Library._connections = {}
    closeActivePopup()
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
        Library.ScreenGui = nil
    end
end

-- ═══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════
function Library:Notify(text, duration)
    duration = duration or 3

    if not Library.ScreenGui then return end

    local notif = create("Frame", {
        Size = UDim2.new(0, 280, 0, 36),
        Position = UDim2.new(1, 0, 1, -50),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = Library.ScreenGui,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = notif })
    create("UIStroke", { Color = T.Accent, Thickness = 1, Parent = notif })

    -- Accent bar on left
    create("Frame", {
        Size = UDim2.new(0, 3, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 201,
        Parent = notif,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = notif:FindFirstChild("Frame") })

    create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = T.TextPrimary,
        Font = FONT,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 201,
        Parent = notif,
    })

    -- Slide in
    tween(notif, { Position = UDim2.new(1, -290, 1, -50) }, 0.25, Enum.EasingStyle.Back)

    -- Auto dismiss
    task.delay(duration, function()
        local tw = tween(notif, { Position = UDim2.new(1, 10, 1, -50) }, 0.2)
        tw.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

return Library
