-- Astral Hub / Hitbox Expander (Return to Position Version)
-- Grabs players, holds them in front of you for 3 seconds, then returns them to original position.

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Astral Hub v3",
    SubTitle = "Hitbox Expander",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Hitbox", Icon = "user-plus" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local HitboxPart = nil
local isHitboxActive = false

-- Loop Logic
task.spawn(function()
    while true do
        task.wait() -- Run every frame

        if Fluent.Unloaded then break end

        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if isHitboxActive and Root then
            -- 1. Create or Update Hitbox Visual
            if not HitboxPart or not HitboxPart.Parent then
                HitboxPart = Instance.new("Part")
                HitboxPart.Name = "AstralHitbox"
                HitboxPart.Transparency = 0.8
                HitboxPart.Color = Color3.fromRGB(255, 0, 0)
                HitboxPart.Anchored = true
                HitboxPart.CanCollide = false
                HitboxPart.Material = Enum.Material.Neon
                HitboxPart.Parent = workspace
            end

            local size = Options.HitboxSize.Value
            HitboxPart.Size = Vector3.new(size, size, size)
            HitboxPart.Position = Root.Position

            -- 2. Scan Players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local targetChar = player.Character
                    if targetChar then
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = targetChar:FindFirstChild("Humanoid")

                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                            -- Check if player is INSIDE the hitbox
                            local distance = (targetRoot.Position - Root.Position).Magnitude
                            if distance <= (size / 2) then
                                
                                -- Check if we are NOT already holding them
                                if not targetChar:GetAttribute("IsBeingAstraled") then
                                    -- Mark them as being held
                                    targetChar:SetAttribute("IsBeingAstraled", true)

                                    -- Save their original position
                                    local originalPosition = targetRoot.CFrame

                                    -- Attempt to set network ownership (makes teleporting smoother)
                                    pcall(function()
                                        targetRoot:SetNetworkOwner(LocalPlayer)
                                    end)

                                    -- Notify (Once)
                                    Fluent:Notify({
                                        Title = "Hitbox Active",
                                        Content = "Caught " .. player.Name,
                                        Duration = 2
                                    })

                                    -- Start the 0.55 Second Hold Logic
                                    task.spawn(function()
                                        local holdTime = 0
                                        while task.wait() do
                                            holdTime = holdTime + RunService.Heartbeat:Wait()
                                            
                                            -- Release after 0.55 seconds OR if they die OR if script turns off
                                            if holdTime >= 0.55 or targetHumanoid.Health <= 0 or not isHitboxActive then
                                                -- Return them to original position
                                                if targetRoot and targetHumanoid.Health > 0 then
                                                    targetRoot.CFrame = originalPosition
                                                    
                                                    Fluent:Notify({
                                                        Title = "Released",
                                                        Content = player.Name .. " returned to position",
                                                        Duration = 2
                                                    })
                                                end
                                                
                                                targetChar:SetAttribute("IsBeingAstraled", false)
                                                break
                                            end

                                            -- Force Position (Very close to you)
                                            if Root and targetRoot then
                                                -- Position them 2 studs directly in front of you (very close)
                                                targetRoot.CFrame = Root.CFrame * CFrame.new(0, 0, -2)
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        else
            -- Cleanup if disabled
            if HitboxPart then
                HitboxPart:Destroy()
                HitboxPart = nil
            end
        end
    end
end)

-- UI Setup
do
    Tabs.Main:AddToggle("HitboxEnabled", {Title = "Enable Hitbox", Default = false })
        :OnChanged(function(Value)
            isHitboxActive = Value
            if isHitboxActive then
                Fluent:Notify({ Title = "System", Content = "Hitbox Enabled", Duration = 2 })
            end
        end)

    Tabs.Main:AddSlider("HitboxSize", {
        Title = "Hitbox Size",
        Description = "Radius of the grab area",
        Default = 20,
        Min = 5,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            -- Visual update handled in loop
        end
    })

    Tabs.Main:AddParagraph({
        Title = "Info",
        Content = "When a player touches the red box, they will be brought in front of you for 0.55 seconds, then returned to their original position."
    })
end

-- Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("AstralHub")
SaveManager:SetFolder("AstralHub/config")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Astral Hub",
    Content = "Script Loaded.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
