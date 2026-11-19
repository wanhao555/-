local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")

if getgenv then
    getgenv().DELTA_VERSION_NUM = nil
    getgenv().delta = nil
    getgenv().getreg = nil
    getgenv().getsenv = nil
    getgenv().readbspval = nil
    getgenv().getbspval = nil
end

local mt = getrawmetatable(game)
local nc, ni = mt.__namecall, mt.__newindex
setreadonly(mt, false)

local mNC = newcclosure(function(self, ...)
    if checkcaller() then return nc(self, ...) end
    local m = getnamecallmethod()
    if m == "Kick" or m == "ClientKick" then return end
    if m == "Teleport" or m == "TeleportAsync" or m == "TeleportToPlaceInstance" or m == "TeleportToPrivateServer" or m == "TeleportPartyAsync" then return end
    if m == "FireClient" then
        local n = self.Name
        if n == "ServerMove" or n == "CorrectionNotice" or n == "AntiCheatNotice" or n == "Teleport" or n == "Blacklist" then return end
    end
    return nc(self, ...)
end)

local mNI = newcclosure(function(self, k, v)
    if not checkcaller() and self.Parent == lp.Character and self.Name == "HumanoidRootPart" then
        if k == "CFrame" or k == "Position" then
            local np = k == "CFrame" and v.Position or v
            if (np - self.Position).Magnitude > 25 then return end
        end
    end
    return ni(self, k, v)
end)

mt.__namecall = mNC
mt.__newindex = mNI
setreadonly(mt, true)

local function patchAc()
    local at = rs:FindFirstChild("AntiTunnel")
    if at then
        pcall(function()
            local m = require(at)
            if m then
                m.Step = function() return false end
                m.Unclip = function() return 0 end
                m.Update = function() end
                m.Track = function() return nil end
            end
        end)
    end
end
patchAc()
task.delay(5, patchAc)

for _, v in ipairs(lp.PlayerScripts:GetChildren()) do
    if v.Name == "ServerMoveClient" or v.Name == "AntiTunnelClient" or v.Name == "AntiCheatNoticeClient" or v.Name == "CorrectionNoticeClient" then
        pcall(function() v.Disabled = true end)
    end
end

local hb = task.spawn(function()
    while true do
        local ac = lp.PlayerScripts:FindFirstChild("ClientAntiCheat")
        if ac then pcall(ac.SetAttribute, ac, "t", os.clock()) end
        task.wait(1)
    end
end)

getgenv().ac_stop = function()
    pcall(task.cancel, hb)
    setreadonly(mt, false)
    if mt.__namecall == mNC then mt.__namecall = nc end
    if mt.__newindex == mNI then mt.__newindex = ni end
    setreadonly(mt, true)
    nc, ni, mNC, mNI = nil, nil, nil, nil
    getgenv().ac_stop = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer
local Camera = Workspace.CurrentCamera
local genv = getgenv()

for _, p in ipairs({"RW", "UR", "XN"}) do
    if genv[p .. "_GUI"] then pcall(genv[p .. "_GUI"].Destroy) end
    if genv[p .. "_EX"] then pcall(genv[p .. "_EX"].Unload) end
    if genv[p .. "_AIM"] then pcall(genv[p .. "_AIM"].Unload) end
    if genv[p .. "_ESP"] then pcall(genv[p .. "_ESP"].Unload) end
end
if genv.RW_MX then pcall(genv.RW_MX.Unload) end

local ESP, AIM, EX, MX
local UILib
local unloadAll

-- ==================== ESP模块 ====================
do
    local Config = {
        Enabled = false,
        TeamCheck = true,
        MaxDistance = 1500,
        Box = true,
        BoxFill = false,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = false,
        TracerOrigin = "Bottom",
        HeadDot = false,
        Skeleton = false,
        Chams = false,
        VisibleCheck = false,
        VisibleColor = Color3.fromRGB(255, 255, 255),
        HiddenColor = Color3.fromRGB(255, 40, 40),
        TeamColor = Color3.fromRGB(120, 120, 120),
        Rainbow = false,
        ToggleKey = Enum.KeyCode.RightShift,
        UnloadKey = Enum.KeyCode.End,
    }

    local R15 = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }
    local R6 = {
        {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
        {"Torso","Left Leg"},{"Torso","Right Leg"},
    }

    local function new(class, props)
        local o = Drawing.new(class)
        for k, v in pairs(props) do o[k] = v end
        return o
    end

    local pool = {}
    local connections = {}

    local function makeEntry(plr)
        local e = {
            Box = new("Square", {Thickness = 1, Filled = false, Visible = false}),
            Fill = new("Square", {Thickness = 1, Filled = true, Transparency = 0.15, Visible = false}),
            Outline = new("Square", {Thickness = 3, Filled = false, Color = Color3.new(0,0,0), Visible = false}),
            Name = new("Text", {Size = 13, Center = true, Outline = true, Font = 2, Visible = false}),
            Dist = new("Text", {Size = 12, Center = true, Outline = true, Font = 2, Visible = false}),
            HpBack = new("Line", {Thickness = 4, Color = Color3.new(0,0,0), Visible = false}),
            Hp = new("Line", {Thickness = 2, Visible = false}),
            Tracer = new("Line", {Thickness = 1, Visible = false}),
            Head = new("Circle", {Thickness = 1, NumSides = 20, Filled = false, Visible = false}),
            Bones = {},
        }
        for i = 1, 14 do e.Bones[i] = new("Line", {Thickness = 1, Visible = false}) end
        pool[plr] = e
    end

    local function hide(e)
        for k, v in pairs(e) do
            if k == "Bones" then for _, b in ipairs(v) do b.Visible = false end
            else v.Visible = false end
        end
    end

    local function destroyEntry(plr)
        local e = pool[plr]
        if not e then return end
        for k, v in pairs(e) do
            if k == "Bones" then for _, b in ipairs(v) do b:Remove() end
            else v:Remove() end
        end
        pool[plr] = nil
        local h = plr:FindFirstChild("__rw_cham")
        if h then h:Destroy() end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function isVisible(targetChar, part)
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
        local origin = Camera.CFrame.Position
        return Workspace:Raycast(origin, part.Position - origin, rayParams) == nil
    end

    local function w2s(pos)
        local v, on = Camera:WorldToViewportPoint(pos)
        return Vector2.new(v.X, v.Y), on, v.Z
    end

    local function setChams(plr, char, color)
        local h = plr:FindFirstChild("__rw_cham")
        if not Config.Chams then
            if h then h:Destroy() end
            return
        end
        if not h then
            h = Instance.new("Highlight")
            h.Name = "__rw_cham"
            h.FillTransparency = 0.6
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = plr
        end
        h.Adornee = char
        h.FillColor = color
        h.OutlineColor = color
    end

    local function step()
        Camera = Workspace.CurrentCamera
        if not Camera then return end
        local screen = Camera.ViewportSize
        local hue = (tick() % 5) / 5

        for plr, e in pairs(pool) do
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if not (Config.Enabled and char and hum and root and head and hum.Health > 0) then
                hide(e)
                local c = plr:FindFirstChild("__rw_cham")
                if c then c.Enabled = false end
                continue
            end

            local isTeam = plr.Team ~= nil and plr.Team == LocalPlayer.Team
            local friend = MX ~= nil and MX.IsFriend(plr)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if (Config.TeamCheck and (isTeam or friend) and not (friend and MX.Config.CrewShow)) or dist > Config.MaxDistance then
                hide(e)
                local c = plr:FindFirstChild("__rw_cham")
                if c then c.Enabled = false end
                continue
            end

            local color
            if friend then
                color = MX.Config.CrewColor
            elseif Config.Rainbow then
                color = Color3.fromHSV(hue, 1, 1)
            elseif isTeam then
                color = Config.TeamColor
            elseif Config.VisibleCheck then
                color = isVisible(char, head) and Config.VisibleColor or Config.HiddenColor
            else
                color = Config.HiddenColor
            end

            setChams(plr, char, color)
            local ch = plr:FindFirstChild("__rw_cham")
            if ch then ch.Enabled = true end

            local top, onTop, z1 = w2s(head.Position + Vector3.new(0, 0.6, 0))
            local bot, onBot, z2 = w2s(root.Position - Vector3.new(0, 3, 0))

            if not (onTop or onBot) or z1 < 0 or z2 < 0 then
                hide(e)
                continue
            end

            local height = math.abs(bot.Y - top.Y)
            local width = height * 0.55
            local cx = (top.X + bot.X) / 2
            local pos = Vector2.new(cx - width / 2, top.Y)
            local size = Vector2.new(width, height)

            e.Outline.Visible = Config.Box
            e.Box.Visible = Config.Box
            e.Fill.Visible = Config.Box and Config.BoxFill
            if Config.Box then
                e.Outline.Position, e.Outline.Size = pos, size
                e.Box.Position, e.Box.Size, e.Box.Color = pos, size, color
                e.Fill.Position, e.Fill.Size, e.Fill.Color = pos, size, color
            end

            e.Name.Visible = Config.Name
            if Config.Name then
                local nm = plr.DisplayName
                if friend then nm = "[队友] " .. nm end
                if MX and MX.Config.SafeFilter and MX.Config.SafeTag and MX.IsSafe(plr) then nm = nm .. " [安全]" end
                e.Name.Text = nm
                e.Name.Position = Vector2.new(cx, top.Y - 16)
                e.Name.Color = color
            end

            e.Dist.Visible = Config.Distance
            if Config.Distance then
                e.Dist.Text = string.format("[%dm]", dist)
                e.Dist.Position = Vector2.new(cx, bot.Y + 2)
                e.Dist.Color = Color3.new(1, 1, 1)
            end

            e.Hp.Visible, e.HpBack.Visible = Config.Health, Config.Health
            if Config.Health then
                local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                local x = pos.X - 5
                e.HpBack.From = Vector2.new(x, pos.Y + height + 1)
                e.HpBack.To = Vector2.new(x, pos.Y - 1)
                e.Hp.From = Vector2.new(x, pos.Y + height)
                e.Hp.To = Vector2.new(x, pos.Y + height - height * pct)
                e.Hp.Color = Color3.fromHSV(pct * 0.33, 1, 1)
            end

            e.Tracer.Visible = Config.Tracer
            if Config.Tracer then
                local o = Config.TracerOrigin
                local from =
                    o == "Center" and screen / 2 or
                    o == "Top" and Vector2.new(screen.X / 2, 0) or
                    o == "Mouse" and UIS:GetMouseLocation() or
                    Vector2.new(screen.X / 2, screen.Y)
                e.Tracer.From = from
                e.Tracer.To = Vector2.new(cx, bot.Y)
                e.Tracer.Color = color
            end

            e.Head.Visible = Config.HeadDot
            if Config.HeadDot then
                local hp = w2s(head.Position)
                e.Head.Position = hp
                e.Head.Radius = math.clamp(height * 0.09, 2, 14)
                e.Head.Color = color
            end

            local map = hum.RigType == Enum.HumanoidRigType.R15 and R15 or R6
            for i, line in ipairs(e.Bones) do
                local pair = map[i]
                local a = pair and char:FindFirstChild(pair[1])
                local b = pair and char:FindFirstChild(pair[2])
                if Config.Skeleton and a and b then
                    local pa, onA = w2s(a.Position)
                    local pb, onB = w2s(b.Position)
                    line.Visible = onA and onB
                    line.From, line.To, line.Color = pa, pb, color
                else
                    line.Visible = false
                end
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then makeEntry(p) end
    end
    table.insert(connections, Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then makeEntry(p) end
    end))
    table.insert(connections, Players.PlayerRemoving:Connect(destroyEntry))
    table.insert(connections, RunService.RenderStepped:Connect(step))

    local function Unload()
        for _, c in ipairs(connections) do c:Disconnect() end
        for plr in pairs(pool) do destroyEntry(plr) end
        if genv.RW_ESP == ESP then genv.RW_ESP = nil end
    end

    table.insert(connections, UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Config.ToggleKey then
            Config.Enabled = not Config.Enabled
        elseif i.KeyCode == Config.UnloadKey then
            Unload()
        end
    end))

    ESP = {Config = Config, Unload = Unload}
    genv.RW_ESP = ESP
end

-- ==================== 自瞄/静默瞄准/移速模块 ====================
do
    local Mouse = LP:GetMouse()

    local Config = {
        Aimbot = false,
        AimKey = "RMB",
        AimPart = "Head",
        Smoothness = 35,
        AimFOV = 160,
        ShowAimFOV = false,
        Prediction = 0,
        TargetLock = false,
        Priority = "Crosshair",
        Silent = false,
        SilentPart = "Head",
        SilentFOV = 200,
        ShowSilentFOV = false,
        HitChance = 100,
        MouseSpoof = true,
        RemoteSpoof = true,
        TeamCheck = true,
        WallCheck = true,
        MaxDistance = 2000,
        Walk = false,
        WalkSpeed = 32,
        WalkMode = "Property",
    }

    local State = {SilentPos = nil, SilentPart = nil, SilentScreen = nil, AimPart = nil, Locked = nil, Chars = {}, MyPos = nil}
    local A = {Config = Config, State = State}
    local conns = {}

    local function circle(color)
        local c = Drawing.new("Circle")
        c.Thickness, c.NumSides, c.Filled, c.Color, c.Visible = 1, 64, false, color, false
        return c
    end
    local aimCircle = circle(Color3.fromRGB(255, 45, 45))
    local silentCircle = circle(Color3.fromRGB(200, 200, 200))
    local silentDot = circle(Color3.fromRGB(255, 60, 60))
    silentDot.Filled, silentDot.Radius, silentDot.NumSides = true, 4, 12

    local KEYS = {Shift = Enum.KeyCode.LeftShift, E = Enum.KeyCode.E, Q = Enum.KeyCode.Q}
    local function held(k)
        if k == "Always" then return true end
        if k == "RMB" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
        if k == "LMB" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
        return KEYS[k] and UIS:IsKeyDown(KEYS[k]) or false
    end

    local NAMES = {
        Head = {"Head"},
        Torso = {"UpperTorso", "Torso", "HumanoidRootPart"},
        Closest = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"},
    }
    local RANDOM_POOL = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"}
    local randName, randAt = "Head", 0

    local function candidates(char, mode)
        if mode == "Random" then
            if os.clock() - randAt > 0.2 then
                randAt = os.clock()
                randName = RANDOM_POOL[math.random(#RANDOM_POOL)]
            end
            local p = char:FindFirstChild(randName) or char:FindFirstChild("HumanoidRootPart")
            return p and {p} or {}
        end
        local out = {}
        for _, n in ipairs(NAMES[mode] or NAMES.Head) do
            local p = char:FindFirstChild(n)
            if p then
                out[#out + 1] = p
                if mode ~= "Closest" then break end
            end
        end
        return out
    end

    local function aimOrigin()
        if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
            return Camera.ViewportSize / 2
        end
        return UIS:GetMouseLocation()
    end

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local function visible(char, part)
        local list = {char}
        if LP.Character then list[2] = LP.Character end
        local o = Camera.CFrame.Position
        local target = part.Position
        for _ = 1, 6 do
            rp.FilterDescendantsInstances = list
            local hit = Workspace:Raycast(o, target - o, rp)
            if not hit then return true end
            local inst = hit.Instance
            local ignorable = inst.CanCollide == false
                or inst.Transparency >= 0.95
                or inst:FindFirstAncestorOfClass("Accessory") ~= nil
                or (inst.Parent and inst.Parent:FindFirstChildOfClass("Humanoid") ~= nil)
            if not ignorable then return false end
            list[#list + 1] = inst
        end
        return false
    end

    local function pick(radius, mode)
        local mouse = aimOrigin()
        local bestPart, bestS
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p ~= LP and p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0
                and not (Config.TeamCheck and p.Team ~= nil and p.Team == LP.Team)
                and not (MX and MX.IsIgnored(p)) then
                for _, part in ipairs(candidates(char, mode)) do
                    local v, on = Camera:WorldToViewportPoint(part.Position)
                    if on and v.Z > 0 then
                        local d = (Vector2.new(v.X, v.Y) - mouse).Magnitude
                        local world = (Camera.CFrame.Position - part.Position).Magnitude
                        local score = d
                        if Config.Priority == "Lowest HP" then
                            score = hum.Health + d * 0.001
                        elseif Config.Priority == "Closest" then
                            score = world
                        end
                        if d <= radius
                            and (not bestS or score < bestS)
                            and world <= Config.MaxDistance
                            and (not Config.WallCheck or visible(char, part)) then
                            bestPart, bestS = part, score
                        end
                    end
                end
            end
        end
        return bestPart
    end

    local function aimPoint(part)
        return part.Position + part.AssemblyLinearVelocity * Config.Prediction
    end

    RunService:BindToRenderStep("RW_AIM_STEP", Enum.RenderPriority.Camera.Value + 1, function(dt)
        Camera = Workspace.CurrentCamera
        if not Camera then return end
        local mouse = aimOrigin()

        aimCircle.Visible = Config.Aimbot and Config.ShowAimFOV
        aimCircle.Position, aimCircle.Radius = mouse, Config.AimFOV
        silentCircle.Visible = Config.Silent and Config.ShowSilentFOV
        silentCircle.Position, silentCircle.Radius = mouse, Config.SilentFOV

        State.SilentPos, State.SilentPart, State.AimPart = nil, nil, nil
        local chars = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then chars[pl.Character] = true end
        end
        State.Chars = chars
        local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        State.MyPos = mr and mr.Position or nil

        if Config.Silent then
            local part = pick(Config.SilentFOV, Config.SilentPart)
            if part and math.random(1, 100) <= Config.HitChance then
                State.SilentPart, State.SilentPos = part, aimPoint(part)
            end
        end
        if State.SilentPos then
            local sv, son = Camera:WorldToViewportPoint(State.SilentPos)
            State.SilentScreen = (son and sv.Z > 0) and Vector2.new(sv.X, sv.Y) or nil
            silentDot.Visible = Config.Silent and State.SilentScreen ~= nil
            if State.SilentScreen then silentDot.Position = State.SilentScreen end
        else
            State.SilentScreen = nil
            silentDot.Visible = false
        end

        if Config.Aimbot and held(Config.AimKey) and not UIS:GetFocusedTextBox() then
            local part
            if Config.TargetLock and State.Locked then
                local lc = State.Locked.Character
                local lh = lc and lc:FindFirstChildOfClass("Humanoid")
                if lh and lh.Health > 0 then
                    part = candidates(lc, Config.AimPart)[1]
                else
                    State.Locked = nil
                end
            end
            if not part then
                part = pick(Config.AimFOV, Config.AimPart)
                if part and Config.TargetLock then
                    State.Locked = Players:GetPlayerFromCharacter(part.Parent)
                end
            end
            if part then
                State.AimPart = part
                local cf = Camera.CFrame
                local goal = CFrame.lookAt(cf.Position, aimPoint(part))
                local k = math.clamp((101 - Config.Smoothness) / 100, 0.01, 1)
                local alpha = 1 - (1 - k) ^ (dt * 60)
                Camera.CFrame = cf:Lerp(goal, alpha)
            end
        else
            State.Locked = nil
        end
    end)

    local savedWS
    local function restoreWS()
        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum and savedWS then hum.WalkSpeed = savedWS end
        savedWS = nil
    end
    table.insert(conns, LP.CharacterAdded:Connect(function() savedWS = nil end))
    table.insert(conns, RunService.Heartbeat:Connect(function(dt)
        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        if Config.Walk then
            if Config.WalkMode == "Property" then
                if not savedWS then savedWS = hum.WalkSpeed end
                if hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
            else
                if savedWS then restoreWS() end
                local md = hum.MoveDirection
                local extra = Config.WalkSpeed - hum.WalkSpeed
                if md.Magnitude > 0 and extra > 0 then
                    root.CFrame = root.CFrame + md * extra * dt
                end
            end
        elseif savedWS then
            restoreWS()
        end
    end))

    local HOOKV = 4
    local Stats = {raycast = 0, ray = 0, camera = 0, mouse = 0, loc = 0, remote = 0}
    A.Stats = Stats

    function A.StatsText()
        if not hookmetamethod then return "当前执行器不支持钩子" end
        local total = 0
        for _, v in pairs(Stats) do total = total + v end
        return string.format("重定向 %d\n射线 %d   相机 %d   鼠标 %d   位置 %d   远程 %d",
            total, Stats.raycast + Stats.ray, Stats.camera, Stats.mouse, Stats.loc, Stats.remote)
    end

    genv.RW_AIM_NC = function(old, self, m, ...)
        local a = genv.RW_AIM
        local pos = a and a.Config.Silent and a.State.SilentPos
        if pos then
            local cfg, st = a.Config, a.State
            if self == Workspace then
                if m == "Raycast" then
                    local origin, dir = ...
                    if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" and dir.Magnitude > 0 then
                        Stats.raycast += 1
                        setnamecallmethod(m)
                        return old(self, origin, (pos - origin).Unit * dir.Magnitude, select(3, ...))
                    end
                elseif m == "FindPartOnRay" or m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRayWithWhitelist" then
                    local ray = ...
                    if typeof(ray) == "Ray" and ray.Direction.Magnitude > 0 then
                        Stats.ray += 1
                        setnamecallmethod(m)
                        return old(self, Ray.new(ray.Origin, (pos - ray.Origin).Unit * ray.Direction.Magnitude), select(2, ...))
                    end
                end
            elseif cfg.MouseSpoof and (m == "ScreenPointToRay" or m == "ViewportPointToRay") and self == Camera then
                setnamecallmethod(m)
                local ray = old(self, ...)
                if typeof(ray) == "Ray" and ray.Direction.Magnitude > 0 then
                    Stats.camera += 1
                    return Ray.new(ray.Origin, (pos - ray.Origin).Unit * ray.Direction.Magnitude)
                end
                return ray
            elseif cfg.MouseSpoof and m == "GetMouseLocation" and self == UIS and st.SilentScreen then
                Stats.loc += 1
                return st.SilentScreen
            elseif cfg.RemoteSpoof and (m == "FireServer" or m == "InvokeServer") and typeof(self) == "Instance" then
                local args = table.pack(...)
                local changed = false
                local cf = Camera.CFrame
                local cp, look = cf.Position, cf.LookVector
                local me = st.MyPos or Vector3.new(1e9, 1e9, 1e9)
                for i = 1, args.n do
                    local v = args[i]
                    local tv = typeof(v)
                    if tv == "Vector3" then
                        local d = v - cp
                        if d.Magnitude > 8 and (v - me).Magnitude > 7 and look:Dot(d.Unit) > 0.96 then
                            args[i] = pos
                            changed = true
                        end
                    elseif tv == "Instance" and st.SilentPart then
                        local par, hops = v.Parent, 0
                        while par and hops < 4 do
                            if st.Chars[par] then
                                args[i] = st.SilentPart
                                changed = true
                                break
                            end
                            par = par.Parent
                            hops += 1
                        end
                    end
                end
                if changed then
                    Stats.remote += 1
                    setnamecallmethod(m)
                    return old(self, table.unpack(args, 1, args.n))
                end
            end
        end
        setnamecallmethod(m)
        return old(self, ...)
    end

    genv.RW_AIM_IDX = function(old, self, k)
        if self == Mouse then
            local a = genv.RW_AIM
            local st = a and a.Config.Silent and a.State
            if st and st.SilentPos then
                if k == "Hit" then
                    Stats.mouse += 1
                    return CFrame.new(st.SilentPos)
                elseif k == "Target" then
                    Stats.mouse += 1
                    return st.SilentPart
                elseif k == "UnitRay" and a.Config.MouseSpoof then
                    local o = Camera.CFrame.Position
                    Stats.mouse += 1
                    return Ray.new(o, (st.SilentPos - o).Unit)
                end
            end
        end
        return old(self, k)
    end

    if hookmetamethod and genv.RW_HOOK_V ~= HOOKV then
        genv.RW_HOOK_V = HOOKV
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m = getnamecallmethod()
            local a = genv.RW_AIM
            local h = genv.RW_AIM_NC
            if h and a and a.State.SilentPos and not checkcaller() then
                return h(oldNC, self, m, ...)
            end
            return oldNC(self, ...)
        end))
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, k)
            local a = genv.RW_AIM
            local h = genv.RW_AIM_IDX
            if h and a and a.State.SilentPos and not checkcaller() then
                return h(oldIdx, self, k)
            end
            return oldIdx(self, k)
        end))
    end

    function A.Unload()
        pcall(function() RunService:UnbindFromRenderStep("RW_AIM_STEP") end)
        for _, c in ipairs(conns) do c:Disconnect() end
        pcall(restoreWS)
        aimCircle:Remove()
        silentCircle:Remove()
        silentDot:Remove()
        genv.RW_AIM_NC, genv.RW_AIM_IDX = nil, nil
        if genv.RW_AIM == A then genv.RW_AIM = nil end
    end

    AIM = A
    genv.RW_AIM = A
end

-- ==================== 附加功能模块 ====================
do
    local baseFov = Workspace.CurrentCamera.FieldOfView

    local Config = {
        NoRecoil = false,
        RecoilStrength = 85,
        Skin = "Off",
        Trigger = false,
        TriggerDelay = 60,
        TriggerTeamCheck = true,
        InfJump = false,
        Noclip = false,
        Fullbright = false,
        Crosshair = false,
        CrosshairSize = 8,
        CrosshairGap = 4,
        CrosshairColor = "Red",
        CrosshairDot = true,
        FovOverride = false,
        FovValue = math.floor(baseFov + 0.5),
    }

    local X = {
        Config = Config,
        SkinList = {"Off", "Neon Red", "Gold", "Ice", "Galaxy", "Void", "Rainbow"},
        CrossList = {"Red", "White", "Cyan", "Green", "Yellow"},
        BaseFov = baseFov,
    }
    local conns = {}
    local function track(c) conns[#conns + 1] = c return c end

    local SKINS = {
        ["Neon Red"] = {Color3.fromRGB(255, 30, 30), Enum.Material.Neon, 0},
        ["Gold"]     = {Color3.fromRGB(255, 200, 60), Enum.Material.Metal, 0.35},
        ["Ice"]      = {Color3.fromRGB(150, 230, 255), Enum.Material.Glass, 0.2},
        ["Galaxy"]   = {Color3.fromRGB(120, 40, 255), Enum.Material.ForceField, 0},
        ["Void"]     = {Color3.fromRGB(8, 8, 8), Enum.Material.SmoothPlastic, 0.6},
    }
    local SKIP = {"arm$", "^arm", "hand$", "glove", "sleeve", "finger", "shirt"}
    local function skippable(name)
        name = name:lower()
        for _, pat in ipairs(SKIP) do
            if name:find(pat) then return true end
        end
        return false
    end

    local function gather()
        local out = {}
        local function scan(root)
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("BasePart") and not skippable(d.Name) then out[#out + 1] = d end
            end
        end
        local ch = LP.Character
        if ch then
            for _, t in ipairs(ch:GetChildren()) do
                if t:IsA("Tool") then scan(t) end
            end
        end
        local cam = Workspace.CurrentCamera
        if cam then
            for _, c in ipairs(cam:GetChildren()) do
                if c:IsA("Model") and not c:FindFirstChildOfClass("Humanoid") then scan(c) end
            end
        end
        return out
    end

    local orig, stash = {}, {}
    local function remember(p)
        if orig[p] then return end
        orig[p] = {
            Color = p.Color, Material = p.Material, Reflectance = p.Reflectance,
            Tex = p:IsA("MeshPart") and p.TextureID or nil,
        }
    end
    local function restoreSkins()
        for p, o in pairs(orig) do
            if p.Parent then
                p.Color, p.Material, p.Reflectance = o.Color, o.Material, o.Reflectance
                if o.Tex ~= nil then pcall(function() p.TextureID = o.Tex end) end
            end
        end
        for sa, par in pairs(stash) do
            if par.Parent then sa.Parent = par end
        end
        orig, stash = {}, {}
    end

    local fbOrig
    local function restoreLight()
        if not fbOrig then return end
        for k, v in pairs(fbOrig) do pcall(function() Lighting[k] = v end) end
        fbOrig = nil
    end

    local noclipped = {}
    local function restoreNoclip()
        for p in pairs(noclipped) do
            if p.Parent then p.CanCollide = true end
        end
        noclipped = {}
    end

    local CROSS = {
        Red = Color3.fromRGB(255, 45, 45), White = Color3.new(1, 1, 1),
        Cyan = Color3.fromRGB(0, 225, 255), Green = Color3.fromRGB(60, 255, 90),
        Yellow = Color3.fromRGB(255, 230, 60),
    }
    local cross = {}
    for i = 1, 4 do
        cross[i] = Drawing.new("Line")
        cross[i].Thickness, cross[i].Visible = 1.5, false
    end
    local dot = Drawing.new("Circle")
    dot.Filled, dot.Radius, dot.NumSides, dot.Visible = true, 1.5, 12, false
    local DIRS = {Vector2.new(0, -1), Vector2.new(0, 1), Vector2.new(-1, 0), Vector2.new(1, 0)}

    local lastPitch, userY, fovWas = nil, 0, false
    track(UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then userY += i.Delta.Y end
    end))

    RunService:BindToRenderStep("RW_EX_STEP", Enum.RenderPriority.Camera.Value + 3, function()
        Camera = Workspace.CurrentCamera
        local cam = Camera
        if not cam then return end

        if Config.FovOverride then
            cam.FieldOfView = Config.FovValue
            fovWas = true
        elseif fovWas then
            cam.FieldOfView = baseFov
            fovWas = false
        end

        local pitch = math.asin(math.clamp(cam.CFrame.LookVector.Y, -1, 1))
        if Config.NoRecoil and lastPitch and AIM.State.AimPart == nil
            and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local d = pitch - lastPitch
            if d > 0.0004 and userY > -1 then
                local comp = d * (Config.RecoilStrength / 100)
                cam.CFrame = cam.CFrame * CFrame.Angles(-comp, 0, 0)
                pitch -= comp
            end
        end
        lastPitch, userY = pitch, 0

        local on = Config.Crosshair
        local col = CROSS[Config.CrosshairColor] or CROSS.Red
        local c = cam.ViewportSize / 2
        local s, g = Config.CrosshairSize, Config.CrosshairGap
        for i, d in ipairs(DIRS) do
            local l = cross[i]
            l.Visible, l.Color = on, col
            l.From, l.To = c + d * g, c + d * (g + s)
        end
        dot.Visible = on and Config.CrosshairDot
        dot.Position, dot.Color = c, col
    end)

    local lastScan, lastShot = 0, 0
    local trigParams = RaycastParams.new()
    trigParams.FilterType = Enum.RaycastFilterType.Exclude

    track(RunService.Heartbeat:Connect(function()
        local now = os.clock()

        if Config.Skin == "Off" then
            if next(orig) or next(stash) then restoreSkins() end
        else
            if Config.Skin == "Rainbow" then
                local col = Color3.fromHSV((now % 4) / 4, 1, 1)
                for p in pairs(orig) do
                    if p.Parent then p.Color = col end
                end
            end
            if now - lastScan >= 0.25 then
                lastScan = now
                local preset = SKINS[Config.Skin]
                for _, p in ipairs(gather()) do
                    remember(p)
                    local sa = p:FindFirstChildOfClass("SurfaceAppearance")
                    if sa then stash[sa] = p sa.Parent = nil end
                    if p:IsA("MeshPart") then pcall(function() p.TextureID = "" end) end
                    if preset then
                        p.Color, p.Material, p.Reflectance = preset[1], preset[2], preset[3]
                    else
                        p.Material, p.Reflectance = Enum.Material.Neon, 0
                    end
                end
            end
        end

        if Config.Fullbright then
            if not fbOrig then
                fbOrig = {
                    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                    FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
                    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
                }
            end
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        elseif fbOrig then
            restoreLight()
        end

        if Config.Trigger and Camera then
            local ch = LP.Character
            if ch then trigParams.FilterDescendantsInstances = {ch} end
            local m = UIS:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(m.X, m.Y)
            local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, trigParams)
            if hit then
                local model = hit.Instance:FindFirstAncestorOfClass("Model")
                local plr = model and Players:GetPlayerFromCharacter(model)
                local hum = model and model:FindFirstChildOfClass("Humanoid")
                if plr and plr ~= LP and hum and hum.Health > 0
                    and not (Config.TriggerTeamCheck and plr.Team ~= nil and plr.Team == LP.Team)
                    and now - lastShot >= Config.TriggerDelay / 1000 then
                    lastShot = now
                    task.spawn(function()
                        if mouse1click then
                            mouse1click()
                        elseif mouse1press and mouse1release then
                            mouse1press()
                            task.wait(0.02)
                            mouse1release()
                        end
                    end)
                end
            end
        end
    end))

    track(RunService.Stepped:Connect(function()
        local ch = LP.Character
        if Config.Noclip and ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    noclipped[p] = true
                    p.CanCollide = false
                end
            end
        elseif next(noclipped) then
            restoreNoclip()
        end
    end))

    track(UIS.JumpRequest:Connect(function()
        if not Config.InfJump then return end
        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))

    function X.Unload()
        pcall(function() RunService:UnbindFromRenderStep("RW_EX_STEP") end)
        for _, c in ipairs(conns) do c:Disconnect() end
        pcall(restoreSkins)
        pcall(restoreLight)
        pcall(restoreNoclip)
        for _, l in ipairs(cross) do l:Remove() end
        dot:Remove()
        local cam = Workspace.CurrentCamera
        if fovWas and cam then cam.FieldOfView = baseFov end
        if genv.RW_EX == X then genv.RW_EX = nil end
    end

    EX = X
    genv.RW_EX = X
end

-- ==================== MX综合模块 ====================
do
    local C = {
        Grade = false, Saturation = 0.6, Contrast = 0.05, Tint = Color3.new(1, 1, 1),
        Held = false, HeldColor = Color3.fromRGB(255, 220, 120), HeldUnarmed = false, HeldSize = 12, HeldMax = 1500,
        LootESP = false, LootColor = Color3.fromRGB(120, 255, 160), LootMax = 900,
        LootWords = {"loot", "drop", "corpse", "body", "bag", "pickup", "pick up", "weapon", "gun"},
        PromptESP = false, PromptColor = Color3.fromRGB(120, 200, 255), PromptMax = 120,
        CarESP = false, CarColor = Color3.fromRGB(255, 170, 60), CarMax = 1200,
        Arrows = false, ArrowRadius = 200, ArrowSize = 14, ArrowColor = Color3.fromRGB(255, 70, 70), ArrowMax = 1200,
        Radar = false, RadarSize = 100, RadarRange = 180,
        Death = false,
        Tuner = false, TunerRange = 2, TunerInstant = true, TunerLOS = true,
        Crew = false, CrewList = {}, CrewShow = true, CrewColor = Color3.fromRGB(90, 255, 140),
        SafeFilter = false, SafeSkip = true, SafeTag = true,
        Hitbox = false, HitboxSize = 8, HitboxPart = "Root", HitboxAlpha = 0.7,
        GunSpread = false, GunReload = false, GunFire = false, GunAmmo = false, GunMult = 2,
        Fly = false, FlySpeed = 70,
        AntiAFK = false, Reequip = false, Respawn = false, RespawnDelay = 1.5,
        CarSpeed = false, CarSpeedValue = 90, CarNoFlip = false,
        Alert = false, AlertRadius = 80, AlertMin = 1, AlertSound = true,
        Spectate = false,
        Logger = false, LogRange = 300,
        AutoFarm = false, FarmMode = "Prompts", FarmWords = {"farm", "harvest", "gather", "collect", "mine", "chop", "scrap", "weed", "plant", "grow", "dig", "cut"},
        FarmAny = false, FarmRange = 250, FarmMove = "Tween", FarmSpeed = 70, FarmDelay = 0.25, PromptCooldown = 4,
        FarmNoclip = true, FarmSafe = true, SafeRadius = 60,
        NpcWords = {}, NpcTool = "", NpcStandoff = 7, NpcTimeout = 12, NpcRate = 0.12,
        AutoLoot = false, AutoLootRange = 120,
        Route = false, RoutePoints = {}, RouteRadius = 12, RouteDwell = 0.8, RouteLoop = true, RouteAny = false,
        Cash = false, CashStat = "",
        Waypoints = {}, WpMode = "Tween", WpSpeed = 120,
    }

    local X = {Config = C}
    local alive = true
    local conns, draws = {}, {}
    local function track(c) conns[#conns + 1] = c return c end
    local function now() return os.clock() end
    X.Notify = function() end

    local lastErr = {}
    local function guard(name, f, ...)
        local ok, e = pcall(f, ...)
        if not ok and (not lastErr[name] or now() - lastErr[name] > 5) then
            lastErr[name] = now()
            warn("[xn:" .. name .. "] " .. tostring(e))
        end
    end

    local function snapshot(set)
        local out = {}
        for k in pairs(set) do out[#out + 1] = k end
        return out
    end

    local function matches(text, words)
        for _, w in ipairs(words) do
            if type(w) == "string" and w ~= "" and text:find(w:lower(), 1, true) then return true end
        end
        return false
    end

    local function comma(n)
        local s = tostring(math.floor(n + 0.5))
        local neg = s:sub(1, 1) == "-"
        if neg then s = s:sub(2) end
        s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        return (neg and "-" or "") .. s
    end

    local function myRoot()
        local ch = LP.Character
        if not ch then return nil, nil end
        return ch:FindFirstChild("HumanoidRootPart"), ch:FindFirstChildOfClass("Humanoid")
    end

    local caches = {prompts = {}, tools = {}, npcs = {}, seats = {}}
    local tuned, applyTune

    local function classify(d, add)
        if d:IsA("ProximityPrompt") then
            caches.prompts[d] = add or nil
            if add and C.Tuner and applyTune then applyTune(d) end
        elseif d:IsA("Tool") then
            caches.tools[d] = add or nil
        elseif d:IsA("Humanoid") then
            caches.npcs[d] = add or nil
        elseif d:IsA("VehicleSeat") or (d:IsA("Seat") and d.Name:lower():find("driver", 1, true)) then
            caches.seats[d] = add or nil
        end
    end

    local cachesOn = false
    local function ensureCaches()
        if cachesOn then return end
        cachesOn = true
        track(Workspace.DescendantAdded:Connect(function(d) classify(d, true) end))
        track(Workspace.DescendantRemoving:Connect(function(d) classify(d, false) end))
        task.spawn(function()
            local list = Workspace:GetDescendants()
            for i, d in ipairs(list) do
                if not alive then return end
                classify(d, true)
                if i % 1500 == 0 then task.wait() end
            end
        end)
    end

    local function promptPos(p)
        local a = p.Parent
        if not a then return nil end
        if a:IsA("BasePart") then return a.Position, a end
        if a:IsA("Attachment") then
            local par = a.Parent
            return a.WorldPosition, (par and par:IsA("BasePart")) and par or nil
        end
        if a:IsA("Model") then return a:GetPivot().Position, nil end
        local bp = a:FindFirstAncestorWhichIsA("BasePart")
        if bp then return bp.Position, bp end
        return nil
    end

    local function promptText(p)
        local par = p.Parent
        local gp = par and par.Parent
        return (p.ActionText .. " " .. p.ObjectText .. " " .. (par and par.Name or "") .. " " .. (gp and gp.Name or "")):lower()
    end

    local function promptLabel(p)
        local a, o = p.ActionText, p.ObjectText
        if o ~= "" then return a ~= "" and (a .. " " .. o) or o end
        if a ~= "" then return a end
        return p.Parent and p.Parent.Name or "prompt"
    end

    local mcache = setmetatable({}, {__mode = "k"})
    local function matchesCached(p, words)
        local e = mcache[p]
        local t = now()
        if not e or t - e.t > 4 or e.w ~= words then
            e = {t = t, w = words, v = matches(promptText(p), words)}
            mcache[p] = e
        end
        return e.v
    end

    local function ownedByChar(inst)
        local m = inst:FindFirstAncestorOfClass("Model")
        return m ~= nil and Players:GetPlayerFromCharacter(m) ~= nil
    end

    local function firePrompt(p)
        if fireproximityprompt then
            local ok = pcall(fireproximityprompt, p)
            if ok then return true end
        end
        local hd = p.HoldDuration
        pcall(function() p:InputHoldBegin() end)
        task.wait(hd + 0.05)
        pcall(function() p:InputHoldEnd() end)
        return true
    end

    function X.IsFriend(plr)
        if not C.Crew then return false end
        local n, d = plr.Name:lower(), plr.DisplayName:lower()
        for _, e in ipairs(C.CrewList) do
            local l = tostring(e):lower()
            if l == n or l == d then return true end
        end
        return false
    end

    local SAFE_ATTRS = {"SafeZone", "InSafeZone", "Safezone", "InSafezone", "Safe", "Invincible", "Protected", "GodMode"}
    function X.IsSafe(plr)
        local ch = plr.Character
        if not ch then return false end
        if ch:FindFirstChildOfClass("ForceField") then return true end
        for _, a in ipairs(SAFE_ATTRS) do
            if ch:GetAttribute(a) == true or plr:GetAttribute(a) == true then return true end
        end
        return false
    end

    function X.IsIgnored(plr)
        if X.IsFriend(plr) then return true end
        return C.SafeFilter and C.SafeSkip and X.IsSafe(plr) or false
    end

    function X.IsEnemy(plr)
        if plr == LP then return false end
        if plr.Team ~= nil and plr.Team == LP.Team then return false end
        return not X.IsIgnored(plr)
    end

    local WEAPON_ATTRS = {"EquippedWeapon", "Weapon", "Equipped", "CurrentWeapon", "EquippedTool", "HeldItem"}
    function X.HeldName(plr, ch)
        ch = ch or plr.Character
        if not ch then return nil end
        local tool = ch:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
        for _, a in ipairs(WEAPON_ATTRS) do
            local v = ch:GetAttribute(a)
            if v == nil then v = plr:GetAttribute(a) end
            if type(v) == "string" and v ~= "" then return v end
        end
        for _, c in ipairs(ch:GetChildren()) do
            if c:IsA("Model") and not c:FindFirstChildOfClass("Humanoid") then return c.Name end
        end
        return nil
    end

    local function nearestEnemy(radius)
        local root = myRoot()
        if not root then return nil end
        local best, bd
        for _, p in ipairs(Players:GetPlayers()) do
            if X.IsEnemy(p) then
                local ch = p.Character
                local r = ch and ch:FindFirstChild("HumanoidRootPart")
                local h = ch and ch:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local d = (r.Position - root.Position).Magnitude
                    if d <= radius and (not bd or d < bd) then best, bd = p, d end
                end
            end
        end
        return best, bd
    end

    local function labelAt(pool, i)
        local t = pool[i]
        if not t then
            t = Drawing.new("Text")
            t.Center, t.Outline, t.Font, t.Size, t.Visible = true, true, 2, 12, false
            pool[i] = t
            draws[#draws + 1] = t
        end
        return t
    end
    local function hidePool(pool)
        for _, t in ipairs(pool) do t.Visible = false end
    end
    local function drawList(pool, list, color, textFn)
        local cam = Camera
        local n = 0
        for _, e in ipairs(list) do
            local pos = (e.part and e.part.Parent) and e.part.Position or e.pos
            local v, on = cam:WorldToViewportPoint(pos)
            if on and v.Z > 0 then
                n += 1
                local t = labelAt(pool, n)
                t.Text = textFn(e)
                t.Color = e.color or color
                t.Position = Vector2.new(v.X, v.Y)
                t.Visible = true
            end
        end
        for i = n + 1, #pool do pool[i].Visible = false end
    end

    local lists = {prompts = {}, loot = {}, cars = {}}

    local function refreshPrompts()
        local cp = Camera.CFrame.Position
        local out = {}
        for p in pairs(caches.prompts) do
            if p.Parent and p.Enabled then
                local pos, part = promptPos(p)
                if pos then
                    local d = (pos - cp).Magnitude
                    if d <= C.PromptMax then
                        local farm = matchesCached(p, C.FarmWords)
                        out[#out + 1] = {pos = pos, part = part, dist = d, p = p, farm = farm, color = farm and Color3.fromRGB(120, 255, 160) or nil}
                    end
                end
            end
        end
        table.sort(out, function(a, b) return a.dist < b.dist end)
        for i = #out, 41, -1 do out[i] = nil end
        lists.prompts = out
    end

    local function refreshLoot()
        local cp = Camera.CFrame.Position
        local out, seen = {}, {}
        for t in pairs(caches.tools) do
            local par = t.Parent
            if par and not par:FindFirstChildOfClass("Humanoid") then
                local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart", true)
                if handle then
                    local d = (handle.Position - cp).Magnitude
                    if d <= C.LootMax then
                        local pr = t:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if pr then seen[pr] = true end
                        out[#out + 1] = {inst = t, part = handle, pos = handle.Position, dist = d, name = t.Name, prompt = pr}
                    end
                end
            end
        end
        for p in pairs(caches.prompts) do
            if p.Parent and p.Enabled and not seen[p] and matchesCached(p, C.LootWords) and not ownedByChar(p) then
                local pos, part = promptPos(p)
                if pos then
                    local d = (pos - cp).Magnitude
                    if d <= C.LootMax then
                        out[#out + 1] = {
                            inst = p.Parent, part = part, pos = pos, dist = d, prompt = p,
                            name = p.ObjectText ~= "" and p.ObjectText or p.Parent.Name,
                        }
                    end
                end
            end
        end
        table.sort(out, function(a, b) return a.dist < b.dist end)
        for i = #out, 61, -1 do out[i] = nil end
        lists.loot = out
    end

    local function refreshCars()
        local cp = Camera.CFrame.Position
        local out = {}
        for s in pairs(caches.seats) do
            if s.Parent then
                local d = (s.Position - cp).Magnitude
                if d <= C.CarMax then
                    local m = s:FindFirstAncestorOfClass("Model")
                    local owner = m and m:GetAttribute("Owner") or s:GetAttribute("Owner")
                    local mine = owner ~= nil and (tostring(owner) == LP.Name or tostring(owner) == tostring(LP.UserId))
                    local locked = (m and m:GetAttribute("Locked") == true) or s:GetAttribute("Locked") == true
                    local occ = s.Occupant ~= nil
                    out[#out + 1] = {
                        part = s, seat = s, pos = s.Position, dist = d, name = m and m.Name or s.Name,
                        occ = occ, locked = locked, mine = mine,
                        color = mine and Color3.fromRGB(110, 255, 150) or (occ and Color3.fromRGB(255, 90, 90)) or (locked and Color3.fromRGB(255, 200, 80)) or nil,
                    }
                end
            end
        end
        table.sort(out, function(a, b) return a.dist < b.dist end)
        for i = #out, 26, -1 do out[i] = nil end
        lists.cars = out
    end

    local function goTo(pos, o)
        local root, hum = myRoot()
        if not root then return false end
        local mode, speed, stop = o.mode or "Tween", math.max(o.speed or 60, 5), o.stop or 3
        if mode == "Teleport" then
            root.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0)) * root.CFrame.Rotation
            root.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        local dist0 = (pos - root.Position).Magnitude
        local limit = mode == "Walk" and (dist0 / 14 + 8) or (dist0 / speed + 6)
        local t0 = now()
        while alive do
            if o.abort and o.abort() then return false end
            root, hum = myRoot()
            if not root then return false end
            local delta = pos - root.Position
            local m = delta.Magnitude
            if m <= stop then return true end
            if now() - t0 > limit then return false end
            if mode == "Walk" then
                if hum then hum:MoveTo(pos) end
                task.wait(0.1)
            else
                local dt = RunService.Heartbeat:Wait()
                root = myRoot()
                if not root then return false end
                delta = pos - root.Position
                m = delta.Magnitude
                if m > 0.001 then
                    root.CFrame = root.CFrame + delta.Unit * math.min(m, speed * dt)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
        return false
    end

    local stats = {farm = 0, loot = 0, npc = 0, t0 = now(), status = "空闲"}
    local blacklist = {}
    local function bl(i, secs) blacklist[i] = now() + secs end
    local function isBL(i)
        local e = blacklist[i]
        if e and e > now() then return true end
        blacklist[i] = nil
        return false
    end

    local function anyJob() return C.AutoFarm or C.AutoLoot or C.Route end

    local function makeAbort(extra)
        local nextCheck, cached = 0, false
        return function()
            if not alive or not anyJob() then return true end
            local t = now()
            if t >= nextCheck then
                nextCheck = t + 0.2
                local _, hum = myRoot()
                cached = (not hum) or hum.Health <= 0 or (C.FarmSafe and nearestEnemy(C.SafeRadius) ~= nil)
            end
            return cached or (extra and extra()) or false
        end
    end

    function X.StatsText()
        local mins = math.max((now() - stats.t0) / 60, 1 / 60)
        local total = stats.farm + stats.loot + stats.npc
        return string.format("%s\n农场 %d   拾取 %d   NPC %d\n%.1f 次操作/分钟", stats.status, stats.farm, stats.loot, stats.npc, total / mins)
    end
    function X.ResetStats()
        stats.farm, stats.loot, stats.npc, stats.t0 = 0, 0, 0, now()
    end

    local function nearestFarmPrompt(origin)
        local best, bd, bpos
        for p in pairs(caches.prompts) do
            if p.Parent and p.Enabled and not isBL(p) then
                local pos = promptPos(p)
                if pos then
                    local d = (pos - origin).Magnitude
                    if d <= C.FarmRange and (not bd or d < bd) and (C.FarmAny or matchesCached(p, C.FarmWords)) and not ownedByChar(p) then
                        best, bd, bpos = p, d, pos
                    end
                end
            end
        end
        return best, bpos, bd
    end

    local function nearestNpc(origin)
        local mine = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        local best, bd
        for h in pairs(caches.npcs) do
            local m = h.Parent
            if m and h ~= mine and h.Health > 0 and not Players:GetPlayerFromCharacter(m) and not isBL(h) then
                local r = m:FindFirstChild("HumanoidRootPart") or (m:IsA("Model") and m.PrimaryPart) or m:FindFirstChildWhichIsA("BasePart")
                if r then
                    local d = (r.Position - origin).Magnitude
                    if d <= C.FarmRange and (not bd or d < bd) and (#C.NpcWords == 0 or matches(m.Name:lower(), C.NpcWords)) then
                        best, bd = h, d
                    end
                end
            end
        end
        return best, bd
    end

    local function farmPromptJob(root)
        local p, pos = nearestFarmPrompt(root.Position)
        if not p then return false end
        stats.status = "农场: " .. promptLabel(p)
        local stop = math.clamp(p.MaxActivationDistance * 0.6, 2, 8)
        local ok = goTo(pos, {mode = C.FarmMove, speed = C.FarmSpeed, stop = stop, abort = makeAbort(function() return not p.Parent or not p.Enabled end)})
        if ok and p.Parent then
            firePrompt(p)
            stats.farm += 1
            bl(p, C.PromptCooldown)
            task.wait(C.FarmDelay)
        else
            bl(p, 1.5)
        end
        return true
    end

    X.AimTarget = nil
    local function npcJob(root, hum)
        local h = nearestNpc(root.Position)
        if not h then return false end
        local model = h.Parent
        local tr = model:FindFirstChild("HumanoidRootPart") or (model:IsA("Model") and model.PrimaryPart) or model:FindFirstChildWhichIsA("BasePart")
        local head = model:FindFirstChild("Head") or tr
        if not tr then bl(h, 5) return true end
        stats.status = "NPC: " .. model.Name
        local abort = makeAbort(function() return h.Health <= 0 or not model.Parent or not tr.Parent end)

        local ch = LP.Character
        if ch and not ch:FindFirstChildOfClass("Tool") then
            local bp = LP:FindFirstChildOfClass("Backpack")
            local t = bp and ((C.NpcTool ~= "" and bp:FindFirstChild(C.NpcTool)) or bp:FindFirstChildWhichIsA("Tool"))
            if t then
                hum:EquipTool(t)
                task.wait(0.2)
            end
        end

        local t0 = now()
        while not abort() and now() - t0 < C.NpcTimeout do
            local r, hm = myRoot()
            if not r then break end
            local tp = tr.Position
            if (r.Position - tp).Magnitude > C.NpcStandoff + 4 then
                goTo(tp, {mode = C.FarmMove, speed = C.FarmSpeed, stop = C.NpcStandoff, abort = abort})
            end
            r = myRoot()
            if not r then break end
            X.AimTarget = head
            r.CFrame = CFrame.lookAt(r.Position, Vector3.new(tp.X, r.Position.Y, tp.Z))
            local ct = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if mouse1click then
                pcall(mouse1click)
            elseif ct then
                pcall(function() ct:Activate() end)
            end
            task.wait(C.NpcRate)
        end
        X.AimTarget = nil
        if h.Health <= 0 then
            stats.npc += 1
            bl(h, 30)
        else
            bl(h, 5)
        end
        return true
    end

    local function farmJob()
        local root, hum = myRoot()
        if not (root and hum) then return false end
        local mode = C.FarmMode
        if mode == "Prompts" or mode == "Both" then
            if farmPromptJob(root) then return true end
        end
        if mode == "NPCs" or mode == "Both" then
            if npcJob(root, hum) then return true end
        end
        return false
    end

    local function lootJob()
        local root = myRoot()
        if not root then return false end
        local best
        for _, e in ipairs(lists.loot) do
            if e.dist <= C.AutoLootRange and e.part and e.part.Parent and not isBL(e.inst) then
                best = e
                break
            end
        end
        if not best then return false end
        stats.status = "拾取: " .. best.name
        local stop = best.prompt and math.clamp(best.prompt.MaxActivationDistance * 0.6, 2, 8) or 2
        local part = best.part
        local ok = goTo(part.Position, {mode = C.FarmMove, speed = C.FarmSpeed, stop = stop, abort = makeAbort(function() return not part.Parent end)})
        if ok and part.Parent then
            if best.prompt then
                firePrompt(best.prompt)
            elseif firetouchinterest then
                local r = myRoot()
                if r then
                    pcall(firetouchinterest, r, part, 0)
                    task.wait()
                    pcall(firetouchinterest, r, part, 1)
                end
            end
            stats.loot += 1
            task.wait(C.FarmDelay)
        end
        bl(best.inst, ok and 8 or 1.5)
        return true
    end

    function X.ParsePoint(s)
        local n, x, y, z = tostring(s):match("^(.-)|(-?[%d%.]+)|(-?[%d%.]+)|(-?[%d%.]+)$")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if not (n and x and y and z) then return nil end
        return n, Vector3.new(x, y, z)
    end
    function X.FormatPoint(name)
        local r = myRoot()
        if not r then return nil end
        local p = r.Position
        return string.format("%s|%.1f|%.1f|%.1f", name, p.X, p.Y, p.Z)
    end

    local routeIdx = 1
    local function routeJob()
        local pts = {}
        for _, s in ipairs(C.RoutePoints) do
            local n, v = X.ParsePoint(s)
            if v then pts[#pts + 1] = {n, v} end
        end
        if #pts == 0 then
            stats.status = "路线: 无路径点"
            return false
        end
        if routeIdx > #pts then routeIdx = 1 end
        local n, v = pts[routeIdx][1], pts[routeIdx][2]
        stats.status = "路线: " .. n
        local ok = goTo(v, {mode = C.FarmMove, speed = C.FarmSpeed, stop = 2.5, abort = makeAbort()})
        if not ok then return true end
        local rp = myRoot()
        if rp then
            for _, p in ipairs(snapshot(caches.prompts)) do
                if p.Parent and p.Enabled and not isBL(p) then
                    local pos = promptPos(p)
                    if pos and (pos - rp.Position).Magnitude <= C.RouteRadius and (C.RouteAny or matchesCached(p, C.FarmWords)) then
                        firePrompt(p)
                        bl(p, C.PromptCooldown)
                        stats.farm += 1
                        task.wait(C.FarmDelay)
                    end
                end
            end
        end
        task.wait(C.RouteDwell)
        routeIdx += 1
        if routeIdx > #pts then
            routeIdx = 1
            if not C.RouteLoop then
                C.Route = false
                X.Notify("农场路线", "路线已完成", "ok")
            end
        end
        return true
    end

    local farmingNow = false
    task.spawn(function()
        local wasActive = false
        while alive do
            task.wait(0.15)
            local active = anyJob()
            if active and not wasActive then X.ResetStats() end
            wasActive = active
            if not active then
                stats.status = "空闲"
                farmingNow = false
                continue
            end
            local root, hum = myRoot()
            if not (root and hum) or hum.Health <= 0 then
                stats.status = "死亡"
                farmingNow = false
                continue
            end
            if C.FarmSafe then
                local e, d = nearestEnemy(C.SafeRadius)
                if e then
                    stats.status = string.format("暂停: %s %.0fm", e.DisplayName, d)
                    farmingNow = false
                    continue
                end
            end
            farmingNow = true
            local ran = false
            if C.AutoLoot then
                local ok, r = pcall(lootJob)
                if ok then ran = r else warn("[xn:loot] " .. tostring(r)) end
            end
            if not ran and C.AutoFarm then
                local ok, r = pcall(farmJob)
                if ok then ran = r else warn("[xn:farm] " .. tostring(r)) end
            end
            if not ran and C.Route then
                local ok, r = pcall(routeJob)
                if ok then ran = r else warn("[xn:route] " .. tostring(r)) end
            end
            X.AimTarget = ran and X.AimTarget or nil
            if not ran then
                stats.status = "搜索中"
                farmingNow = false
            end
        end
    end)

    local nc = {}
    track(RunService.Stepped:Connect(function()
        local ch = LP.Character
        if farmingNow and C.FarmNoclip and ch then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    nc[p] = true
                    p.CanCollide = false
                end
            end
        elseif next(nc) then
            for p in pairs(nc) do
                if p.Parent then p.CanCollide = true end
            end
            nc = {}
        end
    end))

    RunService:BindToRenderStep("RW_MX_AIM", Enum.RenderPriority.Camera.Value + 2, function()
        local t = X.AimTarget
        local cam = Workspace.CurrentCamera
        if t and t.Parent and cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, t.Position)
        end
    end)

    tuned = {}
    applyTune = function(p)
        local o = tuned[p]
        if not o then
            o = {p.HoldDuration, p.MaxActivationDistance, p.RequiresLineOfSight}
            tuned[p] = o
        end
        p.HoldDuration = C.TunerInstant and 0 or o[1]
        p.MaxActivationDistance = math.clamp(o[2] * C.TunerRange, 0, 80)
        p.RequiresLineOfSight = (not C.TunerLOS) and o[3] or false
    end
    local function untuneAll()
        for p, o in pairs(tuned) do
            if p.Parent then
                pcall(function()
                    p.HoldDuration, p.MaxActivationDistance, p.RequiresLineOfSight = o[1], o[2], o[3]
                end)
            end
        end
        tuned = {}
    end
    local tuneKey
    local function tuneStep()
        if C.Tuner then
            local key = tostring(C.TunerRange) .. tostring(C.TunerInstant) .. tostring(C.TunerLOS)
            local retune = key ~= tuneKey
            tuneKey = key
            for _, p in ipairs(snapshot(caches.prompts)) do
                if p.Parent and (retune or not tuned[p]) then applyTune(p) end
            end
        elseif next(tuned) then
            untuneAll()
            tuneKey = nil
        end
    end

    local gradeFx
    local function gradeStep()
        if C.Grade then
            if not gradeFx or not gradeFx.Parent then
                gradeFx = Instance.new("ColorCorrectionEffect")
                gradeFx.Name = "__rw_grade"
                gradeFx.Parent = Lighting
            end
            gradeFx.Saturation = C.Saturation
            gradeFx.Contrast = C.Contrast
            gradeFx.TintColor = C.Tint
        elseif gradeFx then
            gradeFx:Destroy()
            gradeFx = nil
        end
    end

    local hitOrig, lastHitKey = {}, nil
    local function restoreHit()
        for part, o in pairs(hitOrig) do
            if part.Parent then
                pcall(function()
                    part.Size, part.Transparency, part.CanCollide, part.Massless = o[1], o[2], o[3], o[4]
                end)
            end
        end
        hitOrig, lastHitKey = {}, nil
    end
    local function hitStep()
        if not C.Hitbox then
            if next(hitOrig) then restoreHit() end
            return
        end
        local key = C.HitboxPart .. tostring(C.HitboxSize) .. tostring(C.HitboxAlpha)
        if key ~= lastHitKey then
            restoreHit()
            lastHitKey = key
        end
        local s = C.HitboxSize
        for _, p in ipairs(Players:GetPlayers()) do
            if X.IsEnemy(p) then
                local ch = p.Character
                local part = ch and (C.HitboxPart == "Head" and ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
                if part and part:IsA("BasePart") then
                    if not hitOrig[part] then hitOrig[part] = {part.Size, part.Transparency, part.CanCollide, part.Massless} end
                    part.Size = Vector3.new(s, s, s)
                    part.Transparency = C.HitboxAlpha
                    part.CanCollide = false
                    part.Massless = true
                end
            end
        end
    end

    local gunTabs = setmetatable({}, {__mode = "k"})
    local gunOrig = setmetatable({}, {__mode = "k"})
    local gunScanning = false
    local GUN_HINTS = {"spread", "recoil", "firerate", "fire_rate", "reload", "ammo", "cooldown", "bloom"}

    local function gunHits(t)
        local hits = 0
        for k, v in pairs(t) do
            if type(k) == "string" and type(v) == "number" then
                local l = k:lower()
                for _, h in ipairs(GUN_HINTS) do
                    if l:find(h, 1, true) then
                        hits += 1
                        break
                    end
                end
            end
        end
        return hits
    end

    function X.RescanGun()
        if not getgc or gunScanning then return end
        gunScanning = true
        task.spawn(function()
            local ok, list = pcall(getgc, true)
            if ok and type(list) == "table" then
                for i, t in ipairs(list) do
                    if not alive then break end
                    if type(t) == "table" and not gunTabs[t] then
                        local good, n = pcall(gunHits, t)
                        if good and n >= 2 then gunTabs[t] = true end
                    end
                    if i % 1500 == 0 then task.wait() end
                end
            end
            gunScanning = false
        end)
    end

    local function setGun(t, k, v)
        local o = gunOrig[t]
        if not o then
            o = {}
            gunOrig[t] = o
        end
        if o[k] == nil then o[k] = t[k] end
        t[k] = v
    end

    local function restoreGun()
        for t, o in pairs(gunOrig) do
            for k, v in pairs(o) do pcall(function() t[k] = v end) end
        end
        gunOrig = setmetatable({}, {__mode = "k"})
    end

    local function applyGun()
        local mult = math.max(C.GunMult, 1)
        for t in pairs(gunTabs) do
            local keys = {}
            for k, v in pairs(t) do
                if type(k) == "string" and type(v) == "number" then keys[#keys + 1] = k end
            end
            for _, k in ipairs(keys) do
                local l = k:lower()
                local base = gunOrig[t] and gunOrig[t][k]
                if base == nil then base = t[k] end
                pcall(function()
                    if C.GunSpread and (l:find("spread", 1, true) or l:find("bloom", 1, true) or l:find("inaccuracy", 1, true) or l:find("recoil", 1, true)) then
                        setGun(t, k, 0)
                    elseif C.GunReload and l:find("reload", 1, true) and (l:find("time", 1, true) or l:find("delay", 1, true) or l:find("duration", 1, true)) then
                        setGun(t, k, 0.05)
                    elseif C.GunFire and (l:find("firerate", 1, true) or l:find("fire_rate", 1, true) or l == "rpm") then
                        setGun(t, k, base * mult)
                    elseif C.GunFire and (l:find("delay", 1, true) or l:find("cooldown", 1, true) or l:find("interval", 1, true))
                        and (l:find("fire", 1, true) or l:find("shoot", 1, true) or l:find("shot", 1, true)) then
                        setGun(t, k, base / mult)
                    elseif C.GunAmmo and (l == "ammo" or l == "currentammo" or l == "clip" or l == "mag" or l == "magazine") then
                        local cap = t.MaxAmmo or t.maxAmmo or t.MagSize or t.ClipSize or t.magSize or t.clipSize
                        setGun(t, k, type(cap) == "number" and cap or 999)
                    end
                end)
            end
        end
    end

    local gunWasOn, gunKey, lastGunScan = false, nil, 0
    local function gunStep()
        local on = C.GunSpread or C.GunReload or C.GunFire or C.GunAmmo
        if on then
            if not gunWasOn or now() - lastGunScan > 10 then
                lastGunScan = now()
                X.RescanGun()
            end
            local key = tostring(C.GunSpread) .. tostring(C.GunReload) .. tostring(C.GunFire) .. tostring(C.GunAmmo) .. tostring(C.GunMult)
            if key ~= gunKey then
                restoreGun()
                gunKey = key
            end
            applyGun()
            gunWasOn = true
        elseif gunWasOn then
            restoreGun()
            gunWasOn, gunKey = false, nil
        end
    end

    local flyWas = false
    local function stepFly(dt)
        local root, hum = myRoot()
        if not (root and hum) then return end
        if C.Fly then
            flyWas = true
            hum.PlatformStand = true
            local cam = Camera.CFrame
            local mv = Vector3.zero
            if not UIS:GetFocusedTextBox() then
                if UIS:IsKeyDown(Enum.KeyCode.W) then mv += cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mv += cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.yAxis end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.yAxis end
            end
            local pos = root.Position
            if mv.Magnitude > 0 then pos += mv.Unit * C.FlySpeed * dt end
            local look = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
            if look.Magnitude > 0.01 then
                root.CFrame = CFrame.lookAt(pos, pos + look)
            else
                root.CFrame = CFrame.new(pos)
            end
            root.AssemblyLinearVelocity = Vector3.zero
        elseif flyWas then
            flyWas = false
            hum.PlatformStand = false
        end
    end

    local function stepCar()
        if not C.CarSpeed then return end
        local _, hum = myRoot()
        local seat = hum and hum.SeatPart
        if not (seat and seat:IsA("BasePart")) or UIS:GetFocusedTextBox() then return end
        local v = seat.AssemblyLinearVelocity
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            local planar = Vector3.new(v.X, 0, v.Z)
            local dir
            if planar.Magnitude > 3 then
                dir = planar.Unit
            else
                local lv = seat.CFrame.LookVector
                local flat = Vector3.new(lv.X, 0, lv.Z)
                if flat.Magnitude > 0.01 then dir = flat.Unit end
            end
            if dir and planar.Magnitude < C.CarSpeedValue then
                seat.AssemblyLinearVelocity = Vector3.new(dir.X * C.CarSpeedValue, v.Y, dir.Z * C.CarSpeedValue)
            end
        end
        if C.CarNoFlip and seat.CFrame.UpVector.Y < 0.35 then
            local p, lv = seat.Position + Vector3.new(0, 3, 0), seat.CFrame.LookVector
            seat.AssemblyAngularVelocity = Vector3.zero
            seat.CFrame = CFrame.lookAt(p, p + Vector3.new(lv.X, 0, lv.Z))
        end
    end

    function X.TpCar()
        if not cachesOn then
            ensureCaches()
            X.Notify("车辆查找", "正在扫描地图，几秒后再试", "off")
            return
        end
        refreshCars()
        local rp = myRoot()
        for _, e in ipairs(lists.cars) do
            if not e.occ and rp then
                rp.CFrame = e.seat.CFrame * CFrame.new(-4, 1.5, 0)
                rp.AssemblyLinearVelocity = Vector3.zero
                X.Notify("车辆查找", "已移动到 " .. e.name, "ok")
                return
            end
        end
        X.Notify("车辆查找", "范围内没有空闲车辆", "err")
    end

    X.DeathPos, X.DeathT = nil, nil
    local logLines = {}
    local function logEvent(s)
        table.insert(logLines, 1, os.date("%H:%M:%S") .. "  " .. s)
        while #logLines > 8 do table.remove(logLines) end
        if X.OnLog then X.OnLog(table.concat(logLines, "\n")) end
    end
    function X.ClearLog()
        logLines = {}
        if X.OnLog then X.OnLog("暂无事件") end
    end

    local RESPAWN_WORDS = {"respawn", "deploy", "重生", "复活"}
    local function pressButton(b)
        local fired = false
        if getconnections then
            for _, sig in ipairs({"MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up"}) do
                local ok, cs = pcall(getconnections, b[sig])
                if ok and type(cs) == "table" then
                    for _, c in ipairs(cs) do
                        pcall(function() c:Fire() end)
                        fired = true
                    end
                end
            end
        end
        if not fired and firesignal then
            pcall(firesignal, b.MouseButton1Click)
            pcall(firesignal, b.Activated)
        end
    end
    local function findRespawnButton()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if not pg then return nil end
        for _, d in ipairs(pg:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("ImageButton")) and d.Visible and d.AbsoluteSize.X > 4 then
                local sg = d:FindFirstAncestorOfClass("ScreenGui")
                if sg and sg.Enabled then
                    local txt = d:IsA("TextButton") and d.Text or ""
                    for _, c in ipairs(d:GetChildren()) do
                        if c:IsA("TextLabel") then txt = txt .. " " .. c.Text end
                    end
                    if matches((txt .. " " .. d.Name):lower(), RESPAWN_WORDS) then return d end
                end
            end
        end
        return nil
    end

    local lastTool
    local function hookSelf(ch)
        local hum = ch:WaitForChild("Humanoid", 10)
        if not hum then return end
        local last = hum.Health
        track(hum.HealthChanged:Connect(function(hp)
            if C.Logger and hp < last - 0.5 then
                local e, d = nearestEnemy(300)
                logEvent(string.format("-%.0f 生命值 (剩余 %.0f)%s", last - hp, hp,
                    e and string.format(" 附近 %s %.0fm [%s]", e.DisplayName, d, X.HeldName(e) or "-") or ""))
            end
            last = hp
        end))
        track(hum.Died:Connect(function()
            local r = ch:FindFirstChild("HumanoidRootPart")
            if r then X.DeathPos, X.DeathT = r.Position, now() end
            if C.Logger then
                local e, d = nearestEnemy(300)
                logEvent("你死了" .. (e and string.format(" - 最近敌人 %s %.0fm [%s]", e.DisplayName, d, X.HeldName(e) or "-") or ""))
            end
            if C.Respawn then
                task.delay(C.RespawnDelay, function()
                    for _ = 1, 10 do
                        local b = findRespawnButton()
                        if b then
                            pressButton(b)
                            break
                        end
                        task.wait(0.4)
                    end
                end)
            end
        end))
    end
    track(LP.CharacterAdded:Connect(function(ch)
        task.spawn(hookSelf, ch)
        if C.Reequip and lastTool then
            task.spawn(function()
                local name = lastTool
                local bp = LP:WaitForChild("Backpack", 8)
                local t = bp and bp:WaitForChild(name, 8)
                local hum = ch:WaitForChild("Humanoid", 5)
                if t and hum then
                    task.wait(0.4)
                    pcall(function() hum:EquipTool(t) end)
                end
            end)
        end
    end))
    if LP.Character then task.spawn(hookSelf, LP.Character) end

    local lastHeld = {}
    local function watchPlayer(p)
        if p == LP then return end
        local function hook(ch)
            local hum = ch:WaitForChild("Humanoid", 8)
            if not hum then return end
            track(hum.Died:Connect(function()
                if not C.Logger then return end
                local r = ch:FindFirstChild("HumanoidRootPart")
                local me = myRoot()
                local d = (r and me) and (r.Position - me.Position).Magnitude or nil
                if not d or d <= C.LogRange then
                    logEvent(string.format("%s 死亡%s [持有 %s]", p.DisplayName, d and string.format(" %.0fm", d) or "", lastHeld[p] or "-"))
                end
            end))
        end
        track(p.CharacterAdded:Connect(hook))
        if p.Character then task.spawn(hook, p.Character) end
    end
    for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
    track(Players.PlayerAdded:Connect(watchPlayer))
    track(Players.PlayerRemoving:Connect(function(p) lastHeld[p] = nil end))

    track(LP.Idled:Connect(function()
        if C.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end))

    local specTarget, specWas = nil, false
    local function applySpectate()
        local ch = specTarget and specTarget.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if h and Camera.CameraSubject ~= h then Camera.CameraSubject = h end
    end
    local function stopSpectate()
        local _, h = myRoot()
        if h then Camera.CameraSubject = h end
    end
    function X.SpectateStep(dir)
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then list[#list + 1] = p end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        if #list == 0 then return end
        local idx = table.find(list, specTarget)
        if not idx then
            idx = dir > 0 and 1 or #list
        else
            idx = ((idx - 1 + dir) % #list) + 1
        end
        specTarget = list[idx]
        X.Notify("观战", specTarget.DisplayName, "ok")
        if C.Spectate then applySpectate() end
    end
    function X.SpectateFind(q)
        q = tostring(q):lower()
        if q == "" then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and (p.Name:lower():find(q, 1, true) or p.DisplayName:lower():find(q, 1, true)) then
                specTarget = p
                X.Notify("观战", p.DisplayName, "ok")
                if C.Spectate then applySpectate() end
                return
            end
        end
        X.Notify("观战", "未找到匹配玩家", "err")
    end

    function X.GoTo(name)
        name = tostring(name):lower()
        local pos
        if name == "death" or name == "死亡" then
            pos = X.DeathPos
        else
            for _, s in ipairs(C.Waypoints) do
                local n, v = X.ParsePoint(s)
                if v and (n:lower() == name or n:lower():find(name, 1, true) == 1) then
                    pos = v
                    break
                end
            end
        end
        if not pos then
            X.Notify("路径点", "未找到路径点 " .. name, "err")
            return
        end
        task.spawn(function()
            local ok = goTo(pos, {mode = C.WpMode, speed = C.WpSpeed, stop = 2})
            X.Notify("路径点", ok and "已到达" or "无法到达", ok and "ok" or "err")
        end)
    end

    local function httpGet(url)
        local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
        if req then
            local r = req({Url = url, Method = "GET"})
            return r and r.Body
        end
        local ok, body = pcall(function() return game:HttpGet(url) end)
        return ok and body or nil
    end

    function X.Hop(mode)
        task.spawn(function()
            local ok, err = pcall(function()
                local found, cursor = {}, ""
                for _ = 1, 2 do
                    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s", game.PlaceId,
                        cursor ~= "" and ("&cursor=" .. cursor) or "")
                    local body = httpGet(url)
                    if not body then error("HTTP请求失败") end
                    local data = HttpService:JSONDecode(body)
                    for _, s in ipairs(data.data or {}) do
                        if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers - 1 then
                            found[#found + 1] = s
                        end
                    end
                    if not data.nextPageCursor then break end
                    cursor = data.nextPageCursor
                end
                if #found == 0 then error("未找到可用服务器") end
                table.sort(found, function(a, b) return a.playing < b.playing end)
                local pick = found[1]
                if mode == "高人数" then pick = found[#found]
                elseif mode == "随机" then pick = found[math.random(#found)] end
                X.Notify("服务器跳转", pick.playing .. " 玩家，加入中", "ok")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LP)
            end)
            if not ok then X.Notify("服务器跳转", tostring(err), "err") end
        end)
    end
    function X.Rejoin()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
    end

    local CASH_WORDS = {"cash", "money", "coins", "gold", "bank", "金币", "金钱", "现金"}
    local cash = {start = nil, t0 = now()}
    function X.ReadCash()
        local custom = C.CashStat:lower()
        local function scanChildren(folder)
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("ValueBase") and type(v.Value) == "number" then
                    local n = v.Name:lower()
                    if custom ~= "" then
                        if n == custom then return v.Value end
                    elseif matches(n, CASH_WORDS) then
                        return v.Value
                    end
                end
            end
        end
        local ls = LP:FindFirstChild("leaderstats")
        local r = ls and scanChildren(ls)
        if r then return r end
        r = scanChildren(LP)
        if r then return r end
        for _, f in ipairs(LP:GetChildren()) do
            if f:IsA("Folder") and f.Name ~= "leaderstats" then
                r = scanChildren(f)
                if r then return r end
            end
        end
        for k, v in pairs(LP:GetAttributes()) do
            if type(v) == "number" then
                local n = k:lower()
                if (custom ~= "" and n == custom) or (custom == "" and matches(n, CASH_WORDS)) then return v end
            end
        end
        return nil
    end
    function X.CashReset()
        cash.start, cash.t0 = nil, now()
    end
    function X.CashText()
        local cur = X.ReadCash()
        if not cur then return "未找到金钱属性\n请在设置中指定属性名" end
        if not cash.start then cash.start, cash.t0 = cur, now() end
        local gain = cur - cash.start
        local mins = math.max((now() - cash.t0) / 60, 1 / 60)
        return string.format("金钱 %s\n%s%s 总计   %s%s / 分钟", comma(cur), gain >= 0 and "+" or "", comma(gain), gain >= 0 and "+" or "", comma(gain / mins))
    end

    local heldPool, promptPool, lootPool, carPool, arrowPool = {}, {}, {}, {}, {}
    local deathTxt, deathDot, alertSq, alertTxt
    local radar = {dots = {}}
    local hudReady = false
    local function initHud()
        if hudReady then return end
        hudReady = true
        deathTxt = Drawing.new("Text")
        deathTxt.Center, deathTxt.Outline, deathTxt.Font, deathTxt.Size, deathTxt.Visible = true, true, 2, 13, false
        deathDot = Drawing.new("Circle")
        deathDot.NumSides, deathDot.Radius, deathDot.Filled, deathDot.Visible = 16, 4, true, false
        radar.bg, radar.ring, radar.me = Drawing.new("Circle"), Drawing.new("Circle"), Drawing.new("Circle")
        radar.bg.NumSides, radar.bg.Filled, radar.bg.Color, radar.bg.Transparency, radar.bg.Visible = 48, true, Color3.new(0, 0, 0), 0.5, false
        radar.ring.NumSides, radar.ring.Filled, radar.ring.Thickness, radar.ring.Color, radar.ring.Visible = 48, false, 1, Color3.fromRGB(200, 200, 210), false
        radar.me.NumSides, radar.me.Filled, radar.me.Radius, radar.me.Color, radar.me.Visible = 12, true, 3, Color3.new(1, 1, 1), false
        alertSq = Drawing.new("Square")
        alertSq.Filled, alertSq.Thickness, alertSq.Color, alertSq.Visible = false, 6, Color3.fromRGB(255, 40, 40), false
        alertTxt = Drawing.new("Text")
        alertTxt.Center, alertTxt.Outline, alertTxt.Font, alertTxt.Size, alertTxt.Color, alertTxt.Visible = true, true, 2, 18, Color3.fromRGB(255, 80, 80), false
        for _, d in ipairs({deathTxt, deathDot, radar.bg, radar.ring, radar.me, alertSq, alertTxt}) do
            draws[#draws + 1] = d
        end
    end

    local function collect()
        local out = {}
        local cp = Camera.CFrame.Position
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local friend = X.IsFriend(p)
                    local safe = C.SafeFilter and X.IsSafe(p) or false
                    local team = p.Team ~= nil and p.Team == LP.Team
                    out[#out + 1] = {
                        plr = p, root = root, dist = (root.Position - cp).Magnitude, friend = friend, safe = safe,
                        enemy = not friend and not team and not (C.SafeSkip and safe),
                        color = friend and C.CrewColor or (team and Color3.fromRGB(110, 110, 120)) or (safe and Color3.fromRGB(150, 150, 160)) or Color3.fromRGB(255, 70, 70),
                    }
                end
            end
        end
        return out
    end

    local function renderHeld()
        if not C.Held then
            for _, t in pairs(heldPool) do t.Visible = false end
            return
        end
        local cam = Camera
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local t = heldPool[plr]
                if not t then
                    t = Drawing.new("Text")
                    t.Center, t.Outline, t.Font, t.Visible = true, true, 2, false
                    heldPool[plr] = t
                    draws[#draws + 1] = t
                end
                local show = false
                local ch = plr.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local friend = X.IsFriend(plr)
                    local ally = (plr.Team ~= nil and plr.Team == LP.Team) or friend
                    local dist = (cam.CFrame.Position - root.Position).Magnitude
                    if dist <= C.HeldMax and not (ESP.Config.TeamCheck and ally and not (friend and C.CrewShow)) then
                        local name = X.HeldName(plr, ch)
                        if name or C.HeldUnarmed then
                            local v, on = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.3, 0))
                            if on and v.Z > 0 then
                                t.Text = name and ("[" .. name .. "]") or "[空手]"
                                t.Color = name and C.HeldColor or Color3.fromRGB(150, 150, 150)
                                t.Size = C.HeldSize
                                t.Position = Vector2.new(v.X, v.Y + (ESP.Config.Distance and 14 or 2))
                                show = true
                            end
                        end
                    end
                end
                t.Visible = show
            end
        end
    end
    track(Players.PlayerRemoving:Connect(function(p)
        local t = heldPool[p]
        if t then
            pcall(function() t:Remove() end)
            heldPool[p] = nil
        end
    end))

    local function renderArrows(list)
        local n = 0
        if C.Arrows then
            local cam = Camera
            local vp = cam.ViewportSize
            local ctr = vp / 2
            for _, e in ipairs(list) do
                if e.enemy and e.dist <= C.ArrowMax then
                    local v, on = cam:WorldToViewportPoint(e.root.Position)
                    if not (on and v.Z > 0) then
                        local dir = Vector2.new(v.X, v.Y) - ctr
                        if v.Z < 0 then dir = -dir end
                        if dir.Magnitude < 1 then dir = Vector2.new(0, -1) end
                        dir = dir.Unit
                        local p = ctr + dir * math.min(C.ArrowRadius, vp.Y / 2 - 30)
                        local s = C.ArrowSize
                        local perp = Vector2.new(-dir.Y, dir.X)
                        n += 1
                        local tri = arrowPool[n]
                        if not tri then
                            tri = Drawing.new("Triangle")
                            tri.Filled, tri.Thickness, tri.Visible = true, 1, false
                            arrowPool[n] = tri
                            draws[#draws + 1] = tri
                        end
                        tri.PointA = p + dir * s
                        tri.PointB = p - dir * (s * 0.5) + perp * (s * 0.6)
                        tri.PointC = p - dir * (s * 0.5) - perp * (s * 0.6)
                        tri.Color = C.ArrowColor
                        tri.Visible = true
                    end
                end
            end
        end
        for i = n + 1, #arrowPool do arrowPool[i].Visible = false end
    end

    local function renderRadar(list)
        if C.Radar then initHud() end
        if not hudReady then return end
        local on = C.Radar
        radar.bg.Visible, radar.ring.Visible, radar.me.Visible = on, on, on
        if not on then
            for _, d in ipairs(radar.dots) do d.Visible = false end
            return
        end
        local vp = Camera.ViewportSize
        local r = C.RadarSize
        local c = Vector2.new(vp.X - r - 24, r + 70)
        radar.bg.Position, radar.bg.Radius = c, r
        radar.ring.Position, radar.ring.Radius = c, r
        radar.me.Position = c
        local cf = Camera.CFrame
        local fwd = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        if fwd.Magnitude < 0.01 then fwd = Vector3.new(0, 0, -1) end
        fwd = fwd.Unit
        local right = Vector3.new(-fwd.Z, 0, fwd.X)
        local mr = myRoot()
        local origin = mr and mr.Position or cf.Position
        local n = 0
        for _, e in ipairs(list) do
            local rel = e.root.Position - origin
            local v = Vector2.new(rel:Dot(right), -rel:Dot(fwd)) * (r / C.RadarRange)
            if v.Magnitude > r - 3 then v = v.Unit * (r - 3) end
            n += 1
            local d = radar.dots[n]
            if not d then
                d = Drawing.new("Circle")
                d.NumSides, d.Radius, d.Filled, d.Visible = 10, 3, true, false
                radar.dots[n] = d
                draws[#draws + 1] = d
            end
            d.Position = c + v
            d.Color = e.color
            d.Visible = true
        end
        for i = n + 1, #radar.dots do radar.dots[i].Visible = false end
    end

    local alertActive, alertInfo = false, ""

    local function renderDeath()
        if C.Death then initHud() end
        if not hudReady then return end
        if C.Death and X.DeathPos then
            local v, on = Camera:WorldToViewportPoint(X.DeathPos)
            if on and v.Z > 0 then
                local mr = myRoot()
                local d = mr and (mr.Position - X.DeathPos).Magnitude or 0
                local age = now() - (X.DeathT or now())
                deathTxt.Text = string.format("死亡地点  %.0fm  %d:%02d", d, math.floor(age / 60), math.floor(age % 60))
                deathTxt.Color = Color3.fromRGB(255, 120, 120)
                deathTxt.Position = Vector2.new(v.X, v.Y - 16)
                deathDot.Position, deathDot.Color = Vector2.new(v.X, v.Y), Color3.fromRGB(255, 80, 80)
                deathTxt.Visible, deathDot.Visible = true, true
                return
            end
        end
        deathTxt.Visible, deathDot.Visible = false, false
    end

    local function renderAlert()
        if alertActive then initHud() end
        if not hudReady then return end
        if alertActive then
            local vp = Camera.ViewportSize
            local pulse = 0.4 + 0.35 * math.sin(now() * 8)
            alertSq.Position, alertSq.Size, alertSq.Transparency = Vector2.new(3, 3), vp - Vector2.new(6, 6), pulse
            alertTxt.Position, alertTxt.Text = Vector2.new(vp.X / 2, 70), alertInfo
            alertSq.Visible, alertTxt.Visible = true, true
        else
            alertSq.Visible, alertTxt.Visible = false, false
        end
    end

    RunService:BindToRenderStep("RW_MX_STEP", Enum.RenderPriority.Camera.Value + 4, function()
        Camera = Workspace.CurrentCamera
        if not Camera then return end
        guard("held", renderHeld)

        if C.PromptESP then
            guard("promptesp", drawList, promptPool, lists.prompts, C.PromptColor, function(e)
                return string.format("%s  %.0fm", promptLabel(e.p), e.dist)
            end)
        else
            hidePool(promptPool)
        end
        if C.LootESP then
            guard("lootesp", drawList, lootPool, lists.loot, C.LootColor, function(e)
                return string.format("%s  %.0fm", e.name, e.dist)
            end)
        else
            hidePool(lootPool)
        end
        if C.CarESP then
            guard("caresp", drawList, carPool, lists.cars, C.CarColor, function(e)
                return string.format("%s  %.0fm%s%s%s", e.name, e.dist, e.mine and " (你的)" or "", e.occ and " (已占用)" or "", e.locked and " (已锁定)" or "")
            end)
        else
            hidePool(carPool)
        end

        local players
        if C.Arrows or C.Radar then players = collect() end
        guard("arrows", renderArrows, players or {})
        guard("radar", renderRadar, players or {})
        guard("death", renderDeath)
        guard("alert", renderAlert)
    end)

    local lastSlow, lastMid, lastPing, lastHeldPoll = 0, 0, 0, 0
    local snd
    track(RunService.Heartbeat:Connect(function(dt)
        guard("fly", stepFly, dt)
        guard("car", stepCar)
        local t = now()

        if t - lastMid >= 0.25 then
            lastMid = t
            if C.AutoFarm or C.AutoLoot or C.Route or C.PromptESP or C.LootESP or C.CarESP or C.Tuner then ensureCaches() end
            guard("grade", gradeStep)
            guard("tuner", tuneStep)
            guard("hitbox", hitStep)
            guard("gun", gunStep)

            if C.Spectate then
                specWas = true
                if not specTarget then X.SpectateStep(1) end
                applySpectate()
            elseif specWas then
                specWas = false
                stopSpectate()
            end

            local ch = LP.Character
            local tool = ch and ch:FindFirstChildOfClass("Tool")
            if tool then lastTool = tool.Name end

            if C.Alert then
                local count, nearest = 0, math.huge
                local rp = myRoot()
                if rp then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if X.IsEnemy(p) then
                            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                            if r and h and h.Health > 0 then
                                local d = (r.Position - rp.Position).Magnitude
                                if d <= C.AlertRadius then
                                    count += 1
                                    nearest = math.min(nearest, d)
                                end
                            end
                        end
                    end
                end
                alertActive = count >= math.max(C.AlertMin, 1)
                alertInfo = string.format("敌人 x%d   %.0fm", count, nearest == math.huge and 0 or nearest)
                if alertActive and C.AlertSound and t - lastPing > 1.8 then
                    lastPing = t
                    pcall(function()
                        if not snd then
                            snd = Instance.new("Sound")
                            snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                            snd.Volume = 0.5
                            snd.Parent = SoundService
                        end
                        snd:Play()
                    end)
                end
            else
                alertActive = false
            end
        end

        if t - lastHeldPoll >= 0.6 then
            lastHeldPoll = t
            if C.Logger then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then
                        local n = X.HeldName(p)
                        if n then lastHeld[p] = n end
                    end
                end
            end
        end

        if t - lastSlow >= 0.5 then
            lastSlow = t
            if C.PromptESP then guard("plist", refreshPrompts) end
            if C.LootESP or C.AutoLoot then guard("llist", refreshLoot) end
            if C.CarESP then guard("clist", refreshCars) end
        end
    end))

    function X.Unload()
        alive = false
        pcall(function() RunService:UnbindFromRenderStep("RW_MX_STEP") end)
        pcall(function() RunService:UnbindFromRenderStep("RW_MX_AIM") end)
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        for p in pairs(nc) do
            if p.Parent then p.CanCollide = true end
        end
        pcall(untuneAll)
        pcall(restoreHit)
        pcall(restoreGun)
        pcall(function() if gradeFx then gradeFx:Destroy() end end)
        pcall(function() if snd then snd:Destroy() end end)
        pcall(function()
            local _, hum = myRoot()
            if hum and flyWas then hum.PlatformStand = false end
            if specWas then stopSpectate() end
        end)
        for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
        if genv.RW_MX == X then genv.RW_MX = nil end
    end

    MX = X
    genv.RW_MX = X
end

function unloadAll()
    if MX then pcall(MX.Unload) end
    pcall(EX.Unload)
    pcall(AIM.Unload)
    pcall(ESP.Unload)
    if UILib then pcall(UILib.Unload, UILib) end
    genv.RW_GUI = nil
end

-- ==================== WindUI 界面 ====================
do
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()

    local function Notify(title, content, duration)
        WindUI:Notify({Title = title, Content = content, Duration = duration or 3, Icon = "bell"})
    end

    local EC, AC, XC = ESP.Config, AIM.Config, EX.Config
    local MXC = MX.Config

    local Window = WindUI:CreateWindow({
        Title = 'XNHUB | 刀刃球',
        Icon = "crown",
        IconThemed = true,
        Author = "by XN",
        Folder = "XNHUB",
        Size = UDim2.fromOffset(340, 480),
        Transparent = true,
        Theme = "Midnight",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        Background = "https://raw.githubusercontent.com/SQ182/y/c55acfcf047f4ac75d72fad5a39000c020afd024/image_download_1769957292011.jpg",
        BackgroundImageTransparency = 0.5,
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({Title = "XNHUB", Content = "刀刃球整合版已加载", Duration = 2, Icon = "check"})
            end,
            Anonymous = false
        },
        SideBarWidth = 220,
        Search = {
            Enabled = true,
            Placeholder = "搜索功能...",
            Callback = function(searchText)
                print("搜索:", searchText)
            end
        },
    })

    Window:Tag({
        Title = "刀刃球",
        Icon = "skull",
        IconColor = Color3.fromHex("#FF1493"),
        Color = Color3.fromHex("#1C1C1C"),
        Border = true,
        BorderColor = Color3.fromHex("#FF1493"),
        IconShape = "Square"
    })

    Window:EditOpenButton({
        Title = "XNHUB",
        Icon = "gem",
        CornerRadius = UDim.new(0, 16),
        Size = UDim2.new(0, 140, 0, 48),
        StrokeThickness = 3,
        StrokeColor = Color3.fromRGB(0, 50, 255),
        Color = ColorSequence.new(
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(240, 240, 255),
            Color3.fromRGB(0, 30, 200),
            Color3.fromRGB(0, 10, 150)
        ),
        BackgroundColor = Color3.fromRGB(0, 15, 60),
        BackgroundTransparency = 0.1,
        Draggable = true,
    })

    local buttonFrame = Window.OpenButtonMain.Button
    local stroke = buttonFrame:FindFirstChild("UIStroke")
    if stroke then
        local gradient = stroke:FindFirstChildOfClass("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new(
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(0, 30, 200),
                Color3.fromRGB(0, 10, 150),
                Color3.fromRGB(255, 255, 255)
            )
            RunService.RenderStepped:Connect(function(deltaTime)
                gradient.Rotation = (gradient.Rotation + 60 * deltaTime) % 360
            end)
        end
    end

    -- ==================== 战斗标签页 ====================
    local TabCombat = Window:Tab({ Title = "战斗", Icon = "crosshair" })

    TabCombat:Section({ Title = "自瞄辅助" })

    TabCombat:Toggle({
        Title = "启用自瞄",
        Desc = "按住瞄准键时自动锁定目标",
        Default = false,
        Callback = function(v) AC.Aimbot = v end
    })

    TabCombat:Dropdown({
        Title = "瞄准按键",
        Values = {"右键", "左键", "Shift", "E", "Q", "始终"},
        Default = "右键",
        Callback = function(v)
            local map = {["右键"]="RMB", ["左键"]="LMB", ["Shift"]="Shift", ["E"]="E", ["Q"]="Q", ["始终"]="Always"}
            AC.AimKey = map[v] or "RMB"
        end
    })

    TabCombat:Dropdown({
        Title = "瞄准部位",
        Values = {"头部", "躯干", "最近部位"},
        Default = "头部",
        Callback = function(v)
            local map = {["头部"]="Head", ["躯干"]="Torso", ["最近部位"]="Closest"}
            AC.AimPart = map[v] or "Head"
        end
    })

    TabCombat:Slider({
        Title = "平滑度",
        Desc = "1 = 瞬间锁定, 100 = 缓慢跟随",
        Min = 1, Max = 100, Default = 35,
        Callback = function(v) AC.Smoothness = v end
    })

    TabCombat:Slider({
        Title = "自瞄FOV",
        Min = 20, Max = 600, Default = 160,
        Callback = function(v) AC.AimFOV = v end
    })

    TabCombat:Toggle({
        Title = "显示自瞄FOV",
        Default = false,
        Callback = function(v) AC.ShowAimFOV = v end
    })

    TabCombat:Toggle({
        Title = "目标锁定",
        Desc = "锁定一个目标直到死亡或松开按键",
        Default = false,
        Callback = function(v) AC.TargetLock = v end
    })

    TabCombat:Slider({
        Title = "预判系数",
        Min = 0, Max = 0.3, Default = 0,
        Callback = function(v) AC.Prediction = v end
    })

    TabCombat:Section({ Title = "静默瞄准" })

    TabCombat:Toggle({
        Title = "启用静默瞄准",
        Desc = "重定向射线和鼠标查询到目标",
        Default = false,
        Callback = function(v) AC.Silent = v end
    })

    TabCombat:Slider({
        Title = "静默FOV",
        Min = 20, Max = 800, Default = 200,
        Callback = function(v) AC.SilentFOV = v end
    })

    TabCombat:Slider({
        Title = "命中率",
        Min = 1, Max = 100, Default = 100,
        Callback = function(v) AC.HitChance = v end
    })

    TabCombat:Dropdown({
        Title = "命中部位",
        Values = {"头部", "躯干", "最近部位", "随机"},
        Default = "头部",
        Callback = function(v)
            local map = {["头部"]="Head", ["躯干"]="Torso", ["最近部位"]="Closest", ["随机"]="Random"}
            AC.SilentPart = map[v] or "Head"
        end
    })

    TabCombat:Toggle({
        Title = "显示静默FOV",
        Default = false,
        Callback = function(v) AC.ShowSilentFOV = v end
    })

    TabCombat:Toggle({
        Title = "鼠标欺骗",
        Desc = "同时重定向相机射线和鼠标位置",
        Default = true,
        Callback = function(v) AC.MouseSpoof = v end
    })

    TabCombat:Toggle({
        Title = "远程欺骗",
        Desc = "重写通过远程发送的瞄准位置",
        Default = true,
        Callback = function(v) AC.RemoteSpoof = v end
    })

    TabCombat:Section({ Title = "目标过滤" })

    TabCombat:Toggle({
        Title = "队伍检查",
        Default = true,
        Callback = function(v) AC.TeamCheck = v end
    })

    TabCombat:Toggle({
        Title = "墙体检查",
        Default = true,
        Callback = function(v) AC.WallCheck = v end
    })

    TabCombat:Dropdown({
        Title = "优先目标",
        Values = {"准星最近", "血量最低", "距离最近"},
        Default = "准星最近",
        Callback = function(v)
            local map = {["准星最近"]="Crosshair", ["血量最低"]="Lowest HP", ["距离最近"]="Closest"}
            AC.Priority = map[v] or "Crosshair"
        end
    })

    TabCombat:Slider({
        Title = "最大距离",
        Min = 100, Max = 3000, Default = 2000,
        Callback = function(v) AC.MaxDistance = v end
    })

    TabCombat:Section({ Title = "扳机bot" })

    TabCombat:Toggle({
        Title = "启用扳机bot",
        Desc = "准星对准目标时自动开火",
        Default = false,
        Callback = function(v) XC.Trigger = v end
    })

    TabCombat:Slider({
        Title = "延迟 (毫秒)",
        Min = 0, Max = 300, Default = 60,
        Callback = function(v) XC.TriggerDelay = v end
    })

    TabCombat:Toggle({
        Title = "队伍检查",
        Default = true,
        Callback = function(v) XC.TriggerTeamCheck = v end
    })

    TabCombat:Section({ Title = "后坐力" })

    TabCombat:Toggle({
        Title = "无后坐力",
        Desc = "抵消你没有自己拉的上扬",
        Default = false,
        Callback = function(v) XC.NoRecoil = v end
    })

    TabCombat:Slider({
        Title = "抵消强度",
        Min = 10, Max = 100, Default = 85,
        Callback = function(v) XC.RecoilStrength = v end
    })

    TabCombat:Section({ Title = "命中框" })

    TabCombat:Toggle({
        Title = "命中框放大",
        Desc = "放大敌人命中框（仅本地）",
        Default = false,
        Callback = function(v) MXC.Hitbox = v end
    })

    TabCombat:Slider({
        Title = "大小",
        Min = 2, Max = 25, Default = 8,
        Callback = function(v) MXC.HitboxSize = v end
    })

    TabCombat:Dropdown({
        Title = "部位",
        Values = {"躯干", "头部"},
        Default = "躯干",
        Callback = function(v)
            MXC.HitboxPart = v == "头部" and "Head" or "Root"
        end
    })

    TabCombat:Slider({
        Title = "透明度",
        Min = 0, Max = 1, Default = 0.7,
        Callback = function(v) MXC.HitboxAlpha = v end
    })

    TabCombat:Section({ Title = "枪械修改" })

    TabCombat:Toggle({
        Title = "无扩散/后坐力",
        Default = false,
        Callback = function(v) MXC.GunSpread = v end
    })

    TabCombat:Toggle({
        Title = "瞬间换弹",
        Default = false,
        Callback = function(v) MXC.GunReload = v end
    })

    TabCombat:Toggle({
        Title = "快速射击",
        Default = false,
        Callback = function(v) MXC.GunFire = v end
    })

    TabCombat:Toggle({
        Title = "无限弹药",
        Default = false,
        Callback = function(v) MXC.GunAmmo = v end
    })

    TabCombat:Slider({
        Title = "射速倍率",
        Min = 1, Max = 6, Default = 2,
        Callback = function(v) MXC.GunMult = v end
    })

    TabCombat:Button({
        Title = "重新扫描内存",
        Callback = function()
            if getgc then
                MX.RescanGun()
                Notify("枪械修改", "正在扫描武器表", 2)
            else
                Notify("枪械修改", "当前执行器不支持getgc", 2)
            end
        end
    })

    -- ==================== 透视标签页 ====================
    local TabESP = Window:Tab({ Title = "透视", Icon = "eye" })

    TabESP:Section({ Title = "玩家透视" })

    TabESP:Toggle({
        Title = "启用ESP",
        Default = false,
        Callback = function(v) EC.Enabled = v end
    })

    TabESP:Slider({
        Title = "最大距离",
        Min = 100, Max = 3000, Default = 1500,
        Callback = function(v) EC.MaxDistance = v end
    })

    TabESP:Toggle({
        Title = "方框",
        Default = true,
        Callback = function(v) EC.Box = v end
    })

    TabESP:Toggle({
        Title = "方框填充",
        Default = false,
        Callback = function(v) EC.BoxFill = v end
    })

    TabESP:Toggle({
        Title = "名字",
        Default = true,
        Callback = function(v) EC.Name = v end
    })

    TabESP:Toggle({
        Title = "血量",
        Default = true,
        Callback = function(v) EC.Health = v end
    })

    TabESP:Toggle({
        Title = "距离",
        Default = true,
        Callback = function(v) EC.Distance = v end
    })

    TabESP:Toggle({
        Title = "追踪线",
        Default = false,
        Callback = function(v) EC.Tracer = v end
    })

    TabESP:Dropdown({
        Title = "追踪线起点",
        Values = {"底部", "中心", "顶部", "鼠标"},
        Default = "底部",
        Callback = function(v)
            local map = {["底部"]="Bottom", ["中心"]="Center", ["顶部"]="Top", ["鼠标"]="Mouse"}
            EC.TracerOrigin = map[v] or "Bottom"
        end
    })

    TabESP:Toggle({
        Title = "头部圆点",
        Default = false,
        Callback = function(v) EC.HeadDot = v end
    })

    TabESP:Toggle({
        Title = "骨骼",
        Default = false,
        Callback = function(v) EC.Skeleton = v end
    })

    TabESP:Toggle({
        Title = "高亮填充",
        Default = false,
        Callback = function(v) EC.Chams = v end
    })

    TabESP:Section({ Title = "过滤与颜色" })

    TabESP:Toggle({
        Title = "队伍检查",
        Default = true,
        Callback = function(v) EC.TeamCheck = v end
    })

    TabESP:Toggle({
        Title = "可见性检查",
        Default = false,
        Callback = function(v) EC.VisibleCheck = v end
    })

    TabESP:Toggle({
        Title = "彩虹色",
        Default = false,
        Callback = function(v) EC.Rainbow = v end
    })

    TabESP:ColorPicker({
        Title = "可见颜色",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(v) EC.VisibleColor = v end
    })

    TabESP:ColorPicker({
        Title = "隐藏颜色",
        Default = Color3.fromRGB(255, 40, 40),
        Callback = function(v) EC.HiddenColor = v end
    })

    TabESP:ColorPicker({
        Title = "队伍颜色",
        Default = Color3.fromRGB(120, 120, 120),
        Callback = function(v) EC.TeamColor = v end
    })

    TabESP:Section({ Title = "其他透视" })

    TabESP:Toggle({
        Title = "手持武器透视",
        Desc = "显示每个玩家持有的武器",
        Default = false,
        Callback = function(v) MXC.Held = v end
    })

    TabESP:Toggle({
        Title = "显示空手",
        Default = false,
        Callback = function(v) MXC.HeldUnarmed = v end
    })

    TabESP:Slider({
        Title = "武器文字大小",
        Min = 9, Max = 20, Default = 12,
        Callback = function(v) MXC.HeldSize = v end
    })

    TabESP:Slider({
        Title = "武器透视距离",
        Min = 100, Max = 3000, Default = 1500,
        Callback = function(v) MXC.HeldMax = v end
    })

    TabESP:ColorPicker({
        Title = "武器颜色",
        Default = Color3.fromRGB(255, 220, 120),
        Callback = function(v) MXC.HeldColor = v end
    })

    TabESP:Toggle({
        Title = "战利品透视",
        Desc = "标记掉落的武器和战利品",
        Default = false,
        Callback = function(v) MXC.LootESP = v end
    })

    TabESP:Slider({
        Title = "战利品距离",
        Min = 50, Max = 2000, Default = 900,
        Callback = function(v) MXC.LootMax = v end
    })

    TabESP:ColorPicker({
        Title = "战利品颜色",
        Default = Color3.fromRGB(120, 255, 160),
        Callback = function(v) MXC.LootColor = v end
    })

    TabESP:Toggle({
        Title = "交互提示透视",
        Desc = "标记附近的交互提示，农场点位显示绿色",
        Default = false,
        Callback = function(v) MXC.PromptESP = v end
    })

    TabESP:Slider({
        Title = "提示距离",
        Min = 20, Max = 500, Default = 120,
        Callback = function(v) MXC.PromptMax = v end
    })

    TabESP:ColorPicker({
        Title = "提示颜色",
        Default = Color3.fromRGB(120, 200, 255),
        Callback = function(v) MXC.PromptColor = v end
    })

    TabESP:Toggle({
        Title = "车辆透视",
        Desc = "标记车辆，绿色=你的，红色=已占用，黄色=已锁定",
        Default = false,
        Callback = function(v) MXC.CarESP = v end
    })

    TabESP:Slider({
        Title = "车辆距离",
        Min = 100, Max = 3000, Default = 1200,
        Callback = function(v) MXC.CarMax = v end
    })

    TabESP:ColorPicker({
        Title = "车辆颜色",
        Default = Color3.fromRGB(255, 170, 60),
        Callback = function(v) MXC.CarColor = v end
    })

    TabESP:Toggle({
        Title = "屏幕外箭头",
        Desc = "在屏幕边缘显示指向敌人的箭头",
        Default = false,
        Callback = function(v) MXC.Arrows = v end
    })

    TabESP:Slider({
        Title = "箭头半径",
        Min = 80, Max = 400, Default = 200,
        Callback = function(v) MXC.ArrowRadius = v end
    })

    TabESP:Slider({
        Title = "箭头大小",
        Min = 8, Max = 30, Default = 14,
        Callback = function(v) MXC.ArrowSize = v end
    })

    TabESP:Slider({
        Title = "箭头距离",
        Min = 100, Max = 3000, Default = 1200,
        Callback = function(v) MXC.ArrowMax = v end
    })

    TabESP:ColorPicker({
        Title = "箭头颜色",
        Default = Color3.fromRGB(255, 70, 70),
        Callback = function(v) MXC.ArrowColor = v end
    })

    TabESP:Toggle({
        Title = "雷达",
        Desc = "俯视雷达，敌人红色，队友绿色",
        Default = false,
        Callback = function(v) MXC.Radar = v end
    })

    TabESP:Slider({
        Title = "雷达大小",
        Min = 60, Max = 180, Default = 100,
        Callback = function(v) MXC.RadarSize = v end
    })

    TabESP:Slider({
        Title = "雷达范围",
        Min = 50, Max = 600, Default = 180,
        Callback = function(v) MXC.RadarRange = v end
    })

    TabESP:Toggle({
        Title = "死亡标记",
        Desc = "标记你上次死亡的位置",
        Default = false,
        Callback = function(v) MXC.Death = v end
    })

    TabESP:Button({
        Title = "前往死亡地点",
        Callback = function() MX.GoTo("death") end
    })

    -- ==================== 移动标签页 ====================
    local TabMove = Window:Tab({ Title = "移动", Icon = "zap" })

    TabMove:Section({ Title = "移动速度" })

    TabMove:Toggle({
        Title = "启用加速",
        Default = false,
        Callback = function(v) AC.Walk = v end
    })

    TabMove:Slider({
        Title = "速度",
        Min = 16, Max = 200, Default = 32,
        Callback = function(v) AC.WalkSpeed = v end
    })

    TabMove:Dropdown({
        Title = "模式",
        Values = {"属性修改", "CFrame"},
        Default = "属性修改",
        Callback = function(v)
            AC.WalkMode = v == "CFrame" and "CFrame" or "Property"
        end
    })

    TabMove:Section({ Title = "飞行与跳跃" })

    TabMove:Toggle({
        Title = "启用飞行",
        Desc = "WASD移动，空格上升，左Ctrl下降",
        Default = false,
        Callback = function(v) MXC.Fly = v end
    })

    TabMove:Slider({
        Title = "飞行速度",
        Min = 10, Max = 200, Default = 70,
        Callback = function(v) MXC.FlySpeed = v end
    })

    TabMove:Toggle({
        Title = "无限跳跃",
        Default = false,
        Callback = function(v) XC.InfJump = v end
    })

    TabMove:Toggle({
        Title = "穿墙",
        Default = false,
        Callback = function(v) XC.Noclip = v end
    })

    TabMove:Section({ Title = "载具" })

    TabMove:Toggle({
        Title = "载具加速",
        Desc = "按住W时推动载具超过正常速度",
        Default = false,
        Callback = function(v) MXC.CarSpeed = v end
    })

    TabMove:Slider({
        Title = "载具速度",
        Min = 30, Max = 250, Default = 90,
        Callback = function(v) MXC.CarSpeedValue = v end
    })

    TabMove:Toggle({
        Title = "防翻车",
        Default = false,
        Callback = function(v) MXC.CarNoFlip = v end
    })

    TabMove:Button({
        Title = "传送到最近空闲车辆",
        Callback = function() MX.TpCar() end
    })

    TabMove:Section({ Title = "交互" })

    TabMove:Toggle({
        Title = "交互提示调谐",
        Desc = "让所有提示立即完成并延长范围",
        Default = false,
        Callback = function(v) MXC.Tuner = v end
    })

    TabMove:Toggle({
        Title = "立即完成",
        Default = true,
        Callback = function(v) MXC.TunerInstant = v end
    })

    TabMove:Toggle({
        Title = "忽略视线",
        Default = true,
        Callback = function(v) MXC.TunerLOS = v end
    })

    TabMove:Slider({
        Title = "范围倍率",
        Min = 1, Max = 6, Default = 2,
        Callback = function(v) MXC.TunerRange = v end
    })

    -- ==================== 农场标签页 ====================
    local TabFarm = Window:Tab({ Title = "农场", Icon = "sprout" })

    TabFarm:Section({ Title = "自动农场" })

    TabFarm:Toggle({
        Title = "启用自动农场",
        Desc = "自动走到农场提示和NPC，交互并重复",
        Default = false,
        Callback = function(v) MXC.AutoFarm = v end
    })

    TabFarm:Dropdown({
        Title = "模式",
        Values = {"提示", "NPC", "两者"},
        Default = "提示",
        Callback = function(v)
            local map = {["提示"]="Prompts", ["NPC"]="NPCs", ["两者"]="Both"}
            MXC.FarmMode = map[v] or "Prompts"
        end
    })

    TabFarm:Toggle({
        Title = "匹配任意提示",
        Default = false,
        Callback = function(v) MXC.FarmAny = v end
    })

    TabFarm:Slider({
        Title = "搜索范围",
        Min = 30, Max = 1500, Default = 250,
        Callback = function(v) MXC.FarmRange = v end
    })

    TabFarm:Dropdown({
        Title = "移动方式",
        Values = {"补间", "传送", "步行"},
        Default = "补间",
        Callback = function(v)
            local map = {["补间"]="Tween", ["传送"]="Teleport", ["步行"]="Walk"}
            MXC.FarmMove = map[v] or "Tween"
        end
    })

    TabFarm:Slider({
        Title = "移动速度",
        Min = 20, Max = 200, Default = 70,
        Callback = function(v) MXC.FarmSpeed = v end
    })

    TabFarm:Slider({
        Title = "动作延迟",
        Min = 0, Max = 2, Default = 0.25,
        Callback = function(v) MXC.FarmDelay = v end
    })

    TabFarm:Slider({
        Title = "提示冷却",
        Min = 0, Max = 30, Default = 4,
        Callback = function(v) MXC.PromptCooldown = v end
    })

    TabFarm:Toggle({
        Title = "农场时穿墙",
        Default = true,
        Callback = function(v) MXC.FarmNoclip = v end
    })

    TabFarm:Toggle({
        Title = "敌人靠近时暂停",
        Default = true,
        Callback = function(v) MXC.FarmSafe = v end
    })

    TabFarm:Slider({
        Title = "暂停半径",
        Min = 10, Max = 200, Default = 60,
        Callback = function(v) MXC.SafeRadius = v end
    })

    TabFarm:Section({ Title = "NPC设置" })

    TabFarm:TextBox({
        Title = "NPC名称过滤",
        Placeholder = "留空 = 任意NPC",
        Default = "",
        Callback = function(v)
            local t = {}
            for s in string.gmatch(v, "([^,]+)") do
                t[#t + 1] = s:gsub("^%s+", ""):gsub("%s+$", "")
            end
            MXC.NpcWords = t
        end
    })

    TabFarm:TextBox({
        Title = "NPC工具",
        Placeholder = "工具名称",
        Default = "",
        Callback = function(v) MXC.NpcTool = v end
    })

    TabFarm:Slider({
        Title = "NPC距离",
        Min = 3, Max = 25, Default = 7,
        Callback = function(v) MXC.NpcStandoff = v end
    })

    TabFarm:Slider({
        Title = "NPC超时",
        Min = 3, Max = 40, Default = 12,
        Callback = function(v) MXC.NpcTimeout = v end
    })

    TabFarm:Section({ Title = "自动拾取" })

    TabFarm:Toggle({
        Title = "启用自动拾取",
        Desc = "收集掉落的武器和战利品",
        Default = false,
        Callback = function(v) MXC.AutoLoot = v end
    })

    TabFarm:Slider({
        Title = "拾取范围",
        Min = 20, Max = 600, Default = 120,
        Callback = function(v) MXC.AutoLootRange = v end
    })

    TabFarm:Section({ Title = "农场路线" })

    TabFarm:Toggle({
        Title = "启用路线",
        Desc = "沿保存的点位循环并触发农场提示",
        Default = false,
        Callback = function(v) MXC.Route = v end
    })

    TabFarm:Slider({
        Title = "触发半径",
        Min = 3, Max = 60, Default = 12,
        Callback = function(v) MXC.RouteRadius = v end
    })

    TabFarm:Slider({
        Title = "停留时间",
        Min = 0, Max = 5, Default = 0.8,
        Callback = function(v) MXC.RouteDwell = v end
    })

    TabFarm:Toggle({
        Title = "循环路线",
        Default = true,
        Callback = function(v) MXC.RouteLoop = v end
    })

    TabFarm:Toggle({
        Title = "触发任意提示",
        Default = false,
        Callback = function(v) MXC.RouteAny = v end
    })

    TabFarm:Button({
        Title = "添加当前位置为路径点",
        Callback = function()
            local pt = MX.FormatPoint("点位" .. (#MXC.RoutePoints + 1))
            if pt then
                local t = {}
                for i, v in ipairs(MXC.RoutePoints) do t[i] = v end
                t[#t + 1] = pt
                MXC.RoutePoints = t
                Notify("农场路线", "已添加路径点 #" .. #t, 2)
            end
        end
    })

    TabFarm:Button({
        Title = "清空路径点",
        Callback = function()
            MXC.RoutePoints = {}
            Notify("农场路线", "已清空", 2)
        end
    })

    TabFarm:Section({ Title = "金钱追踪" })

    TabFarm:Toggle({
        Title = "启用金钱追踪",
        Desc = "读取金钱属性并显示每分钟收益",
        Default = false,
        Callback = function(v) MXC.Cash = v end
    })

    TabFarm:TextBox({
        Title = "属性名",
        Placeholder = "自动检测",
        Default = "",
        Callback = function(v)
            MXC.CashStat = v
            MX.CashReset()
        end
    })

    TabFarm:Button({
        Title = "重置计数器",
        Callback = function() MX.CashReset() end
    })

    -- ==================== 世界标签页 ====================
    local TabWorld = Window:Tab({ Title = "世界", Icon = "globe" })

    TabWorld:Section({ Title = "视觉" })

    TabWorld:Toggle({
        Title = "全亮",
        Desc = "强制明亮无雾光照",
        Default = false,
        Callback = function(v) XC.Fullbright = v end
    })

    TabWorld:Toggle({
        Title = "FOV修改",
        Default = false,
        Callback = function(v) XC.FovOverride = v end
    })

    TabWorld:Slider({
        Title = "视野角度",
        Min = 30, Max = 120, Default = 70,
        Callback = function(v) XC.FovValue = v end
    })

    TabWorld:Toggle({
        Title = "颜色分级",
        Desc = "调整饱和度、对比度和色调",
        Default = false,
        Callback = function(v) MXC.Grade = v end
    })

    TabWorld:Slider({
        Title = "饱和度",
        Min = -1, Max = 3, Default = 0.6,
        Callback = function(v) MXC.Saturation = v end
    })

    TabWorld:Slider({
        Title = "对比度",
        Min = -0.5, Max = 1, Default = 0.05,
        Callback = function(v) MXC.Contrast = v end
    })

    TabWorld:ColorPicker({
        Title = "色调",
        Default = Color3.new(1, 1, 1),
        Callback = function(v) MXC.Tint = v end
    })

    TabWorld:Section({ Title = "准星" })

    TabWorld:Toggle({
        Title = "自定义准星",
        Default = false,
        Callback = function(v) XC.Crosshair = v end
    })

    TabWorld:Slider({
        Title = "大小",
        Min = 2, Max = 30, Default = 8,
        Callback = function(v) XC.CrosshairSize = v end
    })

    TabWorld:Slider({
        Title = "间隙",
        Min = 0, Max = 20, Default = 4,
        Callback = function(v) XC.CrosshairGap = v end
    })

    TabWorld:Dropdown({
        Title = "颜色",
        Values = {"红色", "白色", "青色", "绿色", "黄色"},
        Default = "红色",
        Callback = function(v)
            local map = {["红色"]="Red", ["白色"]="White", ["青色"]="Cyan", ["绿色"]="Green", ["黄色"]="Yellow"}
            XC.CrosshairColor = map[v] or "Red"
        end
    })

    TabWorld:Toggle({
        Title = "中心点",
        Default = true,
        Callback = function(v) XC.CrosshairDot = v end
    })

    TabWorld:Section({ Title = "武器皮肤" })

    local skinSel = "Neon Red"
    local skinList = {"Neon Red", "Gold", "Ice", "Galaxy", "Void", "Rainbow"}
    local skinEnabled = false

    TabWorld:Toggle({
        Title = "启用武器皮肤",
        Desc = "本地武器换色",
        Default = false,
        Callback = function(v)
            skinEnabled = v
            XC.Skin = v and skinSel or "Off"
        end
    })

    TabWorld:Dropdown({
        Title = "皮肤",
        Values = skinList,
        Default = "Neon Red",
        Callback = function(v)
            skinSel = v
            if skinEnabled then XC.Skin = v end
        end
    })

    TabWorld:Section({ Title = "路径点" })

    TabWorld:TextBox({
        Title = "前往路径点",
        Placeholder = "输入名称或 death",
        Default = "",
        Callback = function(v)
            if v ~= "" then MX.GoTo(v) end
        end
    })

    TabWorld:Button({
        Title = "保存当前位置",
        Callback = function()
            local pt = MX.FormatPoint("点位" .. (#MXC.Waypoints + 1))
            if pt then
                local t = {}
                for i, v in ipairs(MXC.Waypoints) do t[i] = v end
                t[#t + 1] = pt
                MXC.Waypoints = t
                Notify("路径点", "已保存 #" .. #t, 2)
            end
        end
    })

    TabWorld:Dropdown({
        Title = "移动方式",
        Values = {"补间", "传送", "步行"},
        Default = "补间",
        Callback = function(v)
            local map = {["补间"]="Tween", ["传送"]="Teleport", ["步行"]="Walk"}
            MXC.WpMode = map[v] or "Tween"
        end
    })

    TabWorld:Slider({
        Title = "速度",
        Min = 30, Max = 300, Default = 120,
        Callback = function(v) MXC.WpSpeed = v end
    })

    TabWorld:Section({ Title = "观战" })

    TabWorld:Toggle({
        Title = "启用观战",
        Default = false,
        Callback = function(v) MXC.Spectate = v end
    })

    TabWorld:TextBox({
        Title = "玩家名称",
        Placeholder = "输入名字",
        Default = "",
        Callback = function(v)
            if v ~= "" then MX.SpectateFind(v) end
        end
    })

    TabWorld:Button({
        Title = "下一个玩家",
        Callback = function() MX.SpectateStep(1) end
    })

    TabWorld:Button({
        Title = "上一个玩家",
        Callback = function() MX.SpectateStep(-1) end
    })

    TabWorld:Section({ Title = "服务器" })

    local hopMode = "低人数"
    TabWorld:Dropdown({
        Title = "跳转目标",
        Values = {"低人数", "随机", "高人数"},
        Default = "低人数",
        Callback = function(v) hopMode = v end
    })

    TabWorld:Button({
        Title = "服务器跳转",
        Callback = function()
            Notify("服务器跳转", "搜索服务器中...", 2)
            local map = {["低人数"]="低人数", ["随机"]="随机", ["高人数"]="高人数"}
            MX.Hop(map[hopMode] or "低人数")
        end
    })

    TabWorld:Button({
        Title = "重新加入",
        Callback = function() MX.Rejoin() end
    })

    -- ==================== 工具标签页 ====================
    local TabTools = Window:Tab({ Title = "工具", Icon = "settings" })

    TabTools:Section({ Title = "自动化" })

    TabTools:Toggle({
        Title = "防挂机",
        Desc = "防止因闲置被踢",
        Default = false,
        Callback = function(v) MXC.AntiAFK = v end
    })

    TabTools:Toggle({
        Title = "自动重新装备",
        Desc = "重生后自动装备上次武器",
        Default = false,
        Callback = function(v) MXC.Reequip = v end
    })

    TabTools:Toggle({
        Title = "自动重生",
        Desc = "死亡后自动点击重生按钮",
        Default = false,
        Callback = function(v) MXC.Respawn = v end
    })

    TabTools:Slider({
        Title = "重生延迟",
        Min = 0, Max = 6, Default = 1.5,
        Callback = function(v) MXC.RespawnDelay = v end
    })

    TabTools:Section({ Title = "警报" })

    TabTools:Toggle({
        Title = "敌人接近警报",
        Desc = "敌人靠近时闪烁屏幕并提示",
        Default = false,
        Callback = function(v) MXC.Alert = v end
    })

    TabTools:Slider({
        Title = "警报半径",
        Min = 20, Max = 300, Default = 80,
        Callback = function(v) MXC.AlertRadius = v end
    })

    TabTools:Slider({
        Title = "最小人数",
        Min = 1, Max = 8, Default = 1,
        Callback = function(v) MXC.AlertMin = v end
    })

    TabTools:Toggle({
        Title = "声音",
        Default = true,
        Callback = function(v) MXC.AlertSound = v end
    })

    TabTools:Section({ Title = "队伍" })

    TabTools:Toggle({
        Title = "队伍白名单",
        Desc = "白名单玩家将被自瞄和命中框跳过",
        Default = false,
        Callback = function(v) MXC.Crew = v end
    })

    TabTools:TextBox({
        Title = "添加玩家",
        Placeholder = "用户名或显示名，逗号分隔",
        Default = "",
        Callback = function(v)
            local t = {}
            for s in string.gmatch(v, "([^,]+)") do
                t[#t + 1] = s:gsub("^%s+", ""):gsub("%s+$", "")
            end
            MXC.CrewList = t
        end
    })

    TabTools:Toggle({
        Title = "在ESP中显示",
        Default = true,
        Callback = function(v) MXC.CrewShow = v end
    })

    TabTools:ColorPicker({
        Title = "队伍颜色",
        Default = Color3.fromRGB(90, 255, 140),
        Callback = function(v) MXC.CrewColor = v end
    })

    TabTools:Section({ Title = "安全区" })

    TabTools:Toggle({
        Title = "安全区过滤",
        Desc = "检测出生保护和安全区",
        Default = false,
        Callback = function(v) MXC.SafeFilter = v end
    })

    TabTools:Toggle({
        Title = "自瞄跳过",
        Default = true,
        Callback = function(v) MXC.SafeSkip = v end
    })

    TabTools:Toggle({
        Title = "ESP标记",
        Default = true,
        Callback = function(v) MXC.SafeTag = v end
    })

    TabTools:Section({ Title = "事件日志" })

    TabTools:Toggle({
        Title = "启用日志",
        Desc = "记录伤害、死亡和附近击杀",
        Default = false,
        Callback = function(v) MXC.Logger = v end
    })

    TabTools:Slider({
        Title = "日志范围",
        Min = 50, Max = 1000, Default = 300,
        Callback = function(v) MXC.LogRange = v end
    })

    TabTools:Button({
        Title = "清空日志",
        Callback = function() MX.ClearLog() end
    })

    TabTools:Section({ Title = "关于" })

    TabTools:Paragraph({
        Title = "XNHUB",
        Desc = "urban"
    })

    TabTools:Button({
        Title = "重置所有功能",
        Desc = "关闭所有激活的功能",
        Callback = function()
            for k in pairs(EC) do
                if type(EC[k]) == "boolean" and k ~= "TeamCheck" and k ~= "VisibleCheck" and k ~= "ToggleKey" and k ~= "UnloadKey" then EC[k] = false end
            end
            EC.Enabled = false; EC.Box = true; EC.Name = true; EC.Health = true; EC.Distance = true
            for k in pairs(AC) do
                if type(AC[k]) == "boolean" and k ~= "TeamCheck" and k ~= "WallCheck" and k ~= "MouseSpoof" and k ~= "RemoteSpoof" then AC[k] = false end
            end
            AC.Aimbot = false; AC.Silent = false; AC.Walk = false
            for k in pairs(XC) do
                if type(XC[k]) == "boolean" and k ~= "TriggerTeamCheck" and k ~= "CrosshairDot" then XC[k] = false end
            end
            XC.Trigger = false; XC.NoRecoil = false; XC.InfJump = false; XC.Noclip = false; XC.Fullbright = false; XC.Crosshair = false; XC.FovOverride = false; XC.Skin = "Off"
            for k in pairs(MXC) do
                if type(MXC[k]) == "boolean" and k ~= "CrewShow" and k ~= "SafeSkip" and k ~= "SafeTag" and k ~= "TunerInstant" and k ~= "TunerLOS" and k ~= "FarmNoclip" and k ~= "FarmSafe" and k ~= "RouteLoop" and k ~= "AlertSound" and k ~= "MouseSpoof" and k ~= "RemoteSpoof" then MXC[k] = false end
            end
            MXC.AutoFarm = false; MXC.AutoLoot = false; MXC.Route = false; MXC.Cash = false
            MXC.Fly = false; MXC.CarSpeed = false; MXC.Tuner = false; MXC.Alert = false
            MXC.Spectate = false; MXC.Logger = false; MXC.Hitbox = false
            MXC.GunSpread = false; MXC.GunReload = false; MXC.GunFire = false; MXC.GunAmmo = false
            MXC.Grade = false; MXC.Held = false; MXC.LootESP = false; MXC.PromptESP = false
            MXC.CarESP = false; MXC.Arrows = false; MXC.Radar = false; MXC.Death = false
            MXC.AntiAFK = false; MXC.Reequip = false; MXC.Respawn = false; MXC.Crew = false; MXC.SafeFilter = false
            Notify("重置", "所有功能已关闭", 3)
        end
    })

    MX.Notify = function(title, msg, kind)
        Notify(title, msg, 2)
    end

    Notify("XNHUB", "刀刃球整合版加载成功！", 3)
    print("[XNHUB] 刀刃球整合版已加载")
end
