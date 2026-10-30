if game.CoreGui:FindFirstChild("ViolenceDistrictUltraUI") then
    game.CoreGui.ViolenceDistrictUltraUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictUltraUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local menuOpen = false
local espActive = false
local tpGenActive = false
local trollPalletActive = false
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

local function createFeatureButton(text, order)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.9, 0, 0, 40)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = order
    Container.Parent = MainMenu

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

local RadioESP, DotESP, StrokeESP = createFeatureButton("Enable ESP (All Players)", 1)
local RadioGen, DotGen, StrokeGen = createFeatureButton("TP to Further Gen (+1m)", 2)
local RadioPallet, DotPallet, StrokePallet = createFeatureButton("Troll Closest Pallet", 3)

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

local function applyESP(player)
    if player == game.Players.LocalPlayer then return end
    local function addHighlight(character)
        if not espActive then return end
        if highlights[player] then 
            highlights[player]:Destroy() 
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(0, 255, 100)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlights[player] = highlight
    end
    if player.Character then addHighlight(player.Character) end
    player.CharacterAdded:Connect(addHighlight)
end

RadioESP.MouseButton1Click:Connect(function()
    espActive = not espActive
    animateRadio(espActive, DotESP, StrokeESP)
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do 
            applyESP(p) 
        end
        game.Players.PlayerAdded:Connect(applyESP)
    else
        clearESP()
    end
end)

local function tpToFurtherGenerator()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local map = workspace:FindFirstChild("Map")
    local gensFolder = map and map:FindFirstChild("Gens")
    
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
            hrp.CFrame = furthestGen.CFrame * CFrame.new(0, 4.5, 0)
        end
    end
end

RadioGen.MouseButton1Click:Connect(function()
    tpGenActive = not tpGenActive
    animateRadio(tpGenActive, DotGen, StrokeGen)
    
    if tpGenActive then
        tpToFurtherGenerator()
        task.wait(0.2)
        tpGenActive = false
        animateRadio(false, DotGen, StrokeGen)
    end
end)

local function dropClosestPallet()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local map = workspace:FindFirstChild("Map")
    local palletsFolder = map and map:FindFirstChild("Pallets")
    
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
        
        if closestPallet and minDistance < 25 then
            pcall(function()
                local prompt = closestPallet:FindFirstChildWhichIsA(
                    "ProximityPrompt", 
                    true
                )
                if prompt then
                    fireproximityprompt(prompt)
                else
                    local intactPallet = closestPallet.Intact.Pallet
                    firetouchinterest(hrp, intactPallet, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, intactPallet, 1)
                end
            end)
        end
    end
end

RadioPallet.MouseButton1Click:Connect(function()
    trollPalletActive = not trollPalletActive
    animateRadio(trollPalletActive, DotPallet, StrokePallet)
    
    if trollPalletActive then
        dropClosestPallet()
        task.wait(0.2)
        trollPalletActive = false
        animateRadio(false, DotPallet, StrokePallet)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)

