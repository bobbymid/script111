-- Проверяем, не запущен ли скрипт уже, чтобы не дублировать интерфейс
if game.CoreGui:FindFirstChild("ViolenceDistrictUI") then
    game.CoreGui.ViolenceDistrictUI:Destroy()
end

-- Создаем основу интерфейса в CoreGui (чтобы не пропадал при респавне)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrictUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Переменные состояния
local menuOpen = false
local espActive = false
local highlights = {} -- Таблица для хранения эффектов подсветки

----------------------------------------------------------------
-- 1. СОЗДАНИЕ КРУГЛОЙ КНОПКИ "M" (С перетаскиванием)
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

-- Логика перетаскивания (Drag) для Android
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

----------------------------------------------------------------
-- 2. СОЗДАНИЕ НЕОНОВОГО МЕНЮ (Черно-фиолетовый стиль)
----------------------------------------------------------------
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Parent = ScreenGui
MainMenu.Size = UDim2.new(0, 0, 0, 0) -- Старт с нуля для анимации из центра
MainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
MainMenu.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
MainMenu.ClipsDescendants = true

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(130, 50, 200)
MenuStroke.Parent = MainMenu

local Title = Instance.new("TextLabel")
Title.Parent = MainMenu
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

----------------------------------------------------------------
-- 3. КНОПКА ВКЛЮЧЕНИЯ ESP (Радиокнопка)
----------------------------------------------------------------
local EspContainer = Instance.new("Frame")
EspContainer.Parent = MainMenu
EspContainer.Size = UDim2.new(0.9, 0, 0, 50)
EspContainer.Position = UDim2.new(0.05, 0, 0.4, 0)
EspContainer.BackgroundTransparency = 1

local EspLabel = Instance.new("TextLabel")
EspLabel.Parent = EspContainer
EspLabel.Size = UDim2.new(0.6, 0, 1, 0)
EspLabel.BackgroundTransparency = 1
EspLabel.Text = "Enable ESP"
EspLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
EspLabel.TextSize = 16
EspLabel.Font = Enum.Font.Gotham
EspLabel.TextXAlignment = Enum.TextXAlignment.Left

local RadioButton = Instance.new("TextButton")
RadioButton.Parent = EspContainer
RadioButton.Size = UDim2.new(0, 24, 0, 24)
RadioButton.Position = UDim2.new(0.9, -24, 0.5, -12)
RadioButton.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
RadioButton.Text = ""

local RadioCorner = Instance.new("UICorner")
RadioCorner.CornerRadius = UDim.new(1, 0)
RadioCorner.Parent = RadioButton

local RadioStroke = Instance.new("UIStroke")
RadioStroke.Thickness = 2
RadioStroke.Color = Color3.fromRGB(130, 50, 200)
RadioStroke.Parent = RadioButton

local RadioDot = Instance.new("Frame")
RadioDot.Parent = RadioButton
RadioDot.Size = UDim2.new(0, 0, 0, 0)
RadioDot.Position = UDim2.new(0.5, 0, 0.5, 0)
RadioDot.AnchorPoint = Vector2.new(0.5, 0.5)
RadioDot.BackgroundColor3 = Color3.fromRGB(180, 100, 255)

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = RadioDot

----------------------------------------------------------------
-- 4. ЗЕРКАЛЬНАЯ АНИМАЦИЯ ИНТЕРФЕЙСА
----------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local openTween = TweenService:Create(MainMenu, tweenInfo, {Size = UDim2.new(0, 250, 0, 150)})
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

----------------------------------------------------------------
-- 5. МЕХАНИКА ДИНАМИЧЕСКОГО ЗЕЛЕНОГО ESP (Через Highlights)
----------------------------------------------------------------
-- Функция для удаления всей подсветки
local function clearESP()
    for _, highlight in pairs(highlights) do
        if highlight then highlight:Destroy() end
    end
    table.clear(highlights)
end

-- Функция добавления подсветки на персонажа
local function applyESP(player)
    -- Не подсвечиваем самого себя
    if player == game.Players.LocalPlayer then return end
    
    local function addHighlight(character)
        if not espActive then return end
        if not character:IsDescendantOf(workspace) then return end
        
        -- Если подсветка уже есть, удаляем старую
        if highlights[player] then
            highlights[player]:Destroy()
        end
        
        -- Создаем встроенный неоновый силуэт
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Ярко-зеленый цвет заливки
        highlight.FillTransparency = 0.5                  -- Прозрачность заливки
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0) -- Зеленый контур силуэта
        highlight.OutlineTransparency = 0                 -- Четкий контур
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь любые стены!
        
        highlights[player] = highlight
    end

    if player.Character then
        addHighlight(player.Character)
    end
    
    -- Отслеживаем респавн игрока (например, если киллер убил выжившего и он возродился)
    player.CharacterAdded:Connect(addHighlight)
end

-- Логика переключения радиокнопки
RadioButton.MouseButton1Click:Connect(function()
    espActive = not espActive
    
    -- Анимация точки радиокнопки
    local dotTargetSize = espActive and UDim2.new(0, 12, 0, 12) or UDim2.new(0, 0, 0, 0)
    local dotTween = TweenService:Create(RadioDot, tweenInfo, {Size = dotTargetSize})
    dotTween:Play()
    RadioStroke.Color = espActive and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(130, 50, 200)
    
    if espActive then
        -- Включаем ESP для всех, кто сейчас на сервере
        for _, p in pairs(game.Players:GetPlayers()) do
            applyESP(p)
        end
        
        -- Отслеживаем новых игроков, если они зайдут на сервер
        game.Players.PlayerAdded:Connect(applyESP)
    else
        -- Выключаем и очищаем память
        clearESP()
    end
end)

-- Очистка при удалении игрока с сервера
game.Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)
