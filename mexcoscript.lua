-- ===================================================================
-- Violence District - CFrame Movement & Noclip Fix (Futuristic UI)
-- ===================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------------
-- 1. НАСТРОЙКИ И СОСТОЯНИЯ
----------------------------------------------------------------------
local States = {
    Noclip = false,
    SpeedEnabled = false,
    TargetSpeed = 32,
    DefaultSpeed = 16,
    ESPEnabled = false
}

----------------------------------------------------------------------
-- 2. ЦИКЛ ОБХОДА АНТИЧИТА И РЕАЛИЗАЦИЯ NOCLIP / SPEED ЧЕРЕЗ CFRAME
----------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid then
        if States.Noclip then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            if humanoid.MoveDirection.Magnitude > 0 then
                local speed = States.SpeedEnabled and States.TargetSpeed or humanoid.WalkSpeed
                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * speed * dt)
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        elseif States.SpeedEnabled then
            if humanoid.MoveDirection.Magnitude > 0 then
                local moveDir = humanoid.MoveDirection
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * States.TargetSpeed, hrp.AssemblyLinearVelocity.Y, moveDir.Z * States.TargetSpeed)
            end
        end
    end
end)

----------------------------------------------------------------------
-- 3. СИСТЕМА ПОДСВЕТКИ ИГРОКОВ (HIGHLIGHT ESP)
----------------------------------------------------------------------
local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupHighlight(character)
        if not character then return end
        
        local highlight = character:FindFirstChild("ESPHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            -- Неоновый красный для ESP
            highlight.FillColor = Color3.fromRGB(255, 0, 100)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.7
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
-- 4. МЕХАНИКА СВОБОДНОГО ПЕРЕТАСКИВАНИЯ КНОПКИ
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
-- 5. СОЗДАНИЕ ФУТУРИСТИЧНОГО ИНТЕРФЕЙСА (GUI)
----------------------------------------------------------------------
local parentGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = parentGui:FindFirstChild("ViolenceDistrictMenu")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui
ScreenGui.IgnoreGuiInset = true

-- Перетаскиваемая кнопка "M" (Неоновая)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "OpenButton"
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Text = "M"
MenuButton.TextSize = 28
MenuButton.Font = Enum.Font.GothamBlack
MenuButton.Parent = ScreenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0) -- Полный круг
btnCorner.Parent = MenuButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 255, 255) -- Циановая неоновая обводка
btnStroke.Thickness = 2
btnStroke.Transparency = 0.6
btnStroke.Parent = MenuButton

-- Эффект свечения (Neon Glow)
local btnGlow = Instance.new("ImageLabel")
btnGlow.Image = "rbxassetid://549760022" -- Стандартный круг для свечения
btnGlow.ImageColor3 = Color3.fromRGB(0, 255, 255)
btnGlow.BackgroundTransparency = 1
btnGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
btnGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
btnGlow.Visible = false
btnGlow.Parent = MenuButton

makeDraggable(MenuButton)

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = MainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 255, 255)
frameStroke.Thickness = 2
frameStroke.Transparency = 0.5
frameStroke.Parent = MainFrame

-- Футуристичный градиентный фон (вертикальные полосы)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
UIGradient.Rotation = 90
UIGradient.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundTransparency = 0.5
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = Title

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(255, 0, 0) -- Красный акцент
titleStroke.Thickness = 1
titleStroke.Parent = Title

-- Контейнер для кнопок
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 1, -60)
ButtonContainer.Position = UDim2.new(0, 0, 0, 60)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = ButtonContainer

local function updateToggle(btn, state, text)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        btn.Text = text .. ": ON"
    else
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.Text = text .. ": OFF"
    end
end

local function createToggleButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSans
    btn.Parent = ButtonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 60)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    -- Анимация наведения
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.6, Position = UDim2.new(0.075, 5, 0, 0)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, Position = UDim2.new(0.075, 0, 0, 0)}):Play()
    end)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle(btn, state, text)
        callback(state)
    end)
    return btn
end

createToggleButton("Noclip", function(enabled) States.Noclip = enabled end)
createToggleButton("Speed Boost", function(enabled) States.SpeedEnabled = enabled end)
createToggleButton("Highlight ESP", function(enabled) toggleESP(enabled) end)

-- Панель настройки скорости
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.85, 0, 0, 60)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SpeedFrame.Parent = ButtonContainer

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 10)
speedCorner.Parent = SpeedFrame

local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(50, 50, 60)
speedStroke.Thickness = 1
speedStroke.Parent = SpeedFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.25, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: " .. tostring(States.TargetSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansSemibold
SpeedLabel.Parent = SpeedFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
MinusBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 20
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = SpeedFrame
local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 8)
minusCorner.Parent = MinusBtn

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
PlusBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 20
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = SpeedFrame
local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 8)
plusCorner.Parent = PlusBtn

MinusBtn.MouseButton1Click:Connect(function()
    States.TargetSpeed = math.max(16, States.TargetSpeed - 8)
    SpeedLabel.Text = "SPEED: " .. tostring(States.TargetSpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    States.TargetSpeed = math.min(120, States.TargetSpeed + 8)
    SpeedLabel.Text = "SPEED: " .. tostring(States.TargetSpeed)
end)

----------------------------------------------------------------------
-- 6. АНИМАЦИЯ ОКНА И ЛОГИКА ОТКРЫТИЯ
----------------------------------------------------------------------
local menuOpen = false

MenuButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 320, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 320, 0, 400)
        }):Play()
        btnGlow.Visible = true
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 320, 0, 0)
        })
        tween.Completed:Connect(function()
            if not menuOpen then
                MainFrame.Visible = false
                btnGlow.Visible = false
            end
        end)
        tween:Play()
    end
end)

-- Эффект нажатия на кнопку M
MenuButton.MouseButton1Down:Connect(function()
    TweenService:Create(MenuButton, TweenInfo.new(0.05), {Size = UDim2.new(0, 55, 0, 55)}):Play()
end)
MenuButton.MouseButton1Up:Connect(function()
    TweenService:Create(MenuButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)
