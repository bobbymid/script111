-- ===================================================================
-- Violence District - Key System (24h), Scroll, Drag & Full Clean UI
-- ===================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- База данных постоянных ключей
local validKeys = {
    -- mex ключи
    ["mex12"] = true, ["mex76"] = true, ["mex04"] = true, ["mex33"] = true,
    ["mex55"] = true, ["mex81"] = true, ["mex19"] = true, ["mex42"] = true,
    ["mex67"] = true, ["mex90"] = true, ["mex25"] = true, ["mex88"] = true,
    -- co ключи
    ["co64"] = true, ["co93"] = true, ["co12"] = true, ["co35"] = true,
    ["co47"] = true, ["co52"] = true, ["co78"] = true, ["co81"] = true,
    ["co24"] = true, ["co99"] = true, ["co15"] = true, ["co33"] = true,
}

local parentGui = LocalPlayer:WaitForChild("PlayerGui")

-- Проверка сохраненного доступа на 24 часа (в секундах: 24 * 3600 = 86400)
local function hasValidSession()
    local savedTime = getgenv().VD_AccessExpiry
    if savedTime and os.time() < savedTime then
        return true
    end
    return false
end

-- Очистка старых интерфейсов
if parentGui:FindFirstChild("ViolenceDistrictMenu") then parentGui.ViolenceDistrictMenu:Destroy() end
if parentGui:FindFirstChild("ViolenceDistrictKeyGui") then parentGui.ViolenceDistrictKeyGui:Destroy() end

----------------------------------------------------------------------
-- 1. ФУНКЦИЯ ОСНОВНОГО СКРИПТА
----------------------------------------------------------------------
local function startMainCheat()
    local States = {
        ESPEnabled = false,
        AutoParryEnabled = false,
        GriddyEnabled = false,
        AutoSkillCheckEnabled = false
    }

    -- Конфигурация Auto Skill Check
    local CONFIG = {
        CheckInterval = 0.01,
        TriggerKey = Enum.KeyCode.Space,
        CustomTapX = 0.5,
        CustomTapY = 0.5,
    }

    local skillCheckConnection = nil

    local function triggerMobileTap()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local tapX = viewportSize.X * CONFIG.CustomTapX
        local tapY = viewportSize.Y * CONFIG.CustomTapY

        VirtualInputManager:SendTouchEvent(0, 0, tapX, tapY)
        task.wait(0.02)
        VirtualInputManager:SendTouchEvent(0, 2, tapX, tapY)
    end

    local function hitSkillCheck()
        VirtualInputManager:SendKeyEvent(true, CONFIG.TriggerKey, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, CONFIG.TriggerKey, false, game)
        triggerMobileTap()
    end

    local function processSkillCheckUI()
        local skillCheckGui = parentGui:FindFirstChild("SkillCheck") 
                           or parentGui:FindFirstChild("GeneratorGui") 
                           or parentGui:FindFirstChild("RepairGui")

        if not skillCheckGui or not skillCheckGui.Enabled then
            return
        end

        local mainFrame = skillCheckGui:FindFirstChild("Frame") or skillCheckGui:FindFirstChild("Main")
        if not mainFrame then return end

        local needle = mainFrame:FindFirstChild("Needle") or mainFrame:FindFirstChild("Pointer")
        local perfectZone = mainFrame:FindFirstChild("PerfectZone") or mainFrame:FindFirstChild("WhiteZone")

        if needle and perfectZone and needle.Visible and perfectZone.Visible then
            if needle:IsA("GuiObject") and needle.Rotation ~= nil then
                local needleAngle = needle.Rotation % 360
                local targetAngle = perfectZone.Rotation % 360
                local tolerance = 3
                
                if math.abs(needleAngle - targetAngle) <= tolerance then
                    hitSkillCheck()
                    task.wait(0.5)
                end
            elseif needle:IsA("GuiObject") then
                local needleX = needle.AbsolutePosition.X
                local perfectX = perfectZone.AbsolutePosition.X
                local perfectWidth = perfectZone.AbsoluteSize.X

                if needleX >= perfectX and needleX <= (perfectX + perfectWidth) then
                    hitSkillCheck()
                    task.wait(0.5)
                end
            end
        end
    end

    local function isPlayerRepairing()
        local character = LocalPlayer.Character
        if not character then return false end
        
        if character:GetAttribute("IsRepairing") or LocalPlayer:GetAttribute("Repairing") then
            return true
        end

        local activeGui = parentGui:FindFirstChild("SkillCheck") or parentGui:FindFirstChild("RepairGui")
        if activeGui and activeGui.Enabled then
            return true
        end

        return false
    end

    local function manageAutoSkillCheck(enable)
        if enable then
            if not skillCheckConnection then
                skillCheckConnection = RunService.Heartbeat:Connect(function()
                    if States.AutoSkillCheckEnabled and isPlayerRepairing() then
                        processSkillCheckUI()
                    end
                end)
            end
        else
            if skillCheckConnection then
                skillCheckConnection:Disconnect()
                skillCheckConnection = nil
            end
        end
    end

    -- Логика Griddy Emote
    local TARGET_EMOTE_NAME = "Griddy" 
    local emoteTrack = nil
    local loopConnection = nil

    local function stopEmote()
        if loopConnection then loopConnection:Disconnect() loopConnection = nil end
        if emoteTrack then emoteTrack:Stop() emoteTrack = nil end
    end

    local function startEmote()
        stopEmote()
        if not States.GriddyEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        local animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end

        local animId = "rbxassetid://131695692404479" 
        
        if TARGET_EMOTE_NAME ~= "Griddy" then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if string.find(string.lower(track.Name), string.lower(TARGET_EMOTE_NAME)) then
                    animId = track.Animation.AnimationId
                    break
                end
            end
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = animId

        emoteTrack = animator:LoadAnimation(animation)
        emoteTrack.Priority = Enum.AnimationPriority.Action4
        emoteTrack.Looped = true
        emoteTrack:Play()

        local cleanTargetId = string.match(animId, "%d+")
        
        loopConnection = RunService.Heartbeat:Connect(function()
            if not States.GriddyEnabled then
                stopEmote()
                return
            end

            if not character or not character:IsDescendantOf(workspace) then
                stopEmote()
                return
            end

            if emoteTrack and not emoteTrack.IsPlaying then
                emoteTrack:Play()
            end

            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local trackId = string.match(track.Animation.AnimationId, "%d+")
                if trackId ~= cleanTargetId then
                    track:Stop(0)
                end
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if States.GriddyEnabled then
            task.wait(1.5)
            startEmote()
        end
    end)

    -- ESP Система
    local function applyESP(player)
        if player == LocalPlayer then return end
        local function setupHighlight(character)
            if not character then return end
            local highlight = character:FindFirstChild("ESPHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 100)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
            end
            highlight.Enabled = States.ESPEnabled
        end
        if player.Character then setupHighlight(player.Character) end
        player.CharacterAdded:Connect(setupHighlight)
    end

    local function toggleESP(enable)
        States.ESPEnabled = enable
        local function updatePlayersESP()
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
        pcall(updatePlayersESP)
    end

    for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
    Players.PlayerAdded:Connect(applyESP)

    -- Auto Parry
    RunService.Heartbeat:Connect(function()
        if not States.AutoParryEnabled then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local myHrp = character.HumanoidRootPart

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local enemyHrp = player.Character:FindFirstChild("HumanoidRootPart")
                if enemyHrp then
                    local distance = (myHrp.Position - enemyHrp.Position).Magnitude
                    if distance <= 12 then
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") or game:GetService("ReplicatedStorage")
                        local parryEvent = remotes:FindFirstChild("Parry") or remotes:FindFirstChild("DaggerParry") or remotes:FindFirstChild("UseAbility")
                        
                        if parryEvent and parryEvent:IsA("RemoteEvent") then
                            parryEvent:FireServer()
                        end
                        break
                    end
                end
            end
        end
    end)

    -- Универсальная функция перетаскивания (для кнопки и для главного окна)
    local function makeDraggable(guiObject, handle)
        handle = handle or guiObject
        local dragging, dragInput, dragStart, startPos = false, nil, Vector3.new(), UDim2.new()

        handle.Active = true
        handle.InputBegan:Connect(function(input)
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

        handle.InputChanged:Connect(function(input)
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

    -- Интерфейс главного меню
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ViolenceDistrictMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentGui
    ScreenGui.IgnoreGuiInset = true

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
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = MenuButton

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(0, 255, 255)
    btnStroke.Thickness = 2
    btnStroke.Transparency = 0.6
    btnStroke.Parent = MenuButton

    local btnGlow = Instance.new("ImageLabel")
    btnGlow.Image = "rbxassetid://549760022"
    btnGlow.ImageColor3 = Color3.fromRGB(0, 255, 255)
    btnGlow.BackgroundTransparency = 1
    btnGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
    btnGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    btnGlow.Visible = false
    btnGlow.Parent = MenuButton

    makeDraggable(MenuButton)

    -- Главное окно фиксированного размера (с вертикальным свайпом)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
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

    -- Заголовок (он же зона для перетаскивания окна)
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
    titleStroke.Color = Color3.fromRGB(255, 0, 0)
    titleStroke.Thickness = 1
    titleStroke.Parent = Title

    makeDraggable(MainFrame, Title) -- Теперь окно можно двигать за шапку

    -- Крестик закрытия скрипта справа сверху
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Text = "X"
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = MainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        stopEmote()
        manageAutoSkillCheck(false)
        ScreenGui:Destroy()
    end)

    -- Скролл-контейнер для вертикального свайпа
    local ScrollingContainer = Instance.new("ScrollingFrame")
    ScrollingContainer.Size = UDim2.new(1, 0, 1, -60)
    ScrollingContainer.Position = UDim2.new(0, 0, 0, 60)
    ScrollingContainer.BackgroundTransparency = 1
    ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 260) -- Высота содержимого под прокрутку
    ScrollingContainer.ScrollBarThickness = 4
    ScrollingContainer.Parent = MainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = ScrollingContainer

    local function createToggleButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.85, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.TextSize = 16
        btn.Font = Enum.Font.SourceSans
        btn.Parent = ScrollingContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(50, 50, 60)
        stroke.Thickness = 1
        stroke.Parent = btn
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                btn.TextColor3 = Color3.fromRGB(0, 255, 255)
                btn.Text = text .. ": ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                btn.Text = text .. ": OFF"
            end
            callback(state)
        end)
        return btn
    end

    -- Создаем кнопки функций в скролле
    createToggleButton("Highlight ESP", function(enabled) toggleESP(enabled) end)
    createToggleButton("Auto Parry", function(enabled) States.AutoParryEnabled = enabled end)
    createToggleButton("Auto Skill Check", function(enabled) 
        States.AutoSkillCheckEnabled = enabled 
        manageAutoSkillCheck(enabled)
    end)
    createToggleButton("Griddy Emote", function(enabled)
        States.GriddyEnabled = enabled
        if enabled then
            startEmote()
        else
            stopEmote()
        end
    end)

    local menuOpen = false
    MenuButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 320, 0, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 320, 0, 320)
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
end

----------------------------------------------------------------------
-- 2. ПРОВЕРКА СЕССИИ ИЛИ ЗАПУСК ОКНА КЛЮЧЕЙ
----------------------------------------------------------------------
if hasValidSession() then
    startMainCheat()
else
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "ViolenceDistrictKeyGui"
    KeyGui.ResetOnSpawn = false
    KeyGui.Parent = parentGui
    KeyGui.IgnoreGuiInset = true

    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 320, 0, 220)
    KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    KeyFrame.BackgroundTransparency = 0.1
    KeyFrame.Parent = KeyGui

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(0, 15)
    kCorner.Parent = KeyFrame

    local kStroke = Instance.new("UIStroke")
    kStroke.Color = Color3.fromRGB(0, 255, 255)
    kStroke.Thickness = 2
    kStroke.Transparency = 0.5
    kStroke.Parent = KeyFrame

    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Size = UDim2.new(1, 0, 0, 40)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "AUTHORIZATION"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.TextSize = 18
    KeyTitle.Font = Enum.Font.GothamBlack
    KeyTitle.Parent = KeyFrame

    local LinkButton = Instance.new("TextButton")
    LinkButton.Size = UDim2.new(1, 0, 0, 30)
    LinkButton.Position = UDim2.new(0, 0, 0, 45)
    LinkButton.BackgroundTransparency = 1
    LinkButton.Text = "key in telegram: t.me/needspbc"
    LinkButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    LinkButton.TextSize = 14
    LinkButton.Font = Enum.Font.SourceSansBold
    LinkButton.Parent = KeyFrame

    LinkButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://t.me/needspbc")
            LinkButton.Text = "Link copied to clipboard!"
            task.wait(1.5)
            LinkButton.Text = "key in telegram: t.me/needspbc"
        end
    end)

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0.85, 0, 0, 40)
    KeyBox.Position = UDim2.new(0.075, 0, 0, 85)
    KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.PlaceholderText = "Enter your key here..."
    KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    KeyBox.TextSize = 14
    KeyBox.Font = Enum.Font.SourceSans
    KeyBox.ClearTextOnFocus = false
    KeyBox.Parent = KeyFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = KeyBox

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(50, 50, 60)
    boxStroke.Thickness = 1
    boxStroke.Parent = KeyBox

    local SendBtn = Instance.new("TextButton")
    SendBtn.Size = UDim2.new(0.85, 0, 0, 40)
    SendBtn.Position = UDim2.new(0.075, 0, 0, 140)
    SendBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    SendBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
    SendBtn.Text = "SEND"
    SendBtn.TextSize = 16
    SendBtn.Font = Enum.Font.GothamBold
    SendBtn.Parent = KeyFrame

    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 8)
    sendCorner.Parent = SendBtn

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 0, 185)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Parent = KeyFrame

    SendBtn.MouseButton1Click:Connect(function()
        local enteredKey = KeyBox.Text
        if validKeys[enteredKey] then
            -- Даем доступ ровно на 24 часа (86400 секунд)
            getgenv().VD_AccessExpiry = os.time() + 86400
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            StatusLabel.Text = "Success! 24h Access Granted."
            task.wait(0.8)
            KeyGui:Destroy()
            startMainCheat()
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            StatusLabel.Text = "Invalid key! Get it in Telegram."
        end
    end)
end
