-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Added for Gun logic

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- == FLUENT LIBRARY SETUP ==
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Derfy Hub [ MM2 ]",
    SubTitle = "Created by devthederon",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Options = Fluent.Options

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Add Managers to Settings Tab
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("DerfyHub")
SaveManager:SetFolder("DerfyHub/MM2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- ===========================
-- == FUNCTIONS & LOGIC ==
-- ===========================

-- Helper to check tools
local function hasTool(player, toolName)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if char and char:FindFirstChild(toolName) then return true end
    if backpack and backpack:FindFirstChild(toolName) then return true end
    return false
end

-- Get Gun
local function grabGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local gun = Workspace:FindFirstChild("GunDrop", true)
        if gun then
            if firetouchinterest then
                firetouchinterest(root, gun, 0)
                firetouchinterest(root, gun, 1)
            else
                root.CFrame = gun.CFrame
            end
        end
    end
end

-- Fling Target
local function FlingTarget(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if hasTool(TargetPlayer, "Gun") and RootPart and TRootPart then
        if firetouchinterest then
            firetouchinterest(RootPart, TRootPart, 0)
            firetouchinterest(RootPart, TRootPart, 1)
        end
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end

        if THumanoid and THumanoid.Sit then
            return Fluent:Notify({ Title = "Error", Content = TargetPlayer.Name .. " is sitting", Duration = 3 })
        end

        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)) task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)) task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not getgenv().FlingActive
        end

        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart BV.Velocity = Vector3.new(0, 0, 0) BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle)
        else return Fluent:Notify({ Title = "Error", Content = "No valid parts", Duration = 3 }) end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    else
        return Fluent:Notify({ Title = "Error", Content = "Character not ready", Duration = 3 })
    end
end

-- Fling All
local function FlingAll()
    Fluent:Notify({ Title = "Flinging All", Content = "Flinging everyone...", Duration = 5 })
    
    task.spawn(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                -- Added a small wait to prevent freezing
                task.wait(0.5) 
                if getgenv().FlingActive == false then
                    getgenv().FlingActive = true
                    FlingTarget(player)
                    getgenv().FlingActive = false
                end
            end
        end
        Fluent:Notify({ Title = "Done", Content = "Flinging Finished", Duration = 3 })
    end)
end

-- Kill All (Teleport method)
local function KillAll()
    Fluent:Notify({ Title = "Killing All", Content = "Killing everyone...", Duration = 5 })
    
    task.spawn(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                -- Wait to reduce lag
                task.wait(0.5) 
                
                if RootPart and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport to them
                    RootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    -- Teleport them up high
                    player.Character:MoveTo(Vector3.new(0, 5000, 0))
                    -- Wait a second to ensure they fall
                    task.wait(0.1)
                end
            end
        end
        Fluent:Notify({ Title = "Done", Content = "Killing Finished", Duration = 3 })
    end)
end

local function getRolePlayer(roleName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if roleName == "Murderer" and hasTool(player, "Knife") then return player end
            if roleName == "Sheriff" and hasTool(player, "Gun") then return player end
        end
    end
    return nil
end

-- ===========================
-- == NEW GUN LOGIC (From Source) ==
-- ===========================

local function getMurdererTarget()
    local dataObj = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not dataObj then return nil, false end
    
    local success, data = pcall(function() return dataObj:InvokeServer() end)
    if not success or not data then return nil, false end

    for plr, plrData in pairs(data) do
        if plrData.Role == "Murderer" then
            local player = Players:FindFirstChild(plr)
            if player then
                if player == LocalPlayer then return nil, true end
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp.Position, false end
                    local head = char:FindFirstChild("Head")
                    if head then return head.Position, false end
                end
            end
        end
    end
    return nil, false
end

local ShootButtonGui = nil
local AimbotConnection = nil

-- Shoot Murder Button Logic
local function toggleShootButton(enabled)
    if ShootButtonGui then
        ShootButtonGui:Destroy()
        ShootButtonGui = nil
    end

    if enabled then
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "DerfyShootGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = CoreGui

        local TextButton = Instance.new("TextButton")
        TextButton.Name = "ShootBtn"
        TextButton.Size = UDim2.new(0, 150, 0, 40)
        TextButton.Position = UDim2.new(0.5, -75, 0.5, 0)
        TextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        TextButton.Font = Enum.Font.FredokaOne
        TextButton.Text = "SHOOT MURDERER"
        TextButton.TextSize = 16
        TextButton.Draggable = true
        TextButton.Active = true
        TextButton.Parent = ScreenGui
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.new(1,1,1)
        Stroke.Parent = TextButton
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = TextButton

        TextButton.MouseButton1Click:Connect(function()
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Gun") then
                local targetPos, isSelf = getMurdererTarget()
                if targetPos and not isSelf then
                    local gunScript = Char.Gun:FindFirstChild("KnifeLocal")
                    if gunScript then
                        local createBeam = gunScript:FindFirstChild("CreateBeam")
                        if createBeam then
                            local remote = createBeam:FindFirstChild("RemoteFunction")
                            if remote then
                                pcall(function() remote:InvokeServer(1, targetPos, "AH2") end)
                            end
                        end
                    end
                else
                    Fluent:Notify({ Title = "Error", Content = "Murderer not found", Duration = 2 })
                end
            else
                Fluent:Notify({ Title = "Error", Content = "You need the Gun!", Duration = 2 })
            end
        end)
        
        ShootButtonGui = ScreenGui
    end
end

-- Gun Aimbot Logic
local function toggleGunAimbot(enabled)
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end

    if enabled then
        AimbotConnection = RunService.Heartbeat:Connect(function()
            local Char = LocalPlayer.Character
            if Char then
                local Gun = Char:FindFirstChild("Gun")
                if Gun then
                    local gunScript = Gun:FindFirstChild("KnifeLocal")
                    if gunScript then
                        -- Check if user is clicking (Mouse1)
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            local targetPos, isSelf = getMurdererTarget()
                            if targetPos and not isSelf then
                                local createBeam = gunScript:FindFirstChild("CreateBeam")
                                if createBeam then
                                    local remote = createBeam:FindFirstChild("RemoteFunction")
                                    if remote then
                                        -- Basic cooldown check to prevent spamming too hard
                                        if not getgenv().LastShot or tick() - getgenv().LastShot > 0.5 then
                                            pcall(function() remote:InvokeServer(1, targetPos, "AH2") end)
                                            getgenv().LastShot = tick()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ===========================
-- == FIXED INVISIBLE LOGIC (With Head Text) ==
-- ===========================

local invisOn = false
local ghostSpeedEnforced = false
local ghostSpeedValue = 16
local ghostConnection = nil
local InvisBillboard = nil

local function setTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = val
        end
    end
end

local function toggleInvis()
    invisOn = not invisOn
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if char and hrp then
        if invisOn then
            -- 1. Add Text above head
            if head then
                InvisBillboard = Instance.new("BillboardGui")
                InvisBillboard.Name = "DerfyInvisText"
                InvisBillboard.Adornee = head
                InvisBillboard.Size = UDim2.new(0, 100, 0, 50)
                InvisBillboard.StudsOffset = Vector3.new(0, 3, 0)
                InvisBillboard.AlwaysOnTop = true
                InvisBillboard.Parent = head
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextStrokeTransparency = 0
                text.Text = "Invisible 👻"
                text.TextSize = 18
                text.Font = Enum.Font.FredokaOne
                text.Parent = InvisBillboard
            end

            -- 2. Save Position
            local savedpos = hrp.CFrame
            
            -- 3. Set Transparency
            setTransparency(char, 1) -- Fully invisible
            
            -- 4. Teleport to Void
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            
            -- 5. Create Seat and Weld
            local Seat = Instance.new("Seat", Workspace)
            Seat.Anchored = false
            Seat.CanCollide = false
            Seat.Name = "DerfyInvisSeat"
            Seat.Transparency = 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            
            local Torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if Torso then
                local Weld = Instance.new("Weld", Seat)
                Weld.Part0 = Seat
                Weld.Part1 = Torso
            end
            
            Seat.CFrame = savedpos
            
            Fluent:Notify({ Title = "Invisible", Content = "Enabled (Press Z)", Duration = 5 })
        else
            -- Disable Invis
            setTransparency(char, 0) -- Visible
            
            -- Remove Text
            if InvisBillboard then
                InvisBillboard:Destroy()
                InvisBillboard = nil
            end
            
            local seat = Workspace:FindFirstChild("DerfyInvisSeat")
            if seat then seat:Destroy() end
            Fluent:Notify({ Title = "Visible", Content = "Invisibility Disabled", Duration = 3 })
        end
    end
end

local function toggleGhostSpeed()
    ghostSpeedEnforced = not ghostSpeedEnforced
    if ghostSpeedEnforced then
        Fluent:Notify({ Title = "Ghost Speed", Content = "Locked at " .. ghostSpeedValue, Duration = 3 })
        if ghostConnection then ghostConnection:Disconnect() end
        ghostConnection = RunService.Stepped:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = ghostSpeedValue end
        end)
    else
        if ghostConnection then ghostConnection:Disconnect() ghostConnection = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        Fluent:Notify({ Title = "Ghost Speed", Content = "Unlocked", Duration = 3 })
    end
end

-- ===========================
-- == MAIN TAB ELEMENTS ==
-- ===========================

Tabs.Main:AddSection("Info")
Tabs.Main:AddParagraph({
    Title = "Derfy Hub",
    Content = "Created by devthederon"
})

Tabs.Main:AddSection("Gun & Fling")

Tabs.Main:AddButton({
    Title = "Get Gun",
    Description = "Pick up the gun",
    Callback = function()
        grabGun()
    end
})

Tabs.Main:AddToggle("AutoGun", {
    Title = "Auto Get Gun",
    Default = false,
    Callback = function(Value)
        getgenv().AutoGetGun = Value
        if getgenv().AutoGetGun then
            task.spawn(function()
                while getgenv().AutoGetGun do
                    grabGun()
                    task.wait(0.5)
                end
            end)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Steal Gun",
    Description = "Steal gun from Sheriff/Hero",
    Callback = function()
        local Char = LocalPlayer.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        
        if Char and Hum and Backpack then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    if p.Character and p.Character:FindFirstChild("Gun") then
                        p.Character.Gun.Parent = Char
                        Hum:EquipTool(Char:FindFirstChild("Gun"))
                        Hum:UnequipTools()
                    elseif p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
                        p.Backpack.Gun.Parent = Backpack
                        Hum:EquipTool(Backpack:FindFirstChild("Gun"))
                        Hum:UnequipTools()
                    end
                end
            end
            Fluent:Notify({ Title = "Gun Stealer", Content = "Attempted to steal gun", Duration = 2 })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Fling Murderer",
    Description = "Fling the Murderer",
    Callback = function()
        local target = getRolePlayer("Murderer")
        if target then
            getgenv().FlingActive = true
            Fluent:Notify({ Title = "Flinging", Content = "Flinging " .. target.Name, Duration = 5 })
            FlingTarget(target)
            getgenv().FlingActive = false
            Fluent:Notify({ Title = "Done", Content = "Fling Finished", Duration = 2 })
        else
            Fluent:Notify({ Title = "Error", Content = "No Murderer Found", Duration = 3 })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Fling Sheriff",
    Description = "Fling the Sheriff",
    Callback = function()
        local target = getRolePlayer("Sheriff")
        if target then
            getgenv().FlingActive = true
            Fluent:Notify({ Title = "Flinging", Content = "Flinging " .. target.Name, Duration = 5 })
            FlingTarget(target)
            getgenv().FlingActive = false
            Fluent:Notify({ Title = "Done", Content = "Fling Finished", Duration = 2 })
        else
            Fluent:Notify({ Title = "Error", Content = "No Sheriff Found", Duration = 3 })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Fling All",
    Description = "Fling everyone in the server",
    Callback = function()
        FlingAll()
    end
})

-- NEW GUN FEATURES SECTION
Tabs.Main:AddSection("Shoot Murderer")

Tabs.Main:AddToggle("MurderAimbot", {
    Title = "Gun Aimbot (Click to Shoot)",
    Description = "Aims and shoots at Murderer automatically when you click",
    Default = false,
    Callback = function(Value)
        toggleGunAimbot(Value)
    end
})

Tabs.Main:AddToggle("MurderButton", {
    Title = "Shoot Murderer Button",
    Description = "Creates a draggable button to shoot the murderer",
    Default = false,
    Callback = function(Value)
        toggleShootButton(Value)
    end
})

Tabs.Main:AddSection("Kill All")

Tabs.Main:AddButton({
    Title = "Kill All",
    Description = "Kill everyone in the server",
    Callback = function()
        KillAll()
    end
})

Tabs.Main:AddSection("Keybinds")
Tabs.Main:AddParagraph({
    Title = "Controls",
    Content = "Press [G] to Get Gun\nPress [Z] to Toggle Invisible"
})

-- ===========================
-- == PLAYER TAB ELEMENTS ==
-- ===========================

Tabs.Player:AddSection("Movement")

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Description = "Set your walking speed",
    Default = 16,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        getgenv().SpeedValue = Value
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid then Humanoid.WalkSpeed = Value end
    end
})

Tabs.Player:AddToggle("KeepSpeed", {
    Title = "Keep Speed Set",
    Default = false,
    Callback = function(Value)
        getgenv().KeepSpeed = Value
        if getgenv().KeepSpeed then
            task.spawn(function()
                while getgenv().KeepSpeed do
                    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if Humanoid and getgenv().SpeedValue then Humanoid.WalkSpeed = getgenv().SpeedValue end
                    task.wait()
                end
            end)
        end
    end
})

Tabs.Player:AddSection("Ghost / Invis")

Tabs.Player:AddToggle("GhostSpeed", {
    Title = "Ghost Speed Lock",
    Default = false,
    Callback = function(Value)
        toggleGhostSpeed()
    end
})

Tabs.Player:AddSlider("GhostValue", {
    Title = "Ghost Speed Value",
    Description = "Speed value for Ghost Mode",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        ghostSpeedValue = Value
        if ghostSpeedEnforced then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = ghostSpeedValue end
        end
    end
})

Tabs.Player:AddButton({
    Title = "Toggle Invisible (Z)",
    Description = "Turn Invisible",
    Callback = function() toggleInvis() end
})

Tabs.Player:AddSection("Other")

Tabs.Player:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
        if getgenv().NoclipEnabled then
            task.spawn(function()
                while getgenv().NoclipEnabled do
                    local Character = LocalPlayer.Character
                    if Character then
                        for _, v in pairs(Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                    task.wait()
                end
            end)
        else
            local Character = LocalPlayer.Character
            if Character then
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end
    end
})

Tabs.Player:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        getgenv().FlyEnabled = Value
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if getgenv().FlyEnabled then
            if not root then return end
            if getgenv().FlyBV then getgenv().FlyBV:Destroy() end
            if getgenv().FlyBG then getgenv().FlyBG:Destroy() end

            local FlyBV = Instance.new("BodyVelocity")
            local FlyBG = Instance.new("BodyGyro")
            FlyBV.Parent = root FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge) FlyBV.Velocity = Vector3.new(0,0,0)
            FlyBG.Parent = root FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) FlyBG.P = 10000 FlyBG.CFrame = root.CFrame
            getgenv().FlyBV = FlyBV getgenv().FlyBG = FlyBG

            task.spawn(function()
                while getgenv().FlyEnabled do
                    local speed = 5 local newPos = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then newPos = newPos + Workspace.CurrentCamera.CFrame.LookVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then newPos = newPos - Workspace.CurrentCamera.CFrame.LookVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then newPos = newPos - Workspace.CurrentCamera.CFrame.RightVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then newPos = newPos + Workspace.CurrentCamera.CFrame.RightVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then newPos = newPos + Vector3.new(0, speed, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then newPos = newPos - Vector3.new(0, speed, 0) end
                    FlyBV.Velocity = newPos FlyBG.CFrame = Workspace.CurrentCamera.CFrame task.wait()
                end
            end)
        else
            if getgenv().FlyBV then getgenv().FlyBV:Destroy() getgenv().FlyBV = nil end
            if getgenv().FlyBG then getgenv().FlyBG:Destroy() getgenv().FlyBG = nil end
        end
    end
})

-- ===========================
-- == TELEPORT TAB ELEMENTS ==
-- ===========================

Tabs.Teleport:AddButton({
    Title = "Teleport to Map",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local coins = Workspace:FindFirstChild("CoinContainer", true)
        if coins then
            local targetObj = coins.Parent
            local part = targetObj:IsA("BasePart") and targetObj or targetObj:FindFirstChildWhichIsA("BasePart")
            if part then hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0) end
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Lobby",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local targetObj = Workspace:FindFirstChild("Lobby", true)
        if not targetObj then targetObj = Workspace:FindFirstChild("Spawns", true) end
        if targetObj then
            local part = targetObj:IsA("BasePart") and targetObj or targetObj:FindFirstChildWhichIsA("BasePart")
            if part then hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0) end
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Sheriff",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and hasTool(player, "Gun") then
                hrp.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        Fluent:Notify({ Title = "Teleport Failed", Content = "No Sheriff found", Duration = 3 })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Murderer",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and hasTool(player, "Knife") then
                hrp.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        Fluent:Notify({ Title = "Teleport Failed", Content = "No Murderer found", Duration = 3 })
    end
})

-- ===========================
-- == VISUAL TAB ELEMENTS ==
-- ===========================

local function GetPlayerColor(Player)
    if hasTool(Player, "Knife") then return Color3.fromRGB(255, 0, 0)
    elseif hasTool(Player, "Gun") then return Color3.fromRGB(0, 0, 255)
    else return Color3.fromRGB(0, 255, 0) end
end

Tabs.Visual:AddToggle("EspRoles", {
    Title = "ESP Roles",
    Default = false,
    Callback = function(Value)
        getgenv().EspRolesEnabled = Value
        local function ClearEsp()
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local hl = player.Character:FindFirstChild("DerfyHighlight")
                    if hl then hl:Destroy() end
                    local head = player.Character:FindFirstChild("Head")
                    if head then 
                        local bdg = head:FindFirstChild("NameEsp")
                        if bdg then bdg:Destroy() end
                    end
                end
            end
        end

        if getgenv().EspRolesEnabled then
            task.spawn(function()
                while getgenv().EspRolesEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                            local color = GetPlayerColor(player)
                            local head = player.Character.Head
                            if not player.Character:FindFirstChild("DerfyHighlight") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "DerfyHighlight" hl.Adornee = player.Character
                                hl.FillColor = color hl.OutlineColor = color
                                hl.FillTransparency = 0.5 hl.OutlineTransparency = 0 hl.Parent = player.Character
                            else
                                player.Character.DerfyHighlight.FillColor = color
                                player.Character.DerfyHighlight.OutlineColor = color
                            end
                            if not head:FindFirstChild("NameEsp") then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "NameEsp" billboard.Adornee = head
                                billboard.Size = UDim2.new(0, 100, 0, 50)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.AlwaysOnTop = true billboard.Parent = head
                                local text = Instance.new("TextLabel")
                                text.Size = UDim2.new(1, 0, 1, 0) text.BackgroundTransparency = 1
                                text.TextColor3 = color text.TextStrokeTransparency = 0
                                text.Text = player.Name text.TextSize = 14
                                text.Font = Enum.Font.FredokaOne text.Parent = billboard
                            else
                                head.NameEsp.TextLabel.TextColor3 = color
                                head.NameEsp.TextLabel.Text = player.Name
                            end
                        end
                    end
                    task.wait(0.1)
                end
                ClearEsp()
            end)
        else
            ClearEsp()
        end
    end
})

Tabs.Visual:AddToggle("EspGun", {
    Title = "ESP Gun",
    Default = false,
    Callback = function(Value)
        getgenv().EspGunEnabled = Value
        local function ClearGunEsp()
            local gun = Workspace:FindFirstChild("GunDrop", true)
            if gun then
                local hl = gun:FindFirstChild("DerfyGunHL")
                if hl then hl:Destroy() end
                local bdg = gun:FindFirstChild("DerfyGunBd")
                if bdg then bdg:Destroy() end
            end
        end

        if getgenv().EspGunEnabled then
            task.spawn(function()
                while getgenv().EspGunEnabled do
                    local gun = Workspace:FindFirstChild("GunDrop", true)
                    if gun then
                        if not gun:FindFirstChild("DerfyGunHL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "DerfyGunHL" hl.Adornee = gun
                            hl.FillColor = Color3.new(1, 1, 0)
                            hl.OutlineColor = Color3.new(1, 1, 1) hl.Parent = gun
                        end
                        if not gun:FindFirstChild("DerfyGunBd") then
                            local bdg = Instance.new("BillboardGui")
                            bdg.Name = "DerfyGunBd" bdg.Adornee = gun
                            bdg.Size = UDim2.new(0, 100, 0, 50)
                            bdg.AlwaysOnTop = true bdg.Parent = gun
                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1, 0, 1, 0) text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.new(1, 1, 0) text.TextStrokeTransparency = 0
                            text.Text = "GUN" text.TextSize = 18
                            text.Font = Enum.Font.FredokaOne text.Parent = bdg
                        end
                    else
                        ClearGunEsp()
                    end
                    task.wait(0.1)
                end
                ClearGunEsp()
            end)
        else
            ClearGunEsp()
        end
    end
})

-- ===========================
-- == SETTINGS TAB ELEMENTS ==
-- ===========================

Tabs.Settings:AddKeybind("MenuKeybind", {
    Title = "Toggle UI",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function(Value)
        Fluent:Toggle()
    end
})

Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Description = "Unloads the script",
    Callback = function()
        Fluent:Destroy()
    end
})

-- ===========================
-- == GLOBAL KEYBINDS ==
-- ===========================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- G to Get Gun
    if input.KeyCode == Enum.KeyCode.G then
        grabGun()
    end
    
    -- Z to Toggle Invisible
    if input.KeyCode == Enum.KeyCode.Z then
        toggleInvis()
    end
end)

-- ===========================
-- == INITIALIZATION ==
-- ===========================

Fluent:Notify({
    Title = "Derfy Hub",
    Content = "Script Loaded. Created by devthederon",
    Duration = 5
})

-- Load Configs
SaveManager:LoadAutoloadConfig()
