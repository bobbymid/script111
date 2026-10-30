if game.CoreGui:FindFirstChild("ViolenceDistrictUltraUI") then
    game.CoreGui.ViolenceDistrictUltraUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictUltraUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local menuOpen = false
local espActive = false
local highlights = {}

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

ToggleButton.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then 
        update(input) 
    end
end)
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
Title.Text = "VIOLENCE DISTRICT v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = MainMenu
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Padding = Instance.new("UIPadding")
Padding.Parent = MainMenu
Padding.PaddingTop = UDim.new(0, 50)

local ContainerESP = Instance.new("Frame")
ContainerESP.Size = UDim2.new(0.9, 0, 0, 40)
ContainerESP.BackgroundTransparency = 1
ContainerESP.LayoutOrder = 1
ContainerESP.Parent = MainMenu

local LabelESP = Instance.new("TextLabel")
LabelESP.Size = UDim2.new(0.7, 0, 1, 0)
LabelESP.BackgroundTransparency = 1
LabelESP.Text = "Enable ESP (All Players)"
LabelESP.TextColor3 = Color3.fromRGB(210, 210, 210)
LabelESP.TextSize = 14
LabelESP.Font = Enum.Font.Gotham
LabelESP.TextXAlignment = Enum.TextXAlignment.Left
LabelESP.Parent = ContainerESP

local RadioESP = Instance.new("TextButton")
RadioESP.Size = UDim2.new(0, 22, 0, 22)
RadioESP.Position = UDim2.new(1, -25, 0.5, -11)
RadioESP.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
RadioESP.Text = ""
RadioESP.Parent = ContainerESP

local RadioCorner = Instance.new("UICorner")
RadioCorner.CornerRadius = UDim.new(1, 0)
RadioCorner.Parent = RadioESP

local RadioStroke = Instance.new("UIStroke")
RadioStroke.Thickness = 2
RadioStroke.Color = Color3.fromRGB(130, 50, 200)
RadioStroke.Parent = RadioESP

local DotESP = Instance.new("Frame")
DotESP.Size = UDim2.new(0, 0, 0, 0)
DotESP.Position = UDim2.new(0.5, 0, 0.5, 0)
DotESP.AnchorPoint = Vector2.new(0.5, 0.5)
DotESP.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
DotESP.Parent = RadioESP

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = DotESP

local function createRegularButton(text, order)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(230, 230, 230)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.LayoutOrder = order
    Button.Parent = MainMenu

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(150, 60, 220)
    Stroke.Parent = Button

    return Button
end

local BtnGen = createRegularButton("TP to Further Gen (+1m)", 2)
local BtnPallet = createRegularButton("Troll Closest Pallet", 3)

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local openTween = TweenService:Create(MainMenu, tweenInfo, {Size = UDim2.new(0, 280, 0, 230)})
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

-- Профессиональное перемещение микро-шагами для полного обхода античита
local function bypassBlink(targetPos)
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Отключаем коллизии тела, чтобы не застрять в стенах
    local noclipping
    noclipping = game:GetService("RunService").Stepped:Connect(function()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    -- Двигаемся микро-шагами по вектору к цели каждый микрокадр
    local distance = (targetPos.Position - hrp.Position).Magnitude
    local stepSize = 4 -- Размер одного шага (оптимально для обхода проверок сервера)
    local steps = math.floor(distance / stepSize)
    local direction = (targetPos.Position - hrp.Position).Unit

    for i = 1, steps do
        if not hrp or not char then break end
        hrp.CFrame = hrp.CFrame + (direction * stepSize)
        game:GetService("RunService").Heartbeat:Wait() -- Ждем один физический кадр
    end

    -- Дожимаем финальную позицию
    hrp.CFrame = targetPos
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    -- Включаем коллизии обратно
    if noclipping then noclipping:Disconnect() end
end

-- Телепорт к самому дальнему генератору через микро-шаги
local function tpToFurtherGenerator()
    local map = workspace:FindFirstChild("Map")
    local gensFolder = map and map:FindFirstChild("Gens")
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and gensFolder then
        local furthestGen = nil
        local maxDistance = -1
        
        for _, gen in pairs(gensFolder:GetChildren()) do
            if gen:IsA("Model") and gen.Name == "Generator" then
                local body = gen:FindFirstChild("GeneratorBody")
                if body and body:IsA("BasePart") then
                    local distance = (hrp.Position - body.Position).Magnitude
                    if distance > maxDistance then
                        maxDistance = distance
                        furthestGen = body
                    end
                end
            end
        end
        
        if furthestGen then
            -- Перемещаемся на безопасную высоту над дальним генератором
            local targetPosition = furthestGen.CFrame * CFrame.new(0, 4, 0)
            bypassBlink(targetPosition)
        end
    end
end

BtnGen.MouseButton1Click:Connect(function()
    tpToFurtherGenerator()
end)

-- Телепорт К паллете (Без возврата назад, чтобы ты мог сам нажать её и не багаться)
local function tpToClosestPallet()
    local map = workspace:FindFirstChild("Map")
    local palletsFolder = map and map:FindFirstChild("Pallets")
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and palletsFolder then
        local closestPallet = nil
        local minDistance = math.huge
        
        for _, palletModel in pairs(palletsFolder:GetChildren()) do
            if palletModel:IsA("Model") and palletModel.Name == "Newpallet" then
                local intact = palletModel:FindFirstChild("Intact")
                local mainPart = intact and intact:FindFirstChild("Pallet")
                
                if mainPart and mainPart:IsA("BasePart") then
                    local distance = (hrp.Position - mainPart.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        closestPallet = palletModel
                    end
                end
            end
        end
        
        if closestPallet then
            local intact = closestPallet:FindFirstChild("Intact")
            local targetPart = intact and intact:FindFirstChild("Pallet")
            
            if targetPart then
                -- Перемещаемся прямо к паллете, чтобы ты её сбросил
                bypassBlink(targetPart.CFrame * CFrame.new(0, 2, 0))
            end
        end
    end
end

BtnPallet.MouseButton1Click:Connect(function()
    tpToClosestPallet()
end)

game.Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)
