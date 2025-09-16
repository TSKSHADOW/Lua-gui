-- OldLuaGUI v5 (Полный обновлённый скрипт)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "OldLuaGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 550)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 1
title.BorderColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Lua Team GUI v5"
title.Font = Enum.Font.Legacy
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local btnHolder = Instance.new("Frame")
btnHolder.Position = UDim2.new(0, 0, 0, 25)
btnHolder.Size = UDim2.new(1, 0, 1, -25)
btnHolder.BackgroundTransparency = 1
btnHolder.Parent = frame

-- States and vars
local states = {}
local yPos = 10
local speedValue, jumpValue = 100, 200

local function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    yPos += 35
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.Legacy
    btn.TextSize = 14
    btn.Parent = btnHolder

    states[name:lower()] = false
    btn.MouseButton1Click:Connect(function()
        local state = not states[name:lower()]
        states[name:lower()] = state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function safeDisconnect(conn)
    if conn then pcall(function() conn:Disconnect() end) end
end

-- FLY
local flyConn, bv, bg
createButton("Fly", function(state)
    if state then
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 1e9
        bv.Velocity = Vector3.new()
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 1e9

        flyConn = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local vel = Vector3.new()
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
        safeDisconnect(flyConn)
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
end)

-- NOCLIP
local noclipConn
createButton("Noclip", function(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        safeDisconnect(noclipConn)
    end
end)

-- SPIN
local spinConn
createButton("Spin", function(state)
    if state then
        spinConn = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(10), 0)
                -- Голова вниз (голова и шея)
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local neck = torso and torso:FindFirstChild("Neck")
                if neck then
                    neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-60), 0, 0)
                end
            end
        end)
    else
        safeDisconnect(spinConn)
        -- Восстановить шею
        local char = player.Character
        if char then
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            local neck = torso and torso:FindFirstChild("Neck")
            if neck then
                neck.C0 = CFrame.new(0, 1, 0)
            end
        end
    end
end)

-- T-POSE (R6)
local tposeConn, originalC0 = nil, {}
createButton("T-Pose", function(state)
    local char = player.Character or player.CharacterAdded:Wait()
    if state then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.RigType == Enum.HumanoidRigType.R6 then
            local ls = char:FindFirstChild("Left Shoulder", true)
            local rs = char:FindFirstChild("Right Shoulder", true)
            if ls and rs then
                originalC0.ls = ls.C0
                originalC0.rs = rs.C0
                tposeConn = RunService.Heartbeat:Connect(function()
                    ls.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(-90))
                    rs.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
                end)
            end
        end
    else
        safeDisconnect(tposeConn)
        local ls = char:FindFirstChild("Left Shoulder", true)
        local rs = char:FindFirstChild("Right Shoulder", true)
        if ls and rs and originalC0.ls and originalC0.rs then
            ls.C0 = originalC0.ls
            rs.C0 = originalC0.rs
        end
    end
end)

-- GODMODE
local godConn
local function setupGod(char)
    local hum = char:WaitForChild("Humanoid")
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    godConn = hum.HealthChanged:Connect(function()
        if states.godmode then hum.Health = hum.MaxHealth end
    end)
end
createButton("Godmode", function(state)
    if state then
        setupGod(player.Character or player.CharacterAdded:Wait())
        player.CharacterAdded:Connect(setupGod)
    else
        safeDisconnect(godConn)
    end
end)

-- ESP
local espConns, playerAddedConn = {}, nil
local function colorForPlayer(plr)
    if plr == player then return Color3.fromRGB(0, 200, 0) end
    if player.Team and plr.Team and plr.Team == player.Team then
        return Color3.fromRGB(0, 200, 0)
    end
    if plr.Team then return plr.TeamColor.Color end
    return Color3.fromRGB(255, 0, 0)
end
local function removeESP(plr)
    if plr.Character then
        local old = plr.Character:FindFirstChild("LuaESP")
        if old then old:Destroy() end
    end
    if espConns[plr] then
        for _, c in pairs(espConns[plr]) do pcall(function() c:Disconnect() end) end
        espConns[plr] = nil
    end
end
local function applyESP(plr)
    if not plr.Character then return end
    removeESP(plr)
    local hl = Instance.new("Highlight")
    hl.Name = "LuaESP"
    hl.FillTransparency = 0.5
    hl.Adornee = plr.Character
    local col = colorForPlayer(plr)
    hl.OutlineColor, hl.FillColor = col, col
    hl.Parent = plr.Character
end
createButton("ESP", function(state)
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            espConns[plr] = {}
            table.insert(espConns[plr], plr.CharacterAdded:Connect(function() if states.esp then applyESP(plr) end end))
            table.insert(espConns[plr], plr:GetPropertyChangedSignal("Team"):Connect(function() if states.esp then applyESP(plr) end end))
            if plr.Character then applyESP(plr) end
        end
        playerAddedConn = Players.PlayerAdded:Connect(function(plr)
            espConns[plr] = {}
            table.insert(espConns[plr], plr.CharacterAdded:Connect(function() if states.esp then applyESP(plr) end end))
            table.insert(espConns[plr], plr:GetPropertyChangedSignal("Team"):Connect(function() if states.esp then applyESP(plr) end end))
        end)
    else
        if playerAddedConn then playerAddedConn:Disconnect() playerAddedConn = nil end
        for plr in pairs(espConns) do removeESP(plr) end
        espConns = {}
    end
end)

-- SPEED
local function setSpeed(char, val)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = states.speed and val or 16
end
createButton("Speed", function(state)
    if player.Character then setSpeed(player.Character, speedValue) end
    player.CharacterAdded:Connect(function(char) if states.speed then setSpeed(char, speedValue) end end)
end)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, yPos)
yPos += 30
speedBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
speedBox.Text = tostring(speedValue)
speedBox.TextColor3 = Color3.fromRGB(0,0,0)
speedBox.Parent = btnHolder
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then speedValue = val if states.speed and player.Character then setSpeed(player.Character, speedValue) end end
end)

-- JUMP
local function setJump(char, val)
    local hum = char:WaitForChild("Humanoid")
    hum.UseJumpPower = true
    hum.JumpPower = states.jump and val or 50
end
createButton("Jump", function(state)
    if player.Character then setJump(player.Character, jumpValue) end
    player.CharacterAdded:Connect(function(char) if states.jump then setJump(char, jumpValue) end end)
end)
local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, -20, 0, 25)
jumpBox.Position = UDim2.new(0, 10, 0, yPos)
yPos += 30
jumpBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
jumpBox.Text = tostring(jumpValue)
jumpBox.TextColor3 = Color3.fromRGB(0,0,0)
jumpBox.Parent = btnHolder
jumpBox.FocusLost:Connect(function()
    local val = tonumber(jumpBox.Text)
    if val then jumpValue = val if states.jump and player.Character then setJump(player.Character, jumpValue) end end
end)

print("Lua Team GUI v5 loaded!")
