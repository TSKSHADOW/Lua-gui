local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- GUI (старый стиль)
local gui = Instance.new("ScreenGui")
gui.Name = "OldLuaGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Основной фрейм
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 1
title.BorderColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Lua Team GUI"
title.Font = Enum.Font.Legacy
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- Контейнер кнопок
local btnHolder = Instance.new("Frame")
btnHolder.Position = UDim2.new(0, 0, 0, 25)
btnHolder.Size = UDim2.new(1, 0, 1, -25)
btnHolder.BackgroundTransparency = 1
btnHolder.Parent = frame

-- Состояния
local states = {
    fly = false,
    noclip = false,
    spam = false,
    godmode = false,
    sky = false
}

local yPos = 10
local function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    yPos = yPos + 35
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Legacy
    btn.TextSize = 14
    btn.Parent = btnHolder

    btn.MouseButton1Click:Connect(function()
        local state = not states[name:lower()]
        states[name:lower()] = state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Fly
local flyConn
local bv, bg
createButton("Fly", function(state)
    if state then
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 1e9
        bv.Velocity = Vector3.new(0,0,0)
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 1e9
        bg.CFrame = hrp.CFrame

        flyConn = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local vel = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0,1,0) end
            bv.Velocity = vel * 100
            bg.CFrame = cam.CFrame
        end)
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end
    end
end)

-- Noclip
local noclipConn
createButton("Noclip", function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end)

-- Spam
local spamThread
createButton("Spam", function(state)
    if state then
        spamThread = coroutine.create(function()
            while states.spam do
                pcall(function()
                    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if chatEvents then
                        local sayMsg = chatEvents:FindFirstChild("SayMessageRequest")
                        if sayMsg then
                            sayMsg:FireServer("lua team best", "All")
                        end
                    end
                end)
                wait(0.5)
            end
        end)
        coroutine.resume(spamThread)
    else
        -- Остановить спам
        states.spam = false
    end
end)

-- Godmode
local godConn
local function setupGodmode(char)
    local hum = char:WaitForChild("Humanoid")
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    if godConn then godConn:Disconnect() godConn = nil end
    godConn = hum.HealthChanged:Connect(function()
        if states.godmode and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end
createButton("Godmode", function(state)
    if state then
        setupGodmode(player.Character or player.CharacterAdded:Wait())
        player.CharacterAdded:Connect(setupGodmode)
    else
        if godConn then godConn:Disconnect() godConn = nil end
    end
end)

-- Skybox
local sky
createButton("Sky", function(state)
    if state then
        sky = Instance.new("Sky")
        local id = "rbxassetid://27870569" -- твоя декалка для неба
        sky.SkyboxBk = id
        sky.SkyboxDn = id
        sky.SkyboxFt = id
        sky.SkyboxLf = id
        sky.SkyboxRt = id
        sky.SkyboxUp = id
        sky.Parent = Lighting
    else
        if sky then sky:Destroy() sky = nil end
    end
end)

print("Old-style Lua Team GUI Loaded.")
