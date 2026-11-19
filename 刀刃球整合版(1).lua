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

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()

local function Notify(title, content, duration)
    WindUI:Notify({Title = title, Content = content, Duration = duration or 3, Icon = "bell"})
end

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

local S = {
    Aim = false, HS = 100, FOV = 140, MaxDist = 120, ShowFOV = false, IgnoreTeam = false,
    Silent = false,
    Line = false, Box = false, Skel = false, Health = false, ESPName = false, ESPDist = false,
    ColESP = Color3.fromRGB(232, 38, 54), ColFOV = Color3.fromRGB(232, 38, 54),
    SpeedOn = false, Speed = 30,
    NoSpread = false, BigHead = false, HeadSize = 4,
    NPCAim = false, NPCHead = false, NPCDist = 120, NPCName = "", IgnoreDead = true,
    NPCShowFOV = false, NPCFOV = 160, NPCBox = false, NPCSkel = false, SilentNPC = false,
    InfStamina = false,
    FlyFree = false, FlyFreeSpeed = 40, Noclip = false,
}

local lastErr = nil
local function fail(where, e)
    lastErr = where .. ": " .. tostring(e)
    warn("[FrostHub] " .. lastErr)
end

local conns = {}
local function keep(c) conns[#conns + 1] = c return c end

local DRAW_NAME = "FrostHubESP"

pcall(function()
    local roots = {}
    pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
    pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
    pcall(function() roots[#roots + 1] = LP:FindFirstChild("PlayerGui") end)
    for _, root in ipairs(roots) do
        pcall(function()
            local old = root:FindFirstChild(DRAW_NAME)
            if old then old:Destroy() end
        end)
    end
end)

local EG = Instance.new("ScreenGui")
EG.Name = DRAW_NAME
EG.ResetOnSpawn = false
EG.IgnoreGuiInset = true
EG.DisplayOrder = 50
EG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(EG) end end)
pcall(function() if gethui then EG.Parent = gethui() end end)
if not EG.Parent then pcall(function() EG.Parent = game:GetService("CoreGui") end) end
if not EG.Parent then EG.Parent = LP:WaitForChild("PlayerGui") end

local Draw = {}
function Draw.new(kind)
    local v = {Visible = false, Color = Color3.new(1, 1, 1), Thickness = 1}
    local inst, render

    if kind == "Line" then
        v.From, v.To = Vector2.new(0, 0), Vector2.new(0, 0)
        inst = Instance.new("Frame")
        inst.AnchorPoint = Vector2.new(0.5, 0.5)
        inst.BorderSizePixel = 0
        inst.Visible = false
        inst.Parent = EG
        render = function()
            if not v.Visible then inst.Visible = false return end
            local d = v.To - v.From
            inst.Size = UDim2.fromOffset(d.Magnitude, math.max(v.Thickness, 1))
            inst.Position = UDim2.fromOffset((v.From.X + v.To.X) / 2, (v.From.Y + v.To.Y) / 2)
            inst.Rotation = math.deg(math.atan2(d.Y, d.X))
            inst.BackgroundColor3 = v.Color
            inst.Visible = true
        end
    elseif kind == "Square" then
        v.Position, v.Size, v.Filled = Vector2.new(0, 0), Vector2.new(0, 0), false
        inst = Instance.new("Frame")
        inst.BorderSizePixel = 0
        inst.Visible = false
        inst.Parent = EG
        local st = Instance.new("UIStroke")
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = inst
        render = function()
            if not v.Visible then inst.Visible = false return end
            inst.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
            inst.Size = UDim2.fromOffset(v.Size.X, v.Size.Y)
            inst.BackgroundColor3 = v.Color
            inst.BackgroundTransparency = v.Filled and 0 or 1
            st.Color = v.Color
            st.Thickness = v.Thickness
            st.Enabled = not v.Filled
            inst.Visible = true
        end
    elseif kind == "Circle" then
        v.Position, v.Radius, v.NumSides, v.Filled = Vector2.new(0, 0), 50, 32, false
        inst = Instance.new("Frame")
        inst.AnchorPoint = Vector2.new(0.5, 0.5)
        inst.BorderSizePixel = 0
        inst.Visible = false
        inst.Parent = EG
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(1, 0)
        cr.Parent = inst
        local st = Instance.new("UIStroke")
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = inst
        render = function()
            if not v.Visible then inst.Visible = false return end
            inst.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
            inst.Size = UDim2.fromOffset(v.Radius * 2, v.Radius * 2)
            inst.BackgroundColor3 = v.Color
            inst.BackgroundTransparency = v.Filled and 0.6 or 1
            st.Color = v.Color
            st.Thickness = v.Thickness
            inst.Visible = true
        end
    else
        v.Text, v.Position, v.Size, v.Center, v.Outline = "", Vector2.new(0, 0), 13, false, false
        inst = Instance.new("TextLabel")
        inst.BackgroundTransparency = 1
        inst.BorderSizePixel = 0
        inst.Font = Enum.Font.GothamMedium
        inst.TextWrapped = false
        inst.Visible = false
        inst.Parent = EG
        render = function()
            if not v.Visible then inst.Visible = false return end
            inst.Text = v.Text
            inst.TextSize = v.Size
            inst.TextColor3 = v.Color
            inst.TextStrokeTransparency = v.Outline and 0 or 1
            inst.TextXAlignment = v.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            inst.AnchorPoint = Vector2.new(v.Center and 0.5 or 0, 0)
            inst.Size = UDim2.fromOffset(240, v.Size + 4)
            inst.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
            inst.Visible = true
        end
    end

    return setmetatable({}, {
        __index = function(_, k)
            if k == "Remove" or k == "Destroy" then
                return function() pcall(function() inst:Destroy() end) end
            end
            return v[k]
        end,
        __newindex = function(_, k, val)
            if v[k] ~= val then
                v[k] = val
                render()
            end
        end,
    })
end

local function charOf(p)
    local ch = p.Character
    if ch then return ch end
    local m = WS:FindFirstChild(p.Name)
    if m and m:IsA("Model") then return m end
    return nil
end

local function rootOf(ch)
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso")
        or ch:FindFirstChild("Torso") or ch:FindFirstChild("Head")
end

local function isTeammate(p)
    local a, b = LP.Team, p.Team
    if a and b then return a == b end
    local aa, ba = LP:GetAttribute("Team"), p:GetAttribute("Team")
    if aa ~= nil and ba ~= nil then return aa == ba end
    if not LP.Neutral and not p.Neutral then return LP.TeamColor == p.TeamColor end
    return false
end

local function valid(p)
    if p == LP then return false end
    local ch = charOf(p)
    if not ch or not ch.Parent then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    if not rootOf(ch) then return false end
    if S.IgnoreTeam and isTeammate(p) then return false end
    return true
end

local fov, npcFov
pcall(function()
    fov = Draw.new("Circle")
    fov.Thickness = 1.5
    fov.NumSides = 48
    fov.Filled = false
    fov.Color = S.ColFOV
    fov.Visible = false
end)
pcall(function()
    npcFov = Draw.new("Circle")
    npcFov.Thickness = 1.5
    npcFov.NumSides = 48
    npcFov.Filled = false
    npcFov.Color = S.ColFOV
    npcFov.Visible = false
end)

local lockP, lockHead, lockT = nil, true, 0
local function roll() return math.random(1, 100) <= S.HS end

local function bodyPart(ch, head)
    if head then return ch:FindFirstChild("Head") or rootOf(ch) end
    return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or rootOf(ch)
end

local function screenDist(part, c0)
    local v = Cam:WorldToViewportPoint(part.Position)
    if v.Z <= 0 then return nil end
    return (Vector2.new(v.X, v.Y) - c0).Magnitude
end

local function refPart(ch) return ch:FindFirstChild("Head") or rootOf(ch) end

local function myPos()
    local ch = LP.Character
    local r = ch and rootOf(ch)
    return r and r.Position or Cam.CFrame.Position
end

local function pickTarget(c0)
    local me = myPos()
    if lockP and valid(lockP) then
        local ch = charOf(lockP)
        local ref, r = refPart(ch), rootOf(ch)
        local d = ref and screenDist(ref, c0)
        if d and d <= S.FOV * 1.3 and (r.Position - me).Magnitude <= S.MaxDist * 1.1 then
            return lockP
        end
    end

    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if valid(p) then
            local ch = charOf(p)
            local ref, r = refPart(ch), rootOf(ch)
            local d = ref and screenDist(ref, c0)
            if d and d <= S.FOV then
                local dist = (r.Position - me).Magnitude
                if dist <= S.MaxDist and dist < bestDist then
                    best, bestDist = p, dist
                end
            end
        end
    end
    if best then lockHead, lockT = roll(), os.clock() end
    lockP = best
    return best
end

local AIM_SMOOTH = 14

local function aimAtPoint(point, dt)
    local a = math.clamp(1 - math.exp(-0.8 * AIM_SMOOTH * AIM_SMOOTH * dt), 0, 1)
    local camPos = Cam.CFrame.Position
    local cur = Cam.CFrame.LookVector
    local want = point - camPos
    if want.Magnitude < 0.1 then return end
    want = want.Unit

    local focus = Cam.Focus.Position
    local toFocus = focus - camPos
    local zd = toFocus.Magnitude
    local third = zd > 0.5 and zd < 120 and cur:Dot(toFocus.Unit) > 0.999
    if third then
        for _ = 1, 4 do
            local d2 = point - (focus - want * zd)
            if d2.Magnitude < 0.1 then break end
            want = d2.Unit
        end
    end

    local newLook = want
    if a < 1 then
        local l = cur:Lerp(want, a)
        if l.Magnitude > 1e-3 then newLook = l.Unit end
    end
    local pos = third and (focus - newLook * zd) or camPos
    Cam.CFrame = CFrame.lookAt(pos, pos + newLook)
end

local function aim(dt)
    local p = pickTarget(Cam.ViewportSize / 2)
    if not p then return end
    if os.clock() - lockT > 1.5 then lockHead, lockT = roll(), os.clock() end
    local part = bodyPart(charOf(p), lockHead)
    if not part then return end
    aimAtPoint(part.Position, dt)
end

local npcs = {}

local function regNpc(h)
    local m = h.Parent
    if m and m:IsA("Model") and m ~= LP.Character and not Players:GetPlayerFromCharacter(m) then
        npcs[m] = h
    end
end

task.spawn(function()
    local n = 0
    for _, d in ipairs(WS:GetDescendants()) do
        if d:IsA("Humanoid") then regNpc(d) end
        n = n + 1
        if n % 3000 == 0 then task.wait() end
    end
end)
keep(WS.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then task.defer(regNpc, d) end
end))
keep(WS.DescendantRemoving:Connect(function(d)
    if d:IsA("Humanoid") and d.Parent then npcs[d.Parent] = nil end
end))

local function nameOk(m)
    local f = S.NPCName
    if f == nil or f == "" then return true end
    return string.find(string.lower(m.Name), string.lower(f), 1, true) ~= nil
end

local deadNpc = setmetatable({}, {__mode = "k"})
local corpseCache = setmetatable({}, {__mode = "k"})

local function hasLootPrompt(m)
    local c = corpseCache[m]
    if c and os.clock() < c.t then return c.v end
    local v = false
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local t = string.lower((d.ActionText or "") .. " " .. (d.ObjectText or "") .. " " .. d.Name)
            if string.find(t, "loot", 1, true) or string.find(t, "saque", 1, true) then v = true break end
        end
    end
    corpseCache[m] = {t = os.clock() + 1, v = v}
    return v
end

local function alive(m, h)
    if deadNpc[m] then return false end
    local dead = h.Health <= 0.5
    if not dead then
        local okk, st = pcall(function() return h:GetState() end)
        dead = okk and st == Enum.HumanoidStateType.Dead
    end
    if not dead then
        dead = m:GetAttribute("Dead") == true or m:GetAttribute("IsDead") == true or m:GetAttribute("Died") == true
    end
    if dead then deadNpc[m] = true return false end
    if hasLootPrompt(m) then deadNpc[m] = true return false end
    local r = rootOf(m)
    if r and r.CFrame.UpVector.Y < 0.3 then return false end
    return true
end

local function usable(m, h)
    if S.IgnoreDead then return alive(m, h) end
    return h.Health > 0
end

local function inNpcFov(r)
    if not S.NPCShowFOV then return true end
    local v = Cam:WorldToViewportPoint(r.Position)
    return v.Z > 0 and (Vector2.new(v.X, v.Y) - Cam.ViewportSize / 2).Magnitude <= S.NPCFOV
end

local npcLock
local function pickNpc()
    local me = myPos()
    local best, bd = nil, math.huge
    for m, h in pairs(npcs) do
        if m.Parent and h.Parent then
            if usable(m, h) and nameOk(m) then
                local r = rootOf(m)
                if r then
                    local d = (r.Position - me).Magnitude
                    if d <= S.NPCDist and d < bd and inNpcFov(r) then best, bd = m, d end
                end
            end
        else
            npcs[m] = nil
        end
    end

    if npcLock and npcs[npcLock] and npcLock.Parent and usable(npcLock, npcs[npcLock]) and nameOk(npcLock) then
        local r = rootOf(npcLock)
        if r and (r.Position - me).Magnitude <= bd + 6 and inNpcFov(r) then return npcLock end
    end
    npcLock = best
    return best
end

local function aimNpc(dt)
    local m = pickNpc()
    if not m then return end
    local part = S.NPCHead and m:FindFirstChild("Head") or nil
    part = part or m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso") or rootOf(m)
    if not part then return end
    aimAtPoint(part.Position, dt)
end

local silentPart
local silentHooked, silentAlive = false, true
local sHead, sT = true, 0

local function silentStep()
    silentPart = nil
    if not (S.Silent or S.SilentNPC) then return end
    local c0 = Cam.ViewportSize / 2

    if S.Silent then
        local pl = pickTarget(c0)
        if pl then
            local ch = charOf(pl)
            if os.clock() - sT > 1.5 then sT, sHead = os.clock(), roll() end
            local part = ch and bodyPart(ch, sHead)
            if part and part.Parent then silentPart = part return end
        end
    end

    if S.SilentNPC then
        local m = pickNpc()
        if m then
            local part = (S.NPCHead and m:FindFirstChild("Head")) or m:FindFirstChild("UpperTorso")
                or m:FindFirstChild("Torso") or rootOf(m)
            if part and part.Parent then silentPart = part end
        end
    end
end

local function nearMe(v)
    return (v - Cam.CFrame.Position).Magnitude < 12 or (v - myPos()).Magnitude < 12
end

pcall(function()
    local function hookMeta(name, fn)
        local f = newcclosure and newcclosure(fn) or fn
        if hookmetamethod then return hookmetamethod(game, name, f) end
        local mt = getrawmetatable(game)
        local old = rawget(mt, name)
        if setreadonly then setreadonly(mt, false) elseif make_writeable then make_writeable(mt) end
        rawset(mt, name, f)
        return old
    end

    local function active()
        return silentAlive and silentPart and silentPart.Parent and not (checkcaller and checkcaller())
    end

    local oldNC
    oldNC = hookMeta("__namecall", function(self, ...)
        if active() and self == WS then
            local m = getnamecallmethod()
            local n = select("#", ...)
            local a = {...}
            if m == "Raycast" then
                local o, d = a[1], a[2]
                if typeof(o) == "Vector3" and typeof(d) == "Vector3" and d.Magnitude > 30 and nearMe(o) then
                    a[2] = (silentPart.Position - o).Unit * d.Magnitude
                    return oldNC(self, table.unpack(a, 1, n))
                end
            elseif m == "FindPartOnRay" or m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRayWithWhitelist" then
                local r = a[1]
                if typeof(r) == "Ray" and r.Direction.Magnitude > 30 and nearMe(r.Origin) then
                    a[1] = Ray.new(r.Origin, (silentPart.Position - r.Origin).Unit * r.Direction.Magnitude)
                    return oldNC(self, table.unpack(a, 1, n))
                end
            end
        end
        return oldNC(self, ...)
    end)

    local mouse = LP:GetMouse()
    local oldIdx
    oldIdx = hookMeta("__index", function(self, k)
        if self == mouse and active() then
            if k == "Hit" then return CFrame.new(silentPart.Position) end
            if k == "Target" then return silentPart end
        end
        return oldIdx(self, k)
    end)

    silentHooked = true
end)

local headOrig = {}

local function restoreHead(part)
    local o = headOrig[part]
    if o then
        if part.Parent then
            part.Size, part.Transparency, part.CanCollide = o.Size, o.Transparency, o.CanCollide
        end
        headOrig[part] = nil
    end
end

local function headsStep()
    for part in pairs(headOrig) do
        if not part.Parent then headOrig[part] = nil end
    end

    if not S.BigHead then
        for part in pairs(headOrig) do restoreHead(part) end
        return
    end

    local sz = S.HeadSize
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local ch = charOf(p)
            local head = ch and ch:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                if valid(p) then
                    if not headOrig[head] then
                        headOrig[head] = {Size = head.Size, Transparency = head.Transparency, CanCollide = head.CanCollide}
                    end
                    head.Size = Vector3.new(sz, sz, sz)
                    head.Transparency = 0.6
                    head.CanCollide = false
                else
                    restoreHead(head)
                end
            end
        end
    end
end

local spreadKeys = {"spread", "bloom", "inaccuracy", "deviation", "scatter"}
local function isSpreadName(n)
    if type(n) ~= "string" then return false end
    n = string.lower(n)
    for _, k in ipairs(spreadKeys) do
        if string.find(n, k, 1, true) then return true end
    end
    return false
end

local function zeroOf(v)
    local t = typeof(v)
    if t == "number" then return 0 end
    if t == "Vector3" then return Vector3.zero end
    if t == "Vector2" then return Vector2.zero end
    return nil
end

local spreadInst, spreadTabs = {}, {}
local spreadWasOn, needScan, scanning = false, true, false

local function zeroInst(inst)
    if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and isSpreadName(inst.Name) and inst.Value ~= 0 then
        spreadInst[#spreadInst + 1] = {kind = "val", inst = inst, orig = inst.Value}
        inst.Value = 0
    end
    for name, v in pairs(inst:GetAttributes()) do
        local z = zeroOf(v)
        if isSpreadName(name) and z ~= nil and v ~= z then
            spreadInst[#spreadInst + 1] = {kind = "attr", inst = inst, name = name, orig = v}
            inst:SetAttribute(name, z)
        end
    end
end

local function scanTools()
    local boxes = {LP.Character, LP:FindFirstChildOfClass("Backpack")}
    for _, box in ipairs(boxes) do
        if box then
            for _, tool in ipairs(box:GetChildren()) do
                if tool:IsA("Tool") then
                    zeroInst(tool)
                    for _, d in ipairs(tool:GetDescendants()) do zeroInst(d) end
                end
            end
        end
    end
end

local function scanGC()
    if not getgc then return end
    local okk, list = pcall(getgc, true)
    if not okk or type(list) ~= "table" then return end
    local n = 0
    for _, t in ipairs(list) do
        if type(t) == "table" then
            pcall(function()
                for k, v in pairs(t) do
                    if isSpreadName(k) then
                        local z = zeroOf(v)
                        if z ~= nil and v ~= z then
                            spreadTabs[#spreadTabs + 1] = {t, k, v}
                            t[k] = z
                        end
                    end
                end
            end)
        end
        n = n + 1
        if n % 1500 == 0 then task.wait() end
    end
end

local function restoreSpread()
    for _, e in ipairs(spreadInst) do
        pcall(function()
            if e.kind == "val" then e.inst.Value = e.orig else e.inst:SetAttribute(e.name, e.orig) end
        end)
    end
    for _, e in ipairs(spreadTabs) do pcall(function() e[1][e[2]] = e[3] end) end
    spreadInst, spreadTabs = {}, {}
end

local function hookChar(ch)
    keep(ch.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then needScan = true end
    end))
    needScan = true
end
if LP.Character then hookChar(LP.Character) end
keep(LP.CharacterAdded:Connect(hookChar))

local BonesR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local BonesR6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local ESP, espShown = {}, false
local RED, GREEN = Color3.fromRGB(255, 60, 60), Color3.fromRGB(70, 235, 120)

local function newObj()
    local o = {
        Snap = Draw.new("Line"), Box = Draw.new("Square"),
        HpBg = Draw.new("Line"), HpFill = Draw.new("Line"), HpTxt = Draw.new("Text"),
        Name = Draw.new("Text"), Dist = Draw.new("Text"),
        Bones = {},
    }
    o.Snap.Color = S.ColESP
    o.Snap.Thickness = 1.2
    o.Box.Color = S.ColESP
    o.Box.Thickness = 1.5
    o.Box.Filled = false
    o.HpBg.Color = Color3.new(0, 0, 0)
    o.HpBg.Thickness = 4
    o.HpFill.Thickness = 2
    o.HpTxt.Size = 11
    o.HpTxt.Center = true
    o.HpTxt.Outline = true
    o.HpTxt.Color = Color3.new(1, 1, 1)
    for _, t in ipairs({o.Name, o.Dist}) do
        t.Size = 13
        t.Center = true
        t.Outline = true
        t.Color = Color3.new(1, 1, 1)
        t.Visible = false
    end
    o.Snap.Visible, o.Box.Visible, o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false, false, false
    return o
end

local function hideBones(o, from)
    for i = from or 1, #o.Bones do o.Bones[i].Visible = false end
end
local function hideObj(o)
    o.Snap.Visible, o.Box.Visible = false, false
    o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false
    o.Name.Visible, o.Dist.Visible = false, false
    hideBones(o)
end
local function killObj(o)
    for k, d in pairs(o) do
        if k == "Bones" then
            for _, l in ipairs(d) do pcall(function() l:Remove() end) end
        else
            pcall(function() d:Remove() end)
        end
    end
end

keep(Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then killObj(ESP[p]) ESP[p] = nil end
    if lockP == p then lockP = nil end
end))

local function drawSkeleton(o, ch, yoff)
    local bones = ch:FindFirstChild("UpperTorso") and BonesR15 or BonesR6
    for i = #o.Bones + 1, #bones do
        local l = Draw.new("Line")
        l.Color = Color3.new(1, 1, 1)
        l.Thickness = 1.3
        l.Visible = false
        o.Bones[i] = l
    end
    for i, pair in ipairs(bones) do
        local line = o.Bones[i]
        local a, b = ch:FindFirstChild(pair[1]), ch:FindFirstChild(pair[2])
        local shown = false
        if a and b then
            local pa = Cam:WorldToViewportPoint(a.Position)
            local pb = Cam:WorldToViewportPoint(b.Position)
            if pa.Z > 0 and pb.Z > 0 then
                line.From = Vector2.new(pa.X, pa.Y + yoff)
                line.To = Vector2.new(pb.X, pb.Y + yoff)
                shown = true
            end
        end
        line.Color = S.ColESP
        line.Visible = shown
    end
    hideBones(o, #bones + 1)
end

local function playersEsp()
    if not (S.Line or S.Box or S.Skel or S.Health or S.ESPName or S.ESPDist) then
        if espShown then
            for _, o in pairs(ESP) do hideObj(o) end
            espShown = false
        end
        return
    end
    espShown = true
    local vs = Cam.ViewportSize
    local yoff = 0

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local o = ESP[p]
            if not o then
                local okk, res = pcall(newObj)
                if okk then o = res ESP[p] = o else fail("esp", res) end
            end
            if o then
                local vis = false
                o.Snap.Color = S.ColESP
                o.Box.Color = S.ColESP
                if valid(p) then
                    local ch = charOf(p)
                    local root = rootOf(ch)
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    local head = ch:FindFirstChild("Head")
                    local rp = Cam:WorldToViewportPoint(root.Position)
                    if rp.Z > 0 then
                        local hy = head and ((headOrig[head] and headOrig[head].Size.Y) or head.Size.Y)
                        local topW = head and (head.Position + Vector3.new(0, hy / 2 + 0.15, 0)) or (root.Position + Vector3.new(0, 2.5, 0))
                        local feet = math.max(3, (hum and hum.HipHeight or 2) + root.Size.Y / 2)
                        local tp = Cam:WorldToViewportPoint(topW)
                        local bp = Cam:WorldToViewportPoint(root.Position - Vector3.new(0, feet, 0))
                        if tp.Z > 0 and bp.Z > 0 then
                            local top = math.min(tp.Y, bp.Y) + yoff
                            local h = math.abs(bp.Y - tp.Y)
                            local w = h * 0.55
                            if h >= 4 then
                                vis = true
                                local cx = rp.X

                                o.Snap.Visible = S.Line
                                if S.Line then
                                    o.Snap.From = Vector2.new(vs.X / 2, 0)
                                    o.Snap.To = Vector2.new(cx, top + h / 2)
                                end

                                o.Box.Visible = S.Box
                                if S.Box then
                                    o.Box.Size = Vector2.new(w, h)
                                    o.Box.Position = Vector2.new(cx - w / 2, top)
                                end

                                if S.Health and hum then
                                    local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                    local x = cx - w / 2 - 5
                                    o.HpBg.From = Vector2.new(x, top + h)
                                    o.HpBg.To = Vector2.new(x, top)
                                    o.HpFill.Color = RED:Lerp(GREEN, frac)
                                    o.HpFill.From = Vector2.new(x, top + h)
                                    o.HpFill.To = Vector2.new(x, top + h - h * frac)
                                    o.HpTxt.Text = tostring(math.floor(hum.Health))
                                    o.HpTxt.Position = Vector2.new(x - 12, top + h - h * frac - 6)
                                    o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = true, true, true
                                else
                                    o.HpBg.Visible, o.HpFill.Visible, o.HpTxt.Visible = false, false, false
                                end

                                if S.Skel then drawSkeleton(o, ch, yoff) else hideBones(o) end

                                o.Name.Visible = S.ESPName
                                if S.ESPName then
                                    o.Name.Text = (p.DisplayName ~= "" and p.DisplayName) or p.Name
                                    o.Name.Position = Vector2.new(cx, top - 16)
                                end
                                o.Dist.Visible = S.ESPDist
                                if S.ESPDist then
                                    o.Dist.Text = string.format("[%dm]", math.floor((root.Position - myPos()).Magnitude))
                                    o.Dist.Position = Vector2.new(cx, top + h + 2)
                                end
                            end
                        end
                    end
                end
                if not vis then hideObj(o) end
            end
        end
    end
end

local ESPN = {}
local function newNpcObj()
    local o = {Box = Draw.new("Square"), Bones = {}}
    o.Box.Thickness = 1.5
    o.Box.Filled = false
    o.Box.Visible = false
    return o
end
local function hideNpc(o)
    o.Box.Visible = false
    hideBones(o)
end

local function bboxOnScreen(ch)
    local okk, cf, size = pcall(function() return ch:GetBoundingBox() end)
    if not okk then return end
    local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
    for _, sx in ipairs({-1, 1}) do
        for _, sy in ipairs({-1, 1}) do
            for _, sz in ipairs({-1, 1}) do
                local wp = cf:PointToWorldSpace(Vector3.new(sx * size.X / 2, sy * size.Y / 2, sz * size.Z / 2))
                local v = Cam:WorldToViewportPoint(wp)
                if v.Z <= 0 then return end
                x0, y0 = math.min(x0, v.X), math.min(y0, v.Y)
                x1, y1 = math.max(x1, v.X), math.max(y1, v.Y)
            end
        end
    end
    return x0, y0, x1, y1
end

local npcShown = false
local function npcEsp()
    if not (S.NPCBox or S.NPCSkel) then
        if npcShown then
            for _, o in pairs(ESPN) do hideNpc(o) end
            npcShown = false
        end
        return
    end
    npcShown = true

    local me = myPos()
    local list = {}
    for m, h in pairs(npcs) do
        if m.Parent and h.Parent then
            local r = rootOf(m)
            if r and alive(m, h) then
                local d = (r.Position - me).Magnitude
                if d <= S.NPCDist then list[#list + 1] = {m, d} end
            end
        end
    end
    table.sort(list, function(a, b) return a[2] < b[2] end)

    local used = {}
    for i = 1, math.min(#list, 20) do
        local m = list[i][1]
        used[m] = true
        local o = ESPN[m]
        if not o then
            o = newNpcObj()
            ESPN[m] = o
        end
        o.Box.Color = S.ColESP
        local x0, y0, x1, y1 = bboxOnScreen(m)
        if x0 then
            o.Box.Visible = S.NPCBox
            if S.NPCBox then
                o.Box.Position = Vector2.new(x0, y0)
                o.Box.Size = Vector2.new(x1 - x0, y1 - y0)
            end
            if S.NPCSkel then drawSkeleton(o, m, 0) else hideBones(o) end
        else
            hideNpc(o)
        end
    end

    for m, o in pairs(ESPN) do
        if not used[m] then
            if not m.Parent then
                killObj(o)
                ESPN[m] = nil
            else
                hideNpc(o)
            end
        end
    end
end

local function espStep()
    local o1, e1 = pcall(playersEsp)
    if not o1 then fail("esp", e1) end
    local o2, e2 = pcall(npcEsp)
    if not o2 then fail("esp npc", e2) end
end

local function myHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local speedWas = false
keep(RS.Heartbeat:Connect(function(dt)
    if not S.SpeedOn then
        if speedWas then
            speedWas = false
            local h0 = myHum()
            if h0 then h0.WalkSpeed = 16 end
        end
        return
    end
    speedWas = true
    if S.FlyFree then return end

    local ch = LP.Character
    local h = ch and ch:FindFirstChildOfClass("Humanoid")
    local r = ch and ch:FindFirstChild("HumanoidRootPart")
    if not h or not r or h.Health <= 0 then return end

    if h.WalkSpeed < S.Speed then h.WalkSpeed = S.Speed end

    local md = h.MoveDirection
    if md.Magnitude > 0.05 then
        local v = r.AssemblyLinearVelocity
        local cur = Vector3.new(v.X, 0, v.Z).Magnitude
        if cur < S.Speed - 2 then
            r.CFrame = r.CFrame + md.Unit * (S.Speed - cur) * dt
        end
    end
end))

local stamEntries = {}
local stamWasOn, stamNeedScan, stamScanning = false, true, false
local stamOk = {stamina = true, currentstamina = true, curstamina = true, staminavalue = true, playerstamina = true}

local function cleanName(n) return (string.gsub(string.lower(tostring(n)), "[^%a]", "")) end

local function scanStamInst(inst)
    if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and stamOk[cleanName(inst.Name)] then
        local mx = math.max(inst.Value, 100)
        local sib = inst.Parent and inst.Parent:FindFirstChild("Max" .. inst.Name)
        if sib and (sib:IsA("NumberValue") or sib:IsA("IntValue")) then mx = math.max(mx, sib.Value) end
        stamEntries[#stamEntries + 1] = {kind = "val", inst = inst, max = mx}
    end
    for name, v in pairs(inst:GetAttributes()) do
        if type(v) == "number" and stamOk[cleanName(name)] then
            local mxA = inst:GetAttribute("Max" .. name)
            stamEntries[#stamEntries + 1] = {kind = "attr", inst = inst, name = name,
                max = math.max(v, 100, type(mxA) == "number" and mxA or 0)}
        end
    end
end

local function scanStamina()
    stamEntries = {}
    local roots = {LP.Character}
    for _, c in ipairs(LP:GetChildren()) do
        if not c:IsA("PlayerGui") then roots[#roots + 1] = c end
    end
    for _, root in ipairs(roots) do
        scanStamInst(root)
        for _, d in ipairs(root:GetDescendants()) do scanStamInst(d) end
    end

    if getgc then
        local okk, list = pcall(getgc, true)
        if okk and type(list) == "table" then
            local n = 0
            for _, t in ipairs(list) do
                if type(t) == "table" then
                    pcall(function()
                        for k, v in pairs(t) do
                            if type(k) == "string" and type(v) == "number" and stamOk[cleanName(k)] then
                                stamEntries[#stamEntries + 1] = {kind = "tab", t = t, key = k, max = math.max(v, 100)}
                            end
                        end
                    end)
                end
                n = n + 1
                if n % 1500 == 0 then task.wait() end
            end
        end
    end
end

local function applyStam(e)
    if e.kind == "val" then
        if e.inst.Value < e.max then e.inst.Value = e.max end
    elseif e.kind == "attr" then
        local v = e.inst:GetAttribute(e.name)
        if type(v) == "number" and v < e.max then e.inst:SetAttribute(e.name, e.max) end
    else
        if e.t[e.key] < e.max then e.t[e.key] = e.max end
    end
end

keep(RS.Heartbeat:Connect(function()
    if not S.InfStamina then return end
    for _, e in ipairs(stamEntries) do pcall(applyStam, e) end
end))

keep(LP.CharacterAdded:Connect(function() stamNeedScan = true end))

local ffWas = false
keep(RS.Heartbeat:Connect(function(dt)
    local ch = LP.Character
    local h = ch and ch:FindFirstChildOfClass("Humanoid")
    local r = ch and ch:FindFirstChild("HumanoidRootPart")
    if not S.FlyFree or not h or not r or h.Health <= 0 then
        if ffWas then
            ffWas = false
            if h then h.PlatformStand = false end
        end
        return
    end
    ffWas = true
    h.PlatformStand = true
    local cf = Cam.CFrame
    local mv = h.MoveDirection
    local vel = Vector3.zero
    if mv.Magnitude > 0.05 then
        local flat = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
        local right = flat:Cross(Vector3.yAxis)
        vel = cf.LookVector * mv:Dot(flat) + cf.RightVector * mv:Dot(right)
    end
    r.CFrame = r.CFrame + vel * S.FlyFreeSpeed * dt
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end))

local ncParts = {}
keep(RS.Stepped:Connect(function()
    local ch = LP.Character
    if not ch then return end
    if S.Noclip or S.FlyFree then
        for _, d in ipairs(ch:GetChildren()) do
            if d:IsA("BasePart") and d.CanCollide then
                d.CanCollide = false
                ncParts[d] = true
            end
        end
    else
        for d in pairs(ncParts) do
            if d.Parent then d.CanCollide = true end
            ncParts[d] = nil
        end
    end
end))

local function step(dt)
    Cam = WS.CurrentCamera or Cam

    if fov then
        pcall(function()
            fov.Visible = S.ShowFOV
            fov.Color = S.ColFOV
            if S.ShowFOV then
                fov.Position = Cam.ViewportSize / 2
                fov.Radius = S.FOV
            end
        end)
    end

    if npcFov then
        pcall(function()
            npcFov.Visible = S.NPCShowFOV
            if S.NPCShowFOV then
                npcFov.Position = Cam.ViewportSize / 2
                npcFov.Radius = S.NPCFOV
                npcFov.Color = S.ColFOV
            end
        end)
    end

    pcall(silentStep)

    if S.NPCAim then
        pcall(aimNpc, dt)
    elseif S.Aim then
        pcall(aim, dt)
    else
        lockP = nil
    end

    pcall(espStep)
end

local bound = pcall(function()
    RS:BindToRenderStep("FrostHub", Enum.RenderPriority.Last.Value, function(dt) step(dt or 1/60) end)
end)
if not bound then
    keep(RS.RenderStepped:Connect(function(dt) step(dt) end))
end

task.spawn(function()
    while true do
        if S.InfStamina then
            if (not stamWasOn or stamNeedScan) and not stamScanning then
                stamWasOn, stamNeedScan, stamScanning = true, false, true
                task.spawn(function()
                    local okk, e = pcall(scanStamina)
                    if not okk then fail("stamina", e) end
                    stamScanning = false
                end)
            end
        else
            stamWasOn = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        pcall(headsStep)

        if S.NoSpread then
            if (not spreadWasOn or needScan) and not scanning then
                spreadWasOn, needScan, scanning = true, false, true
                task.spawn(function()
                    local ok2, e2 = pcall(function() scanTools() scanGC() end)
                    if not ok2 then fail("spread", e2) end
                    scanning = false
                end)
            end
        elseif spreadWasOn then
            spreadWasOn = false
            pcall(restoreSpread)
        end
        task.wait(0.3)
    end
end)

LP.CharacterRemoving:Connect(function()
    for part in pairs(headOrig) do restoreHead(part) end
end)

local Window = WindUI:CreateWindow({
    Title = 'Frost HUB | 刀刃球',
    Icon = "crown",
    IconThemed = true,
    Author = "by SQ",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(320, 420),
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
            WindUI:Notify({Title = "Frost HUB", Content = "刀刃球整合版已加载", Duration = 2, Icon = "check"})
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
    Title = "Frost HUB",
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
        RS.RenderStepped:Connect(function(deltaTime)
            gradient.Rotation = (gradient.Rotation + 60 * deltaTime) % 360
        end)
    end
end

local TabAim = Window:Tab({ Title = "自瞄", Icon = "crosshair" })

TabAim:Section({ Title = "玩家自瞄" })

TabAim:Toggle({
    Title = "启用自瞄",
    Desc = "自动锁定最近的敌人",
    Default = false,
    Callback = function(v) S.Aim = v end
})

TabAim:Dropdown({
    Title = "爆头几率",
    Desc = "选择瞄准头部的概率",
    Values = {"100% 爆头", "70% 爆头", "50% 爆头", "30% 爆头"},
    Default = "100% 爆头",
    Callback = function(v)
        local map = {["100% 爆头"] = 100, ["70% 爆头"] = 70, ["50% 爆头"] = 50, ["30% 爆头"] = 30}
        S.HS = map[v] or 100
    end
})

TabAim:Toggle({
    Title = "静默瞄准",
    Desc = "子弹自动飞向目标，无需瞄准",
    Default = false,
    Callback = function(v) S.Silent = v end
})

TabAim:Toggle({
    Title = "忽略队友",
    Desc = "自瞄和ESP都会忽略队友",
    Default = false,
    Callback = function(v) S.IgnoreTeam = v end
})

TabAim:Section({ Title = "范围设置" })

TabAim:Toggle({
    Title = "显示FOV圆圈",
    Desc = "显示自瞄搜索范围",
    Default = false,
    Callback = function(v) S.ShowFOV = v end
})

TabAim:Slider({
    Title = "FOV大小",
    Desc = "自瞄搜索范围",
    Min = 40, Max = 400, Default = 140,
    Callback = function(v) S.FOV = v end
})

TabAim:Slider({
    Title = "最大距离 (studs)",
    Desc = "自瞄最大锁定距离",
    Min = 20, Max = 500, Default = 120,
    Callback = function(v) S.MaxDist = v end
})

TabAim:Section({ Title = "武器设置" })

TabAim:Toggle({
    Title = "无扩散",
    Desc = "尝试消除子弹散布",
    Default = false,
    Callback = function(v) S.NoSpread = v end
})

TabAim:Section({ Title = "头部设置" })

TabAim:Toggle({
    Title = "增大头部",
    Desc = "敌人头部变大（仅本地可见）",
    Default = false,
    Callback = function(v) S.BigHead = v end
})

TabAim:Slider({
    Title = "头部大小",
    Min = 2, Max = 12, Default = 4,
    Callback = function(v) S.HeadSize = v end
})

local TabESP = Window:Tab({ Title = "透视", Icon = "eye" })

TabESP:Section({ Title = "玩家透视" })

TabESP:Toggle({
    Title = "连线透视",
    Desc = "从屏幕顶部连线到玩家",
    Default = false,
    Callback = function(v) S.Line = v end
})

TabESP:Toggle({
    Title = "方框透视",
    Desc = "在玩家周围绘制方框",
    Default = false,
    Callback = function(v) S.Box = v end
})

TabESP:Toggle({
    Title = "骨骼透视",
    Desc = "显示玩家骨骼结构",
    Default = false,
    Callback = function(v) S.Skel = v end
})

TabESP:Toggle({
    Title = "血量显示",
    Desc = "显示血条和数值",
    Default = false,
    Callback = function(v) S.Health = v end
})

TabESP:Toggle({
    Title = "名字显示",
    Desc = "在方框上方显示名字",
    Default = false,
    Callback = function(v) S.ESPName = v end
})

TabESP:Toggle({
    Title = "距离显示",
    Desc = "在方框下方显示距离",
    Default = false,
    Callback = function(v) S.ESPDist = v end
})

TabESP:Section({ Title = "颜色设置" })

TabESP:ColorPicker({
    Title = "ESP颜色",
    Default = Color3.fromRGB(232, 38, 54),
    Callback = function(v)
        S.ColESP = v
        S.ColFOV = v
    end
})

local TabMove = Window:Tab({ Title = "移动", Icon = "zap" })

TabMove:Section({ Title = "速度设置" })

TabMove:Toggle({
    Title = "启用加速",
    Desc = "增加移动速度",
    Default = false,
    Callback = function(v) S.SpeedOn = v end
})

TabMove:Slider({
    Title = "移动速度",
    Desc = "推荐值 30",
    Min = 16, Max = 60, Default = 30,
    Callback = function(v) S.Speed = v end
})

TabMove:Section({ Title = "飞行设置" })

TabMove:Toggle({
    Title = "启用飞行",
    Desc = "摇杆移动，相机控制升降",
    Default = false,
    Callback = function(v) S.FlyFree = v end
})

TabMove:Slider({
    Title = "飞行速度",
    Min = 15, Max = 80, Default = 40,
    Callback = function(v) S.FlyFreeSpeed = v end
})

TabMove:Toggle({
    Title = "穿墙模式",
    Desc = "Noclip 穿过墙壁",
    Default = false,
    Callback = function(v) S.Noclip = v end
})

TabMove:Section({ Title = "耐力设置" })

TabMove:Toggle({
    Title = "无限耐力",
    Desc = "快速奔跑不消耗耐力",
    Default = false,
    Callback = function(v) S.InfStamina = v end
})

local TabNPC = Window:Tab({ Title = "NPC", Icon = "bot" })

TabNPC:Section({ Title = "NPC自瞄" })

TabNPC:Toggle({
    Title = "启用NPC自瞄",
    Desc = "锁定最近的存活NPC（暂停玩家自瞄）",
    Default = false,
    Callback = function(v) S.NPCAim = v end
})

TabNPC:Toggle({
    Title = "瞄准头部",
    Desc = "关闭则瞄准躯干（更容易命中）",
    Default = false,
    Callback = function(v) S.NPCHead = v end
})

TabNPC:Toggle({
    Title = "忽略死亡NPC",
    Desc = "不瞄准倒地的NPC",
    Default = true,
    Callback = function(v) S.IgnoreDead = v end
})

TabNPC:Toggle({
    Title = "NPC静默瞄准",
    Desc = "子弹自动飞向最近的NPC",
    Default = false,
    Callback = function(v) S.SilentNPC = v end
})

TabNPC:Slider({
    Title = "NPC距离 (studs)",
    Min = 20, Max = 500, Default = 120,
    Callback = function(v) S.NPCDist = v end
})

TabNPC:Section({ Title = "NPC范围" })

TabNPC:Toggle({
    Title = "显示NPC FOV",
    Desc = "开启后只瞄准圆圈内NPC",
    Default = false,
    Callback = function(v) S.NPCShowFOV = v end
})

TabNPC:Slider({
    Title = "NPC FOV大小",
    Min = 40, Max = 500, Default = 160,
    Callback = function(v) S.NPCFOV = v end
})

TabNPC:Section({ Title = "NPC透视" })

TabNPC:Toggle({
    Title = "NPC方框",
    Desc = "在存活NPC周围绘制方框",
    Default = false,
    Callback = function(v) S.NPCBox = v end
})

TabNPC:Toggle({
    Title = "NPC骨骼",
    Desc = "显示NPC骨骼结构",
    Default = false,
    Callback = function(v) S.NPCSkel = v end
})

local TabSettings = Window:Tab({ Title = "设置", Icon = "settings" })

TabSettings:Section({ Title = "关于" })

TabSettings:Paragraph({
    Title = "Frost HUB | 刀刃球整合版",
    Desc = "基于 WindUI + Netrix 核心功能\n\n功能：自瞄 / 静默瞄准 / ESP透视 / 加速 / 飞行 / 穿墙 / NPC自瞄 / 无限耐力 / 无扩散 / 大头模式"
})

TabSettings:Button({
    Title = "复制Discord链接",
    Desc = "点击复制",
    Callback = function()
        local copy = setclipboard or toclipboard
        if copy then
            pcall(copy, "https://discord.gg/yQyvXYM2CK")
            Notify("成功", "Discord链接已复制！", 2)
        else
            Notify("提示", "当前环境不支持剪贴板", 2)
        end
    end
})

TabSettings:Button({
    Title = "重置所有功能",
    Desc = "关闭所有激活的功能",
    Callback = function()
        S.Aim = false; S.Silent = false; S.NPCAim = false; S.SilentNPC = false
        S.Line = false; S.Box = false; S.Skel = false; S.Health = false
        S.ESPName = false; S.ESPDist = false; S.NPCBox = false; S.NPCSkel = false
        S.SpeedOn = false; S.FlyFree = false; S.Noclip = false; S.InfStamina = false
        S.NoSpread = false; S.BigHead = false; S.ShowFOV = false; S.NPCShowFOV = false
        Notify("重置", "所有功能已关闭，请重新打开界面刷新状态", 3)
    end
})

Notify("Frost HUB", "刀刃球整合版加载成功！", 3)
print("[FrostHub] 刀刃球整合版已加载")
