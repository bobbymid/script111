-- ===================================================================
-- Violence District - Optimized Mobile/PC Script
-- ===================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

----------------------------------------------------------------------
-- 1. НАСТРОЙКИ И СОСТОЯНИЯ (STATES)
----------------------------------------------------------------------
local States = {
    Noclip = false,
    SpeedEnabled = false,
    TargetSpeed = 32,
    DefaultSpeed = 16,
    ESPEnabled = false
}

local Connections = {
    Noclip = nil,
    CharacterAdded = nil
}

----------------------------------------------------------------------
-- 2. СИСТЕМА NOCLIP (ИСПРАВЛЕНА: Стена больше не отталкивает)
----------------------------------------------------------------------
local function toggleNoclip(enable)
    States.Noclip = enable
    
    if Connections.Noclip then
        Connections.Noclip:Disconnect()
        Connections.Noclip = nil
    end

    if enable then
        -- Подключаемся к Stepped (срабатывает ДО просчета физики кадра)
        Connections.Noclip = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Восстанавливаем коллизию при отключении
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- 3. СИСТЕМА УСКОРЕНИЯ (SPEED BOOST)
----------------------------------------------------------------------
local function updateSpeed()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if States.SpeedEnabled then
                humanoid.WalkSpeed = States.TargetSpeed
            else
                humanoid.WalkSpeed = States.DefaultSpeed
            end
        end
    end
end

-- Авто-восстановление скорости при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.2)
    updateSpeed()
end)

----------------------------------------------------------------------
-- 4. СИСТЕМА ПОДСВЕТКИ ИГРОКОВ (HIGHLIGHT ESP)
----------------------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupHighlight(character)
        if not character then return end
        
        local highlight = character:FindFirstChild("ESPHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
        end
        highlight.Enabled = States.ESPEnabled
    end

    if player.Character then
        setupHighlight(player.Character)
    end
    player.CharacterAdded:Connect(setupHighlight)
end

local function toggleESP(enable)
    States.ESPEnabled = enable
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if highlight then
                highlight.Enabled = enable
            elseif enable then
                applyESP(player)
            end
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    applyESP(player)
end
Players.PlayerAdded:Connect(applyESP)

----------------------------------------------------------------------
-- 5. МЕХАНИКА СВОБОДНОГО ПЕРЕТАСКИВАНИЯ КНОПКИ (TOUCH / MOUSE DRAG)
----------------------------------------------------------------------
local function makeDraggable(guiObject)
    local dragging = false
    local dragInput = nil
    local dragStart = Vector3.new()
    local startPos = UDim2.new()

    guiObject.Active = true

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

----------------------------------------------------------------------
-- 6. СОЗДАНИЕ ИНТЕРФЕЙСА (GUI)
----------------------------------------------------------------------
local parentGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = parentGui:FindFirstChild("ViolenceDistrictMenu")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Перетаскиваемая кнопка "M" (Главное меню)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "OpenButton"
MenuButton.Size = UDim2.new(0, 50, 0, 50)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Text = "M"
MenuButton.TextSize = 24
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.Parent = ScreenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 25)
btnCorner.Parent = MenuButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 70, 70)
btnStroke.Thickness = 2
btnStroke.Parent = MenuButton

-- Подключаем сенсорное/мышиное перетаскивание к кнопке "M"
makeDraggable(MenuButton)

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = MainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 75)
frameStroke.Thickness = 1.5
frameStroke.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "Violence District Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = Title

-- Функция создания кнопок переключателей
local function createToggleButton(name, text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Text = text .. ": OFF"
        end
        callback(state)
    end)
    return btn
end

-- Кнопка Noclip
createToggleButton("Noclip", "Noclip", 55, function(enabled)
    toggleNoclip(enabled)
end)

-- Кнопка Speed Boost
createToggleButton("Speed", "Speed Boost", 105, function(enabled)
    States.SpeedEnabled = enabled
    updateSpeed()
end)

-- Кнопка ESP
createToggleButton("ESP", "Highlight ESP", 155, function(enabled)
    toggleESP(enabled)
end)

-- Ползунок / Кнопки управления скоростью (+ / -)
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 50)
SpeedFrame.Position = UDim2.new(0.05, 0, 0, 210)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedFrame.Parent = MainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = SpeedFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.25, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. tostring(States.TargetSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = SpeedFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
MinusBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 18
MinusBtn.Parent = SpeedFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
PlusBtn.Position = UDim2.new(0.77, 0, 0.1, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 18
PlusBtn.Parent = SpeedFrame

MinusBtn.MouseButton1Click:Connect(function()
    States.TargetSpeed = math.max(16, States.TargetSpeed - 8)
    SpeedLabel.Text = "Speed: " .. tostring(States.TargetSpeed)
    if States.SpeedEnabled then updateSpeed() end
end)

PlusBtn.MouseButton1Click:Connect(function()
    States.TargetSpeed = math.min(120, States.TargetSpeed + 8)
    SpeedLabel.Text = "Speed: " .. tostring(States.TargetSpeed)
    if States.SpeedEnabled then updateSpeed() end
end)

----------------------------------------------------------------------
-- 7. АНИМАЦИЯ ОТКРЫТИЯ И ЗАКРЫТИЯ МЕНЮ
----------------------------------------------------------------------
local menuOpen = false
local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 280, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 275)
        }):Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 280, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not menuOpen then
                MainFrame.Visible = false
            end
        end)
    end
end

MenuButton.MouseButton1Click:Connect(toggleMenu)
