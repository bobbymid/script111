if game.CoreGui:FindFirstChild("ViolenceDistrictUltraUI") then
    game.CoreGui.ViolenceDistrictUltraUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictUltraUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Переменные состояния функций
local menuOpen = false
local espActive = false
local speedActive = false
local noclipActive = false
local targetSpeed = 16
local highlights = {}

-- Делаем стандартный прицел игры прозрачным
pcall(function()
    local lp = game.Players.LocalPlayer
    if lp and lp:WaitForChild("PlayerGui") then
        for _, gui in pairs(lp.PlayerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") or gui:IsA("Frame") then
                local n = gui.Name:lower()
                if n:find("crosshair") or n:find("dot") then
                    gui.BackgroundTransparency = 1
                    if gui:IsA("ImageLabel") then 
                        gui.ImageTransparency = 1 
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- 1. Круглая кнопка "M" (С возможностью перетаскивания)
----------------------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
ToggleButton.Text = "M"
ToggleButton.TextColor3 = Color3.fromRGB(180, 100, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 2
ButtonStroke.Color = Color3.fromRGB(180, 100, 255)
ButtonStroke.Parent = ToggleButton

local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Parent = ScreenGui
MainMenu.Size = UDim2.new(0, 0, 0, 0)
MainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
MainMenu.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
MainMenu.ClipsDescendants = true

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(160, 40, 255)
MenuStroke.Parent = MainMenu

local Title = Instance.new("TextLabel")
Title.Parent = MainMenu
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

----------------------------------------------------------------
-- СОЗДАНИЕ КЛАССИЧЕСКОГО СКРОЛЛ-КОНТЕЙНЕРА (SCROLLING FRAME)
----------------------------------------------------------------
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 100, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280) -- Область прокрутки
ScrollFrame.Parent = MainMenu

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ScrollFrame
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Padding = Instance.new("UIPadding")
Padding.Parent = ScrollFrame
Padding.PaddingTop = UDim.new(0, 10)

-- Функция создания радиокнопок внутри скролла
local function createFeatureRadio(text, order)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.9, 0, 0, 35)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = order
    Container.Parent = ScrollFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Radio = Instance.new("TextButton")
    Radio.Size = UDim2.new(0, 22, 0, 22)
    Radio.Position = UDim2.new(1, -25, 0.5, -11)
    Radio.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    Radio.Text = ""
    Radio.Parent = Container

    local RadioCorner = Instance.new("UICorner")
    RadioCorner.CornerRadius = UDim.new(1, 0)
    RadioCorner.Parent = Radio

    local RadioStroke = Instance.new("UIStroke")
    RadioStroke.Thickness = 2
    RadioStroke.Color = Color3.fromRGB(130, 50, 200)
    RadioStroke.Parent = Radio

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 0, 0, 0)
    Dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dot.AnchorPoint = Vector2.new(0.5, 0.5)
    Dot.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
    Dot.Parent = Radio

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    return Radio, Dot, RadioStroke
end

local RadioESP, DotESP, StrokeESP = createFeatureRadio("Enable ESP (All Players)", 1)
local RadioSpeed, DotSpeed, StrokeSpeed = createFeatureRadio("Enable SpeedHack", 2)

----------------------------------------------------------------
-- СОЗДАНИЕ ПОЛЗУНКА СКОРОСТИ
----------------------------------------------------------------
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(0.9, 0, 0, 30)
SliderContainer.BackgroundTransparency = 1
SliderContainer.LayoutOrder = 3
SliderContainer.Parent = ScrollFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(0.65, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 0.5, -3)
SliderTrack.BackgroundColor3 = Color3.fromRGB(35, 25, 50)
SliderTrack.Parent = SliderContainer

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local TrackStroke = Instance.new("UIStroke")
TrackStroke.Thickness = 1
TrackStroke.Color = Color3.fromRGB(130, 50, 200)
TrackStroke.Parent = SliderTrack

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 16, 0, 16)
SliderBtn.Position = UDim2.new(0, 0, 0.5, -8)
SliderBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderTrack

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local SpeedInfo = Instance.new("TextLabel")
SpeedInfo.Size = UDim2.new(0.3, 0, 1, 0)
SpeedInfo.Position = UDim2.new(0.7, 0, 0, 0)
SpeedInfo.BackgroundTransparency = 1
SpeedInfo.Text = "Speed: 16"
SpeedInfo.TextColor3 = Color3.fromRGB(180, 100, 255)
SpeedInfo.TextSize = 13
SpeedInfo.Font = Enum.Font.GothamBold
SpeedInfo.TextXAlignment = Enum.TextXAlignment.Right
SpeedInfo.Parent = SliderContainer

local RadioClip, DotClip, StrokeClip = createFeatureRadio("Horizontal NoClip Walls", 4)

----------------------------------------------------------------
-- НАСТРОЙКА ЗЕРКАЛЬНОЙ АНИМАЦИИ МЕНЮ
----------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local openTween = TweenService:Create(MainMenu, tweenInfo, {Size = UDim2.new(0, 280, 0, 250)})
local closeTween = TweenService:Create(MainMenu, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})

ToggleButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        closeTween:Cancel()
        openTween:Play()
    else
        openTween:Cancel()
        closeTween:Play()
    end
end)

local function animateRadio(active, dot, stroke)
    local targetSize = active and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
    TweenService:Create(dot, tweenInfo, {Size = targetSize}):Play()
    stroke.Color = active and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(130, 50, 200)
end
local function clearESP()
    for _, h in pairs(highlights) do 
        if h then h:Destroy() end 
    end
    table.clear(highlights)
end

local function updateESP()
    if not espActive then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local pl = game.Players:GetPlayerFromCharacter(obj)
            if pl ~= game.Players.LocalPlayer then
                if not obj:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = obj
                    highlight.FillColor = Color3.fromRGB(0, 255, 100)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlights[obj] = highlight
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        if espActive then updateESP() else clearESP() end
    end
end)

RadioESP.MouseButton1Click:Connect(function()
    espActive = not espActive
    animateRadio(espActive, DotESP, StrokeESP)
    if not espActive then clearESP() end
end)

----------------------------------------------------------------
-- ЛОГИКА ПОЛЗУНКА СКОРОСТИ ДЛЯ СЕНСОРНЫХ ЭКРАНОВ (ANDROID)
----------------------------------------------------------------
local sliderDragging = false
local minSpeed = 16
local maxSpeed = 150

local function updateSlider(input)
    local trackWidth = SliderTrack.AbsoluteSize.X
    local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
    local percentage = math.clamp(relativeX / trackWidth, 0, 1)
    
    SliderBtn.Position = UDim2.new(percentage, -8, 0.5, -8)
    
    targetSpeed = math.floor(minSpeed + (percentage * (maxSpeed - minSpeed)))
    SpeedInfo.Text = "Speed: " .. tostring(targetSpeed)
end

SliderBtn.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if sliderDragging then
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

RadioSpeed.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    animateRadio(speedActive, DotSpeed, StrokeSpeed)
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        if speedActive then
            hum.WalkSpeed = targetSpeed
        else
            hum.WalkSpeed = 16
        end
    end
end)

----------------------------------------------------------------
-- 100% РАБОЧИЙ NOCLIP ЧЕРЕЗ СТЕЙТ ГУМАНОИДА (БЕЗ ОТКАТОВ)
----------------------------------------------------------------
RadioClip.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    animateRadio(noclipActive, DotClip, StrokeClip)
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclipActive then
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.NoClip)
            end
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)
