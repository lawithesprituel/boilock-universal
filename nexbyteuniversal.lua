if _G.BoiLockLoaded then
    warn("BoiLock already running!")
    return
end
_G.BoiLockLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Boilock Alpha ',
    Center = true,
    AutoShow = false,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Player = Window:AddTab('Player'),
    Combat = Window:AddTab('Combat'),
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
local selfViewWindow = nil
local selfViewCamera = nil
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
local chatSpamMessage = "BoiLock by NexByte"
local chatSpamDelay = 1
local chatSpamConnection

local stretchedResEnabled = false
local stretchedResAmount = 0.75
local _sRes = {w=nil, h=nil}

local flingEnabled = false
local flingTarget = nil
local flingPower = 500

local waypoints = {}
local selectedWaypoint = nil
local waypointDots = {}

local screenshotFolder = "BoiLock/Screenshots"

local clipboardHistory = {}

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
local autoShootEnabled = false
local autoShootDelay = 0.05

local hitboxExpanderEnabled = false
local hitboxSize = 10
local hitboxTeamCheck = false

local antiAimEnabled = false
local antiAimMode = "Spin"
local antiAimSpeed = 20
local antiAimAngle = 0

local rapidFireEnabled = false
local rapidFireDelay = 0.05

local colorbotEnabled = false
local colorbotTargetColor = Color3.fromRGB(255, 0, 0)
local colorbotStrength = 0.5
local colorbotSmoothing = 5
local colorbotTeamCheck = true
local colorbotColorTolerance = 0.15

local antiRagdollEnabled = false
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

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = 100
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 1
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
    Box3DColor = Color3.fromRGB(255, 100, 0),
    Box3DTeamCheck = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxFillColor = Color3.fromRGB(255, 255, 255),
    BoxFillTransparency = 0.5,
    TracerColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 255, 255),
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
    LookDirColor = Color3.fromRGB(255, 200, 0),
    VelocityArrow = false,
    VelocityColor = Color3.fromRGB(0, 200, 255),
    VisibilityIndicator = true,
    MaxDistance = 500,
    MaxDistanceEnabled = false,
    OffScreenArrow = false,
    OffScreenArrowColor = Color3.fromRGB(255, 80, 80),
    Snapline = false,
    SnaplineColor = Color3.fromRGB(255, 255, 255),
}

local box3dObjects = {}

local radarEnabled = false
local radarSettings = {
    Size = 200,
    Range = 150,
    DotSize = 4,
    Color = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TeamCheck = false,
    X = 100,
    Y = 100,
}
local radarDrawings = {}

local chamsEnabled = false
local chamsObjects = {}
local chamsSettings = {
    Color = Color3.fromRGB(255, 0, 255),
    Transparency = 0.5,
    Rainbow = false,
    TeamCheck = false,
    Mode = "Fill",
    OutlineColor = Color3.fromRGB(255, 0, 255),
    OutlineTransparency = 0,
    AuraPulse = false,
    AuraColor = Color3.fromRGB(0, 150, 255),
    AuraPulseSpeed = 2,
}

local crosshairEnabled = false
local crosshairStyle = "Cross"
local crosshairColor = Color3.fromRGB(255, 255, 255)
local crosshairSize = 10
local crosshairThickness = 1
local crosshairGap = 4
local crosshairOutline = true
local crosshairDrawings = {}

local overlayEnabled = false
local overlayDrawing = nil

local scopeEnabled = false
local scopeLines = {}

local rainbowHue = 0
local function getRainbowColor()
    rainbowHue = rainbowHue + (espSettings.RainbowSpeed * 0.001)
    if rainbowHue >= 1 then rainbowHue = 0 end
    return Color3.fromHSV(rainbowHue, 1, 1)
end

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
    selfDot.Color = Color3.fromRGB(0, 200, 255)
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

    for targetPlayer, esp in pairs(espObjects) do
        local character = targetPlayer.Character
        local valid = character
            and character:FindFirstChild("HumanoidRootPart")
            and character:FindFirstChild("Humanoid")

        if valid then
            local humanoid = character.Humanoid
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")

            local skip = false
            if espSettings.TeamCheck and targetPlayer.Team == player.Team then
                skip = true
            end
            if not skip and (humanoid.Health <= 0 or not head) then
                skip = true
            end
            if not skip and espSettings.MaxDistanceEnabled then
                local dist = (localRoot.Position - rootPart.Position).Magnitude
                if dist > espSettings.MaxDistance then skip = true end
            end
            local onScreen
            if not skip then
                _, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if not onScreen then
                    if espSettings.OffScreenArrow then
                        local screenSize = camera.ViewportSize
                        local cx, cy = screenSize.X / 2, screenSize.Y / 2
                        local sp = camera:WorldToViewportPoint(rootPart.Position)
                        local dir = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Unit
                        local margin = 40
                        local ax = math.clamp(cx + dir.X * (cx - margin), margin, screenSize.X - margin)
                        local ay = math.clamp(cy + dir.Y * (cy - margin), margin, screenSize.Y - margin)
                        local angle = math.atan2(dir.Y, dir.X)
                        local arrowSize = 10
                        local tip = Vector2.new(ax + math.cos(angle) * arrowSize, ay + math.sin(angle) * arrowSize)
                        local left = Vector2.new(ax + math.cos(angle + 2.4) * arrowSize, ay + math.sin(angle + 2.4) * arrowSize)
                        local right = Vector2.new(ax + math.cos(angle - 2.4) * arrowSize, ay + math.sin(angle - 2.4) * arrowSize)
                        local col = espSettings.OffScreenArrowColor
                        esp.Drawings.OffArrowL1.From = tip
                        esp.Drawings.OffArrowL1.To = left
                        esp.Drawings.OffArrowL1.Color = col
                        esp.Drawings.OffArrowL1.Visible = true
                        esp.Drawings.OffArrowL2.From = tip
                        esp.Drawings.OffArrowL2.To = right
                        esp.Drawings.OffArrowL2.Color = col
                        esp.Drawings.OffArrowL2.Visible = true
                        esp.Drawings.OffArrowL3.From = left
                        esp.Drawings.OffArrowL3.To = right
                        esp.Drawings.OffArrowL3.Color = col
                        esp.Drawings.OffArrowL3.Visible = true
                        for k, d in pairs(esp.Drawings) do
                            if k ~= "OffArrowL1" and k ~= "OffArrowL2" and k ~= "OffArrowL3" then d.Visible = false end
                        end
                        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                        for _, l in ipairs(esp.CornerLines) do l.Visible = false end
                    else
                        hideESP(esp)
                    end
                    skip = true
                end
            end

            if skip then
                if not (espSettings.OffScreenArrow and esp.Drawings.OffArrowL1.Visible) then
                    hideESP(esp)
                end
            else
                local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                local anyVisible = false
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        local cf = part.CFrame
                        local sz = part.Size * 0.5
                        local corners3d = {
                            cf * Vector3.new( sz.X,  sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X,  sz.Y,  sz.Z),
                            cf * Vector3.new( sz.X, -sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X, -sz.Y,  sz.Z),
                            cf * Vector3.new( sz.X,  sz.Y, -sz.Z),
                            cf * Vector3.new(-sz.X,  sz.Y, -sz.Z),
                            cf * Vector3.new( sz.X, -sz.Y, -sz.Z),
                            cf * Vector3.new(-sz.X, -sz.Y, -sz.Z),
                        }
                        for _, corner in ipairs(corners3d) do
                            local sp, vis = camera:WorldToViewportPoint(corner)
                            if vis then
                                anyVisible = true
                                if sp.X < minX then minX = sp.X end
                                if sp.Y < minY then minY = sp.Y end
                                if sp.X > maxX then maxX = sp.X end
                                if sp.Y > maxY then maxY = sp.Y end
                            end
                        end
                    end
                end

                if not anyVisible then
                    hideESP(esp)
                else

        local width  = maxX - minX
        local height = maxY - minY
        local bx     = minX
        local by     = minY
        local isLocked = aimbotLock and aimbotLockedTarget == targetPlayer
        local boxColor = isLocked and Color3.fromRGB(255, 50, 50)
            or (espSettings.RainbowBox and getRainbowColor() or espSettings.BoxColor)
        local headPos = camera:WorldToViewportPoint(head.Position)

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
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local hp = math.floor(healthPercent * 100)
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
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barH = height * healthPercent
            local barX = bx - 6
            esp.Drawings.HealthBarBG.Size = Vector2.new(3, height)
            esp.Drawings.HealthBarBG.Position = Vector2.new(barX, by)
            esp.Drawings.HealthBarBG.Visible = true
            esp.Drawings.HealthBarOutline.Size = Vector2.new(5, height + 2)
            esp.Drawings.HealthBarOutline.Position = Vector2.new(barX - 1, by - 1)
            esp.Drawings.HealthBarOutline.Visible = true
            local hue = (healthPercent * 120) / 360
            esp.Drawings.HealthBar.Color = Color3.fromHSV(hue, 1, 1)
            esp.Drawings.HealthBar.Size = Vector2.new(3, barH)
            esp.Drawings.HealthBar.Position = Vector2.new(barX, by + height - barH)
            esp.Drawings.HealthBar.Visible = true
        else
            esp.Drawings.HealthBar.Visible = false
            esp.Drawings.HealthBarBG.Visible = false
            esp.Drawings.HealthBarOutline.Visible = false
        end

        if espSettings.Tracer then
            local screenSize = camera.ViewportSize
            local tFrom = espSettings.TracerOrigin == "Center"
                and Vector2.new(screenSize.X / 2, screenSize.Y / 2)
                or  Vector2.new(screenSize.X / 2, screenSize.Y)
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
            local skeletonParts = {}
            if character:FindFirstChild("UpperTorso") then
                skeletonParts = {
                    {character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso")},
                    {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso")},
                    {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm")},
                    {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm")},
                    {character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand")},
                    {character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm")},
                    {character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm")},
                    {character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")},
                    {character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg")},
                    {character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg")},
                    {character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot")},
                    {character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg")},
                    {character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg")},
                    {character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot")}
                }
            else
                skeletonParts = {
                    {character:FindFirstChild("Head"), character:FindFirstChild("Torso")},
                    {character:FindFirstChild("Torso"), character:FindFirstChild("Left Arm")},
                    {character:FindFirstChild("Torso"), character:FindFirstChild("Right Arm")},
                    {character:FindFirstChild("Torso"), character:FindFirstChild("Left Leg")},
                    {character:FindFirstChild("Torso"), character:FindFirstChild("Right Leg")}
                }
            end
            for i, connection in ipairs(skeletonParts) do
                if esp.SkeletonLines[i] and connection[1] and connection[2] then
                    local pos1, vis1 = camera:WorldToViewportPoint(connection[1].Position)
                    local pos2, vis2 = camera:WorldToViewportPoint(connection[2].Position)
                    if vis1 and vis2 then
                        esp.SkeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                        esp.SkeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                        esp.SkeletonLines[i].Color = espSettings.SkeletonColor
                        esp.SkeletonLines[i].Visible = true
                    else
                        esp.SkeletonLines[i].Visible = false
                    end
                elseif esp.SkeletonLines[i] then
                    esp.SkeletonLines[i].Visible = false
                end
            end
        else
            for _, line in ipairs(esp.SkeletonLines) do
                line.Visible = false
            end
        end

        if espSettings.Snapline then
            local screenSize = camera.ViewportSize
            local snapFrom = Vector2.new(screenSize.X / 2, screenSize.Y)
            local snapTo = Vector2.new(bx + width / 2, by + height)
            esp.Drawings.Snapline.From = snapFrom
            esp.Drawings.Snapline.To = snapTo
            esp.Drawings.Snapline.Color = espSettings.SnaplineColor
            esp.Drawings.Snapline.Visible = true
        else
            esp.Drawings.Snapline.Visible = false
        end

        if espSettings.LookDirection then
            local lookWorld = rootPart.CFrame.LookVector
            local rootSP = camera:WorldToViewportPoint(rootPart.Position)
            local lookSP = camera:WorldToViewportPoint(rootPart.Position + lookWorld * 3)
            esp.Drawings.LookDir.From = Vector2.new(rootSP.X, rootSP.Y)
            esp.Drawings.LookDir.To = Vector2.new(lookSP.X, lookSP.Y)
            esp.Drawings.LookDir.Color = espSettings.LookDirColor
            esp.Drawings.LookDir.Visible = true
        else
            esp.Drawings.LookDir.Visible = false
        end

        if espSettings.VelocityArrow then
            local vel = rootPart.AssemblyLinearVelocity
            if vel.Magnitude > 0.5 then
                local rootSP = camera:WorldToViewportPoint(rootPart.Position)
                local velSP = camera:WorldToViewportPoint(rootPart.Position + vel.Unit * 3)
                esp.Drawings.VelocityArrow.From = Vector2.new(rootSP.X, rootSP.Y)
                esp.Drawings.VelocityArrow.To = Vector2.new(velSP.X, velSP.Y)
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
        else
            hideESP(esp)
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
                    task.wait(0.1)
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
            task.wait(0.1)
            removeESP(targetPlayer)
            removeChams(targetPlayer)
            remove3DBox(targetPlayer)
            createESP(targetPlayer)
            create3DBox(targetPlayer)
            if chamsEnabled then
                task.wait(0.3)
                createChams(targetPlayer)
            end
            local hum = character:WaitForChild("Humanoid", 3)
            if hum then
                hum.Died:Connect(function()
                    task.wait(0.1)
                    removeESP(targetPlayer)
                    remove3DBox(targetPlayer)
                    removeChams(targetPlayer)
                end)
            end
        end)

        targetPlayer.CharacterRemoving:Connect(function()
            removeESP(targetPlayer)
            removeChams(targetPlayer)
            remove3DBox(targetPlayer)
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
        task.wait(0.1)
        removeESP(targetPlayer)
        removeChams(targetPlayer)
        remove3DBox(targetPlayer)
        createESP(targetPlayer)
        create3DBox(targetPlayer)
        if chamsEnabled then
            task.wait(0.3)
            createChams(targetPlayer)
        end
        local hum = character:WaitForChild("Humanoid", 3)
        if hum then
            hum.Died:Connect(function()
                task.wait(0.1)
                removeESP(targetPlayer)
                remove3DBox(targetPlayer)
                removeChams(targetPlayer)
            end)
        end
    end)

    targetPlayer.CharacterRemoving:Connect(function()
        removeESP(targetPlayer)
        removeChams(targetPlayer)
        remove3DBox(targetPlayer)
    end)
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
    removeESP(targetPlayer)
    removeChams(targetPlayer)
    remove3DBox(targetPlayer)
end)

local _espFrame = 0
RunService.Heartbeat:Connect(function()
    _espFrame = _espFrame + 1
    if _espFrame % 2 == 0 then
        pcall(updateESP)
    end
end)
RunService.RenderStepped:Connect(function() pcall(update3DBox) end)
RunService.Heartbeat:Connect(function() pcall(updateRadar) end)
RunService.Heartbeat:Connect(updateChams)

local function createCrosshairDrawings()
    for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end
    crosshairDrawings = {}
    for i = 1, 10 do
        local d = Drawing.new("Line")
        d.Visible = false
        d.ZIndex = 10
        table.insert(crosshairDrawings, d)
    end
    local c = Drawing.new("Circle")
    c.Visible = false
    c.ZIndex = 10
    table.insert(crosshairDrawings, c)
    local co = Drawing.new("Circle")
    co.Visible = false
    co.ZIndex = 9
    table.insert(crosshairDrawings, co)
end
createCrosshairDrawings()

local function updateCrosshair()
    for _, d in pairs(crosshairDrawings) do d.Visible = false end
    if not crosshairEnabled then return end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local cx = camera.ViewportSize.X / 2
    local cy = camera.ViewportSize.Y / 2
    local center = Vector2.new(cx, cy)

    local gap = crosshairGap
    if crosshairStyle == "Dynamic" then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            local speed = Vector2.new(vel.X, vel.Z).Magnitude
            gap = crosshairGap + math.clamp(speed * 0.15, 0, 20)
        end
    end

    local function drawLine(idx, from, to, color, thick, vis)
        local d = crosshairDrawings[idx]
        if not d then return end
        d.From = from
        d.To = to
        d.Color = color
        d.Thickness = thick
        d.Transparency = 1
        d.Visible = vis
    end

    local black = Color3.fromRGB(0, 0, 0)
    local s = crosshairSize
    local t = crosshairThickness

    if crosshairStyle == "Cross" or crosshairStyle == "Dynamic" then
        if crosshairOutline then
            drawLine(1, Vector2.new(cx, cy - gap - s), Vector2.new(cx, cy - gap),     black, t + 2, true)
            drawLine(2, Vector2.new(cx, cy + gap),     Vector2.new(cx, cy + gap + s), black, t + 2, true)
            drawLine(3, Vector2.new(cx - gap - s, cy), Vector2.new(cx - gap, cy),     black, t + 2, true)
            drawLine(4, Vector2.new(cx + gap, cy),     Vector2.new(cx + gap + s, cy), black, t + 2, true)
        end
        drawLine(5, Vector2.new(cx, cy - gap - s), Vector2.new(cx, cy - gap),     crosshairColor, t, true)
        drawLine(6, Vector2.new(cx, cy + gap),     Vector2.new(cx, cy + gap + s), crosshairColor, t, true)
        drawLine(7, Vector2.new(cx - gap - s, cy), Vector2.new(cx - gap, cy),     crosshairColor, t, true)
        drawLine(8, Vector2.new(cx + gap, cy),     Vector2.new(cx + gap + s, cy), crosshairColor, t, true)

    elseif crosshairStyle == "Dot" then
        local dot = crosshairDrawings[11]
        dot.Position = center
        dot.Radius = t + 1
        dot.Color = crosshairColor
        dot.Filled = true
        dot.NumSides = 16
        dot.Transparency = 1
        dot.Visible = true
        if crosshairOutline then
            local outline = crosshairDrawings[12]
            outline.Position = center
            outline.Radius = t + 3
            outline.Color = black
            outline.Filled = false
            outline.Thickness = 1
            outline.NumSides = 16
            outline.Transparency = 1
            outline.Visible = true
        end

    elseif crosshairStyle == "Circle" then
        local circ = crosshairDrawings[11]
        circ.Position = center
        circ.Radius = s
        circ.Color = crosshairColor
        circ.Filled = false
        circ.Thickness = t
        circ.NumSides = 32
        circ.Transparency = 1
        circ.Visible = true
        if crosshairOutline then
            local outline = crosshairDrawings[12]
            outline.Position = center
            outline.Radius = s + 1
            outline.Color = black
            outline.Filled = false
            outline.Thickness = t + 2
            outline.NumSides = 32
            outline.Transparency = 1
            outline.Visible = true
        end
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
                    local distance = (humanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = targetPlayer
                    end
                end
            end

            orbitTarget = closestPlayer
        end
    else
        local foundPlayer = Players:FindFirstChild(orbitTargetName)
        if foundPlayer and foundPlayer ~= player then
            orbitTarget = foundPlayer
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

    moveDirection = moveDirection.Unit

    if flyMethod == "BodyVelocity" then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Parent = humanoidRootPart

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 9e4
            flyBodyGyro.Parent = humanoidRootPart
        end

        flyBodyVelocity.Velocity = moveDirection * flySpeed
        flyBodyGyro.CFrame = camera.CFrame

    elseif flyMethod == "CFrame" then
        stopFly()
        if moveDirection.Magnitude > 0 then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + (moveDirection * (flySpeed / 50))
        end
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    elseif flyMethod == "Tween" then
        stopFly()
        if moveDirection.Magnitude > 0 then
            local targetPos = humanoidRootPart.Position + (moveDirection * (flySpeed / 50))
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

    if noclipMethod == "CanCollide" then
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

    elseif noclipMethod == "Velocity" then
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled and character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end

                    if humanoidRootPart.AssemblyLinearVelocity.Magnitude > 0 then
                        humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity * 1.1
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

local function restoreTextures()
    for obj, data in pairs(originalTextures) do
        if obj and obj.Parent then
            if obj:IsA("BasePart") then
                obj.Material = data.Material
                obj.Transparency = data.Transparency
                obj.Color = data.Color
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = data.Transparency
            end
        end
    end
    originalTextures = {}
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



local function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local savedCFrame = hrp.CFrame
    local savedSpeed = hum.WalkSpeed
    hum.WalkSpeed = 0
    hum.PlatformStand = true

    hrp.CFrame = targetRoot.CFrame * CFrame.new(0, 0.5, 0)
    task.wait()

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(
        math.random(-1, 1) == 0 and flingPower or -flingPower,
        flingPower,
        math.random(-1, 1) == 0 and flingPower or -flingPower
    )
    bv.Parent = targetRoot

    task.wait(0.1)
    pcall(function() bv:Destroy() end)

    hrp.CFrame = savedCFrame
    hum.WalkSpeed = savedSpeed
    hum.PlatformStand = false
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
    end

    return closestPlayer
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
            local aimPos = targetPart.Position

            if aimbotPrediction then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.AssemblyLinearVelocity
                    aimPos = aimPos + vel * aimbotPredictionStrength
                end
            end

            local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
            if not onScreen then return end

            local mousePos = UserInputService:GetMouseLocation()
            local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
            local delta = targetScreen - mousePos
            local smoothed = delta / aimbotSmoothing

            if mousemoverel then
                mousemoverel(smoothed.X, smoothed.Y)
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
end)

RunService.RenderStepped:Connect(updateAimbot)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and fovCircle.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = aimbotFOV
    end
end)

local function updateHitboxes()
    if not hitboxExpanderEnabled then return end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            if not (hitboxTeamCheck and targetPlayer.Team == player.Team) then
                local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    humanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    humanoidRootPart.Transparency = 0.8
                    humanoidRootPart.CanCollide = false
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(updateHitboxes)

local function updateAntiAim(dt)
    if not antiAimEnabled then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.AutoRotate = false

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
    if joint then
        pcall(function() joint.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(targetAngle), 0) end)
    end

    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then
        local rootMotor = lowerTorso:FindFirstChild("Root")
        if rootMotor then
            pcall(function() rootMotor.C0 = CFrame.new(0,0,0) * CFrame.Angles(0, math.rad(targetAngle), 0) end)
        end
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

local function updateColorbot()
    if not colorbotEnabled then return end
    if not getpixelcolor then return end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local vp = camera.ViewportSize
    local cx = math.floor(vp.X / 2)
    local cy = math.floor(vp.Y / 2)

    local fov = math.floor(colorbotStrength * 150)
    local step = 3
    local tr = colorbotTargetColor.R
    local tg = colorbotTargetColor.G
    local tb = colorbotTargetColor.B
    local tolerance = colorbotColorTolerance

    local bestDist = math.huge
    local bestX, bestY = nil, nil

    local x = cx - fov
    while x <= cx + fov do
        local y = cy - fov
        while y <= cy + fov do
            local screenDist = math.sqrt((x - cx)^2 + (y - cy)^2)
            if screenDist <= fov then
                local ok, col = pcall(getpixelcolor, x, y)
                if ok and col then
                    local dr = math.abs(col.R - tr)
                    local dg = math.abs(col.G - tg)
                    local db = math.abs(col.B - tb)
                    if dr <= tolerance and dg <= tolerance and db <= tolerance then
                        if screenDist < bestDist then
                            bestDist = screenDist
                            bestX = x
                            bestY = y
                        end
                    end
                end
            end
            y = y + step
        end
        x = x + step
    end

    if bestX and bestY then
        local current = UserInputService:GetMouseLocation()
        local delta = Vector2.new(bestX - current.X, bestY - current.Y) / colorbotSmoothing
        mousemoverel(delta.X, delta.Y)
    end
end

RunService.RenderStepped:Connect(function()
    pcall(updateColorbot)
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
            fovCircle.Visible = false
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
        fovCircle.Visible = value
    end
})

AimbotBox:AddLabel('FOV Circle Color:'):AddColorPicker('FOVCircleColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'FOV Circle Color',
    Callback = function(value)
        fovCircle.Color = value
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
AimbotBox:AddLabel('Always: Continuous aim')
AimbotBox:AddLabel('Hold: Aim while key pressed')
AimbotBox:AddLabel('Toggle: Press key to toggle')

local HitboxBox = Tabs.Combat:AddLeftGroupbox('Hitbox Expander')

HitboxBox:AddToggle('HitboxExpanderEnabled', {
    Text = 'Enable Hitbox Expander',
    Default = false,
    Callback = function(value)
        hitboxExpanderEnabled = value
        if value then
            Library:Notify('Hitbox Expander enabled', 3)
        else
            Library:Notify('Hitbox Expander disabled', 3)
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character then
                    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.CanCollide = false
                    end
                end
            end
        end
    end
})

HitboxBox:AddSlider('HitboxSize', {
    Text = 'Hitbox Size',
    Default = 10,
    Min = 2,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        hitboxSize = value
    end
})

HitboxBox:AddToggle('HitboxTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Callback = function(value)
        hitboxTeamCheck = value
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end
})

HitboxBox:AddDivider()
HitboxBox:AddLabel('Makes enemies easier to hit')

local AntiAimBox = Tabs.Combat:AddRightGroupbox('Anti Aim')

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

local RapidFireBox = Tabs.Combat:AddRightGroupbox('Rapid Fire')

RapidFireBox:AddToggle('RapidFireEnabled', {
    Text = 'Enable Rapid Fire',
    Default = false,
    Callback = function(v)
        rapidFireEnabled = v
        if not v and rapidFireConnection then
            rapidFireConnection:Disconnect()
            rapidFireConnection = nil
        end
    end
})
RapidFireBox:AddSlider('RapidFireDelay', {
    Text = 'Fire Delay',
    Default = 0.05,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(v) rapidFireDelay = v end
})
RapidFireBox:AddLabel('Re-equip tool to apply')

local ColorbotBox = Tabs.Combat:AddLeftGroupbox('Colorbot')

ColorbotBox:AddToggle('ColorbotEnabled', {
    Text = 'Enable Colorbot',
    Default = false,
    Tooltip = 'Scans screen pixels for target color and moves mouse toward it',
    Callback = function(v) colorbotEnabled = v end
})

ColorbotBox:AddLabel('Target Color:'):AddColorPicker('ColorbotTargetColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Target Color',
    Callback = function(v) colorbotTargetColor = v end
})

ColorbotBox:AddSlider('ColorbotTolerance', {
    Text = 'Color Tolerance',
    Default = 0.15,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(v) colorbotColorTolerance = v end
})

ColorbotBox:AddSlider('ColorbotStrength', {
    Text = 'FOV Radius',
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(v) colorbotStrength = v end
})

ColorbotBox:AddSlider('ColorbotSmoothing', {
    Text = 'Smoothing',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Compact = false,
    Callback = function(v) colorbotSmoothing = v end
})

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
    Default = Color3.fromRGB(255, 100, 0),
    Title = '3D Box Color',
    Callback = function(v) espSettings.Box3DColor = v end
})
ESPBox:AddDivider()
ESPBox:AddToggle('ESPSnapline', {Text = 'Snapline', Default = false, Callback = function(v) espSettings.Snapline = v end})
ESPBox:AddToggle('ESPLookDir', {Text = 'Look Direction', Default = false, Callback = function(v) espSettings.LookDirection = v end})
ESPBox:AddToggle('ESPVelocity', {Text = 'Velocity Arrow', Default = false, Callback = function(v) espSettings.VelocityArrow = v end})
ESPBox:AddToggle('ESPVisibility', {Text = 'Lock Indicator (Aimbot)', Default = true, Callback = function(v) espSettings.VisibilityIndicator = v end})
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
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Box Color',
    Callback = function(v) espSettings.BoxColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Box Fill Color:'):AddColorPicker('ESPBoxFillColor', {
    Default = Color3.fromRGB(255, 255, 255),
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
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Tracer Color',
    Callback = function(v) espSettings.TracerColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Skeleton Color:'):AddColorPicker('ESPSkeletonColor', {
    Default = Color3.fromRGB(255, 255, 255),
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
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Head Dot Color',
    Callback = function(v) espSettings.HeadDotColor = v end
})

ESPColorBox:AddDivider()
ESPColorBox:AddLabel('Snapline Color:'):AddColorPicker('ESPSnaplineColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Snapline Color',
    Callback = function(v) espSettings.SnaplineColor = v end
})
ESPColorBox:AddLabel('Look Dir Color:'):AddColorPicker('ESPLookDirColor', {
    Default = Color3.fromRGB(255, 200, 0),
    Title = 'Look Direction Color',
    Callback = function(v) espSettings.LookDirColor = v end
})
ESPColorBox:AddLabel('Velocity Color:'):AddColorPicker('ESPVelocityColor', {
    Default = Color3.fromRGB(0, 200, 255),
    Title = 'Velocity Arrow Color',
    Callback = function(v) espSettings.VelocityColor = v end
})
ESPColorBox:AddLabel('Off-Screen Color:'):AddColorPicker('ESPOffArrowColor', {
    Default = Color3.fromRGB(255, 80, 80),
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
            RunService:UnbindFromRenderStep("BoiLockStretch")
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
                RunService:BindToRenderStep("BoiLockStretch", Enum.RenderPriority.Camera.Value + 1, function()
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

            RunService:BindToRenderStep("BLThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
                local character = player.Character
                if not character then return end
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.new(0, 0, 0)
                end
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        local parentIsChar = part.Parent == character
                        local parentIsTool = part.Parent and part.Parent:IsA("Tool")
                        local parentIsAccessory = part.Parent and part.Parent:IsA("Accessory")
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

WorldBox:AddToggle('Spinbot', {
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

WorldBox:AddSlider('SpinbotSpeed', {
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
    Default = Color3.fromRGB(255, 0, 0),
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
    Default = Color3.fromRGB(255, 0, 255),
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
    Default = Color3.fromRGB(255, 0, 255),
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

ChamsBox:AddDivider()
ChamsBox:AddLabel('Aura Color:'):AddColorPicker('ChamsAuraColor', {
    Default = Color3.fromRGB(0, 150, 255),
    Title = 'Aura Color',
    Callback = function(value) chamsSettings.AuraColor = value end
})
ChamsBox:AddToggle('ChamsAuraPulse', {
    Text = 'Aura Pulse',
    Default = false,
    Callback = function(value) chamsSettings.AuraPulse = value end
})
ChamsBox:AddSlider('ChamsAuraPulseSpeed', {
    Text = 'Pulse Speed',
    Default = 2,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(value) chamsSettings.AuraPulseSpeed = value end
})

local CrosshairBox = Tabs.Visuals:AddLeftGroupbox('Crosshair')

CrosshairBox:AddToggle('CrosshairEnabled', {
    Text = 'Enable Crosshair',
    Default = false,
    Callback = function(v) crosshairEnabled = v end
})

CrosshairBox:AddDropdown('CrosshairStyle', {
    Text = 'Style',
    Default = 'Cross',
    Values = {'Cross', 'Dot', 'Circle', 'Dynamic'},
    Callback = function(v) crosshairStyle = v end
})

CrosshairBox:AddSlider('CrosshairSize', {
    Text = 'Size',
    Default = 10,
    Min = 3,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairSize = v end
})

CrosshairBox:AddSlider('CrosshairGap', {
    Text = 'Gap',
    Default = 4,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairGap = v end
})

CrosshairBox:AddSlider('CrosshairThickness', {
    Text = 'Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Callback = function(v) crosshairThickness = v end
})

CrosshairBox:AddToggle('CrosshairOutline', {
    Text = 'Outline',
    Default = true,
    Callback = function(v) crosshairOutline = v end
})

CrosshairBox:AddLabel('Color:'):AddColorPicker('CrosshairColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Crosshair Color',
    Callback = function(v) crosshairColor = v end
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

FlingBox:AddInput('FlingTarget', {
    Default = '',
    Numeric = false,
    Finished = true,
    Text = 'Target Player',
    Tooltip = 'Player name to fling',
    Placeholder = 'Enter player name...',
    Callback = function(value)
        flingTarget = Players:FindFirstChild(value)
    end
})

FlingBox:AddSlider('FlingPower', {
    Text = 'Fling Power',
    Default = 500,
    Min = 100,
    Max = 2000,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        flingPower = value
    end
})

FlingBox:AddButton({
    Text = 'Fling Player',
    Func = function()
        if flingTarget then
            flingPlayer(flingTarget)
        else
            Library:Notify('No target selected!', 3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Fling the target player'
})

FlingBox:AddDivider()
FlingBox:AddLabel('Flings target player away')

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
            Library:Notify("Safe Teleport: Active — walk on ground to save position", 3)
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

local SelfViewBox = Tabs.Misc:AddLeftGroupbox('Self View')

SelfViewBox:AddButton({
    Text = 'Open Self Preview',
    Func = function()
        if selfViewEnabled then
            selfViewEnabled = false

            if originalCamera then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            end

            removeESP(player)
            removeChams(player)

            Library:Notify('Self Preview closed', 3)
        else
            selfViewEnabled = true

            local character = player.Character
            if not character then
                Library:Notify('Character not found!', 3)
                selfViewEnabled = false
                return
            end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                Library:Notify('HumanoidRootPart not found!', 3)
                selfViewEnabled = false
                return
            end

            createESP(player)
            if chamsEnabled then
                createChams(player)
            end

            originalCamera = workspace.CurrentCamera.CameraType
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

            local function updateSelfViewCamera()
                if selfViewEnabled and character and humanoidRootPart then
                    local offset = humanoidRootPart.CFrame * CFrame.new(0, 2, 8)
                    workspace.CurrentCamera.CFrame = CFrame.new(offset.Position, humanoidRootPart.Position)
                end
            end

            task.spawn(function()
                while selfViewEnabled do
                    updateSelfViewCamera()
                    task.wait(0.03)
                end
            end)

            Library:Notify('Self Preview opened! Click again to close', 5)
            Library:Notify('You can see your ESP/Chams settings', 3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Preview how you look with current ESP/Chams settings'
})

SelfViewBox:AddDivider()
SelfViewBox:AddLabel('Preview your ESP/Chams')
SelfViewBox:AddLabel('Camera will focus on you')
SelfViewBox:AddLabel('Click again to close preview')

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
                local legParts = {
                    char:FindFirstChild("RightUpperLeg"),
                    char:FindFirstChild("RightLowerLeg"),
                    char:FindFirstChild("RightFoot"),
                }
                local applied = false
                for _, part in pairs(legParts) do
                    if part then
                        for _, v in pairs(char:GetChildren()) do
                            if v.Name == "KorbloxFake_" .. part.Name then v:Destroy() end
                        end
                        part.Transparency = 1
                        local fake = Instance.new("Part")
                        fake.Name = "KorbloxFake_" .. part.Name
                        fake.Size = part.Size
                        fake.Transparency = 0
                        fake.CanCollide = false
                        fake.Anchored = false
                        fake.CastShadow = false
                        fake.CFrame = part.CFrame
                        fake.Parent = char
                        local weld = Instance.new("Motor6D")
                        weld.Name = "KorbloxWeld"
                        weld.Part0 = part
                        weld.Part1 = fake
                        weld.C0 = CFrame.new()
                        weld.C1 = CFrame.new()
                        weld.Parent = fake
                        local mesh = Instance.new("SpecialMesh")
                        mesh.MeshType = Enum.MeshType.FileMesh
                        mesh.MeshId = "rbxassetid://101851696"
                        mesh.TextureId = "rbxassetid://101851254"
                        mesh.Scale = Vector3.new(1, 1, 1)
                        mesh.Parent = fake
                        applied = true
                    end
                end
                if not applied then error("Right leg parts not found!") end
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
                    for _, v in pairs(part:GetChildren()) do
                        if v:IsA("SpecialMesh") then v:Destroy() end
                    end
                    part.Transparency = 0
                end
            end
            for _, v in pairs(char:GetChildren()) do
                if v.Name:sub(1, 12) == "KorbloxFake_" then v:Destroy() end
            end
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 0
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
ThemeManager:SetFolder('BoiLock')
ThemeManager:ApplyToTab(Tabs.Misc)

ThemeManager:ApplyTheme('Default')

Library.BackgroundColor = Color3.fromHex('050810')
Library.MainColor = Color3.fromHex('0a0f1e')
Library.AccentColor = Color3.fromHex('0078d4')
Library.OutlineColor = Color3.fromHex('0d2847')
Library.FontColor = Color3.fromHex('ffffff')
Library:UpdateColorsUsingRegistry()

task.defer(function()
    local gui = Library.GUI
    if not gui then return end
    local mainFrame = gui:FindFirstChildOfClass("Frame")
    if not mainFrame then return end

    local glowColor = Color3.fromRGB(0, 120, 212)

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
SaveManager:SetFolder('BoiLock/Configs')
SaveManager:BuildConfigSection(Tabs.Misc)

ConfigBox:AddDivider()

ConfigBox:AddButton({
    Text = 'Open Config Folder',
    Func = function()
        local folderPath = 'BoiLock/Configs'
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
ConfigBox:AddLabel('Folder: BoiLock/Configs')

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
        Library:Notify('unloading the boilock', 3)

        espEnabled = false
        chamsEnabled = false
        thirdPersonEnabled = false
        spinbotEnabled = false
        flyEnabled = false
        walkSpeedEnabled = false
        jumpPowerEnabled = false
        noclipEnabled = false
        infiniteJumpEnabled = false
        selfViewEnabled = false
        antiAFKEnabled = false
        bunnyHopEnabled = false
        autoSprintEnabled = false
        removeTexturesEnabled = false
        noWaterEnabled = false
        wireframeEnabled = false
        noFogEnabled = false
        aimbotEnabled = false
        hitboxExpanderEnabled = false
        antiAimEnabled = false
        rapidFireEnabled = false
        flingEnabled = false
        radarEnabled = false
        colorbotEnabled = false
        antiRagdollEnabled = false
        antiStunEnabled = false
        antiVoidEnabled = false
        safeTeleportEnabled = false
        safeTeleportLastPos = nil

        if antiRagdollEnabled then
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BallSocketConstraint") or part:IsA("HingeConstraint") then
                        part.Enabled = true
                    end
                end
            end
        end

        RunService:UnbindFromRenderStep("BLThirdPerson")
        RunService:UnbindFromRenderStep("BLSpinbot")
        RunService:UnbindFromRenderStep("BLAntiAim")

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

        if rapidFireConnection then
            rapidFireConnection:Disconnect()
            rapidFireConnection = nil
        end

        stretchedResEnabled = false
        RunService:UnbindFromRenderStep("BoiLockStretch")
        workspace.CurrentCamera.FieldOfView = 70
        if setresolution and _sRes.w then
            setresolution(_sRes.w, _sRes.h)
            _sRes.w = nil
            _sRes.h = nil
        end

        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end

        restoreTextures()
        restoreWater()
        disableWireframe()
        for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        restoreLightingSettings()
        workspace.Gravity = 196.2

        stopAntiAFK()
        stopBunnyHop()

        if originalCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            workspace.CurrentCamera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        end

        stopInfiniteJump()

        stopNoclip()

        stopFly()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.WalkSpeed = 16
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = 50
                else
                    humanoid.JumpHeight = 7.2
                end
            end
        end

        for targetPlayer, esp in pairs(espObjects) do
            for _, drawing in pairs(esp.Drawings) do
                pcall(function() drawing:Remove() end)
            end
            for _, line in pairs(esp.SkeletonLines) do
                pcall(function() line:Remove() end)
            end
            for _, line in pairs(esp.CornerLines or {}) do
                pcall(function() line:Remove() end)
            end
        end
        espObjects = {}

        for targetPlayer, lines in pairs(box3dObjects) do
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
        createRadarDrawings()

        if fovCircle then
            fovCircle.Visible = false
            pcall(function() fovCircle:Remove() end)
        end

        for targetPlayer, chams in pairs(chamsObjects) do
            pcall(function() chams:Destroy() end)
        end
        chamsObjects = {}

        for name, dot in pairs(waypointDots) do
            pcall(function() dot:Destroy() end)
        end
        waypointDots = {}

        crosshairEnabled = false
        overlayEnabled = false
        scopeEnabled = false
        for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end
        crosshairDrawings = {}
        if overlayDrawing then pcall(function() overlayDrawing:Remove() end) end
        overlayDrawing = nil
        for _, l in pairs(scopeLines) do pcall(function() l:Remove() end) end
        scopeLines = {}

        workspace.CurrentCamera.FieldOfView = 70
        if originalCameraMode then
            player.CameraMode = originalCameraMode
        end
        player.CameraMaxZoomDistance = 128
        player.CameraMinZoomDistance = 0.5
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
        end

        task.wait(0.5)

        pcall(function()
            if Library.Unload then
                Library:Unload()
            end
        end)

        pcall(function()
            if Library.Destroy then
                Library:Destroy()
            end
        end)

        pcall(function()
            for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
                if v.Name:find("LinoriaGui") or v.Name:find("Library") then
                    v:Destroy()
                end
            end
        end)

        _G.BoiLockLoaded = nil
        Library:Notify('boilock unloading', 3)
    end,
    DoubleClick = true,
    Tooltip = 'Double click to unload the script'
})

local function updateWatermark()
    local dt = RunService.RenderStepped:Wait()
    local fps = dt > 0 and math.floor(1 / dt) or 0
    local ping = math.floor(player:GetNetworkPing() * 1000)
    Library:SetWatermark(string.format("BoiLock | %s | FPS: %d | Ping: %dms", player.Name, fps, ping))
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
_blFrame.BackgroundColor3 = Color3.fromRGB(8, 18, 40)
_blFrame.BorderSizePixel = 0
_blFrame.ZIndex = 2
_blFrame.Parent = _blGui

local _blCorner = Instance.new("UICorner")
_blCorner.CornerRadius = UDim.new(1, 0)
_blCorner.Parent = _blFrame

local _blStroke = Instance.new("UIStroke")
_blStroke.Color = Color3.fromRGB(80, 160, 255)
_blStroke.Thickness = 2
_blStroke.Parent = _blFrame

local _blGlow = Instance.new("ImageLabel")
_blGlow.Size = UDim2.new(0, 100, 0, 100)
_blGlow.Position = UDim2.new(0.5, -50, 0.5, -50)
_blGlow.BackgroundTransparency = 1
_blGlow.Image = "rbxassetid://5028857084"
_blGlow.ImageColor3 = Color3.fromRGB(0, 100, 255)
_blGlow.ImageTransparency = 0.5
_blGlow.ZIndex = 1
_blGlow.Parent = _blFrame

local _blLabel = Instance.new("TextLabel")
_blLabel.Size = UDim2.new(1, 0, 1, 0)
_blLabel.BackgroundTransparency = 1
_blLabel.Text = "BL"
_blLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
_blLabel.TextSize = 20
_blLabel.Font = Enum.Font.GothamBold
_blLabel.TextStrokeTransparency = 0.3
_blLabel.TextStrokeColor3 = Color3.fromRGB(0, 60, 180)
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
    _blStroke.Color = Color3.fromRGB(60 + math.floor(s*80), 140 + math.floor(s*60), 255)
    _blLabel.TextColor3 = Color3.fromRGB(100 + math.floor(s*80), 180 + math.floor(s*40), 255)
    _blGlow.ImageTransparency = 0.4 + s * 0.3
end)

Library.OnUnload = function()
    pcall(function() _blGui:Destroy() end)

    RunService:UnbindFromRenderStep("BLThirdPerson")
    RunService:UnbindFromRenderStep("BLSpinbot")
    RunService:UnbindFromRenderStep("BLAntiAim")
    RunService:UnbindFromRenderStep("BoiLockStretch")

    for _, esp in pairs(espObjects) do
        for _, d in pairs(esp.Drawings) do pcall(function() d:Remove() end) end
        for _, l in pairs(esp.SkeletonLines) do pcall(function() l:Remove() end) end
        for _, l in pairs(esp.CornerLines or {}) do pcall(function() l:Remove() end) end
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

    for _, highlight in pairs(chamsObjects) do
        pcall(function() highlight:Destroy() end)
    end
    chamsObjects = {}

    if fovCircle then pcall(function() fovCircle:Remove() end) end

    for _, d in pairs(crosshairDrawings) do pcall(function() d:Remove() end) end
    crosshairDrawings = {}
    if overlayDrawing then pcall(function() overlayDrawing:Remove() end) end
    for _, l in pairs(scopeLines) do pcall(function() l:Remove() end) end
    scopeLines = {}

    for _, dot in pairs(waypointDots) do pcall(function() dot:Destroy() end) end
    waypointDots = {}

    if rapidFireConnection then rapidFireConnection:Disconnect() end

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = 16
            if humanoid.UseJumpPower then humanoid.JumpPower = 50 else humanoid.JumpHeight = 7.2 end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local joint = hrp:FindFirstChild("RootJoint")
            if joint then joint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0) end
        end
    end

    player.CameraMaxZoomDistance = 128
    player.CameraMinZoomDistance = 0.5
    workspace.CurrentCamera.FieldOfView = 70

    if setresolution and _sRes.w then
        setresolution(_sRes.w, _sRes.h)
        _sRes.w = nil
        _sRes.h = nil
    end

    _G.BoiLockLoaded = nil
end

SaveManager:LoadAutoloadConfig()
Library:Notify('boilock on here', 5)
