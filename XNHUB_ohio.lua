local _cloneref = (cloneref or clonereference or function(i) return i end)

local _WINDUI_URLS = {
	"https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
	"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
}
local WindUI, _wuErr
for _, _u in ipairs(_WINDUI_URLS) do
	local _ok, _res = pcall(function()
		local s = game:HttpGet(_u)
		if not s or #s < 1000 then error("响应过短") end
		return loadstring(s)()
	end)
	if _ok and type(_res) == "table" then WindUI = _res break end
	_wuErr = _res
end
if not WindUI then
	error("[XNHUB] WindUI 加载失败: " .. tostring(_wuErr))
end

local _BACKGROUND_IDS = {
	79035780602083, 115285451809270, 126071927593389, 105661627105291,
	77508472999355, 107872248048503, 72869227895853, 126952765872927,
	83853972032276,
}

local WIN = WindUI:CreateWindow({
	Title = "XNHUB",
	Icon = "snowflake",
	Author = "XNHUB",
	Folder = "XNHUB",
	Size = UDim2.fromOffset(620, 480),
	Theme = "Dark",
	Transparent = false,
	User = { Enabled = true, Anonymous = true },
	SideBarWidth = 200,
	ScrollBarEnabled = true,
	ToggleKey = Enum.KeyCode.RightShift,
	Background = "rbxassetid://" .. tostring(_BACKGROUND_IDS[math.random(1, #_BACKGROUND_IDS)]),
	BackgroundImageTransparency = 0,
})

local function _sectionWrap(ws)
	local s = {}
	function s:Toggle(name, flag, default, cb)
		return ws:Toggle({ Title = name, Value = default, Callback = cb })
	end
	function s:Slider(name, flag, default, mn, mx, round, cb)
		return ws:Slider({
			Title = name,
			Value = { Min = mn or 0, Max = mx or 100, Default = default or mn or 0 },
			Callback = cb,
		})
	end
	function s:Dropdown(name, flag, values, cb)
		return ws:Dropdown({ Title = name, Values = values, Callback = cb })
	end
	function s:Button(name, cb)
		return ws:Button({ Title = name, Callback = cb })
	end
	function s:Textbox(name, flag, default, cb)
		return ws:Input({ Title = name, Value = default, Callback = cb })
	end
	function s:Label(text)
		local w = ws:Paragraph({ Title = "", Desc = tostring(text or "") })
		return { Set = function(_, t) pcall(function() w:SetDesc(tostring(t or "")) end) end }
	end
	return s
end

local uiLib = {}
function uiLib:Tab(name, icon)
	local wt = WIN:Tab({ Title = tostring(name) })
	local t = {}
	function t:Section(sname, opened)
		local ws = wt:Section({ Title = tostring(sname or ""), Opened = true })
		return _sectionWrap(ws)
	end
	return t
end





local BG_MASK_NAME = "BackgroundMask"
local MASK_DEFAULT = 0.30

local function applyBackgroundMask(strength)
	strength = math.clamp(tonumber(strength) or 0, 0, 1)
	pcall(function()
		local main = WIN.UIElements and WIN.UIElements.Main
		if not main then return end
		local bgLayer = main:FindFirstChild("Background")
		if not bgLayer then return end
		local mask = bgLayer:FindFirstChild(BG_MASK_NAME)
		if not mask then
			mask = Instance.new("Frame")
			mask.Name = BG_MASK_NAME
			mask.Size = UDim2.new(1, 0, 1, 0)
			mask.Position = UDim2.new(0, 0, 0, 0)
			mask.BorderSizePixel = 0
			mask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			mask.ZIndex = 10
			mask.Parent = bgLayer
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 16)
			corner.Parent = mask
		end
		mask.Visible = strength > 0
		mask.BackgroundTransparency = 1 - strength
	end)
end

task.spawn(function()
	local tries = 0
	while tries < 20 do
		local main = WIN.UIElements and WIN.UIElements.Main
		if main and main:FindFirstChild("Background") then break end
		task.wait(0.1)
		tries = tries + 1
	end
	applyBackgroundMask(MASK_DEFAULT)
end)

local notifyLib = {}
function notifyLib:Notify(msg, lvl)
	pcall(function()
		WIN:Notify({ Title = "XNHUB", Content = tostring(msg), Duration = 6 })
	end)
end


local _setTab = uiLib:Tab("设置")
local _setSec = _setTab:Section("界面")
_setSec:Slider("背景遮罩(×100)", "ui_mask", 30, 0, 80, true, function(v)
	if type(v) == "number" then applyBackgroundMask(v / 100) end
end)
_setSec:Slider("背景图透明度(×100)", "ui_bgtrans", 0, 0, 90, true, function(v)
	if type(v) == "number" then
		pcall(function() WIN:SetBackgroundImageTransparency(v / 100) end)
	end
end)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local PlayerGui = LocalPlayer.PlayerGui
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CurrentCamera = Workspace.CurrentCamera
local GameFolder = Workspace:WaitForChild("Game", 20)
local Props = GameFolder and GameFolder:WaitForChild("Props", 10)
local Entities = GameFolder and GameFolder:WaitForChild("Entities", 10)
local Airdrops = GameFolder and GameFolder:WaitForChild("Airdrops", 10)
local CashBundle = Entities and Entities:WaitForChild("CashBundle", 10)
local ItemPickup = Entities and Entities:WaitForChild("ItemPickup", 10)
local GemRobbery = Workspace:WaitForChild("GemRobbery", 5)
local BankRobbery = Workspace:WaitForChild("BankRobbery", 5)
local JewelryCases = GemRobbery and GemRobbery:WaitForChild("JewelryCases", 10)
local BlackMarket = Workspace:WaitForChild("BlackMarket", 5)
local ItemsOnSale = Workspace:WaitForChild("ItemsOnSale", 5)
local ChristmasMobs = (Workspace:WaitForChild("Christmas", 5) or Workspace):WaitForChild("Mobs", 5)
local itemStoreBillboard = (PlayerGui:WaitForChild("Billboards", 10) or PlayerGui):WaitForChild("itemStore", 5)
local ReplicatedStorageDev = game:GetService("ReplicatedStorage").devv
local v3item = ReplicatedStorageDev.client.Objects.v3item
local SignalRemote = ReplicatedStorageDev.client.Helpers.remotes.Signal
local FireServer = require(SignalRemote).FireServer
local InvokeServer = require(SignalRemote).InvokeServer
debug.getupvalue(FireServer, 1)
local stateModule = ReplicatedStorageDev.datum.state

local adminList = {}
task.spawn(function()
    local specialRoles = require(ReplicatedStorageDev).data.specialroles
    for role, data in pairs(specialRoles) do
        if role == "developer" or role == "admins" or role == "heros" then
            for _, userId in pairs(data.users) do
                table.insert(adminList, userId)
            end
        end
    end
    for _, player in pairs(Players:GetChildren()) do
        if table.find(adminList, player.UserId) then
            LocalPlayer:Kick("服务器存在管理员/作者")
        end
    end
    Players.PlayerAdded:Connect(function(player)
        if table.find(adminList, player.UserId) then
            LocalPlayer:Kick("管理员/作者 加入了此服务器")
        end
    end)
end)

local colors = {
    ["Red"] = Color3.fromRGB(255, 0, 0),
    ["Green"] = Color3.fromRGB(0, 255, 0),
    ["Blue"] = Color3.fromRGB(0, 0, 255),
    ["Pink"] = Color3.fromRGB(255, 170, 255),
    ["Cyan"] = Color3.fromRGB(85, 255, 255)
}

local settings = {
    ["EspToggle"] = false,
    ["HighlightToggle"] = false,
    ["HighlightTransparency"] = 0.5,
    ["SelectFillColor"] = Color3.fromRGB(255, 0, 0),
    ["Fullbright"] = false,
    ["Noclip"] = false,
    ["Fly"] = false,
    ["Flyspeed"] = 3,
    ["InfJump"] = false,
    ["SelectPlr"] = nil,
    ["Aimbot"] = false,
    ["SilentAim"] = false,
    ["HitboxToggle"] = false,
    ["SnipePlr"] = false,
    ["EspMoneys"] = false,
    ["EspItems"] = false,
    ["SnipeToHeadLookVector"] = false,
    ["MoneyFarm"] = false,
    ["ItemsFarm"] = false,
    ["BringPlayerDistance"] = 6,
    ["BankFarm"] = false,
    ["ATMFarm"] = false,
    ["HitboxHeadToggle"] = false,
    ["AutoFarmAirdrop"] = false,
    ["SuperPunch"] = false,
    ["MoneyAura"] = false,
    ["ItemAura"] = false,
    ["EspScale"] = 0.5,
    ["GetRemoteOfAttack"] = false,
    ["AutoSpammer"] = false,
    ["AutoSpammerText"] = "B赞搜索灾难蛋购买脚本!",
    ["JewelryCasesAura"] = false,
    ["AutoFarmJewelryCases"] = false,
    ["CombatWeapon"] = "拳头",
    ["AutoTreasure"] = false,
    ["KillAuraDistance"] = 25,
    ["AttackNonKnockedFirst"] = false,
    ["Attack1096First"] = false,
    ["PredValue"] = 2,
    ["RespawnAtDeadPos"] = false,
    ["RespawnAtDeadPosWait"] = 1,
    ["EspName"] = false,
    ["FunAmmo"] = false,
    ["FunTarget"] = nil,
    ["FunPart"] = "Head",
    ["ShowLocker"] = false,
    ["AnimateSelect"] = "无",
    ["ChangeAnimate"] = false,
    ["StompAura"] = false,
    ["StompAuraDistance"] = 25,
    ["SemiGod"] = false,
    ["BringDistance"] = 10,
    ["BringUnAnchored"] = false,
    ["GrabAura"] = false,
    ["GrabAuraDistance"] = 25,
    ["BuyItem"] = nil,
    ["MessageSpammer"] = false,
    ["MessageNuke"] = false,
    ["MessageSpammerText"] = "B赞搜索灾难蛋购买脚本!",
    ["PhoneSpammer"] = false,
    ["InstantPrompt"] = false,
    ["KillAuraAutoEquipPunch"] = false,
    ["AutoHealth"] = false,
    ["AutoHealthLimit"] = 90,
    ["Invisible"] = false,
    ["SelectLocate"] = nil,
    ["Christmas"] = false
}

local blacklistedNames = {
    "advent259",
    "Zainandan1337",
    "DangweiDan",
    "AdvancedLogic_Dev",
    "ojwvs65lq",
    "KSBWKJJ",
    "AkiraDank",
    "sbsbsbsbnba",
    "woshinibbjjjj",
    "KELE_889",
    "tangmeiLONG",
    "longsu_long",
    "cnmdnmsbsb123"
}
local combatWhitelist = {}

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if settings.InstantPrompt then
        fireproximityprompt(prompt)
    end
end)

local tabCombat = uiLib:Tab("战斗类", "17901200092")
local sectionCombat = tabCombat:Section("战斗类", false)
local sectionAntiGrab = tabCombat:Section("防吸人", false)
local sectionKillAura = tabCombat:Section("杀戮光环", false)
local sectionKillAll = tabCombat:Section("杀死全体", false)
local sectionStompAura = tabCombat:Section("踩人光环", false)
local sectionGrabAura = tabCombat:Section("抱人光环", false)
local sectionHitbox = tabCombat:Section("范围", false)
local sectionAutoSpammer = tabCombat:Section("自动嘲讽", false)
local sectionRespawn = tabCombat:Section("原地复活", false)

local tabAim = uiLib:Tab("瞄准", "6922963617"):Section("自瞄", false)

local tabItems = uiLib:Tab("物品", "7734056747")
local sectionInteract = tabItems:Section("互动", false)
local sectionBlackMarket = tabItems:Section("黑市", false)
local sectionLocker = tabItems:Section("储物柜", false)
local sectionBuy = tabItems:Section("购买物品", false)

local tabAuto = uiLib:Tab("自动", "15332132816")
local sectionChristmas = tabAuto:Section("圣诞节", false)
local sectionMoney = tabAuto:Section("钱", false)
local sectionItems = tabAuto:Section("物品", false)
local sectionBank = tabAuto:Section("银行", false)
local sectionJewelry = tabAuto:Section("珠宝店", false)
local sectionSafes = tabAuto:Section("保险柜", false)
local sectionAirdrop = tabAuto:Section("空投", false)

local tabTeleport = uiLib:Tab("传送", "7733992469"):Section("地点")

local tabFun = uiLib:Tab("娱乐", "10683794445"):Section("娱乐", true)

local tabData = uiLib:Tab("数据", "7743866778")
local sectionMoneyData = tabData:Section("金钱数据", false)
local sectionBanData = tabData:Section("封禁数据", false)

local tabEsp = uiLib:Tab("透视", "7733696665")
local sectionEspToggle = tabEsp:Section("功能", false)
local sectionEspSettings = tabEsp:Section("透视设置", false)

local tabPlayers = uiLib:Tab("玩家", "7743876054"):Section("玩家选项", true)

local tabLocal = uiLib:Tab("本地", "7733752575")
local sectionLocalPlayer = tabLocal:Section("本地玩家", false)
local sectionChat = tabLocal:Section("聊天", false)
local sectionLocalVisuals = tabLocal:Section("本地视觉", false)
local sectionSkybox = tabLocal:Section("天空盒", false)


function UpdateEsp(playerName, color)
    pcall(function()
        if Players:FindFirstChild(playerName) and Players:FindFirstChild(playerName).Character then
            local character = Players:FindFirstChild(playerName).Character
            local showName = settings.EspToggle and settings.EspName
            if character.Head.Transparency == 0 and not character.Head:FindFirstChild("ALESP") or not character:FindFirstChild("ALHL") then
                if not character.Head:FindFirstChild("ALESP") then
                    local billboard = Instance.new("BillboardGui")
                    local textLabel = Instance.new("TextLabel")
                    billboard.Name = "ALESP"
                    billboard.Parent = character.Head
                    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    billboard.Active = true
                    billboard.ExtentsOffset = Vector3.new(0, 2, 0)
                    billboard.LightInfluence = 1
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.Enabled = showName
                    billboard.AlwaysOnTop = true
                    textLabel.Name = "Text"
                    textLabel.Parent = billboard
                    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.BackgroundTransparency = 1
                    textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.BorderSizePixel = 5
                    textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                    textLabel.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Text = Players:FindFirstChild(playerName).Name
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextScaled = true
                    textLabel.TextSize = 1
                    textLabel.TextStrokeTransparency = 0.19
                    textLabel.TextWrapped = true
                end
                if not character:FindFirstChild("ALHL") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ALHL"
                    highlight.Parent = character
                    highlight.FillColor = color
                    highlight.Enabled = settings.HighlightToggle
                    highlight.FillTransparency = settings.HighlightTransparency
                end
            end
            if character.Head:FindFirstChild("ALESP") then
                local billboard = character.Head:FindFirstChild("ALESP")
                local textLabel = billboard.Text
                billboard.Enabled = showName
                textLabel.Text = Players:FindFirstChild(playerName).Name
                textLabel.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
                textLabel.TextColor3 = color
            end
            if character:FindFirstChild("ALHL") then
                local highlight = character:FindFirstChild("ALHL")
                highlight.FillColor = color
                highlight.Enabled = settings.HighlightToggle
                highlight.FillTransparency = settings.HighlightTransparency
            end
        end
    end)
end

function MoneyUpdateEsp(moneyValue, part, color)
    pcall(function()
        if part then
            local enabled = settings.EspToggle and settings.EspMoneys
            if not (part:FindFirstChild("ALESP") or part:FindFirstChild("ALESP")) then
                local billboard = Instance.new("BillboardGui")
                local imageLabel = Instance.new("ImageLabel")
                local textLabel = Instance.new("TextLabel")
                billboard.Name = "ALESP"
                billboard.Parent = part
                billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                billboard.Active = true
                billboard.ExtentsOffset = Vector3.new(0, 2, 0)
                billboard.LightInfluence = 1
                billboard.Size = UDim2.new(0, 50, 0, 50)
                billboard.Enabled = enabled
                billboard.AlwaysOnTop = true
                imageLabel.Name = "Image"
                imageLabel.Parent = billboard
                imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                imageLabel.BackgroundTransparency = 1
                imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                imageLabel.BorderSizePixel = 0
                imageLabel.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
                imageLabel.Image = "rbxassetid://5567568456"
                imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                textLabel.Name = "Text"
                textLabel.Parent = billboard
                textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.BackgroundTransparency = 1
                textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.BorderSizePixel = 5
                textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                textLabel.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.Text = moneyValue
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextScaled = true
                textLabel.TextSize = 1
                textLabel.TextStrokeTransparency = 0.19
                textLabel.TextWrapped = true
            end
            if part:FindFirstChild("ALESP") then
                local billboard = part:FindFirstChild("ALESP")
                local textLabel = billboard.Text
                billboard.Enabled = enabled
                textLabel.Text = moneyValue
                textLabel.TextColor3 = color
                moneyValue.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
            end
        end
    end)
end

function ItemUpdateEsp(itemName, part, color)
    pcall(function()
        if part then
            local enabled = settings.EspToggle and settings.EspItems
            if not (part:FindFirstChild("ALESP") or part:FindFirstChild("ALESP")) then
                local billboard = Instance.new("BillboardGui")
                local textLabel = Instance.new("TextLabel")
                billboard.Name = "ALESP"
                billboard.Parent = part
                billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                billboard.Active = true
                billboard.ExtentsOffset = Vector3.new(0, 2, 0)
                billboard.LightInfluence = 1
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.Enabled = enabled
                billboard.AlwaysOnTop = true
                textLabel.Name = "Text"
                textLabel.Parent = billboard
                textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.BackgroundTransparency = 1
                textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.BorderSizePixel = 5
                textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                textLabel.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.Text = itemName
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextScaled = true
                textLabel.TextSize = 1
                textLabel.TextStrokeTransparency = 0.19
                textLabel.TextWrapped = true
            end
            if part:FindFirstChild("ALESP") then
                local billboard = part:FindFirstChild("ALESP")
                local textLabel = billboard.Text
                billboard.Enabled = enabled
                textLabel.Text = itemName
                textLabel.TextColor3 = color
                itemName.Size = UDim2.new(settings.EspScale, 0, settings.EspScale, 0)
            end
        end
    end)
end

function SpawnSkybox(skyboxData)
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
    if skyboxData.Bk and skyboxData.Dn and skyboxData.Ft and skyboxData.Lf and skyboxData.Rt and skyboxData.Up and skyboxData.Name then
        local sky = Instance.new("Sky")
        sky.Name = skyboxData.Name
        sky.SkyboxBk = skyboxData.Bk
        sky.SkyboxDn = skyboxData.Dn
        sky.SkyboxFt = skyboxData.Ft
        sky.SkyboxLf = skyboxData.Lf
        sky.SkyboxRt = skyboxData.Rt
        sky.SkyboxUp = skyboxData.Up
        sky.Parent = Lighting
        if skyboxData.SunAsset and skyboxData.SunAngularSize then
            sky.SunTextureId = skyboxData.SunAsset
            sky.SunAngularSize = skyboxData.SunAngularSize
        end
    else
        notifyLib:Notify("无效的天空盒参数", 2)
    end
end

local aimbotData = {
    ["AimPart"] = "Head",
    ["WallCheck"] = false,
    ["Enemy"] = nil,
    ["LockEnemy"] = nil,
    ["Line"] = Drawing.new("Line"),
    ["LineEnabled"] = false,
    ["Circle"] = {
        ["Circle"] = Drawing.new("Circle"),
        ["Visible"] = false,
        ["Transparency"] = 0.5,
        ["Radius"] = 200,
        ["Filled"] = false,
        ["Thickness"] = 1,
        ["Color"] = Color3.fromRGB(255, 255, 255)
    },
    ["Aimbot"] = {
        ["Epitaph"] = 17.6,
        ["ShowEpitaph"] = false,
        ["EpitaphCircle"] = Drawing.new("Circle"),
        ["StickAim"] = false
    }
}
aimbotData.Aimbot.EpitaphCircle.Visible = false
aimbotData.Aimbot.EpitaphCircle.Filled = true
aimbotData.Aimbot.EpitaphCircle.Radius = 5
aimbotData.Aimbot.EpitaphCircle.Transparency = 1
aimbotData.Aimbot.EpitaphCircle.Thickness = 1
aimbotData.Aimbot.EpitaphCircle.Color = Color3.fromRGB(255, 255, 255)
aimbotData.Line.Visible = false
aimbotData.Line.Thickness = 1
aimbotData.Line.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
aimbotData.Line.To = Vector2.new(0, 0)
aimbotData.Line.Color = Color3.fromRGB(255, 255, 255)
aimbotData.Line.Transparency = 1
aimbotData.Line.ZIndex = 999

local function getClosestEnemy()
    local closestDist = math.huge
    local closest = nil
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if table.find(blacklistedNames, player.Name) or table.find(combatWhitelist, player.Name) then
                    return
                end
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
                    local char = player.Character
                    local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(char[aimbotData.AimPart].Position)
                    if onScreen and (aimbotData.WallCheck ~= true or #CurrentCamera:GetPartsObscuringTarget({ char[aimbotData.AimPart].Position }, { CurrentCamera, LocalPlayer.Character, char }) <= 0) then
                        local dist = (Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist < closestDist and dist < aimbotData.Circle.Radius then
                            closestDist = dist
                            closest = char
                        end
                    end
                end
            end
        end
    end)
    return closest
end

local function updateCircle()
    if aimbotData.Circle.Circle == nil then
        aimbotData.Circle.Circle = Drawing.new("Circle")
        updateCircle()
    else
        local circleData = aimbotData.Circle
        local circle = circleData.Circle
        circle.Visible = circleData.Visible
        circle.Transparency = circleData.Transparency
        circle.Radius = circleData.Radius
        circle.Filled = circleData.Filled
        circle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
        circle.Thickness = circleData.Thickness
        circle.Color = circleData.Color
    end
end

local function setCameraCFrame(from, to)
    CurrentCamera.CFrame = CFrame.new(from, to)
end

function getTimeString(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    local secs = math.floor(seconds % 60)
    if hours < 10 then hours = "0" .. hours end
    if minutes < 10 then minutes = "0" .. minutes end
    if secs < 10 then secs = "0" .. secs end
    return "" .. hours .. ":" .. minutes .. ":" .. secs
end

local playerNames = {}
for _, player in pairs(Players:GetChildren()) do
    if player.Name ~= LocalPlayer.Name then
        table.insert(playerNames, player.Name)
    end
end

local whitelistLabelText = "战斗白名单:"
local whitelistLabel = sectionCombat:Label(whitelistLabelText)
local selectedWhitelistPlayer = nil
local whitelistDropdown = sectionCombat:Dropdown("玩家列表", "Players", playerNames, function(player)
    selectedWhitelistPlayer = player
end)
sectionCombat:Button("添加战斗白名单", function()
    pcall(function()
        if selectedWhitelistPlayer ~= nil then
            table.insert(combatWhitelist, selectedWhitelistPlayer)
            whitelistLabelText = whitelistLabelText .. "/" .. selectedWhitelistPlayer
            whitelistLabel:Set(whitelistLabelText)
        end
    end)
end)
sectionCombat:Button("重置战斗白名单", function()
    pcall(function()
        table.clear(combatWhitelist)
        whitelistLabelText = "战斗白名单:"
        whitelistLabel:Set(whitelistLabelText)
    end)
end)

local antiGrabSeat = nil
sectionAntiGrab:Button("防吸人", function()
    pcall(function()
        if antiGrabSeat and antiGrabSeat.Occupant == nil then
            antiGrabSeat.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            antiGrabSeat:Sit(LocalPlayer.Character.Humanoid)
        else
            antiGrabSeat = nil
            for _, obj in pairs(Workspace:GetDescendants()) do
                if antiGrabSeat then return end
                if obj:IsA("Seat") and obj.Occupant == nil then
                    obj.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    obj:Sit(LocalPlayer.Character.Humanoid)
                    antiGrabSeat = obj
                end
            end
        end
    end)
end)

sectionCombat:Label("如果你想在倒地之后打人请在倒地之前装备武器")

function SemiGod()
    while settings.SemiGod and _G.ScriptIsRunning ~= false do
        pcall(function()
            local props = require(ReplicatedStorageDev.datum.state).properties[LocalPlayer]
            if props.knocked == true then
                props.knocked = false
            end
        end)
        task.wait()
    end
end
sectionCombat:Toggle("防倒地", "EspToggle", false, function(val)
    settings.SemiGod = val
    SemiGod()
end)
sectionCombat:Toggle("超级拳", "EspToggle", false, function(val)
    settings.SuperPunch = val
end)
sectionCombat:Toggle("超级刀", "EspToggle", false, function(val)
    settings.SuperKnife = val
end)

local function autoHealthLoop()
    local consumables = {}
    local lastEquipped = ""
    while settings.AutoHealth do
        task.spawn(function()
            pcall(function()
                table.clear(consumables)
                for itemId, itemData in pairs(require(v3item).inventory.items) do
                    if not table.find(consumables, itemId) and itemData.type and itemData.type == "Consumable" then
                        table.insert(consumables, itemId)
                    end
                end
            end)
        end)
        pcall(function()
            if LocalPlayer.Character.Humanoid.Health <= settings.AutoHealthLimit and require(ReplicatedStorageDev.datum.state).properties[LocalPlayer].knocked == false then
                local equippedFound = false
                for itemId, itemData in pairs(require(v3item).inventory.items) do
                    if itemData.equipped == true and not table.find(consumables, itemId) then
                        lastEquipped = itemId
                    end
                end
                if #consumables == 0 then
                    InvokeServer("attemptPurchase", "Bandage")
                    InvokeServer("attemptPurchaseAmmo", "Bandage")
                    InvokeServer("attemptPurchaseAmmo", "Bandage")
                else
                    local item = consumables[1]
                    if require(v3item).inventory.items[item] and require(v3item).inventory.items[item].equipped ~= true then
                        FireServer("equip", item)
                        require(v3item).inventory.items[item].equipped = true
                    end
                    FireServer("useConsumable", item)
                    FireServer("removeItem", item)
                    FireServer("equip", lastEquipped)
                    require(v3item).inventory.items[lastEquipped].equipped = true
                end
            end
        end)
        task.wait()
    end
end
sectionCombat:Toggle("自动打药(并且会自动买绷带)", "AutoHealth", false, function(val)
    settings.AutoHealth = val
    autoHealthLoop()
end)
sectionCombat:Slider("打药血量", "KillAuraDistance", 90, 1, 185, true, function(val)
    settings.AutoHealthLimit = val
end)

local oldNamecall = nil
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    pcall(function()
        if method and method == "FireServer" then
            if typeof(args) == "table" and args[1] and tostring(args[1]) ~= "player" and tostring(args[1]):find("melee") then
                if settings.SuperPunch then
                    args[1] = "meleemegapunch"
                    return oldNamecall(self, unpack(args))
                end
                if settings.SuperKnife then
                    args[1] = "meleemegaswing"
                    return oldNamecall(self, unpack(args))
                end
            end
            if typeof(args) == "table" and args[1] and tostring(args[1]) == "player" and typeof(args[2]) == "table" and args[2].meleeType and tostring(args[2].meleeType) ~= "meleemegapunch" then
                if settings.SuperPunch then
                    args[2].meleeType = "meleemegapunch"
                    return oldNamecall(self, unpack(args))
                end
                if settings.SuperKnife then
                    args[2].meleeType = "meleemegaswing"
                end
            end
        end
    end)
    return oldNamecall(self, ...)
end)

local function killAuraLoop()
    while settings.KillAura and _G.ScriptIsRunning ~= false do
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.KillAura == false then return end
                if player ~= LocalPlayer and not table.find(combatWhitelist, player.Name) and not table.find(blacklistedNames, player.Name) then
                    if player.Character and not player.Character:FindFirstChildOfClass("ForceField") and player.Character.Humanoid.Health > 10 then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < settings.KillAuraDistance then
                            local inventory = require(v3item).inventory.items
                            pcall(function()
                                for id, data in pairs(inventory) do
                                    if data.name and data.name == "Fists" and data.equipped ~= true then
                                        FireServer("equip", id)
                                    end
                                end
                            end)
                            FireServer("meleeItemHit", "player", {
                                ["meleeType"] = "meleemegapunch",
                                ["hitPlayerId"] = player.UserId
                            })
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionKillAura:Toggle("杀戮光环", "KillAura", false, function(val)
    settings.KillAura = val
    killAuraLoop()
end)
sectionKillAura:Slider("杀戮距离", "KillAuraDistance", 25, 0.1, 40, true, function(val)
    settings.KillAuraDistance = val
end)

function KillAll()
    while settings.KillAll do
        if _G.ScriptIsRunning == false then return end
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.KillAll == false then return end
                if player ~= LocalPlayer and not table.find(combatWhitelist, player.Name) and not table.find(blacklistedNames, player.Name) then
                    if player.Character and not player.Character:FindFirstChildOfClass("ForceField") and player.Character.Humanoid.Health ~= 0 then
                        local attempts = 0
                        if LocalPlayer.Character.Humanoid.Health < 10 then
                            LocalPlayer.Character.Humanoid.Health = 0
                        end
                        if LocalPlayer.Character.Humanoid.Sit == true then
                            LocalPlayer.Character.Humanoid.Sit = false
                        end
                        pcall(function()
                            for id, data in pairs(require(v3item).inventory.items) do
                                if data.name and data.name == "Fists" and data.equipped ~= true then
                                    FireServer("equip", id)
                                end
                            end
                        end)
                        while true do
                            task.wait()
                            if settings.KillAll == false or player.Character:FindFirstChildOfClass("ForceField") or player.Character.Humanoid.Health == 0 then
                                break
                            end
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame - player.Character.HumanoidRootPart.CFrame.LookVector * 4.5
                            attempts = attempts + 1
                            FireServer("meleeItemHit", "player", {
                                ["meleeType"] = "meleemegapunch",
                                ["hitPlayerId"] = player.UserId
                            })
                            if LocalPlayer.Character.Humanoid.Health < 10 then
                                LocalPlayer.Character.Humanoid.Health = 0
                            end
                            if LocalPlayer.Character.Humanoid.Sit == true then
                                LocalPlayer.Character.Humanoid.Sit = false
                            end
                            if player.Character.Humanoid.Health < 5 or not player.Character or attempts >= 25 then
                                break
                            end
                        end
                        FireServer("stomp", player)
                        task.wait(0.4)
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionKillAll:Toggle("自动杀死全体玩家", "EspToggle", false, function(val)
    settings.KillAll = val
    KillAll()
end)

local function stompAuraLoop()
    while settings.StompAura do
        if _G.ScriptIsRunning == false then return end
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.StompAura == false then return end
                if player ~= LocalPlayer and not table.find(combatWhitelist, player.Name) and not table.find(blacklistedNames, player.Name) then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < settings.StompAuraDistance and player.Character.Humanoid.Health < 10 and player.Character.Humanoid.Health ~= 0 then
                        FireServer("stomp", player)
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionStompAura:Toggle("踩人光环", "EspToggle", false, function(val)
    settings.StompAura = val
    stompAuraLoop()
end)
sectionStompAura:Slider("踩人距离", "Slider", 25, 0.1, 100, true, function(val)
    settings.StompAuraDistance = val
end)

function GrabAura()
    while settings.GrabAura do
        if _G.ScriptIsRunning == false then return end
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.GrabAura == false then return end
                if player ~= LocalPlayer and not table.find(combatWhitelist, player.Name) and not table.find(blacklistedNames, player.Name) then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < settings.GrabAuraDistance and player.Character.Humanoid.Health < 10 and player.Character.Humanoid.Health ~= 0 then
                        FireServer("grabPlayer", player)
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionGrabAura:Toggle("抱人光环", "EspToggle", false, function(val)
    settings.GrabAura = val
    GrabAura()
end)
sectionGrabAura:Slider("抱人距离", "Slider", 25, 0.1, 100, true, function(val)
    settings.GrabAuraDistance = val
end)

for _, obj in pairs(game.CoreGui:GetChildren()) do
    if obj.Name == "ALbot" and obj:IsA("ScreenGui") then
        obj:Destroy()
    end
end
local aimGui = Instance.new("ScreenGui")
local aimButtonFrame = Instance.new("Frame")
local aimButtonImage = Instance.new("ImageButton")
local uiCorner = Instance.new("UICorner")
local uiStroke = Instance.new("UIStroke")
aimGui.Name = "ALbot"
aimGui.Parent = game.CoreGui
aimButtonFrame.Name = "AimButton"
aimButtonFrame.Parent = aimGui
aimButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
aimButtonFrame.BackgroundTransparency = 0.5
aimButtonFrame.Position = UDim2.new(0.0485268645, 0, 0.269377351, 0)
aimButtonFrame.Size = UDim2.new(0, 54, 0, 54)
aimButtonImage.Parent = aimButtonFrame
aimButtonImage.BackgroundTransparency = 1
aimButtonImage.Size = UDim2.new(1, 0, 1, 0)
aimButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
aimButtonImage.Position = UDim2.new(0.5, 0, 0.5, 0)
aimButtonImage.Image = "rbxassetid://6922963617"
aimButtonImage.AutoButtonColor = false
uiCorner.CornerRadius = UDim.new(0.3, 0)
uiCorner.Name = "UIC"
uiCorner.Parent = aimButtonFrame
uiStroke.Transparency = 0.5
uiStroke.Name = "UIS"
uiStroke.Parent = aimButtonFrame

local aimButtonRotation = 0
aimButtonImage.MouseButton1Click:Connect(function()
    if settings.Aimbot ~= false then
        task.spawn(function()
            game:GetService("TweenService"):Create(aimButtonFrame, TweenInfo.new(0.5), {
                ["BackgroundColor3"] = Color3.fromRGB(255, 0, 0)
            }):Play()
        end)
        settings.Aimbot = false
        aimbotData.Enemy = nil
    else
        task.spawn(function()
            game:GetService("TweenService"):Create(aimButtonFrame, TweenInfo.new(0.5), {
                ["BackgroundColor3"] = Color3.fromRGB(0, 255, 0)
            }):Play()
        end)
        settings.Aimbot = true
        aimbotData.Enemy = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if settings.Aimbot ~= true then
        aimButtonRotation = 0
        aimButtonImage.Rotation = aimButtonRotation
    else
        aimButtonRotation = aimButtonRotation + 1
        aimButtonImage.Rotation = aimButtonRotation
    end
end)

tabAim:Toggle("子弹追踪", "SilentAim", false, function(val)
    settings.SilentAim = val
    aimbotData.Line.Visible = false
end)
tabAim:Toggle("显示范围", "EspToggle", false, function(val)
    aimbotData.Circle.Visible = val
    updateCircle()
end)
tabAim:Toggle("范围填充", "EspToggle", false, function(val)
    aimbotData.Circle.Filled = val
    updateCircle()
end)
tabAim:Slider("自瞄范围", "FillTncy", 200, 1, 600, true, function(val)
    aimbotData.Circle.Radius = val
    updateCircle()
end)
tabAim:Toggle("目标连线", "EspToggle", false, function(val)
    aimbotData.LineEnabled = val
end)
tabAim:Slider("范围厚度", "FillTncy", 1, 1, 10, true, function(val)
    aimbotData.Circle.Thickness = val
    updateCircle()
end)
tabAim:Slider("范围透明度", "FillTncy", 1, 0, 1, true, function(val)
    aimbotData.Circle.Transparency = val
    updateCircle()
end)
tabAim:Dropdown("范围颜色", "SelectFillColor", {
    "白",
    "红",
    "绿",
    "蓝",
    "粉",
    "青"
}, function(val)
    if val == "白" then
        aimbotData.Circle.Color = Color3.fromRGB(255, 255, 255)
    elseif val == "红" then
        aimbotData.Circle.Color = colors.Red
    elseif val == "绿" then
        aimbotData.Circle.Color = colors.Green
    elseif val == "蓝" then
        aimbotData.Circle.Color = colors.Blue
    elseif val == "粉" then
        aimbotData.Circle.Color = colors.Pink
    elseif val == "青" then
        aimbotData.Circle.Color = colors.Cyan
    end
    updateCircle()
end)
tabAim:Slider("预判自瞄", "Slider", 17.6, 0.1, 25, true, function(val)
    aimbotData.Aimbot.Epitaph = val
end)
tabAim:Toggle("显示预判自瞄", "EspToggle", false, function(val)
    aimbotData.Aimbot.ShowEpitaph = val
end)
tabAim:Dropdown("自瞄部位", "AimPart", {
    "头",
    "上身",
    "鸡巴",
    "左大臂",
    "左小臂",
    "左手",
    "右大臂",
    "右小臂",
    "右手",
    "左大腿",
    "左小腿",
    "左脚",
    "右大腿",
    "右小腿",
    "右脚"
}, function(val)
    if val == "头" then
        aimbotData.AimPart = "Head"
    elseif val == "上身" then
        aimbotData.AimPart = "UpperTorso"
    elseif val == "鸡巴" then
        aimbotData.AimPart = "LowerTorso"
    elseif val == "左上臂" then
        aimbotData.AimPart = "LeftUpperArm"
    elseif val == "左小臂" then
        aimbotData.AimPart = "LeftLowerArm"
    elseif val == "左手" then
        aimbotData.AimPart = "LeftHand"
    elseif val == "右上臂" then
        aimbotData.AimPart = "RightUpperArm"
    elseif val == "右小臂" then
        aimbotData.AimPart = "RightLowerArm"
    elseif val == "右手" then
        aimbotData.AimPart = "RightHand"
    elseif val == "左大腿" then
        aimbotData.AimPart = "LeftUpperLeg"
    elseif val == "左小腿" then
        aimbotData.AimPart = "LeftLowerLeg"
    elseif val == "左脚" then
        aimbotData.AimPart = "LeftFoot"
    elseif val == "右大腿" then
        aimbotData.AimPart = "RightUpperLeg"
    elseif val == "右小腿" then
        aimbotData.AimPart = "RightLowerLeg"
    elseif val == "右脚" then
        aimbotData.AimPart = "RightFoot"
    end
end)
tabAim:Toggle("墙壁检测", "EspToggle", false, function(val)
    aimbotData.WallCheck = val
end)
tabAim:Toggle("粘性自瞄", "EspToggle", false, function(val)
    aimbotData.StickAim = val
    if val == false then
        aimbotData.Enemy = nil
    end
end)

local lockTargetLabel = tabAim:Label("当前锁定玩家: " .. tostring(aimbotData.Enemy))
local renderSteppedConn = nil
renderSteppedConn = RunService.RenderStepped:Connect(function()
    lockTargetLabel:Set("当前锁定玩家: " .. tostring(aimbotData.Enemy))
    Workspace.FallenPartsDestroyHeight = -math.huge
    if _G.ScriptIsRunning == false then
        renderSteppedConn:Disconnect()
    end
    if aimbotData.LineEnabled then
        if aimbotData.Enemy == nil then
            aimbotData.Line.Visible = false
        else
            local pos, onScreen = CurrentCamera:WorldToViewportPoint(aimbotData.Enemy[aimbotData.AimPart].Position)
            if onScreen then
                aimbotData.Line.To = Vector2.new(pos.X, pos.Y)
                aimbotData.Line.Visible = true
            end
        end
    end
    pcall(function()
        if settings.Aimbot and not settings.SilentAim then
            local enemy
            if aimbotData.StickAim ~= true or aimbotData.Enemy ~= nil then
                enemy = getClosestEnemy()
            else
                enemy = getClosestEnemy()
            end
            aimbotData.Enemy = enemy
            if aimbotData.Enemy == nil then
                aimbotData.Aimbot.EpitaphCircle.Visible = false
            else
                local predicted = aimbotData.Enemy[aimbotData.AimPart].CFrame + aimbotData.Enemy[aimbotData.AimPart].Velocity * aimbotData.Aimbot.Epitaph / 100
                if aimbotData.Aimbot.ShowEpitaph then
                    local screen = CurrentCamera:WorldToViewportPoint(predicted.Position)
                    aimbotData.Aimbot.EpitaphCircle.Visible = true
                    aimbotData.Aimbot.EpitaphCircle.Position = screen
                end
                setCameraCFrame(CurrentCamera.CFrame.p, predicted.Position)
            end
        end
    end)
end)

local oldNamecallSilent = nil
oldNamecallSilent = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    if getnamecallmethod() ~= "Raycast" or settings.SilentAim ~= true then
        return oldNamecallSilent(self, ...)
    end
    local origin = args[1]
    local enemy = getClosestEnemy()
    aimbotData.Enemy = enemy
    if aimbotData.Enemy ~= nil then
        local direction = (aimbotData.Enemy[aimbotData.AimPart].Position - origin).Unit * 1000
        args[2] = direction
    end
    return oldNamecallSilent(self, unpack(args))
end)

local hitboxSettings = { ["HitboxSize"] = 10 }

function HRPHitbox()
    while settings.HitboxToggle do
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.HitboxToggle == false then return end
                if player.Name ~= LocalPlayer.Name and player.Character ~= nil then
                    player.Character.HumanoidRootPart.Size = Vector3.new(hitboxSettings.HitboxSize, hitboxSettings.HitboxSize, hitboxSettings.HitboxSize)
                    player.Character.HumanoidRootPart.CanCollide = false
                    player.Character.HumanoidRootPart.Transparency = 0.5
                end
            end
        end)
        task.wait()
    end
end
sectionHitbox:Toggle("近战范围开关", "DDD29F", false, function(val)
    settings.HitboxToggle = val
    HRPHitbox()
    if val == false then
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if player.Name ~= LocalPlayer.Name and player.Character ~= nil then
                    player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    player.Character.HumanoidRootPart.CanCollide = true
                    player.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end)
    end
end)
sectionHitbox:Slider("范围", "FillTncy", 10, 1, 100, true, function(val)
    hitboxSettings.HitboxSize = val
end)

sectionAutoSpammer:Toggle("开关", "EspToggle", false, function(val)
    settings.AutoSpammer = val
end)
sectionAutoSpammer:Textbox("嘲讽内容", "Textbox", "B赞搜索灾难蛋购买脚本!", function(val)
    settings.AutoSpammerText = val
end)

task.spawn(function()
    pcall(function()
        for _, player in pairs(Players:GetChildren()) do
            if player ~= LocalPlayer then
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
                        if settings.AutoSpammer and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 12 then
                            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(settings.AutoSpammerText), "All")
                        end
                    end)
                end
                player.CharacterAdded:Connect(function(char)
                    repeat task.wait() until char:FindFirstChild("Humanoid")
                    char.Humanoid.Died:Connect(function()
                        if settings.AutoSpammer and (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 12 then
                            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(settings.AutoSpammerText), "All")
                        end
                    end)
                end)
            end
        end
    end)
end)

Players.PlayerAdded:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character:FindFirstChild("Humanoid").Died:Connect(function()
            if settings.AutoSpammer and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 12 then
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(settings.AutoSpammerText), "All")
            end
        end)
    end
    player.CharacterAdded:Connect(function(char)
        repeat task.wait() until char:FindFirstChild("Humanoid")
        char.Humanoid.Died:Connect(function()
            if settings.AutoSpammer and (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 12 then
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(settings.AutoSpammerText), "All")
            end
        end)
    end)
end)

function RespawnAtDeadPos()
    while settings.RespawnAtDeadPos do
        pcall(function()
            if LocalPlayer.Character.Humanoid.Health == 0 and not LocalPlayer.Character:FindFirstChild("Tag") then
                local deadCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                local tag = Instance.new("BoolValue")
                tag.Parent = LocalPlayer.Character
                tag.Name = "Tag"
                repeat task.wait() until LocalPlayer.Character ~= nil and tag.Parent ~= LocalPlayer.Character
                task.wait(settings.RespawnAtDeadPosWait)
                LocalPlayer.Character.HumanoidRootPart.CFrame = deadCFrame
            end
        end)
        task.wait()
    end
end
sectionRespawn:Toggle("开关", "EspToggle", false, function(val)
    settings.RespawnAtDeadPos = val
    RespawnAtDeadPos()
end)
sectionRespawn:Slider("等待时间", "FillTransparency", 1, 0.1, 5, true, function(val)
    settings.RespawnAtDeadPosWait = val
end)

sectionInteract:Toggle("快速互动", "InstantPrompt", false, function(val)
    settings.InstantPrompt = val
end)

sectionBlackMarket:Button("售卖手中的物品", function()
    pcall(function()
        fireproximityprompt(BlackMarket.Dealer.Dealer.ProximityPrompt)
    end)
end)

function ShowLocker()
    while settings.ShowLocker do
        pcall(function()
            PlayerGui.Backpack.Enabled = true
            PlayerGui.Backpack.Holder.Locker.Visible = true
        end)
        task.wait()
    end
end
sectionLocker:Toggle("显示储存柜", "ShowLocker", false, function(val)
    settings.ShowLocker = val
    ShowLocker()
end)

local itemNameMap = {}
local itemDisplayNames = {}
for _, item in pairs(ItemsOnSale:GetChildren()) do
    if not table.find(itemNameMap, item.Name) then
        table.insert(itemNameMap, item.Name)
    end
end
for _, child in pairs(itemStoreBillboard:GetChildren()) do
    if child:FindFirstChild("TopLabel") and child.Adornee ~= nil then
        if table.find(itemNameMap, child.Adornee.Parent.Name) then
            itemNameMap[child.Adornee.Parent.Name] = child:FindFirstChild("TopLabel").LocalizedText
        end
        if not table.find(itemDisplayNames, child:FindFirstChild("TopLabel").LocalizedText) then
            table.insert(itemDisplayNames, child:FindFirstChild("TopLabel").LocalizedText)
            itemDisplayNames[child:FindFirstChild("TopLabel").LocalizedText] = child.Adornee.Parent.Name
        end
    end
end

sectionBuy:Dropdown("道具列表", "sb", itemDisplayNames, function(displayName)
    for id, name in pairs(itemNameMap) do
        if name == displayName then
            settings.BuyItem = id
        end
    end
end)
sectionBuy:Button("购买物品", function()
    if settings.BuyItem == nil then
        notifyLib:Notify("未选择物品", 1)
    else
        InvokeServer("attemptPurchase", settings.BuyItem)
        notifyLib:Notify("购买成功 " .. settings.BuyItem, 1)
    end
end)
sectionBuy:Button("购买子弹", function()
    if settings.BuyItem == nil then
        notifyLib:Notify("未选择物品", 1)
    else
        InvokeServer("attemptPurchaseAmmo", settings.BuyItem)
        notifyLib:Notify("购买成功 " .. settings.BuyItem, 1)
    end
end)
sectionBuy:Button("传送到购买点", function()
    if settings.BuyItem == nil then
        notifyLib:Notify("未选择物品", 1)
    elseif ItemsOnSale:FindFirstChild(settings.BuyItem) then
        local item = ItemsOnSale:FindFirstChild(settings.BuyItem)
        if item:FindFirstChild("Button") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = item.Button.CFrame
        else
            notifyLib:Notify("购买按钮未加载", 1)
        end
    else
        notifyLib:Notify("无效的物品", 1)
    end
end)

local function christmasLoop()
    while settings.Christmas do
        for _, mob in pairs(ChristmasMobs:GetChildren()) do
            if settings.Christmas ~= true then return end
            if mob:GetAttribute("mobName") then
                mob:SetAttribute("health", 0)
                InvokeServer("attemptCollectMob", mob:GetAttribute("mobName"), mob.Name)
                task.wait(0.1)
                for _ = 1, 4 do
                    FireServer("collectGingerbread", 40)
                end
            end
        end
        task.wait()
    end
end
sectionChristmas:Toggle("开关", "Christmas", false, function(val)
    settings.Christmas = val
    christmasLoop()
end)

local moneyFarmSettings = {
    ["MinRandomWait"] = 0.5,
    ["MaxRandomWait"] = 2,
    ["MinMoney"] = 300
}

function MoneyFarm()
    while settings.MoneyFarm do
        for _, cash in pairs(CashBundle:GetChildren()) do
            if settings.MoneyFarm == false then return end
            pcall(function()
                if cash:FindFirstChildOfClass("IntValue").Value >= moneyFarmSettings.MinMoney then
                    notifyLib:Notify("传送到金钱", 0.5)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = cash:FindFirstChildOfClass("Part").CFrame * CFrame.new(0, 4, 0)
                    task.wait(math.random(moneyFarmSettings.MinRandomWait, moneyFarmSettings.MaxRandomWait))
                    notifyLib:Notify("尝试拾取金钱", 0.5)
                    fireclickdetector(cash:FindFirstChildOfClass("ClickDetector") or cash:FindFirstChildOfClass("Part"):FindFirstChildOfClass("ClickDetector"))
                    task.wait(math.random(moneyFarmSettings.MinRandomWait, moneyFarmSettings.MaxRandomWait))
                end
            end)
        end
        task.wait()
    end
end
sectionMoney:Toggle("自动捡钱", "EspToggle", false, function(val)
    settings.MoneyFarm = val
    MoneyFarm()
end)

function MoneyAura()
    while settings.MoneyAura do
        for _, cash in pairs(CashBundle:GetChildren()) do
            if settings.MoneyAura == false then return end
            pcall(function()
                local part = cash:FindFirstChildOfClass("Part")
                if (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude <= 6.5 then
                    fireclickdetector(cash:FindFirstChildOfClass("ClickDetector") or part:FindFirstChildOfClass("ClickDetector"))
                end
            end)
        end
        task.wait()
    end
end
sectionMoney:Toggle("捡钱光环", "EspToggle", false, function(val)
    settings.MoneyAura = val
    MoneyAura()
end)
sectionMoney:Slider("最小钱数", "FillTransparency", 300, 20, 100000, true, function(val)
    moneyFarmSettings.MinMoney = val
end)
sectionMoney:Slider("最小随机等待数值", "FillTransparency", 0.5, 0.5, 2, true, function(val)
    moneyFarmSettings.MinRandomWait = val
end)
sectionMoney:Slider("最大随机等待数值", "FillTransparency", 2, 2, 5, true, function(val)
    moneyFarmSettings.MaxRandomWait = val
end)

local itemFarmSettings = {
    ["IsSelectItem"] = false,
    ["MinRandomWait"] = 0.5,
    ["MaxRandomWait"] = 2,
    ["SelectItem"] = {}
}

function ItemsFarm()
    while settings.ItemsFarm do
        pcall(function()
            for _, item in pairs(ItemPickup:GetChildren()) do
                if settings.ItemsFarm == false then return end
                local shouldPick = true
                if itemFarmSettings.IsSelectItem then
                    shouldPick = false
                    for _, child in pairs(item:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and table.find(itemFarmSettings.SelectItem, child.ObjectText) then
                            shouldPick = true
                            break
                        end
                    end
                end
                if shouldPick then
                    notifyLib:Notify("传送到物品", 0.5)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = item:FindFirstChildOfClass("Part").CFrame * CFrame.new(0, 4, 0)
                    task.wait(math.random(itemFarmSettings.MinRandomWait, itemFarmSettings.MaxRandomWait))
                    notifyLib:Notify("尝试拾取物品", 0.5)
                    fireclickdetector(item:FindFirstChildOfClass("ClickDetector") or item:FindFirstChildOfClass("Part"):FindFirstChildOfClass("ClickDetector"))
                    task.wait(math.random(itemFarmSettings.MinRandomWait, itemFarmSettings.MaxRandomWait))
                end
            end
        end)
        task.wait()
    end
end
sectionItems:Toggle("自动捡物品", "EspToggle", false, function(val)
    settings.ItemsFarm = val
    ItemsFarm()
end)

function ItemAura()
    while settings.ItemAura do
        pcall(function()
            for _, item in pairs(ItemPickup:GetChildren()) do
                if settings.ItemAura == false then return end
                local part = item:FindFirstChildOfClass("Part")
                if (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude <= 6.5 then
                    fireclickdetector(item:FindFirstChildOfClass("ClickDetector") or part:FindFirstChildOfClass("ClickDetector"))
                end
            end
        end)
        task.wait()
    end
end
sectionItems:Toggle("物品光环", "EspToggle", false, function(val)
    settings.ItemAura = val
    ItemAura()
end)
sectionItems:Label("设置")
sectionItems:Slider("最小随机等待数值", "FillTransparency", 0.5, 0.5, 2, true, function(val)
    itemFarmSettings.MinRandomWait = val
end)
sectionItems:Slider("最大随机等待数值", "FillTransparency", 2, 2, 5, true, function(val)
    itemFarmSettings.MaxRandomWait = val
end)

local selectedItemsLabelText = "选中的物品: "
local selectedItemsLabel = sectionItems:Label(selectedItemsLabelText)
sectionItems:Dropdown("道具列表", "sb", { "红卡", "蓝卡", "印钞机" }, function(display)
    if display == "红卡" then
        table.insert(itemFarmSettings.SelectItem, "Military Armory Keycard")
        selectedItemsLabelText = selectedItemsLabelText .. "/" .. display
        selectedItemsLabel:Set(selectedItemsLabelText)
    elseif display == "蓝卡" then
        table.insert(itemFarmSettings.SelectItem, "Police Armory Keycard")
        selectedItemsLabelText = selectedItemsLabelText .. "/" .. display
        selectedItemsLabel:Set(selectedItemsLabelText)
    elseif display == "印钞机" then
        table.insert(itemFarmSettings.SelectItem, "Money Printer")
        selectedItemsLabelText = selectedItemsLabelText .. "/" .. display
        selectedItemsLabel:Set(selectedItemsLabelText)
    end
end)
sectionItems:Button("清空选中物品", function()
    pcall(function()
        table.clear(itemFarmSettings.SelectItem)
        selectedItemsLabelText = "选中的物品: "
        selectedItemsLabel:Set(selectedItemsLabelText)
    end)
end)
sectionItems:Toggle("仅自动捡起选中的道具", "EspToggle", false, function(val)
    itemFarmSettings.IsSelectItem = val
end)

local bankFarmSettings = {
    ["MinRandomWait"] = 0.1,
    ["MaxRandomWait"] = 1,
    ["RobLoots"] = false
}

function BankFarm()
    while settings.BankFarm do
        pcall(function()
            if #BankRobbery.BankCash.Cash:GetChildren() > 0 then
                if BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.Enabled ~= true then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = BankRobbery.BankCash.Main.CFrame
                    task.wait(math.random(bankFarmSettings.MinRandomWait, bankFarmSettings.MaxRandomWait))
                    fireproximityprompt(BankRobbery.BankCash.Main.Attachment.ProximityPrompt)
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = BankRobbery.VaultDoor.Door.CFrame
                    task.wait(math.random(bankFarmSettings.MinRandomWait, bankFarmSettings.MaxRandomWait))
                    fireproximityprompt(BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt)
                end
            end
        end)
        task.wait()
    end
end
sectionBank:Toggle("自动抢银行", "EspToggle", false, function(val)
    settings.BankFarm = val
    BankFarm()
end)
sectionBank:Slider("最小随机等待数值", "FillTransparency", 0.3, 0, 1, true, function(val)
    bankFarmSettings.MinRandomWait = val
end)
sectionBank:Slider("最小随机等待数值", "FillTransparency", 1, 1, 2, true, function(val)
    bankFarmSettings.MaxRandomWait = val
end)

function JewelryCasesAura()
    while settings.JewelryCasesAura do
        pcall(function()
            for _, spawn in pairs(JewelryCases.LowYieldSpawns:GetChildren()) do
                if settings.JewelryCasesAura == false then return end
                if spawn.Name ~= "Case" and spawn.Name ~= "Glass" then
                    for _, child in pairs(spawn:GetDescendants()) do
                        if settings.JewelryCasesAura == false then return end
                        if child:IsA("ProximityPrompt") and child.Enabled and (LocalPlayer.Character.HumanoidRootPart.Position - child.Parent.Position).Magnitude <= 3 then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
            for _, spawn in pairs(JewelryCases.HighYieldSpawns:GetChildren()) do
                if settings.JewelryCasesAura == false then return end
                if spawn.Name ~= "Case" and spawn.Name ~= "Glass" then
                    for _, child in pairs(spawn:GetDescendants()) do
                        if settings.JewelryCasesAura == false then return end
                        if child:IsA("ProximityPrompt") and child.Enabled and (LocalPlayer.Character.HumanoidRootPart.Position - child.Parent.Position).Magnitude <= 3 then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionJewelry:Toggle("珠宝光环", "EspToggle", false, function(val)
    settings.JewelryCasesAura = val
    JewelryCasesAura()
end)

function AutoFarmJewelryCases()
    while settings.AutoFarmJewelryCases do
        pcall(function()
            for _, spawn in pairs(JewelryCases.LowYieldSpawns:GetChildren()) do
                if settings.AutoFarmJewelryCases == false then return end
                if spawn.Name ~= "Case" and spawn.Name ~= "Glass" then
                    for _, child in pairs(spawn:GetChildren()) do
                        if settings.AutoFarmJewelryCases == false then return end
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = child.Parent.CFrame
                            task.wait(0.1)
                            fireproximityprompt(child)
                            task.wait(0.3)
                        end
                    end
                end
            end
            for _, spawn in pairs(JewelryCases.HighYieldSpawns:GetChildren()) do
                if settings.AutoFarmJewelryCases == false then return end
                if spawn.Name ~= "Case" and spawn.Name ~= "Glass" then
                    for _, child in pairs(spawn:GetChildren()) do
                        if settings.AutoFarmJewelryCases == false then return end
                        if child:FindFirstChild("Box") and child.Box:FindFirstChildOfClass("ProximityPrompt") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = child.Parent.CFrame
                            task.wait(0.1)
                            fireproximityprompt(child)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionJewelry:Toggle("自动捡珠宝", "EspToggle", false, function(val)
    settings.AutoFarmJewelryCases = val
    AutoFarmJewelryCases()
end)

function AutoFarmSafes()
    while settings.AutoFarmSafes do
        pcall(function()
            for _, safe in pairs(Entities.JewelSafe:GetChildren()) do
                if settings.AutoFarmSafes == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = safe.SafeMain.CFrame
                            task.wait(0.5)
                            fireproximityprompt(child)
                            task.wait(0.5)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.GoldJewelSafe:GetChildren()) do
                if settings.AutoFarmSafes == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = safe.SafeMain.CFrame
                            task.wait(0.5)
                            fireproximityprompt(child)
                            task.wait(0.5)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.SmallSafe:GetChildren()) do
                if settings.AutoFarmSafes == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = safe.SafeMain.CFrame
                            task.wait(0.5)
                            fireproximityprompt(child)
                            task.wait(0.5)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.MediumSafe:GetChildren()) do
                if settings.AutoFarmSafes == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = safe.SafeMain.CFrame
                            task.wait(0.5)
                            fireproximityprompt(child)
                            task.wait(0.5)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.LargeSafe:GetChildren()) do
                if settings.AutoFarmSafes == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = safe.SafeMain.CFrame
                            task.wait(0.5)
                            fireproximityprompt(child)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionSafes:Toggle("自动开保险柜开关", "AutoFarmSafes", false, function(val)
    settings.AutoFarmSafes = val
    AutoFarmSafes()
end)

function SafesAura()
    while settings.SafesAura do
        pcall(function()
            for _, safe in pairs(Entities.JewelSafe:GetChildren()) do
                if settings.SafesAura == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") and (LocalPlayer.Character.HumanoidRootPart.Position - safe.SafeMain.Position).Magnitude < 10 then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.GoldJewelSafe:GetChildren()) do
                if settings.SafesAura == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") and (LocalPlayer.Character.HumanoidRootPart.Position - safe.SafeMain.Position).Magnitude < 10 then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.SmallSafe:GetChildren()) do
                if settings.SafesAura == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") and (LocalPlayer.Character.HumanoidRootPart.Position - safe.SafeMain.Position).Magnitude < 10 then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.MediumSafe:GetChildren()) do
                if settings.SafesAura == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") and (LocalPlayer.Character.HumanoidRootPart.Position - safe.SafeMain.Position).Magnitude < 10 then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
            for _, safe in pairs(Entities.LargeSafe:GetChildren()) do
                if settings.SafesAura == false then return end
                if safe:IsA("Model") and safe:FindFirstChild("Door") and (LocalPlayer.Character.HumanoidRootPart.Position - safe.SafeMain.Position).Magnitude < 10 then
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("ProximityPrompt") and child.Enabled then
                            fireproximityprompt(child)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end
sectionSafes:Toggle("保险柜光环", "SafesAura", false, function(val)
    settings.SafesAura = val
    SafesAura()
end)

local function airdropLoop()
    while settings.AutoFarmAirdrop do
        pcall(function()
            for _, airdrop in pairs(Airdrops:GetChildren()) do
                if airdrop:FindFirstChild("Airdrop") and airdrop:FindFirstChild("Airdrop"):FindFirstChildOfClass("ProximityPrompt") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = airdrop:FindFirstChild("Airdrop").CFrame
                    task.wait(0.2)
                    fireproximityprompt(airdrop:FindFirstChild("Airdrop"):FindFirstChildOfClass("ProximityPrompt"))
                end
            end
        end)
        task.wait()
    end
end
sectionAirdrop:Toggle("自动捡空投", "SafesAura", false, function(val)
    settings.AutoFarmAirdrop = val
    airdropLoop()
end)

local locationCFrames = {
    ["商店"] = CFrame.new(674, 6, -694),
    ["家具店"] = CFrame.new(891, 6, -774),
    ["便利店"] = CFrame.new(913, 6, -894),
    ["游戏厅"] = CFrame.new(836, 6, -906),
    ["警察局"] = CFrame.new(646, 9, -865),
    ["披萨餐厅"] = CFrame.new(469, 8, -861),
    ["高级家具城"] = CFrame.new(375, -5, -408),
    ["黑市"] = CFrame.new(655, -16, -77),
    ["银行"] = CFrame.new(1084, 8, -380),
    ["咖啡餐厅"] = CFrame.new(1331, 8, -329),
    ["游乐场"] = CFrame.new(1177, 13, -25),
    ["珠宝店"] = CFrame.new(1579, 8, -689),
    ["健身房"] = CFrame.new(1593, 6, -317),
    ["医院"] = CFrame.new(1152, 6, -974),
    ["手机店"] = CFrame.new(853, 6, -1048),
    ["军事基地"] = CFrame.new(796, 25, -1336)
}
tabTeleport:Dropdown("地点列表", "Locates", {
    "商店",
    "家具店",
    "便利店",
    "游戏厅",
    "警察局",
    "披萨餐厅",
    "高级家具城",
    "黑市",
    "银行",
    "咖啡餐厅",
    "游乐场",
    "珠宝店",
    "健身房",
    "医院",
    "手机店",
    "军事基地"
}, function(loc)
    settings.SelectLocate = locationCFrames[loc]
end)
tabTeleport:Button("传送到地点", function()
    pcall(function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = settings.SelectLocate
    end)
end)

local allPartsForBring = {}
local bodyPositionsForBring = {}
for _, obj in pairs(Props:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        table.insert(allPartsForBring, obj)
    end
end
Props.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        table.insert(allPartsForBring, obj)
        if settings.BringUnAnchored then
            obj.CanCollide = true
            local bp = Instance.new("BodyPosition")
            bp.Parent = obj
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            table.insert(bodyPositionsForBring, bp)
        end
    end
end)

tabFun:Toggle("吸物体到身体前面", "EspToggle", false, function(val)
    settings.BringUnAnchored = val
    if val then
        for _, part in pairs(allPartsForBring) do
            pcall(function()
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
                part.CanCollide = true
                local bp = Instance.new("BodyPosition")
                bp.Parent = part
                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                table.insert(bodyPositionsForBring, bp)
            end)
        end
    else
        for _, bp in pairs(bodyPositionsForBring) do
            pcall(function()
                bp:Destroy()
            end)
        end
        table.clear(bodyPositionsForBring)
    end
end)

task.spawn(function()
    while _G.ScriptIsRunning do
        pcall(function()
            if settings.BringUnAnchored then
                for _, bp in pairs(bodyPositionsForBring) do
                    if settings.BringUnAnchored == false then return end
                    bp.Position = LocalPlayer.Character.HumanoidRootPart.Position
                end
            end
        end)
        task.wait()
    end
end)

local funPlayerDropdown = tabFun:Dropdown("玩家列表", "Players", playerNames, function(player)
    settings.FunTarget = player
end)

tabFun:Label("改的动作全部人可以看见")

function MessageSpammer()
    while settings.MessageSpammer do
        if Players:FindFirstChild(settings.FunTarget) then
            FireServer("sendMessage", Players:FindFirstChild(settings.FunTarget).UserId, settings.MessageSpammerText)
        end
        task.wait()
    end
end

function MESSAGENUKE()
    while settings.MessageNuke do
        for _, player in pairs(Players:GetChildren()) do
            if player ~= LocalPlayer then
                FireServer("sendMessage", player.UserId, settings.MessageSpammerText)
            end
        end
        task.wait()
    end
end

tabFun:Textbox("轰炸信息", "Textbox", "B赞搜索灾难蛋购买脚本!", function(val)
    settings.MessageSpammerText = val
end)
tabFun:Toggle("手机信息轰炸(个人)", "EspToggle", false, function(val)
    settings.MessageSpammer = val
    MessageSpammer()
end)
tabFun:Toggle("手机信息轰炸(全体)", "EspToggle", false, function(val)
    settings.MessageNuke = val
    MESSAGENUKE()
end)

function PhoneSpammer()
    while settings.PhoneSpammer do
        pcall(function()
            InvokeServer("attemptCall", Players:FindFirstChild(settings.FunTarget).UserId)
        end)
        task.wait()
    end
end
tabFun:Toggle("电话骚扰", "EspToggle", false, function(val)
    settings.PhoneSpammer = val
    PhoneSpammer()
end)

function ChangeAnimate()
    while settings.ChangeAnimate do
        pcall(function()
            local char = LocalPlayer.Character
            local anim = char and char.Animate
            if not anim then return end
            if settings.AnimateSelect == "宇航员" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
            elseif settings.AnimateSelect == "卡通" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
            elseif settings.AnimateSelect == "开心" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=910009958"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
                anim.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=910030921"
                anim.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=910028158"
            elseif settings.AnimateSelect == "长老" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
            elseif settings.AnimateSelect == "悬空人" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
            elseif settings.AnimateSelect == "骑士" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
            elseif settings.AnimateSelect == "忍者" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
            elseif settings.AnimateSelect == "大法师" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
            elseif settings.AnimateSelect == "机器人" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616088211"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616089559"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616095330"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616091570"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616090535"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616086039"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616087089"
            elseif settings.AnimateSelect == "海盗" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
            elseif settings.AnimateSelect == "超级英雄" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
            elseif settings.AnimateSelect == "优雅" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"
            elseif settings.AnimateSelect == "吸血鬼" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"
            elseif settings.AnimateSelect == "玩具人" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"
            elseif settings.AnimateSelect == "僵尸" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
            elseif settings.AnimateSelect == "狼人" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
            elseif settings.AnimateSelect == "自信人" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1069977950"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1069987858"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1070017263"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1070001516"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1069984524"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1069946257"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1069973677"
            elseif settings.AnimateSelect == "巡逻警察" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1149612882"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1151231493"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1150967949"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1148863382"
            elseif settings.AnimateSelect == "牛仔" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1014390418"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1014398616"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1014421541"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1014401683"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1014394726"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1014380606"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1014384571"
            elseif settings.AnimateSelect == "明星" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1212900985"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980338"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980348"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1212954642"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1213044953"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1212900995"
            elseif settings.AnimateSelect == "小偷" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1132473842"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1132477671"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1132510133"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1132494274"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1132489853"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1132461372"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1132469004"
            elseif settings.AnimateSelect == "幽灵" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
                anim.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=616012453"
                anim.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=616011509"
            elseif settings.AnimateSelect == "国王" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=941003647"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=941013098"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=941028902"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=941015281"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=941008832"
                anim.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=940996062"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=941000007"
            elseif settings.AnimateSelect == "无" then
                anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
                anim.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
        task.wait()
    end
end

tabFun:Dropdown("选择修改的动作包", "sb", {
    "宇航员",
    "卡通",
    "开心",
    "长老",
    "悬空人",
    "骑士",
    "忍者",
    "大法师",
    "机器人",
    "海盗",
    "超级英雄",
    "优雅",
    "吸血鬼",
    "玩具人",
    "僵尸",
    "狼人",
    "自信人",
    "巡逻警察",
    "牛仔",
    "明星",
    "小偷",
    "幽灵",
    "国王",
    "无"
}, function(val)
    settings.AnimateSelect = val
end)
tabFun:Toggle("修改动画开关", "EspToggle", false, function(val)
    settings.ChangeAnimate = val
    ChangeAnimate()
end)

local shadowbannedExpires = require(stateModule).data.shadowbannedExpires
local shadowbannedAt = require(stateModule).data.shadowbannedAt
local shadowbanned = require(stateModule).data.shadowbanned
local numshadowbans = require(stateModule).data.numshadowbans
local banEnd = not shadowbannedExpires and "无" or os.date("%Y-%m-%d %H:%M:%S", shadowbannedExpires)
local banStart = not shadowbannedAt and "无" or os.date("%Y-%m-%d %H:%M:%S", shadowbannedAt)
local banRemaining = not (shadowbannedExpires and shadowbannedAt) and 0 or getTimeString(shadowbannedExpires - shadowbannedAt)

sectionMoneyData:Label("当前钱数 " .. require(stateModule).data.money)
sectionMoneyData:Label("历史总钱数 " .. require(stateModule).data.totalMoneyEarned)
sectionMoneyData:Label("当前Robux花费 " .. require(stateModule).data.robuxSpent)
sectionMoneyData:Label("ATM抢劫金钱 " .. require(stateModule).data.atmsRobbed)
sectionMoneyData:Label("宝石抢劫金钱 " .. require(stateModule).data.gemsRobbed)
sectionMoneyData:Label("历史最高连续登陆 " .. require(stateModule).data.topLoginStreak)
sectionMoneyData:Label("工作赚钱金钱 " .. require(stateModule).data.jobEarnings)
sectionBanData:Label("封禁结束期 " .. banEnd)
sectionBanData:Label("封禁开始期 " .. banStart)
sectionBanData:Label("剩余封禁时间 " .. banRemaining)
sectionBanData:Label("历史封禁次数 " .. (numshadowbans or 0))
sectionBanData:Label("封禁原因 " .. (shadowbanned or "无"))

sectionEspToggle:Toggle("透视开关", "EspToggle", false, function(val)
    settings.EspToggle = val
    if val == false then
        for _, player in pairs(Players:GetChildren()) do
            if player ~= LocalPlayer then
                UpdateEsp(player.Name, settings.SelectFillColor)
            end
        end
    end
end)
sectionEspToggle:Toggle("上色开关", "HighlightToggle", false, function(val)
    settings.HighlightToggle = val
end)
sectionEspSettings:Dropdown("透视颜色", "SelectFillColor", {
    "红",
    "绿",
    "蓝",
    "粉",
    "青"
}, function(val)
    if val == "红" then
        settings.SelectFillColor = colors.Red
    elseif val == "绿" then
        settings.SelectFillColor = colors.Green
    elseif val == "蓝" then
        settings.SelectFillColor = colors.Blue
    elseif val == "粉" then
        settings.SelectFillColor = colors.Pink
    elseif val == "青" then
        settings.SelectFillColor = colors.Cyan
    end
end)
sectionEspSettings:Toggle("显示用户名", "HighlightToggle", false, function(val)
    settings.EspName = val
    if val == false then
        for _, player in pairs(Players:GetChildren()) do
            if player ~= LocalPlayer then
                UpdateEsp(player.Name, settings.SelectFillColor)
            end
        end
    end
end)
sectionEspSettings:Toggle("透视金钱", "HighlightToggle", false, function(val)
    settings.EspMoneys = val
    if val == false then
        for _, cash in pairs(CashBundle:GetChildren()) do
            if cash:FindFirstChildOfClass("Part") then
                MoneyUpdateEsp(cash:FindFirstChildOfClass("IntValue").Value, cash:FindFirstChildOfClass("Part"), colors.Green)
            end
        end
    end
end)
sectionEspSettings:Toggle("透视物品", "HighlightToggle", false, function(val)
    settings.EspItems = val
    if val == false then
        for _, item in pairs(ItemPickup:GetChildren()) do
            if item:FindFirstChildOfClass("Part") then
                ItemUpdateEsp(item:FindFirstChildOfClass("Part"):FindFirstChildOfClass("ProximityPrompt").ObjectText, item:FindFirstChildOfClass("Part"), colors.Red)
            end
        end
    end
end)
sectionEspSettings:Slider("透视大小", "FillTransparency", 0.5, 0.1, 1, true, function(val)
    settings.EspScale = val
end)
sectionEspSettings:Slider("上色透明度", "FillTransparency", 0.5, 0, 1, true, function(val)
    settings.HighlightTransparency = val
end)

task.spawn(function()
    while _G.ScriptIsRunning do
        pcall(function()
            if settings.EspToggle and settings.EspMoneys then
                for _, cash in pairs(CashBundle:GetChildren()) do
                    if cash:FindFirstChildOfClass("Part") then
                        MoneyUpdateEsp(cash:FindFirstChildOfClass("IntValue").Value, cash:FindFirstChildOfClass("Part"), colors.Green)
                    end
                end
            end
        end)
        task.wait()
    end
end)

task.spawn(function()
    while _G.ScriptIsRunning do
        pcall(function()
            if settings.EspToggle and settings.EspItems then
                for _, item in pairs(ItemPickup:GetChildren()) do
                    if item:FindFirstChildOfClass("Part") then
                        ItemUpdateEsp(item:FindFirstChildOfClass("Part"):FindFirstChildOfClass("ProximityPrompt").ObjectText, item:FindFirstChildOfClass("Part"), colors.Red)
                    end
                end
            end
        end)
        task.wait()
    end
end)

task.spawn(function()
    while _G.ScriptIsRunning do
        pcall(function()
            if settings.EspToggle and settings.EspName then
                for _, player in pairs(Players:GetChildren()) do
                    if player.Name ~= LocalPlayer.Name then
                        UpdateEsp(player.Name, settings.SelectFillColor)
                    end
                end
            end
        end)
        task.wait()
    end
end)

local playerDropdown = tabPlayers:Dropdown("玩家列表", "Players", playerNames, function(player)
    settings.SelectPlr = player
end)
Players.PlayerAdded:Connect(function(player)
    table.insert(playerNames, player.Name)
    playerDropdown.AddOption(player.Name)
    whitelistDropdown.AddOption(player.Name)
    funPlayerDropdown.AddOption(player.Name)
end)
Players.PlayerRemoving:Connect(function(player)
    table.remove(playerNames, table.find(playerNames, player.Name))
    playerDropdown.RemoveOption(player.Name)
    whitelistDropdown.RemoveOption(player.Name)
    funPlayerDropdown.RemoveOption(player.Name)
end)

tabPlayers:Button("传送到选中的玩家", function()
    pcall(function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = Players:FindFirstChild(settings.SelectPlr).Character.HumanoidRootPart.CFrame
    end)
end)

function PredTeleport()
    while settings.PredTeleport do
        pcall(function()
            if Players:FindFirstChild(settings.SelectPlr).Character.Humanoid.Health ~= 0 then
                local target = Players:FindFirstChild(settings.SelectPlr)
                local predicted = target.Character.HumanoidRootPart.CFrame + target.Character.HumanoidRootPart.Velocity * (LocalPlayer:GetNetworkPing() * 2) * settings.PredValue
                LocalPlayer.Character.HumanoidRootPart.CFrame = predicted
            end
        end)
        task.wait()
    end
end
tabPlayers:Toggle("循环预判传送", "Snipe", false, function(val)
    settings.PredTeleport = val
    PredTeleport()
end)
tabPlayers:Slider("预判传送倍数", "FillTransparency", 2, 0.1, 300, true, function(val)
    settings.PredValue = val
end)

function SnipePlr()
    while settings.SnipePlr do
        pcall(function()
            if Players:FindFirstChild(settings.SelectPlr).Character.Humanoid.Health ~= 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Players:FindFirstChild(settings.SelectPlr).Character.HumanoidRootPart.CFrame - Players:FindFirstChild(settings.SelectPlr).Character.HumanoidRootPart.CFrame.LookVector * settings.BringPlayerDistance
            end
        end)
        task.wait()
    end
end
tabPlayers:Toggle("循环传送到玩家身后", "Snipe", false, function(val)
    settings.SnipePlr = val
    SnipePlr()
end)

function SnipeToHeadLookVector()
    while settings.SnipeToHeadLookVector do
        pcall(function()
            if Players:FindFirstChild(settings.SelectPlr).Character.Humanoid.Health ~= 0 then
                local target = Players:FindFirstChild(settings.SelectPlr).Character
                if target.Humanoid.SeatPart then
                    target.Humanoid.SeatPart.CFrame = LocalPlayer.Character.Head.CFrame + LocalPlayer.Character.Head.CFrame.LookVector * settings.BringPlayerDistance
                else
                    target.HumanoidRootPart.CFrame = LocalPlayer.Character.Head.CFrame + LocalPlayer.Character.Head.CFrame.LookVector * settings.BringPlayerDistance
                end
            end
        end)
        task.wait()
    end
end
tabPlayers:Toggle("吸选中的玩家", "Snipe", false, function(val)
    settings.SnipeToHeadLookVector = val
    SnipeToHeadLookVector()
end)

function SnipeAllPlrs()
    while settings.SnipeAllPlrs do
        pcall(function()
            for _, player in pairs(Players:GetChildren()) do
                if settings.SnipeAllPlrs == false then return end
                if player ~= LocalPlayer and player.Character and player.Character.Humanoid.Health ~= 0 then
                    player.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.Head.CFrame + LocalPlayer.Character.Head.CFrame.LookVector * settings.BringPlayerDistance
                end
            end
        end)
        task.wait()
    end
end
tabPlayers:Toggle("吸全体玩家", "Snipe", false, function(val)
    settings.SnipeAllPlrs = val
    SnipeAllPlrs()
end)
tabPlayers:Slider("距离", "FillTransparency", 6, 0, 20, true, function(val)
    settings.BringPlayerDistance = val
end)

local walkSettings = { ["Tpwalk"] = 0 }
local walkConn = nil
walkConn = RunService.RenderStepped:Connect(function()
    if _G.ScriptIsRunning == false then
        walkConn:Disconnect()
    end
    pcall(function()
        if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(LocalPlayer.Character.Humanoid.MoveDirection * walkSettings.Tpwalk / 10)
        end
    end)
end)
sectionLocalPlayer:Slider("移动速度", "Slider", 0, 0, 300, true, function(val)
    walkSettings.Tpwalk = val
end)

function NoclipFunc()
    while settings.Noclip do
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        task.wait()
    end
end
sectionLocalPlayer:Toggle("穿墙", "Noclip", false, function(val)
    settings.Noclip = val
    if val == false then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and (part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso") then
                    part.CanCollide = true
                end
            end
        end)
    end
    NoclipFunc()
end)

sectionChat:Toggle("显示聊天框", "InfJump", false, function(val)
    PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = val
    PlayerGui.Chat.Frame.ChatChannelParentFrame.Selectable = val
    PlayerGui.Chat.Frame.ChatBarParentFrame.Position = PlayerGui.Chat.Frame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), PlayerGui.Chat.Frame.ChatChannelParentFrame.Size.Y)
end)

sectionLocalPlayer:Toggle("无限跳", "InfJump", false, function(val)
    settings.InfJump = val
end)
UserInputService.JumpRequest:Connect(function()
    if settings.InfJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

function FlyFunc()
    while settings.Fly do
        pcall(function()
            Workspace.Gravity = 0
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            local states = Enum.HumanoidStateType:GetEnumItems()
            table.remove(states, table.find(states, Enum.HumanoidStateType.None))
            for _, state in pairs(states) do
                humanoid:SetStateEnabled(state, false)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            LocalPlayer.Character.HumanoidRootPart.Velocity = (humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and LocalPlayer.Character.HumanoidRootPart.Velocity or Vector3.new()
        end)
        task.wait()
    end
end
local defaultGravity = Workspace.Gravity
sectionLocalPlayer:Toggle("飞行", "Fly", false, function(val)
    settings.Fly = val
    if val == false then
        Workspace.Gravity = defaultGravity
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local states = Enum.HumanoidStateType:GetEnumItems()
        for _, state in pairs(states) do
            humanoid:SetStateEnabled(state, true)
        end
    end
    FlyFunc()
end)

function Fling()
    if settings.Fling then
        repeat
            RunService.Heartbeat:Wait()
            pcall(function()
                local char = LocalPlayer.Character
                local root = char.HumanoidRootPart
                local vel = 0.1
                while not (char and char.Parent and root and root.Parent) do
                    RunService.Heartbeat:Wait()
                    char = LocalPlayer.Character
                    root = char.HumanoidRootPart
                end
                local oldVel = root.Velocity
                root.Velocity = oldVel * 1000000 + Vector3.new(0, 1000000, 0)
                RunService.RenderStepped:Wait()
                if char and char.Parent and root and root.Parent then
                    root.Velocity = oldVel
                end
                RunService.Stepped:Wait()
                if char and char.Parent and root and root.Parent then
                    root.Velocity = oldVel + Vector3.new(0, vel, 0)
                end
            end)
        until settings.Fling ~= true
    end
end
sectionLocalPlayer:Toggle("撞飞", "Fling", false, function(val)
    settings.Fling = val
    Fling()
end)

local visualSettings = {
    ["DefFOV"] = CurrentCamera.FieldOfView,
    ["DefCameraMaxZoomDistance"] = LocalPlayer.CameraMaxZoomDistance,
    ["DefCameraMinZoomDistance"] = LocalPlayer.CameraMinZoomDistance,
    ["FieldOfView"] = 70,
    ["FieldOfViewToggle"] = false,
    ["CameraMaxZoomDistance"] = 128,
    ["CameraMaxZoomDistanceToggle"] = false,
    ["CameraMinZoomDistance"] = 0.5,
    ["CameraMinZoomDistanceToggle"] = false,
    ["FullBright"] = false,
    ["DefAmbient"] = Lighting.Ambient
}

local function fovLoop()
    while visualSettings.FieldOfViewToggle do
        CurrentCamera.FieldOfView = visualSettings.FieldOfView
        task.wait()
    end
end

local function maxZoomLoop()
    while visualSettings.CameraMaxZoomDistanceToggle do
        LocalPlayer.CameraMaxZoomDistance = visualSettings.CameraMaxZoomDistance
        task.wait()
    end
end

local function minZoomLoop()
    while visualSettings.CameraMinZoomDistanceToggle do
        LocalPlayer.CameraMinZoomDistance = visualSettings.CameraMinZoomDistance
        task.wait()
    end
end

sectionLocalVisuals:Slider("FOV", "FOV", 70, 1, 120, true, function(val)
    visualSettings.FieldOfView = val
end)
sectionLocalVisuals:Toggle("FOV开关", "FOVToggle", false, function(val)
    visualSettings.FieldOfViewToggle = val
    if val == false then
        CurrentCamera.FieldOfView = visualSettings.DefFOV
    else
        fovLoop()
    end
end)
sectionLocalVisuals:Slider("最大相机聚焦距离", "CameraMaxZoomDistance", 128, 1, 1200, true, function(val)
    visualSettings.CameraMaxZoomDistance = val
end)
sectionLocalVisuals:Toggle("最大相机聚焦距离开关", "CameraMaxZoomDistanceToggle", false, function(val)
    visualSettings.CameraMaxZoomDistanceToggle = val
    if val == false then
        LocalPlayer.CameraMaxZoomDistance = visualSettings.DefCameraMaxZoomDistance
    else
        maxZoomLoop()
    end
end)
sectionLocalVisuals:Slider("最小相机聚焦距离", "Slider", 0.5, 1, 50, true, function(val)
    visualSettings.CameraMinZoomDistance = val
end)
sectionLocalVisuals:Toggle("最小相机聚焦距离开关", "CameraMinZoomDistanceToggle", false, function(val)
    visualSettings.CameraMinZoomDistanceToggle = val
    if val == false then
        LocalPlayer.CameraMinZoomDistance = visualSettings.DefCameraMinZoomDistance
    else
        minZoomLoop()
    end
end)

local function fullbrightLoop()
    while visualSettings.FullBright do
        pcall(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
        end)
        task.wait()
    end
end
sectionLocalVisuals:Toggle("全局高亮", "FullBright", false, function(val)
    visualSettings.FullBright = val
    if val == false then
        Lighting.Ambient = visualSettings.DefAmbient
    end
    fullbrightLoop()
end)

local customSkybox = {
    ["Bk"] = nil,
    ["Dn"] = nil,
    ["Ft"] = nil,
    ["Lf"] = nil,
    ["Rt"] = nil,
    ["Up"] = nil
}
sectionSkybox:Dropdown("天空盒", "Skybox", { "cs_办公室", "Always.win", "XNHUB" }, function(choice)
    if choice == "cs_办公室" then
        SpawnSkybox({
            ["Name"] = "cs_office",
            ["Bk"] = "rbxassetid://658623433",
            ["Dn"] = "rbxassetid://316342560",
            ["Ft"] = "rbxassetid://658625205",
            ["Lf"] = "rbxassetid://658627155",
            ["Rt"] = "rbxassetid://658628504",
            ["Up"] = "rbxassetid://658632701"
        })
    elseif choice == "Always.win" then
        SpawnSkybox({
            ["Name"] = "Always.win",
            ["Bk"] = "rbxassetid://17411013742",
            ["Dn"] = "rbxassetid://17411013742",
            ["Ft"] = "rbxassetid://17411013742",
            ["Lf"] = "rbxassetid://17411013742",
            ["Rt"] = "rbxassetid://17411013742",
            ["Up"] = "rbxassetid://17411013742"
        })
    elseif choice == "XNHUB" then
        SpawnSkybox({
            ["Name"] = "XNHUB",
            ["Bk"] = "rbxassetid://17803761395",
            ["Dn"] = "rbxassetid://17803761395",
            ["Ft"] = "rbxassetid://17803761395",
            ["Lf"] = "rbxassetid://17803761395",
            ["Rt"] = "rbxassetid://17803761395",
            ["Up"] = "rbxassetid://17803761395",
            ["SunAsset"] = "rbxassetid://17768924741",
            ["SunAngularSize"] = 50
        })
    end
end)
sectionSkybox:Textbox("自定义天空盒Bk", "Textbox", "请输入SkyboxBk贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Bk = val
        else
            customSkybox.Bk = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Textbox("自定义天空盒Dn", "Textbox", "请输入SkyboxDn贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Dn = val
        else
            customSkybox.Dn = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Textbox("自定义天空盒Ft", "Textbox", "请输入SkyboxFt贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Ft = val
        else
            customSkybox.Ft = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Textbox("自定义天空盒Lf", "Textbox", "请输入SkyboxLf贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Lf = val
        else
            customSkybox.Lf = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Textbox("自定义天空盒Rt", "Textbox", "请输入SkyboxRt贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Rt = val
        else
            customSkybox.Rt = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Textbox("自定义天空盒Up", "Textbox", "请输入SkyboxUp贴图ID", function(val)
    pcall(function()
        if val:find("rbx") then
            customSkybox.Up = val
        else
            customSkybox.Up = "rbxassetid://" .. val
        end
    end)
end)
sectionSkybox:Button("修改自定义天空盒", function()
    pcall(function()
        SpawnSkybox({
            ["Name"] = "自定义天空盒",
            ["Bk"] = customSkybox.Bk,
            ["Dn"] = customSkybox.Dn,
            ["Ft"] = customSkybox.Ft,
            ["Lf"] = customSkybox.Lf,
            ["Rt"] = customSkybox.Rt,
            ["Up"] = customSkybox.Up
        })
    end)
end)

sectionAboutAuthor:Label("XNHUB")
sectionAboutScript:Label("当前版本 " .. version)

LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.LegacyChatService then
    rawset(require(LocalPlayer:FindFirstChild("PlayerScripts"):FindFirstChild("ChatScript").ChatMain), "MessagePosted", {
        ["fire"] = function(msg) return msg end,
        ["wait"] = function() end,
        ["connect"] = function() end
    })
end