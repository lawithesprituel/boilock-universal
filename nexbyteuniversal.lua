if _G.WraithsenseLoaded then
    warn("Wraithsense already running!")
    return
end
_G.WraithsenseLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer


local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local function safeLoad(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok then return result end
    warn("safeLoad failed: " .. tostring(url) .. " | " .. tostring(result))
    return nil
end





-- ==========================================================================
--  1000x Ultra-Premium Key Authentication System
-- ==========================================================================
local Library, ThemeManager, SaveManager

do
    local TweenService     = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local ContextAction    = game:GetService("ContextActionService")
    local Lighting         = game:GetService("Lighting")
    local SoundService     = game:GetService("SoundService")
    local Players          = game:GetService("Players")
    local HttpService      = game:GetService("HttpService")

    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")
    local parentGui = (gethui and gethui()) or (syn and syn.protect_gui and pg) or game:GetService("CoreGui")

    local JUNKIE_SERVICE_ID   = "1169689"
    local JUNKIE_SERVICE_NAME = "Nexbyte Loader"
    local JUNKIE_PROVIDER     = "Loader"
    local JUNKIE_API_KEY      = "e7d95baf-4120-48e3-a7ae-5798585429a3"
    local JUNKIE_ALT_KEY      = "NEXBYTEPLUS-6ff0090f-eeff-4488-bb58-aeb02456d5a6"
    local JUNKIE_ADMIN_KEY    = "NEXBYTEPLUS-2929"

    -- Color Palette
    local PINK_ACCENT  = Color3.fromRGB(232, 97, 154)
    local PURPLE_GRAD  = Color3.fromRGB(160, 80, 220)
    local DARK_BG      = Color3.fromRGB(12, 9, 18)
    local HEADER_BG    = Color3.fromRGB(18, 13, 26)
    local INPUT_BG     = Color3.fromRGB(22, 16, 32)
    local TEXT_LIGHT   = Color3.fromRGB(240, 235, 245)
    local TEXT_MUTED   = Color3.fromRGB(140, 125, 150)
    local SUCCESS_GRN  = Color3.fromRGB(80, 240, 140)
    local ERROR_RED    = Color3.fromRGB(255, 80, 100)

    -- 1) Background Blur Effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    TweenService:Create(blur, TweenInfo.new(0.5), { Size = 20 }):Play()

    -- Junkie SDK loader
    local JunkieSDK = nil
    pcall(function()
        local sdk = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
        if sdk then
            JunkieSDK = sdk
            sdk.service = JUNKIE_SERVICE_NAME
            sdk.identifier = JUNKIE_SERVICE_ID
            sdk.provider = JUNKIE_PROVIDER
            sdk.apiKey = JUNKIE_API_KEY
            sdk.api_key = JUNKIE_API_KEY
        end
    end)

    local function verifyJunkieKey(inputKey)
        if not inputKey or inputKey:gsub("%s+", "") == "" then
            return false, "Please enter a key."
        end

        local trimmedKey = inputKey:gsub("%s+", "")

        -- Admin & Forever API Keys Check
        if trimmedKey == JUNKIE_API_KEY or trimmedKey == JUNKIE_ALT_KEY or trimmedKey == JUNKIE_ADMIN_KEY then
            getgenv().SCRIPT_KEY = trimmedKey
            return true, "Authenticated with Admin / Master Key!"
        end

        -- Junkie SDK Check
        if JunkieSDK and typeof(JunkieSDK.check_key) == "function" then
            local sdkOk, res = pcall(function() return JunkieSDK.check_key(trimmedKey) end)
            if sdkOk and res then
                if type(res) == "table" and (res.valid == true or res.status == true or res.message == "KEY_VALID" or res.message == "KEYLESS") then
                    getgenv().SCRIPT_KEY = trimmedKey
                    return true, "Validated via Junkie API!"
                elseif res == true then
                    getgenv().SCRIPT_KEY = trimmedKey
                    return true, "Validated via Junkie API!"
                end
            end
        end

        -- Junkie HTTP REST API Check
        local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if requestFunc then
            local endpoints = {
                "https://api.jnkie.com/api/v1/services/" .. JUNKIE_SERVICE_ID .. "/verifyKey",
                "https://api.junkie-development.de/api/v1/services/" .. JUNKIE_SERVICE_ID .. "/verifyKey",
                "https://jnkie.com/api/v1/keys/verify"
            }
            for _, url in ipairs(endpoints) do
                local reqOk, resp = pcall(function()
                    return requestFunc({
                        Url = url, Method = "POST",
                        Headers = { ["Content-Type"] = "application/json", ["x-api-key"] = JUNKIE_API_KEY },
                        Body = HttpService:JSONEncode({ key = trimmedKey, service = JUNKIE_SERVICE_ID, api_key = JUNKIE_API_KEY })
                    })
                end)
                if reqOk and resp and resp.Body then
                    local decodeOk, jsonRes = pcall(function() return HttpService:JSONDecode(resp.Body) end)
                    if decodeOk and jsonRes and (jsonRes.valid == true or jsonRes.success == true or jsonRes.status == "success" or jsonRes.status == true) then
                        getgenv().SCRIPT_KEY = trimmedKey
                        return true, "Validated via Junkie API!"
                    end
                end
            end
        end

        -- Junkie HttpGet Fallback
        local getOk, getRes = pcall(function()
            return game:HttpGet("https://api.jnkie.com/api/v1/verify?service=" .. JUNKIE_SERVICE_ID .. "&key=" .. HttpService:UrlEncode(trimmedKey) .. "&apiKey=" .. JUNKIE_API_KEY)
        end)
        if getOk and getRes then
            local decodeOk, jsonRes = pcall(function() return HttpService:JSONDecode(getRes) end)
            if decodeOk and jsonRes and (jsonRes.valid == true or jsonRes.success == true) then
                getgenv().SCRIPT_KEY = trimmedKey
                return true, "Validated via Junkie API!"
            end
        end

        return false, "Invalid key! Check your key or try again."
    end

    -- 2) Build Key GUI
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "WraithKeyGUI"
    keyGui.ResetOnSpawn = false
    keyGui.AutoLocalize = false
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    if syn and syn.protect_gui then syn.protect_gui(keyGui) end
    pcall(function() keyGui.Parent = parentGui end)
    if not keyGui.Parent then keyGui.Parent = pg end

    -- Main Centered Container
    local mainFrame = Instance.new("Frame", keyGui)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 480, 0, 270)
    mainFrame.BackgroundColor3 = DARK_BG
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    -- Glowing Border Stroke
    local outerStroke = Instance.new("UIStroke", mainFrame)
    outerStroke.Color = PINK_ACCENT
    outerStroke.Thickness = 1.5
    outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local strokeGrad = Instance.new("UIGradient", outerStroke)
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, PINK_ACCENT),
        ColorSequenceKeypoint.new(0.5, PURPLE_GRAD),
        ColorSequenceKeypoint.new(1.0, PINK_ACCENT)
    })

    -- Rotating Stroke Gradient Animation
    task.spawn(function()
        local rot = 0
        while mainFrame and mainFrame.Parent do
            rot = (rot + 1) % 360
            strokeGrad.Rotation = rot
            task.wait(0.03)
        end
    end)

    -- Header Frame
    local headerFrame = Instance.new("Frame", mainFrame)
    headerFrame.Size = UDim2.new(1, 0, 0, 56)
    headerFrame.BackgroundColor3 = HEADER_BG
    headerFrame.BorderSizePixel = 0
    Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 10)

    local hCornerFix = Instance.new("Frame", headerFrame)
    hCornerFix.Size = UDim2.new(1, 0, 0, 12)
    hCornerFix.Position = UDim2.new(0, 0, 1, -12)
    hCornerFix.BackgroundColor3 = HEADER_BG
    hCornerFix.BorderSizePixel = 0

    -- Header Logo
    local logoIcon = Instance.new("ImageLabel", headerFrame)
    logoIcon.Size = UDim2.new(0, 32, 0, 32)
    logoIcon.Position = UDim2.new(0, 16, 0.5, -16)
    logoIcon.BackgroundTransparency = 1
    logoIcon.ScaleType = Enum.ScaleType.Fit
    logoIcon.Image = "rbxthumb://type=Asset&id=108077329495242&w=150&h=150"

    -- Header Title
    local titleLabel = Instance.new("TextLabel", headerFrame)
    titleLabel.Size = UDim2.new(0, 200, 0, 24)
    titleLabel.Position = UDim2.new(0, 56, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.AutoLocalize = false
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Text = "WRAITHSENSE"
    titleLabel.TextColor3 = TEXT_LIGHT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local titleGrad = Instance.new("UIGradient", titleLabel)
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 170, 210)),
        ColorSequenceKeypoint.new(1.0, PINK_ACCENT)
    })

    -- Header Subtitle
    local subLabel = Instance.new("TextLabel", headerFrame)
    subLabel.Size = UDim2.new(0, 200, 0, 16)
    subLabel.Position = UDim2.new(0, 56, 0, 32)
    subLabel.BackgroundTransparency = 1
    subLabel.AutoLocalize = false
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 11
    subLabel.Text = "Junkie Key System"
    subLabel.TextColor3 = TEXT_MUTED
    subLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Header Divider Line
    local hLine = Instance.new("Frame", mainFrame)
    hLine.Size = UDim2.new(1, -32, 0, 1)
    hLine.Position = UDim2.new(0, 16, 0, 56)
    hLine.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    hLine.BorderSizePixel = 0

    -- Input Section Box
    local inputContainer = Instance.new("Frame", mainFrame)
    inputContainer.Size = UDim2.new(1, -32, 0, 44)
    inputContainer.Position = UDim2.new(0, 16, 0, 74)
    inputContainer.BackgroundColor3 = INPUT_BG
    inputContainer.BorderSizePixel = 0
    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 6)

    local inputStroke = Instance.new("UIStroke", inputContainer)
    inputStroke.Color = Color3.fromRGB(50, 36, 68)
    inputStroke.Thickness = 1

    local textBox = Instance.new("TextBox", inputContainer)
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.AutoLocalize = false
    textBox.Font = Enum.Font.Code
    textBox.TextSize = 14
    textBox.Text = ""
    textBox.PlaceholderText = "Paste access key here..."
    textBox.TextColor3 = TEXT_LIGHT
    textBox.PlaceholderColor3 = Color3.fromRGB(110, 95, 125)
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false

    textBox.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = PINK_ACCENT }):Play()
    end)
    textBox.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(50, 36, 68) }):Play()
    end)

    -- Status Label
    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(1, -32, 0, 20)
    statusLabel.Position = UDim2.new(0, 16, 0, 126)
    statusLabel.BackgroundTransparency = 1
    statusLabel.AutoLocalize = false
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Text = "Please enter your key to unlock Wraithsense"
    statusLabel.TextColor3 = TEXT_MUTED
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Buttons Area
    local btnContainer = Instance.new("Frame", mainFrame)
    btnContainer.Size = UDim2.new(1, -32, 0, 42)
    btnContainer.Position = UDim2.new(0, 16, 0, 154)
    btnContainer.BackgroundTransparency = 1

    -- 1) AUTHENTICATE Button
    local authBtn = Instance.new("TextButton", btnContainer)
    authBtn.Size = UDim2.new(0, 200, 1, 0)
    authBtn.Position = UDim2.new(0, 0, 0, 0)
    authBtn.BackgroundColor3 = PINK_ACCENT
    authBtn.BorderSizePixel = 0
    authBtn.AutoLocalize = false
    authBtn.Font = Enum.Font.GothamBold
    authBtn.TextSize = 13
    authBtn.Text = "AUTHENTICATE"
    authBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    authBtn.AutoButtonColor = false
    Instance.new("UICorner", authBtn).CornerRadius = UDim.new(0, 6)

    local authGrad = Instance.new("UIGradient", authBtn)
    authGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(240, 110, 170)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(180, 60, 150))
    })

    -- 2) GET KEY Button
    local getKeyBtn = Instance.new("TextButton", btnContainer)
    getKeyBtn.Size = UDim2.new(0, 114, 1, 0)
    getKeyBtn.Position = UDim2.new(0, 212, 0, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(24, 17, 36)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.AutoLocalize = false
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 12
    getKeyBtn.Text = "GET KEY"
    getKeyBtn.TextColor3 = PINK_ACCENT
    getKeyBtn.AutoButtonColor = false
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)

    local gkStroke = Instance.new("UIStroke", getKeyBtn)
    gkStroke.Color = Color3.fromRGB(60, 42, 80)
    gkStroke.Thickness = 1

    -- 3) DISCORD Button
    local discordBtn = Instance.new("TextButton", btnContainer)
    discordBtn.Size = UDim2.new(0, 112, 1, 0)
    discordBtn.Position = UDim2.new(0, 336, 0, 0)
    discordBtn.BackgroundColor3 = Color3.fromRGB(24, 17, 36)
    discordBtn.BorderSizePixel = 0
    discordBtn.AutoLocalize = false
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 12
    discordBtn.Text = "DISCORD"
    discordBtn.TextColor3 = Color3.fromRGB(114, 137, 218)
    discordBtn.AutoButtonColor = false
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 6)

    local dcStroke = Instance.new("UIStroke", discordBtn)
    dcStroke.Color = Color3.fromRGB(50, 60, 100)
    dcStroke.Thickness = 1

    -- Button Hover Animations
    authBtn.MouseEnter:Connect(function()
        TweenService:Create(authBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 125, 185) }):Play()
    end)
    authBtn.MouseLeave:Connect(function()
        TweenService:Create(authBtn, TweenInfo.new(0.15), { BackgroundColor3 = PINK_ACCENT }):Play()
    end)

    getKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(38, 26, 56) }):Play()
        TweenService:Create(gkStroke, TweenInfo.new(0.15), { Color = PINK_ACCENT }):Play()
    end)
    getKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(24, 17, 36) }):Play()
        TweenService:Create(gkStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(60, 42, 80) }):Play()
    end)

    discordBtn.MouseEnter:Connect(function()
        TweenService:Create(discordBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(32, 38, 65) }):Play()
        TweenService:Create(dcStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(114, 137, 218) }):Play()
    end)
    discordBtn.MouseLeave:Connect(function()
        TweenService:Create(discordBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(24, 17, 36) }):Play()
        TweenService:Create(dcStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 60, 100) }):Play()
    end)

    -- Footer info
    local footerLabel = Instance.new("TextLabel", mainFrame)
    footerLabel.Size = UDim2.new(1, -32, 0, 16)
    footerLabel.Position = UDim2.new(0, 16, 0, 206)
    footerLabel.BackgroundTransparency = 1
    footerLabel.AutoLocalize = false
    footerLabel.Font = Enum.Font.Code
    footerLabel.TextSize = 10
    footerLabel.Text = "Wraithsense Alpha • Protection Powered by Junkie"
    footerLabel.TextColor3 = Color3.fromRGB(80, 70, 95)
    footerLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Pop-In Entrance Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 480, 0, 236)
    }):Play()

    -- Shake Animation on Error
    local function shakeUI()
        local orig = mainFrame.Position
        for i = 1, 6 do
            mainFrame.Position = orig + UDim2.new(0, (i % 2 == 0) and 8 or -8, 0, 0)
            task.wait(0.04)
        end
        mainFrame.Position = orig
    end

    local authenticated = false
    local isSubmitting = false

    local function trySubmit()
        if isSubmitting or authenticated then return end
        isSubmitting = true

        local key = textBox.Text
        statusLabel.TextColor3 = Color3.fromRGB(230, 190, 90)
        statusLabel.Text = "Authenticating key..."

        task.spawn(function()
            local success, msg = verifyJunkieKey(key)
            if success then
                authenticated = true
                outerStroke.Color = SUCCESS_GRN
                authBtn.BackgroundColor3 = SUCCESS_GRN
                authBtn.Text = "ACCESS GRANTED"
                statusLabel.TextColor3 = SUCCESS_GRN
                statusLabel.Text = msg or "Welcome to Wraithsense!"
                
                task.wait(0.8)
                TweenService:Create(blur, TweenInfo.new(0.4), { Size = 0 }):Play()
                TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
                task.wait(0.45)
                pcall(function() blur:Destroy() end)
                pcall(function() keyGui:Destroy() end)
            else
                statusLabel.TextColor3 = ERROR_RED
                statusLabel.Text = msg or "Invalid Key! Please try again."
                inputStroke.Color = ERROR_RED
                task.spawn(shakeUI)
                task.delay(1.8, function()
                    inputStroke.Color = Color3.fromRGB(50, 36, 68)
                    statusLabel.TextColor3 = TEXT_MUTED
                    statusLabel.Text = "Please enter your key to unlock Wraithsense"
                end)
                textBox.Text = ""
                textBox:CaptureFocus()
            end
            isSubmitting = false
        end)
    end

    authBtn.Activated:Connect(trySubmit)
    textBox.FocusLost:Connect(function(enter)
        if enter then trySubmit() end
    end)

    local function getJunkieKeyLink()
        local link = nil
        if JunkieSDK then
            pcall(function()
                if typeof(JunkieSDK.get_key_link) == "function" then
                    link = JunkieSDK.get_key_link()
                elseif typeof(JunkieSDK.getKeyLink) == "function" then
                    link = JunkieSDK.getKeyLink()
                elseif typeof(JunkieSDK.get_key_url) == "function" then
                    link = JunkieSDK.get_key_url()
                elseif type(JunkieSDK.key_link) == "string" then
                    link = JunkieSDK.key_link
                end
            end)
        end

        -- Filter out any invalid or discord fallback links
        if not link or type(link) ~= "string" or #link == 0 or link:lower():find("discord") then
            link = "https://jnkie.com/getkey/" .. JUNKIE_SERVICE_ID
        end

        return link
    end

    getKeyBtn.Activated:Connect(function()
        local getLink = getJunkieKeyLink()
        if setclipboard then setclipboard(getLink)
        elseif toclipboard then toclipboard(getLink)
        elseif set_clipboard then set_clipboard(getLink) end
        
        local origText = getKeyBtn.Text
        getKeyBtn.Text = "COPIED LINK!"
        getKeyBtn.TextColor3 = SUCCESS_GRN
        task.delay(1.5, function()
            getKeyBtn.Text = origText
            getKeyBtn.TextColor3 = PINK_ACCENT
        end)
    end)

    discordBtn.Activated:Connect(function()
        local dcLink = "https://discord.gg/5bphTHsGjM"
        if setclipboard then setclipboard(dcLink)
        elseif toclipboard then toclipboard(dcLink)
        elseif set_clipboard then set_clipboard(dcLink) end
        
        local origText = discordBtn.Text
        discordBtn.Text = "COPIED DISCORD!"
        discordBtn.TextColor3 = SUCCESS_GRN
        task.delay(1.5, function()
            discordBtn.Text = origText
            discordBtn.TextColor3 = Color3.fromRGB(114, 137, 218)
        end)
    end)

    -- Block player movement while key GUI is open
    local BLOCK_ACTION = "WraithKeyBlock"
    ContextAction:BindActionAtPriority(BLOCK_ACTION, function()
        return Enum.ContextActionResult.Sink
    end, false, 3000,
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl
    )

    textBox:CaptureFocus()

    while not authenticated do
        task.wait(0.1)
    end
    ContextAction:UnbindAction(BLOCK_ACTION)
end

-- Load core modules after key validation
local Library = safeLoad(repo .. 'Library.lua')
local ThemeManager = safeLoad(repo .. 'addons/ThemeManager.lua')
local SaveManager = safeLoad(repo .. 'addons/SaveManager.lua')

local Window = Library:CreateWindow({
    Title = 'Wraithsense Alpha',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Player = Window:AddTab('Player'),
    Combat = Window:AddTab('Combat'),
    Rage = Window:AddTab('Rage'),
    Visuals = Window:AddTab('Visuals'),
    World = Window:AddTab('World'),
    Utility = Window:AddTab('Utility'),
    Anti = Window:AddTab('Anti'),
    Misc = Window:AddTab('Misc')
}

local thirdPersonEnabled = false
local thirdPersonDistance = 15
local originalCameraMode

local spinbotEnabled = false
local spinbotSpeed = 10

local orbitEnabled = false
local orbitSpeed = 5
local orbitRadius = 10
local orbitHeight = 0
local orbitAngle = 0
local orbitTarget = nil
local orbitTargetName = "Closest"
local orbitTeamCheck = false

local flyEnabled = false
local flySpeed = 50
local flyMethod = "BodyVelocity"
local flyBodyVelocity
local flyBodyGyro

local walkSpeedEnabled = false
local walkSpeedValue = 16
local jumpPowerEnabled = false
local jumpPowerValue = 50

local noclipEnabled = false
local noclipMethod = "CanCollide"
local noclipConnection

local infiniteJumpEnabled = false
local infiniteJumpConnection

local selfViewEnabled = false
local originalCamera = nil

local antiAFKEnabled = false
local antiAFKConnection

local bunnyHopEnabled = false
local bunnyHopConnection

local autoSprintEnabled = false

local removeTexturesEnabled = false
local originalTextures = {}

local noWaterEnabled = false
local wireframeEnabled = false
local noFogEnabled = false
local shadowsEnabled = true
local originalLighting = {}
local originalWaterParts = {}

local chatSpamEnabled = false
local chatSpamMessage = "Wraithsense by NexByte"
local chatSpamDelay = 1
local chatSpamConnection

local stretchedResEnabled = false
local stretchedResAmount = 0.75
local _sRes = {w=nil, h=nil}

local flingEnabled = false
local flingTarget = nil

local waypoints = {}
local selectedWaypoint = nil
local waypointDots = {}

local screenshotFolder = "Wraithsense/Screenshots"

local clipboardHistory = {}

local silentAimEnabled = false
local silentAimFOV = 120
local silentAimTeamCheck = true
local silentAimWallCheck = false
local silentAimTargetPart = "Head"
local silentAimFovCircle = {visible = false, color = Color3.fromRGB(232, 97, 154)}

local aimbotEnabled = false
local aimbotFOV = 100
local aimbotSmoothing = 5
local aimbotTargetPart = "Head"
local aimbotTeamCheck = true
local aimbotVisibleCheck = true
local aimbotKeybind = Enum.KeyCode.E
local aimbotMode = "Always"
local aimbotToggleState = false
local aimbotPrediction = false
local aimbotPredictionStrength = 0.1
local aimbotLock = false
local aimbotLockedTarget = nil
local aimbotMethod = "Mouse Delta"
local autoShootEnabled = false
local autoShootDelay = 0.05

local stickyAimEnabled = false

local antiAimEnabled = false
local antiAimMode = "Spin"
local antiAimSpeed = 20
local antiAimAngle = 0

local jitterEnabled = false
local jitterFromAngle = -45
local jitterToAngle = 45
local jitterSpeed = 5
local jitterCurrentAngle = -45
local jitterToggleState = false
local lastJitterTime = 0

local backwardAAEnabled = false
local customYawEnabled = false
local customYawAngle = 0

local desyncEnabled = false
local desyncMode = "Void"
local desyncOldPosition = nil
local desyncTeleportPosition = nil
local desyncSetback = nil

local jumpBugEnabled = false

local localChamsEnabled = false
local localChamsColor = Color3.fromRGB(232, 97, 154)

local armsChamsEnabled = false
local armsChamsColor = Color3.fromRGB(200, 200, 200)

local rapidFireEnabled = false
local rapidFireDelay = 0.05
local noSpreadEnabled = false
local noRecoilEnabled = false
local infiniteAmmoEnabled = false
local instantReloadEnabled = false
local weaponModsCache = {}
local weaponValueCache = {}
local backtrackEnabled = false
local backtrackTime = 0.2
local backtrackRecords = {}

local hitboxEnabled = false
local hitboxSize = 8
local hitboxOriginalSizes = {}
local hitboxParts = {"HumanoidRootPart", "Head", "UpperTorso", "Torso"}
local backtrackAuraEnabled = false
local backtrackAuraColor = Color3.fromRGB(232, 97, 154)
local backtrackAuraDrawings = {}
local autoStrafeEnabled = false
local autoStrafeState = 0
local fakeLagEnabled = false
local fakeLagStrength = 5
local fakeLagTimer = 0
local resolverEnabled = false
local resolverMode = "Spin"
local resolverHistory = {}

-- Advanced Resolver Variables
local resolverAutoHeadshot = true
local resolverAutoShoot = true
local resolverAutoShootDelay = 0.03
local resolverConfidenceThreshold = 65
local resolverNotify = true
local resolverFOVOverride = false
local resolverFOVValue = 200
local resolverSmoothing = 2
local resolverTeamCheck = true
local resolverWallCheck = true
local resolverLog = {}
local resolverMaxLogSize = 50
local resolverLastShotTime = {}
local resolverShotCooldown = 0.3
local resolverDetectedModes = {}
local resolverConfidenceScores = {}
local resolverResolvedCount = 0
local resolverHeadshotCount = 0

local antiRagdollEnabled = false
local antiFlingEnabled = false
local antiFlingConnections = {}
local antiStunEnabled = false
local antiVoidEnabled = false
local antiVoidHeight = -50
local antiVoidConnection = nil
local antiStunConnection = nil
local antiRagdollConnection = nil

local safeTeleportEnabled = false
local safeTeleportLastPos = nil
local safeTeleportInterval = 1
local safeTeleportTimer = 0

local fovCircle = {visible = false, color = Color3.fromRGB(232, 97, 154)}

local killAuraEnabled = false
local killAuraFOV = 150
local killAuraDelay = 0.05
local killAuraTimer = 0
local killAuraTeamCheck = true
local killAuraWallCheck = false

local killAuraFovCircle = {visible = false, color = Color3.fromRGB(232, 97, 154)}

local previewGui = nil
local previewViewport = nil

local espEnabled = false
local espObjects = {}
local espSettings = {
    Box = true,
    CornerBox = false,
    BoxFill = false,
    Name = true,
    Distance = true,
    Health = true,
    Tracer = false,
    Skeleton = false,
    HeadDot = false,
    Box3D = false,
    Box3DColor = Color3.fromRGB(232, 97, 154),
    Box3DTeamCheck = false,
    BoxColor = Color3.fromRGB(255, 180, 210),
    BoxFillColor = Color3.fromRGB(232, 97, 154),
    BoxFillTransparency = 0.5,
    TracerColor = Color3.fromRGB(255, 180, 210),
    SkeletonColor = Color3.fromRGB(255, 160, 200),
    HeadDotColor = Color3.fromRGB(255, 180, 210),
    TeamCheck = false,
    RainbowBox = false,
    RainbowTracer = false,
    RainbowSpeed = 1,
    BoxOutline = true,
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    TracerOutline = true,
    TracerOutlineColor = Color3.fromRGB(0, 0, 0),
    TracerOrigin = "Bottom",
    LookDirection = false,
    LookDirColor = Color3.fromRGB(255, 180, 210),
    VelocityArrow = false,
    VelocityColor = Color3.fromRGB(232, 97, 154),
    VisibilityIndicator = true,
    LockIndicator = true,
    MaxDistance = 500,
    MaxDistanceEnabled = false,
    OffScreenArrow = false,
    OffScreenArrowColor = Color3.fromRGB(232, 97, 154),
    Snapline = false,
    SnaplineColor = Color3.fromRGB(255, 180, 210),
}

local box3dObjects = {}

local radarEnabled = false
local radarSettings = {
    Size = 200,
    Range = 150,
    DotSize = 4,
    Color = Color3.fromRGB(255, 180, 210),
    EnemyColor = Color3.fromRGB(232, 97, 154),
    TeamCheck = false,
    X = 100,
    Y = 100,
}
local radarDrawings = {}

local chamsEnabled = false
local chamsObjects = {}
local chamsSettings = {
    Color = Color3.fromRGB(232, 97, 154),
    Transparency = 0.5,
    Rainbow = false,
    TeamCheck = false,
    Mode = "Fill",
    OutlineColor = Color3.fromRGB(255, 180, 210),
    OutlineTransparency = 0,
    AuraPulse = false,
    AuraColor = Color3.fromRGB(232, 97, 154),
    AuraPulseSpeed = 2,
}

local crosshairEnabled = false
local crosshairColor = Color3.fromRGB(255, 180, 210)
local crosshairWidth = 1.5
local crosshairLength = 10
local crosshairRadius = 11
local crosshairSpin = true
local crosshairSpinSpeed = 150
local crosshairSpinMax = 340
local crosshairResize = true
local crosshairResizeSpeed = 150
local crosshairResizeMin = 5
local crosshairResizeMax = 22
local crosshairDrawings = {}

local overlayEnabled = false
local overlayDrawing = nil

local scopeEnabled = false
local scopeLines = {}

local bulletTracerEnabled = false
local bulletTracerColor = Color3.fromRGB(255, 180, 210)
local bulletTracerThickness = 1
local bulletTracerDuration = 0.3
local bulletTracerFadeEnabled = true
local bulletTracerLines = {}

local keybindsEnabled = false
local keybindsDrawings = {}

local lockIndicatorEnabled = false
local lockIndicatorDrawings = {}
local lockIndicatorGui = nil
local lockIndicatorThumb = nil

local rainbowHue = 0
local function getRainbowColor()
    rainbowHue = rainbowHue + (espSettings.RainbowSpeed * 0.001)
    if rainbowHue >= 1 then rainbowHue = 0 end
    return Color3.fromHSV(rainbowHue, 1, 1)
end

local function spawnBulletTracer(toPos, targetPart)
    if not bulletTracerEnabled then return end
    local camera = workspace.CurrentCamera
    if not camera then return end

    local line = Drawing.new("Line")
    line.Color = bulletTracerColor
    line.Thickness = bulletTracerThickness
    line.Transparency = 0
    line.Visible = false
    line.ZIndex = 15

    local startTime = tick()
    local duration = bulletTracerDuration
    table.insert(bulletTracerLines, line)

    task.spawn(function()
        while true do
            local elapsed = tick() - startTime
            if elapsed >= duration then
                pcall(function() line:Remove() end)
                for i, l in ipairs(bulletTracerLines) do
                    if l == line then table.remove(bulletTracerLines, i) break end
                end
                break
            end

            local cam = workspace.CurrentCamera
            if cam then
                local vp = cam.ViewportSize
                local currentTo = (targetPart and targetPart.Parent) and targetPart.Position or toPos
                local toScreen = cam:WorldToViewportPoint(currentTo)
                line.From = Vector2.new(vp.X / 2, vp.Y)
                line.To = Vector2.new(toScreen.X, toScreen.Y)
                line.Visible = true
            end

            if bulletTracerFadeEnabled then
                line.Transparency = elapsed / duration
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

local function hookBulletTracer()
    local tracerTimer = 0
    local tracerInterval = 0.05

    RunService.Heartbeat:Connect(function(dt)
        if not bulletTracerEnabled then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            tracerTimer = 0
            return
        end
        tracerTimer = tracerTimer + dt
        if tracerTimer < tracerInterval then return end
        tracerTimer = 0

        local char = player.Character
        if not char then return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local mousePos = UserInputService:GetMouseLocation()
        local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, params)
        local hitPos = rayResult and rayResult.Position or (unitRay.Origin + unitRay.Direction * 2000)

        local targetPart = nil
        if rayResult and rayResult.Instance then
            local hitChar = rayResult.Instance.Parent
            local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
            if hitPlayer and hitPlayer ~= player then
                targetPart = hitChar:FindFirstChild("HumanoidRootPart") or rayResult.Instance
            end
        end

        spawnBulletTracer(hitPos, targetPart)
    end)
end
hookBulletTracer()

local function removeChams(targetPlayer)
    local highlight = chamsObjects[targetPlayer]
    if highlight then
        pcall(function() highlight:Destroy() end)
        chamsObjects[targetPlayer] = nil
    end
end

local function createChams(targetPlayer)
    if targetPlayer == Players.LocalPlayer and not selfViewEnabled then return end
    if not targetPlayer.Character then return end

    if chamsSettings.TeamCheck and targetPlayer.Team == player.Team and targetPlayer ~= player then
        return
    end

    removeChams(targetPlayer)

    local highlight = Instance.new("Highlight")
    highlight.Adornee = targetPlayer.Character

    if chamsSettings.Mode == "Fill" then
        highlight.FillColor = chamsSettings.Color
        highlight.FillTransparency = chamsSettings.Transparency
        highlight.OutlineTransparency = 1
    elseif chamsSettings.Mode == "Outline" then
        highlight.FillTransparency = 1
        highlight.OutlineColor = chamsSettings.OutlineColor
        highlight.OutlineTransparency = chamsSettings.OutlineTransparency
    elseif chamsSettings.Mode == "Aura" then
        highlight.FillColor = chamsSettings.AuraColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = chamsSettings.AuraColor
        highlight.OutlineTransparency = 0
    elseif chamsSettings.Mode == "Full" then
        highlight.FillColor = chamsSettings.Color
        highlight.FillTransparency = chamsSettings.Transparency
        highlight.OutlineColor = chamsSettings.OutlineColor
        highlight.OutlineTransparency = chamsSettings.OutlineTransparency
    end

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = targetPlayer.Character
    chamsObjects[targetPlayer] = highlight
end

local _chamsPulse = 0
local function updateChams()
    if not chamsEnabled then return end
    _chamsPulse = _chamsPulse + 0.016 * chamsSettings.AuraPulseSpeed
    local pulseT = 0.3 + math.abs(math.sin(_chamsPulse)) * 0.6

    for targetPlayer, highlight in pairs(chamsObjects) do
        if highlight and highlight.Parent then
            if chamsSettings.Mode == "Fill" then
                highlight.FillColor = chamsSettings.Rainbow and getRainbowColor() or chamsSettings.Color
                highlight.FillTransparency = chamsSettings.Transparency
                highlight.OutlineTransparency = 1
            elseif chamsSettings.Mode == "Outline" then
                highlight.FillTransparency = 1
                highlight.OutlineColor = chamsSettings.OutlineColor
                highlight.OutlineTransparency = chamsSettings.OutlineTransparency
            elseif chamsSettings.Mode == "Aura" then
                local col = chamsSettings.Rainbow and getRainbowColor() or chamsSettings.AuraColor
                highlight.FillColor = col
                highlight.OutlineColor = col
                if chamsSettings.AuraPulse then
                    highlight.FillTransparency = pulseT
                    highlight.OutlineTransparency = 1 - (1 - pulseT) * 0.5
                else
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0
                end
            elseif chamsSettings.Mode == "Full" then
                highlight.FillColor = chamsSettings.Rainbow and getRainbowColor() or chamsSettings.Color
                highlight.FillTransparency = chamsSettings.Transparency
                highlight.OutlineColor = chamsSettings.OutlineColor
                highlight.OutlineTransparency = chamsSettings.OutlineTransparency
            end
        end
    end
end

local function createESP(targetPlayer)
    if targetPlayer == Players.LocalPlayer and not selfViewEnabled then return end
    local esp = {Player = targetPlayer, Drawings = {}, SkeletonLines = {}, CornerLines = {}}

    esp.Drawings.BoxFill = Drawing.new("Square")
    esp.Drawings.BoxFill.Visible = false
    esp.Drawings.BoxFill.Color = espSettings.BoxFillColor
    esp.Drawings.BoxFill.Thickness = 1
    esp.Drawings.BoxFill.Transparency = espSettings.BoxFillTransparency
    esp.Drawings.BoxFill.Filled = true
    esp.Drawings.BoxFill.ZIndex = 1

    esp.Drawings.BoxOutline = Drawing.new("Square")
    esp.Drawings.BoxOutline.Visible = false
    esp.Drawings.BoxOutline.Color = espSettings.BoxOutlineColor
    esp.Drawings.BoxOutline.Thickness = 2
    esp.Drawings.BoxOutline.Filled = false
    esp.Drawings.BoxOutline.Transparency = 1
    esp.Drawings.BoxOutline.ZIndex = 1

    esp.Drawings.Box = Drawing.new("Square")
    esp.Drawings.Box.Visible = false
    esp.Drawings.Box.Color = espSettings.BoxColor
    esp.Drawings.Box.Thickness = 1
    esp.Drawings.Box.Transparency = 1
    esp.Drawings.Box.Filled = false
    esp.Drawings.Box.ZIndex = 2

    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espSettings.BoxColor
        line.Thickness = 2
        line.Transparency = 1
        line.ZIndex = 3
        table.insert(esp.CornerLines, line)
    end
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espSettings.BoxOutlineColor
        line.Thickness = 3
        line.Transparency = 1
        line.ZIndex = 2
        table.insert(esp.CornerLines, line)
    end

    esp.Drawings.TracerOutline = Drawing.new("Line")
    esp.Drawings.TracerOutline.Visible = false
    esp.Drawings.TracerOutline.Color = espSettings.TracerOutlineColor
    esp.Drawings.TracerOutline.Thickness = 2
    esp.Drawings.TracerOutline.Transparency = 1
    esp.Drawings.TracerOutline.ZIndex = 1

    esp.Drawings.Tracer = Drawing.new("Line")
    esp.Drawings.Tracer.Visible = false
    esp.Drawings.Tracer.Color = espSettings.TracerColor
    esp.Drawings.Tracer.Thickness = 1
    esp.Drawings.Tracer.Transparency = 1
    esp.Drawings.Tracer.ZIndex = 2

    esp.Drawings.HeadDot = Drawing.new("Circle")
    esp.Drawings.HeadDot.Visible = false
    esp.Drawings.HeadDot.Color = espSettings.HeadDotColor
    esp.Drawings.HeadDot.Thickness = 2
    esp.Drawings.HeadDot.NumSides = 32
    esp.Drawings.HeadDot.Radius = 4
    esp.Drawings.HeadDot.Filled = false
    esp.Drawings.HeadDot.Transparency = 1
    esp.Drawings.HeadDot.ZIndex = 4

    esp.Drawings.HeadDotOutline = Drawing.new("Circle")
    esp.Drawings.HeadDotOutline.Visible = false
    esp.Drawings.HeadDotOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.Drawings.HeadDotOutline.Thickness = 3
    esp.Drawings.HeadDotOutline.NumSides = 32
    esp.Drawings.HeadDotOutline.Radius = 4
    esp.Drawings.HeadDotOutline.Filled = false
    esp.Drawings.HeadDotOutline.Transparency = 1
    esp.Drawings.HeadDotOutline.ZIndex = 3

    esp.Drawings.Name = Drawing.new("Text")
    esp.Drawings.Name.Visible = false
    esp.Drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Drawings.Name.Size = 14
    esp.Drawings.Name.Font = Drawing.Fonts.Plex
    esp.Drawings.Name.Center = true
    esp.Drawings.Name.Outline = true
    esp.Drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Drawings.Name.Text = targetPlayer.Name

    esp.Drawings.Distance = Drawing.new("Text")
    esp.Drawings.Distance.Visible = false
    esp.Drawings.Distance.Color = Color3.fromRGB(180, 180, 180)
    esp.Drawings.Distance.Size = 12
    esp.Drawings.Distance.Font = Drawing.Fonts.Plex
    esp.Drawings.Distance.Center = true
    esp.Drawings.Distance.Outline = true
    esp.Drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)

    esp.Drawings.HealthBar = Drawing.new("Square")
    esp.Drawings.HealthBar.Visible = false
    esp.Drawings.HealthBar.Thickness = 1
    esp.Drawings.HealthBar.Filled = true
    esp.Drawings.HealthBar.Transparency = 1
    esp.Drawings.HealthBar.ZIndex = 4

    esp.Drawings.HealthBarBG = Drawing.new("Square")
    esp.Drawings.HealthBarBG.Visible = false
    esp.Drawings.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
    esp.Drawings.HealthBarBG.Thickness = 1
    esp.Drawings.HealthBarBG.Filled = true
    esp.Drawings.HealthBarBG.Transparency = 0.6
    esp.Drawings.HealthBarBG.ZIndex = 3

    esp.Drawings.HealthBarOutline = Drawing.new("Square")
    esp.Drawings.HealthBarOutline.Visible = false
    esp.Drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.Drawings.HealthBarOutline.Thickness = 1
    esp.Drawings.HealthBarOutline.Filled = false
    esp.Drawings.HealthBarOutline.Transparency = 1
    esp.Drawings.HealthBarOutline.ZIndex = 2

    esp.Drawings.HealthBarRed = nil
    esp.Drawings.HealthBarYellow = nil
    esp.Drawings.HealthBarGreen = nil

    esp.HealthGradientLines = {}
    for i = 1, 24 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1
        l.Transparency = 1
        l.ZIndex = 4
        table.insert(esp.HealthGradientLines, l)
    end

    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espSettings.SkeletonColor
        line.Thickness = 1
        line.Transparency = 0.8
        line.ZIndex = 1
        table.insert(esp.SkeletonLines, line)
    end

    esp.Drawings.LookDir = Drawing.new("Line")
    esp.Drawings.LookDir.Visible = false
    esp.Drawings.LookDir.Thickness = 2
    esp.Drawings.LookDir.Transparency = 1
    esp.Drawings.LookDir.ZIndex = 5

    esp.Drawings.VelocityArrow = Drawing.new("Line")
    esp.Drawings.VelocityArrow.Visible = false
    esp.Drawings.VelocityArrow.Thickness = 2
    esp.Drawings.VelocityArrow.Transparency = 1
    esp.Drawings.VelocityArrow.ZIndex = 5

    esp.Drawings.Snapline = Drawing.new("Line")
    esp.Drawings.Snapline.Visible = false
    esp.Drawings.Snapline.Thickness = 1
    esp.Drawings.Snapline.Transparency = 0.7
    esp.Drawings.Snapline.ZIndex = 1

    esp.Drawings.OffArrowL1 = Drawing.new("Line")
    esp.Drawings.OffArrowL1.Visible = false
    esp.Drawings.OffArrowL1.Thickness = 2
    esp.Drawings.OffArrowL1.Transparency = 1
    esp.Drawings.OffArrowL1.ZIndex = 10

    esp.Drawings.OffArrowL2 = Drawing.new("Line")
    esp.Drawings.OffArrowL2.Visible = false
    esp.Drawings.OffArrowL2.Thickness = 2
    esp.Drawings.OffArrowL2.Transparency = 1
    esp.Drawings.OffArrowL2.ZIndex = 10

    esp.Drawings.OffArrowL3 = Drawing.new("Line")
    esp.Drawings.OffArrowL3.Visible = false
    esp.Drawings.OffArrowL3.Thickness = 2
    esp.Drawings.OffArrowL3.Transparency = 1
    esp.Drawings.OffArrowL3.ZIndex = 10

    espObjects[targetPlayer] = esp
end

local function removeESP(targetPlayer)
    local esp = espObjects[targetPlayer]
    if esp then
        for _, drawing in pairs(esp.Drawings) do
            pcall(function() drawing:Remove() end)
        end
        for _, line in pairs(esp.SkeletonLines) do
            pcall(function() line:Remove() end)
        end
        for _, line in pairs(esp.CornerLines) do
            pcall(function() line:Remove() end)
        end
        for _, line in pairs(esp.HealthGradientLines or {}) do
            pcall(function() line:Remove() end)
        end
        espObjects[targetPlayer] = nil
    end
end

local function hideESP(esp)
    for _, drawing in pairs(esp.Drawings) do
        drawing.Visible = false
    end
    for _, line in pairs(esp.SkeletonLines) do
        line.Visible = false
    end
    for _, line in pairs(esp.CornerLines) do
        line.Visible = false
    end
    for _, line in pairs(esp.HealthGradientLines or {}) do
        line.Visible = false
    end
end

local function drawCornerBox(esp, x, y, w, h, color, outlineColor, showOutline)
    local cLen = math.min(w, h) * 0.25
    local x1, y1 = x, y
    local x2, y2 = x + w, y + h
    local corners = {
        {Vector2.new(x1, y1),         Vector2.new(x1 + cLen, y1)},
        {Vector2.new(x1, y1),         Vector2.new(x1, y1 + cLen)},
        {Vector2.new(x2, y1),         Vector2.new(x2 - cLen, y1)},
        {Vector2.new(x2, y1),         Vector2.new(x2, y1 + cLen)},
        {Vector2.new(x1, y2),         Vector2.new(x1 + cLen, y2)},
        {Vector2.new(x1, y2),         Vector2.new(x1, y2 - cLen)},
        {Vector2.new(x2, y2),         Vector2.new(x2 - cLen, y2)},
        {Vector2.new(x2, y2),         Vector2.new(x2, y2 - cLen)},
    }
    for i, c in ipairs(corners) do
        if showOutline then
            esp.CornerLines[i + 8].From = c[1]
            esp.CornerLines[i + 8].To = c[2]
            esp.CornerLines[i + 8].Color = outlineColor
            esp.CornerLines[i + 8].Visible = true
        else
            esp.CornerLines[i + 8].Visible = false
        end
        esp.CornerLines[i].From = c[1]
        esp.CornerLines[i].To = c[2]
        esp.CornerLines[i].Color = color
        esp.CornerLines[i].Visible = true
    end
end

local function create3DBox(targetPlayer)
    local lines = {}
    for i = 1, 12 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1
        l.Transparency = 1
        l.ZIndex = 5
        lines[i] = l
    end
    box3dObjects[targetPlayer] = lines
end

local function remove3DBox(targetPlayer)
    local lines = box3dObjects[targetPlayer]
    if lines then
        for _, l in ipairs(lines) do pcall(function() l:Remove() end) end
        box3dObjects[targetPlayer] = nil
    end
end

local function update3DBoxForPlayer(targetPlayer, lines, camera, localRoot)
    local character = targetPlayer.Character
    if not character then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end
    if espSettings.Box3DTeamCheck and targetPlayer.Team == player.Team then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end

    local sz = Vector3.new(4, 5, 2)
    local cf = hrp.CFrame
    local hx, hy, hz = sz.X/2, sz.Y/2, sz.Z/2

    local corners = {
        cf * Vector3.new(-hx,  hy, -hz),
        cf * Vector3.new( hx,  hy, -hz),
        cf * Vector3.new( hx,  hy,  hz),
        cf * Vector3.new(-hx,  hy,  hz),
        cf * Vector3.new(-hx, -hy, -hz),
        cf * Vector3.new( hx, -hy, -hz),
        cf * Vector3.new( hx, -hy,  hz),
        cf * Vector3.new(-hx, -hy,  hz),
    }

    local screen = {}
    local allVisible = true
    for i, c in ipairs(corners) do
        local sp, vis = camera:WorldToViewportPoint(c)
        screen[i] = Vector2.new(sp.X, sp.Y)
        if not vis then allVisible = false end
    end

    if not allVisible then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end

    local edges = {
        {1,2},{2,3},{3,4},{4,1},
        {5,6},{6,7},{7,8},{8,5},
        {1,5},{2,6},{3,7},{4,8},
    }
    for i, e in ipairs(edges) do
        lines[i].From = screen[e[1]]
        lines[i].To = screen[e[2]]
        lines[i].Color = espSettings.Box3DColor
        lines[i].Visible = true
    end
end

local function update3DBox()
    if not espSettings.Box3D then
        for _, lines in pairs(box3dObjects) do
            for _, l in ipairs(lines) do l.Visible = false end
        end
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local localChar = player.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    for targetPlayer, lines in pairs(box3dObjects) do
        update3DBoxForPlayer(targetPlayer, lines, camera, localRoot)
    end
end

local function createRadarDrawings()
    for _, d in pairs(radarDrawings) do pcall(function() d:Remove() end) end
    radarDrawings = {}
    local bg = Drawing.new("Square")
    bg.Filled = true
    bg.Color = Color3.fromRGB(10, 10, 10)
    bg.Transparency = 0.5
    bg.Visible = false
    bg.ZIndex = 20
    radarDrawings.bg = bg

    local border = Drawing.new("Square")
    border.Filled = false
    border.Color = Color3.fromRGB(100, 100, 100)
    border.Thickness = 1
    border.Transparency = 1
    border.Visible = false
    border.ZIndex = 21
    radarDrawings.border = border

    local crossH = Drawing.new("Line")
    crossH.Color = Color3.fromRGB(60, 60, 60)
    crossH.Thickness = 1
    crossH.Transparency = 1
    crossH.Visible = false
    crossH.ZIndex = 21
    radarDrawings.crossH = crossH

    local crossV = Drawing.new("Line")
    crossV.Color = Color3.fromRGB(60, 60, 60)
    crossV.Thickness = 1
    crossV.Transparency = 1
    crossV.Visible = false
    crossV.ZIndex = 21
    radarDrawings.crossV = crossV

    local selfDot = Drawing.new("Circle")
    selfDot.Filled = true
    selfDot.Color = Color3.fromRGB(255, 180, 210)
    selfDot.Radius = 4
    selfDot.NumSides = 16
    selfDot.Transparency = 1
    selfDot.Visible = false
    selfDot.ZIndex = 23
    radarDrawings.selfDot = selfDot

    radarDrawings.dots = {}
end
createRadarDrawings()

local function updateRadar()
    if not radarEnabled then
        if radarDrawings.bg then radarDrawings.bg.Visible = false end
        if radarDrawings.border then radarDrawings.border.Visible = false end
        if radarDrawings.crossH then radarDrawings.crossH.Visible = false end
        if radarDrawings.crossV then radarDrawings.crossV.Visible = false end
        if radarDrawings.selfDot then radarDrawings.selfDot.Visible = false end
        if radarDrawings.dots then
            for _, d in pairs(radarDrawings.dots) do d.Visible = false end
        end
        return
    end

    local localChar = player.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local sz = radarSettings.Size
    local rx = radarSettings.X
    local ry = radarSettings.Y
    local cx = rx + sz/2
    local cy = ry + sz/2

    radarDrawings.bg.Size = Vector2.new(sz, sz)
    radarDrawings.bg.Position = Vector2.new(rx, ry)
    radarDrawings.bg.Visible = true

    radarDrawings.border.Size = Vector2.new(sz, sz)
    radarDrawings.border.Position = Vector2.new(rx, ry)
    radarDrawings.border.Visible = true

    radarDrawings.crossH.From = Vector2.new(rx, cy)
    radarDrawings.crossH.To = Vector2.new(rx + sz, cy)
    radarDrawings.crossH.Visible = true

    radarDrawings.crossV.From = Vector2.new(cx, ry)
    radarDrawings.crossV.To = Vector2.new(cx, ry + sz)
    radarDrawings.crossV.Visible = true

    radarDrawings.selfDot.Position = Vector2.new(cx, cy)
    radarDrawings.selfDot.Visible = true

    local dotIdx = 1
    local camera = workspace.CurrentCamera
    local camCF = camera and camera.CFrame or localRoot.CFrame
    local range = radarSettings.Range

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and hum and hum.Health > 0 then
                if not radarSettings.TeamCheck or targetPlayer.Team ~= player.Team then
                    local diff = targetRoot.Position - localRoot.Position
                    local dist = diff.Magnitude
                    if dist <= range then
                        local relX = camCF.RightVector:Dot(diff)
                        local relZ = camCF.LookVector:Dot(diff)
                        local px = cx + (relX / range) * (sz/2)
                        local py = cy - (relZ / range) * (sz/2)

                        if not radarDrawings.dots[dotIdx] then
                            local d = Drawing.new("Circle")
                            d.Filled = true
                            d.NumSides = 16
                            d.ZIndex = 22
                            d.Transparency = 1
                            radarDrawings.dots[dotIdx] = d
                        end
                        local dot = radarDrawings.dots[dotIdx]
                        dot.Position = Vector2.new(px, py)
                        dot.Radius = radarSettings.DotSize
                        dot.Color = radarSettings.EnemyColor
                        dot.Visible = true
                        dotIdx = dotIdx + 1
                    end
                end
            end
        end
    end

    for i = dotIdx, #radarDrawings.dots do
        radarDrawings.dots[i].Visible = false
    end
end

local function updateESP()
    if not espEnabled then
        for _, esp in pairs(espObjects) do
            hideESP(esp)
        end
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local localChar = player.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local camCF = camera.CFrame
    local screenSize = camera.ViewportSize
    local screenCX = screenSize.X / 2
    local screenCY = screenSize.Y / 2

    -- Cleanup stale ESP entries for players no longer in game
    local staleKeys = {}
    for targetPlayer, esp in pairs(espObjects) do
        if not targetPlayer or not targetPlayer.Parent then
            table.insert(staleKeys, targetPlayer)
        end
    end
    for _, key in ipairs(staleKeys) do
        removeESP(key)
        remove3DBox(key)
    end

    for targetPlayer, esp in pairs(espObjects) do
        local character = targetPlayer.Character
        if not character or not character.Parent then
            hideESP(esp)
        end
        if character and character.Parent then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")

            if not rootPart or not humanoid or not head or humanoid.Health < 1 then
                hideESP(esp)
            else
                local skip = espSettings.TeamCheck and targetPlayer.Team == player.Team

                if not skip and espSettings.MaxDistanceEnabled then
                    if (localRoot.Position - rootPart.Position).Magnitude > espSettings.MaxDistance then
                        skip = true
                    end
                end

                if skip then
                    hideESP(esp)
                else
                    local rootSP, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                    if not onScreen then
                        if espSettings.OffScreenArrow then
                            local dir = (Vector2.new(rootSP.X, rootSP.Y) - Vector2.new(screenCX, screenCY)).Unit
                            local margin = 40
                            local ax = math.clamp(screenCX + dir.X * (screenCX - margin), margin, screenSize.X - margin)
                            local ay = math.clamp(screenCY + dir.Y * (screenCY - margin), margin, screenSize.Y - margin)
                            local angle = math.atan2(dir.Y, dir.X)
                            local arrowSize = 10
                            local tip   = Vector2.new(ax + math.cos(angle) * arrowSize,       ay + math.sin(angle) * arrowSize)
                            local left  = Vector2.new(ax + math.cos(angle + 2.4) * arrowSize, ay + math.sin(angle + 2.4) * arrowSize)
                            local right = Vector2.new(ax + math.cos(angle - 2.4) * arrowSize, ay + math.sin(angle - 2.4) * arrowSize)
                            local col = espSettings.OffScreenArrowColor
                            esp.Drawings.OffArrowL1.From = tip;  esp.Drawings.OffArrowL1.To = left;  esp.Drawings.OffArrowL1.Color = col; esp.Drawings.OffArrowL1.Visible = true
                            esp.Drawings.OffArrowL2.From = tip;  esp.Drawings.OffArrowL2.To = right; esp.Drawings.OffArrowL2.Color = col; esp.Drawings.OffArrowL2.Visible = true
                            esp.Drawings.OffArrowL3.From = left; esp.Drawings.OffArrowL3.To = right; esp.Drawings.OffArrowL3.Color = col; esp.Drawings.OffArrowL3.Visible = true
                            for k, d in pairs(esp.Drawings) do
                                if k ~= "OffArrowL1" and k ~= "OffArrowL2" and k ~= "OffArrowL3" then d.Visible = false end
                            end
                            for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                            for _, l in ipairs(esp.CornerLines) do l.Visible = false end
                        else
                            hideESP(esp)
                        end
                    else
                        local hum2 = character:FindFirstChildOfClass("Humanoid")
                        local isR6 = hum2 and hum2.RigType == Enum.HumanoidRigType.R6

                        local headSP = camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
                        local footSP = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, (hum2 and hum2.HipHeight or 2) + (isR6 and 2.05 or 1.05), 0))

                        local height = footSP.Y - headSP.Y
                        local width  = math.max(height * 0.4, 20)
                        if height < 1 then height = 1 end

                        local bx = headSP.X - width / 2
                        local by = headSP.Y
                        local anyVisible = headSP.Z > 0

                        if not anyVisible then
                            hideESP(esp)
                        else
                            local isLocked = aimbotLock and aimbotLockedTarget == targetPlayer

                            local isVisible = false
                            if espSettings.VisibilityIndicator or espSettings.LockIndicator then
                                local ray = Ray.new(camCF.Position, (head.Position - camCF.Position).Unit * 1000)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localChar, camera})
                                isVisible = not hit or hit:IsDescendantOf(character)
                            end

                            local boxColor
                            if isLocked and espSettings.LockIndicator then
                                boxColor = Color3.fromRGB(255, 50, 50)
                            elseif espSettings.VisibilityIndicator then
                                boxColor = isVisible and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 60, 60)
                            elseif espSettings.RainbowBox then
                                boxColor = getRainbowColor()
                            else
                                boxColor = espSettings.BoxColor
                            end

                            if espSettings.BoxFill then
                                esp.Drawings.BoxFill.Size = Vector2.new(width, height)
                                esp.Drawings.BoxFill.Position = Vector2.new(bx, by)
                                esp.Drawings.BoxFill.Color = espSettings.BoxFillColor
                                esp.Drawings.BoxFill.Transparency = espSettings.BoxFillTransparency
                                esp.Drawings.BoxFill.Visible = true
                            else
                                esp.Drawings.BoxFill.Visible = false
                            end

                            if espSettings.Box and not espSettings.CornerBox then
                                esp.Drawings.Box.Size = Vector2.new(width, height)
                                esp.Drawings.Box.Position = Vector2.new(bx, by)
                                esp.Drawings.Box.Color = boxColor
                                esp.Drawings.Box.Visible = true
                                if espSettings.BoxOutline then
                                    esp.Drawings.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                                    esp.Drawings.BoxOutline.Position = Vector2.new(bx - 1, by - 1)
                                    esp.Drawings.BoxOutline.Color = espSettings.BoxOutlineColor
                                    esp.Drawings.BoxOutline.Transparency = 1
                                    esp.Drawings.BoxOutline.Visible = true
                                else
                                    esp.Drawings.BoxOutline.Visible = false
                                end
                                for _, l in ipairs(esp.CornerLines) do l.Visible = false end
                            elseif espSettings.CornerBox then
                                esp.Drawings.Box.Visible = false
                                esp.Drawings.BoxOutline.Visible = false
                                drawCornerBox(esp, bx, by, width, height, boxColor, espSettings.BoxOutlineColor, espSettings.BoxOutline)
                            else
                                esp.Drawings.Box.Visible = false
                                esp.Drawings.BoxOutline.Visible = false
                                for _, l in ipairs(esp.CornerLines) do l.Visible = false end
                            end

                            if espSettings.HeadDot then
                                local hdPos = camera:WorldToViewportPoint(head.Position)
                                esp.Drawings.HeadDotOutline.Position = Vector2.new(hdPos.X, hdPos.Y)
                                esp.Drawings.HeadDotOutline.Radius = width * 0.18
                                esp.Drawings.HeadDotOutline.Visible = true
                                esp.Drawings.HeadDot.Position = Vector2.new(hdPos.X, hdPos.Y)
                                esp.Drawings.HeadDot.Color = espSettings.HeadDotColor
                                esp.Drawings.HeadDot.Radius = width * 0.18
                                esp.Drawings.HeadDot.Visible = true
                            else
                                esp.Drawings.HeadDot.Visible = false
                                esp.Drawings.HeadDotOutline.Visible = false
                            end

                            if espSettings.Name then
                                local hp = math.floor(humanoid.Health / humanoid.MaxHealth * 100)
                                esp.Drawings.Name.Text = targetPlayer.Name .. "  " .. hp .. "%"
                                esp.Drawings.Name.Position = Vector2.new(bx + width / 2, by - 16)
                                esp.Drawings.Name.Visible = true
                            else
                                esp.Drawings.Name.Visible = false
                            end

                            if espSettings.Distance then
                                local dist = math.floor((localRoot.Position - rootPart.Position).Magnitude)
                                esp.Drawings.Distance.Text = "[" .. dist .. "m]"
                                esp.Drawings.Distance.Position = Vector2.new(bx + width / 2, by + height + 3)
                                esp.Drawings.Distance.Visible = true
                            else
                                esp.Drawings.Distance.Visible = false
                            end

                            if espSettings.Health then
                                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                local barW = 4
                                local barX = bx - 8
                                local totalH = height
                                local filledH = totalH * healthPercent

                                local r, g
                                if healthPercent > 0.5 then
                                    local t = (healthPercent - 0.5) * 2
                                    r = math.floor(255 * (1 - t))
                                    g = 210
                                else
                                    local t = healthPercent * 2
                                    r = 220
                                    g = math.floor(210 * t)
                                end
                                local healthColor = Color3.fromRGB(r, g, 0)

                                esp.Drawings.HealthBarBG.Size = Vector2.new(barW, totalH)
                                esp.Drawings.HealthBarBG.Position = Vector2.new(barX, by)
                                esp.Drawings.HealthBarBG.Color = Color3.fromRGB(15, 15, 15)
                                esp.Drawings.HealthBarBG.Transparency = 0.5
                                esp.Drawings.HealthBarBG.Visible = true
                                esp.Drawings.HealthBarOutline.Size = Vector2.new(barW + 2, totalH + 2)
                                esp.Drawings.HealthBarOutline.Position = Vector2.new(barX - 1, by - 1)
                                esp.Drawings.HealthBarOutline.Visible = true
                                esp.Drawings.HealthBar.Color = healthColor
                                esp.Drawings.HealthBar.Size = Vector2.new(barW, filledH)
                                esp.Drawings.HealthBar.Position = Vector2.new(barX, by + totalH - filledH)
                                esp.Drawings.HealthBar.Visible = true

                                for _, l in ipairs(esp.HealthGradientLines) do l.Visible = false end
                            else
                                esp.Drawings.HealthBar.Visible = false
                                esp.Drawings.HealthBarBG.Visible = false
                                esp.Drawings.HealthBarOutline.Visible = false
                                for _, l in ipairs(esp.HealthGradientLines) do l.Visible = false end
                            end

                            if espSettings.Tracer then
                                local tFrom = espSettings.TracerOrigin == "Center"
                                    and Vector2.new(screenCX, screenCY)
                                    or  Vector2.new(screenCX, screenSize.Y)
                                local tTo = Vector2.new(bx + width / 2, by + height / 2)
                                local tracerColor = espSettings.RainbowTracer and getRainbowColor() or espSettings.TracerColor
                                if espSettings.TracerOutline then
                                    esp.Drawings.TracerOutline.From = tFrom
                                    esp.Drawings.TracerOutline.To = tTo
                                    esp.Drawings.TracerOutline.Color = espSettings.TracerOutlineColor
                                    esp.Drawings.TracerOutline.Visible = true
                                else
                                    esp.Drawings.TracerOutline.Visible = false
                                end
                                esp.Drawings.Tracer.From = tFrom
                                esp.Drawings.Tracer.To = tTo
                                esp.Drawings.Tracer.Color = tracerColor
                                esp.Drawings.Tracer.Visible = true
                            else
                                esp.Drawings.Tracer.Visible = false
                                esp.Drawings.TracerOutline.Visible = false
                            end

                            if espSettings.Skeleton then
                                local skeletonParts
                                if not isR6 then
                                    local ut = character:FindFirstChild("UpperTorso")
                                    local lt = character:FindFirstChild("LowerTorso")
                                    skeletonParts = {
                                        {head, ut},
                                        {ut, lt},
                                        {ut, character:FindFirstChild("LeftUpperArm")},
                                        {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm")},
                                        {character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand")},
                                        {ut, character:FindFirstChild("RightUpperArm")},
                                        {character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm")},
                                        {character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")},
                                        {lt, character:FindFirstChild("LeftUpperLeg")},
                                        {character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg")},
                                        {character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot")},
                                        {lt, character:FindFirstChild("RightUpperLeg")},
                                        {character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg")},
                                        {character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot")}
                                    }
                                else
                                    local torso2 = character:FindFirstChild("Torso")
                                    skeletonParts = {
                                        {head, torso2},
                                        {torso2, character:FindFirstChild("Left Arm")},
                                        {torso2, character:FindFirstChild("Right Arm")},
                                        {torso2, character:FindFirstChild("Left Leg")},
                                        {torso2, character:FindFirstChild("Right Leg")}
                                    }
                                end
                                for i, conn in ipairs(skeletonParts) do
                                    if esp.SkeletonLines[i] and conn[1] and conn[2] then
                                        local p1 = camera:WorldToViewportPoint(conn[1].Position)
                                        local p2 = camera:WorldToViewportPoint(conn[2].Position)
                                        esp.SkeletonLines[i].From = Vector2.new(p1.X, p1.Y)
                                        esp.SkeletonLines[i].To = Vector2.new(p2.X, p2.Y)
                                        esp.SkeletonLines[i].Color = espSettings.SkeletonColor
                                        esp.SkeletonLines[i].Visible = true
                                    elseif esp.SkeletonLines[i] then
                                        esp.SkeletonLines[i].Visible = false
                                    end
                                end
                            else
                                for _, line in ipairs(esp.SkeletonLines) do line.Visible = false end
                            end

                            if espSettings.Snapline then
                                esp.Drawings.Snapline.From = Vector2.new(screenCX, screenSize.Y)
                                esp.Drawings.Snapline.To = Vector2.new(bx + width / 2, by + height)
                                esp.Drawings.Snapline.Color = espSettings.SnaplineColor
                                esp.Drawings.Snapline.Visible = true
                            else
                                esp.Drawings.Snapline.Visible = false
                            end

                            if espSettings.LookDirection then
                                local lookWorld = rootPart.CFrame.LookVector
                                local rsp = camera:WorldToViewportPoint(rootPart.Position)
                                local lsp = camera:WorldToViewportPoint(rootPart.Position + lookWorld * 3)
                                esp.Drawings.LookDir.From = Vector2.new(rsp.X, rsp.Y)
                                esp.Drawings.LookDir.To = Vector2.new(lsp.X, lsp.Y)
                                esp.Drawings.LookDir.Color = espSettings.LookDirColor
                                esp.Drawings.LookDir.Visible = true
                            else
                                esp.Drawings.LookDir.Visible = false
                            end

                            if espSettings.VelocityArrow then
                                local vel = rootPart.AssemblyLinearVelocity
                                if vel.Magnitude > 0.5 then
                                    local rsp = camera:WorldToViewportPoint(rootPart.Position)
                                    local vsp = camera:WorldToViewportPoint(rootPart.Position + vel.Unit * 3)
                                    esp.Drawings.VelocityArrow.From = Vector2.new(rsp.X, rsp.Y)
                                    esp.Drawings.VelocityArrow.To = Vector2.new(vsp.X, vsp.Y)
                                    esp.Drawings.VelocityArrow.Color = espSettings.VelocityColor
                                    esp.Drawings.VelocityArrow.Visible = true
                                else
                                    esp.Drawings.VelocityArrow.Visible = false
                                end
                            else
                                esp.Drawings.VelocityArrow.Visible = false
                            end

                            esp.Drawings.OffArrowL1.Visible = false
                            esp.Drawings.OffArrowL2.Visible = false
                            esp.Drawings.OffArrowL3.Visible = false
                        end
                    end
                end
            end
        end
    end
end

for _, targetPlayer in pairs(Players:GetPlayers()) do
    if targetPlayer ~= player or selfViewEnabled then
        createESP(targetPlayer)
        create3DBox(targetPlayer)
        if targetPlayer.Character then
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Died:Connect(function()
                    task.wait(0.5)
                    removeESP(targetPlayer)
                    remove3DBox(targetPlayer)
                    removeChams(targetPlayer)
                end)
            end
        end
        if chamsEnabled then
            task.spawn(function()
                if targetPlayer.Character then
                    createChams(targetPlayer)
                end
            end)
        end

        targetPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.2)
            removeESP(targetPlayer)
            removeChams(targetPlayer)
            remove3DBox(targetPlayer)
            task.wait(0.1)
            createESP(targetPlayer)
            create3DBox(targetPlayer)
            if chamsEnabled then
                task.wait(0.3)
                createChams(targetPlayer)
            end
            local hum = character:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    task.wait(0.5)
                    removeESP(targetPlayer)
                    remove3DBox(targetPlayer)
                    removeChams(targetPlayer)
                end)
            end
        end)

        targetPlayer.CharacterRemoving:Connect(function()
            task.wait(0.1)
            removeESP(targetPlayer)
            remove3DBox(targetPlayer)
            removeChams(targetPlayer)
        end)
    end
end

Players.PlayerAdded:Connect(function(targetPlayer)
    if targetPlayer == player then return end

    createESP(targetPlayer)
    create3DBox(targetPlayer)

    if chamsEnabled and targetPlayer.Character then
        task.wait(0.3)
        createChams(targetPlayer)
    end

    targetPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        removeESP(targetPlayer)
        removeChams(targetPlayer)
        remove3DBox(targetPlayer)
        task.wait(0.1)
        createESP(targetPlayer)
        create3DBox(targetPlayer)
        if chamsEnabled then
            task.wait(0.3)
            createChams(targetPlayer)
        end
        local hum = character:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                task.wait(0.5)
                removeESP(targetPlayer)
                remove3DBox(targetPlayer)
                removeChams(targetPlayer)
            end)
        end
    end)

    targetPlayer.CharacterRemoving:Connect(function()
        task.wait(0.1)
        removeESP(targetPlayer)
        remove3DBox(targetPlayer)
        removeChams(targetPlayer)
    end)
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
    removeESP(targetPlayer)
    removeChams(targetPlayer)
    remove3DBox(targetPlayer)
    -- Clean up resolver data for leaving players
    resolverHistory[targetPlayer] = nil
    resolverDetectedModes[targetPlayer] = nil
    resolverConfidenceScores[targetPlayer] = nil
    resolverLastShotTime[targetPlayer] = nil
    backtrackRecords[targetPlayer] = nil
end)

local function refreshPlayer(targetPlayer)
    removeESP(targetPlayer)
    removeChams(targetPlayer)
    remove3DBox(targetPlayer)
    createESP(targetPlayer)
    create3DBox(targetPlayer)
    if chamsEnabled and targetPlayer.Character then
        task.wait(0.3)
        createChams(targetPlayer)
    end
end

for _, targetPlayer in pairs(Players:GetPlayers()) do
    if targetPlayer ~= player then
        targetPlayer:GetPropertyChangedSignal("Team"):Connect(function()
            task.wait(0.1)
            refreshPlayer(targetPlayer)
        end)
    end
end

Players.PlayerAdded:Connect(function(targetPlayer)
    if targetPlayer == player then
        targetPlayer:GetPropertyChangedSignal("Team"):Connect(function()
            task.wait(0.1)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    refreshPlayer(p)
                end
            end
        end)
        return
    end
    targetPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        task.wait(0.1)
        refreshPlayer(targetPlayer)
    end)
end)

player:GetPropertyChangedSignal("Team"):Connect(function()
    task.wait(0.1)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            refreshPlayer(p)
        end
    end
end)

local _espFrame = 0
RunService.Heartbeat:Connect(function()
    _espFrame = _espFrame + 1
    if _espFrame % 2 == 0 then
        pcall(updateESP)
        pcall(updateChams)
    end
    if _espFrame % 3 == 0 then
        pcall(update3DBox)
        pcall(updateRadar)
    end
end)

local FOV_SIDES = 10
local fovAngle = 0
local fovAngleSpeed = 1.2

local fovPolygons = {
    aimbot   = {lines = {}, glows = {}, visible = false, radius = 100, color = Color3.fromRGB(232, 97, 154)},
    silent   = {lines = {}, glows = {}, visible = false, radius = 120, color = Color3.fromRGB(232, 97, 154)},
    killaura = {lines = {}, glows = {}, visible = false, radius = 150, color = Color3.fromRGB(232, 97, 154)},
}

local function initFovPolygons()
    for _, poly in pairs(fovPolygons) do
        for _, l in ipairs(poly.lines) do pcall(function() l:Remove() end) end
        for _, l in ipairs(poly.glows) do pcall(function() l:Remove() end) end
        poly.lines = {}
        poly.glows = {}
        for i = 1, FOV_SIDES do
            local glow = Drawing.new("Line")
            glow.Thickness = 5
            glow.Transparency = 0.18
            glow.Visible = false
            glow.ZIndex = 5
            table.insert(poly.glows, glow)
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Transparency = 1
            line.Visible = false
            line.ZIndex = 6
            table.insert(poly.lines, line)
        end
    end
end
initFovPolygons()

local function updateFovPolygon(poly, cx, cy)
    if not poly.visible then
        for _, l in ipairs(poly.lines) do l.Visible = false end
        for _, l in ipairs(poly.glows) do l.Visible = false end
        return
    end
    local r = poly.radius
    local col = poly.color
    local glowCol = Color3.fromRGB(
        math.min(col.R * 255 + 60, 255),
        math.min(col.G * 255 + 40, 255),
        math.min(col.B * 255 + 60, 255)
    )
    for i = 1, FOV_SIDES do
        local a1 = math.rad((360 / FOV_SIDES) * (i - 1) + fovAngle)
        local a2 = math.rad((360 / FOV_SIDES) * i + fovAngle)
        local p1 = Vector2.new(cx + math.cos(a1) * r, cy + math.sin(a1) * r)
        local p2 = Vector2.new(cx + math.cos(a2) * r, cy + math.sin(a2) * r)
        poly.glows[i].From = p1
        poly.glows[i].To = p2
        poly.glows[i].Color = glowCol
        poly.glows[i].Visible = true
        poly.lines[i].From = p1
        poly.lines[i].To = p2
        poly.lines[i].Color = col
        poly.lines[i].Visible = true
    end
end

local function createCrosshairDrawings()
    for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end
    crosshairDrawings = {}
    for i = 1, 8 do
        local d = Drawing.new("Line")
        d.Visible = false
        d.ZIndex = 10
        table.insert(crosshairDrawings, d)
    end
end
createCrosshairDrawings()

local _chAngle = 0
local TweenService = game:GetService("TweenService")

local function solve(angle, radius, cx, cy)
    return Vector2.new(cx + math.sin(math.rad(angle)) * radius, cy + math.cos(math.rad(angle)) * radius)
end

local function updateCrosshair()
    for _, d in pairs(crosshairDrawings) do d.Visible = false end
    if not crosshairEnabled then return end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local pos = UserInputService:GetMouseLocation()
    local cx, cy = pos.X, pos.Y
    local t = tick()

    for idx = 1, 4 do
        local outline = crosshairDrawings[idx]
        local inline = crosshairDrawings[idx + 4]
        local angle = (idx - 1) * 90
        local length = crosshairLength

        if crosshairSpin then
            local spinAngle = -t * crosshairSpinSpeed % crosshairSpinMax
            angle = angle + TweenService:GetValue(spinAngle / 360, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) * 360
        end

        if crosshairResize then
            local resizeLen = t * crosshairResizeSpeed % 180
            length = crosshairResizeMin + math.sin(math.rad(resizeLen)) * crosshairResizeMax
        end

        inline.Visible = true
        inline.Color = crosshairColor
        inline.From = solve(angle, crosshairRadius, cx, cy)
        inline.To = solve(angle, crosshairRadius + length, cx, cy)
        inline.Thickness = crosshairWidth

        outline.Visible = false
    end
end

local function createOverlay()
    if overlayDrawing then pcall(function() overlayDrawing:Remove() end) end
    overlayDrawing = Drawing.new("Text")
    overlayDrawing.Visible = false
    overlayDrawing.Font = Drawing.Fonts.Plex
    overlayDrawing.Size = 14
    overlayDrawing.Color = Color3.fromRGB(255, 255, 255)
    overlayDrawing.Outline = true
    overlayDrawing.OutlineColor = Color3.fromRGB(0, 0, 0)
    overlayDrawing.ZIndex = 8
end
createOverlay()

local function createKeybindsDrawings()
    for _, d in pairs(keybindsDrawings) do pcall(function() d:Remove() end) end
    keybindsDrawings = {}
    local bg = Drawing.new("Square")
    bg.Filled = true
    bg.Color = Color3.fromRGB(15, 8, 12)
    bg.Transparency = 0.55
    bg.Visible = false
    bg.ZIndex = 18
    keybindsDrawings.bg = bg

    local border = Drawing.new("Square")
    border.Filled = false
    border.Color = Color3.fromRGB(232, 97, 154)
    border.Thickness = 1
    border.Transparency = 1
    border.Visible = false
    border.ZIndex = 19
    keybindsDrawings.border = border

    local topLine = Drawing.new("Line")
    topLine.Color = Color3.fromRGB(232, 97, 154)
    topLine.Thickness = 2
    topLine.Transparency = 1
    topLine.Visible = false
    topLine.ZIndex = 20
    keybindsDrawings.topLine = topLine

    local title = Drawing.new("Text")
    title.Text = "KEYBINDS"
    title.Font = Drawing.Fonts.Plex
    title.Size = 13
    title.Color = Color3.fromRGB(232, 97, 154)
    title.Outline = true
    title.OutlineColor = Color3.fromRGB(0, 0, 0)
    title.Center = false
    title.Visible = false
    title.ZIndex = 20
    keybindsDrawings.title = title

    keybindsDrawings.rows = {}
    for i = 1, 10 do
        local t = Drawing.new("Text")
        t.Font = Drawing.Fonts.Plex
        t.Size = 12
        t.Color = Color3.fromRGB(255, 180, 210)
        t.Outline = true
        t.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.Center = false
        t.Visible = false
        t.ZIndex = 20
        table.insert(keybindsDrawings.rows, t)
    end
end
createKeybindsDrawings()

local lockIndicatorPos = {x = 20, y = 20}

local function createLockIndicatorDrawings()
    for k, d in pairs(lockIndicatorDrawings) do
        if type(d) ~= "table" then pcall(function() d:Remove() end) end
    end
    lockIndicatorDrawings = {}

    if lockIndicatorGui then pcall(function() lockIndicatorGui:Destroy() end) end
    lockIndicatorGui = Instance.new("ScreenGui")
    lockIndicatorGui.Name = "WraithLockIndicator"
    lockIndicatorGui.ResetOnSpawn = false
    lockIndicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    lockIndicatorGui.DisplayOrder = 55
    lockIndicatorGui.Enabled = false
    lockIndicatorGui.Parent = game:GetService("CoreGui")

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 260, 0, 90)
    panel.Position = UDim2.new(1, -280, 0.5, -45)
    panel.BackgroundColor3 = Color3.fromRGB(12, 6, 10)
    panel.BackgroundTransparency = 0.3
    panel.BorderSizePixel = 0
    panel.ZIndex = 2
    panel.Parent = lockIndicatorGui
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 6)
    panelCorner.Parent = panel
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(232, 97, 154)
    panelStroke.Thickness = 1.5
    panelStroke.Parent = panel
    lockIndicatorDrawings.panel = panel

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -12)
    accentBar.Position = UDim2.new(0, 6, 0, 6)
    accentBar.BackgroundColor3 = Color3.fromRGB(232, 97, 154)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 3
    accentBar.Parent = panel
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar

    local thumbFrame = Instance.new("Frame")
    thumbFrame.Size = UDim2.new(0, 68, 0, 68)
    thumbFrame.Position = UDim2.new(0, 16, 0.5, -34)
    thumbFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 18)
    thumbFrame.BorderSizePixel = 0
    thumbFrame.ZIndex = 3
    thumbFrame.Parent = panel
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 5)
    thumbCorner.Parent = thumbFrame
    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Color = Color3.fromRGB(232, 97, 154)
    thumbStroke.Thickness = 1
    thumbStroke.Parent = thumbFrame

    lockIndicatorThumb = Instance.new("ImageLabel")
    lockIndicatorThumb.Size = UDim2.new(1, 0, 1, 0)
    lockIndicatorThumb.BackgroundTransparency = 1
    lockIndicatorThumb.ZIndex = 4
    lockIndicatorThumb.Parent = thumbFrame
    local thumbImgCorner = Instance.new("UICorner")
    thumbImgCorner.CornerRadius = UDim.new(0, 5)
    thumbImgCorner.Parent = lockIndicatorThumb

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 160, 0, 22)
    nameLabel.Position = UDim2.new(0, 92, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = ""
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.ZIndex = 4
    nameLabel.Parent = panel
    lockIndicatorDrawings.nameLabel = nameLabel

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(0, 160, 0, 18)
    distLabel.Position = UDim2.new(0, 92, 0, 30)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.TextStrokeTransparency = 0.5
    distLabel.ZIndex = 4
    distLabel.Parent = panel
    lockIndicatorDrawings.distLabel = distLabel

    local hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HpLabel"
    hpLabel.Size = UDim2.new(0, 160, 0, 16)
    hpLabel.Position = UDim2.new(0, 92, 0, 48)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = ""
    hpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hpLabel.TextSize = 11
    hpLabel.Font = Enum.Font.Gotham
    hpLabel.TextXAlignment = Enum.TextXAlignment.Left
    hpLabel.TextStrokeTransparency = 0.6
    hpLabel.ZIndex = 4
    hpLabel.Parent = panel
    lockIndicatorDrawings.hpLabel = hpLabel

    local hpBGFrame = Instance.new("Frame")
    hpBGFrame.Size = UDim2.new(0, 155, 0, 7)
    hpBGFrame.Position = UDim2.new(0, 92, 0, 66)
    hpBGFrame.BackgroundColor3 = Color3.fromRGB(30, 15, 22)
    hpBGFrame.BorderSizePixel = 0
    hpBGFrame.ZIndex = 3
    hpBGFrame.Parent = panel
    local hpBGCorner = Instance.new("UICorner")
    hpBGCorner.CornerRadius = UDim.new(0, 3)
    hpBGCorner.Parent = hpBGFrame

    local hpBarFrame = Instance.new("Frame")
    hpBarFrame.Name = "HpBar"
    hpBarFrame.Size = UDim2.new(1, 0, 1, 0)
    hpBarFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
    hpBarFrame.BorderSizePixel = 0
    hpBarFrame.ZIndex = 4
    hpBarFrame.Parent = hpBGFrame
    local hpBarCorner = Instance.new("UICorner")
    hpBarCorner.CornerRadius = UDim.new(0, 3)
    hpBarCorner.Parent = hpBarFrame
    lockIndicatorDrawings.hpBar = hpBarFrame

    local dragging = false
    local dragStart = nil
    local startPos = nil
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    panel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            panel.Position = UDim2.new(0, newX, 0, newY)
            lockIndicatorPos.x = newX
            lockIndicatorPos.y = newY
        end
    end)
    panel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
createLockIndicatorDrawings()

local fpsClock = 0
local fpsCount = 0
local fpsDisplay = 0
local function updateOverlay(dt)
    if not overlayEnabled then
        if overlayDrawing then overlayDrawing.Visible = false end
        return
    end
    fpsClock = fpsClock + dt
    fpsCount = fpsCount + 1
    if fpsClock >= 0.5 then
        fpsDisplay = math.floor(fpsCount / fpsClock)
        fpsCount = 0
        fpsClock = 0
    end
    local t = os.date("*t")
    local timeStr = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
    local camera = workspace.CurrentCamera
    if not camera then return end
    overlayDrawing.Text = string.format("FPS: %d  |  %s", fpsDisplay, timeStr)
    overlayDrawing.Position = Vector2.new(8, 8)
    overlayDrawing.Visible = true
end

local function updateKeybinds()
    if not keybindsEnabled then
        if keybindsDrawings.bg then keybindsDrawings.bg.Visible = false end
        if keybindsDrawings.border then keybindsDrawings.border.Visible = false end
        if keybindsDrawings.topLine then keybindsDrawings.topLine.Visible = false end
        if keybindsDrawings.title then keybindsDrawings.title.Visible = false end
        if keybindsDrawings.rows then
            for _, r in ipairs(keybindsDrawings.rows) do r.Visible = false end
        end
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local vp = camera.ViewportSize

    local features = {}
    if aimbotEnabled then
        local keyStr = ""
        if aimbotMode == "Hold" or aimbotMode == "Toggle" then
            keyStr = aimbotKeybind.Name
        else
            keyStr = "Always"
        end
        table.insert(features, {name = "Aimbot", key = keyStr})
    end
    if silentAimEnabled then table.insert(features, {name = "Silent Aim", key = "M1"}) end
    if espEnabled then table.insert(features, {name = "ESP", key = ""}) end
    if chamsEnabled then table.insert(features, {name = "Chams", key = ""}) end
    if flyEnabled then table.insert(features, {name = "Fly", key = "WASD"}) end
    if noclipEnabled then table.insert(features, {name = "Noclip", key = ""}) end
    if spinbotEnabled then table.insert(features, {name = "Spinbot", key = ""}) end
    if antiAimEnabled then table.insert(features, {name = "Anti Aim", key = ""}) end
    if killAuraEnabled then table.insert(features, {name = "Kill Aura", key = ""}) end
    if crosshairEnabled then table.insert(features, {name = "Crosshair", key = ""}) end
    if radarEnabled then table.insert(features, {name = "Radar", key = ""}) end

    local rowH = 16
    local padX = 10
    local padY = 8
    local titleH = 20
    local panelW = 130
    local panelH = titleH + padY + #features * rowH + padY
    local px = vp.X - panelW - 12
    local py = vp.Y / 2 - panelH / 2

    keybindsDrawings.bg.Position = Vector2.new(px, py)
    keybindsDrawings.bg.Size = Vector2.new(panelW, panelH)
    keybindsDrawings.bg.Visible = true

    keybindsDrawings.border.Position = Vector2.new(px, py)
    keybindsDrawings.border.Size = Vector2.new(panelW, panelH)
    keybindsDrawings.border.Visible = true

    keybindsDrawings.topLine.From = Vector2.new(px, py + titleH)
    keybindsDrawings.topLine.To = Vector2.new(px + panelW, py + titleH)
    keybindsDrawings.topLine.Visible = true

    keybindsDrawings.title.Text = "KEYBINDS"
    keybindsDrawings.title.Position = Vector2.new(px + padX, py + 4)
    keybindsDrawings.title.Visible = true

    for i, row in ipairs(keybindsDrawings.rows) do
        local feat = features[i]
        if feat then
            local label = feat.key ~= "" and (feat.name .. "  [" .. feat.key .. "]") or feat.name
            row.Text = label
            row.Position = Vector2.new(px + padX, py + titleH + padY + (i - 1) * rowH)
            row.Visible = true
        else
            row.Visible = false
        end
    end
end

local _lastThumbId = ""
local function updateLockIndicator()
    local function hideAll()
        if lockIndicatorGui then lockIndicatorGui.Enabled = false end
    end

    if not lockIndicatorEnabled then hideAll() return end

    local target = aimbotLockedTarget
    if not target or not target.Character then hideAll() return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then hideAll() return end

    if lockIndicatorGui then lockIndicatorGui.Enabled = true end

    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local dist = localRoot and math.floor((localRoot.Position - hrp.Position).Magnitude) or 0
    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

    if lockIndicatorDrawings.nameLabel then
        lockIndicatorDrawings.nameLabel.Text = target.DisplayName ~= target.Name
            and (target.DisplayName .. "  (@" .. target.Name .. ")")
            or target.Name
    end

    if lockIndicatorDrawings.distLabel then
        lockIndicatorDrawings.distLabel.Text = dist .. " studs"
    end

    if lockIndicatorDrawings.hpLabel then
        lockIndicatorDrawings.hpLabel.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    end

    if lockIndicatorDrawings.hpBar then
        local r2, g2
        if hp > 0.5 then
            local t2 = (hp - 0.5) * 2
            r2 = math.floor(255 * (1 - t2))
            g2 = 210
        else
            local t2 = hp * 2
            r2 = 220
            g2 = math.floor(210 * t2)
        end
        lockIndicatorDrawings.hpBar.BackgroundColor3 = Color3.fromRGB(r2, g2, 0)
        lockIndicatorDrawings.hpBar.Size = UDim2.new(math.max(0.01, hp), 0, 1, 0)
    end

    if lockIndicatorThumb then
        local thumbId = tostring(target.UserId)
        if _lastThumbId ~= thumbId then
            _lastThumbId = thumbId
            task.spawn(function()
                local ok, url = pcall(function()
                    return Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and lockIndicatorThumb then
                    lockIndicatorThumb.Image = url
                end
            end)
        end
    end
end

local function createScopeLines()
    for _, l in pairs(scopeLines) do pcall(function() l:Remove() end) end
    scopeLines = {}
    for i = 1, 6 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Color = Color3.fromRGB(0, 0, 0)
        l.Thickness = 1
        l.Transparency = 0.85
        l.ZIndex = 7
        table.insert(scopeLines, l)
    end
    for i = 1, 4 do
        local sq = Drawing.new("Square")
        sq.Visible = false
        sq.Color = Color3.fromRGB(0, 0, 0)
        sq.Filled = true
        sq.Transparency = 0.5
        sq.ZIndex = 6
        table.insert(scopeLines, sq)
    end
end
createScopeLines()

local function updateScope()
    local allVis = scopeEnabled
    local camera = workspace.CurrentCamera
    if not camera then
        for _, l in pairs(scopeLines) do l.Visible = false end
        return
    end
    local vx = camera.ViewportSize.X
    local vy = camera.ViewportSize.Y
    local cx, cy = vx / 2, vy / 2
    local r = math.min(vx, vy) * 0.42

    local lines = {
        {Vector2.new(0, cy),        Vector2.new(cx - r, cy)},
        {Vector2.new(cx + r, cy),   Vector2.new(vx, cy)},
        {Vector2.new(cx, 0),        Vector2.new(cx, cy - r)},
        {Vector2.new(cx, cy + r),   Vector2.new(cx, vy)},
        {Vector2.new(cx - 6, cy),   Vector2.new(cx + 6, cy)},
        {Vector2.new(cx, cy - 6),   Vector2.new(cx, cy + 6)},
    }
    for i, l in ipairs(lines) do
        if scopeLines[i] then
            scopeLines[i].From = l[1]
            scopeLines[i].To = l[2]
            scopeLines[i].Visible = allVis
        end
    end
    local vignettes = {
        {pos = Vector2.new(0, 0),        size = Vector2.new(cx - r, vy)},
        {pos = Vector2.new(cx + r, 0),   size = Vector2.new(vx - cx - r, vy)},
        {pos = Vector2.new(cx - r, 0),   size = Vector2.new(r * 2, cy - r)},
        {pos = Vector2.new(cx - r, cy + r), size = Vector2.new(r * 2, vy - cy - r)},
    }
    for i, v in ipairs(vignettes) do
        local sq = scopeLines[6 + i]
        if sq then
            sq.Position = v.pos
            sq.Size = v.size
            sq.Visible = allVis
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    updateCrosshair()
    updateOverlay(dt)
    updateScope()
    pcall(updateKeybinds)
    pcall(updateLockIndicator)
end)

local function updateThirdPerson()
end

local spinAngle = 0
local function updateSpinbot()
    if not spinbotEnabled then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    spinAngle = (spinAngle + spinbotSpeed * 0.5) % 360
    humanoid.AutoRotate = false

    local pos = hrp.Position
    local rot = CFrame.Angles(0, math.rad(spinAngle), 0)

    pcall(function() hrp.CFrame = CFrame.new(pos) * rot end)

    local rootJoint = hrp:FindFirstChild("RootJoint")
    if rootJoint then
        pcall(function() rootJoint.C0 = CFrame.new(0,0,0) * rot end)
    end

    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then
        local rootMotor = lowerTorso:FindFirstChild("Root")
        if rootMotor then
            pcall(function() rootMotor.C0 = CFrame.new(0,0,0) * rot end)
        end
    end
end

RunService:BindToRenderStep("BLSpinbot", Enum.RenderPriority.Last.Value, function()
    pcall(updateSpinbot)
end)

local function updateOrbit()
    if not orbitEnabled then return end
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    if orbitTargetName == "Closest" then
        if not orbitTarget or not orbitTarget.Character or not orbitTarget.Character:FindFirstChild("HumanoidRootPart") then
            local closestPlayer = nil
            local closestDistance = math.huge

            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if orbitTeamCheck and targetPlayer.Team == player.Team then end
                    if not orbitTeamCheck or targetPlayer.Team ~= player.Team then
                        local distance = (humanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = targetPlayer
                        end
                    end
                end
            end

            orbitTarget = closestPlayer
        end
    else
        local foundPlayer = Players:FindFirstChild(orbitTargetName)
        if foundPlayer and foundPlayer ~= player then
            if orbitTeamCheck and foundPlayer.Team == player.Team then
                orbitTarget = nil
            else
                orbitTarget = foundPlayer
            end
        else
            orbitTarget = nil
        end
    end

    if orbitTarget and orbitTarget.Character and orbitTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = orbitTarget.Character.HumanoidRootPart

        orbitAngle = orbitAngle + (orbitSpeed * 0.1)
        if orbitAngle >= 360 then orbitAngle = 0 end

        local x = math.cos(math.rad(orbitAngle)) * orbitRadius
        local z = math.sin(math.rad(orbitAngle)) * orbitRadius

        local newPosition = targetRoot.Position + Vector3.new(x, orbitHeight, z)
        humanoidRootPart.CFrame = CFrame.new(newPosition, targetRoot.Position)
    end
end

RunService.Heartbeat:Connect(updateOrbit)

local function stopFly()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
end

local function updateFly()
    if not flyEnabled then
        stopFly()
        return
    end

    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end

    local camera = workspace.CurrentCamera
    local moveDirection = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end

    local finalVelocity = moveDirection.Magnitude > 0 and moveDirection.Unit * flySpeed or Vector3.new(0, 0, 0)

    if flyMethod == "BodyVelocity" then
        if not flyBodyVelocity or not flyBodyVelocity.Parent then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.Parent = humanoidRootPart
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBodyGyro.P = 1e4
            flyBodyGyro.D = 100
            flyBodyGyro.Parent = humanoidRootPart
        end

        flyBodyVelocity.Velocity = finalVelocity
        flyBodyGyro.CFrame = camera.CFrame

    elseif flyMethod == "CFrame" then
        stopFly()
        if moveDirection.Magnitude > 0 then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + (moveDirection.Unit * (flySpeed * 0.1))
        end
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    elseif flyMethod == "Tween" then
        stopFly()
        if moveDirection.Magnitude > 0 then
            local targetPos = humanoidRootPart.Position + (moveDirection.Unit * (flySpeed * 0.1))
            humanoidRootPart.CFrame = CFrame.new(targetPos)
        end
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    humanoid.PlatformStand = true
end

RunService.Heartbeat:Connect(updateFly)

local function updateVelocity()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if walkSpeedEnabled then
        humanoid.WalkSpeed = walkSpeedValue
    end

    if jumpPowerEnabled then
        if humanoid.UseJumpPower then
            humanoid.JumpPower = jumpPowerValue
        else
            humanoid.JumpHeight = jumpPowerValue / 5
        end
    end
end

RunService.Heartbeat:Connect(updateVelocity)

local function applyWalkSpeed(humanoid)
    if not walkSpeedEnabled then return end
    humanoid.WalkSpeed = walkSpeedValue
end

local function bindWalkSpeedSignal(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        applyWalkSpeed(humanoid)
    end)
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if jumpPowerEnabled and humanoid.UseJumpPower then
            humanoid.JumpPower = jumpPowerValue
        end
    end)
end

player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    updateVelocity()
    bindWalkSpeedSignal(character)
end)

if player.Character then
    bindWalkSpeedSignal(player.Character)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function updateNoclip()
    if not noclipEnabled then
        stopNoclip()
        return
    end

    local character = player.Character
    if not character then return end

    if noclipMethod == "CanCollide" or noclipMethod == "Velocity" then
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled and character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function stopInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

local function updateInfiniteJump()
    if not infiniteJumpEnabled then
        stopInfiniteJump()
        return
    end

    stopInfiniteJump()

    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

local function stopAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

local function updateAntiAFK()
    if not antiAFKEnabled then
        stopAntiAFK()
        return
    end

    stopAntiAFK()

    antiAFKConnection = game:GetService("VirtualUser").Button1Down:Connect(function()
    end)

    task.spawn(function()
        while antiAFKEnabled do
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            task.wait(300)
        end
    end)
end

local function stopBunnyHop()
    if bunnyHopConnection then
        bunnyHopConnection:Disconnect()
        bunnyHopConnection = nil
    end
end

local function updateBunnyHop()
    if not bunnyHopEnabled then
        stopBunnyHop()
        return
    end

    stopBunnyHop()

    bunnyHopConnection = RunService.Heartbeat:Connect(function()
        if bunnyHopEnabled then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end)
end

local function updateAutoSprint()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if autoSprintEnabled then
        if humanoid.MoveDirection.Magnitude > 0 then
            humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or math.max(humanoid.WalkSpeed, 20)
        end
    end
end

RunService.Heartbeat:Connect(updateAutoSprint)

local function removeTextures()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not originalTextures[obj] then
                originalTextures[obj] = {
                    Material = obj.Material,
                    Transparency = obj.Transparency,
                    Color = obj.Color
                }
            end
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 0.5
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if not originalTextures[obj] then
                originalTextures[obj] = {
                    Transparency = obj.Transparency
                }
            end
            obj.Transparency = 1
        end
    end
end


workspace.DescendantAdded:Connect(function(obj)
    if removeTexturesEnabled then
        task.wait(0.1)
        if obj:IsA("BasePart") then
            originalTextures[obj] = {
                Material = obj.Material,
                Transparency = obj.Transparency,
                Color = obj.Color
            }
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 0.5
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalTextures[obj] = {
                Transparency = obj.Transparency
            }
            obj.Transparency = 1
        end
    end

    if noWaterEnabled and obj:IsA("BasePart") and obj.Material == Enum.Material.Water then
        originalWaterParts[obj] = {
            Material = obj.Material,
            Transparency = obj.Transparency
        }
        obj.Material = Enum.Material.SmoothPlastic
        obj.Transparency = 1
    end
end)

local function removeWater()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Water then
            originalWaterParts[obj] = {
                Material = obj.Material,
                Transparency = obj.Transparency
            }
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 1
        end
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain:Clear()
    end
end

local function restoreWater()
    for obj, data in pairs(originalWaterParts) do
        if obj and obj.Parent then
            obj.Material = data.Material
            obj.Transparency = data.Transparency
        end
    end
    originalWaterParts = {}
end

local function enableWireframe()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local selection = Instance.new("SelectionBox")
            selection.Adornee = obj
            selection.LineThickness = 0.01
            selection.Color3 = Color3.fromRGB(0, 255, 0)
            selection.Parent = obj
            selection.Name = "WireframeBox"

            if not originalTextures[obj] then
                originalTextures[obj] = {
                    Transparency = obj.Transparency
                }
            end
            obj.Transparency = 0.9
        end
    end
end

local function disableWireframe()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SelectionBox") and obj.Name == "WireframeBox" then
            obj:Destroy()
        end
        if obj:IsA("BasePart") and originalTextures[obj] then
            obj.Transparency = originalTextures[obj].Transparency
        end
    end
end

local function saveLightingSettings()
    local lighting = game:GetService("Lighting")
    originalLighting = {
        Ambient = lighting.Ambient,
        Brightness = lighting.Brightness,
        ColorShift_Bottom = lighting.ColorShift_Bottom,
        ColorShift_Top = lighting.ColorShift_Top,
        OutdoorAmbient = lighting.OutdoorAmbient,
        FogEnd = lighting.FogEnd,
        FogStart = lighting.FogStart,
        GlobalShadows = lighting.GlobalShadows,
        ClockTime = lighting.ClockTime
    }
end

local function restoreLightingSettings()
    local lighting = game:GetService("Lighting")
    if originalLighting.Ambient then
        lighting.Ambient = originalLighting.Ambient
        lighting.Brightness = originalLighting.Brightness
        lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        lighting.ColorShift_Top = originalLighting.ColorShift_Top
        lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        lighting.FogEnd = originalLighting.FogEnd
        lighting.FogStart = originalLighting.FogStart
        lighting.GlobalShadows = originalLighting.GlobalShadows
        lighting.ClockTime = originalLighting.ClockTime
    end
end



local flingActive = false
local flingPower = 10000

local function startTouchFling()
    flingActive = true
    task.spawn(function()
        local c, hrp, vel, movel = nil, nil, nil, 0.1
        while flingActive do
            RunService.Heartbeat:Wait()
            c = player.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")
            if c and hrp then
                vel = hrp.Velocity
                hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
                RunService.RenderStepped:Wait()
                if c and c.Parent and hrp and hrp.Parent then
                    hrp.Velocity = vel
                end
                RunService.Stepped:Wait()
                if c and c.Parent and hrp and hrp.Parent then
                    hrp.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = movel * -1
                end
            end
        end
    end)
end

local function stopTouchFling()
    flingActive = false
end

local function saveWaypoint(name)
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    waypoints[name] = humanoidRootPart.CFrame

    if waypointDots[name] then
        pcall(function() waypointDots[name]:Destroy() end)
        waypointDots[name] = nil
    end

    local dot = Instance.new("Part")
    dot.Name = "WaypointDot_" .. name
    dot.Size = Vector3.new(0.4, 0.4, 0.4)
    dot.Shape = Enum.PartType.Ball
    dot.Material = Enum.Material.Neon
    dot.Color = Color3.fromRGB(0, 120, 212)
    dot.Anchored = true
    dot.CanCollide = false
    dot.CastShadow = false
    dot.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0)
    dot.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 80, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 1.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = dot

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.4
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    waypointDots[name] = dot

    Library:Notify('Waypoint "' .. name .. '" saved!', 3)
end

local function loadWaypoint(name)
    if not waypoints[name] then
        Library:Notify('Waypoint "' .. name .. '" not found!', 3)
        return
    end

    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    humanoidRootPart.CFrame = waypoints[name]
    Library:Notify('Teleported to "' .. name .. '"!', 3)
end

local function deleteWaypoint(name)
    if waypoints[name] then
        waypoints[name] = nil
        if waypointDots[name] then
            pcall(function() waypointDots[name]:Destroy() end)
            waypointDots[name] = nil
        end
        Library:Notify('Waypoint "' .. name .. '" deleted!', 3)
    end
end

local function getWaypointList()
    local list = {}
    for name, _ in pairs(waypoints) do
        table.insert(list, name)
    end
    return list
end

local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local placeId = game.PlaceId

    Library:Notify('Finding new server...', 3)

    local success, result = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))

        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    return
                end
            end
        end
    end)

    if not success then
        Library:Notify('Server hop failed! Trying alternative method...', 3)
        TeleportService:Teleport(placeId, player)
    end
end

local function rejoinServer()
    local TeleportService = game:GetService("TeleportService")
    Library:Notify('Rejoining server...', 3)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

local function copyJobId()
    if setclipboard then
        setclipboard(game.JobId)
        Library:Notify('Job ID copied to clipboard!', 3)
    else
        Library:Notify('Job ID: ' .. game.JobId, 10)
    end
end

local function takeScreenshot()
    if not game:GetService("GuiService") then
        Library:Notify('Screenshot not supported!', 3)
        return
    end

    Library:Notify('Taking screenshot...', 2)

    task.wait(0.5)

    Library:SetWatermarkVisibility(false)
    Library.Unloaded = true

    task.wait(0.1)

    if syn and syn.screenshot_game then
        syn.screenshot_game()
        Library:Notify('Screenshot saved!', 3)
    elseif KRNL_LOADED and KRNL.screenshot then
        KRNL.screenshot()
        Library:Notify('Screenshot saved!', 3)
    else
        Library:Notify('Screenshot function not available on this executor', 3)
    end

    task.wait(0.5)

    Library.Unloaded = false
    Library:SetWatermarkVisibility(true)
end

local function setFPSCap(value)
    if setfpscap then
        setfpscap(value)
        Library:Notify('FPS Cap set to ' .. (value == 0 and 'Unlimited' or value), 3)
    else
        Library:Notify('FPS Cap not supported on this executor', 3)
    end
end

local function enableLowGFX()
    local settings = UserSettings():GetService("UserGameSettings")

    settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    settings.MasterVolume = 0

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj.BlastPressure = 1
            obj.BlastRadius = 1
        end
        if obj:IsA("Sound") then
            obj.Volume = 0
        end
    end

    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9

    Library:Notify('Low GFX mode enabled', 3)
end

local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        table.insert(list, p.Name .. " (" .. p.DisplayName .. ")")
    end
    return table.concat(list, "\n")
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = aimbotFOV

    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()

    if aimbotLock and aimbotLockedTarget then
        local t = aimbotLockedTarget
        if t.Character and t.Character:FindFirstChild(aimbotTargetPart) then
            local hum = t.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return t
            end
        end
        aimbotLockedTarget = nil
    end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            if aimbotTeamCheck and targetPlayer.Team == player.Team then
            else
                local character = targetPlayer.Character
                local targetPart = character:FindFirstChild(aimbotTargetPart)
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if targetPart and humanoid and humanoid.Health > 0 then
                    local canAim = true
                    if aimbotVisibleCheck then
                        local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, camera})
                        if hit and not hit:IsDescendantOf(character) then
                            canAim = false
                        end
                    end
                    if canAim then
                        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = targetPlayer
                            end
                        end
                    end
                end
            end
        end
    end

    if aimbotLock and closestPlayer then
        aimbotLockedTarget = closestPlayer
    elseif not aimbotLock then
        aimbotLockedTarget = closestPlayer
    end

    return closestPlayer
end

local function saGetClosestTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = silentAimFOV
    local partName = silentAimTargetPart == "Head" and "Head" or "HumanoidRootPart"

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not silentAimTeamCheck or p.Team ~= player.Team then
                    local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local sp, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local passWall = true
                            if silentAimWallCheck then
                                local ray = Ray.new(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 1000)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, camera})
                                passWall = not hit or hit:IsDescendantOf(char)
                            end
                            if passWall then
                                local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closest = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local autoShootConnection = nil
local function updateAimbot()
    if not aimbotEnabled then return end

    local shouldAim = false
    if aimbotMode == "Always" then
        shouldAim = true
    elseif aimbotMode == "Hold" then
        shouldAim = UserInputService:IsKeyDown(aimbotKeybind)
    elseif aimbotMode == "Toggle" then
        shouldAim = aimbotToggleState
    end

    if not shouldAim then return end

    local target = getClosestPlayer()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(aimbotTargetPart)
        if targetPart then
            local camera = workspace.CurrentCamera
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local aimPos

            if resolverEnabled and targetHRP then
                local offset = getResolverOffset(target)
                local resolvedCF = targetHRP.CFrame * CFrame.Angles(0, math.rad(offset), 0)
                aimPos = resolvedCF * Vector3.new(0, 1.5, 0)
            else
                aimPos = targetPart.Position
            end

            if aimbotPrediction and targetHRP then
                local vel = targetHRP.AssemblyLinearVelocity
                aimPos = aimPos + vel * aimbotPredictionStrength
            end

            local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
            if not onScreen then return end

            local mousePos = UserInputService:GetMouseLocation()
            local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
            local delta = targetScreen - mousePos
            local smoothed = delta / aimbotSmoothing

            if mousemoverel and aimbotMethod == "Mouse Delta" then
                mousemoverel(smoothed.X, smoothed.Y)
            elseif aimbotMethod == "Camera Lerp" then
                local targetCFrame = CFrame.new(camera.CFrame.Position, aimPos)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / aimbotSmoothing)
            elseif aimbotMethod == "View Angle" then
                local targetCFrame = CFrame.new(camera.CFrame.Position, aimPos)
                local lerpFactor = math.clamp(1 / aimbotSmoothing, 0.01, 1)
                local newCF = camera.CFrame:Lerp(targetCFrame, lerpFactor)
                local _, yaw, _ = newCF:ToEulerAnglesYXZ()
                local _, pitch, _ = CFrame.new(camera.CFrame.Position, aimPos):ToEulerAnglesYXZ()
                camera.CFrame = CFrame.new(camera.CFrame.Position)
                    * CFrame.Angles(0, yaw, 0)
                    * CFrame.Angles(pitch, 0, 0)
            else
                local targetCFrame = CFrame.new(camera.CFrame.Position, aimPos)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / aimbotSmoothing)
            end

            if autoShootEnabled and mousemoverel then
                local dist = delta.Magnitude
                if dist < 8 then
                    mouse1press()
                    task.delay(autoShootDelay, function() mouse1release() end)
                end
            end
        end
    else
        if aimbotLock then
            aimbotLockedTarget = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if aimbotEnabled and aimbotMode == "Toggle" and input.KeyCode == aimbotKeybind then
        aimbotToggleState = not aimbotToggleState
        Library:Notify('Aimbot ' .. (aimbotToggleState and 'activated' or 'deactivated'), 2)
    end

    if jumpBugEnabled and input.KeyCode == Enum.KeyCode.Space then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.FloorMaterial ~= Enum.Material.Air then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 18, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end

    if backtrackEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local camera = workspace.CurrentCamera
        if not camera then return end
        local mousePos = UserInputService:GetMouseLocation()
        local closestPlayer = nil
        local closestDist = aimbotFOV
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local head = targetPlayer.Character:FindFirstChild("Head")
                local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local sp, vis = camera:WorldToViewportPoint(head.Position)
                    if vis then
                        local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = targetPlayer
                        end
                    end
                end
            end
        end
        if closestPlayer then
            applyBacktrack(closestPlayer)
        end
    end

    if silentAimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and player.Character then
        local camera = workspace.CurrentCamera
        if not camera then return end
        local targetPart = saGetClosestTarget()
        if targetPart and mousemoverel then
            local currentMouse = UserInputService:GetMouseLocation()
            local sp = camera:WorldToViewportPoint(targetPart.Position)
            local delta = Vector2.new(sp.X, sp.Y) - currentMouse
            mousemoverel(delta.X, delta.Y)
            task.delay(0.07, function()
                mousemoverel(-delta.X, -delta.Y)
            end)
        end
    end
end)

RunService.RenderStepped:Connect(updateAimbot)

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovAngle = fovAngle + fovAngleSpeed

    fovPolygons.aimbot.visible = aimbotEnabled and fovCircle.visible
    fovPolygons.aimbot.radius = aimbotFOV
    fovPolygons.aimbot.color = fovCircle.color
    updateFovPolygon(fovPolygons.aimbot, mousePos.X, mousePos.Y)

    fovPolygons.silent.visible = silentAimEnabled and silentAimFovCircle.visible
    fovPolygons.silent.radius = silentAimFOV
    fovPolygons.silent.color = silentAimFovCircle.color
    updateFovPolygon(fovPolygons.silent, mousePos.X, mousePos.Y)
end)

local function updateAntiAim(dt)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local anyAA = antiAimEnabled or jitterEnabled or backwardAAEnabled or customYawEnabled
    if not anyAA then
        humanoid.AutoRotate = true
        return
    end

    humanoid.AutoRotate = false
    local camera = workspace.CurrentCamera

    if antiAimEnabled then
        local targetAngle
        if antiAimMode == "Spin" then
            antiAimAngle = (antiAimAngle + antiAimSpeed) % 360
            targetAngle = antiAimAngle
        elseif antiAimMode == "Jitter" then
            targetAngle = (math.random() - 0.5) * 2 * antiAimSpeed * 3
        elseif antiAimMode == "Static" then
            targetAngle = 180
        end
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(targetAngle), 0)
        local joint = hrp:FindFirstChild("RootJoint")
        if joint then pcall(function() joint.C0 = CFrame.new(0,0,0) * CFrame.Angles(0, math.rad(targetAngle), 0) end) end
        local lowerTorso = character:FindFirstChild("LowerTorso")
        if lowerTorso then
            local rootMotor = lowerTorso:FindFirstChild("Root")
            if rootMotor then pcall(function() rootMotor.C0 = CFrame.new(0,0,0) * CFrame.Angles(0, math.rad(targetAngle), 0) end) end
        end
    elseif jitterEnabled then
        local now = tick()
        local switchDelay = 1 / jitterSpeed
        if now - lastJitterTime >= switchDelay then
            jitterToggleState = not jitterToggleState
            jitterCurrentAngle = jitterToggleState and jitterToAngle or jitterFromAngle
            lastJitterTime = now
        end
        local camLook = camera.CFrame.LookVector
        local yaw = math.rad(jitterCurrentAngle)
        local rotated = Vector3.new(
            camLook.X * math.cos(yaw) - camLook.Z * math.sin(yaw), 0,
            camLook.X * math.sin(yaw) + camLook.Z * math.cos(yaw)
        )
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + rotated)
    elseif backwardAAEnabled then
        local camPos = camera.CFrame.Position
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(camPos.X, hrp.Position.Y, camPos.Z))
    elseif customYawEnabled then
        local camLook = camera.CFrame.LookVector
        local yaw = math.rad(customYawAngle)
        local rotated = Vector3.new(
            camLook.X * math.cos(yaw) - camLook.Z * math.sin(yaw), 0,
            camLook.X * math.sin(yaw) + camLook.Z * math.cos(yaw)
        )
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + rotated)
    end
end

local rapidFireConnection = nil
local function updateRapidFire()
    if not rapidFireEnabled then
        if rapidFireConnection then
            rapidFireConnection:Disconnect()
            rapidFireConnection = nil
        end
        return
    end
    if rapidFireConnection then return end
    local character = player.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    rapidFireConnection = tool.Activated:Connect(function()
        for i = 1, 3 do
            task.wait(rapidFireDelay)
            pcall(function()
                tool.Activated:Fire()
            end)
        end
    end)
end

RunService:BindToRenderStep("BLAntiAim", Enum.RenderPriority.Last.Value, function(dt)
    pcall(updateAntiAim, dt)
end)
RunService.Heartbeat:Connect(updateRapidFire)

local function restoreWeaponMods()
    for t, orig in pairs(weaponModsCache) do
        for k, v in pairs(orig) do
            pcall(function() rawset(t, k, v) end)
        end
    end
    for obj, val in pairs(weaponValueCache) do
        pcall(function() obj.Value = val end)
    end
    table.clear(weaponModsCache)
    table.clear(weaponValueCache)
end

local function applyToolMod(obj)
    if not obj or not obj:IsA("ValueBase") then return end
    local name = string.lower(obj.Name)
    if noSpreadEnabled and (string.find(name, "spread") or string.find(name, "cone") or string.find(name, "bloom") or string.find(name, "scatter") or string.find(name, "error") or string.find(name, "inaccuracy")) then
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            if weaponValueCache[obj] == nil then weaponValueCache[obj] = obj.Value end
            if obj.Value ~= 0 then obj.Value = 0 end
        end
    end
    if noRecoilEnabled and (string.find(name, "recoil") or string.find(name, "kick") or string.find(name, "punch")) then
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            if weaponValueCache[obj] == nil then weaponValueCache[obj] = obj.Value end
            if obj.Value ~= 0 then obj.Value = 0 end
        end
    end
    if infiniteAmmoEnabled and (string.find(name, "ammo") or string.find(name, "clip") or string.find(name, "magazine") or string.find(name, "mag")) then
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            if weaponValueCache[obj] == nil then weaponValueCache[obj] = obj.Value end
            if obj.Value < 100 then obj.Value = 999 end
        end
    end
    if instantReloadEnabled and (string.find(name, "reload") or string.find(name, "equiptime") or string.find(name, "cooldown")) then
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleValue") then
            if weaponValueCache[obj] == nil then weaponValueCache[obj] = obj.Value end
            if obj.Value ~= 0 then obj.Value = 0 end
        end
    end
end

local weaponModsTimer = 0
local gcScanTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not noSpreadEnabled and not noRecoilEnabled and not infiniteAmmoEnabled and not instantReloadEnabled then return end
    
    weaponModsTimer = weaponModsTimer + dt
    if weaponModsTimer >= 0.2 then
        weaponModsTimer = 0
        local char = player.Character
        local backpack = player:FindFirstChild("Backpack")
        local items = {}
        if char then
            for _, v in ipairs(char:GetChildren()) do if v:IsA("Tool") then table.insert(items, v) end end
        end
        if backpack then
            for _, v in ipairs(backpack:GetChildren()) do if v:IsA("Tool") then table.insert(items, v) end end
        end
        for _, tool in ipairs(items) do
            for _, desc in ipairs(tool:GetDescendants()) do
                applyToolMod(desc)
            end
            pcall(function()
                for attrName, attrVal in pairs(tool:GetAttributes()) do
                    local lowerName = string.lower(attrName)
                    if noSpreadEnabled and (string.find(lowerName, "spread") or string.find(lowerName, "cone") or string.find(lowerName, "bloom") or string.find(lowerName, "inaccuracy")) then
                        if type(attrVal) == "number" and attrVal ~= 0 then tool:SetAttribute(attrName, 0) end
                    elseif noRecoilEnabled and (string.find(lowerName, "recoil") or string.find(lowerName, "kick")) then
                        if type(attrVal) == "number" and attrVal ~= 0 then tool:SetAttribute(attrName, 0) end
                    elseif infiniteAmmoEnabled and (string.find(lowerName, "ammo") or string.find(lowerName, "clip")) then
                        if type(attrVal) == "number" and attrVal < 100 then tool:SetAttribute(attrName, 999) end
                    elseif instantReloadEnabled and string.find(lowerName, "reload") then
                        if type(attrVal) == "number" and attrVal ~= 0 then tool:SetAttribute(attrName, 0) end
                    end
                end
            end)
        end
    end

    gcScanTimer = gcScanTimer + dt
    if gcScanTimer >= 1.5 then
        gcScanTimer = 0
        if type(getgc) == "function" then
            pcall(function()
                for _, t in pairs(getgc(true)) do
                    if type(t) == "table" then
                        if rawget(t, "Spread") or rawget(t, "MaxSpread") or rawget(t, "MinSpread") or rawget(t, "Recoil") or rawget(t, "Clip") or rawget(t, "Ammo") or rawget(t, "Cone") or rawget(t, "CameraKick") or rawget(t, "BulletSpread") or rawget(t, "AimSpread") or rawget(t, "Kick") then
                            if not weaponModsCache[t] then
                                weaponModsCache[t] = {}
                                for k, v in pairs(t) do
                                    if type(v) == "number" then weaponModsCache[t][k] = v end
                                end
                            end
                            if noSpreadEnabled then
                                if rawget(t, "Spread") then rawset(t, "Spread", 0) end
                                if rawget(t, "MinSpread") then rawset(t, "MinSpread", 0) end
                                if rawget(t, "MaxSpread") then rawset(t, "MaxSpread", 0) end
                                if rawget(t, "AimSpread") then rawset(t, "AimSpread", 0) end
                                if rawget(t, "HipSpread") then rawset(t, "HipSpread", 0) end
                                if rawget(t, "Cone") then rawset(t, "Cone", 0) end
                                if rawget(t, "ConeSpread") then rawset(t, "ConeSpread", 0) end
                                if rawget(t, "BulletSpread") then rawset(t, "BulletSpread", 0) end
                                if rawget(t, "Scatter") then rawset(t, "Scatter", 0) end
                                if rawget(t, "Inaccuracy") then rawset(t, "Inaccuracy", 0) end
                                if rawget(t, "Error") then rawset(t, "Error", 0) end
                                if rawget(t, "Bloom") then rawset(t, "Bloom", 0) end
                                if rawget(t, "SpreadAngle") then rawset(t, "SpreadAngle", 0) end
                            end
                            if noRecoilEnabled then
                                if rawget(t, "Recoil") then rawset(t, "Recoil", 0) end
                                if rawget(t, "MinRecoil") then rawset(t, "MinRecoil", 0) end
                                if rawget(t, "MaxRecoil") then rawset(t, "MaxRecoil", 0) end
                                if rawget(t, "CameraKick") then rawset(t, "CameraKick", 0) end
                                if rawget(t, "Kick") then rawset(t, "Kick", 0) end
                                if rawget(t, "GunKick") then rawset(t, "GunKick", 0) end
                                if rawget(t, "AimRecoil") then rawset(t, "AimRecoil", 0) end
                                if rawget(t, "Punch") then rawset(t, "Punch", 0) end
                                if rawget(t, "RecoilForce") then rawset(t, "RecoilForce", 0) end
                            end
                            if infiniteAmmoEnabled then
                                if rawget(t, "Ammo") and type(rawget(t, "Ammo")) == "number" then rawset(t, "Ammo", 9999) end
                                if rawget(t, "Clip") and type(rawget(t, "Clip")) == "number" then rawset(t, "Clip", 9999) end
                                if rawget(t, "MaxAmmo") and type(rawget(t, "MaxAmmo")) == "number" then rawset(t, "MaxAmmo", 9999) end
                                if rawget(t, "Magazine") and type(rawget(t, "Magazine")) == "number" then rawset(t, "Magazine", 9999) end
                                if rawget(t, "ClipSize") and type(rawget(t, "ClipSize")) == "number" then rawset(t, "ClipSize", 9999) end
                            end
                            if instantReloadEnabled then
                                if rawget(t, "ReloadTime") then rawset(t, "ReloadTime", 0) end
                                if rawget(t, "ReloadSpeed") then rawset(t, "ReloadSpeed", 0) end
                                if rawget(t, "ReloadDuration") then rawset(t, "ReloadDuration", 0) end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local function updateKillAura(dt)
    if not killAuraEnabled then return end
    killAuraTimer = killAuraTimer + dt
    if killAuraTimer < killAuraDelay then return end
    killAuraTimer = 0

    local camera = workspace.CurrentCamera
    if not camera then return end
    local mousePos = UserInputService:GetMouseLocation()

    local closestPlayer = nil
    local closestDist = killAuraFOV

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                if not killAuraTeamCheck or targetPlayer.Team ~= player.Team then
                    local sp, vis = camera:WorldToViewportPoint(head.Position)
                    if vis then
                        local passWall = true
                        if killAuraWallCheck then
                            local ray = Ray.new(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, targetPlayer.Character})
                            if hit then passWall = false end
                        end
                        if passWall then
                            local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPlayer = targetPlayer
                            end
                        end
                    end
                end
            end
        end
    end

    if closestPlayer and closestPlayer.Character then
        local head = closestPlayer.Character:FindFirstChild("Head")
        if head then
            local sp = camera:WorldToViewportPoint(head.Position)
            local targetScreen = Vector2.new(sp.X, sp.Y)
            local delta = targetScreen - mousePos
            if mousemoverel then
                mousemoverel(delta.X, delta.Y)
                task.wait()
                mouse1press()
                task.delay(0.05, function() mouse1release() end)
            else
                pcall(function()
                    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                end)
                mouse1press()
                task.delay(0.05, function() mouse1release() end)
            end
        end
    end
end

local function recordBacktrack()
    if not backtrackEnabled then
        backtrackRecords = {}
        return
    end
    local now = tick()
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if not backtrackRecords[targetPlayer] then
                    backtrackRecords[targetPlayer] = {}
                end

                local partPositions = {}
                for _, part in pairs(targetPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        partPositions[part.Name] = part.CFrame
                    end
                end

                table.insert(backtrackRecords[targetPlayer], {
                    cframe = hrp.CFrame,
                    parts = partPositions,
                    time = now
                })
                local records = backtrackRecords[targetPlayer]
                while #records > 0 and (now - records[1].time) > backtrackTime do
                    table.remove(records, 1)
                end
            end
        end
    end
end

local function getBacktrackCFrame(targetPlayer)
    local records = backtrackRecords[targetPlayer]
    if not records or #records == 0 then return nil end
    local camera = workspace.CurrentCamera
    if not camera then return records[#records].cframe end
    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return records[#records].cframe end
    local bestRecord = nil
    local bestScore = math.huge
    for _, record in ipairs(records) do
        local dist = (record.cframe.Position - localRoot.Position).Magnitude
        local _, onScreen = camera:WorldToViewportPoint(record.cframe.Position)
        local score = dist + (onScreen and 0 or 9999)
        if score < bestScore then
            bestScore = score
            bestRecord = record
        end
    end
    return bestRecord and bestRecord.cframe or records[#records].cframe
end

local function updateBacktrackAura()
    for _, d in pairs(backtrackAuraDrawings) do
        d.Visible = false
    end
    if not backtrackAuraEnabled or not backtrackEnabled then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local drawIdx = 0
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local records = backtrackRecords[targetPlayer]
            if records and #records > 0 then
                local bestCF = getBacktrackCFrame(targetPlayer)
                for i, record in ipairs(records) do
                    local screenPos, onScreen = camera:WorldToViewportPoint(record.cframe.Position)
                    if onScreen then
                        drawIdx = drawIdx + 1
                        if not backtrackAuraDrawings[drawIdx] then
                            local c = Drawing.new("Circle")
                            c.Thickness = 1
                            c.NumSides = 32
                            c.Filled = false
                            backtrackAuraDrawings[drawIdx] = c
                        end
                        local d = backtrackAuraDrawings[drawIdx]
                        local alpha = i / #records
                        local isBest = bestCF and (record.cframe.Position - bestCF.Position).Magnitude < 0.01
                        if isBest then
                            d.Color = Color3.fromRGB(255, 255, 100)
                            d.Thickness = 2
                            d.Radius = 12
                            d.Transparency = 1
                        else
                            d.Color = backtrackAuraColor
                            d.Thickness = 1
                            d.Transparency = 0.2 + alpha * 0.6
                            d.Radius = 6 + (1 - alpha) * 8
                        end
                        d.Position = Vector2.new(screenPos.X, screenPos.Y)
                        d.Visible = true
                    end
                end
            end
        end
    end
end

local function applyBacktrack(targetPlayer)
    if not backtrackEnabled then return end
    local records = backtrackRecords[targetPlayer]
    if not records or #records == 0 then return end
    local hrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bestCF = getBacktrackCFrame(targetPlayer)
    if not bestCF then return end
    local realCF = hrp.CFrame
    pcall(function() hrp.CFrame = bestCF end)
    task.delay(0.15, function()
        pcall(function()
            if hrp and hrp.Parent then
                hrp.CFrame = realCF
            end
        end)
    end)
end

local function updateAutoStrafe()
    if not autoStrafeEnabled then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if hum.MoveDirection.Magnitude < 0.1 then return end

    autoStrafeState = autoStrafeState + 1
    if autoStrafeState % 6 < 3 then
        hrp.CFrame = hrp.CFrame * CFrame.new(0.8, 0, 0)
    else
        hrp.CFrame = hrp.CFrame * CFrame.new(-0.8, 0, 0)
    end
end

local function updateFakeLag(dt)
    if not fakeLagEnabled then return end
    fakeLagTimer = fakeLagTimer + dt
    if fakeLagTimer >= (fakeLagStrength * 0.016) then
        fakeLagTimer = 0
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.CFrame = hrp.CFrame
                end)
            end
        end
    end
end

local function updateDesync()
    if not desyncEnabled then return end
    local character = player.Character
    if not character or not desyncSetback then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local camera = workspace.CurrentCamera

    desyncOldPosition = rootPart.CFrame

    if desyncMode == "Void" then
        desyncTeleportPosition = Vector3.new(
            rootPart.Position.X + math.random(-3044, 3044),
            rootPart.Position.Y + math.random(-4044, 4044),
            rootPart.Position.Z + math.random(-3044, 3044)
        )
    elseif desyncMode == "Underground" then
        desyncTeleportPosition = rootPart.Position - Vector3.new(0, 34, 0)
    elseif desyncMode == "Void Spam" then
        if math.random(1, 2) == 1 then
            desyncTeleportPosition = desyncOldPosition.Position
        else
            desyncTeleportPosition = Vector3.new(math.random(1000,5000), math.random(1000,5000), math.random(1000,5000))
        end
    end

    rootPart.CFrame = CFrame.new(desyncTeleportPosition)
    camera.CameraSubject = desyncSetback
    RunService.RenderStepped:Wait()
    desyncSetback.CFrame = desyncOldPosition * CFrame.new(0, rootPart.Size.Y / 2 + 0.5, 0)
    rootPart.CFrame = desyncOldPosition
end

local function updateLocalChams()
    local character = player.Character
    if not character then return end
    local h = character:FindFirstChild("WraithLocalChams")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "WraithLocalChams"
        h.Adornee = character
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = character
    end
    if not localChamsEnabled then
        h.Enabled = false
        return
    end
    h.Adornee = character
    h.Enabled = true
    h.FillColor = localChamsColor
    h.FillTransparency = 0
    h.OutlineTransparency = 1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function updateArmsChams()
    if not armsChamsEnabled then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    for _, model in ipairs(camera:GetChildren()) do
        if model:IsA("Model") and (model.Name == "Arms" or model.Name == "ViewModel") then
            local h = model:FindFirstChild("WraithArmsChams")
            if not h then
                h = Instance.new("Highlight")
                h.Name = "WraithArmsChams"
                h.Parent = model
            end
            h.Enabled = true
            h.FillColor = armsChamsColor
            h.OutlineColor = armsChamsColor
            h.FillTransparency = 0
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

task.spawn(function()
    desyncSetback = Instance.new("Part")
    desyncSetback.Name = "WraithDesyncSetback"
    desyncSetback.Anchored = true
    desyncSetback.CanCollide = false
    desyncSetback.Transparency = 1
    desyncSetback.Size = Vector3.new(0.1, 0.1, 0.1)
    desyncSetback.Parent = workspace
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(recordBacktrack)
    pcall(updateBacktrackAura)
    pcall(updateAutoStrafe)
    pcall(updateFakeLag, dt)
    pcall(updateKillAura, dt)
    pcall(updateDesync)
    pcall(updateLocalChams)
    pcall(updateArmsChams)
end)

local function updateHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                for _, partName in ipairs(hitboxParts) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        if hitboxEnabled then
                            if not hitboxOriginalSizes[part] then
                                hitboxOriginalSizes[part] = part.Size
                            end
                            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            part.Transparency = 1
                        else
                            if hitboxOriginalSizes[part] then
                                part.Size = hitboxOriginalSizes[part]
                                hitboxOriginalSizes[part] = nil
                            end
                        end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if hitboxEnabled then pcall(updateHitbox) end
end)

local function getResolverOffset(targetPlayer)
    if not resolverEnabled then return 0 end
    local hist = resolverHistory[targetPlayer]
    if not hist or #hist < 3 then return 0 end
    local detectedMode = resolverDetectedModes[targetPlayer] or "None"
    local confidence = resolverConfidenceScores[targetPlayer] or 0
    if confidence < resolverConfidenceThreshold then return 0 end
    if detectedMode == "Spin" then
        local lastAngle = hist[#hist].angle
        local prevAngle = hist[#hist - 1].angle
        local delta = lastAngle - prevAngle
        if math.abs(delta) > 180 then delta = delta > 0 and delta - 360 or delta + 360 end
        return 180 + delta * -0.5
    elseif detectedMode == "Jitter" then
        local sum = 0
        local count = math.min(#hist, 6)
        for i = #hist - count + 1, #hist do
            sum = sum + hist[i].angle
        end
        local avgAngle = sum / count
        local currentAngle = hist[#hist].angle
        local diff = currentAngle - avgAngle
        return -diff
    elseif detectedMode == "Backward" then
        return 180
    elseif detectedMode == "Static" then
        return 0
    elseif detectedMode == "Custom" then
        local lastAngle = hist[#hist].angle
        local secondLast = hist[#hist - 1].angle
        local delta = lastAngle - secondLast
        if math.abs(delta) > 180 then delta = delta > 0 and delta - 360 or delta + 360 end
        return -delta
    end
    return 0
end

local function updateResolverHistory()
    if not resolverEnabled then return end
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            if resolverTeamCheck and targetPlayer.Team == player.Team then
                -- skip teammates
            else
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if not resolverHistory[targetPlayer] then
                        resolverHistory[targetPlayer] = {}
                    end
                    local _, yRot, _ = hrp.CFrame:ToEulerAnglesYXZ()
                    local deg = math.deg(yRot)
                    local now = tick()
                    local hist = resolverHistory[targetPlayer]
                    table.insert(hist, {angle = deg, time = now})
                    if #hist > 30 then
                        table.remove(hist, 1)
                    end

                    -- Pattern Detection
                    if #hist >= 5 then
                        local deltas = {}
                        local totalDelta = 0
                        local maxDelta = 0
                        local dirChanges = 0
                        local lastDir = 0

                        for i = 2, #hist do
                            local d = hist[i].angle - hist[i-1].angle
                            if math.abs(d) > 180 then
                                d = d > 0 and d - 360 or d + 360
                            end
                            table.insert(deltas, d)
                            local absD = math.abs(d)
                            totalDelta = totalDelta + absD
                            if absD > maxDelta then maxDelta = absD end

                            local curDir = d > 0 and 1 or (d < 0 and -1 or 0)
                            if curDir ~= 0 and lastDir ~= 0 and curDir ~= lastDir then
                                dirChanges = dirChanges + 1
                            end
                            if curDir ~= 0 then lastDir = curDir end
                        end

                        local avgDelta = totalDelta / #deltas
                        local detectedMode = "None"
                        local confidence = 0

                        -- Consistent high rotation = Spin
                        if avgDelta > 40 and dirChanges < #deltas * 0.3 then
                            detectedMode = "Spin"
                            confidence = math.clamp(50 + avgDelta * 0.5 + (1 - dirChanges / #deltas) * 30, 0, 100)
                        -- High direction changes with moderate deltas = Jitter
                        elseif dirChanges > #deltas * 0.5 and avgDelta > 15 then
                            detectedMode = "Jitter"
                            confidence = math.clamp(40 + dirChanges / #deltas * 40 + avgDelta * 0.3, 0, 100)
                        -- Very low delta = Static (or backward)
                        elseif avgDelta < 5 and maxDelta < 15 then
                            -- Check if they're facing backward relative to move direction
                            local moveDir = hrp.AssemblyLinearVelocity
                            local lookDir = hrp.CFrame.LookVector
                            if moveDir.Magnitude > 1 then
                                local dot = lookDir:Dot(moveDir.Unit)
                                if dot < -0.5 then
                                    detectedMode = "Backward"
                                    confidence = math.clamp(70 + math.abs(dot) * 30, 0, 100)
                                else
                                    detectedMode = "Static"
                                    confidence = math.clamp(30 + (1 - avgDelta / 5) * 40, 0, 100)
                                end
                            else
                                detectedMode = "Static"
                                confidence = math.clamp(30 + (1 - avgDelta / 5) * 40, 0, 100)
                            end
                        -- Moderate delta with some jitter = Custom Yaw
                        elseif avgDelta > 5 and avgDelta <= 40 then
                            detectedMode = "Custom"
                            confidence = math.clamp(35 + avgDelta * 0.5 + dirChanges * 2, 0, 100)
                        end

                        resolverDetectedModes[targetPlayer] = detectedMode
                        resolverConfidenceScores[targetPlayer] = math.floor(confidence)

                        -- Log resolved event when confidence crosses threshold
                        if confidence >= resolverConfidenceThreshold then
                            local lastLog = nil
                            for li = #resolverLog, 1, -1 do
                                if resolverLog[li].player == targetPlayer.Name then
                                    lastLog = resolverLog[li]
                                    break
                                end
                            end
                            if not lastLog or lastLog.mode ~= detectedMode or (now - lastLog.time) > 3 then
                                resolverResolvedCount = resolverResolvedCount + 1
                                table.insert(resolverLog, {
                                    player = targetPlayer.Name,
                                    mode = detectedMode,
                                    confidence = math.floor(confidence),
                                    time = now
                                })
                                if #resolverLog > resolverMaxLogSize then
                                    table.remove(resolverLog, 1)
                                end
                                if resolverNotify then
                                    Library:Notify('[Resolver] ' .. targetPlayer.Name .. ' -> ' .. detectedMode .. ' (' .. math.floor(confidence) .. '%)', 3)
                                end
                            end

                            -- Auto Headshot: Aim at head and shoot
                            if resolverAutoHeadshot and resolverAutoShoot then
                                local lastShot = resolverLastShotTime[targetPlayer] or 0
                                if (now - lastShot) >= resolverShotCooldown then
                                    local head = targetPlayer.Character:FindFirstChild("Head")
                                    local camera = workspace.CurrentCamera
                                    if head and camera then
                                        local canShoot = true
                                        if resolverWallCheck then
                                            local rayParams = RaycastParams.new()
                                            rayParams.FilterDescendantsInstances = {player.Character, camera}
                                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                            local rayResult = workspace:Raycast(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 2000, rayParams)
                                            if rayResult and not rayResult.Instance:IsDescendantOf(targetPlayer.Character) then
                                                canShoot = false
                                            end
                                        end

                                        if canShoot then
                                            local offset = getResolverOffset(targetPlayer)
                                            local resolvedCF = hrp.CFrame * CFrame.Angles(0, math.rad(offset), 0)
                                            local headOffset = (head.Position - hrp.Position)
                                            local resolvedHeadPos = resolvedCF.Position + headOffset

                                            local screenPos, onScreen = camera:WorldToViewportPoint(resolvedHeadPos)
                                            if onScreen then
                                                local mousePos = UserInputService:GetMouseLocation()
                                                local fovToUse = resolverFOVOverride and resolverFOVValue or aimbotFOV
                                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                                                if dist < fovToUse then
                                                    -- Snap aim to resolved head position
                                                    local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
                                                    local smoothed = delta / resolverSmoothing

                                                    if mousemoverel then
                                                        mousemoverel(smoothed.X, smoothed.Y)
                                                    else
                                                        local targetCFrame = CFrame.new(camera.CFrame.Position, resolvedHeadPos)
                                                        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / resolverSmoothing)
                                                    end

                                                    task.delay(resolverAutoShootDelay, function()
                                                        if mouse1press and mouse1release then
                                                            mouse1press()
                                                            task.delay(0.04, function() mouse1release() end)
                                                        end
                                                    end)

                                                    resolverLastShotTime[targetPlayer] = now
                                                    resolverHeadshotCount = resolverHeadshotCount + 1

                                                    if resolverNotify and resolverHeadshotCount % 5 == 0 then
                                                        Library:Notify('[Resolver] Auto Headshots: ' .. resolverHeadshotCount, 2)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- getResolverOffset is defined above updateResolverHistory

RunService.RenderStepped:Connect(function()
    pcall(updateResolverHistory)
end)

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovPolygons.killaura.visible = killAuraEnabled and killAuraFovCircle.visible
    fovPolygons.killaura.radius = killAuraFOV
    fovPolygons.killaura.color = killAuraFovCircle.color
    updateFovPolygon(fovPolygons.killaura, mousePos.X, mousePos.Y)
end)

local function updateAntiRagdoll()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if antiRagdollEnabled then
        if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll
            or humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                part.Enabled = false
            end
        end
    end
end

local function updateAntiStun()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if antiStunEnabled then
        if humanoid.WalkSpeed < 1 and walkSpeedEnabled then
            humanoid.WalkSpeed = walkSpeedValue
        end
        if humanoid:GetState() == Enum.HumanoidStateType.Seated then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        humanoid.PlatformStand = false
    end
end

local function updateAntiVoid()
    if not antiVoidEnabled then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp.Position.Y < antiVoidHeight then
        local spawnLocation = game:GetService("Players").LocalPlayer.Character
        local safePos = Vector3.new(0, 10, 0)
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("SpawnLocation") then
                safePos = obj.Position + Vector3.new(0, 5, 0)
                break
            end
        end
        hrp.CFrame = CFrame.new(safePos)
        Library:Notify("Anti Void: Teleported to safety!", 2)
    end
end

local function applyAntiFlingToHRP(hrp)
    local conn = RunService.Heartbeat:Connect(function()
        if not antiFlingEnabled then return end
        hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CanCollide = false
    end)
    table.insert(antiFlingConnections, conn)
end

local function startAntiFling()
    for _, conn in ipairs(antiFlingConnections) do conn:Disconnect() end
    antiFlingConnections = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then applyAntiFlingToHRP(hrp) end
        end
    end
    workspace.DescendantAdded:Connect(function(part)
        if not antiFlingEnabled then return end
        task.wait(0.1)
        if part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
            local char = part.Parent
            if char then
                local p2 = Players:GetPlayerFromCharacter(char)
                if p2 and p2 ~= player then
                    applyAntiFlingToHRP(part)
                end
            end
        end
    end)
end

local function stopAntiFling()
    for _, conn in ipairs(antiFlingConnections) do conn:Disconnect() end
    antiFlingConnections = {}
end

RunService.Heartbeat:Connect(function(dt)
    pcall(updateAntiRagdoll)
    pcall(updateAntiStun)
    pcall(updateAntiVoid)

    if safeTeleportEnabled then
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                safeTeleportTimer = safeTeleportTimer + dt
                if safeTeleportTimer >= safeTeleportInterval then
                    safeTeleportTimer = 0
                    local pos = hrp.Position
                    if pos.Y > antiVoidHeight then
                        local ray = workspace:Raycast(pos, Vector3.new(0, -10, 0))
                        if ray then
                            safeTeleportLastPos = hrp.CFrame
                        end
                    end
                end

                if hrp.Position.Y < antiVoidHeight or hrp.Position.Magnitude > 5000 then
                    if safeTeleportLastPos then
                        hrp.CFrame = safeTeleportLastPos
                        Library:Notify("Safe Teleport: Returned to last safe position!", 2)
                    end
                end
            end
        end
    end
end)

local AimbotBox = Tabs.Combat:AddLeftGroupbox('Aimbot')

AimbotBox:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Callback = function(value)
        aimbotEnabled = value
        if value then
            Library:Notify('Aimbot enabled', 3)
        else
            Library:Notify('Aimbot disabled', 3)
            fovCircle.visible = false
            aimbotToggleState = false
        end
    end
})

AimbotBox:AddSlider('AimbotFOV', {
    Text = 'FOV',
    Default = 100,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        aimbotFOV = value
    end
})

AimbotBox:AddToggle('AimbotPrediction', {
    Text = 'Prediction',
    Default = false,
    Callback = function(v) aimbotPrediction = v end
})
AimbotBox:AddSlider('AimbotPredictionStrength', {
    Text = 'Prediction Strength',
    Default = 0.1,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(v) aimbotPredictionStrength = v end
})

AimbotBox:AddToggle('AimbotLock', {
    Text = 'Aim Lock',
    Default = false,
    Callback = function(v)
        aimbotLock = v
        if not v then aimbotLockedTarget = nil end
    end
})

AimbotBox:AddToggle('AutoShoot', {
    Text = 'Auto Shoot',
    Default = false,
    Callback = function(v) autoShootEnabled = v end
})
AimbotBox:AddSlider('AutoShootDelay', {
    Text = 'Auto Shoot Delay',
    Default = 0.05,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(v) autoShootDelay = v end
})

AimbotBox:AddDivider()

AimbotBox:AddDropdown('AimbotMethod', {
    Values = {'Mouse Delta', 'Camera Lerp', 'View Angle'},
    Default = 1,
    Multi = false,
    Text = 'Aim Method',
    Callback = function(v) aimbotMethod = v end
})

AimbotBox:AddDivider()

AimbotBox:AddSlider('AimbotSmoothing', {
    Text = 'Smoothing',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        aimbotSmoothing = value
    end
})

AimbotBox:AddDropdown('AimbotTargetPart', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'Torso'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Callback = function(value)
        aimbotTargetPart = value
    end
})

AimbotBox:AddToggle('AimbotTeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(value)
        aimbotTeamCheck = value
    end
})

AimbotBox:AddToggle('AimbotVisibleCheck', {
    Text = 'Visible Check',
    Default = true,
    Callback = function(value)
        aimbotVisibleCheck = value
    end
})

AimbotBox:AddDivider()

AimbotBox:AddToggle('ShowFOVCircle', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(value)
        fovCircle.visible = value
    end
})

AimbotBox:AddLabel('FOV Circle Color:'):AddColorPicker('FOVCircleColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'FOV Circle Color',
    Callback = function(value)
        fovCircle.color = value
    end
})

AimbotBox:AddDivider()

AimbotBox:AddDropdown('AimbotMode', {
    Values = {'Always', 'Hold', 'Toggle'},
    Default = 1,
    Multi = false,
    Text = 'Activation Mode',
    Tooltip = 'Always: Always active\nHold: Active while key held\nToggle: Press key to toggle on/off',
    Callback = function(value)
        aimbotMode = value
        if value ~= "Toggle" then
            aimbotToggleState = false
        end
    end
})

AimbotBox:AddLabel('Keybind: E')
AimbotBox:AddButton({
    Text = 'Change Keybind',
    Func = function()
        Library:Notify('Press any key...', 3)
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                aimbotKeybind = input.KeyCode
                Library:Notify('Aimbot keybind set to: ' .. input.KeyCode.Name, 3)
                connection:Disconnect()
            end
        end)
    end,
    Tooltip = 'Click to change keybind'
})

AimbotBox:AddDivider()
AimbotBox:AddLabel('FOV: Detection range')
AimbotBox:AddLabel('Smoothing: Lower = Faster')

local SilentAimBox = Tabs.Combat:AddRightGroupbox('Silent Aim')

SilentAimBox:AddToggle('SilentAimEnabled', {
    Text = 'Enable Silent Aim',
    Default = false,
    Callback = function(v) silentAimEnabled = v end
})

SilentAimBox:AddToggle('SilentAimShowFOV', {
    Text = 'Show FOV',
    Default = false,
    Callback = function(v) silentAimFovCircle.visible = v end
})

SilentAimBox:AddSlider('SilentAimFOV', {
    Text = 'FOV Radius',
    Default = 120,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(v) silentAimFOV = v end
})

SilentAimBox:AddToggle('SilentAimWallCheck', {
    Text = 'Wall Check',
    Default = false,
    Callback = function(v) silentAimWallCheck = v end
})

SilentAimBox:AddToggle('SilentAimTeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(v) silentAimTeamCheck = v end
})

SilentAimBox:AddDropdown('SilentAimTarget', {
    Text = 'Target Part',
    Default = 'Head',
    Values = {'Head', 'Body'},
    Callback = function(v) silentAimTargetPart = v end
})

SilentAimBox:AddLabel('FOV Color:'):AddColorPicker('SilentAimFOVColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Silent Aim FOV Color',
    Callback = function(v) silentAimFovCircle.color = v end
})

local AntiAimBox = Tabs.Rage:AddRightGroupbox('Anti Aim')

AntiAimBox:AddToggle('AntiAimEnabled', {
    Text = 'Enable Anti Aim',
    Default = false,
    Callback = function(v)
        antiAimEnabled = v
        if not v then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.AutoRotate = true end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local joint = hrp:FindFirstChild("RootJoint")
                    if joint then joint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0) end
                end
            end
        end
    end
})
AntiAimBox:AddDropdown('AntiAimMode', {
    Text = 'Mode',
    Default = 'Spin',
    Values = {'Spin', 'Jitter', 'Static'},
    Callback = function(v) antiAimMode = v end
})
AntiAimBox:AddSlider('AntiAimSpeed', {
    Text = 'Speed',
    Default = 20,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Compact = false,
    Callback = function(v) antiAimSpeed = v end
})
AntiAimBox:AddDivider()
AntiAimBox:AddToggle('JitterAAEnabled', {
    Text = 'Jitter AA',
    Default = false,
    Callback = function(v)
        jitterEnabled = v
        if v then jitterCurrentAngle = jitterFromAngle jitterToggleState = false end
        if not v then
            local character = player.Character
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
        end
    end
})
AntiAimBox:AddSlider('JitterFrom', {Text = 'Jitter From', Default = -45, Min = -180, Max = 180, Rounding = 0, Compact = false, Callback = function(v) jitterFromAngle = v end})
AntiAimBox:AddSlider('JitterTo', {Text = 'Jitter To', Default = 45, Min = -180, Max = 180, Rounding = 0, Compact = false, Callback = function(v) jitterToAngle = v end})
AntiAimBox:AddSlider('JitterSpeed', {Text = 'Jitter Speed', Default = 5, Min = 1, Max = 300, Rounding = 0, Compact = false, Callback = function(v) jitterSpeed = v end})
AntiAimBox:AddDivider()
AntiAimBox:AddToggle('BackwardAA', {
    Text = 'Backward AA',
    Default = false,
    Callback = function(v)
        backwardAAEnabled = v
        if not v then
            local character = player.Character
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
        end
    end
})
AntiAimBox:AddDivider()
AntiAimBox:AddToggle('CustomYawEnabled', {
    Text = 'Custom Yaw',
    Default = false,
    Callback = function(v)
        customYawEnabled = v
        if not v then
            local character = player.Character
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
        end
    end
})
AntiAimBox:AddSlider('CustomYawAngle', {Text = 'Yaw Angle', Default = 0, Min = -180, Max = 180, Rounding = 0, Compact = false, Callback = function(v) customYawAngle = v end})
AntiAimBox:AddDivider()
AntiAimBox:AddToggle('DesyncEnabled', {
    Text = 'Desync',
    Default = false,
    Callback = function(v) desyncEnabled = v end
})
AntiAimBox:AddDropdown('DesyncMode', {
    Text = 'Desync Mode',
    Default = 'Void',
    Values = {'Void', 'Underground', 'Void Spam'},
    Callback = function(v) desyncMode = v end
})

local SpinbotBox = Tabs.Rage:AddLeftGroupbox('Spinbot')

SpinbotBox:AddToggle('Spinbot', {
    Text = 'Spinbot',
    Default = false,
    Callback = function(value)
        spinbotEnabled = value
        if not value then
            spinAngle = 0
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.AutoRotate = true end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local joint = hrp:FindFirstChild("RootJoint")
                    if joint then joint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0) end
                end
            end
        end
    end
})

SpinbotBox:AddSlider('SpinbotSpeed', {
    Text = 'Spin Speed',
    Default = 10,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        spinbotSpeed = value
    end
})

local HitboxBox = Tabs.Combat:AddRightGroupbox('Hitbox Expander')

HitboxBox:AddToggle('HitboxEnabled', {
    Text = 'Enable Hitbox',
    Default = false,
    Callback = function(v)
        hitboxEnabled = v
        if not v then pcall(updateHitbox) end
    end
})

HitboxBox:AddSlider('HitboxSize', {
    Text = 'Hitbox Size',
    Default = 8,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Callback = function(v) hitboxSize = v end
})

HitboxBox:AddDropdown('HitboxParts', {
    Values = {'All Parts', 'HRP Only', 'Head Only', 'HRP + Head'},
    Default = 1,
    Multi = false,
    Text = 'Target Parts',
    Callback = function(v)
        if v == 'All Parts' then
            hitboxParts = {"HumanoidRootPart", "Head", "UpperTorso", "Torso"}
        elseif v == 'HRP Only' then
            hitboxParts = {"HumanoidRootPart"}
        elseif v == 'Head Only' then
            hitboxParts = {"Head"}
        elseif v == 'HRP + Head' then
            hitboxParts = {"HumanoidRootPart", "Head"}
        end
    end
})

HitboxBox:AddDivider()
HitboxBox:AddLabel('Parts become invisible & enlarged')
HitboxBox:AddLabel('Restored on disable/unload')

local TeleportBox = Tabs.Player:AddLeftGroupbox('Teleport')

TeleportBox:AddDropdown('TeleportPlayer', {
    Values = {},
    Default = 1,
    Multi = false,
    Text = 'Select Player',
    Tooltip = 'Choose a player to teleport to'
})

TeleportBox:AddButton({
    Text = 'Teleport to Player',
    Func = function()
        local selectedPlayer = Options.TeleportPlayer.Value
        if selectedPlayer and selectedPlayer ~= "" then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer.Name == selectedPlayer and targetPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local myChar = player.Character
                    if targetRoot and myChar then
                        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                            Library:Notify('Teleported to ' .. targetPlayer.Name, 3)
                        end
                    end
                end
            end
        else
            Library:Notify('Please select a player first!', 3)
        end
    end,
    Tooltip = 'Teleport to selected player'
})

TeleportBox:AddButton({
    Text = 'Refresh Player List',
    Func = function()
        local playerNames = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(playerNames, p.Name)
            end
        end
        Options.TeleportPlayer:SetValues(playerNames)
        Library:Notify('Player list refreshed!', 3)
    end,
    Tooltip = 'Update the player list'
})

task.spawn(function()
    while true do
        task.wait(5)
        local playerNames = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(playerNames, p.Name)
            end
        end
        if Options.TeleportPlayer then
            Options.TeleportPlayer:SetValues(playerNames)
        end
    end
end)

local FlyBox = Tabs.Player:AddRightGroupbox('Fly')

FlyBox:AddToggle('FlyEnabled', {
    Text = 'Enable Fly',
    Default = false,
    Callback = function(value)
        flyEnabled = value
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if not value then
                    humanoid.PlatformStand = false
                    stopFly()
                end
            end
        end
    end
})

FlyBox:AddDropdown('FlyMethod', {
    Values = {'BodyVelocity', 'CFrame', 'Tween'},
    Default = 1,
    Multi = false,
    Text = 'Fly Method',
    Tooltip = 'BodyVelocity: Smooth & Stable\nCFrame: Fast & Responsive\nTween: Smooth Animation',
    Callback = function(value)
        flyMethod = value
        if flyEnabled then
            stopFly()
        end
    end
})

FlyBox:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        flySpeed = value
    end
})

FlyBox:AddDivider()
FlyBox:AddLabel('Controls:')
FlyBox:AddLabel('W/A/S/D - Move')
FlyBox:AddLabel('Space - Up')
FlyBox:AddLabel('Shift - Down')

local VelocityBox = Tabs.Player:AddLeftGroupbox('Velocity')

VelocityBox:AddToggle('WalkSpeedEnabled', {
    Text = 'Custom WalkSpeed',
    Default = false,
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end
})

VelocityBox:AddSlider('WalkSpeedValue', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        walkSpeedValue = value
    end
})

VelocityBox:AddDivider()

VelocityBox:AddToggle('JumpPowerEnabled', {
    Text = 'Custom JumpPower',
    Default = false,
    Callback = function(value)
        jumpPowerEnabled = value
        if not value then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if humanoid.UseJumpPower then
                        humanoid.JumpPower = 50
                    else
                        humanoid.JumpHeight = 7.2
                    end
                end
            end
        end
    end
})

VelocityBox:AddSlider('JumpPowerValue', {
    Text = 'JumpPower',
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        jumpPowerValue = value
    end
})

VelocityBox:AddButton({
    Text = 'Reset to Default',
    Func = function()
        Options.WalkSpeedValue:SetValue(16)
        Options.JumpPowerValue:SetValue(50)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = 50
                else
                    humanoid.JumpHeight = 7.2
                end
            end
        end
        Library:Notify('Velocity reset to default!', 3)
    end,
    Tooltip = 'Reset WalkSpeed and JumpPower to default values'
})

local NoclipBox = Tabs.Player:AddRightGroupbox('Noclip')

NoclipBox:AddToggle('NoclipEnabled', {
    Text = 'Enable Noclip',
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        if value then
            updateNoclip()
        else
            stopNoclip()
        end
    end
})

NoclipBox:AddDropdown('NoclipMethod', {
    Values = {'CanCollide', 'Velocity'},
    Default = 1,
    Multi = false,
    Text = 'Noclip Method',
    Tooltip = 'CanCollide: Simple & Effective\nVelocity: Smoother Wall Phasing',
    Callback = function(value)
        noclipMethod = value
        if noclipEnabled then
            stopNoclip()
            updateNoclip()
        end
    end
})

NoclipBox:AddDivider()
NoclipBox:AddLabel('Walk through walls and objects')
NoclipBox:AddLabel('Works best with Fly enabled')

local MiscBox = Tabs.Player:AddLeftGroupbox('Misc Features')

MiscBox:AddToggle('InfiniteJumpEnabled', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
        if value then
            updateInfiniteJump()
        else
            stopInfiniteJump()
        end
    end
})

MiscBox:AddLabel('Jump infinitely in the air')
MiscBox:AddLabel('Press Space to jump')

MiscBox:AddDivider()

MiscBox:AddToggle('AntiAFKEnabled', {
    Text = 'Anti AFK',
    Default = false,
    Callback = function(value)
        antiAFKEnabled = value
        if value then
            updateAntiAFK()
            Library:Notify('Anti AFK enabled', 3)
        else
            stopAntiAFK()
            Library:Notify('Anti AFK disabled', 3)
        end
    end
})

MiscBox:AddLabel('Prevents AFK kick')

MiscBox:AddDivider()

MiscBox:AddToggle('BunnyHopEnabled', {
    Text = 'Bunny Hop',
    Default = false,
    Callback = function(value)
        bunnyHopEnabled = value
        if value then
            updateBunnyHop()
            Library:Notify('Bunny Hop enabled', 3)
        else
            stopBunnyHop()
            Library:Notify('Bunny Hop disabled', 3)
        end
    end
})

MiscBox:AddLabel('Auto jump when holding Space')

MiscBox:AddDivider()

MiscBox:AddToggle('AutoSprintEnabled', {
    Text = 'Auto Sprint',
    Default = false,
    Callback = function(value)
        autoSprintEnabled = value
        if value then
            Library:Notify('Auto Sprint enabled', 3)
        else
            Library:Notify('Auto Sprint disabled', 3)
        end
    end
})

MiscBox:AddLabel('Automatically sprint when moving')

MiscBox:AddDivider()

MiscBox:AddToggle('JumpBugEnabled', {
    Text = 'Jump Bug',
    Default = false,
    Callback = function(v) jumpBugEnabled = v end
})
MiscBox:AddLabel('Reduces fall damage on landing')

-- ESP PREVIEW
do
    local TW2 = game:GetService("TweenService")
    local lp3 = game:GetService("Players").LocalPlayer
    local pg3 = lp3:WaitForChild("PlayerGui")
    local AC = Color3.fromRGB(232, 97, 154)

    local previewOpen = false
    local previewGui2 = nil

    local function buildPreview()
        if previewGui2 then previewGui2:Destroy() end

        previewGui2 = Instance.new("ScreenGui")
        previewGui2.Name = "WraithESPPreview"
        previewGui2.ResetOnSpawn = false
        previewGui2.ZIndexBehavior = Enum.ZIndexBehavior.Global
        if syn and syn.protect_gui then syn.protect_gui(previewGui2) end
        previewGui2.Parent = pg3

        -- panel
        local panel = Instance.new("Frame", previewGui2)
        panel.Size = UDim2.new(0, 220, 0, 300)
        panel.Position = UDim2.new(1, -240, 0.5, -160)
        panel.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        panel.BorderSizePixel = 0
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)
        local ps = Instance.new("UIStroke", panel)
        ps.Color = AC; ps.Thickness = 1; ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- title
        local titleL = Instance.new("TextLabel", panel)
        titleL.Size = UDim2.new(1, 0, 0, 24)
        titleL.BackgroundTransparency = 1
        titleL.Font = Enum.Font.GothamBold
        titleL.TextSize = 12
        titleL.Text = "ESP Preview"
        titleL.TextColor3 = Color3.fromRGB(200, 200, 200)
        titleL.ZIndex = 2

        -- close btn
        local closeBtn = Instance.new("TextButton", panel)
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -24, 0, 0)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Text = "x"
        closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        closeBtn.ZIndex = 3
        closeBtn.Activated:Connect(function()
            previewOpen = false
            previewGui2:Destroy()
            previewGui2 = nil
        end)

        -- viewport
        local vp = Instance.new("ViewportFrame", panel)
        vp.Size = UDim2.new(1, -16, 1, -32)
        vp.Position = UDim2.new(0, 8, 0, 28)
        vp.BackgroundColor3 = Color3.fromRGB(18, 28, 18)
        vp.BorderSizePixel = 0
        vp.Ambient = Color3.fromRGB(180, 180, 180)
        vp.LightColor = Color3.fromRGB(255, 255, 255)
        vp.LightDirection = Vector3.new(-1, -2, -1)
        Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 3)

        -- camera
        local cam = Instance.new("Camera", vp)
        cam.CFrame = CFrame.new(Vector3.new(0, 3.8, 8), Vector3.new(0, 3.8, 0))
        vp.CurrentCamera = cam

        -- build fake R6 character from parts
        local boxColor = espSettings.BoxColor
        local function makePart(sx, sy, sz, px, py, pz)
            local p = Instance.new("Part", vp)
            p.Size = Vector3.new(sx, sy, sz)
            p.CFrame = CFrame.new(px, py, pz)
            p.Anchored = true
            p.CanCollide = false
            p.Color = Color3.fromRGB(100, 200, 190)
            p.Material = Enum.Material.SmoothPlastic
            p.TopSurface = Enum.SurfaceType.Smooth
            p.BottomSurface = Enum.SurfaceType.Smooth
            return p
        end

        -- R6 proportions (scaled down)
        makePart(1.2, 1.2, 1.0,  0,    5.6, 0)  -- head
        makePart(2.0, 2.0, 1.0,  0,    4.0, 0)  -- torso
        makePart(1.0, 2.0, 1.0, -1.5,  4.0, 0)  -- left arm
        makePart(1.0, 2.0, 1.0,  1.5,  4.0, 0)  -- right arm
        makePart(0.9, 2.2, 1.0, -0.55, 1.9, 0)  -- left leg
        makePart(0.9, 2.2, 1.0,  0.55, 1.9, 0)  -- right leg

        -- box overlay (2D frame over viewport)
        local boxFrame = Instance.new("Frame", vp)
        boxFrame.Size = UDim2.new(0.72, 0, 0.88, 0)
        boxFrame.Position = UDim2.new(0.14, 0, 0.06, 0)
        boxFrame.BackgroundTransparency = 1
        boxFrame.BorderSizePixel = 0
        local boxStroke = Instance.new("UIStroke", boxFrame)
        boxStroke.Color = boxColor
        boxStroke.Thickness = 1.5
        boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- name tag
        local nameTag = Instance.new("TextLabel", vp)
        nameTag.Size = UDim2.new(1, 0, 0, 16)
        nameTag.Position = UDim2.new(0, 0, 0, 2)
        nameTag.BackgroundTransparency = 1
        nameTag.Font = Enum.Font.GothamBold
        nameTag.TextSize = 11
        nameTag.Text = lp3.Name .. "  100%"
        nameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameTag.TextStrokeTransparency = 0.5
        nameTag.ZIndex = 5

        -- health bar bg
        local hbBg = Instance.new("Frame", vp)
        hbBg.Size = UDim2.new(0, 5, 0.88, 0)
        hbBg.Position = UDim2.new(0.08, 0, 0.06, 0)
        hbBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        hbBg.BorderSizePixel = 0
        Instance.new("UICorner", hbBg).CornerRadius = UDim.new(1, 0)

        local hbFill = Instance.new("Frame", hbBg)
        hbFill.Size = UDim2.new(1, 0, 0.75, 0)
        hbFill.Position = UDim2.new(0, 0, 0.25, 0)
        hbFill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        hbFill.BorderSizePixel = 0
        Instance.new("UICorner", hbFill).CornerRadius = UDim.new(1, 0)

        -- distance label
        local distL = Instance.new("TextLabel", vp)
        distL.Size = UDim2.new(1, 0, 0, 14)
        distL.Position = UDim2.new(0, 0, 1, -16)
        distL.BackgroundTransparency = 1
        distL.Font = Enum.Font.Gotham
        distL.TextSize = 10
        distL.Text = "[67m]"
        distL.TextColor3 = Color3.fromRGB(180, 180, 180)
        distL.TextStrokeTransparency = 0.5
        distL.ZIndex = 5

        -- live update box color
        RunService.Heartbeat:Connect(function()
            if not previewGui2 or not previewGui2.Parent then return end
            local col = espSettings.RainbowBox and getRainbowColor() or espSettings.BoxColor
            boxStroke.Color = col
        end)

        -- fade in
        panel.BackgroundTransparency = 1
        ps.Transparency = 1
        TW2:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        TW2:Create(ps, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end

    local ESPPreviewBox = Tabs.Visuals:AddRightGroupbox('ESP Preview')
    ESPPreviewBox:AddButton({
        Text = 'Toggle Preview Window',
        Func = function()
            if previewOpen then
                previewOpen = false
                if previewGui2 then previewGui2:Destroy(); previewGui2 = nil end
            else
                previewOpen = true
                buildPreview()
            end
        end
    })
    ESPPreviewBox:AddLabel('Shows current ESP settings on a dummy')
end

local ESPBox = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

ESPBox:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(value)
        espEnabled = value
        if not value then
            for _, esp in pairs(espObjects) do
                for _, drawing in pairs(esp.Drawings) do
                    drawing.Visible = false
                end
                for _, line in pairs(esp.SkeletonLines) do
                    line.Visible = false
                end
            end
        end
    end
})

ESPBox:AddDivider()
ESPBox:AddToggle('ESPBox', {Text = 'Box', Default = true, Callback = function(v) espSettings.Box = v end})
ESPBox:AddToggle('ESPCornerBox', {Text = 'Corner Box', Default = false, Callback = function(v) espSettings.CornerBox = v end})
ESPBox:AddToggle('ESPBoxFill', {Text = 'Box Fill', Default = false, Callback = function(v) espSettings.BoxFill = v end})
ESPBox:AddToggle('ESPName', {Text = 'Name + HP%', Default = true, Callback = function(v) espSettings.Name = v end})
ESPBox:AddToggle('ESPDistance', {Text = 'Distance', Default = true, Callback = function(v) espSettings.Distance = v end})
ESPBox:AddToggle('ESPHealth', {Text = 'Health Bar', Default = true, Callback = function(v) espSettings.Health = v end})
ESPBox:AddToggle('ESPTracer', {Text = 'Tracers', Default = false, Callback = function(v) espSettings.Tracer = v end})
ESPBox:AddToggle('ESPSkeleton', {Text = 'Skeleton', Default = false, Callback = function(v) espSettings.Skeleton = v end})
ESPBox:AddToggle('ESPHeadDot', {Text = 'Head Dot', Default = false, Callback = function(v) espSettings.HeadDot = v end})
ESPBox:AddToggle('ESPTeamCheck', {Text = 'Team Check', Default = false, Callback = function(v) espSettings.TeamCheck = v end})
ESPBox:AddDropdown('ESPTracerOrigin', {
    Text = 'Tracer Origin',
    Default = 'Bottom',
    Values = {'Bottom', 'Center'},
    Callback = function(v) espSettings.TracerOrigin = v end
})
ESPBox:AddDivider()
ESPBox:AddToggle('ESP3DBox', {Text = '3D Box', Default = false, Callback = function(v) espSettings.Box3D = v end})
ESPBox:AddToggle('ESP3DBoxTeamCheck', {Text = '3D Box Team Check', Default = false, Callback = function(v) espSettings.Box3DTeamCheck = v end})
ESPBox:AddLabel('3D Box Color:'):AddColorPicker('ESP3DBoxColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = '3D Box Color',
    Callback = function(v) espSettings.Box3DColor = v end
})
ESPBox:AddDivider()
ESPBox:AddToggle('ESPSnapline', {Text = 'Snapline', Default = false, Callback = function(v) espSettings.Snapline = v end})
ESPBox:AddToggle('ESPLookDir', {Text = 'Look Direction', Default = false, Callback = function(v) espSettings.LookDirection = v end})
ESPBox:AddToggle('ESPVelocity', {Text = 'Velocity Arrow', Default = false, Callback = function(v) espSettings.VelocityArrow = v end})
ESPBox:AddToggle('ESPVisibility', {Text = 'Visibility Indicator', Default = true, Callback = function(v) espSettings.VisibilityIndicator = v end})
ESPBox:AddToggle('ESPLockIndicator', {Text = 'Lock Indicator', Default = true, Callback = function(v) espSettings.LockIndicator = v end})
ESPBox:AddToggle('ESPOffScreen', {Text = 'Off-Screen Arrow', Default = false, Callback = function(v) espSettings.OffScreenArrow = v end})
ESPBox:AddDivider()
ESPBox:AddToggle('ESPMaxDistEnabled', {Text = 'Max Distance Filter', Default = false, Callback = function(v) espSettings.MaxDistanceEnabled = v end})
ESPBox:AddSlider('ESPMaxDist', {
    Text = 'Max Distance',
    Default = 500,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Compact = false,
    Callback = function(v) espSettings.MaxDistance = v end
})

local ESPColorBox = Tabs.Visuals:AddRightGroupbox('ESP Colors')

ESPColorBox:AddToggle('RainbowBox', {Text = 'Rainbow Box', Default = false, Callback = function(v) espSettings.RainbowBox = v end})
ESPColorBox:AddLabel('Box Color:'):AddColorPicker('ESPBoxColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Box Color',
    Callback = function(v) espSettings.BoxColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Box Fill Color:'):AddColorPicker('ESPBoxFillColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Box Fill Color',
    Callback = function(v) espSettings.BoxFillColor = v end
})

ESPColorBox:AddSlider('BoxFillTransparency', {
    Text = 'Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(v) espSettings.BoxFillTransparency = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddToggle('RainbowTracer', {Text = 'Rainbow Tracer', Default = false, Callback = function(v) espSettings.RainbowTracer = v end})
ESPColorBox:AddLabel('Tracer Color:'):AddColorPicker('ESPTracerColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Tracer Color',
    Callback = function(v) espSettings.TracerColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Skeleton Color:'):AddColorPicker('ESPSkeletonColor', {
    Default = Color3.fromRGB(255, 160, 200),
    Title = 'Skeleton Color',
    Callback = function(v) espSettings.SkeletonColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddSlider('RainbowSpeed', {
    Text = 'Rainbow Speed',
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(v) espSettings.RainbowSpeed = v end
})

ESPColorBox:AddDivider()

ESPColorBox:AddToggle('BoxOutlineEnabled', {
    Text = 'Box Outline',
    Default = true,
    Callback = function(v) espSettings.BoxOutline = v end
})

ESPColorBox:AddLabel('Box Outline Color:'):AddColorPicker('BoxOutlineColor', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = 'Box Outline Color',
    Callback = function(v) espSettings.BoxOutlineColor = v end
})

ESPColorBox:AddDivider()

ESPColorBox:AddToggle('TracerOutlineEnabled', {
    Text = 'Tracer Outline',
    Default = true,
    Callback = function(v) espSettings.TracerOutline = v end
})

ESPColorBox:AddLabel('Tracer Outline Color:'):AddColorPicker('TracerOutlineColor', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = 'Tracer Outline Color',
    Callback = function(v) espSettings.TracerOutlineColor = v end
})

ESPColorBox:AddDivider()

ESPColorBox:AddLabel('Head Dot Color:'):AddColorPicker('ESPHeadDotColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Head Dot Color',
    Callback = function(v) espSettings.HeadDotColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Snapline Color:'):AddColorPicker('ESPSnaplineColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Snapline Color',
    Callback = function(v) espSettings.SnaplineColor = v end
})
ESPColorBox:AddLabel('Look Dir Color:'):AddColorPicker('ESPLookDirColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Look Direction Color',
    Callback = function(v) espSettings.LookDirColor = v end
})
ESPColorBox:AddLabel('Velocity Color:'):AddColorPicker('ESPVelocityColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Velocity Arrow Color',
    Callback = function(v) espSettings.VelocityColor = v end
})
ESPColorBox:AddLabel('Off-Screen Color:'):AddColorPicker('ESPOffArrowColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Off-Screen Arrow Color',
    Callback = function(v) espSettings.OffScreenArrowColor = v end
})

local WorldBox = Tabs.Visuals:AddRightGroupbox('World')

WorldBox:AddSlider('FOVChanger', {
    Text = 'Field of View',
    Default = 70,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

WorldBox:AddDivider()

WorldBox:AddSlider('TimeChanger', {
    Text = 'Time of Day',
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        game:GetService("Lighting").ClockTime = value
    end
})

WorldBox:AddButton({
    Text = 'Reset FOV',
    Func = function()
        workspace.CurrentCamera.FieldOfView = 70
        Options.FOVChanger:SetValue(70)
    end,
    Tooltip = 'Reset FOV to default (70)'
})

WorldBox:AddDivider()

WorldBox:AddToggle('StretchedResEnabled', {
    Text = 'Stretched Resolution',
    Default = false,
    Callback = function(value)
        stretchedResEnabled = value
        if not value then
            RunService:UnbindFromRenderStep("WraithsenseStretch")
            workspace.CurrentCamera.FieldOfView = Options.FOVChanger.Value or 70
            if setresolution and _sRes.w then
                setresolution(_sRes.w, _sRes.h)
                _sRes.w = nil
                _sRes.h = nil
            end
        else
            local vp = workspace.CurrentCamera.ViewportSize
            _sRes.w = vp.X
            _sRes.h = vp.Y

            if setresolution then
                local newW = math.floor(vp.X * stretchedResAmount)
                setresolution(newW, vp.Y)
            else
                RunService:BindToRenderStep("WraithsenseStretch", Enum.RenderPriority.Camera.Value + 1, function()
                    if not stretchedResEnabled then return end
                    local cam = workspace.CurrentCamera
                    if not cam then return end
                    local cf = cam.CFrame
                    local p = cf.Position
                    local rx = cf.RightVector
                    local up = cf.UpVector
                    local fwd = cf.LookVector
                    local s = stretchedResAmount
                    cam.CFrame = CFrame.new(
                        p.X, p.Y, p.Z,
                        rx.X, up.X * s, -fwd.X,
                        rx.Y, up.Y * s, -fwd.Y,
                        rx.Z, up.Z * s, -fwd.Z
                    )
                end)
            end
        end
    end
})

WorldBox:AddSlider('StretchAmount', {
    Text = 'Stretch Amount',
    Default = 75,
    Min = 10,
    Max = 99,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        stretchedResAmount = value / 100
        if stretchedResEnabled then
            if setresolution and _sRes.w then
                local newW = math.floor(_sRes.w * stretchedResAmount)
                setresolution(newW, _sRes.h)
            end
        end
    end
})

WorldBox:AddDivider()

WorldBox:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
    Callback = function(value)
        local Lighting = game:GetService("Lighting")
        if value then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

WorldBox:AddDivider()

WorldBox:AddToggle('ThirdPerson', {
    Text = 'Third Person',
    Default = false,
    Callback = function(value)
        thirdPersonEnabled = value
        local camera = workspace.CurrentCamera
        if value then
            if camera then camera.CameraType = Enum.CameraType.Custom end
            player.CameraMaxZoomDistance = thirdPersonDistance
            player.CameraMinZoomDistance = thirdPersonDistance

            local function applyThirdPersonToChar(character)
                if not character then return end
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        local parentIsTool = part.Parent and part.Parent:IsA("Tool")
                        local n = part.Name
                        local isArm = n == "Left Arm" or n == "Right Arm"
                            or n == "LeftHand" or n == "RightHand"
                            or n == "LeftLowerArm" or n == "RightLowerArm"
                            or n == "LeftUpperArm" or n == "RightUpperArm"
                        if parentIsTool or isArm then
                            part.LocalTransparencyModifier = 1
                        else
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end

            RunService:BindToRenderStep("BLThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
                if not thirdPersonEnabled then return end
                player.CameraMaxZoomDistance = thirdPersonDistance
                player.CameraMinZoomDistance = thirdPersonDistance
                local character = player.Character
                applyThirdPersonToChar(character)
            end)

            local character = player.Character
            if character then
                character.ChildAdded:Connect(function(child)
                    if not thirdPersonEnabled then return end
                    if child:IsA("Tool") then
                        player.CameraMaxZoomDistance = thirdPersonDistance
                        player.CameraMinZoomDistance = thirdPersonDistance
                    end
                end)
                character.ChildRemoved:Connect(function(child)
                    if not thirdPersonEnabled then return end
                    if child:IsA("Tool") then
                        player.CameraMaxZoomDistance = thirdPersonDistance
                        player.CameraMinZoomDistance = thirdPersonDistance
                    end
                end)
            end

            player.CharacterAdded:Connect(function(newChar)
                if not thirdPersonEnabled then return end
                player.CameraMaxZoomDistance = thirdPersonDistance
                player.CameraMinZoomDistance = thirdPersonDistance
                newChar.ChildAdded:Connect(function(child)
                    if not thirdPersonEnabled then return end
                    if child:IsA("Tool") then
                        player.CameraMaxZoomDistance = thirdPersonDistance
                        player.CameraMinZoomDistance = thirdPersonDistance
                    end
                end)
                newChar.ChildRemoved:Connect(function(child)
                    if not thirdPersonEnabled then return end
                    if child:IsA("Tool") then
                        player.CameraMaxZoomDistance = thirdPersonDistance
                        player.CameraMinZoomDistance = thirdPersonDistance
                    end
                end)
            end)
        else
            RunService:UnbindFromRenderStep("BLThirdPerson")
            player.CameraMaxZoomDistance = 128
            player.CameraMinZoomDistance = 0.5
            local character = player.Character
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.LocalTransparencyModifier = 1
                    end
                end
            end
        end
    end
})

WorldBox:AddSlider('ThirdPersonDistance', {
    Text = 'Camera Distance',
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        thirdPersonDistance = value
        if thirdPersonEnabled then
            player.CameraMaxZoomDistance = value
            player.CameraMinZoomDistance = value
        end
    end
})

WorldBox:AddDivider()

WorldBox:AddToggle('OrbitAxis', {
    Text = 'Orbit Axis',
    Default = false,
    Tooltip = 'Orbit around a player',
    Callback = function(value)
        orbitEnabled = value
        if not value then
            orbitAngle = 0
            orbitTarget = nil
        end
    end
})

WorldBox:AddInput('OrbitTarget', {
    Default = 'Closest',
    Numeric = false,
    Finished = true,
    Text = 'Target Player',
    Tooltip = 'Player name or "Closest"',
    Placeholder = 'Closest',
    Callback = function(value)
        orbitTargetName = value
        orbitTarget = nil
    end
})

WorldBox:AddSlider('OrbitSpeed', {
    Text = 'Orbit Speed',
    Default = 5,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        orbitSpeed = value
    end
})

WorldBox:AddSlider('OrbitRadius', {
    Text = 'Orbit Radius',
    Default = 10,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        orbitRadius = value
    end
})

WorldBox:AddSlider('OrbitHeight', {
    Text = 'Orbit Height',
    Default = 0,
    Min = -20,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        orbitHeight = value
    end
})

WorldBox:AddToggle('OrbitTeamCheck', {
    Text = 'Orbit Team Check',
    Default = false,
    Callback = function(value)
        orbitTeamCheck = value
    end
})

local RadarBox = Tabs.Visuals:AddRightGroupbox('Radar')

RadarBox:AddToggle('RadarEnabled', {
    Text = 'Enable Radar',
    Default = false,
    Callback = function(v) radarEnabled = v end
})
RadarBox:AddToggle('RadarTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Callback = function(v) radarSettings.TeamCheck = v end
})
RadarBox:AddSlider('RadarSize', {
    Text = 'Size',
    Default = 200,
    Min = 100,
    Max = 400,
    Rounding = 0,
    Compact = false,
    Callback = function(v) radarSettings.Size = v end
})
RadarBox:AddSlider('RadarRange', {
    Text = 'Range (studs)',
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(v) radarSettings.Range = v end
})
RadarBox:AddSlider('RadarDotSize', {
    Text = 'Dot Size',
    Default = 4,
    Min = 2,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Callback = function(v) radarSettings.DotSize = v end
})
RadarBox:AddSlider('RadarX', {
    Text = 'Position X',
    Default = 100,
    Min = 0,
    Max = 1800,
    Rounding = 0,
    Compact = false,
    Callback = function(v) radarSettings.X = v end
})
RadarBox:AddSlider('RadarY', {
    Text = 'Position Y',
    Default = 100,
    Min = 0,
    Max = 900,
    Rounding = 0,
    Compact = false,
    Callback = function(v) radarSettings.Y = v end
})
RadarBox:AddLabel('Enemy Color:'):AddColorPicker('RadarEnemyColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Enemy Color',
    Callback = function(v) radarSettings.EnemyColor = v end
})

local ChamsBox = Tabs.Visuals:AddLeftGroupbox('Chams')

ChamsBox:AddToggle('ChamsEnabled', {
    Text = 'Enable Chams',
    Default = false,
    Callback = function(value)
        chamsEnabled = value
        if value then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    createChams(targetPlayer)
                end
            end
        else
            for targetPlayer, _ in pairs(chamsObjects) do
                removeChams(targetPlayer)
            end
        end
    end
})

ChamsBox:AddToggle('RainbowChams', {
    Text = 'Rainbow',
    Default = false,
    Callback = function(value) chamsSettings.Rainbow = value end
})

ChamsBox:AddDropdown('ChamsMode', {
    Text = 'Mode',
    Default = 'Fill',
    Values = {'Fill', 'Outline', 'Aura', 'Full'},
    Callback = function(value)
        chamsSettings.Mode = value
        if chamsEnabled then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player or selfViewEnabled then
                    createChams(targetPlayer)
                end
            end
        end
    end
})

ChamsBox:AddToggle('ChamsTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Callback = function(value)
        chamsSettings.TeamCheck = value
        if chamsEnabled then
            for targetPlayer, _ in pairs(chamsObjects) do removeChams(targetPlayer) end
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player or selfViewEnabled then createChams(targetPlayer) end
            end
        end
    end
})

ChamsBox:AddDivider()
ChamsBox:AddLabel('Fill Color:'):AddColorPicker('ChamsColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Fill Color',
    Callback = function(value) chamsSettings.Color = value end
})
ChamsBox:AddSlider('ChamsTransparency', {
    Text = 'Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(value) chamsSettings.Transparency = value end
})

ChamsBox:AddDivider()
ChamsBox:AddLabel('Outline Color:'):AddColorPicker('ChamsOutlineColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Outline Color',
    Callback = function(value) chamsSettings.OutlineColor = value end
})
ChamsBox:AddSlider('ChamsOutlineTransparency', {
    Text = 'Outline Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(value) chamsSettings.OutlineTransparency = value end
})

local ChamsAuraBox = Tabs.Visuals:AddLeftGroupbox('Chams Aura')

ChamsAuraBox:AddLabel('Aura Color:'):AddColorPicker('ChamsAuraColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Aura Color',
    Callback = function(value) chamsSettings.AuraColor = value end
})
ChamsAuraBox:AddToggle('ChamsAuraPulse', {
    Text = 'Aura Pulse',
    Default = false,
    Callback = function(value) chamsSettings.AuraPulse = value end
})
ChamsAuraBox:AddSlider('ChamsAuraPulseSpeed', {
    Text = 'Pulse Speed',
    Default = 2,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(value) chamsSettings.AuraPulseSpeed = value end
})

local LocalChamsBox = Tabs.Visuals:AddLeftGroupbox('Local Chams')

LocalChamsBox:AddToggle('LocalChamsEnabled', {
    Text = 'Local Chams',
    Default = false,
    Callback = function(v)
        localChamsEnabled = v
        if not v then
            local character = player.Character
            if character then
                local h = character:FindFirstChild("WraithLocalChams")
                if h then h.Enabled = false end
            end
        end
    end
})
LocalChamsBox:AddLabel('Color:'):AddColorPicker('LocalChamsColor', {
    Default = Color3.fromRGB(232, 97, 154),
    Title = 'Local Chams Color',
    Callback = function(v) localChamsColor = v end
})

local ArmsChamsBox = Tabs.Visuals:AddLeftGroupbox('Arms Chams')

ArmsChamsBox:AddToggle('ArmsChamsEnabled', {
    Text = 'Arms / ViewModel Chams',
    Default = false,
    Callback = function(v)
        armsChamsEnabled = v
        if not v then
            local camera = workspace.CurrentCamera
            if camera then
                for _, model in ipairs(camera:GetChildren()) do
                    if model:IsA("Model") then
                        local h = model:FindFirstChild("WraithArmsChams")
                        if h then h.Enabled = false end
                    end
                end
            end
        end
    end
})
ArmsChamsBox:AddLabel('Color:'):AddColorPicker('ArmsChamsColor', {
    Default = Color3.fromRGB(200, 200, 200),
    Title = 'Arms Chams Color',
    Callback = function(v) armsChamsColor = v end
})

local CrosshairBox = Tabs.Visuals:AddLeftGroupbox('Crosshair')
CrosshairBox:AddToggle('CrosshairEnabled', {
    Text = 'Enable Crosshair',
    Default = false,
    Callback = function(v) crosshairEnabled = v end
})

CrosshairBox:AddLabel('Color:'):AddColorPicker('CrosshairColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Crosshair Color',
    Callback = function(v) crosshairColor = v end
})

CrosshairBox:AddSlider('CrosshairWidth', {
    Text = 'Width',
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairWidth = v / 10 end
})

CrosshairBox:AddSlider('CrosshairLength', {
    Text = 'Length',
    Default = 10,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairLength = v end
})

CrosshairBox:AddSlider('CrosshairRadius', {
    Text = 'Radius',
    Default = 11,
    Min = 1,
    Max = 40,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairRadius = v end
})

CrosshairBox:AddDivider()

CrosshairBox:AddToggle('CrosshairSpin', {
    Text = 'Spin',
    Default = true,
    Callback = function(v) crosshairSpin = v end
})

CrosshairBox:AddSlider('CrosshairSpinSpeed', {
    Text = 'Spin Speed',
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairSpinSpeed = v end
})

CrosshairBox:AddDivider()

CrosshairBox:AddToggle('CrosshairResize', {
    Text = 'Resize',
    Default = true,
    Callback = function(v) crosshairResize = v end
})

CrosshairBox:AddSlider('CrosshairResizeMin', {
    Text = 'Resize Min',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairResizeMin = v end
})

CrosshairBox:AddSlider('CrosshairResizeMax', {
    Text = 'Resize Max',
    Default = 22,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairResizeMax = v end
})

local OverlayBox = Tabs.Visuals:AddRightGroupbox('HUD Overlay')

OverlayBox:AddToggle('OverlayEnabled', {
    Text = 'FPS + Clock',
    Default = false,
    Callback = function(v) overlayEnabled = v end
})

OverlayBox:AddLabel('Shows FPS and current time')
OverlayBox:AddLabel('Top-left corner of screen')

OverlayBox:AddDivider()

OverlayBox:AddToggle('KeybindsEnabled', {
    Text = 'Keybinds Panel',
    Default = false,
    Callback = function(v) keybindsEnabled = v end
})

OverlayBox:AddLabel('Shows active features on screen')

OverlayBox:AddDivider()

OverlayBox:AddToggle('LockIndicatorEnabled', {
    Text = 'Lock Indicator',
    Default = false,
    Callback = function(v) lockIndicatorEnabled = v end
})

OverlayBox:AddLabel('Shows locked target info card')

OverlayBox:AddDivider()

OverlayBox:AddToggle('ScopeEnabled', {
    Text = 'Scope Overlay',
    Default = false,
    Callback = function(v)
        scopeEnabled = v
        if not v then
            for _, l in pairs(scopeLines) do l.Visible = false end
        end
    end
})

OverlayBox:AddLabel('Sniper-style scope overlay')

local BulletTracerBox = Tabs.Visuals:AddRightGroupbox('Bullet Tracer')

BulletTracerBox:AddToggle('BulletTracerEnabled', {
    Text = 'Enable Bullet Tracer',
    Default = false,
    Callback = function(v) bulletTracerEnabled = v end
})

BulletTracerBox:AddToggle('BulletTracerFade', {
    Text = 'Fade Out',
    Default = true,
    Callback = function(v) bulletTracerFadeEnabled = v end
})

BulletTracerBox:AddSlider('BulletTracerThickness', {
    Text = 'Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Callback = function(v) bulletTracerThickness = v end
})

BulletTracerBox:AddSlider('BulletTracerDuration', {
    Text = 'Duration (s)',
    Default = 0.3,
    Min = 0.05,
    Max = 2,
    Rounding = 2,
    Compact = false,
    Callback = function(v) bulletTracerDuration = v end
})

BulletTracerBox:AddLabel('Color:'):AddColorPicker('BulletTracerColor', {
    Default = Color3.fromRGB(255, 180, 210),
    Title = 'Tracer Color',
    Callback = function(v) bulletTracerColor = v end
})

local TexturesBox = Tabs.World:AddLeftGroupbox('Textures & Materials')

TexturesBox:AddToggle('RemoveTexturesEnabled', {
    Text = 'Remove Textures',
    Default = false,
    Callback = function(value)
        removeTexturesEnabled = value
        if value then
            removeTextures()
            Library:Notify('Textures removed! Better performance', 3)
        else
            restoreTextures()
            Library:Notify('Textures restored', 3)
        end
    end
})

TexturesBox:AddToggle('WireframeEnabled', {
    Text = 'Wireframe Mode',
    Default = false,
    Callback = function(value)
        wireframeEnabled = value
        if value then
            enableWireframe()
            Library:Notify('Wireframe mode enabled', 3)
        else
            disableWireframe()
            Library:Notify('Wireframe mode disabled', 3)
        end
    end
})

TexturesBox:AddToggle('NoWaterEnabled', {
    Text = 'Remove Water',
    Default = false,
    Callback = function(value)
        noWaterEnabled = value
        if value then
            removeWater()
            Library:Notify('Water removed', 3)
        else
            restoreWater()
            Library:Notify('Water restored', 3)
        end
    end
})

TexturesBox:AddDivider()
TexturesBox:AddLabel('Remove Textures: Better FPS')
TexturesBox:AddLabel('Wireframe: See through walls')
TexturesBox:AddLabel('Remove Water: No water physics')

local LightingBox = Tabs.World:AddRightGroupbox('Lighting')

LightingBox:AddToggle('NoFogEnabled', {
    Text = 'Remove Fog',
    Default = false,
    Callback = function(value)
        noFogEnabled = value
        local lighting = game:GetService("Lighting")
        if value then
            if not originalLighting.FogEnd then
                saveLightingSettings()
            end
            lighting.FogEnd = 100000
            lighting.FogStart = 0
            Library:Notify('Fog removed', 3)
        else
            if originalLighting.FogEnd then
                lighting.FogEnd = originalLighting.FogEnd
                lighting.FogStart = originalLighting.FogStart
            end
            Library:Notify('Fog restored', 3)
        end
    end
})

LightingBox:AddToggle('NoShadowsEnabled', {
    Text = 'Remove Shadows',
    Default = false,
    Callback = function(value)
        shadowsEnabled = not value
        local lighting = game:GetService("Lighting")
        if value then
            if not originalLighting.GlobalShadows then
                saveLightingSettings()
            end
            lighting.GlobalShadows = false
            Library:Notify('Shadows removed', 3)
        else
            lighting.GlobalShadows = true
            Library:Notify('Shadows restored', 3)
        end
    end
})

LightingBox:AddDivider()

LightingBox:AddSlider('AmbientBrightness', {
    Text = 'Ambient Brightness',
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        local lighting = game:GetService("Lighting")
        if not originalLighting.Ambient then
            saveLightingSettings()
        end
        lighting.Ambient = Color3.fromRGB(value, value, value)
    end
})

LightingBox:AddSlider('LightingBrightness', {
    Text = 'Brightness',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        local lighting = game:GetService("Lighting")
        if not originalLighting.Brightness then
            saveLightingSettings()
        end
        lighting.Brightness = value
    end
})

LightingBox:AddButton({
    Text = 'Reset Lighting',
    Func = function()
        restoreLightingSettings()
        Options.AmbientBrightness:SetValue(0)
        Options.LightingBrightness:SetValue(1)
        Library:Notify('Lighting reset to default', 3)
    end,
    Tooltip = 'Reset all lighting settings'
})

LightingBox:AddDivider()
LightingBox:AddLabel('Sky Presets')

local skyboxPresets = {
    {
        name          = "Sunset",
        ambient       = Color3.fromRGB(255, 140, 20),
        outdoorAmbient= Color3.fromRGB(255, 160, 40),
        colorShiftTop = Color3.fromRGB(255, 180, 60),
        colorShiftBot = Color3.fromRGB(255, 100, 10),
        brightness    = 2.2,
        clocktime     = 18.2,
    },
    {
        name          = "Velvet",
        ambient       = Color3.fromRGB(120, 10, 30),
        outdoorAmbient= Color3.fromRGB(80, 5, 20),
        colorShiftTop = Color3.fromRGB(160, 20, 40),
        colorShiftBot = Color3.fromRGB(60, 0, 15),
        brightness    = 0.8,
        clocktime     = 20.5,
    },
    {
        name          = "Midnight",
        ambient       = Color3.fromRGB(10, 15, 70),
        outdoorAmbient= Color3.fromRGB(5, 10, 50),
        colorShiftTop = Color3.fromRGB(20, 30, 100),
        colorShiftBot = Color3.fromRGB(0, 5, 30),
        brightness    = 0.3,
        clocktime     = 0,
    },
    {
        name          = "Golden Hour",
        ambient       = Color3.fromRGB(255, 200, 80),
        outdoorAmbient= Color3.fromRGB(255, 180, 60),
        colorShiftTop = Color3.fromRGB(255, 220, 100),
        colorShiftBot = Color3.fromRGB(200, 120, 20),
        brightness    = 3.0,
        clocktime     = 16.5,
    },
    {
        name          = "Arctic",
        ambient       = Color3.fromRGB(180, 210, 255),
        outdoorAmbient= Color3.fromRGB(200, 225, 255),
        colorShiftTop = Color3.fromRGB(210, 230, 255),
        colorShiftBot = Color3.fromRGB(150, 190, 240),
        brightness    = 3.5,
        clocktime     = 10,
    },
    {
        name          = "Void",
        ambient       = Color3.fromRGB(0, 0, 0),
        outdoorAmbient= Color3.fromRGB(0, 0, 0),
        colorShiftTop = Color3.fromRGB(0, 0, 0),
        colorShiftBot = Color3.fromRGB(0, 0, 0),
        brightness    = 0,
        clocktime     = 0,
    },
    {
        name          = "Neon City",
        ambient       = Color3.fromRGB(20, 0, 40),
        outdoorAmbient= Color3.fromRGB(10, 0, 30),
        colorShiftTop = Color3.fromRGB(180, 0, 255),
        colorShiftBot = Color3.fromRGB(0, 200, 255),
        brightness    = 0.5,
        clocktime     = 22,
    },
    {
        name          = "Blood Moon",
        ambient       = Color3.fromRGB(80, 0, 0),
        outdoorAmbient= Color3.fromRGB(60, 0, 0),
        colorShiftTop = Color3.fromRGB(120, 0, 0),
        colorShiftBot = Color3.fromRGB(40, 0, 0),
        brightness    = 0.4,
        clocktime     = 1,
    },
    {
        name          = "Dawn",
        ambient       = Color3.fromRGB(255, 180, 120),
        outdoorAmbient= Color3.fromRGB(255, 160, 100),
        colorShiftTop = Color3.fromRGB(100, 150, 255),
        colorShiftBot = Color3.fromRGB(255, 140, 80),
        brightness    = 1.8,
        clocktime     = 5.5,
    },
    {
        name          = "Overcast",
        ambient       = Color3.fromRGB(120, 120, 130),
        outdoorAmbient= Color3.fromRGB(130, 130, 140),
        colorShiftTop = Color3.fromRGB(150, 150, 160),
        colorShiftBot = Color3.fromRGB(100, 100, 110),
        brightness    = 1.2,
        clocktime     = 12,
    },
    {
        name          = "Deep Ocean",
        ambient       = Color3.fromRGB(0, 20, 60),
        outdoorAmbient= Color3.fromRGB(0, 30, 80),
        colorShiftTop = Color3.fromRGB(0, 50, 120),
        colorShiftBot = Color3.fromRGB(0, 10, 40),
        brightness    = 0.6,
        clocktime     = 14,
    },
    {
        name          = "Toxic",
        ambient       = Color3.fromRGB(0, 60, 0),
        outdoorAmbient= Color3.fromRGB(0, 80, 0),
        colorShiftTop = Color3.fromRGB(0, 180, 0),
        colorShiftBot = Color3.fromRGB(0, 40, 0),
        brightness    = 0.7,
        clocktime     = 21,
    },
    {
        name          = "Desert",
        ambient       = Color3.fromRGB(255, 200, 120),
        outdoorAmbient= Color3.fromRGB(255, 210, 140),
        colorShiftTop = Color3.fromRGB(100, 180, 255),
        colorShiftBot = Color3.fromRGB(255, 160, 60),
        brightness    = 4.0,
        clocktime     = 13,
    },
    {
        name          = "Blizzard",
        ambient       = Color3.fromRGB(200, 220, 255),
        outdoorAmbient= Color3.fromRGB(220, 235, 255),
        colorShiftTop = Color3.fromRGB(240, 245, 255),
        colorShiftBot = Color3.fromRGB(180, 200, 240),
        brightness    = 5.0,
        clocktime     = 9,
    },
    {
        name          = "Apocalypse",
        ambient       = Color3.fromRGB(80, 40, 0),
        outdoorAmbient= Color3.fromRGB(100, 50, 0),
        colorShiftTop = Color3.fromRGB(150, 60, 0),
        colorShiftBot = Color3.fromRGB(60, 20, 0),
        brightness    = 1.0,
        clocktime     = 17,
    },
}

local activeSkyName = "Default"

local function applySkyPreset(preset)
    local lighting = game:GetService("Lighting")
    if not originalLighting.Ambient then saveLightingSettings() end
    if preset == nil then
        restoreLightingSettings()
        activeSkyName = "Default"
        Library:Notify('Sky reset to default', 3)
        return
    end
    lighting.Ambient         = preset.ambient
    lighting.OutdoorAmbient  = preset.outdoorAmbient
    lighting.ColorShift_Top  = preset.colorShiftTop
    lighting.ColorShift_Bottom = preset.colorShiftBot
    lighting.Brightness      = preset.brightness
    lighting.ClockTime       = preset.clocktime
    activeSkyName = preset.name
    Library:Notify('Sky: ' .. preset.name, 3)
end

for _, preset in ipairs(skyboxPresets) do
    local p = preset
    LightingBox:AddButton({
        Text = p.name,
        Func = function() applySkyPreset(p) end,
        Tooltip = 'Apply ' .. p.name .. ' skybox preset'
    })
end

LightingBox:AddButton({
    Text = 'Reset Skybox',
    Func = function() applySkyPreset(nil) end,
    Tooltip = 'Remove custom skybox and restore default'
})

local WorldSettingsBox = Tabs.World:AddLeftGroupbox('World Settings')

WorldSettingsBox:AddSlider('Gravity', {
    Text = 'Gravity',
    Default = 196.2,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        workspace.Gravity = value
    end
})

WorldSettingsBox:AddButton({
    Text = 'Reset Gravity',
    Func = function()
        workspace.Gravity = 196.2
        Options.Gravity:SetValue(196.2)
        Library:Notify('Gravity reset to default', 3)
    end,
    Tooltip = 'Reset gravity to 196.2'
})

WorldSettingsBox:AddDivider()

WorldSettingsBox:AddButton({
    Text = 'Clear Workspace',
    Func = function()
        local count = 0
        for _, obj in pairs(workspace:GetChildren()) do
            if obj ~= workspace.CurrentCamera and obj.Name ~= "Terrain" and not obj:IsA("Model") or (obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid")) then
                pcall(function()
                    obj:Destroy()
                    count = count + 1
                end)
            end
        end
        Library:Notify('Cleared ' .. count .. ' objects', 3)
    end,
    DoubleClick = true,
    Tooltip = 'Double click to clear workspace (keeps players)'
})

local FlingBox = Tabs.Utility:AddLeftGroupbox('Fling')

FlingBox:AddToggle('FlingEnabled', {
    Text = 'Touch Fling',
    Default = false,
    Callback = function(v)
        flingEnabled = v
        if v then
            startTouchFling()
            Library:Notify('Touch Fling enabled', 3)
        else
            stopTouchFling()
            Library:Notify('Touch Fling disabled', 3)
        end
    end
})

FlingBox:AddSlider('FlingPower', {
    Text = 'Fling Power',
    Default = 10000,
    Min = 1000,
    Max = 50000,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        flingPower = value
    end
})

FlingBox:AddDivider()
FlingBox:AddLabel('Walk into players to fling them')

local WaypointBox = Tabs.Utility:AddLeftGroupbox('Waypoints')

WaypointBox:AddInput('WaypointName', {
    Default = '',
    Numeric = false,
    Finished = true,
    Text = 'Waypoint Name',
    Tooltip = 'Name for waypoint',
    Placeholder = 'Enter name...',
})

WaypointBox:AddButton({
    Text = 'Save Waypoint',
    Func = function()
        local name = Options.WaypointName.Value
        if name ~= '' then
            saveWaypoint(name)
        else
            Library:Notify('Enter a waypoint name!', 3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Save current position'
})

WaypointBox:AddButton({
    Text = 'Load Waypoint',
    Func = function()
        local name = Options.WaypointName.Value
        if name ~= '' then
            loadWaypoint(name)
        else
            Library:Notify('Enter a waypoint name!', 3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to waypoint'
})

WaypointBox:AddButton({
    Text = 'Delete Waypoint',
    Func = function()
        local name = Options.WaypointName.Value
        if name ~= '' then
            deleteWaypoint(name)
        else
            Library:Notify('Enter a waypoint name!', 3)
        end
    end,
    DoubleClick = true,
    Tooltip = 'Delete waypoint (double click)'
})

WaypointBox:AddDivider()
WaypointBox:AddLabel('Save and load positions')

local ServerBox = Tabs.Utility:AddRightGroupbox('Server Management')

ServerBox:AddButton({
    Text = 'Server Hop',
    Func = function()
        serverHop()
    end,
    Tooltip = 'Join a different server'
})

ServerBox:AddButton({
    Text = 'Rejoin Server',
    Func = function()
        rejoinServer()
    end,
    Tooltip = 'Rejoin current server'
})

ServerBox:AddDivider()

ServerBox:AddButton({
    Text = 'Copy Job ID',
    Func = function()
        copyJobId()
    end,
    Tooltip = 'Copy current server Job ID'
})

ServerBox:AddLabel('Job ID: ' .. game.JobId:sub(1, 20) .. '...')

ServerBox:AddDivider()

ServerBox:AddLabel('Server Hop: Find new server')
ServerBox:AddLabel('Rejoin: Return to this server')
ServerBox:AddLabel('Job ID: Share server with friends')

local GameInfoBox = Tabs.Utility:AddLeftGroupbox('Game Information')

GameInfoBox:AddLabel('Place ID: ' .. game.PlaceId)
GameInfoBox:AddLabel('Players: ' .. #Players:GetPlayers() .. '/' .. Players.MaxPlayers)

GameInfoBox:AddButton({
    Text = 'Copy Place ID',
    Func = function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
            Library:Notify('Place ID copied!', 3)
        else
            Library:Notify('Place ID: ' .. game.PlaceId, 5)
        end
    end,
    Tooltip = 'Copy game Place ID'
})

GameInfoBox:AddDivider()

local pingLabel = GameInfoBox:AddLabel('Ping: Calculating...')
local fpsLabel = GameInfoBox:AddLabel('FPS: Calculating...')

task.spawn(function()
    while true do
        local ping = math.floor(player:GetNetworkPing() * 1000)
        local dt = RunService.RenderStepped:Wait()
        local fps = dt > 0 and math.floor(1 / dt) or 0

        pingLabel:SetText('Ping: ' .. ping .. 'ms')
        fpsLabel:SetText('FPS: ' .. fps)

        task.wait(1)
    end
end)

local PerformanceBox = Tabs.Utility:AddRightGroupbox('Performance')

PerformanceBox:AddButton({
    Text = 'Enable Low GFX',
    Func = function()
        enableLowGFX()
    end,
    Tooltip = 'Reduce graphics for better FPS'
})

PerformanceBox:AddDivider()

PerformanceBox:AddLabel('FPS Cap:')

PerformanceBox:AddButton({
    Text = 'Set FPS to 60',
    Func = function()
        setFPSCap(60)
    end,
    Tooltip = 'Cap FPS at 60'
})

PerformanceBox:AddButton({
    Text = 'Set FPS to 120',
    Func = function()
        setFPSCap(120)
    end,
    Tooltip = 'Cap FPS at 120'
})

PerformanceBox:AddButton({
    Text = 'Set FPS to 240',
    Func = function()
        setFPSCap(240)
    end,
    Tooltip = 'Cap FPS at 240'
})

PerformanceBox:AddDivider()
PerformanceBox:AddLabel('Low GFX: Removes particles, sounds')
PerformanceBox:AddLabel('FPS Cap: Executor dependent')

local ToolsBox = Tabs.Utility:AddLeftGroupbox('Tools')

ToolsBox:AddButton({
    Text = 'Take Screenshot',
    Func = function()
        takeScreenshot()
    end,
    Tooltip = 'Capture screenshot (hides UI)'
})

ToolsBox:AddDivider()

ToolsBox:AddButton({
    Text = 'Copy Player List',
    Func = function()
        local list = getPlayerList()
        if setclipboard then
            setclipboard(list)
            Library:Notify('Player list copied!', 3)
        else
            Library:Notify('Player list:\n' .. list, 10)
        end
    end,
    Tooltip = 'Copy all player names'
})

ToolsBox:AddButton({
    Text = 'Copy Game Link',
    Func = function()
        local link = "https://www.roblox.com/games/" .. game.PlaceId
        if setclipboard then
            setclipboard(link)
            Library:Notify('Game link copied!', 3)
        else
            Library:Notify('Link: ' .. link, 5)
        end
    end,
    Tooltip = 'Copy game URL'
})

ToolsBox:AddDivider()

ToolsBox:AddButton({
    Text = 'Clear Console',
    Func = function()
        if rconsoleclear then
            rconsoleclear()
            Library:Notify('Console cleared', 3)
        elseif consoleclear then
            consoleclear()
            Library:Notify('Console cleared', 3)
        else
            Library:Notify('Console clear not supported', 3)
        end
    end,
    Tooltip = 'Clear executor console'
})

ToolsBox:AddButton({
    Text = 'Print Game Info',
    Func = function()
        local info = string.format(
            "Game: %s\nPlace ID: %s\nJob ID: %s\nPlayers: %d/%d\nPing: %dms",
            game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
            game.PlaceId,
            game.JobId,
            #Players:GetPlayers(),
            Players.MaxPlayers,
            math.floor(player:GetNetworkPing() * 1000)
        )

        if rconsoleprint then
            rconsoleprint(info)
        elseif consoleprint then
            consoleprint(info)
        end

        Library:Notify('Game info printed to console', 3)
    end,
    Tooltip = 'Print detailed game info'
})

local AntiBox = Tabs.Anti:AddLeftGroupbox('Anti Ragdoll')

AntiBox:AddToggle('AntiRagdollEnabled', {
    Text = 'Anti Ragdoll',
    Default = false,
    Tooltip = 'Prevents ragdoll state',
    Callback = function(v)
        antiRagdollEnabled = v
        if v then
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                        part.Enabled = false
                    end
                end
            end
        else
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                        part.Enabled = true
                    end
                end
            end
        end
    end
})

local AntiStunBox = Tabs.Anti:AddLeftGroupbox('Anti Stun')

AntiStunBox:AddToggle('AntiStunEnabled', {
    Text = 'Anti Stun',
    Default = false,
    Tooltip = 'Prevents stun/slow/seat effects',
    Callback = function(v) antiStunEnabled = v end
})

local AntiFlingBox = Tabs.Anti:AddLeftGroupbox('Anti Fling')

AntiFlingBox:AddToggle('AntiFlingEnabled', {
    Text = 'Anti Fling',
    Default = false,
    Tooltip = 'Prevents other players from flinging you',
    Callback = function(v)
        antiFlingEnabled = v
        if v then
            startAntiFling()
        else
            stopAntiFling()
        end
    end
})

local AntiVoidBox = Tabs.Anti:AddRightGroupbox('Anti Void')

AntiVoidBox:AddToggle('AntiVoidEnabled', {
    Text = 'Anti Void',
    Default = false,
    Tooltip = 'Teleports you to safety when falling into void',
    Callback = function(v) antiVoidEnabled = v end
})

AntiVoidBox:AddSlider('AntiVoidHeight', {
    Text = 'Void Y Threshold',
    Default = -50,
    Min = -500,
    Max = -10,
    Rounding = 0,
    Compact = false,
    Callback = function(v) antiVoidHeight = v end
})

local SafeTeleportBox = Tabs.Anti:AddRightGroupbox('Safe Teleport')

SafeTeleportBox:AddToggle('SafeTeleportEnabled', {
    Text = 'Safe Teleport',
    Default = false,
    Tooltip = 'Saves last safe ground position and returns you there if you fall out of map',
    Callback = function(v)
        safeTeleportEnabled = v
        if v then
            safeTeleportLastPos = nil
            safeTeleportTimer = 0
            Library:Notify("Safe Teleport: Active - walk on ground to save position", 3)
        end
    end
})

SafeTeleportBox:AddSlider('SafeTeleportInterval', {
    Text = 'Save Interval (s)',
    Default = 1,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(v) safeTeleportInterval = v end
})

SafeTeleportBox:AddButton({
    Text = 'Save Current Position',
    Func = function()
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                safeTeleportLastPos = hrp.CFrame
                Library:Notify("Safe Teleport: Position saved!", 2)
            end
        end
    end,
    Tooltip = 'Manually save current position as safe point'
})

local AppearanceBox = Tabs.Misc:AddLeftGroupbox('Appearance')

AppearanceBox:AddButton({
    Text = 'Korblox',
    Func = function()
        local char = player.Character
        if not char then Library:Notify('Character not found!', 3) return end
        local ok, err = pcall(function()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local isR6 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6

            if isR6 then
                local part = char:FindFirstChild("Right Leg")
                if not part then error("Right Leg not found!") end
                for _, v in pairs(part:GetChildren()) do
                    if v:IsA("SpecialMesh") or v:IsA("DataModelMesh") then v:Destroy() end
                end
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = "rbxassetid://101851696"
                mesh.TextureId = "rbxassetid://101851254"
                mesh.Scale = Vector3.new(1, 1, 1)
                mesh.Parent = part
            else
                for _, v in pairs(char:GetChildren()) do
                    if v.Name == "KorbloxFake_RightLeg" then v:Destroy() end
                end

                local legParts = {
                    char:FindFirstChild("RightUpperLeg"),
                    char:FindFirstChild("RightLowerLeg"),
                    char:FindFirstChild("RightFoot"),
                }

                local anchorPart = legParts[2] or legParts[1] or legParts[3]
                if not anchorPart then error("Right leg parts not found!") end

                for _, p in pairs(legParts) do
                    if p then
                        p.Transparency = 1
                        p.LocalTransparencyModifier = 1
                    end
                end

                local fake = Instance.new("Part")
                fake.Name = "KorbloxFake_RightLeg"
                fake.Size = Vector3.new(1, 2, 1)
                fake.Transparency = 0
                fake.CanCollide = false
                fake.Anchored = false
                fake.CastShadow = false
                fake.CFrame = anchorPart.CFrame
                fake.Parent = char

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = anchorPart
                weld.Part1 = fake
                weld.Parent = fake

                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = "rbxassetid://101851696"
                mesh.TextureId = "rbxassetid://101851254"
                mesh.Scale = Vector3.new(1, 1, 1)
                mesh.Parent = fake
            end
        end)
        if ok then
            Library:Notify('Korblox applied! (clientside)', 3)
        else
            Library:Notify('Failed: ' .. tostring(err), 5)
        end
    end,
    Tooltip = 'Apply Korblox mesh to right leg (clientside only)'
})

AppearanceBox:AddButton({
    Text = 'Headless Head',
    Func = function()
        local char = player.Character
        if not char then Library:Notify('Character not found!', 3) return end
        local head = char:FindFirstChild("Head")
        if not head then Library:Notify('Head not found!', 3) return end
        head.Transparency = 1
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        local existingMesh = head:FindFirstChildOfClass("SpecialMesh") or head:FindFirstChildOfClass("DataModelMesh")
        if existingMesh then
            existingMesh.MeshId = "rbxassetid://1095708"
            existingMesh.TextureId = ""
            existingMesh.Scale = Vector3.new(0.001, 0.001, 0.001)
        else
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1095708"
            mesh.TextureId = ""
            mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
            mesh.Parent = head
        end
        Library:Notify('Headless applied! (clientside)', 3)
    end,
    Tooltip = 'Make head invisible (clientside only)'
})

AppearanceBox:AddButton({
    Text = 'Reset Appearance',
    Func = function()
        local char = player.Character
        if not char then return end
        pcall(function()
            local legParts = {
                char:FindFirstChild("RightUpperLeg"),
                char:FindFirstChild("RightLowerLeg"),
                char:FindFirstChild("RightFoot"),
                char:FindFirstChild("Right Leg"),
            }
            for _, part in pairs(legParts) do
                if part then
                    part.Transparency = 0
                    part.LocalTransparencyModifier = 0
                end
            end
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "KorbloxFake_RightLeg" or v.Name:sub(1, 12) == "KorbloxFake_" then v:Destroy() end
            end
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 0
                head.LocalTransparencyModifier = 0
                for _, v in pairs(head:GetChildren()) do
                    if v:IsA("SpecialMesh") then v:Destroy() end
                    if v:IsA("Decal") then v.Transparency = 0 end
                end
            end
        end)
        Library:Notify('Appearance reset!', 3)
    end,
    Tooltip = 'Remove Korblox and Headless'
})

AppearanceBox:AddDivider()
AppearanceBox:AddLabel('Clientside only - others cannot see')

local ThemeBox = Tabs.Misc:AddLeftGroupbox('Theme Settings')
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('Wraithsense')
ThemeManager:ApplyToTab(Tabs.Misc)

ThemeManager:ApplyTheme('Default')

Library.BackgroundColor = Color3.fromHex('1a0d12')
Library.MainColor = Color3.fromHex('2a1020')
Library.AccentColor = Color3.fromHex('e8619a')
Library.OutlineColor = Color3.fromHex('4a1a2e')
Library.FontColor = Color3.fromHex('ffffff')
Library:UpdateColorsUsingRegistry()

task.defer(function()
    local gui = Library.GUI
    if not gui then return end
    local mainFrame = gui:FindFirstChildOfClass("Frame")
    if not mainFrame then return end

    local glowColor = Color3.fromRGB(232, 97, 154)

    local layers = {
        {expand = 18, alpha = 0.04},
        {expand = 12, alpha = 0.07},
        {expand = 7,  alpha = 0.11},
        {expand = 3,  alpha = 0.16},
    }

    for _, layer in ipairs(layers) do
        local glow = Instance.new("Frame")
        glow.Name = "GlowLayer"
        glow.BackgroundColor3 = glowColor
        glow.BackgroundTransparency = 1 - layer.alpha
        glow.BorderSizePixel = 0
        glow.ZIndex = mainFrame.ZIndex - 1
        glow.Size = UDim2.new(
            mainFrame.Size.X.Scale,
            mainFrame.Size.X.Offset + layer.expand * 2,
            mainFrame.Size.Y.Scale,
            mainFrame.Size.Y.Offset + layer.expand * 2
        )
        glow.Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset - layer.expand,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset - layer.expand
        )
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10 + layer.expand / 2)
        corner.Parent = glow
        glow.Parent = gui
    end

    local stroke = Instance.new("UIStroke")
    stroke.Color = glowColor
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = mainFrame
end)

local ConfigBox = Tabs.Misc:AddRightGroupbox('Configuration')

SaveManager:SetLibrary(Library)
SaveManager:SetFolder('Wraithsense/Configs')
SaveManager:BuildConfigSection(Tabs.Misc)

ConfigBox:AddDivider()

ConfigBox:AddButton({
    Text = 'Open Config Folder',
    Func = function()
        local folderPath = 'Wraithsense/Configs'
        if not isfolder(folderPath) then
            makefolder(folderPath)
        end
        if syn and syn.open_folder then
            syn.open_folder(folderPath)
        elseif KRNL_LOADED then
            KRNL.open_folder(folderPath)
        elseif rconsoleprint then
            rconsoleprint('Config folder: ' .. folderPath .. '\n')
        end
        Library:Notify('Config folder: ' .. folderPath, 5)
    end,
    Tooltip = 'Opens or creates the config folder'
})

ConfigBox:AddDivider()
ConfigBox:AddLabel('Folder: Wraithsense/Configs')

local SettingsBox = Tabs.Misc:AddRightGroupbox('Settings')
SettingsBox:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'K',
    NoUI = true,
    Text = 'Menu Toggle'
})
Library.ToggleKeybind = Options.MenuKeybind

SettingsBox:AddDivider()

SettingsBox:AddButton({
    Text = 'Unload Script',
    Func = function()
        espEnabled = false
        chamsEnabled = false
        aimbotEnabled = false
        silentAimEnabled = false
        killAuraEnabled = false
        antiAimEnabled = false
        radarEnabled = false
        crosshairEnabled = false
        overlayEnabled = false
        scopeEnabled = false
        bulletTracerEnabled = false
        keybindsEnabled = false
        lockIndicatorEnabled = false
        flingEnabled = false
        antiFlingEnabled = false
        antiRagdollEnabled = false
        antiStunEnabled = false
        antiVoidEnabled = false
        safeTeleportEnabled = false
        backtrackEnabled = false
        autoStrafeEnabled = false
        fakeLagEnabled = false
        resolverEnabled = false
        rapidFireEnabled = false
        noSpreadEnabled = false
        noRecoilEnabled = false
        infiniteAmmoEnabled = false
        instantReloadEnabled = false
        pcall(restoreWeaponMods)
        jitterEnabled = false
        desyncEnabled = false
        jumpBugEnabled = false
        localChamsEnabled = false
        armsChamsEnabled = false
        thirdPersonEnabled = false
        spinbotEnabled = false
        flyEnabled = false
        walkSpeedEnabled = false
        jumpPowerEnabled = false
        noclipEnabled = false
        infiniteJumpEnabled = false
        antiAFKEnabled = false
        bunnyHopEnabled = false
        stretchedResEnabled = false

        silentAimFovCircle.visible = false
        fovCircle.visible = false
        killAuraFovCircle.visible = false

        if desyncSetback then desyncSetback:Destroy() desyncSetback = nil end

        pcall(stopTouchFling)
        pcall(stopAntiFling)
        pcall(stopAntiAFK)
        pcall(stopBunnyHop)
        pcall(stopInfiniteJump)
        pcall(stopNoclip)
        pcall(stopFly)

        RunService:UnbindFromRenderStep("BLThirdPerson")
        RunService:UnbindFromRenderStep("BLSpinbot")
        RunService:UnbindFromRenderStep("BLAntiAim")
        RunService:UnbindFromRenderStep("WraithsenseStretch")

        if rapidFireConnection then rapidFireConnection:Disconnect() rapidFireConnection = nil end

        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.AutoRotate = true
                hum.PlatformStand = false
                hum.WalkSpeed = 16
                hum.CameraOffset = Vector3.new(0, 0, 0)
                if hum.UseJumpPower then hum.JumpPower = 50 else hum.JumpHeight = 7.2 end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local joint = hrp:FindFirstChild("RootJoint")
                if joint then joint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0) end
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                    part.Enabled = true
                end
            end
            local h = char:FindFirstChild("WraithLocalChams")
            if h then h:Destroy() end
        end

        local cam = workspace.CurrentCamera
        if cam then
            cam.FieldOfView = 70
            if originalCameraMode then
                player.CameraMode = originalCameraMode
            end
            for _, model in ipairs(cam:GetChildren()) do
                if model:IsA("Model") then
                    local h = model:FindFirstChild("WraithArmsChams")
                    if h then h:Destroy() end
                end
            end
        end

        player.CameraMaxZoomDistance = 128
        player.CameraMinZoomDistance = 0.5
        workspace.Gravity = 196.2

        if setresolution and _sRes.w then
            setresolution(_sRes.w, _sRes.h)
            _sRes.w = nil _sRes.h = nil
        end

        for _, esp in pairs(espObjects) do
            for _, d in pairs(esp.Drawings) do pcall(function() d:Remove() end) end
            for _, l in pairs(esp.SkeletonLines) do pcall(function() l:Remove() end) end
            for _, l in pairs(esp.CornerLines or {}) do pcall(function() l:Remove() end) end
            for _, l in pairs(esp.HealthGradientLines or {}) do pcall(function() l:Remove() end) end
        end
        espObjects = {}

        for _, lines in pairs(box3dObjects) do
            for _, l in ipairs(lines) do pcall(function() l:Remove() end) end
        end
        box3dObjects = {}

        for _, d in pairs(radarDrawings) do
            if type(d) == "table" then
                for _, dd in ipairs(d) do pcall(function() dd:Remove() end) end
            else
                pcall(function() d:Remove() end)
            end
        end
        radarDrawings = {}

        for _, poly in pairs(fovPolygons) do
            for _, l in ipairs(poly.lines) do pcall(function() l:Remove() end) end
            for _, l in ipairs(poly.glows) do pcall(function() l:Remove() end) end
        end

        for _, chams in pairs(chamsObjects) do pcall(function() chams:Destroy() end) end
        chamsObjects = {}

        for _, dot in pairs(waypointDots) do pcall(function() dot:Destroy() end) end
        waypointDots = {}

        for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end
        crosshairDrawings = {}
        if overlayDrawing then pcall(function() overlayDrawing:Remove() end) overlayDrawing = nil end
        for _, l in pairs(scopeLines) do pcall(function() l:Remove() end) end
        scopeLines = {}
        for _, l in pairs(bulletTracerLines) do pcall(function() l:Remove() end) end
        bulletTracerLines = {}

        for k, d in pairs(keybindsDrawings) do
            if type(d) == "table" then
                for _, r in ipairs(d) do pcall(function() r:Remove() end) end
            else
                pcall(function() d:Remove() end)
            end
        end
        keybindsDrawings = {}

        for k, d in pairs(lockIndicatorDrawings) do
            if type(d) ~= "table" then pcall(function() d:Remove() end) end
        end
        lockIndicatorDrawings = {}
        if lockIndicatorGui then pcall(function() lockIndicatorGui:Destroy() end) lockIndicatorGui = nil end
        lockIndicatorThumb = nil
        task.wait(0.3)
        pcall(function()
            local blGui = game:GetService("CoreGui"):FindFirstChild("BLButton")
            if blGui then blGui:Destroy() end
        end)
        pcall(function()
            if Library.ScreenGui then
                Library.ScreenGui:Destroy()
            end
        end)

        _G.WraithsenseLoaded = nil
    end,
    DoubleClick = true,
    Tooltip = 'Double click to unload the script'
})

local function updateWatermark()
    local dt = RunService.RenderStepped:Wait()
    local fps = dt > 0 and math.floor(1 / dt) or 0
    local ping = math.floor(player:GetNetworkPing() * 1000)
    Library:SetWatermark(string.format("Wraithsense | %s | FPS: %d | Ping: %dms", player.Name, fps, ping))
end

task.spawn(function()
    while true do
        pcall(updateWatermark)
        task.wait(1)
    end
end)

Library:SetWatermarkVisibility(true)

local _blGui = Instance.new("ScreenGui")
_blGui.Name = "BLButton"
_blGui.ResetOnSpawn = false
_blGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_blGui.DisplayOrder = 999
_blGui.Parent = game:GetService("CoreGui")

local _blFrame = Instance.new("Frame")
_blFrame.Size = UDim2.new(0, 60, 0, 60)
_blFrame.Position = UDim2.new(0, 30, 0, 30)
_blFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 20)
_blFrame.BorderSizePixel = 0
_blFrame.ZIndex = 2
_blFrame.Parent = _blGui

local _blCorner = Instance.new("UICorner")
_blCorner.CornerRadius = UDim.new(1, 0)
_blCorner.Parent = _blFrame

local _blStroke = Instance.new("UIStroke")
_blStroke.Color = Color3.fromRGB(232, 97, 154)
_blStroke.Thickness = 2
_blStroke.Parent = _blFrame

local _blGlow = Instance.new("ImageLabel")
_blGlow.Size = UDim2.new(0, 100, 0, 100)
_blGlow.Position = UDim2.new(0.5, -50, 0.5, -50)
_blGlow.BackgroundTransparency = 1
_blGlow.Image = "rbxassetid://5028857084"
_blGlow.ImageColor3 = Color3.fromRGB(232, 97, 154)
_blGlow.ImageTransparency = 0.5
_blGlow.ZIndex = 1
_blGlow.Parent = _blFrame

local _blLabel = Instance.new("TextLabel")
_blLabel.Size = UDim2.new(1, 0, 1, 0)
_blLabel.BackgroundTransparency = 1
_blLabel.Text = "WS"
_blLabel.TextColor3 = Color3.fromRGB(255, 180, 210)
_blLabel.TextSize = 20
_blLabel.Font = Enum.Font.GothamBold
_blLabel.TextStrokeTransparency = 0.3
_blLabel.TextStrokeColor3 = Color3.fromRGB(180, 40, 100)
_blLabel.ZIndex = 3
_blLabel.Parent = _blFrame

local _blDragging = false
local _blDragStart = nil
local _blStartPos = nil
local _blClickStart = nil

_blFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _blDragging = true
        _blDragStart = input.Position
        _blStartPos = _blFrame.Position
        _blClickStart = tick()
    end
end)

_blFrame.InputChanged:Connect(function(input)
    if _blDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - _blDragStart
        _blFrame.Position = UDim2.new(
            _blStartPos.X.Scale,
            _blStartPos.X.Offset + delta.X,
            _blStartPos.Y.Scale,
            _blStartPos.Y.Offset + delta.Y
        )
    end
end)

_blFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _blDragging = false
        if _blClickStart and (tick() - _blClickStart) < 0.3 then
            local delta = input.Position - _blDragStart
            if delta.Magnitude < 6 then
                Library:Toggle()
            end
        end
        _blClickStart = nil
    end
end)

local _blPulse = 0
RunService.RenderStepped:Connect(function(dt)
    _blPulse = _blPulse + dt * 2
    local s = 0.5 + math.sin(_blPulse) * 0.5
    _blStroke.Color = Color3.fromRGB(200 + math.floor(s*32), 60 + math.floor(s*60), 120 + math.floor(s*60))
    _blLabel.TextColor3 = Color3.fromRGB(255, 150 + math.floor(s*60), 190 + math.floor(s*40))
    _blGlow.ImageTransparency = 0.4 + s * 0.3
end)

SaveManager:LoadAutoloadConfig()
Library:Notify('Wraithsense on here', 5)

Library.OnUnload = function()
    hitboxEnabled = false
    pcall(updateHitbox)
end
