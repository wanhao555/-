loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

if not game:IsLoaded() then
	game.Loaded:Wait()
end



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local CHARS_FOLDER = "Characters"

local host = getgenv and getgenv() or _G
if type(host.XiProSaintUnload) == "function" then
	pcall(host.XiProSaintUnload)
	task.wait(0.15)
end


local function GetTextGradient(Text, StartColor, EndColor)
	local Result = ""
	local Length = utf8.len(Text)
	if not Length then
		return Text
	end
	local Index = 0
	for _, Code in utf8.codes(Text) do
		local Char = utf8.char(Code)
		local T = Index / math.max(Length - 1, 1)
		local R = StartColor.R + (EndColor.R - StartColor.R) * T
		local G = StartColor.G + (EndColor.G - StartColor.G) * T
		local B = StartColor.B + (EndColor.B - StartColor.B) * T
		Result ..= string.format(
			'<font color="rgb(%d,%d,%d)">%s</font>',
			math.floor(R * 255),
			math.floor(G * 255),
			math.floor(B * 255),
			Char
		)
		Index += 1
	end
	return Result
end


local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()
    local Window = WindUI:CreateWindow({
        Title = 'Frost HUB',
        Icon = "crown",
        IconThemed = true,
        Author = "by SQ",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(300, 200),
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
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么", 
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
        Search = {
            Enabled = true,
            Placeholder = "搜索...",
            Callback = function(searchText)
                print("搜索内容:", searchText)
            end
        },
        SidePanel = {
            Enabled = true,
            Content = {
                {
                    Type = "Button", 
                    Text = "",
                    Style = "Subtle", 
                    Size = UDim2.new(1, -20, 0, 30),
                    Callback = function()
                    end
                }
            }
        }
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
        local RunService = game:GetService("RunService")
        RunService.RenderStepped:Connect(function(deltaTime)
            gradient.Rotation = (gradient.Rotation + 60 * deltaTime) % 360
        end)
    end
end

local LOCALES = {
	zh = {
		tabInfo = "信息",
		tabAim = "自瞄功能",
		tabPlayer = "玩家功能",
		tabPolice = "警察功能",
		tabCombat = "战斗功能",
		tabMoney = "刷钱功能",
		tabVehicle = "载具功能",
		tabEsp = "透视功能",
		tabTeleport = "传送功能",
		tabShop = "商店功能",
		tabPlayers = "在线玩家",
		tabSettings = "设置",
		sectionAim = "自瞄功能",
		aimAssist = "自瞄",
		aimAssistDesc = "快捷键 Q，平滑锁定目标",
		targetPlayers = "自瞄玩家",
		targetPlayersDesc = "自瞄敌人玩家",
		targetTyres = "自瞄轮胎",
		targetTyresDesc = "自瞄其他车辆轮胎",
		wallCheck = "隔墙检查",
		wallCheckDesc = "看不见的目标会被忽略",
		aimAtHead = "自瞄头部",
		aimAtHeadDesc = "关闭则自瞄躯干，更容易打中",
		aimCircle = "瞄准圈",
		aimCircleDesc = "目标需要离准星多近才会锁定",
		showAimCircle = "显示瞄准圈",
		showAimCircleDesc = "在准星处画出瞄准圈大小",
		maxDistance = "最大距离",
		maxDistanceDesc = "目标最远锁定距离",
		humanization = "拟人化",
		humanizationDesc = "越低越准，越高越像真人瞄准",
		fireRealGun = "用真实枪开火",
		fireRealGunDesc = "移动端按下游戏自带开火键，子弹可能打偏",
		sectionAutoFire = "自动开火",
		autoShoot = "自动射击",
		autoShootDesc = "锁定目标后自动开火",
		verifyShot = "射击校验",
		verifyShotDesc = "只有打得中才开火",
		fireRate = "射速",
		fireRateDesc = "每秒开火次数",
		fireCone = "开火锥角",
		fireConeDesc = "准星对准目标多少度内才会开火",
		autoShootOn = "自动射击已开启",
		autoShootOff = "自动射击已关闭",
		sectionSilent = "静默瞄准",
		silentAim = "静默瞄准",
		silentAimDesc = "子弹会打在圈内目标的头上，不需要把准星对准",
		teleportShot = "传送射击",
		teleportShotDesc = "先传送到远处目标再开枪，打完立刻回来",
		silentCircle = "瞄准圈",
		silentCircleDesc = "圈内的人才会被静默瞄准，0 只打锁定目标",
		silentRange = "范围",
		silentRangeDesc = "最远可以打到的距离",
		hitsPerShot = "每发命中数",
		hitsPerShotDesc = "每一枪算几次命中，越高死得越快",
		silentAutoFire = "自动开火",
		silentAutoFireDesc = "打中一次后继续打这个人，直到倒下",
		silentAutoShots = "自动射击次数",
		silentAutoShotsDesc = "每人最多打几枪，死了会提前停",
		combatOnly = "仅战斗状态",
		combatOnlyDesc = "只打处于战斗状态的玩家",
		alwaysShowCircle = "始终显示圈",
		alwaysShowCircleDesc = "没掏枪也一直显示瞄准圈",
		silentOn = "静默瞄准已开启",
		silentOff = "静默瞄准已关闭",
		silentReplacesAim = "静默瞄准不需要自瞄，已关闭瞄准辅助",
		sectionRage = "Ragebot",
		ragebot = "Ragebot",
		ragebotDesc = "范围内自动攻击玩家",
		rageRange = "攻击距离",
		rageRangeDesc = "最远可以攻击的距离",
		rageInterval = "攻击间隔",
		rageIntervalDesc = "每轮攻击之间的等待时间",
		ragePart = "攻击部位",
		ragePartDesc = "伤害打在哪个部位",
		rageHead = "头部",
		rageTorso = "躯干",
		rageLeftArm = "左臂",
		rageRightArm = "右臂",
		rageLeftLeg = "左腿",
		rageRightLeg = "右腿",
		rageJobCheck = "职业检测",
		rageJobCheckDesc = "不攻击同一职业的玩家",
		rageWallCheck = "墙壁检测",
		rageWallCheckDesc = "隔墙的目标不会被攻击",
		rageWallbang = "穿墙攻击",
		rageWallbangDesc = "关闭墙壁检测时，被挡目标会自动寻找可命中发射点",
		rageAliveCheck = "活体检测",
		rageAliveCheckDesc = "只攻击还活着的玩家",
		rageCombatCheck = "战斗状态检测",
		rageCombatCheckDesc = "只攻击处于战斗状态的玩家",
		ragePoliceLock = "锁定警察",
		ragePoliceLockDesc = "只攻击警察",
		rageCivilianLock = "锁定平民",
		rageCivilianLockDesc = "只攻击平民",
		rageBeam = "弹道显示",
		rageBeamDesc = "显示攻击弹道",
		rageOn = "Ragebot 已开启",
		rageOff = "Ragebot 已关闭",
		sectionDefense = "防御",
		defenseMode = "防御模式",
		defenseModeDesc = "有人打你时自动瞄准对方",
		defenseAutoFire = "防御自动射击",
		defenseAutoFireDesc = "不只瞄准，还会开枪还击",
		retaliateFor = "反击持续秒数",
		retaliateForDesc = "被打后继续锁定对方多久",
		defending = "正在反击",
		sectionEquip = "装备",
		autoEquip = "自动换枪",
		autoEquipDesc = "开火前自动拿出武器",
		hotbarSlot = "快捷栏槽位",
		hotbarSlotDesc = "自动装备使用第几个快捷栏",
		sectionFilter = "白名单 / 过滤",
		teamCheck = "队友检查",
		teamCheckDesc = "不瞄准同队玩家",
		crewCheck = "帮派检查",
		crewCheckDesc = "不瞄准同一帮派的人",
		friendsCheck = "好友检查",
		friendsCheckDesc = "不瞄准好友列表里的人",
		whitelist = "玩家白名单",
		whitelistDesc = "白名单里的人不会被瞄准",
		whitelistSearch = "搜索玩家",
		whitelistSearchDesc = "输入名字搜索后加入或移出白名单",
		whitelistToggle = "加入 / 移出白名单",
		whitelistEmpty = "当前没有白名单玩家",
		whitelistOn = "已加入白名单",
		whitelistOff = "已移出白名单",
		roleFilter = "角色过滤",
		roleFilterDesc = "只瞄准下方打开的角色",
		wantedOnly = "仅通缉",
		wantedOnlyDesc = "只瞄准有通缉等级的玩家",
		rolePolice = "警察",
		roleMedical = "医护",
		roleFire = "消防",
		roleTransit = "公交",
		roleRoad = "道路服务",
		roleFarmer = "农民",
		roleChef = "厨师",
		roleDelivery = "配送",
		roleCivilian = "平民",
		rolePrisoner = "囚犯",
		language = "语言",
		languageDesc = "切换界面语言",
		infoTitle = "Xi Pro 免费版",
		infoDesc = "作者：神仇。圣奥里：神仇、蛙蛙。永久免费，请勿倒卖。",
		sectionInfoHero = "Xi Pro",
		infoHero = "Xi Pro 强势回归",
		infoHeroDesc = "免费脚本，打压所有缝合付费脚本",
		infoCrush = "打压所有垃圾付费缝合脚本",
		infoCrushDesc = "能用、好用、一直免费。",
		sectionInfoTeam = "制作人员",
		infoAuthor = "Xi Pro 作者",
		infoAuthorDesc = "神仇",
		infoSaint = "参与开发圣奥里制作者",
		infoSaintDesc = "神仇  ·  蛙蛙",
		sectionInfoRule = "声明",
		infoFree = "脚本永久免费",
		infoFreeDesc = "不会收费，也不会出付费版。",
		infoNoSell = "请勿倒卖",
		infoNoSellDesc = "倒卖出去的一律当垃圾。",
		infoRisk = "风险提醒",
		infoRiskDesc = "传送、速度、飞行类功能不保证不会封号，请谨慎使用。战斗、防护、静默等其余功能已完全绕过。",
		riskNoticeShort = "传送/速度/飞行不保证不封号；其他功能已完全绕过。",
		sectionJump = "跳跃",
		jumpEnabled = "开启跳跃",
		jumpEnabledDesc = "用自定义高度跳跃",
		jumpPower = "跳跃高度",
		jumpPowerDesc = "每次跳跃向上抬的高度",
		jumpMultiplier = "跳跃倍数",
		jumpMultiplierDesc = "高度再乘这个倍数",
		infiniteJump = "无限跳跃",
		infiniteJumpDesc = "空中也可以继续跳",
		sectionProtect = "防护",
		antiRagdoll = "防布娃娃",
		antiRagdollDesc = "阻止游戏把你打成布娃娃",
		antiArrest = "防逮捕",
		antiArrestDesc = "附近有手铐时自动躲开",
		antiAfk = "防挂机",
		antiAfkDesc = "防止因挂机被踢出",
		noDamage = "无伤害",
		noDamageDesc = "挡住坠落、撞击等伤害",
		antiRagdollMissing = "当前地图找不到布娃娃模块",
		antiArrestNoChar = "还没有角色，稍后再开防逮捕",
		antiPrisonPull = "防越狱拉回",
		antiPrisonPullDesc = "阻止监狱把你拉回去",
		sectionMove = "移动",
		noclip = "无碰撞",
		noclipDesc = "穿过墙壁和物体",
		fly = "飞行",
		flyDesc = "空中自由移动，空格上升，Ctrl 下降",
		flySpeed = "飞行速度",
		flySpeedDesc = "飞得有多快",
		godMode = "无敌",
		godModeDesc = "开启后别人很难打中你",
		godOn = "无敌已开启",
		godOff = "无敌已关闭",
		godNeedHook = "无敌需要 hookmetamethod",
		stealth = "隐身",
		stealthDesc = "别人看不见你，自己还能正常移动",
		stealthOn = "隐身已开启",
		stealthOff = "隐身已关闭",
		sectionSurvive = "生存",
		infStamina = "无限体力",
		infStaminaDesc = "体力不会下降",
		infHunger = "无限饥饿",
		infHungerDesc = "饥饿不会下降，先吃一次再开更稳",
		sectionPoliceArrest = "逮捕",
		sectionPoliceRange = "参数",
		autoCuff = "自动铐",
		autoCuffDesc = "铐住范围内有通缉的人，需要先拿出手铐",
		cuffTeleport = "自动传送",
		cuffTeleportDesc = "传到最近通缉犯背后，再交给自动铐",
		cuffCombat = "战斗检测",
		cuffCombatDesc = "只铐正在战斗或被追捕的人",
		cuffRange = "铐人范围",
		cuffRangeDesc = "寻找和传送通缉犯的最远距离",
		cuffInterval = "铐人间隔",
		cuffIntervalDesc = "每轮扫描之间的等待时间",
		cuffOn = "自动铐已开启",
		cuffOff = "自动铐已关闭",
		sectionAura = "杀戮光环",
		sectionCombatBlock = "拦截",
		sectionAmmo = "弹药",
		killAura = "杀戮光环",
		killAuraDesc = "自动打范围内最近的人",
		auraPolice = "只打警察",
		auraPoliceDesc = "光环只锁定警察",
		auraCivilian = "只打平民",
		auraCivilianDesc = "光环只锁定平民",
		auraCombat = "战斗检测",
		auraCombatDesc = "只打正在战斗或被追捕的人",
		auraRange = "攻击范围",
		auraRangeDesc = "光环最远可以打到多远",
		auraDamage = "伤害倍率",
		auraDamageDesc = "每次命中的伤害倍数",
		auraInterval = "攻击间隔",
		auraIntervalDesc = "每轮攻击之间的等待时间",
		combatBlock = "战斗拦截",
		combatBlockDesc = "阻止进入战斗状态",
		infAmmo = "无限弹药",
		infAmmoDesc = "后备弹药不会用完",
		noReload = "无需换弹",
		noReloadDesc = "弹匣保持满的，不用换弹",
		sectionHack = "黑客",
		sectionPickup = "捡钱",
		sectionMission = "任务",
		sectionJobs = "工作",
		autoHack = "黑客小游戏",
		autoHackDesc = "自动过掉黑客和破解小游戏",
		autoAtm = "ATM 黑客",
		autoAtmDesc = "自动点完 ATM 破解密码",
		pickMoney = "捡钱",
		pickMoneyDesc = "自动捡地上的现金和钱袋",
		autoMission = "自动接任务",
		autoMissionDesc = "有空位时自动接下一个任务",
		missionHighPay = "优先高收益",
		missionHighPayDesc = "先接回报更高的任务",
		missionInterval = "接取间隔",
		missionIntervalDesc = "两次接任务之间等多久",
		farmBus = "公交车刷钱",
		farmBusDesc = "把车开到站点完成公交任务",
		farmTaxi = "出租车刷钱",
		farmTaxiDesc = "传到乘客位置完成出租车单",
		taxiSafe = "出租车模式",
		taxiSafeDesc = "先回到起点再等一会儿，再传过去",
		farmFarmer = "农民刷钱",
		farmFarmerDesc = "自动捡作物并送到交付点",
		farmChef = "餐厅 / 厨师",
		farmChefDesc = "接厨师单并传到后厨交互",
		farmGolf = "高尔夫刷钱",
		farmGolfDesc = "自动开局并把球传到旗杆",
		sectionVehicle = "载具",
		sectionSpeedHud = "速度表",
		sectionCar = "召唤",
		sectionDrive = "驾驶",
		sectionVehStats = "状态",
		sectionRam = "撞击",
		sectionFollow = "跟随",
		speedHud = "速度表 HUD",
		speedHudDesc = "屏幕顶部显示车速和状态",
		bringCar = "拉车过来",
		bringCarDesc = "把你的车传送到身边",
		enterCar = "上车",
		enterCarDesc = "传送到驾驶位并坐下",
		cruise = "巡航定速",
		cruiseDesc = "保持当前车速，W 加速 S 减速",
		collisionStop = "碰撞停车",
		collisionStopDesc = "前方有障碍就立刻刹停",
		offroad = "越野捷径",
		offroadDesc = "撞击和跟随时可以飞越地形",
		groundLock = "贴地锁定",
		groundLockDesc = "车身始终贴着地面高度",
		rideHeight = "贴地高度",
		rideHeightDesc = "相对地面的高度偏移",
		floatCar = "漂浮",
		floatCarDesc = "让车悬浮在地面上方",
		floatHeight = "漂浮高度",
		floatHeightDesc = "离地高度",
		noCrashes = "无碰撞损坏",
		noCrashesDesc = "拆掉车身碰撞，不会撞坏",
		fullFuel = "满油",
		fullFuelDesc = "油箱始终加满",
		ramInstant = "瞬间撞击",
		ramInstantDesc = "传送到对方身上高速撞击后再传回来",
		ramDelay = "重复延迟",
		ramDelayDesc = "同一人被撞后过多久再撞",
		ramRange = "撞击范围",
		ramRangeDesc = "自动撞击最远距离，瞬间撞击不受限",
		autoRam = "自动撞击",
		autoRamDesc = "自动找范围内的人撞，没有每日次数限制",
		killCheck = "击杀判定",
		killCheckDesc = "撞飞、布娃娃或掉血才算成功",
		manualRam = "手动撞人",
		manualRamDesc = "撞击当前选中的玩家",
		followPlayer = "跟随玩家",
		followPlayerDesc = "开车或走路跟着选中的人",
		followGap = "跟随距离",
		followGapDesc = "跟在目标后面多远",
		sendCar = "送车",
		sendCarDesc = "把车送到对方身边，等人上车后再拉回来",
		vehTarget = "目标玩家",
		vehTargetDesc = "跟随、送车和手动撞击用的目标",
		vehNoTarget = "先选一个玩家",
		vehNoCar = "这台服务器上没有你的车",
		vehBrought = "车已拉过来",
		vehBringFail = "没法移动你的车",
		vehEnter = "正在上车",
		vehEnterFail = "没法上车",
		vehRamOk = "撞击完成",
		vehRamFail = "没撞到",
		vehNeedSit = "先坐进车里再撞",
		vehSent = "车已送出，等待上车",
		vehSendBack = "车已拉回",
		vehSendBusy = "正在送车",
		hudNoVehicle = "无载具",
		hudCruise = "巡航",
		hudDrive = "行驶",
		hudIdle = "怠速",
		hudReverse = "倒车",
		sectionEspVisual = "视觉",
		sectionEspFilter = "筛选",
		sectionEspRange = "范围",
		espTracers = "射线",
		espTracersDesc = "从屏幕底部连到玩家，按队伍上色",
		espOffscreen = "屏幕外射线",
		espOffscreenDesc = "屏幕外的人也会指向",
		espDots = "头点",
		espDotsDesc = "在每个人头上显示队伍颜色圆点",
		espDetails = "信息",
		espDetailsDesc = "显示名称、距离和血量",
		espHealth = "血条",
		espHealthDesc = "在玩家旁边显示竖向血条",
		espWanted = "通缉高亮",
		espWantedDesc = "通缉玩家显示为蓝色",
		espHideDead = "隐藏死亡",
		espHideDeadDesc = "不显示倒地或死亡的人",
		espPoliceOnly = "只看警察",
		espPoliceOnlyDesc = "只显示警察队伍",
		espWantedOnly = "只看通缉",
		espWantedOnlyDesc = "只显示有通缉的人",
		espRange = "最大距离",
		espRangeDesc = "超过这个距离就不画",
		sectionTpPlayer = "玩家",
		sectionTpBlink = "闪现",
		sectionTpMarker = "地图标记",
		sectionTpLocation = "地点",
		sectionTpCrime = "犯罪",
		sectionTpSurface = "地表",
		tpPlayer = "目标玩家",
		tpPlayerDesc = "传送或观看用的玩家",
		tpToPlayer = "传送到玩家",
		tpViewPlayer = "观看玩家",
		tpStopView = "停止观看",
		tpBlink = "闪现",
		tpBlinkDesc = "电脑按 X 或 8 闪到鼠标位置，手机先点闪现再点地面",
		tpMarker = "传到标记",
		tpMarkerDesc = "先在地图里点 Navigate 设标记",
		tpLocSearch = "搜索地点",
		tpLocSearchDesc = "按名字筛选地点",
		tpLocation = "地点",
		tpLocationDesc = "选一个地点再传送或观看",
		tpToLocation = "传到地点",
		tpViewLocation = "观看地点",
		tpCrimeFilter = "犯罪筛选",
		tpCrimeFilterDesc = "按类型筛选当前可抢的任务",
		tpCrime = "犯罪点",
		tpCrimeDesc = "选一个犯罪点再传送",
		tpToCrime = "传到犯罪点",
		tpCrimeRefresh = "刷新犯罪",
		crimeAll = "全部",
		crimeRobbery = "抢劫",
		crimeHeist = "劫案",
		crimeCar = "车辆",
		crimeTrade = "交易",
		tpSurface = "返回地表",
		tpSurfaceDesc = "离开建筑或从地下回到地面",
		tpOk = "已传送",
		tpFail = "传不过去",
		tpNoPlayer = "先选一个玩家",
		tpNoMarker = "还没有标记，先打开地图点 Navigate",
		tpNoLocation = "先选一个地点",
		tpNoCrime = "这个犯罪点现在不可用",
		tpViewing = "正在观看",
		tpViewOff = "已停止观看",
		tpBlinkOn = "闪现已开启",
		tpBlinkOff = "闪现已关闭",
		tpSurfaceOk = "已回到地面",
		tpSurfaceIdle = "你已经在地面上",
		tpNotLoaded = "这个人还没加载出来",
		sectionShopBrowse = "浏览",
		sectionShopBuy = "购买",
		shopSearch = "搜索物品",
		shopSearchDesc = "按名字筛选商店物品",
		shopCategory = "分类",
		shopCategoryDesc = "武器、黑市、食物或物品",
		shopAll = "全部",
		shopWeapons = "武器",
		shopBlack = "黑市",
		shopFood = "食物",
		shopItems = "物品",
		shopItem = "物品",
		shopItemDesc = "选中后购买或给武器补弹",
		shopQty = "数量",
		shopQtyDesc = "一次买多少个",
		shopBuy = "购买",
		shopRefill = "补弹",
		shopRefresh = "刷新商店",
		shopNeedItem = "先选一个物品",
		shopBought = "购买成功",
		shopBuyFail = "购买失败",
		shopRefilled = "补弹成功",
		shopRefillFail = "补弹失败",
		shopRefillNeedGun = "补弹只能用在武器上",
		sectionPlList = "玩家",
		sectionPlActions = "操作",
		sectionPlWatch = "警戒",
		plSearch = "搜索玩家",
		plSearchDesc = "按名字或昵称筛选",
		plSort = "排序",
		plSortDesc = "列表怎么排",
		plSortNear = "最近",
		plSortName = "名字",
		plSortTeam = "队伍",
		plSelect = "选择玩家",
		plSelectDesc = "置顶的人会排在最前面",
		plInfo = "玩家信息",
		plInfoEmpty = "先选一个玩家",
		plRefresh = "刷新列表",
		plTeleport = "传送过去",
		plView = "观看",
		plStopView = "停止观看",
		plFollow = "跟随",
		plStopFollow = "停止跟随",
		plLockAim = "锁定瞄准",
		plUnlockAim = "取消锁定",
		plNeverAim = "永不瞄准",
		plAimThem = "允许瞄准",
		plRam = "撞击",
		plHunt = "持续撞击",
		plStopHunt = "停止撞击",
		plSendCar = "送车",
		plPin = "置顶",
		plUnpin = "取消置顶",
		plCopy = "复制名字",
		plWatch = "接近警报",
		plWatchDesc = "有人靠近时提醒你",
		plWatchFor = "警戒对象",
		plWatchForDesc = "警察、通缉、置顶或所有人",
		plWatchCops = "警察",
		plWatchWanted = "通缉",
		plWatchPinned = "置顶",
		plWatchAnyone = "所有人",
		plWatchDist = "警戒距离",
		plWatchDistDesc = "进入这个距离就会提醒",
		plCopied = "已复制",
		plNoClip = "执行器没有剪贴板",
		plPinned = "已置顶",
		plUnpinned = "已取消置顶",
		plLocked = "已锁定瞄准",
		plUnlocked = "已取消锁定",
		plNear = "就在附近",
		plNeedMod = "先加载对应功能",
		aimOn = "瞄准辅助已开启",
		aimOff = "瞄准辅助已关闭",
		realGunOn = "真实枪开火已开启",
		realGunNeedWeapon = "拿出武器后再试",
		loaded = "圣奥里已加载",
		switched = "已切换为中文",
	},
	en = {
		tabInfo = "Info",
		tabAim = "Aim",
		tabPlayer = "Player",
		tabPolice = "Police",
		tabCombat = "Combat",
		tabMoney = "Money",
		tabVehicle = "Vehicle",
		tabEsp = "ESP",
		tabTeleport = "Teleport",
		tabShop = "Shop",
		tabPlayers = "Players",
		tabSettings = "Settings",
		sectionAim = "Aim Assist",
		aimAssist = "Aim Assist",
		aimAssistDesc = "Key: Q. Smooth lock onto targets",
		targetPlayers = "Target Players",
		targetPlayersDesc = "Aim at enemy players",
		targetTyres = "Target Tyres",
		targetTyresDesc = "Aim at other cars' tyres",
		wallCheck = "Wall Check",
		wallCheckDesc = "Ignore targets you cannot see",
		aimAtHead = "Aim at Head",
		aimAtHeadDesc = "Off = torso, easier to hit",
		aimCircle = "Aim Circle",
		aimCircleDesc = "How close to your crosshair someone has to be",
		showAimCircle = "Show Aim Circle",
		showAimCircleDesc = "Draw the circle on your crosshair",
		maxDistance = "Max Distance",
		maxDistanceDesc = "How far away a target can be",
		humanization = "Humanization",
		humanizationDesc = "Lower = more accurate. Higher = looks more human",
		fireRealGun = "Fire The Real Gun",
		fireRealGunDesc = "Mobile: press the game's own fire button. Shots can miss",
		sectionAutoFire = "Auto Fire",
		autoShoot = "Auto Shoot",
		autoShootDesc = "Fires when on target",
		verifyShot = "Verify Shot",
		verifyShotDesc = "Only fire if it would connect",
		fireRate = "Fire Rate",
		fireRateDesc = "Shots per second",
		fireCone = "Fire Cone",
		fireConeDesc = "How close your aim has to be before it fires",
		autoShootOn = "Auto Shoot on",
		autoShootOff = "Auto Shoot off",
		sectionSilent = "Silent Aim",
		silentAim = "Silent Aim",
		silentAimDesc = "Your shots land on their head wherever you aim",
		teleportShot = "Teleport Shot",
		teleportShotDesc = "Teleports you to far targets so the shot hits, then brings you back",
		silentCircle = "Aim Circle",
		silentCircleDesc = "Size of the circle that picks who gets shot. 0 only uses a locked target",
		silentRange = "Range",
		silentRangeDesc = "How far away someone can be and still get hit",
		hitsPerShot = "Hits per Shot",
		hitsPerShotDesc = "How many hits each of your shots counts as. Higher kills faster",
		silentAutoFire = "Auto Fire",
		silentAutoFireDesc = "Once you land a hit, keeps shooting that person until they drop",
		silentAutoShots = "Auto Shots",
		silentAutoShotsDesc = "How many shots to send per person before giving up",
		combatOnly = "Combat Only",
		combatOnlyDesc = "Only shoots players who are marked as in combat",
		alwaysShowCircle = "Always Show Circle",
		alwaysShowCircleDesc = "Keeps the circle visible even with no gun out",
		silentOn = "Silent Aim on",
		silentOff = "Silent Aim off",
		silentReplacesAim = "Aim Assist off, Silent Aim doesn't need it",
		sectionRage = "Ragebot",
		ragebot = "Ragebot",
		ragebotDesc = "Automatically attack players in range",
		rageRange = "Attack Range",
		rageRangeDesc = "How far away a target can be",
		rageInterval = "Attack Interval",
		rageIntervalDesc = "Wait time between attack rounds",
		ragePart = "Hitbox",
		ragePartDesc = "Which body part to hit",
		rageHead = "Head",
		rageTorso = "Torso",
		rageLeftArm = "Left Arm",
		rageRightArm = "Right Arm",
		rageLeftLeg = "Left Leg",
		rageRightLeg = "Right Leg",
		rageJobCheck = "Job Check",
		rageJobCheckDesc = "Never attack players with the same job",
		rageWallCheck = "Wall Check",
		rageWallCheckDesc = "Ignore targets behind walls",
		rageWallbang = "Wallbang",
		rageWallbangDesc = "When wall check is off, find a legal shot origin through cover",
		rageAliveCheck = "Alive Check",
		rageAliveCheckDesc = "Only attack living players",
		rageCombatCheck = "Combat Check",
		rageCombatCheckDesc = "Only attack players in combat",
		ragePoliceLock = "Lock Police",
		ragePoliceLockDesc = "Only attack police",
		rageCivilianLock = "Lock Civilian",
		rageCivilianLockDesc = "Only attack civilians",
		rageBeam = "Show Tracer",
		rageBeamDesc = "Draw a tracer for each attack",
		rageOn = "Ragebot on",
		rageOff = "Ragebot off",
		sectionDefense = "Defense",
		defenseMode = "Defense Mode",
		defenseModeDesc = "Aim at whoever shoots you",
		defenseAutoFire = "Defense Auto Fire",
		defenseAutoFireDesc = "Shoot back, not just aim",
		retaliateFor = "Retaliate For",
		retaliateForDesc = "How long to keep locking the attacker",
		defending = "Defending against",
		sectionEquip = "Equipment",
		autoEquip = "Auto Equip",
		autoEquipDesc = "Equip weapon before firing",
		hotbarSlot = "Hotbar Slot",
		hotbarSlotDesc = "Which hotbar slot to equip",
		sectionFilter = "Whitelist / Filter",
		teamCheck = "Team Check",
		teamCheckDesc = "Never target players on your team",
		crewCheck = "Crew Check",
		crewCheckDesc = "Never target players in your crew",
		friendsCheck = "Friends Check",
		friendsCheckDesc = "Never target people on your friends list",
		whitelist = "Whitelist",
		whitelistDesc = "Whitelisted players will not be targeted",
		whitelistSearch = "Search players",
		whitelistSearchDesc = "Search a name, then add or remove them",
		whitelistToggle = "Add / Remove Whitelist",
		whitelistEmpty = "No whitelisted players",
		whitelistOn = "Whitelisted",
		whitelistOff = "Removed from whitelist",
		roleFilter = "Role Filter",
		roleFilterDesc = "Only aim at the roles turned on below",
		wantedOnly = "Wanted Only",
		wantedOnlyDesc = "Only aim at players with a wanted level",
		rolePolice = "Police",
		roleMedical = "Medical",
		roleFire = "Fire",
		roleTransit = "Transit",
		roleRoad = "Road Service",
		roleFarmer = "Farmer",
		roleChef = "Chef",
		roleDelivery = "Delivery",
		roleCivilian = "Civilian",
		rolePrisoner = "Prisoner",
		language = "Language",
		languageDesc = "Switch interface language",
		infoTitle = "Xi Pro Free",
		infoDesc = "Author: 神仇. Saint Aurie: 神仇 & 蛙蛙. Permanently free. Do not resell.",
		sectionInfoHero = "Xi Pro",
		infoHero = "Xi Pro Is Back",
		infoHeroDesc = "A free script that crushes all paid frankenstein scripts.",
		infoCrush = "Crushing paid frankenstein scripts",
		infoCrushDesc = "It works. It stays free.",
		sectionInfoTeam = "Credits",
		infoAuthor = "Xi Pro author",
		infoAuthorDesc = "神仇",
		infoSaint = "Saint Aurie makers",
		infoSaintDesc = "神仇  ·  蛙蛙",
		sectionInfoRule = "Notice",
		infoFree = "Permanently free",
		infoFreeDesc = "No paid version. No charges.",
		infoNoSell = "Do not resell",
		infoNoSellDesc = "Resold copies are trash.",
		infoRisk = "Risk notice",
		infoRiskDesc = "Teleport, speed, and flight are NOT guaranteed ban-safe—use with caution. Combat, protection, silent aim, and other features are fully bypassed.",
		riskNoticeShort = "TP/speed/fly: ban not guaranteed. Everything else is fully bypassed.",
		sectionJump = "Jump",
		jumpEnabled = "Custom Jump",
		jumpEnabledDesc = "Jump with a custom height",
		jumpPower = "Jump Height",
		jumpPowerDesc = "How high each jump goes",
		jumpMultiplier = "Jump Multiplier",
		jumpMultiplierDesc = "Height is multiplied by this",
		infiniteJump = "Infinite Jump",
		infiniteJumpDesc = "Keep jumping in the air",
		sectionProtect = "Protection",
		antiRagdoll = "Anti Ragdoll",
		antiRagdollDesc = "Stops the game ragdolling you",
		antiArrest = "Anti Arrest",
		antiArrestDesc = "Dodges nearby handcuffs automatically",
		antiAfk = "Anti AFK",
		antiAfkDesc = "Stops the game kicking you for being idle",
		noDamage = "No Damage",
		noDamageDesc = "Blocks crash / fall / run-over damage",
		antiRagdollMissing = "Anti-ragdoll: modules not found here",
		antiArrestNoChar = "Anti-arrest: no character yet",
		antiPrisonPull = "Anti Prison Pull",
		antiPrisonPullDesc = "Stops the prison teleporting you back",
		sectionMove = "Movement",
		noclip = "Noclip",
		noclipDesc = "Walk through walls and objects",
		fly = "Fly",
		flyDesc = "Move in the air. Space up, Ctrl down",
		flySpeed = "Fly Speed",
		flySpeedDesc = "How fast you fly",
		godMode = "God Mode",
		godModeDesc = "Makes you much harder to hit",
		godOn = "God Mode on",
		godOff = "God Mode off",
		godNeedHook = "God Mode needs hookmetamethod",
		stealth = "Ghost",
		stealthDesc = "Others can't see you while you still move around",
		stealthOn = "Ghost on",
		stealthOff = "Ghost off",
		sectionSurvive = "Survival",
		infStamina = "Infinite Stamina",
		infStaminaDesc = "Stamina never goes down",
		infHunger = "Infinite Hunger",
		infHungerDesc = "Hunger never goes down. Eat once first if you're low",
		sectionPoliceArrest = "Arrest",
		sectionPoliceRange = "Settings",
		autoCuff = "Auto Handcuff",
		autoCuffDesc = "Cuffs wanted players in range. Equip handcuffs first",
		cuffTeleport = "Auto Teleport",
		cuffTeleportDesc = "Warps behind the nearest wanted player so Auto Handcuff can cuff them",
		cuffCombat = "Combat Check",
		cuffCombatDesc = "Only cuff players who are in combat or pursuit",
		cuffRange = "Cuff Range",
		cuffRangeDesc = "How far to search and teleport for wanted players",
		cuffInterval = "Cuff Interval",
		cuffIntervalDesc = "Wait time between each scan",
		cuffOn = "Auto Handcuff on",
		cuffOff = "Auto Handcuff off",
		sectionAura = "Kill Aura",
		sectionCombatBlock = "Block",
		sectionAmmo = "Ammo",
		killAura = "Kill Aura",
		killAuraDesc = "Automatically hits the nearest player in range",
		auraPolice = "Police Only",
		auraPoliceDesc = "Aura only targets police",
		auraCivilian = "Civilian Only",
		auraCivilianDesc = "Aura only targets civilians",
		auraCombat = "Combat Check",
		auraCombatDesc = "Only hit players in combat or pursuit",
		auraRange = "Aura Range",
		auraRangeDesc = "How far the aura can reach",
		auraDamage = "Damage Multiplier",
		auraDamageDesc = "How hard each aura hit is",
		auraInterval = "Aura Interval",
		auraIntervalDesc = "Wait time between aura hits",
		combatBlock = "Combat Block",
		combatBlockDesc = "Stops the game putting you into combat",
		infAmmo = "Infinite Ammo",
		infAmmoDesc = "Reserve ammo never runs out",
		noReload = "No Reload",
		noReloadDesc = "Clip stays full, so you never reload",
		sectionHack = "Hacking",
		sectionPickup = "Pickup",
		sectionMission = "Missions",
		sectionJobs = "Jobs",
		autoHack = "Auto Hack",
		autoHackDesc = "Skips hack and cracking minigames",
		autoAtm = "ATM Hack",
		autoAtmDesc = "Taps the ATM code for you",
		pickMoney = "Pick Up Money",
		pickMoneyDesc = "Grabs cash drops and money bags",
		autoMission = "Auto Mission",
		autoMissionDesc = "Joins the next free job when you are idle",
		missionHighPay = "Highest Pay First",
		missionHighPayDesc = "Prefers missions that pay more",
		missionInterval = "Join Interval",
		missionIntervalDesc = "Wait time between mission joins",
		farmBus = "Auto Bus",
		farmBusDesc = "Warps the bus to the stop to finish the route",
		farmTaxi = "Auto Taxi",
		farmTaxiDesc = "Warps to passengers to finish taxi jobs",
		taxiSafe = "Taxi Mode",
		taxiSafeDesc = "Return to the start and wait before warping",
		farmFarmer = "Auto Farmer",
		farmFarmerDesc = "Picks crops and takes them to the drop-off",
		farmChef = "Auto Restaurant",
		farmChefDesc = "Joins chef orders and uses kitchen prompts",
		farmGolf = "Auto Golf",
		farmGolfDesc = "Starts a round and moves the ball to the flag",
		sectionVehicle = "Vehicle",
		sectionSpeedHud = "Speed HUD",
		sectionCar = "Car",
		sectionDrive = "Driving",
		sectionVehStats = "Stats",
		sectionRam = "Ram",
		sectionFollow = "Follow",
		speedHud = "Speed HUD",
		speedHudDesc = "Show speed and status at the top of the screen",
		bringCar = "Bring Car",
		bringCarDesc = "Teleport your car next to you",
		enterCar = "Enter Car",
		enterCarDesc = "Teleport to the driver seat and sit",
		cruise = "Cruise Control",
		cruiseDesc = "Hold current speed. W speeds up, S slows down",
		collisionStop = "Collision Stop",
		collisionStopDesc = "Brake immediately if something is ahead",
		offroad = "Off-road Shortcuts",
		offroadDesc = "Allow flying over terrain while ramming or following",
		groundLock = "Ground Lock",
		groundLockDesc = "Keep the car locked to ground height",
		rideHeight = "Ride Height",
		rideHeightDesc = "Height offset from the ground",
		floatCar = "Float",
		floatCarDesc = "Hover the car above the ground",
		floatHeight = "Float Height",
		floatHeightDesc = "How high above the ground",
		noCrashes = "No Crashes",
		noCrashesDesc = "Strip collision parts so the car does not crash",
		fullFuel = "Full Fuel",
		fullFuelDesc = "Keep the tank full",
		ramInstant = "Instant",
		ramInstantDesc = "Teleport onto them at ram speed, then teleport back",
		ramDelay = "Repeat delay",
		ramDelayDesc = "How long before the same person is rammed again",
		ramRange = "Ram range",
		ramRangeDesc = "How far Auto Ram will go. Instant has no limit",
		autoRam = "Auto Ram",
		autoRamDesc = "Ram nearby players automatically. No daily ram limit",
		killCheck = "Kill check",
		killCheckDesc = "Count a ram as a hit only if they ragdoll or lose health",
		manualRam = "Ram player",
		manualRamDesc = "Ram the selected player",
		followPlayer = "Follow player",
		followPlayerDesc = "Drive or walk after the selected player",
		followGap = "Follow distance",
		followGapDesc = "How far behind the target to sit",
		sendCar = "Send Car",
		sendCarDesc = "Send your car to them, wait for them to enter, then bring it back",
		vehTarget = "Target player",
		vehTargetDesc = "Used by Follow, Send Car, and manual ram",
		vehNoTarget = "Pick a player first",
		vehNoCar = "You have no car on this server",
		vehBrought = "Brought your car to you",
		vehBringFail = "Couldn't move your car",
		vehEnter = "Getting in",
		vehEnterFail = "Couldn't enter",
		vehRamOk = "Ram complete",
		vehRamFail = "Didn't connect",
		vehNeedSit = "Get in your car to ram",
		vehSent = "Car sent, waiting for them",
		vehSendBack = "Car brought back",
		vehSendBusy = "Already sending it",
		hudNoVehicle = "NO VEHICLE",
		hudCruise = "CRUISE",
		hudDrive = "DRIVE",
		hudIdle = "IDLE",
		hudReverse = "REVERSE",
		sectionEspVisual = "Visuals",
		sectionEspFilter = "Filter",
		sectionEspRange = "Range",
		espTracers = "Tracers",
		espTracersDesc = "Lines to players, team-coloured",
		espOffscreen = "Off-screen Tracers",
		espOffscreenDesc = "Point to players off-screen too",
		espDots = "Head Dots",
		espDotsDesc = "Team-colour dot over each head",
		espDetails = "Details",
		espDetailsDesc = "Display name, distance and HP",
		espHealth = "Health Bar",
		espHealthDesc = "Vertical HP bar beside each player",
		espWanted = "Wanted",
		espWantedDesc = "Show wanted players in blue",
		espHideDead = "Hide Dead",
		espHideDeadDesc = "Skip players who are down or dead",
		espPoliceOnly = "Police Only",
		espPoliceOnlyDesc = "Only show players on the Police team",
		espWantedOnly = "Wanted Only",
		espWantedOnlyDesc = "Only show wanted players",
		espRange = "Max Distance",
		espRangeDesc = "How far ESP will draw",
		sectionTpPlayer = "Players",
		sectionTpBlink = "Blink",
		sectionTpMarker = "Map marker",
		sectionTpLocation = "Locations",
		sectionTpCrime = "Crimes",
		sectionTpSurface = "Surface",
		tpPlayer = "Target player",
		tpPlayerDesc = "Used by teleport and view",
		tpToPlayer = "Teleport to player",
		tpViewPlayer = "View player",
		tpStopView = "Stop viewing",
		tpBlink = "Blink",
		tpBlinkDesc = "PC: press X or 8 to blink to your cursor. Mobile: tap Blink, then tap a spot",
		tpMarker = "Teleport to marker",
		tpMarkerDesc = "Open the map and press Navigate first",
		tpLocSearch = "Search locations",
		tpLocSearchDesc = "Filter locations by name",
		tpLocation = "Location",
		tpLocationDesc = "Pick a location to teleport or view",
		tpToLocation = "Teleport to location",
		tpViewLocation = "View location",
		tpCrimeFilter = "Crime filter",
		tpCrimeFilterDesc = "Filter current robbable missions",
		tpCrime = "Crime",
		tpCrimeDesc = "Pick a crime to teleport to",
		tpToCrime = "Teleport to crime",
		tpCrimeRefresh = "Refresh crimes",
		crimeAll = "All",
		crimeRobbery = "Robbery",
		crimeHeist = "Heist",
		crimeCar = "Car",
		crimeTrade = "Trade",
		tpSurface = "Return to surface",
		tpSurfaceDesc = "Leave a building or get back above ground",
		tpOk = "Teleported",
		tpFail = "Couldn't teleport",
		tpNoPlayer = "Pick a player first",
		tpNoMarker = "No marker set. Open the map and press Navigate",
		tpNoLocation = "Pick a location first",
		tpNoCrime = "That crime isn't available yet",
		tpViewing = "Viewing",
		tpViewOff = "Stopped viewing",
		tpBlinkOn = "Blink on",
		tpBlinkOff = "Blink off",
		tpSurfaceOk = "Back on the surface",
		tpSurfaceIdle = "You're already on the surface",
		tpNotLoaded = "isn't loaded in",
		sectionShopBrowse = "Browse",
		sectionShopBuy = "Buy",
		shopSearch = "Search items",
		shopSearchDesc = "Filter shop items by name",
		shopCategory = "Category",
		shopCategoryDesc = "Weapons, black market, food, or items",
		shopAll = "All",
		shopWeapons = "Weapons",
		shopBlack = "Black Market",
		shopFood = "Food",
		shopItems = "Items",
		shopItem = "Item",
		shopItemDesc = "Select an item to buy or refill ammo",
		shopQty = "Quantity",
		shopQtyDesc = "How many to buy at once",
		shopBuy = "Purchase",
		shopRefill = "Refill",
		shopRefresh = "Refresh shop",
		shopNeedItem = "Pick an item first",
		shopBought = "Purchase complete",
		shopBuyFail = "Purchase failed",
		shopRefilled = "Refilled",
		shopRefillFail = "Refill failed",
		shopRefillNeedGun = "Refill only works on weapons",
		sectionPlList = "Players",
		sectionPlActions = "Actions",
		sectionPlWatch = "Watch",
		plSearch = "Search players",
		plSearchDesc = "Filter by name or display name",
		plSort = "Sort",
		plSortDesc = "How the list is ordered",
		plSortNear = "Nearest",
		plSortName = "Name",
		plSortTeam = "Team",
		plSelect = "Select player",
		plSelectDesc = "Pinned players stay at the top",
		plInfo = "Player info",
		plInfoEmpty = "Pick a player first",
		plRefresh = "Refresh list",
		plTeleport = "Teleport",
		plView = "View",
		plStopView = "Stop viewing",
		plFollow = "Follow",
		plStopFollow = "Stop follow",
		plLockAim = "Lock aim",
		plUnlockAim = "Unlock aim",
		plNeverAim = "Never aim",
		plAimThem = "Aim at them",
		plRam = "Ram",
		plHunt = "Keep ramming",
		plStopHunt = "Stop ramming",
		plSendCar = "Send car",
		plPin = "Pin",
		plUnpin = "Unpin",
		plCopy = "Copy name",
		plWatch = "Proximity alert",
		plWatchDesc = "Tell you when someone gets close",
		plWatchFor = "Watch for",
		plWatchForDesc = "Cops, wanted, pinned, or anyone",
		plWatchCops = "Cops",
		plWatchWanted = "Wanted",
		plWatchPinned = "Pinned",
		plWatchAnyone = "Anyone",
		plWatchDist = "Distance",
		plWatchDistDesc = "Alert when they come this close",
		plCopied = "Copied",
		plNoClip = "Your executor has no clipboard",
		plPinned = "Pinned",
		plUnpinned = "Unpinned",
		plLocked = "Aim locked",
		plUnlocked = "Aim unlocked",
		plNear = "is nearby",
		plNeedMod = "That module isn't loaded",
		aimOn = "Aim Assist on",
		aimOff = "Aim Assist off",
		realGunOn = "Real gun fire on",
		realGunNeedWeapon = "Hold a weapon to test it",
		loaded = "Saint Aurie loaded",
		switched = "Switched to English",
	},
}

local currentLang = host.XiProLanguage == "en" and "en" or "zh"
local function T(key)
	local pack = LOCALES[currentLang] or LOCALES.zh
	return pack[key] or LOCALES.en[key] or key
end

local function safeIcon(name)
	local iconFn = WindUI and WindUI.Creator and WindUI.Creator.Icon
	local function exists(key)
		if type(key) ~= "string" or key == "" or type(iconFn) ~= "function" then
			return false
		end
		local ok, data = pcall(iconFn, key)
		return ok and type(data) == "table" and data[1] ~= nil
	end
	if exists(name) then
		return name
	end
	if exists("user") then
		return "user"
	end
	if type(iconFn) ~= "function" and type(name) == "string" and name ~= "" then
		return name
	end
	return nil
end

local labeled = {}
local function bind(element, titleKey, descKey)
	if element then
		labeled[#labeled + 1] = {
			el = element,
			title = titleKey,
			desc = descKey,
		}
	end
	return element
end

local function setElementText(element, title, desc)
	if not element then
		return
	end
	pcall(function()
		if element.SetTitle then
			element:SetTitle(title)
		end
	end)
	if desc ~= nil then
		pcall(function()
			if element.SetDesc then
				element:SetDesc(desc)
			end
		end)
	end
end

local function notify(title, content)
	pcall(function()
		WindUI:Notify({
			Title = title,
			Content = content,
			Icon = safeIcon("info"),
			Duration = 3,
		})
	end)
end

local cfg = {
	AimAssist = false,
	TargetPlayers = true,
	TargetTyres = true,
	WallCheck = true,
	AimAtHead = false,
	AimCircle = 110,
	ShowAimCircle = false,
	MaxDistance = 600,
	Humanization = 60,
	FireRealGun = false,
	AutoShoot = false,
	VerifyShot = true,
	FireRate = 8,
	FireCone = 4,
	SilentAim = false,
	SilentTp = false,
	SilentFov = 150,
	SilentRange = 600,
	SilentBurst = 4,
	SilentAutoFire = false,
	SilentAutoShots = 6,
	SilentCombat = true,
	SilentAlways = false,
	Ragebot = false,
	RageRange = 150,
	RageInterval = 0.05,
	RageBodyPart = "Head",
	RageJobCheck = false,
	RageWallCheck = false,
	RageWallbang = true,
	RageAliveCheck = false,
	RageCombatCheck = false,
	RagePoliceLock = false,
	RageCivilianLock = false,
	RageBeam = false,
	JumpEnabled = false,
	JumpPower = 50,
	JumpMultiplier = 1,
	InfiniteJump = false,
	AntiRagdoll = false,
	AntiArrest = false,
	AntiAfk = false,
	AntiPrisonPull = false,
	NoDamage = false,
	Noclip = false,
	Fly = false,
	FlySpeed = 30,
	Ghost = false,
	Stealth = false,
	InfStamina = false,
	InfHunger = false,
	AutoCuff = false,
	CuffTeleport = false,
	CuffCombat = false,
	CuffRange = 200,
	CuffInterval = 0.5,
	KillAura = false,
	AuraRange = 50,
	AuraDamage = 5,
	AuraInterval = 0.05,
	AuraPolice = false,
	AuraCivilian = false,
	AuraCombat = false,
	CombatBlock = false,
	InfAmmo = false,
	NoReload = false,
	AutoHack = false,
	AutoAtm = false,
	PickMoney = false,
	AutoMission = false,
	MissionHighPay = false,
	MissionInterval = 2,
	FarmBus = false,
	FarmTaxi = false,
	TaxiSafe = false,
	FarmFarmer = false,
	FarmChef = false,
	FarmGolf = false,
	SpeedHud = false,
	SpeedMph = false,
	Cruise = false,
	CollisionStop = false,
	Offroad = false,
	GroundLock = false,
	RideHeight = 0,
	Float = false,
	FloatHeight = 8,
	NoCrashes = false,
	FullFuel = false,
	RamInstant = true,
	RamDelay = 6,
	RamRange = 2000,
	AutoRam = false,
	KillCheck = true,
	FollowPlayer = false,
	FollowGap = 30,
	EspTracers = false,
	EspOffscreen = false,
	EspDots = false,
	EspDetails = false,
	EspHealth = false,
	EspWanted = false,
	EspHideDead = true,
	EspPoliceOnly = false,
	EspWantedOnly = false,
	EspRange = 1000,
	Blink = false,
	PlrWatch = false,
	PlrWatchMode = "cops",
	PlrWatchDist = 150,
	Defense = false,
	DefenseAutoFire = true,
	RetaliateFor = 5,
	AutoEquip = false,
	HotbarSlot = 1,
	TeamCheck = false,
	CrewCheck = false,
	FriendCheck = false,
	RoleFilter = false,
	WantedOnly = false,
	Whitelist = {},
	Roles = {
		Police = true,
		Medical = true,
		Fire = true,
		Transit = true,
		["Road Service"] = true,
		Farmer = true,
		Chef = true,
		Delivery = true,
		Civilian = true,
		Prisoner = true,
	},
}

local st = {
	silentToggle = nil,
	autoShootToggle = nil,
	aimToggle = nil,
	ragePoliceToggle = nil,
	rageCivilianToggle = nil,
	ragePartDropdown = nil,
	auraPoliceToggle = nil,
	auraCivilianToggle = nil,
	auraClock = 0,
	auraIdleUntil = 0,
	ammoWatched = {},
	ammoAddedConn = nil,
	ammoChar = nil,
	ammoScanAt = 0,
	moneyStarted = false,
	farmPrompts = {},
	farmPromptHooked = false,
	farmPromptCd = {},
	atmClicked = {},
	atmSeq = nil,
	atmClickAt = 0,
	atmResetAt = 0,
	taxiLastPos = nil,
	taxiOrigin = nil,
	golfReady = false,
	hackHacking = nil,
	hackStart = nil,
	hackCharMod = nil,
	hackRules = nil,
	rageRunning = true,
	bodyPartIds = {},
	jumpConn = nil,
	ghostDesyncPos = nil,
	ghostStreamOrig = nil,
	ghostPulseAt = 0,
	stealthConn = nil,
	stealthRenderConn = nil,
	stealthRealCF = nil,
	stealthVel = nil,
	stealthChar = nil,
	stealthAnim = nil,
	stealthWobble = 1,
	stealthLastGround = nil,
	stealthAnimAt = 0,
	stealthLocGrace = 0,
	coreModule = nil,
	coreLoading = false,
	staminaHooked = false,
	algorithmsModule = nil,
	charPivotToOrig = nil,
	coreNotifyOrig = nil,
	flyControls = nil,
	flyConn = nil,
	noclipConn = nil,
	noclipCache = {},
	ragdollModule = nil,
	ragdollCore = nil,
	ragdollActivate = nil,
	ragdollActivateServer = nil,
	ragdollOnRagdoll = nil,
	ragdollHooked = false,
	ragdollConn = nil,
	ragPretend = nil,
	ragFixUntil = 0,
	ragClock = 0,
	cuffModels = {},
	arrestRunning = false,
	arrestBusy = false,
	arrestCooldown = false,
	arrestGen = 0,
	arrestAddedConn = nil,
	arrestRemovingConn = nil,
	safeFloor = nil,
	afkConn = nil,
	syncingToggle = false,
	friendCache = {},
	backpackNames = {},
	incomingShots = {},
	defenseTarget = nil,
	defenseUntil = 0,
	defenseStarted = 0,
	defenseOwnedAim = false,
	defenseSavedShoot = nil,
	lastHealth = nil,
	whitelistQuery = "",
	whitelistSelected = nil,
	whitelistDropdown = nil,
	whitelistParagraph = nil,
	lastEquipAt = 0,
	playerEvent = nil,
	playerFunc = nil,
	remoteFolder = nil,
	charsFolder = nil,
	charCache = {},
	rootCache = {},
	headPartResolved = false,
	cuffGen = 0,
	cuffCooldown = {},
	headPartId = nil,
	silentSeq = 0,
	lastSilentSeq = 0,
	silentHooked = false,
	silentAutoTarget = nil,
	silentAutoCount = 0,
	silentAutoClock = 0,
	silentAutoCooldown = 0,
	silentCircleClock = 0,
	tpBusy = false,
	tpAt = 0,
	skipCombatOnce = false,
	tyreCache = {},
	nearbyTyres = {},
	nearbyTyresAt = 0,
	tyreScanOrigin = nil,
	gunConfigInst = nil,
	gunConfig = nil,
	gunConfigAt = 0,
	circleGui = nil,
	circleFrame = nil,
	touchDown = false,
	lastTouchPulse = 0,
	mouseHeld = false,
	currentTarget = nil,
	currentType = nil,
	rescanClock = 0,
	fireClock = 0,
	renderConn = nil,
}

local ghost = {
	on = false,
	advanced = false,
	stability = false,
	transParts = {},
	realCF = nil,
	hideCF = nil,
	desyncFrozen = false,
}

local veh = {
	started = false,
	ready = false,
}

local esp = {
	ready = false,
}

local tp = {
	ready = false,
}

local shop = {
	ready = false,
}

local pl = {
	ready = false,
	pinned = {},
	nearAt = {},
}

local stopFiring
local setAimAssist, setSilentAim
local setAutoShootState, startDefense, stopDefense, stopGhost, stopStealth, setAutoCuff, setAutoHack, startMoneyLoops, ensureSilentHook

local ROLE_ORDER = {
	"Police",
	"Medical",
	"Fire",
	"Transit",
	"Road Service",
	"Farmer",
	"Chef",
	"Delivery",
	"Civilian",
	"Prisoner",
}
local ROLE_LOCALE = {
	Police = "rolePolice",
	Medical = "roleMedical",
	Fire = "roleFire",
	Transit = "roleTransit",
	["Road Service"] = "roleRoad",
	Farmer = "roleFarmer",
	Chef = "roleChef",
	Delivery = "roleDelivery",
	Civilian = "roleCivilian",
	Prisoner = "rolePrisoner",
}
local RAGE_PART_ORDER = {
	"Head",
	"Torso",
	"LeftArm",
	"RightArm",
	"LeftLeg",
	"RightLeg",
}
local RAGE_PART_LOCALE = {
	Head = "rageHead",
	Torso = "rageTorso",
	LeftArm = "rageLeftArm",
	RightArm = "rageRightArm",
	LeftLeg = "rageLeftLeg",
	RightLeg = "rageRightLeg",
}
local RAGE_PART_ALIASES = {
	Head = { "Head" },
	Torso = { "Torso", "UpperTorso", "HumanoidRootPart" },
	LeftArm = { "LeftArm", "LeftUpperArm", "LeftHand" },
	RightArm = { "RightArm", "RightUpperArm", "RightHand" },
	LeftLeg = { "LeftLeg", "LeftUpperLeg", "LeftFoot" },
	RightLeg = { "RightLeg", "RightUpperLeg", "RightFoot" },
}
local SLOT_KEYS = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
}

local connections = {}
local function track(conn)
	if conn then
		table.insert(connections, conn)
	end
	return conn
end

local function getUiHost()
	if gethui then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	return CoreGui
end

local function getCharsFolder()
	local folder = st.charsFolder
	if folder and folder.Parent then
		return folder
	end
	folder = Workspace:FindFirstChild(CHARS_FOLDER)
	st.charsFolder = folder
	return folder
end

local getCharacter = LPH_NO_VIRTUALIZE(function(player)
	if not player then
		return nil
	end
	local cached = st.charCache[player]
	if cached and cached.Parent then
		return cached
	end
	if cached then
		st.rootCache[cached] = nil
	end
	local folder = getCharsFolder()
	local model = folder and folder:FindFirstChild(player.Name)
	if model and model.Parent then
		st.charCache[player] = model
		return model
	end
	local character = player.Character
	st.charCache[player] = character
	return character
end)

local getLocalParts = LPH_NO_VIRTUALIZE(function()
	if st._lpHotFrame == _hotFrame and st._lpChar then
		return st._lpChar, st._lpHum, st._lpRoot
	end
	local character = getCharacter(LocalPlayer)
	if not character then
		st._lpHotFrame, st._lpChar, st._lpHum, st._lpRoot = _hotFrame, nil, nil, nil
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character.PrimaryPart
	st._lpHotFrame, st._lpChar, st._lpHum, st._lpRoot = _hotFrame, character, humanoid, root
	return character, humanoid, root
end)

local function isGrounded(humanoid)
	if not humanoid then
		return false
	end
	local state = humanoid:GetState()
	return state == Enum.HumanoidStateType.Landed
		or state == Enum.HumanoidStateType.Running
		or state == Enum.HumanoidStateType.RunningNoPhysics
end

local function stopJumpBoost()
	if st.jumpConn then
		pcall(function()
			st.jumpConn:Disconnect()
		end)
		st.jumpConn = nil
	end
end

local function startJumpBoost()
	stopJumpBoost()
	if not (cfg.JumpEnabled or cfg.InfiniteJump) then
		return
	end
	st.jumpConn = UserInputService.JumpRequest:Connect(function()
		if not (cfg.JumpEnabled or cfg.InfiniteJump) or cfg.Fly then
			return
		end
		local _, humanoid, root = getLocalParts()
		if not humanoid or not root or humanoid.Health <= 0 then
			return
		end
		if not cfg.InfiniteJump and not isGrounded(humanoid) then
			return
		end
		root.CFrame = root.CFrame + Vector3.new(0, cfg.JumpPower * cfg.JumpMultiplier * 0.1, 0)
	end)
end

local function refreshJumpBoost()
	if cfg.JumpEnabled or cfg.InfiniteJump then
		startJumpBoost()
	else
		stopJumpBoost()
	end
end

local getRootPart = LPH_NO_VIRTUALIZE(function(character)
	character = character or getCharacter(LocalPlayer)
	if not character then
		return nil
	end
	local root = st.rootCache[character]
	if root and root.Parent and root:IsDescendantOf(character) then
		return root
	end
	root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	st.rootCache[character] = root
	return root
end)

local function ghostApplyVisual(character, on)
	if not character then
		return
	end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if on then
				if not ghost.transParts[descendant] then
					ghost.transParts[descendant] = {
						t = descendant.Transparency,
						l = descendant.LocalTransparencyModifier,
					}
				end
				descendant.LocalTransparencyModifier = 0.85
				descendant.Transparency = math.max(descendant.Transparency, 0.5)
			elseif ghost.transParts[descendant] then
				local stored = ghost.transParts[descendant]
				pcall(function()
					descendant.Transparency = stored.t
					descendant.LocalTransparencyModifier = stored.l
				end)
				ghost.transParts[descendant] = nil
			end
		end
	end
end

local function ghostComputeHideCF(rootCF)
	if not rootCF then
		return nil
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local character = getCharacter(LocalPlayer)
	params.FilterDescendantsInstances = character and { character } or {}
	local hit = Workspace:Raycast(rootCF.Position + Vector3.new(0, 3, 0), Vector3.new(0, -5000, 0), params)
	local y = hit and (hit.Position.Y - 5) or (rootCF.Position.Y - 120)
	return CFrame.new(rootCF.Position.X, y, rootCF.Position.Z) * (rootCF - rootCF.Position)
end

local function restoreGhostStream()
	pcall(function()
		if st.ghostStreamOrig ~= nil then
			Workspace.StreamingPauseMode = st.ghostStreamOrig
			st.ghostStreamOrig = nil
		end
	end)
end

stopGhost = function()
	ghost.on = false
	cfg.Ghost = false
	ghost.advanced = false
	ghost.stability = false
	ghost.desyncFrozen = false
	st.ghostDesyncPos = nil
	ghost.realCF = nil
	ghost.hideCF = nil
	restoreGhostStream()
	local character = getCharacter(LocalPlayer)
	local root = getRootPart(character)
	if root then
		pcall(function()
			root.Anchored = false
		end)
	end
	if not cfg.Stealth then
		ghostApplyVisual(character, false)
		ghost.transParts = {}
	end
end

local function setGhost(on)
	if not on then
		stopGhost()
		notify("Xi Pro", T("godOff"))
		return
	end
	pcall(ensureSilentHook)
	ghost.on = true
	cfg.Ghost = true
	ghost.advanced = true
	ghost.stability = true
	local root = getRootPart()
	if root then
		ghost.realCF = root.CFrame
		ghost.hideCF = ghostComputeHideCF(root.CFrame)
		st.ghostDesyncPos = root.Position
		if st.ghostStreamOrig == nil then
			st.ghostStreamOrig = Workspace.StreamingPauseMode
		end
		pcall(function()
			Workspace.StreamingPauseMode = Enum.StreamingPauseMode.Disabled
		end)
	end
	ghostApplyVisual(getCharacter(LocalPlayer), true)
	notify("Xi Pro", T("godOn"))
end

local tickGhost = LPH_NO_VIRTUALIZE(function()
	if not ghost.on then
		return
	end
	local character = getCharacter(LocalPlayer)
	local root = getRootPart(character)
	if not root then
		return
	end
	if not ghost.desyncFrozen then
		ghost.realCF = root.CFrame
	end
	if cfg.Fly or cfg.Noclip or cfg.Stealth then
		return
	end
	if not (st.ghostDesyncPos and ghost.hideCF) then
		return
	end
	local interval = 1.1
	if os.clock() < st.ghostPulseAt or ghost.desyncFrozen then
		return
	end
	st.ghostPulseAt = os.clock() + interval
	ghost.desyncFrozen = true
	pcall(function()
		root.Anchored = true
		root.CFrame = ghost.hideCF
		root.AssemblyLinearVelocity = Vector3.zero
	end)
	task.delay(0.12, function()
		if ghost.on and root.Parent then
			pcall(function()
				root.Anchored = false
				if ghost.realCF then
					root.CFrame = ghost.realCF
				end
			end)
		end
		ghost.desyncFrozen = false
	end)
end)

local function stealthFilter(character)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local list = { character, Camera }
	local gameplay = Workspace:FindFirstChild("Gameplay")
	local vehicles = gameplay and gameplay:FindFirstChild("Vehicles")
	local chars = Workspace:FindFirstChild(CHARS_FOLDER)
	if vehicles then
		list[#list + 1] = vehicles
	end
	if chars then
		list[#list + 1] = chars
	end
	params.FilterDescendantsInstances = list
	return params
end

local function playStealthAnim(character)
	if st.stealthAnim then
		pcall(function()
			st.stealthAnim:Stop()
			st.stealthAnim:Destroy()
		end)
		st.stealthAnim = nil
	end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	local r15 = humanoid.RigType == Enum.HumanoidRigType.R15
	local animation = Instance.new("Animation")
	animation.AnimationId = r15 and "rbxassetid://18537363391" or "rbxassetid://215384594"
	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	pcall(function()
		animation:Destroy()
	end)
	if not (ok and track) then
		return
	end
	st.stealthAnim = track
	pcall(function()
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = true
		track:Play()
		track:AdjustWeight(0.001)
		track:AdjustSpeed(0)
		track.TimePosition = r15 and 0.77 or 0.38
	end)
end

local tickStealthHeart = LPH_NO_VIRTUALIZE(function()
	if not cfg.Stealth then
		return
	end
	local character = getCharacter(LocalPlayer)
	local root = getRootPart(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (character and root and humanoid) then
		return
	end
	if character ~= st.stealthChar then
		st.stealthChar = character
		ghost.transParts = {}
		ghostApplyVisual(character, true)
		playStealthAnim(character)
	end
	if root.AssemblyRootPart and root.AssemblyRootPart ~= root then
		ghostApplyVisual(character, false)
		st.stealthRealCF = nil
		return
	end
	ghostApplyVisual(character, true)
	if not (st.stealthAnim and st.stealthAnim.IsPlaying) and os.clock() >= st.stealthAnimAt then
		st.stealthAnimAt = os.clock() + 0.5
		playStealthAnim(character)
	end
	if ghost.desyncFrozen then
		st.stealthRealCF = root.CFrame
		return
	end
	if st.stealthRealCF and math.abs(root.Position.Y - st.stealthRealCF.Position.Y) > 150 then
		st.stealthLocGrace = os.clock() + 8
		st.stealthLastGround = nil
	end
	st.stealthRealCF = root.CFrame
	local rot = root.CFrame - root.Position
	local params = stealthFilter(character)
	local flying = cfg.Fly == true
	if not flying and st.stealthLastGround and os.clock() >= st.stealthLocGrace then
		local drop = st.stealthRealCF.Position.Y - st.stealthLastGround.Position.Y
		if drop < -60 and not Workspace:Raycast(st.stealthRealCF.Position, Vector3.new(0, -3000, 0), params) then
			st.stealthRealCF = st.stealthLastGround
			pcall(function()
				root.CFrame = st.stealthLastGround
				root.AssemblyLinearVelocity = Vector3.zero
			end)
		end
	end
	local hit = Workspace:Raycast(root.Position + Vector3.new(0, 4, 0), Vector3.new(0, -4096, 0), params)
	local extra = 5
	local hip = humanoid.HipHeight + root.Size.Y / 2
	local airborne = hit and root.Position.Y - hit.Position.Y > hip + 3
	if flying or airborne then
		extra += 12
	end
	local buriedY = hit and (hit.Position.Y - extra) or (root.Position.Y - hip - extra)
	local onGround = not flying and hit and root.Position.Y - hit.Position.Y < hip + 4
	if onGround then
		st.stealthLastGround = st.stealthRealCF
	end
	local wobble = 0
	if humanoid.MoveDirection.Magnitude < 0.05 then
		st.stealthWobble = -st.stealthWobble
		wobble = st.stealthWobble
	end
	local r15 = humanoid.RigType == Enum.HumanoidRigType.R15
	local pos = Vector3.new(root.Position.X + wobble, buriedY, root.Position.Z + wobble)
	pcall(function()
		root.CFrame = CFrame.new(pos) * rot * CFrame.Angles(math.rad(r15 and 180 or 90), 0, 0)
		if not flying then
			st.stealthVel = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end)
	if st.stealthAnim then
		pcall(function()
			st.stealthAnim:AdjustWeight(100)
			st.stealthAnim:AdjustSpeed(0)
			st.stealthAnim.TimePosition = r15 and 0.77 or 0.38
		end)
	end
end)

local tickStealthRender = LPH_NO_VIRTUALIZE(function()
	if not cfg.Stealth then
		return
	end
	local root = getRootPart()
	if root and st.stealthRealCF then
		local now = root.CFrame
		local dx = now.Position.X - st.stealthRealCF.Position.X
		local dz = now.Position.Z - st.stealthRealCF.Position.Z
		local dy = math.abs(now.Position.Y - st.stealthRealCF.Position.Y)
		local flipped = now.UpVector.Y < 0
		if (dx * dx + dz * dz > 1600 or dy > 150) and not flipped then
			if dy > 150 then
				st.stealthLocGrace = os.clock() + 8
			end
			st.stealthRealCF = now
		else
			pcall(function()
				root.CFrame = st.stealthRealCF
			end)
		end
	end
	if st.stealthVel and root then
		local vel = st.stealthVel
		st.stealthVel = nil
		pcall(function()
			root.AssemblyLinearVelocity = vel
		end)
	end
	if st.stealthAnim then
		pcall(function()
			st.stealthAnim:AdjustWeight(0.001)
		end)
	end
	ghostApplyVisual(getCharacter(LocalPlayer), true)
end)

stopStealth = function()
	cfg.Stealth = false
	if st.stealthConn then
		pcall(function()
			st.stealthConn:Disconnect()
		end)
		st.stealthConn = nil
	end
	if st.stealthRenderConn then
		pcall(function()
			st.stealthRenderConn:Disconnect()
		end)
		st.stealthRenderConn = nil
	end
	pcall(function()
		RunService:UnbindFromRenderStep("XiProStealthRender")
	end)
	if st.stealthAnim then
		pcall(function()
			st.stealthAnim:Stop()
			st.stealthAnim:Destroy()
		end)
		st.stealthAnim = nil
	end
	local character = getCharacter(LocalPlayer)
	local root = getRootPart(character)
	local restore = st.stealthRealCF
	st.stealthRealCF = nil
	st.stealthVel = nil
	st.stealthChar = nil
	st.stealthLastGround = nil
	if root and restore then
		pcall(function()
			root.CFrame = restore
			root.AssemblyLinearVelocity = Vector3.zero
			root.Anchored = false
		end)
	end
	if not (ghost and ghost.on) then
		ghostApplyVisual(character, false)
		ghost.transParts = {}
	end
end

local function setStealth(on)
	if not on then
		stopStealth()
		notify("Xi Pro", T("stealthOff"))
		return
	end
	if st.stealthConn then
		pcall(function()
			st.stealthConn:Disconnect()
		end)
		st.stealthConn = nil
	end
	if st.stealthRenderConn then
		pcall(function()
			st.stealthRenderConn:Disconnect()
		end)
		st.stealthRenderConn = nil
	end
	pcall(function()
		RunService:UnbindFromRenderStep("XiProStealthRender")
	end)
	cfg.Stealth = true
	st.stealthRealCF = nil
	st.stealthVel = nil
	st.stealthLastGround = nil
	st.stealthChar = getCharacter(LocalPlayer)
	ghostApplyVisual(st.stealthChar, true)
	playStealthAnim(st.stealthChar)
	st.stealthConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(tickStealthHeart))
	local bound = pcall(function()
		RunService:BindToRenderStep("XiProStealthRender", Enum.RenderPriority.Camera.Value - 1, LPH_NO_VIRTUALIZE(tickStealthRender))
	end)
	if not bound then
		st.stealthRenderConn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(tickStealthRender))
	end
	notify("Xi Pro", T("stealthOn"))
end

local function callAtIdentity(fn)
	local setId = setthreadidentity or setidentity
	local getId = getthreadidentity or getidentity
	if type(setId) == "function" then
		local old
		pcall(function()
			old = getId and getId()
		end)
		local lastErr
		for _, identity in ipairs({ 2, 3, 1, 8 }) do
			pcall(setId, identity)
			local ok, result = pcall(fn)
			if ok then
				if old ~= nil then
					pcall(setId, old)
				end
				return result
			end
			lastErr = result
		end
		if old ~= nil then
			pcall(setId, old)
		end
		error(lastErr)
	end
	return fn()
end

local function loadCoreModule()
	if st.coreModule or st.coreLoading then
		return
	end
	st.coreLoading = true
	task.spawn(function()
		local ok, result = pcall(function()
			return callAtIdentity(function()
				local modules = ReplicatedStorage:WaitForChild("Modules", 20)
				local loader = modules and modules:WaitForChild("ModuleLoader", 20)
				local scripts = LocalPlayer:WaitForChild("PlayerScripts", 20)
				local framework = scripts and scripts:WaitForChild("Framework", 20)
				local core = framework and framework:WaitForChild("Core", 20)
				if loader and core then
					local loaded = require(loader)
					if type(loaded) == "table" and type(loaded.assign) == "function" then
						return loaded.assign(core)
					end
				end
				if core then
					return require(core)
				end
				error("Modules.ModuleLoader / Core not found")
			end)
		end)
		if ok and type(result) == "table" then
			st.coreModule = result
		else
			warn("[Xi Pro] Stamina/Food load failed: " .. tostring(result))
		end
		st.coreLoading = false
	end)
end

local function hookStaminaFood()
	if st.staminaHooked or not st.coreModule then
		return
	end
	local original = st.coreModule.setCoreStaminaOrFood
	if type(original) ~= "function" then
		return
	end
	st.coreModule.setCoreStaminaOrFood = function(kind, amount, ...)
		local current = st.coreModule[kind]
		if type(current) == "number" and type(amount) == "number" and amount < current then
			if kind == "food" and cfg.InfHunger or kind == "stamina" and cfg.InfStamina then
				return
			end
		end
		return original(kind, amount, ...)
	end
	st.staminaHooked = true
end

local function hookPrisonNotify()
	if st.coreNotifyOrig or not st.coreModule then
		return
	end
	local original = st.coreModule.notify
	if type(original) ~= "function" then
		return
	end
	st.coreNotifyOrig = original
	st.coreModule.notify = function(payload)
		if cfg.AntiPrisonPull then
			local message = type(payload) == "table" and payload.message
			if type(message) == "string" and string.find(message, "You can't leave prison yet", 1, true) then
				return nil
			end
		end
		return st.coreNotifyOrig(payload)
	end
end

local function setAntiPrisonPull(on)
	cfg.AntiPrisonPull = on and true or false
	pcall(function()
		callAtIdentity(function()
			local modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules", 5)
			local alg = modules and (modules:FindFirstChild("Algorithms") or modules:WaitForChild("Algorithms", 5))
			if not alg then
				return
			end
			local Algorithms = require(alg)
			if type(Algorithms) ~= "table" then
				return
			end
			st.algorithmsModule = Algorithms
			if cfg.AntiPrisonPull then
				if not st.charPivotToOrig and type(Algorithms.charPivotTo) == "function" then
					st.charPivotToOrig = Algorithms.charPivotTo
					Algorithms.charPivotTo = function()
						return nil
					end
				end
			elseif st.charPivotToOrig then
				Algorithms.charPivotTo = st.charPivotToOrig
				st.charPivotToOrig = nil
			end
		end)
	end)
	if cfg.AntiPrisonPull then
		loadCoreModule()
		hookPrisonNotify()
	elseif st.coreNotifyOrig and st.coreModule then
		pcall(function()
			st.coreModule.notify = st.coreNotifyOrig
		end)
		st.coreNotifyOrig = nil
	end
end

local function loadRagdollModules()
	if st.ragdollModule then
		return true
	end
	pcall(function()
		callAtIdentity(function()
			local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
			local framework = scripts and scripts:FindFirstChild("Framework")
			local core = framework and framework:FindFirstChild("Core")
			local modules = ReplicatedStorage:FindFirstChild("Modules")
			local rag = modules and modules:FindFirstChild("Ragdoll")
			if core then
				st.ragdollCore = require(core)
			end
			if rag then
				st.ragdollModule = require(rag)
			end
		end)
	end)
	return st.ragdollModule ~= nil
end

local tickAntiRagdoll = LPH_NO_VIRTUALIZE(function()
	st.ragClock += 0.016
	if st.ragClock < 0.05 then
		return
	end
	st.ragClock = 0
	local character = getCharacter(LocalPlayer)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if st.ragPretend and ((os.clock() - st.ragPretend > 0.6 and root.AssemblyLinearVelocity.Y > -5) or os.clock() - st.ragPretend > 4) then
		st.ragPretend = nil
		pcall(function()
			if st.ragdollModule then
				st.ragdollModule.isActive = false
			end
		end)
	end
	if root.AssemblyRootPart ~= root then
		return
	end
	local fixed = false
	local socket = root:FindFirstChild("RagdollRootBallSocket")
	if socket and socket.Enabled then
		pcall(function()
			socket.Enabled = false
		end)
		fixed = true
	end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("AnimationConstraint") and not descendant.Enabled then
			pcall(function()
				descendant.Enabled = true
			end)
			fixed = true
		end
	end
	if fixed then
		st.ragFixUntil = os.clock() + 3
	end
	if os.clock() < st.ragFixUntil and not cfg.Noclip and not root.CanCollide then
		pcall(function()
			root.CanCollide = true
		end)
	end
end)

local function setAntiRagdoll(on)
	cfg.AntiRagdoll = on and true or false
	if not on then
		if st.ragdollConn then
			pcall(function()
				st.ragdollConn:Disconnect()
			end)
			st.ragdollConn = nil
		end
		if st.ragPretend then
			st.ragPretend = nil
			pcall(function()
				if st.ragdollModule then
					st.ragdollModule.isActive = false
				end
			end)
		end
		if st.ragdollHooked and st.ragdollModule then
			if st.ragdollActivate then
				pcall(function()
					st.ragdollModule.activate = st.ragdollActivate
				end)
				st.ragdollActivate = nil
			end
			if st.ragdollActivateServer then
				pcall(function()
					st.ragdollModule.activateServer = st.ragdollActivateServer
				end)
				st.ragdollActivateServer = nil
			end
			if st.ragdollCore and st.ragdollOnRagdoll ~= nil then
				pcall(function()
					st.ragdollCore.onRagdoll = st.ragdollOnRagdoll
				end)
			end
			st.ragdollHooked = false
		end
		return
	end
	if not loadRagdollModules() then
		notify("Xi Pro", T("antiRagdollMissing"))
		return
	end
	if not st.ragdollHooked then
		st.ragdollActivate = rawget(st.ragdollModule, "activate")
		if type(st.ragdollActivate) == "function" then
			st.ragdollModule.activate = function(character, active, ...)
				local mine = getCharacter(LocalPlayer)
				if character == mine or character == LocalPlayer.Character then
					if active then
						st.ragdollModule.isActive = true
						st.ragPretend = os.clock()
						return
					end
					if st.ragPretend then
						st.ragPretend = nil
						st.ragdollModule.isActive = false
						return
					end
					if not st.ragdollModule.isActive then
						return
					end
				end
				return st.ragdollActivate(character, active, ...)
			end
		end
		local server = rawget(st.ragdollModule, "activateServer")
		if type(server) == "function" then
			st.ragdollActivateServer = server
			st.ragdollModule.activateServer = function(character, active, ...)
				if cfg.AntiRagdoll and active then
					return
				end
				return st.ragdollActivateServer(character, active, ...)
			end
		end
		if st.ragdollCore then
			st.ragdollOnRagdoll = st.ragdollCore.onRagdoll
			st.ragdollCore.onRagdoll = function()
			end
		end
		st.ragdollHooked = true
	end
	if not st.ragdollConn then
		st.ragdollConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
			if cfg.AntiRagdoll then tickAntiRagdoll() end
		end))
	end
end

local function registerCuff(instance)
	if instance:IsA("Model") and instance.Name == "PD Handcuffs" then
		st.cuffModels[instance] = true
	end
end

local function cuffsNearby(root)
	for model in pairs(st.cuffModels) do
		if model.Parent then
			local handle = model:FindFirstChild("Handle") or model:FindFirstChildWhichIsA("BasePart")
			if handle and (handle.Position - root.Position).Magnitude < 8 then
				return true
			end
		else
			st.cuffModels[model] = nil
		end
	end
	return false
end

local function ensureSafeFloor()
	if st.safeFloor and st.safeFloor.Parent then
		return
	end
	local part = Instance.new("Part")
	part.Name = "XiProSafeFloor"
	part.Size = Vector3.new(48, 1, 48)
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = true
	part.Parent = Workspace
	st.safeFloor = part
end

local function setAntiArrest(on)
	cfg.AntiArrest = on and true or false
	st.arrestRunning = cfg.AntiArrest
	if not on then
		st.arrestGen += 1
		st.arrestBusy = false
		st.arrestCooldown = false
		if st.arrestAddedConn then
			pcall(function()
				st.arrestAddedConn:Disconnect()
			end)
			st.arrestAddedConn = nil
		end
		if st.arrestRemovingConn then
			pcall(function()
				st.arrestRemovingConn:Disconnect()
			end)
			st.arrestRemovingConn = nil
		end
		if st.safeFloor then
			pcall(function()
				st.safeFloor:Destroy()
			end)
			st.safeFloor = nil
		end
		return
	end
	if not getRootPart() then
		notify("Xi Pro", T("antiArrestNoChar"))
	end
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		registerCuff(descendant)
	end
	st.arrestAddedConn = Workspace.DescendantAdded:Connect(registerCuff)
	st.arrestRemovingConn = Workspace.DescendantRemoving:Connect(function(instance)
		st.cuffModels[instance] = nil
	end)
	st.arrestGen += 1
	local gen = st.arrestGen
	task.spawn(function()
		while st.arrestRunning and gen == st.arrestGen do
			local characterRoot = getRootPart()
			local team = LocalPlayer.Team
			local isPolice = team ~= nil and team.Name == "Police"
			if characterRoot and not isPolice and not st.arrestBusy and not st.arrestCooldown and cuffsNearby(characterRoot) then
				st.arrestBusy = true
				st.arrestCooldown = true
				ensureSafeFloor()
				local pos = Vector3.new(characterRoot.Position.X, -500, characterRoot.Position.Z)
				if st.safeFloor then
					st.safeFloor.Position = pos
				end
				pcall(function()
					characterRoot.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
				end)
				task.wait(8)
				st.arrestBusy = false
				task.wait(8)
				st.arrestCooldown = false
			else
				task.wait(0.3)
			end
		end
	end)
end

local function setAntiAfk(on)
	cfg.AntiAfk = on and true or false
	if on then
		if st.afkConn then
			return
		end
		st.afkConn = LocalPlayer.Idled:Connect(function()
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end)
		return
	end
	if st.afkConn then
		pcall(function()
			st.afkConn:Disconnect()
		end)
		st.afkConn = nil
	end
end

local function restoreNoclip()
	for part, collide in pairs(st.noclipCache) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = collide
			end)
		end
	end
	st.noclipCache = {}
end

local function stopNoclip()
	if st.noclipConn then
		pcall(function()
			st.noclipConn:Disconnect()
		end)
		st.noclipConn = nil
	end
	restoreNoclip()
end

local function startNoclip()
	if st.noclipConn then
		pcall(function()
			st.noclipConn:Disconnect()
		end)
		st.noclipConn = nil
	end
	restoreNoclip()
	if not cfg.Noclip then
		return
	end
	st.noclipAcc = 0
	st.noclipParts = nil
	st.noclipBuilt = 0
	st.noclipConn = RunService.Stepped:Connect(LPH_NO_VIRTUALIZE(function(_, dt)
		if not cfg.Noclip then
			return
		end
		st.noclipAcc = (st.noclipAcc or 0) + (dt or 0)
		if st.noclipAcc < 0.1 then
			return
		end
		st.noclipAcc = 0
		local character = getCharacter(LocalPlayer)
		if not character then
			return
		end
		local now = os.clock()
		if not st.noclipParts or st.noclipOwner ~= character or now - (st.noclipBuilt or 0) > 0.5 then
			local parts = {}
			local ok, list = pcall(function()
				return character:GetDescendants()
			end)
			if not ok then
				return
			end
			for i = 1, #list do
				if list[i]:IsA("BasePart") then
					parts[#parts + 1] = list[i]
				end
			end
			st.noclipParts, st.noclipOwner, st.noclipBuilt = parts, character, now
		end
		local parts = st.noclipParts
		for i = 1, #parts do
			local part = parts[i]
			if part.Parent then
				if st.noclipCache[part] == nil then
					st.noclipCache[part] = part.CanCollide
				end
				part.CanCollide = false
			end
		end
	end))
end

local function ensureFlyControls()
	if st.flyControls then
		return
	end
	pcall(function()
		local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
		local module = scripts and scripts:FindFirstChild("PlayerModule")
		if module then
			st.flyControls = require(module):GetControls()
		end
	end)
end

local getFlyDelta = LPH_NO_VIRTUALIZE(function(dt, camera, humanoid)
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local move = Vector3.zero
	if st.flyControls and st.flyControls.GetMoveVector then
		local ok, vec = pcall(function()
			return st.flyControls:GetMoveVector()
		end)
		if ok and typeof(vec) == "Vector3" then
			move = look * -vec.Z + right * vec.X
		end
	end
	if move.Magnitude < 0.01 and humanoid and humanoid.MoveDirection.Magnitude > 0.01 then
		move = humanoid.MoveDirection
	end
	local y = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
		y = 1
	elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		or UserInputService:IsKeyDown(Enum.KeyCode.C)
	then
		y = -1
	elseif humanoid and (humanoid.Jump or humanoid:GetState() == Enum.HumanoidStateType.Jumping) then
		y = 1
	end
	if move.Magnitude > 1 then
		move = move.Unit
	end
	return (move + Vector3.new(0, y, 0)) * (tonumber(cfg.FlySpeed) or 30) * dt
end)

local function stopFly()
	if st.flyConn then
		pcall(function()
			st.flyConn:Disconnect()
		end)
		st.flyConn = nil
	end
	local _, humanoid = getLocalParts()
	if humanoid then
		pcall(function()
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end)
	end
end

local function startFly()
	if st.flyConn then
		pcall(function()
			st.flyConn:Disconnect()
		end)
		st.flyConn = nil
	end
	if not cfg.Fly then
		return
	end
	ensureFlyControls()
	local _, humanoid, root = getLocalParts()
	if not humanoid or not root then
		return
	end
	humanoid.AutoRotate = false
	st.flyConn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
		if not cfg.Fly then
			return
		end
		local _, hum, part = getLocalParts()
		Camera = Workspace.CurrentCamera
		if not (hum and part and Camera) then
			return
		end
		local delta = getFlyDelta(dt or 0, Camera, hum)
		part.CFrame = part.CFrame + delta
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Climbing)
		end)
	end))
end

local function getVehicle(player)
	local character = getCharacter(player)
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not root then
		return nil
	end
	local assemblyRoot = root.AssemblyRootPart
	if assemblyRoot and assemblyRoot ~= root then
		local model = assemblyRoot:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("_Chassis") then
			return model
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.SeatPart then
		local model = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("_Chassis") then
			return model
		end
	end
	return nil
end

local function ancestorVehicle(instance, vehiclesFolder)
	while instance and instance.Parent and instance.Parent ~= vehiclesFolder do
		instance = instance.Parent
	end
	if instance and instance.Parent == vehiclesFolder and instance:IsA("Model") then
		return instance
	end
	return nil
end

local function registerTyre(part, vehiclesFolder)
	if not (part:IsA("BasePart") and part.Name == "WheelCollision") then
		return
	end
	local parent = part.Parent
	if not (parent and parent.Name == "Tire") then
		return
	end
	local vehicle = ancestorVehicle(part, vehiclesFolder)
	if not vehicle then
		return
	end
	local size = part.Size
	st.tyreCache[part] = {
		part = part,
		radius = (size.Y + size.Z) / 4,
		vehicle = vehicle,
	}
end

task.spawn(function()
	local gameplay = Workspace:FindFirstChild("Gameplay") or Workspace:WaitForChild("Gameplay", 12)
	local vehicles = gameplay and (gameplay:FindFirstChild("Vehicles") or gameplay:WaitForChild("Vehicles", 12))
	if not vehicles then
		return
	end
	for _, descendant in ipairs(vehicles:GetDescendants()) do
		registerTyre(descendant, vehicles)
	end
	track(vehicles.DescendantAdded:Connect(function(inst)
		registerTyre(inst, vehicles)
	end))
	track(vehicles.DescendantRemoving:Connect(function(inst)
		st.tyreCache[inst] = nil
	end))
end)

local getNearbyTyres = LPH_NO_VIRTUALIZE(function()
	if not cfg.TargetTyres then
		return st.nearbyTyres
	end
	local myChar = getCharacter(LocalPlayer)
	local originPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = originPart and originPart.Position or Camera.CFrame.Position
	local moved = not st.tyreScanOrigin or (origin - st.tyreScanOrigin).Magnitude > 4
	local interval = moved and 0.5 or 1
	if os.clock() - st.nearbyTyresAt < interval then
		return st.nearbyTyres
	end
	st.tyreScanOrigin = origin
	local list = {}
	local myVehicle = getVehicle(LocalPlayer)
	local maxDist = cfg.MaxDistance + 40
	for part, info in pairs(st.tyreCache) do
		if not part.Parent then
			st.tyreCache[part] = nil
		elseif info.vehicle ~= myVehicle and (part.Position - origin).Magnitude <= maxDist then
			local durability = part:GetAttribute("Durability")
			if durability == nil or durability > 0 then
				list[#list + 1] = info
			end
		end
	end
	st.nearbyTyres = list
	st.nearbyTyresAt = os.clock()
	return list
end)

local getTyreAimPoint = LPH_NO_VIRTUALIZE(function(info)
	local part = info.part
	local position = part.Position
	local right = part.CFrame.RightVector
	local toCamera = (Camera.CFrame.Position - position).Unit
	local outward = toCamera - toCamera:Dot(right) * right
	if outward.Magnitude < 0.001 then
		outward = part.CFrame.UpVector
	end
	return position + outward.Unit * info.radius
end)

local function refreshFriend(player)
	if not player or player == LocalPlayer then
		return
	end
	task.spawn(function()
		local ok, result = pcall(function()
			return LocalPlayer:IsFriendsWith(player.UserId)
		end)
		st.friendCache[player.UserId] = ok and result and true or false
	end)
end

local function refreshAllFriends()
	for _, player in ipairs(Players:GetPlayers()) do
		refreshFriend(player)
	end
end

local function shouldSkipPlayer(player)
	if not player or player == LocalPlayer then
		return true
	end
	if st.lockPlayer == player then
		return false
	end
	if cfg.Whitelist[player.Name] then
		return true
	end
	if cfg.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
		return true
	end
	if cfg.FriendCheck and st.friendCache[player.UserId] then
		return true
	end
	if cfg.CrewCheck then
		local myCrew = LocalPlayer:FindFirstChild("Crew")
		local theirCrew = player:FindFirstChild("Crew")
		if myCrew and theirCrew and myCrew.Value ~= "" and myCrew.Value == theirCrew.Value then
			return true
		end
	end
	if cfg.RoleFilter then
		local team = player.Team
		if not team or not cfg.Roles[team.Name] then
			return true
		end
	end
	if cfg.WantedOnly then
		local wanted = player:GetAttribute("WantedLevel")
		if not (type(wanted) == "number" and wanted > 0) then
			return true
		end
	end
	return false
end

local isPlayerValid = LPH_NO_VIRTUALIZE(function(player, maxDistance)
	if player == LocalPlayer or not player then
		return false
	end
	if shouldSkipPlayer(player) then
		return false
	end
	local character = getCharacter(player)
	if not character then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then
		return false
	end
	if character:GetAttribute("IsDead") == true then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local myChar = getCharacter(LocalPlayer)
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if root and myRoot and (root.Position - myRoot.Position).Magnitude > (maxDistance or cfg.MaxDistance) then
		return false
	end
	return true
end)

local function wantedLevelOf(player)
	local level = player and player:GetAttribute("WantedLevel")
	if type(level) ~= "number" then
		local character = getCharacter(player)
		level = character and character:GetAttribute("WantedLevel")
	end
	return type(level) == "number" and level or 0
end

local function isLocalPolice()
	local team = LocalPlayer.Team
	if not team then
		return false
	end
	local name = string.lower(tostring(team.Name))
	return string.find(name, "police", 1, true)
		or string.find(name, "sheriff", 1, true)
		or string.find(name, "trooper", 1, true)
end

local function getRemoteFolder()
	local remote = st.remoteFolder
	if remote and remote.Parent then
		return remote
	end
	remote = ReplicatedStorage:FindFirstChild("Remote")
	st.remoteFolder = remote
	return remote
end

local function resolvePlayerFunc()
	if st.playerFunc and st.playerFunc.Parent then
		return st.playerFunc
	end
	local remote = getRemoteFolder()
	local func = remote and remote:FindFirstChild("PlayerFunc")
	if func then
		st.playerFunc = func
	end
	return st.playerFunc
end

local function playerWorldPos(player)
	local attr = player and player:GetAttribute("CharacterPosition")
	if typeof(attr) == "Vector3" then
		return attr
	end
	if typeof(attr) == "CFrame" then
		return attr.Position
	end
	local root = getRootPart(getCharacter(player))
	return root and root.Position
end

local function cuffTargetOk(player)
	if not player or player == LocalPlayer then
		return false
	end
	if cfg.Whitelist[player.Name] then
		return false
	end
	if wantedLevelOf(player) <= 0 then
		return false
	end
	local character = getCharacter(player)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (humanoid and humanoid.Health > 0) then
		return false
	end
	if character:GetAttribute("IsDead") == true then
		return false
	end
	if cfg.CuffCombat then
		if player:GetAttribute("CombatMode") ~= true and player:GetAttribute("Pursuit") ~= true then
			return false
		end
	end
	return true
end

local function teleportBehind(target)
	local myRoot = getRootPart(getCharacter(LocalPlayer))
	local theirRoot = getRootPart(getCharacter(target))
	if not (myRoot and theirRoot) then
		return false
	end
	local behind = theirRoot.Position - theirRoot.CFrame.LookVector * 3
	local cf = CFrame.new(behind, theirRoot.Position)
	pcall(function()
		myRoot.CFrame = cf
		myRoot.AssemblyLinearVelocity = Vector3.zero
	end)
	if ghost and ghost.on then
		ghost.realCF = cf
		st.ghostDesyncPos = cf.Position
		ghost.hideCF = ghostComputeHideCF(cf)
	end
	if cfg.Stealth then
		st.stealthRealCF = cf
	end
	return true
end

setAutoCuff = function(on)
	cfg.AutoCuff = on and true or false
	st.cuffGen += 1
	local gen = st.cuffGen
	if not cfg.AutoCuff then
		return
	end
	task.spawn(function()
		while cfg.AutoCuff and st.cuffGen == gen do
			if isLocalPolice() then
				local myRoot = getRootPart(getCharacter(LocalPlayer))
				local playerFunc = resolvePlayerFunc()
				if myRoot and playerFunc then
					local range = tonumber(cfg.CuffRange) or 200
					if cfg.CuffTeleport then
						local best, bestDist
						for _, player in ipairs(Players:GetPlayers()) do
							if cuffTargetOk(player) then
								local pos = playerWorldPos(player)
								local dist = pos and (pos - myRoot.Position).Magnitude
								if dist and dist <= range and (not bestDist or dist < bestDist) then
									best = player
									bestDist = dist
								end
							end
						end
						if best then
							teleportBehind(best)
							myRoot = getRootPart(getCharacter(LocalPlayer)) or myRoot
						end
					end
					local now = os.clock()
					local origin = myRoot.Position
					local waitFor = math.max(0.4, tonumber(cfg.CuffInterval) or 0.5)
					for _, player in ipairs(Players:GetPlayers()) do
						if cuffTargetOk(player) then
							local pos = playerWorldPos(player)
							local dist = pos and (pos - origin).Magnitude
							if dist and dist <= range and now - (st.cuffCooldown[player] or 0) >= waitFor then
								st.cuffCooldown[player] = now
								task.spawn(function()
									pcall(function()
										playerFunc:InvokeServer("handcuff", player, false)
									end)
								end)
							end
						end
					end
				end
			end
			task.wait(math.max(0.1, tonumber(cfg.CuffInterval) or 0.5))
		end
	end)
end

local AMMO_FILL = 999

local function fillAmmoValue(value)
	if not (value and value.Parent) then
		return
	end
	local name = value.Name
	local want = (name == "TotalAmmo" and cfg.InfAmmo) or (name == "Ammo" and cfg.NoReload)
	if not want then
		return
	end
	if value.Value ~= AMMO_FILL then
		pcall(function()
			value.Value = AMMO_FILL
		end)
	end
end

local function watchAmmoValue(value)
	if not value or st.ammoWatched[value] then
		return
	end
	if value.Name ~= "TotalAmmo" and value.Name ~= "Ammo" then
		return
	end
	if not (value.Parent and value.Parent.Name == "Config") then
		return
	end
	if not (value:IsA("IntValue") or value:IsA("NumberValue")) then
		return
	end
	st.ammoWatched[value] = true
	fillAmmoValue(value)
	track(value.Changed:Connect(function()
		fillAmmoValue(value)
	end))
end

local function scanAmmo(character)
	if not character then
		return
	end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant.Name == "Config" then
			watchAmmoValue(descendant:FindFirstChild("TotalAmmo"))
			watchAmmoValue(descendant:FindFirstChild("Ammo"))
		elseif (descendant.Name == "TotalAmmo" or descendant.Name == "Ammo") and descendant.Parent and descendant.Parent.Name == "Config" then
			watchAmmoValue(descendant)
		end
	end
end

local tickAmmo = LPH_NO_VIRTUALIZE(function()
	if not (cfg.InfAmmo or cfg.NoReload) then
		return
	end
	local character = getCharacter(LocalPlayer)
	if character ~= st.ammoChar then
		if st.ammoAddedConn then
			pcall(function()
				st.ammoAddedConn:Disconnect()
			end)
			st.ammoAddedConn = nil
		end
		st.ammoChar = character
		if character then
			st.ammoAddedConn = character.DescendantAdded:Connect(function(inst)
				if not (cfg.InfAmmo or cfg.NoReload) then
					return
				end
				if inst.Name == "Config" then
					watchAmmoValue(inst:FindFirstChild("TotalAmmo"))
					watchAmmoValue(inst:FindFirstChild("Ammo"))
				else
					watchAmmoValue(inst)
				end
			end)
			scanAmmo(character)
		end
		return
	end
	if os.clock() - st.ammoScanAt < 0.4 then
		return
	end
	st.ammoScanAt = os.clock()
	scanAmmo(character)
end)

setAutoHack = function(on)
	cfg.AutoHack = on and true or false
	pcall(function()
		callAtIdentity(function()
			local modules = ReplicatedStorage:FindFirstChild("Modules")
			local rules = modules and modules:FindFirstChild("GameRules")
			if rules then
				local loaded = require(rules)
				if type(loaded) == "table" then
					st.hackRules = loaded
					loaded.disableHacking = cfg.AutoHack
					loaded.disableMinigames = cfg.AutoHack
				end
			end
			local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
			local framework = scripts and scripts:FindFirstChild("Framework")
			local characterMod = framework and framework:FindFirstChild("Character")
			if not characterMod then
				return
			end
			local loaded = require(characterMod)
			if type(loaded) ~= "table" then
				return
			end
			st.hackCharMod = loaded
			if cfg.AutoHack then
				if not st.hackHacking then
					st.hackHacking = loaded.hackingMinigame
				end
				if not st.hackStart then
					st.hackStart = loaded.startMinigame
				end
				loaded.hackingMinigame = function()
					return true
				end
				loaded.startMinigame = function()
					return true
				end
			else
				if st.hackHacking then
					loaded.hackingMinigame = st.hackHacking
				end
				if st.hackStart then
					loaded.startMinigame = st.hackStart
				end
			end
		end)
	end)
end

startMoneyLoops = function()
	if st.moneyStarted then
		return
	end
	st.moneyStarted = true

	local ATM_USED = Color3.fromRGB(74, 75, 93)

	local function promptPos(prompt)
		local parent = prompt and prompt.Parent
		if not parent then
			return nil
		end
		if parent:IsA("BasePart") then
			return parent.Position
		end
		if parent:IsA("Attachment") then
			return parent.WorldPosition
		end
		if parent:IsA("Model") then
			local part = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
			return part and part.Position
		end
		local ok, pivot = pcall(function()
			return parent:GetPivot()
		end)
		return ok and pivot and pivot.Position or nil
	end

	local function firePrompt(prompt)
		if not prompt then
			return
		end
		pcall(function()
			if fireproximityprompt then
				fireproximityprompt(prompt)
			else
				prompt.HoldDuration = 0
				prompt:InputHoldBegin()
				task.wait(0.08)
				prompt:InputHoldEnd()
			end
		end)
	end

	local function farmPivot(pos)
		local character, _, root = getLocalParts()
		if not (character and root and pos) then
			return
		end
		local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
		pcall(function()
			if character.PivotTo then
				character:PivotTo(cf)
			else
				root.CFrame = cf
			end
			root.AssemblyLinearVelocity = Vector3.zero
		end)
		pcall(function()
			local event = st.playerEvent
			if not (event and event.Parent) then
				local remote = getRemoteFolder()
				event = remote and remote:FindFirstChild("PlayerEvent")
				if event then
					st.playerEvent = event
				end
			end
			if event then
				local id = ((character:GetAttribute("CharPivotToId") or 0) + 1) % 100
				character:SetAttribute("CharPivotToId", id)
				event:FireServer("charPivotTo", cf, character, id)
			end
		end)
		if ghost and ghost.on then
			ghost.realCF = cf
			st.ghostDesyncPos = cf.Position
			ghost.hideCF = ghostComputeHideCF(cf)
		end
		if cfg.Stealth then
			st.stealthRealCF = cf
		end
	end

	local function classifyPrompt(prompt)
		if not (prompt and prompt:IsA("ProximityPrompt")) then
			return
		end
		local name = prompt.Name
		local action = string.lower(tostring(prompt.ActionText or ""))
		local object = string.lower(tostring(prompt.ObjectText or ""))
		if name == "CashDrop" then
			st.farmPrompts[prompt] = "cashdrop"
			return
		end
		if name == "Mission" then
			st.farmPrompts[prompt] = "mission"
			return
		end
		if action == "pick up" then
			st.farmPrompts[prompt] = "farmer"
			return
		end
		if action:find("cook", 1, true) or action:find("serve", 1, true) or action:find("order", 1, true) or action:find("plate", 1, true) then
			st.farmPrompts[prompt] = "chef"
			return
		end
		if name == "GetItem" or name == "Money" or action:find("pick", 1, true) or action:find("cash", 1, true) or action:find("collect", 1, true) or action:find("grab", 1, true) or object:find("cash", 1, true) or object:find("money", 1, true) then
			st.farmPrompts[prompt] = "cash"
		end
	end

	local function hookPrompts()
		if st.farmPromptHooked then
			return
		end
		st.farmPromptHooked = true
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			classifyPrompt(descendant)
		end
		track(Workspace.DescendantAdded:Connect(classifyPrompt))
		track(Workspace.DescendantRemoving:Connect(function(inst)
			st.farmPrompts[inst] = nil
		end))
	end

	local function promptReady(prompt)
		if not (prompt and prompt.Parent and prompt.Enabled) then
			return false
		end
		local now = os.clock()
		if now - (st.farmPromptCd[prompt] or 0) < 1 then
			return false
		end
		st.farmPromptCd[prompt] = now
		return true
	end

	local jobsCache, jobsAt = nil, 0
	local function getTeamJobs()
		if jobsCache ~= nil and os.clock() - jobsAt < 2 then
			return jobsCache
		end
		if not getgc then
			return nil
		end
		local found
		pcall(function()
			callAtIdentity(LPH_NO_VIRTUALIZE(function()
				for _, value in pairs(getgc(true)) do
					if type(value) == "table" and rawget(value, "teamJobs") then
						found = value.teamJobs
						break
					end
				end
			end))
		end)
		jobsCache = found
		jobsAt = os.clock()
		return found
	end

	local function hasMission()
		if LocalPlayer:GetAttribute("Mission") then
			return true
		end
		local jobs = getTeamJobs()
		if jobs then
			for _, job in pairs(jobs) do
				if type(job) == "table" and job.joined then
					return true
				end
			end
		end
		return false
	end

	local function pickMissionId(kind)
		local jobs = getTeamJobs()
		if not jobs then
			return nil
		end
		local best, bestScore
		for id, job in pairs(jobs) do
			if type(job) == "table" and not job.joined then
				local info = string.lower(tostring(job.infoDescription or job.name or id))
				if kind == "chef" and not (info:find("chef", 1, true) or info:find("restaurant", 1, true) or info:find("cook", 1, true)) then
					continue
				end
				if kind == "taxi" and not (info:find("taxi", 1, true)) then
					continue
				end
				if not cfg.MissionHighPay then
					return id
				end
				local score = (job.profitability or 1) * 1000000 + (job.reward or 0)
				if not bestScore or score > bestScore then
					best = id
					bestScore = score
				end
			end
		end
		return best
	end

	local function joinMission(id)
		local func = resolvePlayerFunc()
		if not (func and id) then
			return
		end
		pcall(function()
			func:InvokeServer("talkToMission", tostring(id) .. "join")
		end)
	end

	local function farmerDrop()
		local gameplay = ReplicatedStorage:FindFirstChild("Gameplay")
		gameplay = gameplay and gameplay:FindFirstChild("Missions")
		gameplay = gameplay and gameplay:FindFirstChild("Active")
		if not gameplay then
			return nil
		end
		for _, child in ipairs(gameplay:GetChildren()) do
			if child.Name:find("^Farmer") then
				for _, name in ipairs({ "DropOff", "Target", "Goal" }) do
					local node = child:FindFirstChild(name)
					if node and node:IsA("BasePart") then
						return node.Position
					end
					if node and node:IsA("ObjectValue") and node.Value and node.Value:IsA("BasePart") then
						return node.Value.Position
					end
				end
			end
		end
		return nil
	end

	local function clientContent()
		local gameplay = Workspace:FindFirstChild("Gameplay")
		gameplay = gameplay and gameplay:FindFirstChild("Entities")
		return gameplay and gameplay:FindFirstChild("ClientContent")
	end

	local function clickGui(button)
		local pos = button.AbsolutePosition
		local size = button.AbsoluteSize
		local x = pos.X + size.X / 2
		local y = pos.Y + size.Y / 2
		if IS_MOBILE then
			pcall(function()
				VirtualInputManager:SendTouchEvent(1, 0, x, y)
				VirtualInputManager:SendTouchEvent(1, 2, x, y)
			end)
			return
		end
		pcall(function()
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end)
	end

	local function findAtm()
		local gui = LocalPlayer:FindFirstChild("PlayerGui")
		if not gui then
			return nil
		end
		local fallback
		for _, child in ipairs(gui:GetChildren()) do
			local ok, result = pcall(function()
				return child.Center.Middle.HackingMinigames["ATM Hack"]
			end)
			if ok and result then
				local visible = true
				local node = result
				while node do
					if node:IsA("LayerCollector") then
						visible = node.Enabled
						break
					end
					if node:IsA("GuiObject") and not node.Visible then
						visible = false
						break
					end
					node = node.Parent
				end
				if visible then
					return result
				end
				fallback = fallback or result
			end
		end
		return fallback
	end

	local tickAtm = LPH_NO_VIRTUALIZE(function()
		if not cfg.AutoAtm then
			st.atmSeq = nil
			return
		end
		local panel = findAtm()
		if not (panel and panel:FindFirstChild("Sequence1") and panel:FindFirstChild("List")) then
			st.atmSeq = nil
			return
		end
		local text = panel.Sequence1.Text
		if text == "" then
			st.atmSeq = nil
			return
		end
		if text ~= st.atmSeq then
			st.atmSeq = text
			st.atmResetAt = os.clock()
			table.clear(st.atmClicked)
		elseif next(st.atmClicked) and os.clock() - st.atmResetAt > 0.8 then
			table.clear(st.atmClicked)
			st.atmResetAt = os.clock()
		end
		if os.clock() < st.atmClickAt then
			return
		end
		for token in string.gmatch(text, "([^%s]+)") do
			for _, descendant in ipairs(panel.List:GetDescendants()) do
				if descendant:IsA("ImageButton") and not st.atmClicked[descendant] and descendant.ImageColor3 ~= ATM_USED then
					for _, label in ipairs(descendant:GetDescendants()) do
						if label:IsA("TextLabel") and label.Text == token then
							clickGui(descendant)
							st.atmClicked[descendant] = true
							st.atmClickAt = os.clock() + 0.06
							st.atmResetAt = os.clock()
							return
						end
					end
				end
			end
		end
	end)

	hookPrompts()
	track(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(tickAtm)))

	task.spawn(function()
		while st.moneyStarted do
			local didWork = false
			if cfg.PickMoney then
				pcall(function()
					local root = getRootPart(getCharacter(LocalPlayer))
					local origin = root and root.Position
					local func = resolvePlayerFunc()
					local event = st.playerEvent
					for prompt, kind in pairs(st.farmPrompts) do
						if (kind == "cashdrop" or kind == "cash") and promptReady(prompt) then
							local pos = promptPos(prompt)
							if origin and pos and (pos - origin).Magnitude > 220 then
								continue
							end
							didWork = true
							if origin and pos and (pos - origin).Magnitude > 8 then
								farmPivot(pos)
								task.wait(0.15)
							end
							if event then
								pcall(function()
									event:FireServer("interacted")
								end)
							end
							if kind == "cashdrop" and func then
								pcall(function()
									func:InvokeServer("cashDrop", prompt)
								end)
							else
								firePrompt(prompt)
							end
						end
					end
				end)
			end
			task.wait(didWork and 0.3 or 0.5)
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.AutoMission and resolvePlayerFunc() and not hasMission() then
				pcall(function()
					joinMission(pickMissionId())
				end)
				for prompt, kind in pairs(st.farmPrompts) do
					if kind == "mission" and promptReady(prompt) then
						local action = prompt.ActionText
						if action == "Steal" or action == "Take" or action == "Remove" then
							pcall(function()
								resolvePlayerFunc():InvokeServer("talkToMission", prompt.Parent)
							end)
						end
					end
				end
			end
			task.wait(math.max(0.5, tonumber(cfg.MissionInterval) or 2))
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.FarmFarmer then
				pcall(function()
					local character, humanoid, root = getLocalParts()
					if root then
						local tool = character and character:FindFirstChildOfClass("Tool")
						if tool then
							local drop = farmerDrop()
							if drop then
								farmPivot(drop)
							end
						else
							local best, bestDist
							for prompt, kind in pairs(st.farmPrompts) do
								if kind == "farmer" and prompt.Parent and prompt.Enabled then
									local pos = promptPos(prompt)
									local dist = pos and (pos - root.Position).Magnitude
									if dist and (not bestDist or dist < bestDist) then
										best = prompt
										bestDist = dist
									end
								end
							end
							if best and bestDist then
								if bestDist > 8 then
									farmPivot(promptPos(best))
								else
									firePrompt(best)
								end
							end
						end
					end
				end)
			end
			task.wait(cfg.FarmFarmer and 0.3 or 0.5)
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.FarmTaxi then
				pcall(function()
					if cfg.AutoMission and not hasMission() then
						joinMission(pickMissionId("taxi") or pickMissionId())
					end
					local content = clientContent()
					local part = content and (content.PrimaryPart or content:FindFirstChildWhichIsA("BasePart"))
					local root = getRootPart(getCharacter(LocalPlayer))
					if part and root then
						local pos = part.Position
						if st.taxiLastPos == nil or (pos - st.taxiLastPos).Magnitude > 5 then
							if cfg.TaxiSafe then
								if not st.taxiOrigin then
									st.taxiOrigin = root.Position
								end
								root.CFrame = CFrame.new(st.taxiOrigin)
								local dist = (st.taxiOrigin - pos).Magnitude
								task.wait(dist > 2000 and math.random(15, 45) or 8)
							end
							farmPivot(pos)
							st.taxiLastPos = pos
						end
					end
				end)
			end
			task.wait(0.5)
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.FarmBus then
				pcall(function()
					local content = clientContent()
					local first = content and content:GetChildren()[1]
					local area = first and first:FindFirstChild("Area")
					local character, humanoid, root = getLocalParts()
					if area and humanoid and root then
						local dest = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, math.rad(270), 0)
						local seat = humanoid.SeatPart
						if seat then
							seat.CFrame = dest * root.CFrame:ToObjectSpace(seat.CFrame)
							seat.AssemblyLinearVelocity = Vector3.zero
							seat.AssemblyAngularVelocity = Vector3.zero
							task.wait(0.1)
							humanoid.Sit = false
						else
							root.CFrame = dest
						end
						task.wait(5)
					end
				end)
			end
			task.wait(1)
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.FarmChef then
				pcall(function()
					local team = LocalPlayer.Team and string.lower(tostring(LocalPlayer.Team.Name)) or ""
					if team:find("chef", 1, true) or team == "" then
						if not hasMission() then
							joinMission(pickMissionId("chef"))
						end
						local root = getRootPart(getCharacter(LocalPlayer))
						for prompt, kind in pairs(st.farmPrompts) do
							if kind == "chef" and promptReady(prompt) then
								local pos = promptPos(prompt)
								if root and pos and (pos - root.Position).Magnitude > 8 then
									farmPivot(pos)
									task.wait(0.15)
								end
								firePrompt(prompt)
							end
						end
						local cook = clientContent()
						cook = cook and cook:FindFirstChild("CookSpot")
						cook = cook and cook:FindFirstChild("Handle")
						cook = cook and cook:FindFirstChild("Interact")
						if cook and cook:IsA("ProximityPrompt") then
							firePrompt(cook)
						end
					end
				end)
			end
			task.wait(cfg.FarmChef and 0.4 or 0.5)
		end
	end)

	task.spawn(function()
		while st.moneyStarted do
			if cfg.FarmGolf then
				pcall(function()
					local func = resolvePlayerFunc()
					if func then
						if not st.golfReady then
							func:InvokeServer("miniGolf", "createLobby")
							task.wait(0.15)
							pcall(function()
								func:InvokeServer("miniGolf", "setLobbyBid", { bid = 500 })
							end)
							task.wait(0.1)
							func:InvokeServer("miniGolf", "setLobbyReady")
							st.golfReady = true
							task.wait(3)
						end
						func:InvokeServer("miniGolf", "shot")
						task.wait(0.4)
						func:InvokeServer("miniGolf", "shot")
						local entities = Workspace:FindFirstChild("Gameplay")
						entities = entities and entities:FindFirstChild("Entities")
						local ball, flagPart
						if entities then
							for _, child in ipairs(entities:GetChildren()) do
								if child.Name == "Content" then
									ball = child:FindFirstChild(LocalPlayer.Name)
								end
								local flag = child:FindFirstChild("_Flag") or (child.Name == "Content" and child:FindFirstChild("_Flag"))
								if not flag and child.Name == "Content" then
									flag = child:FindFirstChild("_Flag")
								end
							end
							local content = entities:FindFirstChild("Content")
							ball = ball or (content and content:FindFirstChild(LocalPlayer.Name))
							local flag = content and content:FindFirstChild("_Flag")
							flag = flag and flag:FindFirstChild("FlagPole")
							flagPart = flag and flag:FindFirstChild("Part")
						end
						if ball and flagPart then
							if ball:IsA("BasePart") then
								ball.CFrame = flagPart.CFrame
							elseif ball.PivotTo then
								ball:PivotTo(flagPart.CFrame)
							end
						end
					end
				end)
			else
				st.golfReady = false
			end
			task.wait(cfg.FarmGolf and 5 or 1)
		end
	end)
end

local function initVehicle()
	if veh.ready then
		return
	end
	veh.ready = true
	veh.ramLast = {}
	veh.collisions = {}
	veh.cruiseSpeed = 0
	veh.fuelMax = 15
	veh.floatHeight = cfg.FloatHeight or 8
	veh.rideHeight = cfg.RideHeight or 0

	local function playerCF()
		if ghost.on and ghost.realCF then
			return ghost.realCF
		end
		if cfg.Stealth and st.stealthRealCF then
			return st.stealthRealCF
		end
		local _, _, root = getLocalParts()
		return root and root.CFrame
	end

	local function loadVehicleMod()
		if veh.modTried then
			return veh.mod
		end
		veh.modTried = true
		pcall(function()
			callAtIdentity(function()
				local modules = ReplicatedStorage:FindFirstChild("Modules")
				local loader = modules and modules:FindFirstChild("ModuleLoader")
				local alg = modules and modules:FindFirstChild("Algorithms")
				if loader and alg then
					local loaded = require(loader)
					if type(loaded) == "table" and type(loaded.assign) == "function" then
						veh.alg = loaded.assign(alg)
					end
				end
				local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
				local framework = scripts and scripts:FindFirstChild("Framework")
				local vehicleMod = framework and framework:FindFirstChild("Vehicle")
				if vehicleMod then
					veh.mod = require(vehicleMod)
				end
			end)
		end)
		return veh.mod
	end

	local function belongingVehicle()
		loadVehicleMod()
		local found
		pcall(function()
			local info = veh.alg and veh.alg.getVehicleInfo
			found = info and info.getBelongingVehicle and info.getBelongingVehicle(LocalPlayer)
		end)
		if found and found.Parent and found:FindFirstChild("_Chassis") then
			return found
		end
		local gameplay = Workspace:FindFirstChild("Gameplay")
		local folder = gameplay and gameplay:FindFirstChild("Vehicles")
		if not folder then
			return nil
		end
		local _, hum = getLocalParts()
		for _, model in ipairs(folder:GetChildren()) do
			if model:IsA("Model") and model:FindFirstChild("_Chassis") then
				for _, desc in ipairs(model:GetDescendants()) do
					if desc:IsA("VehicleSeat") or desc:IsA("Seat") then
						if hum and desc.Occupant == hum then
							return model
						end
					end
				end
			end
		end
		return nil
	end

	local function modelFromSeat(seat)
		local current = seat
		while current and current ~= Workspace do
			if current:IsA("Model") and current:FindFirstChild("_Chassis") then
				return current
			end
			current = current.Parent
		end
		return nil
	end

	local function currentVehicle()
		local _, hum = getLocalParts()
		local seat = hum and hum.SeatPart
		local seated = seat and modelFromSeat(seat)
		if seated then
			veh.cached = seated
			veh.cachedAt = os.clock()
			return seated
		end
		if veh.cached and veh.cached.Parent and os.clock() - (veh.cachedAt or 0) < 4 then
			return veh.cached
		end
		return belongingVehicle()
	end

	local function chassisOf(model)
		local chassis = model and model:FindFirstChild("_Chassis")
		if chassis and chassis:IsA("BasePart") then
			return chassis
		end
		return nil
	end

	local function sittingIn(model)
		local _, hum = getLocalParts()
		local seat = hum and hum.SeatPart
		return seat and modelFromSeat(seat) == model
	end

	local function driverSeatOf(model)
		if not model then
			return nil, nil
		end
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Name == "EnterDriver" then
				local parent = desc.Parent
				if parent and parent:IsA("Attachment") then
					parent = parent.Parent
				end
				if parent and parent:IsA("BasePart") then
					return parent, desc
				end
			end
		end
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("VehicleSeat") then
				return desc, nil
			end
		end
		return nil, nil
	end

	local function streamAround(pos)
		if typeof(pos) ~= "Vector3" then
			return
		end
		if os.clock() - (veh.streamAt or 0) < 1 then
			return
		end
		veh.streamAt = os.clock()
		task.spawn(function()
			pcall(function()
				LocalPlayer:RequestStreamAroundAsync(pos)
			end)
		end)
	end

	local function groundPoint(pos, ignore)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local filter = { getCharacter(LocalPlayer) }
		if ignore then
			filter[#filter + 1] = ignore
		end
		local chars = Workspace:FindFirstChild(CHARS_FOLDER)
		if chars then
			filter[#filter + 1] = chars
		end
		local gameplay = Workspace:FindFirstChild("Gameplay")
		local vehicles = gameplay and gameplay:FindFirstChild("Vehicles")
		if vehicles then
			filter[#filter + 1] = vehicles
		end
		params.FilterDescendantsInstances = filter
		local hit = Workspace:Raycast(pos + Vector3.new(0, 80, 0), Vector3.new(0, -300, 0), params)
		return hit
	end

	local function pivotCar(model, lookAt, gap)
		local chassis = chassisOf(model)
		if not chassis then
			return false
		end
		local target = typeof(lookAt) == "Vector3" and lookAt or lookAt.Position
		local flat = Vector3.new(target.X - chassis.Position.X, 0, target.Z - chassis.Position.Z)
		local unit = flat.Magnitude > 1 and flat.Unit or Vector3.new(chassis.CFrame.LookVector.X, 0, chassis.CFrame.LookVector.Z)
		if unit.Magnitude < 0.1 then
			unit = Vector3.new(0, 0, -1)
		else
			unit = unit.Unit
		end
		gap = gap or 12
		local landing = target - unit * gap
		if not cfg.Offroad then
			local hit = groundPoint(landing, model)
			if hit then
				landing = hit.Position
			end
		end
		local cf = CFrame.lookAt(landing + Vector3.new(0, 4, 0), Vector3.new(target.X, landing.Y + 4, target.Z))
		return (pcall(function()
			chassis.AssemblyLinearVelocity = Vector3.zero
			chassis.AssemblyAngularVelocity = Vector3.zero
			model:PivotTo(cf)
		end))
	end

	local function playHorn(model, on)
		pcall(function()
			local horn
			local chassis = model:FindFirstChild("_Chassis")
			horn = chassis and chassis:FindFirstChild("Horn")
			if not (horn and horn:IsA("Sound")) then
				for _, desc in ipairs(model:GetDescendants()) do
					if desc:IsA("Sound") and desc.Name == "Horn" then
						horn = desc
						break
					end
				end
			end
			if not horn then
				return
			end
			if on then
				horn:Play()
			elseif horn.IsPlaying then
				horn:Stop()
			end
		end)
	end

	local function restoreCollisions()
		for part, info in pairs(veh.collisions) do
			pcall(function()
				if info.parent and info.parent.Parent then
					part.Parent = info.parent
				end
			end)
		end
		veh.collisions = {}
	end

	local function stripCollisions(model)
		if not model then
			return
		end
		local folder = model:FindFirstChild("Collisions") or model:FindFirstChild("Collisions", true)
		if not folder then
			return
		end
		for _, desc in ipairs(folder:GetDescendants()) do
			if desc:IsA("BasePart") and desc.Parent then
				if not veh.collisions[desc] then
					veh.collisions[desc] = { parent = desc.Parent }
				end
				pcall(function()
					desc.Parent = nil
				end)
			end
		end
	end

	local function refreshFuel(model)
		if veh.fuelCfg and veh.fuelCfg.Parent and veh.fuelModel == model then
			return
		end
		veh.fuelCfg = nil
		veh.fuelMax = 15
		veh.fuelModel = model
		if not model then
			return
		end
		for _, desc in ipairs(model:GetDescendants()) do
			if desc.Name == "Config" and desc:FindFirstChild("Fuel") then
				veh.fuelCfg = desc
				pcall(function()
					local data = require(desc)
					if type(data) == "table" and type(data.MAX_FUEL) == "number" then
						veh.fuelMax = data.MAX_FUEL
					end
				end)
				return
			end
		end
	end

	local function fillFuel()
		local cfgInst = veh.fuelCfg
		local fuel = cfgInst and cfgInst:FindFirstChild("Fuel")
		if fuel and (fuel:IsA("NumberValue") or fuel:IsA("IntValue")) and fuel.Value < veh.fuelMax then
			fuel.Value = veh.fuelMax
		end
	end

	local function destroyHud()
		if veh.hudGui then
			pcall(function()
				veh.hudGui:Destroy()
			end)
		end
		veh.hudGui = nil
		veh.speedLabel = nil
		veh.unitBtn = nil
		veh.statusLabel = nil
		veh.barFill = nil
	end

	local function ensureHud()
		if veh.hudGui and veh.hudGui.Parent then
			veh.hudGui.Enabled = cfg.SpeedHud and true or false
			return
		end
		if not cfg.SpeedHud then
			return
		end
		local white = Color3.fromRGB(255, 255, 255)
		local black = Color3.fromRGB(0, 0, 0)
		local gui = Instance.new("ScreenGui")
		gui.Name = "XiProSpeedHud"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 80
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = getUiHost()
		local shadow = Instance.new("Frame")
		shadow.Name = "Shadow"
		shadow.AnchorPoint = Vector2.new(0, 0.5)
		shadow.Position = UDim2.new(0, 18, 0.42, 6)
		shadow.Size = UDim2.fromOffset(148, 168)
		shadow.BackgroundColor3 = black
		shadow.BackgroundTransparency = 0.72
		shadow.BorderSizePixel = 0
		shadow.Parent = gui
		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = UDim.new(0, 26)
		shadowCorner.Parent = shadow
		local frame = Instance.new("Frame")
		frame.Name = "Hud"
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 16, 0.42, 0)
		frame.Size = UDim2.fromOffset(148, 168)
		frame.BackgroundColor3 = black
		frame.BackgroundTransparency = 0.22
		frame.BorderSizePixel = 0
		frame.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 24)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Color = white
		stroke.Thickness = 1
		stroke.Transparency = 0.82
		stroke.Parent = frame
		local gloss = Instance.new("Frame")
		gloss.BackgroundColor3 = white
		gloss.BackgroundTransparency = 0.94
		gloss.BorderSizePixel = 0
		gloss.Size = UDim2.new(1, 0, 0, 54)
		gloss.Parent = frame
		local glossCorner = Instance.new("UICorner")
		glossCorner.CornerRadius = UDim.new(0, 24)
		glossCorner.Parent = gloss
		local caption = Instance.new("TextLabel")
		caption.BackgroundTransparency = 1
		caption.Position = UDim2.fromOffset(16, 14)
		caption.Size = UDim2.new(1, -32, 0, 14)
		caption.Font = Enum.Font.GothamMedium
		caption.TextSize = 11
		caption.TextColor3 = white
		caption.TextTransparency = 0.42
		caption.TextXAlignment = Enum.TextXAlignment.Left
		caption.Text = "SPEED"
		caption.Parent = frame
		local speed = Instance.new("TextLabel")
		speed.BackgroundTransparency = 1
		speed.Position = UDim2.fromOffset(14, 28)
		speed.Size = UDim2.new(1, -28, 0, 58)
		speed.Font = Enum.Font.GothamBold
		speed.TextSize = 48
		speed.TextColor3 = white
		speed.TextXAlignment = Enum.TextXAlignment.Left
		speed.TextYAlignment = Enum.TextYAlignment.Center
		speed.Text = "0"
		speed.Parent = frame
		local unit = Instance.new("TextButton")
		unit.BackgroundColor3 = white
		unit.BackgroundTransparency = 0.88
		unit.BorderSizePixel = 0
		unit.Position = UDim2.fromOffset(16, 88)
		unit.Size = UDim2.fromOffset(78, 22)
		unit.Font = Enum.Font.GothamMedium
		unit.TextSize = 11
		unit.TextColor3 = white
		unit.AutoButtonColor = false
		unit.Text = cfg.SpeedMph and "MPH" or "STUDS"
		unit.Parent = frame
		local unitCorner = Instance.new("UICorner")
		unitCorner.CornerRadius = UDim.new(1, 0)
		unitCorner.Parent = unit
		unit.MouseButton1Click:Connect(function()
			cfg.SpeedMph = not cfg.SpeedMph
			unit.Text = cfg.SpeedMph and "MPH" or "STUDS"
		end)
		local barBg = Instance.new("Frame")
		barBg.BackgroundColor3 = white
		barBg.BackgroundTransparency = 0.86
		barBg.BorderSizePixel = 0
		barBg.Position = UDim2.new(0, 16, 1, -46)
		barBg.Size = UDim2.new(1, -32, 0, 5)
		barBg.Parent = frame
		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = barBg
		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = white
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.Parent = barBg
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill
		local status = Instance.new("TextLabel")
		status.BackgroundTransparency = 1
		status.Position = UDim2.fromOffset(16, 132)
		status.Size = UDim2.new(1, -32, 0, 18)
		status.Font = Enum.Font.GothamMedium
		status.TextSize = 12
		status.TextColor3 = white
		status.TextTransparency = 0.28
		status.TextXAlignment = Enum.TextXAlignment.Left
		status.Text = T("hudNoVehicle")
		status.Parent = frame
		veh.hudGui = gui
		veh.speedLabel = speed
		veh.unitBtn = unit
		veh.statusLabel = status
		veh.barFill = fill
	end

	local function updateHud(model, chassis)
		if not cfg.SpeedHud then
			if veh.hudGui then
				veh.hudGui.Enabled = false
			end
			return
		end
		ensureHud()
		if not (veh.speedLabel and veh.statusLabel and veh.barFill) then
			return
		end
		local mag = 0
		if chassis then
			local vel = chassis.AssemblyLinearVelocity
			mag = Vector3.new(vel.X, 0, vel.Z).Magnitude
		end
		local shown = cfg.SpeedMph and mag * 0.6818 or mag
		veh.speedLabel.Text = tostring(math.floor(shown + 0.5))
		veh.barFill.Size = UDim2.new(math.clamp(mag / 120, 0, 1), 0, 1, 0)
		if veh.unitBtn then
			veh.unitBtn.Text = cfg.SpeedMph and "MPH" or "STUDS"
		end
		local text, fade = T("hudNoVehicle"), 0.42
		if not model then
			text, fade = T("hudNoVehicle"), 0.42
		elseif cfg.Cruise then
			text = ("%s %d"):format(T("hudCruise"), math.floor((cfg.SpeedMph and veh.cruiseSpeed * 0.6818 or veh.cruiseSpeed) + 0.5))
			fade = 0.04
		elseif mag < -0.5 then
			text, fade = T("hudReverse"), 0.18
		elseif mag > 0.5 then
			text, fade = T("hudDrive"), 0.04
		else
			text, fade = T("hudIdle"), 0.32
		end
		veh.statusLabel.Text = text
		veh.statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		veh.statusLabel.TextTransparency = fade
	end

	local function targetPlayer()
		local name = veh.targetName
		if type(name) ~= "string" or name == "" or name == "-" then
			return nil
		end
		return Players:FindFirstChild(name)
	end

	local function playerPos(player)
		if not player then
			return nil
		end
		local character = getCharacter(player)
		local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
		if root then
			return root.Position, root, character
		end
		return nil
	end

	local function ramSuccess(player, humanoid, health0)
		if not cfg.KillCheck then
			return true
		end
		if not humanoid or not humanoid.Parent then
			return true
		end
		if humanoid.Health <= 0 or humanoid.Health <= (health0 or 0) - 2 then
			return true
		end
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Physics
			or state == Enum.HumanoidStateType.FallingDown
			or state == Enum.HumanoidStateType.Ragdoll
			or state == Enum.HumanoidStateType.PlatformStanding
			or humanoid.PlatformStand
		then
			return true
		end
		local character = getCharacter(player)
		if character and character:GetAttribute("IsDead") == true then
			return true
		end
		return false
	end

	local function ramPlayer(player, silent)
		if not player or player == LocalPlayer or veh.ramBusy then
			return false
		end
		local model = currentVehicle()
		local chassis = chassisOf(model)
		if not (model and chassis) then
			if not silent then
				notify("Xi Pro", T("vehNoCar"))
			end
			return false
		end
		if not sittingIn(model) then
			if not silent then
				notify("Xi Pro", T("vehNeedSit"))
			end
			return false
		end
		local pos, root, character = playerPos(player)
		if not (pos and character) then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not (humanoid and humanoid.Health > 0) then
			return false
		end
		veh.ramBusy = true
		local origin = model:GetPivot()
		local health0 = humanoid.Health
		streamAround(pos)
		local waitUntil = os.clock() + 4
		while os.clock() < waitUntil do
			pos, root, character = playerPos(player)
			if root then
				break
			end
			task.wait(0.15)
		end
		if not pos then
			veh.ramBusy = false
			return false
		end
		local hit = false
		pcall(function()
			local look = pos
			if cfg.RamInstant or cfg.Offroad then
				pivotCar(model, look, 10)
			elseif (chassis.Position - look).Magnitude > 45 then
				pivotCar(model, look, 28)
			end
			local dir = Vector3.new(look.X - chassis.Position.X, 0, look.Z - chassis.Position.Z)
			if dir.Magnitude < 0.1 then
				dir = Vector3.new(chassis.CFrame.LookVector.X, 0, chassis.CFrame.LookVector.Z)
			end
			dir = dir.Unit
			local speed = 100
			chassis.AssemblyLinearVelocity = Vector3.new(dir.X * speed, 8, dir.Z * speed)
			local untilAt = os.clock() + 1.1
			while os.clock() < untilAt do
				if cfg.KillCheck and ramSuccess(player, humanoid, health0) then
					hit = true
					break
				end
				local nowPos = playerPos(player)
				if nowPos then
					dir = Vector3.new(nowPos.X - chassis.Position.X, 0, nowPos.Z - chassis.Position.Z)
					if dir.Magnitude > 1 then
						dir = dir.Unit
						chassis.AssemblyLinearVelocity = Vector3.new(dir.X * speed, chassis.AssemblyLinearVelocity.Y, dir.Z * speed)
					end
				end
				task.wait(0.05)
			end
			if not cfg.KillCheck then
				hit = true
			end
			if cfg.RamInstant then
				chassis.AssemblyLinearVelocity = Vector3.zero
				chassis.AssemblyAngularVelocity = Vector3.zero
				model:PivotTo(origin)
			end
		end)
		veh.ramLast[player.Name] = os.clock()
		veh.ramBusy = false
		if not silent then
			notify("Xi Pro", hit and T("vehRamOk") or T("vehRamFail"))
		end
		return hit
	end

	local function bringCar()
		task.spawn(function()
			loadVehicleMod()
			local cf = playerCF()
			local model = belongingVehicle() or currentVehicle()
			if model and cf then
				local ok = pcall(function()
					local chassis = chassisOf(model)
					if chassis then
						chassis.AssemblyLinearVelocity = Vector3.zero
						chassis.AssemblyAngularVelocity = Vector3.zero
					end
					model:PivotTo(cf * CFrame.new(0, 3, -8))
				end)
				notify("Xi Pro", ok and T("vehBrought") or T("vehBringFail"))
				return
			end
			if veh.mod and type(veh.mod.spawnVehicle) == "function" then
				pcall(function()
					veh.mod.spawnVehicle()
				end)
				task.wait(0.6)
				model = belongingVehicle()
				if model and cf then
					pcall(function()
						model:PivotTo(cf * CFrame.new(0, 3, -8))
					end)
					notify("Xi Pro", T("vehBrought"))
					return
				end
			end
			notify("Xi Pro", T("vehNoCar"))
		end)
	end

	local function enterCar()
		task.spawn(function()
			loadVehicleMod()
			local _, _, root = getLocalParts()
			if not root then
				notify("Xi Pro", T("vehEnterFail"))
				return
			end
			local model = belongingVehicle() or currentVehicle()
			local seat, prompt = driverSeatOf(model)
			if not seat then
				notify("Xi Pro", model and T("vehEnterFail") or T("vehNoCar"))
				return
			end
			pcall(function()
				root.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
			end)
			task.wait(0.15)
			local ok = pcall(function()
				if veh.mod and type(veh.mod.enterVehicle) == "function" then
					callAtIdentity(function()
						veh.mod.enterVehicle(seat)
					end)
				elseif prompt and fireproximityprompt then
					pcall(function()
						prompt.HoldDuration = 0
					end)
					fireproximityprompt(prompt)
				else
					error("no enter")
				end
			end)
			notify("Xi Pro", ok and T("vehEnter") or T("vehEnterFail"))
		end)
	end

	local function sendCar()
		if veh.sendBusy then
			notify("Xi Pro", T("vehSendBusy"))
			return
		end
		local player = targetPlayer()
		if not player then
			notify("Xi Pro", T("vehNoTarget"))
			return
		end
		local model = currentVehicle() or belongingVehicle()
		if not chassisOf(model) then
			notify("Xi Pro", T("vehNoCar"))
			return
		end
		local pos = playerPos(player)
		if not pos then
			notify("Xi Pro", T("vehNoTarget"))
			return
		end
		veh.sendBusy = true
		task.spawn(function()
			local origin = model:GetPivot()
			streamAround(pos)
			pivotCar(model, playerPos(player) or pos, 9)
			playHorn(model, true)
			notify("Xi Pro", T("vehSent"))
			local rider
			local started = os.clock()
			local hornAt = os.clock()
			while os.clock() - started < 90 do
				for _, child in ipairs(model:GetChildren()) do
					if child:IsA("Seat") and child.Occupant then
						local other = Players:GetPlayerFromCharacter(child.Occupant.Parent)
						if other and other ~= LocalPlayer then
							rider = other
							break
						end
					end
				end
				if rider then
					break
				end
				if os.clock() - hornAt > 5 then
					hornAt = os.clock()
					playHorn(model, true)
				end
				task.wait(0.25)
			end
			playHorn(model, false)
			pcall(function()
				local chassis = chassisOf(model)
				if chassis then
					chassis.AssemblyLinearVelocity = Vector3.zero
					chassis.AssemblyAngularVelocity = Vector3.zero
				end
				model:PivotTo(origin)
			end)
			notify("Xi Pro", T("vehSendBack"))
			veh.sendBusy = false
		end)
	end

	local function followTick(model, chassis)
		local player = targetPlayer()
		if not player then
			return
		end
		local pos, root = playerPos(player)
		if not (pos and root) then
			return
		end
		local gap = tonumber(cfg.FollowGap) or 30
		local behind = root.CFrame * CFrame.new(0, 0, gap)
		if model and chassis and sittingIn(model) then
			local delta = Vector3.new(behind.Position.X - chassis.Position.X, 0, behind.Position.Z - chassis.Position.Z)
			local dist = delta.Magnitude
			if dist > gap * 2.2 or cfg.Offroad then
				pivotCar(model, pos, gap)
			elseif dist > 6 then
				local unit = delta.Unit
				local speed = math.clamp(dist * 1.6, 28, 90)
				chassis.AssemblyLinearVelocity = Vector3.new(unit.X * speed, chassis.AssemblyLinearVelocity.Y, unit.Z * speed)
				pcall(function()
					model:PivotTo(CFrame.lookAt(chassis.Position, Vector3.new(pos.X, chassis.Position.Y, pos.Z)))
				end)
			end
			return
		end
		local _, _, myRoot = getLocalParts()
		if myRoot and (myRoot.Position - behind.Position).Magnitude > 8 then
			if ghost.on and ghost.realCF then
				ghost.realCF = behind
			elseif cfg.Stealth and st.stealthRealCF then
				st.stealthRealCF = behind
			else
				pcall(function()
					local character = getCharacter(LocalPlayer)
					if character then
						character:PivotTo(behind)
					end
				end)
			end
		end
	end

	local function autoRamTick()
		if veh.ramBusy then
			return
		end
		local model = currentVehicle()
		if not (model and sittingIn(model)) then
			return
		end
		local myRoot = chassisOf(model)
		if not myRoot then
			return
		end
		local best, bestDist
		local range = cfg.RamInstant and math.huge or (tonumber(cfg.RamRange) or 2000)
		local delay = tonumber(cfg.RamDelay) or 6
		local now = os.clock()
		if veh.huntName then
			local hunted = Players:FindFirstChild(veh.huntName)
			if hunted and hunted ~= LocalPlayer then
				local last = veh.ramLast[hunted.Name]
				if not (last and now - last < delay) then
					local pos = playerPos(hunted)
					if pos and (pos - myRoot.Position).Magnitude <= range then
						best = hunted
					end
				end
			end
		end
		if not best then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and not shouldSkipPlayer(player) then
					local last = veh.ramLast[player.Name]
					if not (last and now - last < delay) then
						local pos = playerPos(player)
						if pos then
							local dist = (pos - myRoot.Position).Magnitude
							if dist <= range and (not bestDist or dist < bestDist) then
								best = player
								bestDist = dist
							end
						end
					end
				end
			end
		end
		if best then
			task.spawn(function()
				ramPlayer(best, true)
			end)
		end
	end

	local function applyDrive(model, chassis)
		if not (model and chassis) then
			return
		end
		if cfg.CollisionStop then
			local look = Vector3.new(chassis.CFrame.LookVector.X, 0, chassis.CFrame.LookVector.Z)
			if look.Magnitude > 0.1 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {
					getCharacter(LocalPlayer),
					model,
					Workspace:FindFirstChild(CHARS_FOLDER),
				}
				local hit = Workspace:Raycast(chassis.Position + Vector3.new(0, 2, 0), look.Unit * 18, params)
				if hit then
					chassis.AssemblyLinearVelocity = Vector3.zero
					chassis.AssemblyAngularVelocity = Vector3.zero
					veh.cruiseSpeed = 0
					return
				end
			end
		end
		if cfg.Cruise then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				veh.cruiseSpeed = math.min((veh.cruiseSpeed or 0) + 1.8, 160)
			elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
				veh.cruiseSpeed = math.max((veh.cruiseSpeed or 0) - 2.4, 0)
			end
			local look = Vector3.new(chassis.CFrame.LookVector.X, 0, chassis.CFrame.LookVector.Z)
			if look.Magnitude > 0.1 and (veh.cruiseSpeed or 0) > 0.5 then
				look = look.Unit
				local y = chassis.AssemblyLinearVelocity.Y
				chassis.AssemblyLinearVelocity = Vector3.new(look.X * veh.cruiseSpeed, y, look.Z * veh.cruiseSpeed)
			elseif (veh.cruiseSpeed or 0) <= 0.5 then
				chassis.AssemblyLinearVelocity = Vector3.new(0, chassis.AssemblyLinearVelocity.Y, 0)
			end
		end
		if cfg.GroundLock or cfg.Float then
			local height = cfg.Float and (tonumber(cfg.FloatHeight) or 8) or ((tonumber(cfg.RideHeight) or 0) + 2)
			local hit = groundPoint(chassis.Position, model)
			if hit then
				local y = hit.Position.Y + height
				local pos = chassis.Position
				pcall(function()
					model:PivotTo(CFrame.new(pos.X, y, pos.Z) * (chassis.CFrame - chassis.CFrame.Position))
				end)
			end
		end
	end

	local function wanted()
		return cfg.SpeedHud
			or cfg.Cruise
			or cfg.CollisionStop
			or cfg.GroundLock
			or cfg.Float
			or cfg.NoCrashes
			or cfg.FullFuel
			or cfg.AutoRam
			or cfg.FollowPlayer
	end

	local loopTick = LPH_NO_VIRTUALIZE(function()
		if not wanted() then
			if veh.hbConn then
				pcall(function()
					veh.hbConn:Disconnect()
				end)
				veh.hbConn = nil
			end
			veh.started = false
			destroyHud()
			restoreCollisions()
			return
		end
		local model = currentVehicle()
		local chassis = chassisOf(model)
		if cfg.SpeedHud then
			updateHud(model, chassis)
		end
		if model ~= veh.loopModel then
			restoreCollisions()
			veh.loopModel = model
		end
		if cfg.FullFuel then
			refreshFuel(model)
			fillFuel()
		end
		if cfg.NoCrashes then
			stripCollisions(model)
		else
			restoreCollisions()
		end
		if chassis then
			applyDrive(model, chassis)
		end
		if cfg.FollowPlayer and not cfg.AutoRam then
			followTick(model, chassis)
		end
		if cfg.AutoRam and os.clock() - (veh.ramScanAt or 0) > 0.35 then
			veh.ramScanAt = os.clock()
			autoRamTick()
		end
	end)

	veh.start = function()
		if cfg.Cruise then
			local model = currentVehicle()
			local chassis = chassisOf(model)
			if chassis then
				local vel = chassis.AssemblyLinearVelocity
				veh.cruiseSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
			end
		end
		if cfg.SpeedHud then
			ensureHud()
		end
		if veh.hbConn then
			return
		end
		if not wanted() then
			return
		end
		veh.started = true
		veh.hbConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(loopTick))
		track(veh.hbConn)
	end

	veh.stop = function()
		cfg.SpeedHud = false
		cfg.Cruise = false
		cfg.CollisionStop = false
		cfg.GroundLock = false
		cfg.Float = false
		cfg.NoCrashes = false
		cfg.FullFuel = false
		cfg.AutoRam = false
		cfg.FollowPlayer = false
		if veh.hbConn then
			pcall(function()
				veh.hbConn:Disconnect()
			end)
			veh.hbConn = nil
		end
		veh.started = false
		destroyHud()
		restoreCollisions()
	end

	veh.bring = bringCar
	veh.enter = enterCar
	veh.ram = function()
		local player = targetPlayer()
		if not player then
			notify("Xi Pro", T("vehNoTarget"))
			return
		end
		task.spawn(function()
			ramPlayer(player, false)
		end)
	end
	veh.send = sendCar
	veh.playerNames = function()
		local list = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				list[#list + 1] = player.Name
			end
		end
		table.sort(list)
		if #list == 0 then
			list[1] = "-"
		end
		return list
	end
	veh.refreshDropdown = function()
		local list = veh.playerNames()
		pcall(function()
			if st.vehDropdown and st.vehDropdown.Refresh then
				st.vehDropdown:Refresh(list)
			elseif st.vehDropdown and st.vehDropdown.SetValues then
				st.vehDropdown:SetValues(list)
			end
		end)
		if not veh.targetName or veh.targetName == "-" then
			veh.targetName = list[1]
		end
	end
	track(Players.PlayerAdded:Connect(function()
		task.defer(veh.refreshDropdown)
	end))
	track(Players.PlayerRemoving:Connect(function()
		task.defer(veh.refreshDropdown)
	end))
end

local function initEsp()
	if esp.ready then
		return
	end
	esp.ready = true
	esp.entries = {}
	esp.tick = 0
	esp.colAt = 0
	esp.wantedBlue = Color3.fromRGB(70, 170, 255)
	esp.hpLow = Color3.fromRGB(255, 60, 60)
	esp.hpHigh = Color3.fromRGB(60, 220, 90)

	local function wantedOn()
		return cfg.EspTracers or cfg.EspDots or cfg.EspDetails or cfg.EspHealth
	end

	local function hideItem(item)
		if item and item.Visible then
			item.Visible = false
		end
	end

	local function hideEntry(entry)
		if not entry then
			return
		end
		hideItem(entry.tracer)
		hideItem(entry.dot)
		hideItem(entry.label)
		hideItem(entry.hpBg)
	end

	local function destroyEntry(player)
		local entry = esp.entries[player]
		if not entry then
			return
		end
		for _, key in ipairs({ "tracer", "dot", "label", "hpBg" }) do
			pcall(function()
				if entry[key] then
					entry[key]:Destroy()
				end
			end)
		end
		esp.entries[player] = nil
	end

	local function destroyGui()
		for player in pairs(esp.entries) do
			destroyEntry(player)
		end
		if esp.gui then
			pcall(function()
				esp.gui:Destroy()
			end)
		end
		esp.gui = nil
	end

	local function ensureGui()
		if esp.gui and esp.gui.Parent then
			esp.gui.Enabled = true
			return
		end
		local gui = Instance.new("ScreenGui")
		gui.Name = "XiProESP"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 90
		gui.Parent = getUiHost()
		pcall(function()
			local protect = (syn and syn.protect_gui) or protect_gui
			if protect then
				protect(gui)
			end
		end)
		esp.gui = gui
	end

	local function makeEntry(player)
		if esp.entries[player] or not esp.gui then
			return
		end
		local tracer = Instance.new("Frame")
		tracer.AnchorPoint = Vector2.new(0.5, 0.5)
		tracer.Size = UDim2.fromOffset(0, 2)
		tracer.BackgroundColor3 = Color3.new(1, 1, 1)
		tracer.BorderSizePixel = 0
		tracer.Visible = false
		tracer.ZIndex = 1
		tracer.Parent = esp.gui
		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Size = UDim2.fromOffset(9, 9)
		dot.BackgroundColor3 = Color3.new(1, 1, 1)
		dot.BorderSizePixel = 0
		dot.Visible = false
		dot.ZIndex = 3
		dot.Parent = esp.gui
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
		local dotStroke = Instance.new("UIStroke")
		dotStroke.Color = Color3.fromRGB(0, 0, 0)
		dotStroke.Thickness = 1
		dotStroke.Transparency = 0.3
		dotStroke.Parent = dot
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 1)
		label.Size = UDim2.fromOffset(220, 46)
		label.BackgroundTransparency = 1
		label.RichText = true
		label.Text = ""
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(245, 245, 245)
		label.TextYAlignment = Enum.TextYAlignment.Bottom
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Visible = false
		label.ZIndex = 2
		label.Parent = esp.gui
		local labelStroke = Instance.new("UIStroke")
		labelStroke.Color = Color3.fromRGB(0, 0, 0)
		labelStroke.Thickness = 1.4
		labelStroke.Transparency = 0.35
		labelStroke.Parent = label
		local hpBg = Instance.new("Frame")
		hpBg.AnchorPoint = Vector2.new(0.5, 0.5)
		hpBg.Size = UDim2.fromOffset(4, 44)
		hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		hpBg.BackgroundTransparency = 0.35
		hpBg.BorderSizePixel = 0
		hpBg.Visible = false
		hpBg.ZIndex = 1
		hpBg.Parent = esp.gui
		local hpBgCorner = Instance.new("UICorner")
		hpBgCorner.CornerRadius = UDim.new(1, 0)
		hpBgCorner.Parent = hpBg
		local hpFill = Instance.new("Frame")
		hpFill.AnchorPoint = Vector2.new(0.5, 1)
		hpFill.Position = UDim2.new(0.5, 0, 1, 0)
		hpFill.Size = UDim2.new(1, 0, 1, 0)
		hpFill.BackgroundColor3 = esp.hpHigh
		hpFill.BorderSizePixel = 0
		hpFill.ZIndex = 1
		hpFill.Parent = hpBg
		local hpFillCorner = Instance.new("UICorner")
		hpFillCorner.CornerRadius = UDim.new(1, 0)
		hpFillCorner.Parent = hpFill
		esp.entries[player] = {
			tracer = tracer,
			dot = dot,
			label = label,
			hpBg = hpBg,
			hpFill = hpFill,
		}
	end

	local function ensurePlayers()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				makeEntry(player)
			end
		end
	end

	local function isDowned(humanoid, character)
		if not humanoid then
			return true
		end
		if humanoid.Health <= 0 then
			return true
		end
		if character and character:GetAttribute("IsDead") == true then
			return true
		end
		return humanoid:GetState() == Enum.HumanoidStateType.Dead
	end

	local function isPolicePlayer(player)
		local team = player and player.Team
		return team and team.Name == "Police"
	end

	local function playerColor(player)
		if cfg.EspWanted and wantedLevelOf(player) > 0 then
			return esp.wantedBlue
		end
		local team = player.Team
		if team then
			return team.TeamColor.Color
		end
		return Color3.fromRGB(230, 230, 230)
	end

	local function detailText(player, dist, humanoid)
		local hp = humanoid and math.floor(humanoid.Health + 0.5) or 0
		local wanted = wantedLevelOf(player)
		if wanted > 0 then
			return string.format("%s  ★%d\n%d m  %d HP", player.DisplayName, wanted, dist, hp)
		end
		return string.format("%s\n%d m  %d HP", player.DisplayName, dist, hp)
	end

	local function setColor(gui, cache, key, color)
		if cache[key] ~= color then
			gui.BackgroundColor3 = color
			cache[key] = color
		end
	end

	local function setXY(gui, cache, key, x, y)
		local px, py = cache[key .. "x"], cache[key .. "y"]
		if px ~= x or py ~= y then
			gui.Position = UDim2.fromOffset(x, y)
			cache[key .. "x"] = x
			cache[key .. "y"] = y
		end
	end

	local tickEsp = LPH_NO_VIRTUALIZE(function()
		if not wantedOn() then
			if esp.conn then
				pcall(function()
					esp.conn:Disconnect()
				end)
				esp.conn = nil
			end
			destroyGui()
			return
		end
		ensureGui()
		ensurePlayers()
		esp.tick += 1
		local cam = Workspace.CurrentCamera
		if not (cam and esp.gui) then
			return
		end
		local view = cam.ViewportSize
		local originX, originY = view.X * 0.5, view.Y
		local myRoot = getRootPart(getCharacter(LocalPlayer))
		local myPos = myRoot and myRoot.Position or cam.CFrame.Position
		local now = os.clock()
		local refreshText = now - (esp.colAt or 0) >= 0.12
		if refreshText then
			esp.colAt = now
		end
		local range = tonumber(cfg.EspRange) or 1000
		local folder = getCharsFolder()
		for player, entry in pairs(esp.entries) do
			if not player.Parent then
				destroyEntry(player)
				continue
			end
			if cfg.EspPoliceOnly and not isPolicePlayer(player) then
				hideEntry(entry)
				continue
			end
			if cfg.EspWantedOnly and wantedLevelOf(player) <= 0 then
				hideEntry(entry)
				continue
			end
			local character = entry.model
			if not (character and character.Parent) then
				character = (folder and folder:FindFirstChild(player.Name)) or player.Character
				entry.model = character
				entry.root = nil
				entry.head = nil
				entry.hum = nil
			end
			local root = entry.root
			if not (root and root.Parent) then
				root = character and character:FindFirstChild("HumanoidRootPart")
				entry.root = root
			end
			if not root then
				hideEntry(entry)
				continue
			end
			local dist = (root.Position - myPos).Magnitude
			if dist > range then
				hideEntry(entry)
				continue
			end
			local humanoid = entry.hum
			if not (humanoid and humanoid.Parent) then
				humanoid = character and character:FindFirstChildOfClass("Humanoid")
				entry.hum = humanoid
			end
			if cfg.EspHideDead and isDowned(humanoid, character) then
				hideEntry(entry)
				continue
			end
			local head = entry.head
			if not (head and head.Parent) then
				head = character and (character:FindFirstChild("Head") or root)
				entry.head = head
			end
			if refreshText or not entry.col then
				entry.col = playerColor(player)
			end
			local color = entry.col
			local world = root.Position
			local headWorld = (head and head.Position or world) + Vector3.new(0, 2.2, 0)
			local body, onBody = cam:WorldToViewportPoint(world)
			local top, onTop = cam:WorldToViewportPoint(headWorld)
			local topX = math.floor(top.X + 0.5)
			local topY = math.floor(top.Y + 0.5)
			if cfg.EspTracers then
						local tx, ty, ok
						if onBody and body.Z > 0 then
							tx, ty, ok = body.X, body.Y, true
						elseif cfg.EspOffscreen then
							local ox, oy = body.X, body.Y
							if body.Z < 0 then
								ox, oy = view.X - ox, view.Y - oy
							end
							tx = math.clamp(ox, 8, view.X - 8)
							ty = math.clamp(oy, 8, view.Y - 8)
							ok = true
						end
						if ok then
							setColor(entry.tracer, entry, "trCol", color)
							local dx, dy = tx - originX, ty - originY
							local len = math.floor(math.sqrt(dx * dx + dy * dy) + 0.5)
							if entry.trLen ~= len then
								entry.tracer.Size = UDim2.fromOffset(len, 2)
								entry.trLen = len
							end
							setXY(entry.tracer, entry, "tr", math.floor((originX + tx) / 2 + 0.5), math.floor((originY + ty) / 2 + 0.5))
							local rot = math.deg(math.atan2(dy, dx))
							if entry.trRot ~= rot then
								entry.tracer.Rotation = rot
								entry.trRot = rot
							end
							entry.tracer.Visible = true
						else
							hideItem(entry.tracer)
						end
					else
						hideItem(entry.tracer)
					end
					local onScreen = onTop and top.Z > 0
					if cfg.EspDots and onScreen then
						setColor(entry.dot, entry, "dotCol", color)
						setXY(entry.dot, entry, "dot", topX, topY)
						entry.dot.Visible = true
					else
						hideItem(entry.dot)
					end
					if cfg.EspDetails and onScreen then
						if refreshText or entry.label.Text == "" then
							entry.label.Text = detailText(player, math.floor(dist + 0.5), humanoid)
						end
						setXY(entry.label, entry, "lbl", topX, topY - 8)
						entry.label.Visible = true
					else
						hideItem(entry.label)
					end
					if cfg.EspHealth and humanoid and onScreen then
						local bx, by = body.X, body.Y
						local h = math.abs(topY - by)
						local barH = math.floor(math.clamp(h * 1.15, 26, 80) + 0.5)
						local barW = math.clamp(barH * 0.16, 6, 40)
						setXY(entry.hpBg, entry, "hp", math.floor(bx - barW - 6 + 0.5), math.floor((topY + by) / 2 + 0.5))
						if entry.hpH ~= barH then
							entry.hpBg.Size = UDim2.fromOffset(4, barH)
							entry.hpH = barH
						end
						local frac = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
						if entry.hpFrac ~= frac then
							entry.hpFill.Size = UDim2.new(1, 0, frac, 0)
							entry.hpFill.BackgroundColor3 = esp.hpLow:Lerp(esp.hpHigh, frac)
							entry.hpFrac = frac
						end
						entry.hpBg.Visible = true
					else
						hideItem(entry.hpBg)
					end
		end
	end)

	esp.start = function()
		if not wantedOn() then
			if esp.stop then
				esp.stop()
			end
			return
		end
		ensureGui()
		ensurePlayers()
		if esp.conn then
			return
		end
		esp.conn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(tickEsp))
		track(esp.conn)
	end

	esp.stop = function()
		if esp.conn then
			pcall(function()
				esp.conn:Disconnect()
			end)
			esp.conn = nil
		end
		destroyGui()
	end

	track(Players.PlayerAdded:Connect(function(player)
		if player ~= LocalPlayer and wantedOn() then
			ensureGui()
			makeEntry(player)
		end
	end))
	track(Players.PlayerRemoving:Connect(destroyEntry))
end

local function initTeleport()
	if tp.ready then
		return
	end
	tp.ready = true
	tp.locQuery = ""
	tp.locMap = {}
	tp.crimeMap = {}
	tp.crimeFilter = "all"
	tp.blinkDist = 50
	tp.viewing = nil
	tp.blinkConns = {}

	local function rebase(cf)
		if ghost.on then
			ghost.realCF = cf
		end
		if cfg.Stealth then
			st.stealthRealCF = cf
		end
	end

	local function streamAround(pos)
		if typeof(pos) ~= "Vector3" then
			return
		end
		if os.clock() - (tp.streamAt or 0) < 1 then
			return
		end
		tp.streamAt = os.clock()
		task.spawn(function()
			pcall(function()
				LocalPlayer:RequestStreamAroundAsync(pos)
			end)
		end)
	end

	local function pivotChar(cf)
		local character = getCharacter(LocalPlayer)
		if not (character and typeof(cf) == "CFrame") then
			return false
		end
		rebase(cf)
		local fn = st.charPivotToOrig
		if type(fn) ~= "function" then
			local alg = st.algorithmsModule
			fn = alg and alg.charPivotTo
		end
		if type(fn) == "function" then
			local ok = pcall(function()
				callAtIdentity(function()
					fn(character, cf)
				end)
			end)
			if ok then
				pcall(function()
					character:PivotTo(cf)
				end)
				return true
			end
		end
		return (pcall(function()
			character:PivotTo(cf)
		end))
	end

	local function tpToPos(pos, name)
		if typeof(pos) ~= "Vector3" then
			notify("Xi Pro", T("tpFail"))
			return false
		end
		task.spawn(function()
			local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
			streamAround(cf.Position)
			pivotChar(cf)
			local character = getCharacter(LocalPlayer)
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and not root.Anchored and not ghost.on then
				pcall(function()
					root.Anchored = true
				end)
				task.wait(0.15)
				pcall(function()
					root.AssemblyLinearVelocity = Vector3.zero
					root.Anchored = false
				end)
			end
			notify("Xi Pro", T("tpOk") .. (name and (" · " .. name) or ""))
		end)
		return true
	end

	local function findSpawn(inst)
		if not inst then
			return nil
		end
		local spawnLocation = inst:FindFirstChild("SpawnLocation", true)
		if spawnLocation and spawnLocation:IsA("BasePart") then
			return spawnLocation
		end
		for _, desc in ipairs(inst:GetDescendants()) do
			if desc.Name == "_Interaction" and desc:IsA("BasePart") and desc:FindFirstChildWhichIsA("ProximityPrompt", true) then
				return desc
			end
		end
		if inst:IsA("BasePart") then
			return inst
		end
		return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
	end

	local function interactionOf(part)
		if not part then
			return nil
		end
		if part:FindFirstChildOfClass("ProximityPrompt") then
			return part
		end
		local cur = part
		while cur.Parent and cur.Parent.Name ~= "Locations" and cur.Parent.Name ~= "Gameplay" do
			cur = cur.Parent
		end
		local fallback
		for _, desc in ipairs(cur:GetDescendants()) do
			if desc:IsA("BasePart") and desc.Name:sub(1, 12) == "_Interaction" and desc:FindFirstChildOfClass("ProximityPrompt") then
				if desc.Name == "_Interaction" then
					return desc
				end
				fallback = fallback or desc
			end
		end
		return fallback
	end

	local function tpToLocation(part, name)
		if typeof(part) ~= "Instance" then
			notify("Xi Pro", T("tpFail"))
			return
		end
		local core = st.coreModule
		if not (core and type(core.enterLocation) == "function") then
			tpToPos(part.Position, name)
			return
		end
		local spawnPoint = interactionOf(part) or part
		task.spawn(function()
			pcall(function()
				callAtIdentity(function()
					core.enterLocation({ spawnPoint = spawnPoint })
				end)
			end)
			notify("Xi Pro", T("tpOk") .. (name and (" · " .. name) or ""))
		end)
	end

	local function playerPos(player)
		if not player then
			return nil
		end
		local character = getCharacter(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			return root.Position
		end
		return player:GetAttribute("CharacterPosition")
	end

	local function stopViewing()
		if tp.viewConn then
			pcall(function()
				tp.viewConn:Disconnect()
			end)
			tp.viewConn = nil
		end
		tp.viewing = nil
		local cam = Workspace.CurrentCamera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			local _, hum = getLocalParts()
			if hum then
				cam.CameraSubject = hum
			end
		end
		if tp.viewAnchor then
			pcall(function()
				tp.viewAnchor:Destroy()
			end)
			tp.viewAnchor = nil
		end
	end

	local function viewAnchor()
		if tp.viewAnchor and tp.viewAnchor.Parent then
			return tp.viewAnchor
		end
		local part = Instance.new("Part")
		part.Name = "XiProViewAnchor"
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = Vector3.one
		part.Parent = Workspace
		tp.viewAnchor = part
		return part
	end

	local function startView(kind, target, name)
		stopViewing()
		tp.viewing = { kind = kind, target = target, name = name }
		local cam = Workspace.CurrentCamera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
		end
		tp.viewAccum = 0
		tp.viewConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
			local viewing = tp.viewing
			if not viewing then
				return
			end
			local camera = Workspace.CurrentCamera
			if not camera then
				return
			end
			if camera.CameraType ~= Enum.CameraType.Custom then
				camera.CameraType = Enum.CameraType.Custom
			end
			local pos
			if viewing.kind == "player" then
				local player = viewing.target
				if not (player and player.Parent) then
					stopViewing()
					return
				end
				pos = playerPos(player)
				local character = getCharacter(player)
				local subject = character and (character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("HumanoidRootPart"))
				if subject then
					camera.CameraSubject = subject
				elseif typeof(pos) == "Vector3" then
					local anchor = viewAnchor()
					anchor.CFrame = CFrame.new(pos)
					camera.CameraSubject = anchor
				end
			else
				local part = viewing.target
				if not (part and part.Parent) then
					stopViewing()
					return
				end
				pos = part.Position
				local anchor = viewAnchor()
				anchor.CFrame = CFrame.new(pos)
				camera.CameraSubject = anchor
			end
			tp.viewAccum = (tp.viewAccum or 0) + dt
			if typeof(pos) == "Vector3" and tp.viewAccum >= 0.7 then
				tp.viewAccum = 0
				streamAround(pos)
			end
		end))
		track(tp.viewConn)
		notify("Xi Pro", T("tpViewing") .. " · " .. tostring(name or ""))
	end

	local function mapMarkerPos()
		local core = st.coreModule
		if not core then
			return nil
		end
		local ok, result = pcall(function()
			return core.navigationPoint
		end)
		if ok and typeof(result) == "Vector3" then
			return result
		end
		ok, result = pcall(function()
			return core.waypoints and core.waypoints.Navigation
		end)
		if ok and type(result) == "function" then
			local ok2, pos = pcall(result)
			if ok2 and typeof(pos) == "Vector3" then
				return pos
			end
		end
		return nil
	end

	local function locationFolder()
		local stuff = ReplicatedStorage:FindFirstChild("Stuff")
		return stuff and stuff:FindFirstChild("Locations")
	end

	local function locationNames()
		local list = {}
		tp.locMap = {}
		local folder = locationFolder()
		if not folder then
			return { "-" }
		end
		local query = (tp.locQuery or ""):lower()
		local children = folder:GetChildren()
		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)
		for _, child in ipairs(children) do
			if query == "" or child.Name:lower():find(query, 1, true) then
				local spawn = findSpawn(child)
				if spawn then
					list[#list + 1] = child.Name
					tp.locMap[child.Name] = spawn
				end
			end
		end
		if #list == 0 then
			list[1] = "-"
		end
		return list
	end

	local function crimePos(mission)
		if not mission then
			return nil
		end
		local startLocation = mission:FindFirstChild("StartLocation")
		local value = startLocation and startLocation.Value
		if typeof(value) == "Vector3" then
			return value
		end
		if typeof(value) == "Instance" then
			if value:IsA("BasePart") then
				return value.Position
			end
			local ok, pivot = pcall(function()
				return value:GetPivot()
			end)
			if ok and pivot then
				return pivot.Position
			end
		end
		local include = mission:FindFirstChild("IncludePlayerLocation")
		if include and typeof(include.Value) == "Vector3" then
			return include.Value
		end
		local object = mission:FindFirstChild("Object")
		if object and typeof(object.Value) == "Instance" then
			local ok, pivot = pcall(function()
				return object.Value:GetPivot()
			end)
			if ok and pivot then
				return pivot.Position
			end
		end
		return nil
	end

	local function crimeMatch(name)
		local filter = tp.crimeFilter or "all"
		if filter == "all" then
			return true
		end
		local lower = string.lower(name)
		return lower:find(filter, 1, true) ~= nil
	end

	local function crimeNames()
		local list = {}
		tp.crimeMap = {}
		local gameplay = ReplicatedStorage:FindFirstChild("Gameplay")
		local missions = gameplay and gameplay:FindFirstChild("Missions")
		local active = missions and missions:FindFirstChild("Active")
		if not active then
			return { "-" }
		end
		local rows = {}
		for _, child in ipairs(active:GetChildren()) do
			if child:IsA("BoolValue") and child:FindFirstChild("ID") and crimeMatch(child.Name) then
				rows[#rows + 1] = child
			end
		end
		table.sort(rows, function(a, b)
			local idA = a:FindFirstChild("ID") and a.ID.Value or 0
			local idB = b:FindFirstChild("ID") and b.ID.Value or 0
			if idA == idB then
				return a.Name < b.Name
			end
			return idA < idB
		end)
		for _, row in ipairs(rows) do
			local objectName = row:FindFirstChild("ObjectName")
			local label = objectName and objectName.Value ~= "" and (row.Name .. " · " .. objectName.Value) or row.Name
			if row.Value == false then
				label = label .. " ✓"
			end
			list[#list + 1] = label
			tp.crimeMap[label] = row
		end
		if #list == 0 then
			list[1] = "-"
		end
		return list
	end

	local function refreshDropdown(dropdown, values)
		pcall(function()
			if dropdown and dropdown.Refresh then
				dropdown:Refresh(values)
			elseif dropdown and dropdown.SetValues then
				dropdown:SetValues(values)
			end
		end)
	end

	local function blinkTo(x, y)
		local character = getCharacter(LocalPlayer)
		local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
		if not root then
			return
		end
		local cam = Workspace.CurrentCamera
		if not cam then
			return
		end
		local ray = cam:ScreenPointToRay(x, y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }
		local hit = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
		local dest
		if hit then
			dest = hit.Position + hit.Normal * 3
		else
			local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			dest = root.Position + (look.Magnitude > 0 and look.Unit or cam.CFrame.LookVector) * tp.blinkDist
		end
		if not ghost.on then
			local down = Workspace:Raycast(dest + Vector3.new(0, 5, 0), Vector3.new(0, -4000, 0), params)
			if down then
				local cap = down.Position.Y + 60
				if dest.Y > cap then
					dest = Vector3.new(dest.X, cap, dest.Z)
				end
			end
		end
		local rot = root.CFrame - root.CFrame.Position
		local cf = CFrame.new(dest) * rot
		pcall(function()
			root.CFrame = cf
			root.AssemblyLinearVelocity = Vector3.zero
		end)
		rebase(cf)
	end

	local function destroyBlinkBtn()
		if tp.blinkGui then
			pcall(function()
				tp.blinkGui:Destroy()
			end)
		end
		tp.blinkGui = nil
		tp.blinkBtn = nil
		tp.blinkArmed = false
	end

	local function ensureBlinkBtn()
		if tp.blinkGui and tp.blinkGui.Parent then
			return
		end
		local gui = Instance.new("ScreenGui")
		gui.Name = "XiProBlink"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 95
		gui.Parent = getUiHost()
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(52, 52)
		btn.Position = UDim2.new(1, -68, 0.62, -26)
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = 0.18
		btn.Text = "Blink"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.AutoButtonColor = true
		btn.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = btn
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.72
		stroke.Parent = btn
		tp.blinkGui = gui
		tp.blinkBtn = btn
		btn.MouseButton1Click:Connect(function()
			tp.blinkArmed = not tp.blinkArmed
			btn.Text = tp.blinkArmed and "Tap" or "Blink"
			notify("Xi Pro", tp.blinkArmed and T("tpBlinkOn") or T("tpBlinkOff"))
		end)
	end

	local function stopBlink()
		cfg.Blink = false
		for _, conn in ipairs(tp.blinkConns) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		table.clear(tp.blinkConns)
		destroyBlinkBtn()
	end

	local function startBlink()
		stopBlink()
		cfg.Blink = true
		tp.blinkConns[#tp.blinkConns + 1] = UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not cfg.Blink then
				return
			end
			if input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.Eight then
				local mouse = UserInputService:GetMouseLocation()
				blinkTo(mouse.X, mouse.Y)
			elseif IS_MOBILE and tp.blinkArmed and input.UserInputType == Enum.UserInputType.Touch then
				tp.blinkArmed = false
				if tp.blinkBtn then
					tp.blinkBtn.Text = "Blink"
				end
				blinkTo(input.Position.X, input.Position.Y)
			end
		end)
		if IS_MOBILE then
			ensureBlinkBtn()
		end
		track(tp.blinkConns[#tp.blinkConns])
	end

	local function currentCF()
		if ghost.on and ghost.realCF then
			return ghost.realCF
		end
		if cfg.Stealth and st.stealthRealCF then
			return st.stealthRealCF
		end
		local _, _, root = getLocalParts()
		return root and root.CFrame
	end

	local function roofExit()
		local inside = LocalPlayer:FindFirstChild("InsideLocation")
		if not (inside and inside.Value) then
			return nil
		end
		local here = currentCF()
		if not here then
			return nil
		end
		local best, bestDist
		for _, desc in ipairs(inside.Value:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Name == "EnterLocation" then
				local loc = desc:FindFirstChild("Location")
				loc = loc and loc.Value
				if loc and loc:IsA("BasePart") and loc.Position.Y > here.Position.Y + 150 then
					local dist = Vector3.new(loc.Position.X - here.Position.X, 0, loc.Position.Z - here.Position.Z).Magnitude
					if not bestDist or dist < bestDist then
						bestDist = dist
						best = loc
					end
				end
			end
		end
		return best
	end

	local function returnToSurface()
		local exitPart = roofExit()
		local core = st.coreModule
		if exitPart and core and type(core.enterLocation) == "function" then
			pcall(function()
				callAtIdentity(function()
					core.enterLocation({ spawnPoint = exitPart })
				end)
			end)
			notify("Xi Pro", T("tpSurfaceOk"))
			return
		end
		local character, humanoid, root = getLocalParts()
		if not (character and humanoid and root) then
			notify("Xi Pro", T("tpFail"))
			return
		end
		if humanoid.SeatPart then
			notify("Xi Pro", T("tpFail"))
			return
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character, Workspace:FindFirstChild(CHARS_FOLDER) }
		local fromY = math.max(root.Position.Y + 600, 1500)
		local hit = Workspace:Raycast(Vector3.new(root.Position.X, fromY, root.Position.Z), Vector3.new(0, -6000, 0), params)
		if not hit or math.abs(hit.Position.Y - root.Position.Y) < 8 then
			notify("Xi Pro", T("tpSurfaceIdle"))
			return
		end
		if hit.Position.Y <= root.Position.Y + 3 then
			notify("Xi Pro", T("tpSurfaceIdle"))
			return
		end
		local hip = humanoid.HipHeight or 2
		local cf = CFrame.new(hit.Position.X, hit.Position.Y + hip + 2, hit.Position.Z) * (root.CFrame - root.CFrame.Position)
		pivotChar(cf)
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
		end)
		notify("Xi Pro", T("tpSurfaceOk"))
	end

	tp.playerNames = function()
		local list = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				list[#list + 1] = player.Name
			end
		end
		table.sort(list)
		if #list == 0 then
			list[1] = "-"
		end
		return list
	end

	tp.refreshPlayers = function()
		local list = tp.playerNames()
		refreshDropdown(st.tpPlayerDropdown, list)
		if not tp.playerName or tp.playerName == "-" then
			tp.playerName = list[1]
		end
	end

	tp.refreshLocs = function()
		local list = locationNames()
		refreshDropdown(st.tpLocDropdown, list)
		if not tp.locName or not tp.locMap[tp.locName] then
			tp.locName = list[1]
		end
	end

	tp.refreshCrimes = function()
		local list = crimeNames()
		refreshDropdown(st.tpCrimeDropdown, list)
		if not tp.crimeName or not tp.crimeMap[tp.crimeName] then
			tp.crimeName = list[1]
		end
	end

	tp.crimeFilterLabels = function()
		return {
			T("crimeAll"),
			T("crimeRobbery"),
			T("crimeHeist"),
			T("crimeCar"),
			T("crimeTrade"),
		}
	end

	tp.setCrimeFilter = function(label)
		if label == T("crimeRobbery") or label == "Robbery" or label == "抢劫" then
			tp.crimeFilter = "robbery"
		elseif label == T("crimeHeist") or label == "Heist" or label == "劫案" then
			tp.crimeFilter = "heist"
		elseif label == T("crimeCar") or label == "Car" or label == "车辆" then
			tp.crimeFilter = "car"
		elseif label == T("crimeTrade") or label == "Trade" or label == "交易" then
			tp.crimeFilter = "trade"
		else
			tp.crimeFilter = "all"
		end
		tp.refreshCrimes()
	end

	tp.toPlayer = function()
		local player = Players:FindFirstChild(tp.playerName or "")
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return
		end
		local pos = playerPos(player)
		if typeof(pos) ~= "Vector3" then
			notify("Xi Pro", player.DisplayName .. " " .. T("tpNotLoaded"))
			return
		end
		tpToPos(pos, player.DisplayName)
	end

	tp.viewPlayer = function()
		local player = Players:FindFirstChild(tp.playerName or "")
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return
		end
		local pos = playerPos(player)
		if typeof(pos) ~= "Vector3" then
			notify("Xi Pro", player.DisplayName .. " " .. T("tpNotLoaded"))
			return
		end
		streamAround(pos)
		startView("player", player, player.DisplayName)
	end

	tp.toMarker = function()
		pcall(loadCoreModule)
		local pos = mapMarkerPos()
		if not pos then
			notify("Xi Pro", T("tpNoMarker"))
			return
		end
		tpToPos(pos, T("sectionTpMarker"))
	end

	tp.toLocation = function()
		local spawn = tp.locMap[tp.locName]
		if not spawn then
			notify("Xi Pro", T("tpNoLocation"))
			return
		end
		pcall(loadCoreModule)
		tpToLocation(spawn, tp.locName)
	end

	tp.viewLocation = function()
		local spawn = tp.locMap[tp.locName]
		if not spawn then
			notify("Xi Pro", T("tpNoLocation"))
			return
		end
		streamAround(spawn.Position)
		startView("location", spawn, tp.locName)
	end

	tp.toCrime = function()
		local mission = tp.crimeMap[tp.crimeName]
		local pos = crimePos(mission)
		if not pos then
			notify("Xi Pro", T("tpNoCrime"))
			return
		end
		tpToPos(pos, mission and mission.Name or tp.crimeName)
	end

	tp.stopView = stopViewing
	tp.startBlink = startBlink
	tp.stopBlink = stopBlink
	tp.surface = returnToSurface
	tp.stop = function()
		stopBlink()
		stopViewing()
		if tp.surfGui then
			pcall(function()
				tp.surfGui:Destroy()
			end)
			tp.surfGui = nil
		end
	end

	track(Players.PlayerAdded:Connect(function()
		task.defer(tp.refreshPlayers)
	end))
	track(Players.PlayerRemoving:Connect(function(player)
		if tp.viewing and tp.viewing.kind == "player" and tp.viewing.target == player then
			stopViewing()
		end
		task.defer(tp.refreshPlayers)
	end))

	pcall(loadCoreModule)
	task.defer(function()
		tp.refreshLocs()
		tp.refreshCrimes()
	end)
end

local function initShop()
	if shop.ready then
		return
	end
	shop.ready = true
	shop.query = ""
	shop.filter = "all"
	shop.qty = 1
	shop.items = {}
	shop.map = {}
	shop.skip = {
		["yellow usb"] = true,
		["blue usb"] = true,
		pocket = true,
	}

	local function itemCost(model)
		local config = model:FindFirstChild("Config")
		if not config then
			return nil
		end
		local ok, result = pcall(require, config)
		if not (ok and type(result) == "table" and type(result.COST) == "number") then
			return nil
		end
		if not result.UNIQUE and (result.CATEGORY == "Food" or result.CATEGORY == "Drink") then
			return math.round(result.COST * 1.2)
		end
		return result.COST
	end

	local function scanItems()
		local list = {}
		local stuff = ReplicatedStorage:FindFirstChild("Stuff")
		if not stuff then
			return list
		end
		for _, cat in ipairs({ "Black Market", "Food", "Weapons", "Items" }) do
			local folder = stuff:FindFirstChild(cat)
			if folder then
				if cat == "Items" then
					for _, child in ipairs(folder:GetChildren()) do
						local cost = child:IsA("Model") and not shop.skip[child.Name:lower()] and itemCost(child)
						if cost then
							list[#list + 1] = {
								name = child.Name,
								instance = child,
								cat = cat,
								cost = cost,
							}
						end
					end
				else
					for _, desc in ipairs(folder:GetDescendants()) do
						local cost = desc:IsA("Model") and not shop.skip[desc.Name:lower()] and itemCost(desc)
						if cost then
							local name = desc.Name
							if desc.Parent and desc.Parent.Name:match("^%d+$") then
								name = desc.Parent.Name .. " - " .. desc.Name
							end
							list[#list + 1] = {
								name = name,
								instance = desc,
								cat = cat,
								cost = cost,
							}
						end
					end
				end
			end
		end
		table.sort(list, function(a, b)
			return a.name < b.name
		end)
		return list
	end

	local function catKey(label)
		if label == T("shopWeapons") or label == "Weapons" or label == "武器" then
			return "Weapons"
		end
		if label == T("shopBlack") or label == "Black Market" or label == "黑市" then
			return "Black Market"
		end
		if label == T("shopFood") or label == "Food" or label == "食物" then
			return "Food"
		end
		if label == T("shopItems") or label == "Items" or label == "物品" then
			return "Items"
		end
		return "all"
	end

	local function itemLabel(entry)
		return string.format("%s  ·  $%s", entry.name, tostring(entry.cost))
	end

	local function filteredLabels()
		if #shop.items == 0 then
			shop.items = scanItems()
		end
		local list = {}
		shop.map = {}
		local query = (shop.query or ""):lower()
		for _, entry in ipairs(shop.items) do
			if (shop.filter == "all" or entry.cat == shop.filter) and (query == "" or entry.name:lower():find(query, 1, true)) then
				local label = itemLabel(entry)
				list[#list + 1] = label
				shop.map[label] = entry
			end
		end
		if #list == 0 then
			list[1] = "-"
		end
		return list
	end

	local function refreshDropdown(dropdown, values)
		pcall(function()
			if dropdown and dropdown.Refresh then
				dropdown:Refresh(values)
			elseif dropdown and dropdown.SetValues then
				dropdown:SetValues(values)
			end
		end)
	end

	local function selected()
		return shop.map[shop.selected]
	end

	local function purchase(payload)
		local func = resolvePlayerFunc()
		if not func then
			return false
		end
		return (pcall(function()
			func:InvokeServer("purchase", payload)
		end))
	end

	shop.catLabels = function()
		return {
			T("shopAll"),
			T("shopWeapons"),
			T("shopBlack"),
			T("shopFood"),
			T("shopItems"),
		}
	end

	shop.setFilter = function(label)
		shop.filter = catKey(label)
		shop.refresh()
	end

	shop.refresh = function()
		shop.items = scanItems()
		local list = filteredLabels()
		refreshDropdown(st.shopItemDropdown, list)
		if not shop.selected or not shop.map[shop.selected] then
			shop.selected = list[1]
		end
	end

	shop.labels = filteredLabels

	shop.buy = function()
		local entry = selected()
		if not entry then
			notify("Xi Pro", T("shopNeedItem"))
			return
		end
		local qty = math.max(1, math.floor(tonumber(shop.qty) or 1))
		local food = entry.cat == "Food"
		task.spawn(function()
			local ok = true
			for _ = 1, qty do
				if not purchase({ isResturant = food, item = entry.instance }) then
					ok = false
					break
				end
			end
			notify("Xi Pro", ok and (T("shopBought") .. " · " .. tostring(qty) .. "× " .. entry.name) or T("shopBuyFail"))
		end)
	end

	shop.refill = function()
		local entry = selected()
		if not entry then
			notify("Xi Pro", T("shopNeedItem"))
			return
		end
		if entry.cat ~= "Weapons" then
			notify("Xi Pro", T("shopRefillNeedGun"))
			return
		end
		local qty = math.max(1, math.floor(tonumber(shop.qty) or 1))
		task.spawn(function()
			local ok = purchase({ item = entry.instance, quantity = qty })
			notify("Xi Pro", ok and (T("shopRefilled") .. " · " .. entry.name .. " ×" .. tostring(qty)) or T("shopRefillFail"))
		end)
	end
end

local function initPlayers()
	if pl.ready then
		return
	end
	pl.ready = true
	pl.query = ""
	pl.sort = "distance"
	pl.pinned = pl.pinned or {}
	pl.nearAt = {}

	local function distTo(player)
		local their = getRootPart(getCharacter(player))
		local mine = getRootPart(getCharacter(LocalPlayer))
		if not (their and mine) then
			return nil
		end
		return (their.Position - mine.Position).Magnitude
	end

	local function healthOf(player)
		local character = getCharacter(player)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return nil, nil
		end
		return humanoid.Health, humanoid.MaxHealth
	end

	local function teamName(player)
		local team = player and player.Team
		return team and team.Name or "-"
	end

	local function isCop(player)
		local name = string.lower(tostring(teamName(player)))
		return string.find(name, "police", 1, true)
			or string.find(name, "sheriff", 1, true)
			or string.find(name, "trooper", 1, true)
	end

	local function fmtDist(dist)
		if not dist then
			return "?"
		end
		if dist >= 1000 then
			return string.format("%.1fk", dist / 1000)
		end
		return tostring(math.floor(dist + 0.5))
	end

	local function selectedPlayer()
		local name = pl.selected
		if type(name) ~= "string" or name == "" or name == "-" then
			return nil
		end
		return Players:FindFirstChild(name)
	end

	local function filtered()
		local list = {}
		local query = (pl.query or ""):lower()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				if query == "" or player.Name:lower():find(query, 1, true) or player.DisplayName:lower():find(query, 1, true) then
					list[#list + 1] = player
				end
			end
		end
		table.sort(list, function(a, b)
			local pinA = pl.pinned[a.UserId] and 1 or 0
			local pinB = pl.pinned[b.UserId] and 1 or 0
			if pinA ~= pinB then
				return pinA > pinB
			end
			if pl.sort == "name" then
				return a.Name:lower() < b.Name:lower()
			end
			if pl.sort == "team" then
				local ta, tb = teamName(a), teamName(b)
				if ta ~= tb then
					return ta < tb
				end
				return a.Name:lower() < b.Name:lower()
			end
			local da = distTo(a) or math.huge
			local db = distTo(b) or math.huge
			if da == db then
				return a.Name:lower() < b.Name:lower()
			end
			return da < db
		end)
		return list
	end

	local function labels()
		local names = {}
		for _, player in ipairs(filtered()) do
			names[#names + 1] = player.Name
		end
		if #names == 0 then
			names[1] = "-"
		end
		return names
	end

	local function refreshDropdown()
		local list = labels()
		pcall(function()
			if st.plDropdown and st.plDropdown.Refresh then
				st.plDropdown:Refresh(list)
			elseif st.plDropdown and st.plDropdown.SetValues then
				st.plDropdown:SetValues(list)
			end
		end)
		if not pl.selected or pl.selected == "-" then
			pl.selected = list[1]
		end
	end

	local function infoText()
		local player = selectedPlayer()
		if not player then
			return T("plInfoEmpty")
		end
		local dist = distTo(player)
		local hp, maxHp = healthOf(player)
		local wanted = wantedLevelOf(player)
		local vehicle = getVehicle(player)
		local lines = {
			string.format("%s  (@%s)", player.DisplayName, player.Name),
			teamName(player) .. (wanted > 0 and ("  ·  ★" .. tostring(wanted)) or ""),
			fmtDist(dist) .. " studs  ·  " .. (hp and (tostring(math.floor(hp + 0.5)) .. " HP") or "?"),
		}
		if vehicle then
			lines[#lines + 1] = vehicle.Name
		end
		if pl.pinned[player.UserId] then
			lines[#lines + 1] = T("plPinned")
		end
		if st.friendCache[player.UserId] then
			lines[#lines + 1] = "Friend"
		end
		if st.lockPlayer == player then
			lines[#lines + 1] = T("plLocked")
		end
		return table.concat(lines, "\n")
	end

	local function paintInfo()
		pcall(function()
			if st.plInfo and st.plInfo.SetDesc then
				st.plInfo:SetDesc(infoText())
			end
		end)
	end

	local function usePlayer(player)
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return nil
		end
		pl.selected = player.Name
		if tp then
			tp.playerName = player.Name
		end
		if veh then
			veh.targetName = player.Name
		end
		return player
	end

	local function watchMatch(player)
		local mode = cfg.PlrWatchMode or "cops"
		if mode == "wanted" then
			return wantedLevelOf(player) > 0
		end
		if mode == "pinned" then
			return pl.pinned[player.UserId] == true
		end
		if mode == "all" then
			return true
		end
		return isCop(player)
	end

	local tickWatch = LPH_NO_VIRTUALIZE(function()
		if not cfg.PlrWatch then
			return
		end
		local now = os.clock()
		local range = tonumber(cfg.PlrWatchDist) or 150
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and watchMatch(player) then
				local dist = distTo(player)
				if dist and dist <= range then
					if not pl.nearAt[player.UserId] or now - pl.nearAt[player.UserId] > 20 then
						pl.nearAt[player.UserId] = now
						notify("Xi Pro", player.DisplayName .. " " .. T("plNear") .. " · " .. tostring(math.floor(dist + 0.5)))
					end
				elseif dist and dist > range * 1.35 then
					pl.nearAt[player.UserId] = nil
				end
			end
		end
	end)

	pl.labels = labels
	pl.refresh = function()
		refreshDropdown()
		paintInfo()
	end
	pl.paint = paintInfo
	pl.sortLabels = function()
		return { T("plSortNear"), T("plSortName"), T("plSortTeam") }
	end
	pl.setSort = function(label)
		if label == T("plSortName") or label == "Name" or label == "名字" then
			pl.sort = "name"
		elseif label == T("plSortTeam") or label == "Team" or label == "队伍" then
			pl.sort = "team"
		else
			pl.sort = "distance"
		end
		pl.refresh()
	end
	pl.watchLabels = function()
		return { T("plWatchCops"), T("plWatchWanted"), T("plWatchPinned"), T("plWatchAnyone") }
	end
	pl.setWatch = function(label)
		if label == T("plWatchWanted") or label == "Wanted" or label == "通缉" then
			cfg.PlrWatchMode = "wanted"
		elseif label == T("plWatchPinned") or label == "Pinned" or label == "置顶" then
			cfg.PlrWatchMode = "pinned"
		elseif label == T("plWatchAnyone") or label == "Anyone" or label == "所有人" then
			cfg.PlrWatchMode = "all"
		else
			cfg.PlrWatchMode = "cops"
		end
		table.clear(pl.nearAt)
	end

	pl.teleport = function()
		local player = usePlayer(selectedPlayer())
		if player and tp and tp.toPlayer then
			tp.toPlayer()
		end
	end
	pl.view = function()
		local player = usePlayer(selectedPlayer())
		if player and tp and tp.viewPlayer then
			tp.viewPlayer()
		end
	end
	pl.stopView = function()
		if tp and tp.stopView then
			tp.stopView()
			notify("Xi Pro", T("tpViewOff"))
		end
	end
	pl.follow = function()
		local player = usePlayer(selectedPlayer())
		if not (player and veh and veh.start) then
			notify("Xi Pro", T("plNeedMod"))
			return
		end
		cfg.FollowPlayer = true
		veh.start()
		notify("Xi Pro", T("plFollow") .. " · " .. player.DisplayName)
	end
	pl.stopFollow = function()
		cfg.FollowPlayer = false
		notify("Xi Pro", T("plStopFollow"))
	end
	pl.lock = function()
		local player = usePlayer(selectedPlayer())
		if not player then
			return
		end
		if st.lockPlayer == player then
			st.lockPlayer = nil
			notify("Xi Pro", T("plUnlocked"))
		else
			st.lockPlayer = player
			notify("Xi Pro", T("plLocked") .. " · " .. player.DisplayName)
		end
		paintInfo()
	end
	pl.whitelist = function()
		local player = selectedPlayer()
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return
		end
		if cfg.Whitelist[player.Name] then
			cfg.Whitelist[player.Name] = nil
			notify("Xi Pro", T("plAimThem") .. " · " .. player.Name)
		else
			cfg.Whitelist[player.Name] = true
			notify("Xi Pro", T("plNeverAim") .. " · " .. player.Name)
		end
		pcall(function()
			if st.refreshWhitelistUi then
				st.refreshWhitelistUi()
			end
		end)
	end
	pl.ram = function()
		local player = usePlayer(selectedPlayer())
		if not (player and veh and veh.ram) then
			notify("Xi Pro", T("plNeedMod"))
			return
		end
		veh.ram()
	end
	pl.hunt = function()
		local player = usePlayer(selectedPlayer())
		if not (player and veh and veh.start) then
			notify("Xi Pro", T("plNeedMod"))
			return
		end
		if veh.huntName == player.Name then
			veh.huntName = nil
			cfg.AutoRam = false
			notify("Xi Pro", T("plStopHunt"))
			return
		end
		veh.huntName = player.Name
		cfg.AutoRam = true
		veh.start()
		notify("Xi Pro", T("plHunt") .. " · " .. player.DisplayName)
	end
	pl.send = function()
		local player = usePlayer(selectedPlayer())
		if not (player and veh and veh.send) then
			notify("Xi Pro", T("plNeedMod"))
			return
		end
		veh.send()
	end
	pl.pin = function()
		local player = selectedPlayer()
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return
		end
		if pl.pinned[player.UserId] then
			pl.pinned[player.UserId] = nil
			notify("Xi Pro", T("plUnpinned") .. " · " .. player.Name)
		else
			pl.pinned[player.UserId] = true
			notify("Xi Pro", T("plPinned") .. " · " .. player.Name)
		end
		pl.refresh()
	end
	pl.copy = function()
		local player = selectedPlayer()
		if not player then
			notify("Xi Pro", T("tpNoPlayer"))
			return
		end
		local write = setclipboard or toclipboard or (syn and syn.write_clipboard)
		if not write then
			notify("Xi Pro", T("plNoClip"))
			return
		end
		pcall(write, player.Name)
		notify("Xi Pro", T("plCopied") .. " · @" .. player.Name)
	end
	pl.start = function()
		if pl.conn then
			return
		end
		pl.accum = 0
		pl.conn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
			tickWatch()
			pl.accum = (pl.accum or 0) + (dt or 0)
			if pl.accum >= 0.6 then
				pl.accum = 0
				paintInfo()
			end
		end))
		track(pl.conn)
	end
	pl.stop = function()
		cfg.PlrWatch = false
		st.lockPlayer = nil
		if veh then
			veh.huntName = nil
		end
		if pl.conn then
			pcall(function()
				pl.conn:Disconnect()
			end)
			pl.conn = nil
		end
	end

	track(Players.PlayerAdded:Connect(function()
		task.defer(pl.refresh)
	end))
	track(Players.PlayerRemoving:Connect(function(player)
		pl.pinned[player.UserId] = nil
		pl.nearAt[player.UserId] = nil
		if st.lockPlayer == player then
			st.lockPlayer = nil
		end
		if veh and veh.huntName == player.Name then
			veh.huntName = nil
		end
		task.defer(pl.refresh)
	end))
	pl.start()
end

local function isTyreValid(info)
	if not (info and info.part and info.part:IsA("BasePart") and info.part.Parent) then
		return false
	end
	local durability = info.part:GetAttribute("Durability")
	return durability == nil or durability > 0
end

local hasLineOfSight = LPH_NO_VIRTUALIZE(function(worldPos, ignore)
	local origin = Camera.CFrame.Position
	local delta = worldPos - origin
	local distance = delta.Magnitude
	if distance < 0.01 then
		return true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore or {}
	local hit = Workspace:Raycast(origin, delta.Unit * distance, params)
	if hit then
		return (hit.Position - origin).Magnitude >= distance - 2
	end
	return true
end)

local function getAimPartName()
	return cfg.AimAtHead and "Head" or "HumanoidRootPart"
end

local getAimPosition = LPH_NO_VIRTUALIZE(function(target, targetType)
	if targetType == "player" then
		local character = getCharacter(target)
		if not character then
			return nil
		end
		local part = character:FindFirstChild(getAimPartName())
			or character:FindFirstChild("HumanoidRootPart")
			or character:FindFirstChild("Head")
		return part and part.Position or nil
	end
	if targetType == "tyre" then
		return getTyreAimPoint(target)
	end
	return nil
end)

local isTargetStillValid = LPH_NO_VIRTUALIZE(function(target, targetType)
	if targetType == "player" then
		return isPlayerValid(target)
	end
	if targetType == "tyre" then
		return isTyreValid(target)
	end
	return false
end)

local findBestTarget = LPH_NO_VIRTUALIZE(function()
	Camera = Workspace.CurrentCamera
	if not Camera then
		return nil, nil, nil
	end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local myChar = getCharacter(LocalPlayer)
	local candidates = {}

	if cfg.TargetPlayers then
		for _, player in ipairs(Players:GetPlayers()) do
			if isPlayerValid(player) then
				local character = getCharacter(player)
				local head = character and character:FindFirstChild("Head")
				if head then
					local screen, visible = Camera:WorldToViewportPoint(head.Position)
					if visible then
						local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if dist < cfg.AimCircle then
							candidates[#candidates + 1] = {
								dist = dist,
								ttype = "player",
								target = player,
								pos = head.Position,
								char = character,
								player = player,
							}
						end
					end
				end
			end
		end
	end

	if cfg.TargetTyres then
		for _, info in ipairs(getNearbyTyres()) do
			local pos = getTyreAimPoint(info)
			local screen, visible = Camera:WorldToViewportPoint(pos)
			if visible then
				local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
				if dist < cfg.AimCircle then
					candidates[#candidates + 1] = {
						dist = dist,
						ttype = "tyre",
						target = info,
						pos = pos,
						vehicle = info.vehicle,
					}
				end
			end
		end
	end

	if #candidates == 0 then
		return nil, nil, nil
	end

	table.sort(candidates, function(a, b)
		return a.dist < b.dist
	end)

	for _, item in ipairs(candidates) do
		if not cfg.WallCheck then
			return item.target, item.ttype, item.pos
		end
		local ignore = { myChar }
		if item.ttype == "player" then
			if item.char then
				table.insert(ignore, item.char)
			end
			local vehicle = getVehicle(item.player)
			if vehicle then
				table.insert(ignore, vehicle)
			end
		elseif item.ttype == "tyre" and item.vehicle then
			table.insert(ignore, item.vehicle)
		end
		if hasLineOfSight(item.pos, ignore) then
			return item.target, item.ttype, item.pos
		end
	end

	return nil, nil, nil
end)

local getGunConfig = LPH_NO_VIRTUALIZE(function()
	local character = getCharacter(LocalPlayer)
	if not character then
		st.gunConfigInst, st.gunConfig = nil, nil
		return nil
	end
	if st.gunConfigInst and st.gunConfigInst.Parent and st.gunConfigInst:IsDescendantOf(character) then
		return st.gunConfig
	end
	if os.clock() - st.gunConfigAt < 0.25 then
		return nil
	end
	st.gunConfigAt = os.clock()
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant.Name == "Config" and descendant:FindFirstChild("Ammo") then
			if descendant ~= st.gunConfigInst then
				local ok, result = pcall(require, descendant)
				st.gunConfigInst = descendant
				st.gunConfig = ok and type(result) == "table" and result or nil
			end
			return st.gunConfig
		end
	end
	st.gunConfigInst, st.gunConfig = nil, nil
	return nil
end)

local function hasGunOut()
	return getGunConfig() ~= nil
end

local function updateAimCircle()
	local fov, show = 0, false
	if cfg.SilentAim then
		fov = cfg.SilentFov
		show = fov > 0 and (cfg.SilentAlways or hasGunOut())
	elseif cfg.ShowAimCircle and cfg.AimAssist then
		fov = cfg.AimCircle
		show = fov > 0
	end
	if show and not st.circleGui then
		st.circleGui = Instance.new("ScreenGui")
		st.circleGui.Name = "XiProAimCircle"
		st.circleGui.ResetOnSpawn = false
		st.circleGui.IgnoreGuiInset = true
		st.circleGui.DisplayOrder = 7000
		st.circleGui.Parent = getUiHost()

		st.circleFrame = Instance.new("Frame")
		st.circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		st.circleFrame.Position = UDim2.fromScale(0.5, 0.5)
		st.circleFrame.BackgroundTransparency = 1
		st.circleFrame.BorderSizePixel = 0
		st.circleFrame.Parent = st.circleGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = st.circleFrame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.new(1, 1, 1)
		stroke.Thickness = 1.5
		stroke.Transparency = 0.25
		stroke.Parent = st.circleFrame
	end
	if st.circleFrame and fov > 0 then
		st.circleFrame.Size = UDim2.fromOffset(fov * 2, fov * 2)
	end
	if st.circleGui then
		st.circleGui.Enabled = show == true
	end
end

local function getMobileFireButton()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local screenGui = playerGui and playerGui:FindFirstChild("ScreenGui")
	local right = screenGui and screenGui:FindFirstChild("Right")
	right = right and right:FindFirstChild("Bottom")
	right = right and right:FindFirstChild("Mobile")
	right = right and right:FindFirstChild("Gun")
	if not (right and right.Visible) then
		return nil
	end
	local fire = right:FindFirstChild("Fire")
	if not (fire and fire.Visible) then
		return nil
	end
	return fire
end

local function setTouchFire(down)
	local button = getMobileFireButton()
	if down and not button then
		return false
	end
	if down == st.touchDown then
		if down and button and os.clock() - st.lastTouchPulse > 0.1 then
			st.lastTouchPulse = os.clock()
			local pos = button.AbsolutePosition
			local size = button.AbsoluteSize
			pcall(function()
				VirtualInputManager:SendTouchEvent(2, 1, pos.X + size.X / 2, pos.Y + size.Y / 2)
			end)
		end
		return true
	end
	local pos = button and button.AbsolutePosition
	local size = button and button.AbsoluteSize
	local x = pos and pos.X + size.X / 2 or 0
	local y = pos and pos.Y + size.Y / 2 or 0
	local ok = pcall(function()
		VirtualInputManager:SendTouchEvent(2, down and 0 or 2, x, y)
	end)
	if ok then
		st.touchDown = down
		st.lastTouchPulse = os.clock()
	end
	return ok
end

local function mouseDown()
	if st.mouseHeld then
		return
	end
	Camera = Workspace.CurrentCamera
	local size = Camera.ViewportSize
	VirtualInputManager:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, true, game, 0)
	st.mouseHeld = true
end

local function mouseUp()
	if not st.mouseHeld then
		return
	end
	Camera = Workspace.CurrentCamera
	local size = Camera.ViewportSize
	VirtualInputManager:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, false, game, 0)
	st.mouseHeld = false
end

local function mouseClick()
	Camera = Workspace.CurrentCamera
	local size = Camera.ViewportSize
	local x, y = size.X / 2, size.Y / 2
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function findBackpackGui()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return nil
	end
	local backpack = playerGui:FindFirstChild("Backpack")
	if backpack then
		return backpack
	end
	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if descendant.Name == "Backpack" then
			return descendant
		end
	end
	return nil
end

local function cacheBackpackNames()
	local backpack = findBackpackGui()
	if not backpack then
		return
	end
	for _, descendant in ipairs(backpack:GetDescendants()) do
		if descendant:IsA("Model") then
			st.backpackNames[descendant.Name] = true
		end
	end
	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Model") then
			st.backpackNames[child.Name] = true
		end
	end
end

local function hasWeaponEquipped()
	local character = getCharacter(LocalPlayer)
	if not character then
		return false
	end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant.Name == "Config" and (descendant:FindFirstChild("TotalAmmo") or descendant:FindFirstChild("Ammo")) then
			return true
		end
	end
	cacheBackpackNames()
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Model") and st.backpackNames[child.Name] then
			return true
		end
	end
	return false
end

local function tryEquip()
	if not cfg.AutoEquip then
		return
	end
	if os.clock() - st.lastEquipAt < 1.5 then
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end
	st.lastEquipAt = os.clock()
	if hasWeaponEquipped() then
		return
	end
	local slot = math.clamp(math.floor(cfg.HotbarSlot), 1, 5)
	if IS_MOBILE then
		pcall(function()
			local bar = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
			bar = bar and bar:FindFirstChild("Center")
			bar = bar and bar:FindFirstChild("Bottom")
			bar = bar and bar:FindFirstChild("InventoryBar")
			local button = bar and bar:FindFirstChild(tostring(slot))
			if button and button.Visible then
				local pos = button.AbsolutePosition
				local size = button.AbsoluteSize
				local x = pos.X + size.X / 2
				local y = pos.Y + size.Y / 2
				VirtualInputManager:SendTouchEvent(1, 0, x, y)
				VirtualInputManager:SendTouchEvent(1, 2, x, y)
			end
		end)
		return
	end
	local key = SLOT_KEYS[slot]
	if not key then
		return
	end
	pcall(function()
		VirtualInputManager:SendKeyEvent(true, key, false, game)
		task.wait(0.03)
		VirtualInputManager:SendKeyEvent(false, key, false, game)
	end)
end

local function pointToSegment(point, a, b)
	local ab = b - a
	local len2 = ab:Dot(ab)
	if len2 < 0.0001 then
		return (point - a).Magnitude
	end
	local t = math.clamp((point - a):Dot(ab) / len2, 0, 1)
	return (point - (a + ab * t)).Magnitude
end

local function recordIncomingShot(player, pos)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or player == LocalPlayer then
		return
	end
	if typeof(pos) ~= "Vector3" then
		pos = nil
	end
	table.insert(st.incomingShots, { plr = player, pos = pos, t = os.clock() })
	while #st.incomingShots > 40 do
		table.remove(st.incomingShots, 1)
	end
end

local function findAttacker()
	local myChar = getCharacter(LocalPlayer)
	local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local origin = root.Position
	local now = os.clock()
	local best, bestScore
	for i = #st.incomingShots, 1, -1 do
		local shot = st.incomingShots[i]
		if now - shot.t > 0.7 then
			break
		end
		local attacker = shot.plr
		if attacker and attacker.Parent and attacker ~= LocalPlayer and not shouldSkipPlayer(attacker) then
			local theirRoot = getCharacter(attacker)
			theirRoot = theirRoot and theirRoot:FindFirstChild("HumanoidRootPart")
			local dist
			if theirRoot and shot.pos then
				dist = pointToSegment(origin, theirRoot.Position, shot.pos)
			elseif shot.pos then
				dist = (origin - shot.pos).Magnitude
			elseif theirRoot then
				dist = (origin - theirRoot.Position).Magnitude
			end
			if dist and dist <= 14 then
				local score = dist + (now - shot.t) * 4
				if not bestScore or score < bestScore then
					bestScore = score
					best = attacker
				end
			end
		end
	end
	return best
end

setAutoShootState = function(value)
	cfg.AutoShoot = value and true or false
	if not cfg.AutoShoot then
		stopFiring()
	end
	st.syncingToggle = true
	pcall(function()
		if st.autoShootToggle and st.autoShootToggle.Set then
			st.autoShootToggle:Set(value)
		elseif st.autoShootToggle and st.autoShootToggle.SetValue then
			st.autoShootToggle:SetValue(value)
		end
	end)
	st.syncingToggle = false
end

stopDefense = function()
	if not st.defenseTarget and st.defenseUntil <= 0 then
		return
	end
	st.defenseUntil = 0
	st.defenseStarted = 0
	if st.defenseTarget then
		st.defenseTarget = nil
	end
	if st.defenseSavedShoot ~= nil then
		setAutoShootState(st.defenseSavedShoot)
		st.defenseSavedShoot = nil
	end
	if st.defenseOwnedAim then
		st.defenseOwnedAim = false
		setAimAssist(false)
		st.syncingToggle = true
		pcall(function()
			if st.aimToggle and st.aimToggle.Set then
				st.aimToggle:Set(false)
			elseif st.aimToggle and st.aimToggle.SetValue then
				st.aimToggle:SetValue(false)
			end
		end)
		st.syncingToggle = false
	end
end

startDefense = function(player)
	if not cfg.Defense or not player then
		return
	end
	if st.defenseTarget and st.defenseTarget ~= player then
		return
	end
	local now = os.clock()
	if st.defenseTarget and st.defenseTarget.Parent and isPlayerValid(st.defenseTarget, math.huge) then
		st.defenseUntil = now + cfg.RetaliateFor
		return
	end
	if not isPlayerValid(player, math.huge) then
		return
	end
	if st.defenseSavedShoot == nil then
		st.defenseSavedShoot = cfg.AutoShoot
	end
	st.defenseTarget = player
	st.defenseUntil = now + cfg.RetaliateFor
	st.defenseStarted = now
	if cfg.SilentAim then
		if cfg.DefenseAutoFire then
			st.silentAutoTarget = player
			st.silentAutoCount = 0
		end
	else
		if not cfg.AimAssist then
			st.defenseOwnedAim = true
			setAimAssist(true)
			st.syncingToggle = true
			pcall(function()
				if st.aimToggle and st.aimToggle.Set then
					st.aimToggle:Set(true)
				elseif st.aimToggle and st.aimToggle.SetValue then
					st.aimToggle:SetValue(true)
				end
			end)
			st.syncingToggle = false
		end
		if cfg.DefenseAutoFire then
			setAutoShootState(true)
		end
	end
	pcall(tryEquip)
	notify("Xi Pro", T("defending") .. " " .. (player.DisplayName or player.Name))
end

local function isAutomaticGun()
	local config = getGunConfig()
	return config ~= nil and tonumber(config.SHOOT_MODE) == 2
end

local getRootPosition = LPH_NO_VIRTUALIZE(function(player)
	local character = getCharacter(player)
	local root = getRootPart(character)
	if root then
		return root.Position
	end
	local attribute = player:GetAttribute("CharacterPosition")
	return typeof(attribute) == "Vector3" and attribute or nil
end)

local getHeadPosition = LPH_NO_VIRTUALIZE(function(player)
	local character = getCharacter(player)
	local head = character and character:FindFirstChild("Head")
	if head then
		return head.Position
	end
	local root = getRootPosition(player)
	return root and root + Vector3.new(0, 2.5, 0) or nil
end)

local isSilentValid = LPH_NO_VIRTUALIZE(function(player)
	if not player or player == LocalPlayer then
		return false
	end
	if shouldSkipPlayer(player) then
		return false
	end
	if cfg.SilentCombat and not st.skipCombatOnce and player:GetAttribute("CombatMode") ~= true then
		return false
	end
	local character = getCharacter(player)
	if character then
		if character:GetAttribute("IsDead") == true then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			return false
		end
	end
	local pos = getRootPosition(player)
	if not pos then
		return false
	end
	local myPos = getRootPosition(LocalPlayer)
	if myPos and (pos - myPos).Magnitude > cfg.SilentRange then
		return false
	end
	return true
end)

local pickSilentTarget = LPH_NO_VIRTUALIZE(function()
	if st.defenseTarget and os.clock() < st.defenseUntil then
		st.skipCombatOnce = true
		local ok = isSilentValid(st.defenseTarget)
		st.skipCombatOnce = false
		if ok then
			return st.defenseTarget
		end
	end
	if st.lockPlayer and st.lockPlayer.Parent and isSilentValid(st.lockPlayer) then
		return st.lockPlayer
	end
	if st.silentAutoTarget and st.silentAutoTarget.Parent and cfg.SilentAutoFire and isSilentValid(st.silentAutoTarget) then
		return st.silentAutoTarget
	end
	if cfg.SilentFov <= 0 then
		return nil
	end
	Camera = Workspace.CurrentCamera
	if not Camera then
		return nil
	end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local bestDist, best
	for _, player in ipairs(Players:GetPlayers()) do
		if isSilentValid(player) then
			local headPos = getHeadPosition(player)
			if headPos then
				local screen, visible = Camera:WorldToViewportPoint(headPos)
				if visible then
					local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if dist <= cfg.SilentFov and (not bestDist or dist < bestDist) then
						bestDist = dist
						best = player
					end
				end
			end
		end
	end
	return best
end)

local function resolvePlayerEvent()
	if st.playerEvent and st.playerEvent.Parent then
		return st.playerEvent
	end
	local remote = getRemoteFolder()
	local event = remote and remote:FindFirstChild("PlayerEvent")
	if event then
		st.playerEvent = event
	end
	return st.playerEvent
end

local function resolveHeadPart()
	if st.headPartResolved and (st.headPartId or next(st.bodyPartIds)) then
		return
	end
	pcall(function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local rules = modules and modules:FindFirstChild("GameRules")
		if not rules then
			return
		end
		local ok, result = pcall(require, rules)
		if ok and type(result) == "table" and type(result.characterMeshesToBodyParts) == "table" then
			for name, id in pairs(result.characterMeshesToBodyParts) do
				st.bodyPartIds[name] = id
			end
			st.headPartId = st.bodyPartIds.Head or result.characterMeshesToBodyParts.Head
			st.headPartResolved = true
		end
	end)
end

local function auraPassesLock(player)
	if cfg.AuraPolice then
		return player.Team ~= nil and player.Team.Name == "Police"
	end
	if cfg.AuraCivilian then
		return player.Team ~= nil and player.Team.Name == "Civilian"
	end
	return true
end

local tickKillAura = LPH_NO_VIRTUALIZE(function()
	if not cfg.KillAura or not resolvePlayerEvent() then
		return
	end
	local now = os.clock()
	if st.auraIdleUntil > now then
		return
	end
	local interval = math.max(0.01, tonumber(cfg.AuraInterval) or 0.05)
	if now - st.auraClock < interval then
		return
	end
	local myRoot = getRootPart(getCharacter(LocalPlayer))
	if not myRoot then
		st.auraIdleUntil = now + 0.35
		return
	end
	if not next(st.bodyPartIds) then
		resolveHeadPart()
	end
	local best, bestDist
	local range = tonumber(cfg.AuraRange) or 50
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer
			and not cfg.Whitelist[player.Name]
			and auraPassesLock(player)
			and (not cfg.AuraCombat or player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true)
		then
			local character = getCharacter(player)
			if not character or character:GetAttribute("IsDead") == true then
				continue
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not (humanoid and humanoid.Health > 0) then
				continue
			end
			local part = character:FindFirstChild("Head") or getRootPart(character)
			if not part then
				continue
			end
			local dist = (part.Position - myRoot.Position).Magnitude
			if dist <= range and (not bestDist or dist < bestDist) then
				best = player
				bestDist = dist
			end
		end
	end
	if not best then
		st.auraIdleUntil = now + 0.4
		return
	end
	st.auraIdleUntil = 0
	st.auraClock = now
	local character = getCharacter(best)
	local part = character and (character:FindFirstChild("Head") or getRootPart(character))
	if not part then
		return
	end
	local pos = part.Position
	local partId = st.headPartId or "Head"
	pcall(function()
		st.playerEvent:FireServer("damage", {
			bodyParts = { { partId, 1 } },
			shotCode = { myRoot.Position, (pos - myRoot.Position).Unit },
			pos = pos,
			target = best,
			damageFactor = tonumber(cfg.AuraDamage) or 5,
			bulletProofTool = false,
		})
	end)
end)

local function silentFireAt(player, count)
	if not resolvePlayerEvent() or not player then
		return
	end
	local headPos = getHeadPosition(player)
	local character = getCharacter(LocalPlayer)
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	if not (headPos and root) then
		return
	end
	count = math.max(1, tonumber(count) or 1)
	for _ = 1, count do
		local pos = headPos + Vector3.new((math.random() - 0.5) * 1.5, (math.random() - 0.5) * 1.5, (math.random() - 0.5) * 1.5)
		pcall(function()
			st.playerEvent:FireServer("damage", {
				target = player,
				bodyParts = st.headPartId and { { st.headPartId, 1 } } or nil,
				shotCode = { root.Position, (pos - root.Position).Unit },
				pos = pos,
				damageFactor = 1.5,
			})
		end)
	end
end

local function ragePartLabels()
	local list = {}
	for _, key in ipairs(RAGE_PART_ORDER or {}) do
		list[#list + 1] = T((RAGE_PART_LOCALE or {})[key] or key)
	end
	if #list == 0 then
		list[1] = T("rageHead")
	end
	return list
end

local function ragePartFromLabel(label)
	for _, key in ipairs(RAGE_PART_ORDER or {}) do
		if label == key or label == T((RAGE_PART_LOCALE or {})[key]) then
			return key
		end
	end
	return cfg.RageBodyPart or "Head"
end

local function refreshRagePartUi()
	local labels = ragePartLabels()
	pcall(function()
		if st.ragePartDropdown and st.ragePartDropdown.Refresh then
			st.ragePartDropdown:Refresh(labels)
		elseif st.ragePartDropdown and st.ragePartDropdown.SetValues then
			st.ragePartDropdown:SetValues(labels)
		end
	end)
end

local function findRagePart(character, partName)
	if not character then
		return nil
	end
	local names = RAGE_PART_ALIASES[partName] or { "Head" }
	for _, name in ipairs(names) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end

local function rageJobOf(player)
	return player and player.Team and player.Team.Name or "Civilian"
end

local function ragePassesLock(player)
	if cfg.RagePoliceLock then
		return player.Team ~= nil and player.Team.Name == "Police"
	end
	if cfg.RageCivilianLock then
		return player.Team ~= nil and player.Team.Name == "Civilian"
	end
	return true
end

local function ragePassesCombat(player)
	if not cfg.RageCombatCheck then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end

local rageWallLos = RaycastParams.new()
rageWallLos.FilterType = Enum.RaycastFilterType.Exclude
rageWallLos.IgnoreWater = true
local rageWallFree = RaycastParams.new()
rageWallFree.FilterType = Enum.RaycastFilterType.Exclude

local function rageLosBlocked(from, to, character)
	local delta = to - from
	if delta.Magnitude < 0.05 then
		return false
	end
	local filter = { getCharacter(LocalPlayer), character, Workspace.CurrentCamera }
	local origin, left = from, delta
	for _ = 1, 6 do
		rageWallLos.FilterDescendantsInstances = filter
		local hit = Workspace:Raycast(origin, left, rageWallLos)
		if not hit then
			return false
		end
		local inst = hit.Instance
		local tr = inst and inst.Transparency
		if inst and ((type(tr) == "number" and tr >= 0.9) or inst.CanCollide == false or inst.CanQuery == false) then
			filter[#filter + 1] = inst
		else
			return true, hit.Position, inst
		end
		origin = hit.Position + delta.Unit * 0.05
		left = to - origin
	end
	return false
end

local function rageLosClear(from, to, character)
	return not rageLosBlocked(from, to, character)
end

local function rageWallIsFree(p, character)
	rageWallFree.FilterDescendantsInstances = { getCharacter(LocalPlayer), character, Workspace.CurrentCamera }
	local list = Workspace:GetPartBoundsInRadius(p, 0.8, rageWallFree)
	for i = 1, #list do
		local v = list[i]
		local tr = v.Transparency
		if v.CanCollide ~= false and not (type(tr) == "number" and tr >= 0.9) then
			return false
		end
	end
	return true
end

local function rageWallProbeRoom(base, character)
	local f = Vector3.new(0, 0, -1)
	Camera = Workspace.CurrentCamera
	if Camera then
		local flat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
		if flat.Magnitude > 0.01 then
			f = flat.Unit
		end
	end
	local right = f:Cross(Vector3.new(0, 1, 0))
	if right.Magnitude < 0.01 then
		right = Vector3.new(1, 0, 0)
	else
		right = right.Unit
	end
	local function reach(dir, maxD)
		rageWallLos.FilterDescendantsInstances = { getCharacter(LocalPlayer), character, Workspace.CurrentCamera }
		local hit = Workspace:Raycast(base + dir * 0.6, dir * maxD, rageWallLos)
		if hit then
			return math.max((hit.Position - base).Magnitude - 1, 0)
		end
		return maxD
	end
	return {
		up = reach(Vector3.new(0, 1, 0), 26),
		down = reach(Vector3.new(0, -1, 0), 26),
		right = reach(right, 20),
		left = reach(-right, 20),
		fwd = reach(f, 26),
		back = reach(-f, 20),
	}
end

local function rageWallBuildCands(base, aim, hitPos, hitInst, room)
	local out = {}
	local f = aim - base
	if f.Magnitude < 0.1 then
		return out
	end
	f = f.Unit
	local flat = Vector3.new(f.X, 0, f.Z)
	if flat.Magnitude < 0.01 then
		flat = Vector3.new(0, 0, -1)
	else
		flat = flat.Unit
	end
	local right = flat:Cross(Vector3.new(0, 1, 0))
	if right.Magnitude < 0.01 then
		right = Vector3.new(1, 0, 0)
	else
		right = right.Unit
	end
	local up = Vector3.new(0, 1, 0)
	local wallR = 14
	room = room or { up = 26, down = 26, right = 20, left = 20, fwd = 26, back = 20 }
	if hitPos and hitInst and hitInst:IsA("BasePart") then
		local top = hitInst.Position.Y + hitInst.Size.Y * 0.5 + 1
		if (top - base.Y) <= room.up then
			local near = hitPos - f * 0.6
			out[#out + 1] = Vector3.new(near.X, top, near.Z) - base
			out[#out + 1] = Vector3.new(near.X, top + 1.5, near.Z) - base
		end
	end
	for _, r in ipairs({ 2, 3.5, 5, 7, 9, 12 }) do
		for _, s in ipairs({ 1, -1 }) do
			local lim = s > 0 and room.right or room.left
			if r <= lim and r <= wallR then
				out[#out + 1] = right * (r * s)
			end
		end
		if r <= room.up and r <= wallR then
			out[#out + 1] = up * r
		end
		if r <= room.fwd and r <= wallR then
			out[#out + 1] = f * r
		end
		if r <= room.back * 0.7 and r <= wallR then
			out[#out + 1] = f * -r
		end
	end
	return out
end

local function rageResolveWallStart(base, aim, part, character)
	if not part or not character then
		return base
	end
	if rageLosClear(base, aim, character) then
		return base
	end
	if not cfg.RageWallbang or cfg.RageWallCheck then
		return nil
	end
	local blocked, hitPos, hitInst = rageLosBlocked(base, aim, character)
	if not blocked then
		return base
	end
	local room = rageWallProbeRoom(base, character)
	local list = rageWallBuildCands(base, aim, hitPos, hitInst, room)
	local relaxed
	for i = 1, math.min(#list, 96) do
		local p = base + list[i]
		if (p - base).Magnitude <= 24 and rageWallIsFree(p, character) and rageLosClear(p, aim, character) then
			if rageLosClear(base, p, character) then
				return p
			end
			relaxed = relaxed or p
		end
	end
	return relaxed
end

local function rageCanSee(character, part)
	if not cfg.RageWallCheck then
		if cfg.RageWallbang then
			local base = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or part.Position
			return rageResolveWallStart(base, part.Position, part, character) ~= nil
		end
		return true
	end
	Camera = Workspace.CurrentCamera
	if not (Camera and character and part) then
		return false
	end
	local origin = Camera.CFrame.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { getCharacter(LocalPlayer), Camera }
	local hit = Workspace:Raycast(origin, part.Position - origin, params)
	return not hit or hit.Instance:IsDescendantOf(character)
end

local function spawnRageBeam(fromPos, toPos, bendCorner)
	task.spawn(function()
		local function segment(st, ed)
			local p1 = Instance.new("Part")
			p1.Anchored, p1.CanCollide, p1.Transparency = true, false, 1
			p1.Size, p1.Position, p1.Parent = Vector3.new(0.1, 0.1, 0.1), st, Workspace
			local p2 = Instance.new("Part")
			p2.Anchored, p2.CanCollide, p2.Transparency = true, false, 1
			p2.Size, p2.Position, p2.Parent = Vector3.new(0.1, 0.1, 0.1), ed, Workspace
			local at1, at2 = Instance.new("Attachment", p1), Instance.new("Attachment", p2)
			local bm1 = Instance.new("Beam")
			bm1.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 0, 130)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 112)),
			})
			bm1.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.1),
				NumberSequenceKeypoint.new(1, 0.3),
			})
			bm1.Width0, bm1.Width1 = 0.6, 0.6
			bm1.Texture, bm1.TextureSpeed = "rbxassetid://446111271", 1.5
			bm1.TextureMode, bm1.TextureLength, bm1.Brightness, bm1.LightEmission = Enum.TextureMode.Wrap, 2, 2, 0.4
			bm1.FaceCamera, bm1.Attachment0, bm1.Attachment1, bm1.Parent = true, at1, at2, p1
			local bm2 = Instance.new("Beam")
			bm2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 130, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 180, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255)),
			})
			bm2.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.5, 0.4),
				NumberSequenceKeypoint.new(1, 0.7),
			})
			bm2.Width0, bm2.Width1 = 0.25, 0.25
			bm2.Texture, bm2.TextureSpeed = "rbxassetid://446111271", 2.2
			bm2.TextureMode, bm2.TextureLength, bm2.Brightness, bm2.LightEmission = Enum.TextureMode.Wrap, 1.5, 3, 1
			bm2.FaceCamera, bm2.Attachment0, bm2.Attachment1, bm2.Parent = true, at1, at2, p1
			task.delay(math.random(8, 18) / 10, function()
				for i = 0, 1, 0.08 do
					if not p1.Parent then
						break
					end
					bm1.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, i * 0.6),
						NumberSequenceKeypoint.new(0.5, 0.1 + i * 0.5),
						NumberSequenceKeypoint.new(1, 0.3 + i * 0.7),
					})
					bm2.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2 + i * 0.6),
						NumberSequenceKeypoint.new(0.5, 0.4 + i * 0.5),
						NumberSequenceKeypoint.new(1, 0.7 + i * 0.3),
					})
					task.wait(0.02)
				end
				pcall(function()
					p1:Destroy()
				end)
			end)
		end
		if bendCorner then
			segment(fromPos, bendCorner)
			segment(bendCorner, toPos)
		else
			segment(fromPos, toPos)
		end
	end)
end

local function rageShotOrigin(character, part, myRoot)
	Camera = Workspace.CurrentCamera
	local base = (Camera and Camera.CFrame.Position) or (myRoot and (myRoot.Position + Vector3.new(0, 1.5, 0)))
	if not base then
		return nil
	end
	if cfg.RageWallCheck then
		if not rageCanSee(character, part) then
			return nil
		end
		return base
	end
	return rageResolveWallStart(base, part.Position, part, character) or base
end

local function setLockToggle(toggle, value)
	st.syncingToggle = true
	pcall(function()
		if toggle and toggle.Set then
			toggle:Set(value)
		elseif toggle and toggle.SetValue then
			toggle:SetValue(value)
		end
	end)
	st.syncingToggle = false
end

local function tickRagebot()
	if not cfg.Ragebot or not resolvePlayerEvent() then
		return false
	end
	if not next(st.bodyPartIds) then
		resolveHeadPart()
	end
	local myChar = getCharacter(LocalPlayer)
	local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
	if not myRoot then
		return false
	end
	local origin = myRoot.Position
	local myJob = rageJobOf(LocalPlayer)
	local partName = cfg.RageBodyPart or "Head"
	local partId = st.bodyPartIds[partName] or partName
	local hit = false
	pcall(tryEquip)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer
			and not shouldSkipPlayer(player)
			and ragePassesLock(player)
			and ragePassesCombat(player)
			and not (cfg.RageJobCheck and rageJobOf(player) == myJob)
		then
			local character = getCharacter(player)
			if not character then
				continue
			end
			if cfg.RageAliveCheck and character:GetAttribute("IsDead") == true then
				continue
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not (humanoid and humanoid.Health > 0) then
				continue
			end
			local part = findRagePart(character, partName)
			if part and (part.Position - origin).Magnitude <= cfg.RageRange then
				local shotFrom = rageShotOrigin(character, part, myRoot)
				if not shotFrom then
					continue
				end
				hit = true
				pcall(function()
					st.playerEvent:FireServer("damage", {
						bodyParts = { { partId, 1 } },
						shotCode = { shotFrom, (part.Position - shotFrom).Unit },
						pos = part.Position,
						target = player,
						damageFactor = 1.5,
						bulletProofTool = false,
					})
				end)
				if cfg.RageBeam then
					Camera = Workspace.CurrentCamera
					local viewFrom = (Camera and Camera.CFrame.Position) or origin
					local bend = (shotFrom - viewFrom).Magnitude > 1.5 and shotFrom or nil
					spawnRageBeam(viewFrom, part.Position, bend)
				end
			end
		end
	end
	return hit
end

task.spawn(function()
	while st.rageRunning do
		if cfg.Ragebot then
			local ok, hit = pcall(tickRagebot)
			if ok and hit then
				task.wait(math.max(0.01, tonumber(cfg.RageInterval) or 0.05))
			else
				task.wait(0.4)
			end
		else
			task.wait(0.25)
		end
	end
end)

local function teleportShot(player, count)
	local character = getCharacter(LocalPlayer)
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local headPos = getHeadPosition(player)
	if not (root and headPos) then
		silentFireAt(player, count)
		return
	end
	local far = (headPos - root.Position).Magnitude > 500
	if not (cfg.SilentTp and far) then
		silentFireAt(player, count)
		return
	end
	if st.tpBusy and os.clock() - st.tpAt < 4 then
		return
	end
	st.tpBusy = true
	st.tpAt = os.clock()
	task.spawn(function()
		local ok, origin = pcall(function()
			return root.CFrame
		end)
		if not ok then
			st.tpBusy = false
			return
		end
		local function restore()
			for _ = 1, 10 do
				if not (root and root.Parent) then
					return
				end
				pcall(function()
					root.CFrame = origin
				end)
				RunService.Heartbeat:Wait()
				local okClose, close = pcall(function()
					return (root.Position - origin.Position).Magnitude < 4
				end)
				if okClose and close then
					return
				end
			end
		end
		local shotOk, err = pcall(function()
			local function blinkTo(pos)
				pcall(function()
					root.CFrame = CFrame.new(pos - Vector3.new(0, 250, 0), pos)
				end)
			end
			pcall(function()
				LocalPlayer:RequestStreamAroundAsync(headPos, 5)
			end)
			local deadline = os.clock() + 1.5
			local streamedHead
			while os.clock() < deadline and root and root.Parent do
				local targetChar = getCharacter(player)
				streamedHead = targetChar and targetChar:FindFirstChild("Head")
				if streamedHead then
					break
				end
				RunService.Heartbeat:Wait()
			end
			if not streamedHead and IS_MOBILE then
				return
			end
			local aimAt = streamedHead and streamedHead.Position or headPos
			local holdUntil = os.clock() + 1.2
			while root and root.Parent do
				blinkTo(aimAt)
				RunService.Heartbeat:Wait()
				local attribute = LocalPlayer:GetAttribute("CharacterPosition")
				local streamed = typeof(attribute) == "Vector3" and attribute
					or typeof(attribute) == "CFrame" and attribute.Position
				if streamed and (root.Position - streamed).Magnitude < 60 then
					break
				end
				if os.clock() >= holdUntil then
					break
				end
			end
			silentFireAt(player, count)
			local waitUntil = os.clock() + 0.15
			repeat
				RunService.Heartbeat:Wait()
			until os.clock() >= waitUntil
		end)
		restore()
		st.tpBusy = false
		if not shotOk then
			warn("[Xi Pro] Teleport Shot aborted: " .. tostring(err))
		end
	end)
end

ensureSilentHook = function()
	resolvePlayerEvent()
	resolveHeadPart()
	if st.silentHooked or not hookmetamethod or not getnamecallmethod then
		return
	end
	local ok = pcall(function()
		local old
		old = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
			local method = getnamecallmethod()
			if ghost.on and st.ghostDesyncPos and self == LocalPlayer then
				if method == "GetAttribute" and (...) == "CharacterPosition" then
					return st.ghostDesyncPos
				end
			end
			if method == "FireServer" then
				local first = ...
				if cfg.CombatBlock and first == "combatMode" then
					return
				end
				if st.playerEvent and self == st.playerEvent then
					if cfg.NoDamage and first == "takeDamage" then
						return
					end
					if cfg.SilentAim and first == "bullet" then
						st.silentSeq += 1
					end
				end
			end
			return old(self, ...)
		end))
	end)
	st.silentHooked = ok and true or false
	if not st.silentHooked and ghost.on then
		notify("Xi Pro", T("godNeedHook"))
	end
end

task.spawn(function()
	resolvePlayerEvent()
	resolveHeadPart()
end)

local SMOOTH = 0.135
local OFFSET = 0.025

local function fireInterval()
	return 1 / math.max(1, cfg.FireRate)
end

local function shotWouldConnect(target, targetType)
	if targetType ~= "player" then
		return true
	end
	local targetChar = getCharacter(target)
	if not targetChar then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = { getCharacter(LocalPlayer) }
	local myVehicle = getVehicle(LocalPlayer)
	if myVehicle then
		table.insert(ignore, myVehicle)
	end
	params.FilterDescendantsInstances = ignore
	local hit = Workspace:Raycast(
		Camera.CFrame.Position,
		Camera.CFrame.LookVector * (cfg.MaxDistance + 50),
		params
	)
	return hit ~= nil and hit.Instance:IsDescendantOf(targetChar)
end

stopFiring = function()
	mouseUp()
	if st.touchDown then
		setTouchFire(false)
	end
end

local stepAim = LPH_NO_VIRTUALIZE(function(dt)
	dt = dt or 0
	st.fireClock += dt
	Camera = Workspace.CurrentCamera
	if not cfg.AimAssist or not Camera then
		st.currentTarget, st.currentType = nil, nil
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end

	local myChar = getCharacter(LocalPlayer)
	local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
	if not myChar or (humanoid and humanoid.Health <= 0) then
		st.currentTarget, st.currentType = nil, nil
		stopFiring()
		return
	end

	local forced = false
	if st.defenseTarget and os.clock() < st.defenseUntil then
		if st.defenseTarget.Parent and isPlayerValid(st.defenseTarget, math.huge) then
			st.currentTarget, st.currentType = st.defenseTarget, "player"
			forced = true
		end
	end
	if not forced and st.lockPlayer and st.lockPlayer.Parent and isPlayerValid(st.lockPlayer, math.huge) then
		st.currentTarget, st.currentType = st.lockPlayer, "player"
		forced = true
	end

	st.rescanClock += dt
	local shouldRescan = st.rescanClock >= 0.05
	if not forced and (not st.currentTarget or not isTargetStillValid(st.currentTarget, st.currentType)) then
		if shouldRescan then
			st.rescanClock = 0
			st.currentTarget, st.currentType = findBestTarget()
			shouldRescan = false
		end
	end
	if not st.currentTarget then
		stopFiring()
		return
	end

	local aimPos = getAimPosition(st.currentTarget, st.currentType)
	if not aimPos then
		st.currentTarget, st.currentType = nil, nil
		return
	end

	local screen, onScreen = Camera:WorldToViewportPoint(aimPos)
	if not onScreen and not forced then
		if shouldRescan then
			st.rescanClock = 0
			st.currentTarget, st.currentType = findBestTarget()
		end
		return
	end

	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local screenDist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
	if not forced and screenDist > cfg.AimCircle then
		st.currentTarget, st.currentType = nil, nil
		return
	end

	local ignore = { myChar }
	if st.currentType == "player" then
		local targetChar = getCharacter(st.currentTarget)
		if targetChar then
			table.insert(ignore, targetChar)
		end
		local vehicle = getVehicle(st.currentTarget)
		if vehicle then
			table.insert(ignore, vehicle)
		end
	elseif st.currentType == "tyre" and st.currentTarget.vehicle then
		table.insert(ignore, st.currentTarget.vehicle)
	end

	local visible = not cfg.WallCheck or hasLineOfSight(aimPos, ignore)
	if not visible and not forced then
		st.currentTarget, st.currentType = nil, nil
		return
	end

	local tNorm = math.clamp(screenDist / math.max(cfg.AimCircle, 1), 0, 1)
	local now = tick()
	local speed = SMOOTH * (0.6 + 0.4 * tNorm ^ 0.8)
	speed *= 0.85 + 0.3 * math.sin(now * 0.7 + math.random() * 2)
	local humanize = cfg.Humanization / 100
	local camPos = Camera.CFrame.Position
	local right = Camera.CFrame.RightVector
	local up = Camera.CFrame.UpVector
	local k = math.atan2(aimPos.Y - camPos.Y, aimPos.X - camPos.X) * 0.5
	local jittered = aimPos
		+ (right * math.cos(k) + up * math.sin(k)) * OFFSET * math.max(0, 1 - tNorm * 1.2) * 0.5 * humanize
		+ Vector3.new(math.sin(now * 13) * 3e-4, math.cos(now * 17) * 3e-4, math.sin(now * 11) * 1e-4)
			* humanize
			* (0.5 + 0.5 * math.sin(now * 0.3))
	local look = CFrame.lookAt(camPos, jittered)
	local alpha = speed * (1 + 0.15 * math.sin(now * 4) * humanize)
	alpha = math.clamp(alpha + (1 - humanize) * 0.45, 0, 0.95)
	Camera.CFrame = Camera.CFrame:Lerp(look, alpha)

	local toTarget = aimPos - camPos
	local inCone = false
	if toTarget.Magnitude > 0.01 then
		local dot = math.clamp(Camera.CFrame.LookVector:Dot(toTarget.Unit), -1, 1)
		inCone = math.deg(math.acos(dot)) <= cfg.FireCone
	end
	if inCone and cfg.VerifyShot and st.currentType == "player" then
		inCone = shotWouldConnect(st.currentTarget, st.currentType)
	end

	local canFire = cfg.AutoShoot and visible and inCone and not UserInputService:GetFocusedTextBox()
	if canFire then
		pcall(tryEquip)
	end
	if not canFire then
		stopFiring()
		return
	end

	if IS_MOBILE and cfg.FireRealGun then
		if isAutomaticGun() then
			setTouchFire(true)
		elseif st.touchDown then
			if os.clock() - st.lastTouchPulse > 0.08 then
				setTouchFire(false)
			end
		elseif st.fireClock >= fireInterval() then
			st.fireClock = 0
			setTouchFire(true)
		end
	elseif isAutomaticGun() then
		mouseDown()
	else
		mouseUp()
		if st.fireClock >= fireInterval() then
			st.fireClock = 0
			mouseClick()
		end
	end
end)

setSilentAim = function(enabled)
	cfg.SilentAim = enabled and true or false
	if cfg.SilentAim then
		ensureSilentHook()
		if cfg.AimAssist then
			setAimAssist(false)
			st.syncingToggle = true
			pcall(function()
				if st.aimToggle and st.aimToggle.Set then
					st.aimToggle:Set(false)
				elseif st.aimToggle and st.aimToggle.SetValue then
					st.aimToggle:SetValue(false)
				end
			end)
			st.syncingToggle = false
			notify("Xi Pro", T("silentReplacesAim"))
		end
	else
		st.silentAutoTarget = nil
		st.silentAutoCount = 0
	end
	updateAimCircle()
end

setAimAssist = function(enabled)
	cfg.AimAssist = enabled and true or false
	if cfg.AimAssist then
		if cfg.SilentAim then
			cfg.SilentAim = false
			st.silentAutoTarget = nil
			pcall(function()
				if st.silentToggle and st.silentToggle.Set then
					st.silentToggle:Set(false)
				elseif st.silentToggle and st.silentToggle.SetValue then
					st.silentToggle:SetValue(false)
				end
			end)
		end
		if not st.renderConn then
			st.renderConn = RunService.RenderStepped:Connect(stepAim)
			track(st.renderConn)
		end
	else
		st.currentTarget, st.currentType = nil, nil
		stopFiring()
	end
	updateAimCircle()
end

local function buildUi()
local InfoTab = Window:Tab({
	Title = T("tabInfo"),
	Icon = safeIcon("sparkles"),
})

local AimTab = Window:Tab({
	Title = T("tabAim"),
	Icon = safeIcon("crosshair"),
})

local PlayerTab = Window:Tab({
	Title = T("tabPlayer"),
	Icon = safeIcon("user"),
})

local PoliceTab = Window:Tab({
	Title = T("tabPolice"),
	Icon = safeIcon("shield"),
})

local CombatTab = Window:Tab({
	Title = T("tabCombat"),
	Icon = safeIcon("swords"),
})

local MoneyTab = Window:Tab({
	Title = T("tabMoney"),
	Icon = safeIcon("heart"),
})

local VehicleTab = Window:Tab({
	Title = T("tabVehicle"),
	Icon = safeIcon("car"),
})

local EspTab = Window:Tab({
	Title = T("tabEsp"),
	Icon = safeIcon("eye"),
})

local TeleportTab = Window:Tab({
	Title = T("tabTeleport"),
	Icon = safeIcon("navigation"),
})

local ShopTab = Window:Tab({
	Title = T("tabShop"),
	Icon = safeIcon("shopping-bag"),
})

local PlayersTab = Window:Tab({
	Title = T("tabPlayers"),
	Icon = safeIcon("users"),
})

local SettingsTab = Window:Tab({
	Title = T("tabSettings"),
	Icon = safeIcon("settings"),
})

local aimSection = AimTab:Section({ Title = T("sectionAim") })
bind(aimSection, "sectionAim")
bind(InfoTab, "tabInfo")
bind(AimTab, "tabAim")
bind(PlayerTab, "tabPlayer")
bind(PoliceTab, "tabPolice")
bind(CombatTab, "tabCombat")
bind(MoneyTab, "tabMoney")
bind(VehicleTab, "tabVehicle")
bind(EspTab, "tabEsp")
bind(TeleportTab, "tabTeleport")
bind(ShopTab, "tabShop")
bind(PlayersTab, "tabPlayers")
bind(SettingsTab, "tabSettings")

local function applyInfoVisuals()
	pcall(function()
		if st.infoHero and st.infoHero.SetTitle then
			st.infoHero:SetTitle(GetTextGradient(T("infoHero"), Color3.fromHex("#00DBDE"), Color3.fromHex("#FC00FF")))
		end
	end)
	pcall(function()
		if st.infoCrush and st.infoCrush.SetTitle then
			st.infoCrush:SetTitle(GetTextGradient(T("infoCrush"), Color3.fromHex("#FFB347"), Color3.fromHex("#FF4D4D")))
		end
	end)
	pcall(function()
		if st.infoCardTitle then
			st.infoCardTitle.Text = T("infoHero")
		end
		if st.infoCardSlogan then
			st.infoCardSlogan.Text = T("infoCrush")
		end
		if st.infoCardAuthor then
			st.infoCardAuthor.Text = T("infoAuthor") .. "  ·  " .. T("infoAuthorDesc")
		end
		if st.infoCardSaint then
			st.infoCardSaint.Text = T("infoSaint") .. "  ·  " .. T("infoSaintDesc")
		end
		if st.infoCardRule then
			st.infoCardRule.Text = T("infoFree") .. "    ·    " .. T("infoNoSell")
		end
	end)
end

local function applyLanguage()
	for _, item in ipairs(labeled) do
		setElementText(item.el, T(item.title), item.desc and T(item.desc) or nil)
	end
	pcall(refreshRagePartUi)
	pcall(applyInfoVisuals)
end

bind(InfoTab:Section({ Title = T("sectionInfoHero") }), "sectionInfoHero")

st.infoHero = InfoTab:Paragraph({
	Title = GetTextGradient(T("infoHero"), Color3.fromHex("#00DBDE"), Color3.fromHex("#FC00FF")),
	Desc = T("infoHeroDesc"),
	Image = safeIcon("sparkles"),
	ImageSize = 26,
})
bind(st.infoHero, "infoHero", "infoHeroDesc")

st.infoCrush = InfoTab:Paragraph({
	Title = GetTextGradient(T("infoCrush"), Color3.fromHex("#FFB347"), Color3.fromHex("#FF4D4D")),
	Desc = T("infoCrushDesc"),
	Image = safeIcon("swords"),
	ImageSize = 22,
})
bind(st.infoCrush, "infoCrush", "infoCrushDesc")

bind(InfoTab:Section({ Title = T("sectionInfoTeam") }), "sectionInfoTeam")

bind(InfoTab:Paragraph({
	Title = T("infoAuthor"),
	Desc = T("infoAuthorDesc"),
	Image = safeIcon("crown"),
	ImageSize = 22,
}), "infoAuthor", "infoAuthorDesc")

bind(InfoTab:Paragraph({
	Title = T("infoSaint"),
	Desc = T("infoSaintDesc"),
	Image = safeIcon("users"),
	ImageSize = 22,
}), "infoSaint", "infoSaintDesc")

bind(InfoTab:Section({ Title = T("sectionInfoRule") }), "sectionInfoRule")

bind(InfoTab:Paragraph({
	Title = T("infoFree"),
	Desc = T("infoFreeDesc"),
	Image = safeIcon("heart"),
	ImageSize = 22,
}), "infoFree", "infoFreeDesc")

bind(InfoTab:Paragraph({
	Title = T("infoNoSell"),
	Desc = T("infoNoSellDesc"),
	Image = safeIcon("shield"),
	ImageSize = 22,
}), "infoNoSell", "infoNoSellDesc")

bind(InfoTab:Paragraph({
	Title = T("infoRisk"),
	Desc = T("infoRiskDesc"),
	Image = safeIcon("triangle-alert"),
	ImageSize = 22,
}), "infoRisk", "infoRiskDesc")

local function attachInfoCard()
	if st.infoCard then
		return
	end
	local function scrollFrom(node)
		if typeof(node) ~= "Instance" then
			return nil
		end
		if node:IsA("ScrollingFrame") then
			return node
		end
		return node:FindFirstChildWhichIsA("ScrollingFrame", true)
	end
	local list = scrollFrom(InfoTab.Frame)
		or scrollFrom(InfoTab.Canvas)
		or scrollFrom(InfoTab.Container)
	if not list and type(InfoTab.UIElements) == "table" then
		list = scrollFrom(InfoTab.UIElements.Content)
			or scrollFrom(InfoTab.UIElements.Main)
			or scrollFrom(InfoTab.UIElements.List)
			or scrollFrom(InfoTab.UIElements.Container)
	end
	if not list and typeof(InfoTab.UIElements) == "Instance" then
		list = scrollFrom(InfoTab.UIElements)
	end
	if not list then
		return
	end
	local card = Instance.new("Frame")
	card.Name = "XiProInfoCard"
	card.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	card.BackgroundTransparency = 0.06
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, -6, 0, 218)
	card.LayoutOrder = -80
	card.Parent = list
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = card
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.84
	stroke.Thickness = 1
	stroke.Parent = card
	local accent = Instance.new("Frame")
	accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	accent.BorderSizePixel = 0
	accent.Size = UDim2.new(1, 0, 0, 3)
	accent.Parent = card
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 18)
	accentCorner.Parent = accent
	local accentGrad = Instance.new("UIGradient")
	accentGrad.Color = ColorSequence.new(Color3.fromHex("#00DBDE"), Color3.fromHex("#FC00FF"))
	accentGrad.Parent = accent
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 22)
	pad.PaddingBottom = UDim.new(0, 16)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = card
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 36)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = T("infoHero")
	title.Parent = card
	local titleGrad = Instance.new("UIGradient")
	titleGrad.Color = ColorSequence.new(Color3.fromHex("#00DBDE"), Color3.fromHex("#FC00FF"))
	titleGrad.Parent = title
	local slogan = Instance.new("TextLabel")
	slogan.BackgroundTransparency = 1
	slogan.Position = UDim2.fromOffset(0, 42)
	slogan.Size = UDim2.new(1, 0, 0, 40)
	slogan.Font = Enum.Font.GothamMedium
	slogan.TextSize = 15
	slogan.TextXAlignment = Enum.TextXAlignment.Left
	slogan.TextYAlignment = Enum.TextYAlignment.Top
	slogan.TextWrapped = true
	slogan.TextColor3 = Color3.fromRGB(235, 235, 238)
	slogan.Text = T("infoCrush")
	slogan.Parent = card
	local line = Instance.new("Frame")
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BackgroundTransparency = 0.88
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(0, 92)
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Parent = card
	local author = Instance.new("TextLabel")
	author.BackgroundTransparency = 1
	author.Position = UDim2.fromOffset(0, 108)
	author.Size = UDim2.new(1, 0, 0, 22)
	author.Font = Enum.Font.GothamMedium
	author.TextSize = 13
	author.TextXAlignment = Enum.TextXAlignment.Left
	author.TextColor3 = Color3.fromRGB(210, 210, 214)
	author.Text = T("infoAuthor") .. "  ·  " .. T("infoAuthorDesc")
	author.Parent = card
	local saint = Instance.new("TextLabel")
	saint.BackgroundTransparency = 1
	saint.Position = UDim2.fromOffset(0, 132)
	saint.Size = UDim2.new(1, 0, 0, 22)
	saint.Font = Enum.Font.GothamMedium
	saint.TextSize = 13
	saint.TextXAlignment = Enum.TextXAlignment.Left
	saint.TextColor3 = Color3.fromRGB(210, 210, 214)
	saint.Text = T("infoSaint") .. "  ·  " .. T("infoSaintDesc")
	saint.Parent = card
	local rule = Instance.new("TextLabel")
	rule.BackgroundTransparency = 1
	rule.Position = UDim2.fromOffset(0, 168)
	rule.Size = UDim2.new(1, 0, 0, 22)
	rule.Font = Enum.Font.GothamBold
	rule.TextSize = 13
	rule.TextXAlignment = Enum.TextXAlignment.Left
	rule.TextColor3 = Color3.fromRGB(255, 255, 255)
	rule.Text = T("infoFree") .. "    ·    " .. T("infoNoSell")
	rule.Parent = card
	st.infoCard = card
	st.infoCardTitle = title
	st.infoCardSlogan = slogan
	st.infoCardAuthor = author
	st.infoCardSaint = saint
	st.infoCardRule = rule
end

st.aimToggle = bind(AimTab:Toggle({
	Title = T("aimAssist"),
	Desc = T("aimAssistDesc"),
	Icon = safeIcon("target"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		setAimAssist(value)
		notify("Xi Pro", value and T("aimOn") or T("aimOff"))
	end,
}), "aimAssist", "aimAssistDesc")

local function setAimToggle(value)
	st.syncingToggle = true
	cfg.AimAssist = value and true or false
	pcall(function()
		if st.aimToggle.Set then
			st.aimToggle:Set(value)
		elseif st.aimToggle.SetValue then
			st.aimToggle:SetValue(value)
		end
	end)
	setAimAssist(value)
	st.syncingToggle = false
end

bind(AimTab:Toggle({
	Title = T("targetPlayers"),
	Desc = T("targetPlayersDesc"),
	Icon = safeIcon("user"),
	Value = true,
	Callback = function(value)
		cfg.TargetPlayers = value and true or false
	end,
}), "targetPlayers", "targetPlayersDesc")

bind(AimTab:Toggle({
	Title = T("targetTyres"),
	Desc = T("targetTyresDesc"),
	Icon = safeIcon("circle"),
	Value = true,
	Callback = function(value)
		cfg.TargetTyres = value and true or false
	end,
}), "targetTyres", "targetTyresDesc")

bind(AimTab:Toggle({
	Title = T("wallCheck"),
	Desc = T("wallCheckDesc"),
	Icon = safeIcon("brick-wall"),
	Value = true,
	Callback = function(value)
		cfg.WallCheck = value and true or false
	end,
}), "wallCheck", "wallCheckDesc")

bind(AimTab:Toggle({
	Title = T("aimAtHead"),
	Desc = T("aimAtHeadDesc"),
	Icon = safeIcon("scan-face"),
	Value = false,
	Callback = function(value)
		cfg.AimAtHead = value and true or false
	end,
}), "aimAtHead", "aimAtHeadDesc")

bind(AimTab:Slider({
	Title = T("aimCircle"),
	Desc = T("aimCircleDesc"),
	Step = 1,
	Value = {
		Min = 20,
		Max = 400,
		Default = 110,
	},
	Callback = function(value)
		cfg.AimCircle = tonumber(value) or cfg.AimCircle
		updateAimCircle()
	end,
}), "aimCircle", "aimCircleDesc")

bind(AimTab:Toggle({
	Title = T("showAimCircle"),
	Desc = T("showAimCircleDesc"),
	Icon = safeIcon("eye"),
	Value = false,
	Callback = function(value)
		cfg.ShowAimCircle = value and true or false
		updateAimCircle()
	end,
}), "showAimCircle", "showAimCircleDesc")

bind(AimTab:Slider({
	Title = T("maxDistance"),
	Desc = T("maxDistanceDesc"),
	Step = 10,
	Value = {
		Min = 100,
		Max = 5000,
		Default = 600,
	},
	Callback = function(value)
		cfg.MaxDistance = tonumber(value) or cfg.MaxDistance
	end,
}), "maxDistance", "maxDistanceDesc")

bind(AimTab:Slider({
	Title = T("humanization"),
	Desc = T("humanizationDesc"),
	Step = 1,
	Value = {
		Min = 0,
		Max = 100,
		Default = 60,
	},
	Callback = function(value)
		cfg.Humanization = tonumber(value) or cfg.Humanization
	end,
}), "humanization", "humanizationDesc")

bind(AimTab:Toggle({
	Title = T("fireRealGun"),
	Desc = T("fireRealGunDesc"),
	Icon = safeIcon("crosshair"),
	Value = false,
	Callback = function(value)
		cfg.FireRealGun = value and true or false
		if not value then
			stopFiring()
		elseif IS_MOBILE then
			notify("Xi Pro", getMobileFireButton() and T("realGunOn") or T("realGunNeedWeapon"))
		end
	end,
}), "fireRealGun", "fireRealGunDesc")

bind(AimTab:Section({ Title = T("sectionAutoFire") }), "sectionAutoFire")

st.autoShootToggle = bind(AimTab:Toggle({
	Title = T("autoShoot"),
	Desc = T("autoShootDesc"),
	Icon = safeIcon("crosshair"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.AutoShoot = value and true or false
		if not cfg.AutoShoot then
			stopFiring()
		end
		notify("Xi Pro", cfg.AutoShoot and T("autoShootOn") or T("autoShootOff"))
	end,
}), "autoShoot", "autoShootDesc")

bind(AimTab:Toggle({
	Title = T("verifyShot"),
	Desc = T("verifyShotDesc"),
	Icon = safeIcon("circle-check"),
	Value = true,
	Callback = function(value)
		cfg.VerifyShot = value and true or false
	end,
}), "verifyShot", "verifyShotDesc")

bind(AimTab:Slider({
	Title = T("fireRate"),
	Desc = T("fireRateDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 25,
		Default = 8,
	},
	Callback = function(value)
		cfg.FireRate = tonumber(value) or cfg.FireRate
	end,
}), "fireRate", "fireRateDesc")

bind(AimTab:Slider({
	Title = T("fireCone"),
	Desc = T("fireConeDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 20,
		Default = 4,
	},
	Callback = function(value)
		cfg.FireCone = tonumber(value) or cfg.FireCone
	end,
}), "fireCone", "fireConeDesc")

bind(AimTab:Section({ Title = T("sectionSilent") }), "sectionSilent")

st.silentToggle = bind(AimTab:Toggle({
	Title = T("silentAim"),
	Desc = T("silentAimDesc"),
	Icon = safeIcon("skull"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		setSilentAim(value)
		notify("Xi Pro", value and T("silentOn") or T("silentOff"))
	end,
}), "silentAim", "silentAimDesc")

bind(AimTab:Toggle({
	Title = T("teleportShot"),
	Desc = T("teleportShotDesc"),
	Icon = safeIcon("radar"),
	Value = false,
	Callback = function(value)
		cfg.SilentTp = value and true or false
	end,
}), "teleportShot", "teleportShotDesc")

bind(AimTab:Slider({
	Title = T("silentCircle"),
	Desc = T("silentCircleDesc"),
	Step = 1,
	Value = {
		Min = 0,
		Max = 400,
		Default = 150,
	},
	Callback = function(value)
		cfg.SilentFov = tonumber(value) or cfg.SilentFov
		updateAimCircle()
	end,
}), "silentCircle", "silentCircleDesc")

bind(AimTab:Slider({
	Title = T("silentRange"),
	Desc = T("silentRangeDesc"),
	Step = 10,
	Value = {
		Min = 100,
		Max = 5000,
		Default = 600,
	},
	Callback = function(value)
		cfg.SilentRange = tonumber(value) or cfg.SilentRange
	end,
}), "silentRange", "silentRangeDesc")

bind(AimTab:Slider({
	Title = T("hitsPerShot"),
	Desc = T("hitsPerShotDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 8,
		Default = 4,
	},
	Callback = function(value)
		cfg.SilentBurst = tonumber(value) or cfg.SilentBurst
	end,
}), "hitsPerShot", "hitsPerShotDesc")

bind(AimTab:Toggle({
	Title = T("silentAutoFire"),
	Desc = T("silentAutoFireDesc"),
	Icon = safeIcon("zap"),
	Value = false,
	Callback = function(value)
		cfg.SilentAutoFire = value and true or false
		if not cfg.SilentAutoFire then
			st.silentAutoTarget = nil
			st.silentAutoCount = 0
		end
	end,
}), "silentAutoFire", "silentAutoFireDesc")

bind(AimTab:Slider({
	Title = T("silentAutoShots"),
	Desc = T("silentAutoShotsDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 15,
		Default = 6,
	},
	Callback = function(value)
		cfg.SilentAutoShots = tonumber(value) or cfg.SilentAutoShots
	end,
}), "silentAutoShots", "silentAutoShotsDesc")

bind(AimTab:Toggle({
	Title = T("combatOnly"),
	Desc = T("combatOnlyDesc"),
	Icon = safeIcon("sword"),
	Value = true,
	Callback = function(value)
		cfg.SilentCombat = value and true or false
	end,
}), "combatOnly", "combatOnlyDesc")

bind(AimTab:Toggle({
	Title = T("alwaysShowCircle"),
	Desc = T("alwaysShowCircleDesc"),
	Icon = safeIcon("eye"),
	Value = false,
	Callback = function(value)
		cfg.SilentAlways = value and true or false
		updateAimCircle()
	end,
}), "alwaysShowCircle", "alwaysShowCircleDesc")

bind(AimTab:Section({ Title = T("sectionRage") }), "sectionRage")

bind(AimTab:Toggle({
	Title = T("ragebot"),
	Desc = T("ragebotDesc"),
	Icon = safeIcon("bot"),
	Value = false,
	Callback = function(value)
		cfg.Ragebot = value and true or false
		notify("Xi Pro", cfg.Ragebot and T("rageOn") or T("rageOff"))
	end,
}), "ragebot", "ragebotDesc")

bind(AimTab:Slider({
	Title = T("rageRange"),
	Desc = T("rageRangeDesc"),
	Step = 1,
	Value = {
		Min = 10,
		Max = 500,
		Default = 150,
	},
	Callback = function(value)
		cfg.RageRange = tonumber(value) or cfg.RageRange
	end,
}), "rageRange", "rageRangeDesc")

bind(AimTab:Slider({
	Title = T("rageInterval"),
	Desc = T("rageIntervalDesc"),
	Step = 0.01,
	Value = {
		Min = 0.01,
		Max = 1,
		Default = 0.05,
	},
	Callback = function(value)
		cfg.RageInterval = tonumber(value) or cfg.RageInterval
	end,
}), "rageInterval", "rageIntervalDesc")

st.ragePartDropdown = AimTab:Dropdown({
	Title = T("ragePart"),
	Desc = T("ragePartDesc"),
	Values = ragePartLabels(),
	Value = T(RAGE_PART_LOCALE[cfg.RageBodyPart] or "rageHead"),
	Callback = function(value)
		cfg.RageBodyPart = ragePartFromLabel(value) or "Head"
	end,
})
bind(st.ragePartDropdown, "ragePart", "ragePartDesc")

bind(AimTab:Toggle({
	Title = T("rageJobCheck"),
	Desc = T("rageJobCheckDesc"),
	Icon = safeIcon("briefcase"),
	Value = false,
	Callback = function(value)
		cfg.RageJobCheck = value and true or false
	end,
}), "rageJobCheck", "rageJobCheckDesc")

bind(AimTab:Toggle({
	Title = T("rageWallCheck"),
	Desc = T("rageWallCheckDesc"),
	Icon = safeIcon("eye-off"),
	Value = false,
	Callback = function(value)
		cfg.RageWallCheck = value and true or false
	end,
}), "rageWallCheck", "rageWallCheckDesc")

bind(AimTab:Toggle({
	Title = T("rageWallbang"),
	Desc = T("rageWallbangDesc"),
	Icon = safeIcon("layers"),
	Value = true,
	Callback = function(value)
		cfg.RageWallbang = value and true or false
	end,
}), "rageWallbang", "rageWallbangDesc")

bind(AimTab:Toggle({
	Title = T("rageAliveCheck"),
	Desc = T("rageAliveCheckDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.RageAliveCheck = value and true or false
	end,
}), "rageAliveCheck", "rageAliveCheckDesc")

bind(AimTab:Toggle({
	Title = T("rageCombatCheck"),
	Desc = T("rageCombatCheckDesc"),
	Icon = safeIcon("swords"),
	Value = false,
	Callback = function(value)
		cfg.RageCombatCheck = value and true or false
	end,
}), "rageCombatCheck", "rageCombatCheckDesc")

st.ragePoliceToggle = bind(AimTab:Toggle({
	Title = T("ragePoliceLock"),
	Desc = T("ragePoliceLockDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.RagePoliceLock = value and true or false
		if cfg.RagePoliceLock and cfg.RageCivilianLock then
			cfg.RageCivilianLock = false
			setLockToggle(st.rageCivilianToggle, false)
		end
	end,
}), "ragePoliceLock", "ragePoliceLockDesc")

st.rageCivilianToggle = bind(AimTab:Toggle({
	Title = T("rageCivilianLock"),
	Desc = T("rageCivilianLockDesc"),
	Icon = safeIcon("user"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.RageCivilianLock = value and true or false
		if cfg.RageCivilianLock and cfg.RagePoliceLock then
			cfg.RagePoliceLock = false
			setLockToggle(st.ragePoliceToggle, false)
		end
	end,
}), "rageCivilianLock", "rageCivilianLockDesc")

bind(AimTab:Toggle({
	Title = T("rageBeam"),
	Desc = T("rageBeamDesc"),
	Icon = safeIcon("activity"),
	Value = false,
	Callback = function(value)
		cfg.RageBeam = value and true or false
	end,
}), "rageBeam", "rageBeamDesc")

bind(AimTab:Section({ Title = T("sectionDefense") }), "sectionDefense")

bind(AimTab:Toggle({
	Title = T("defenseMode"),
	Desc = T("defenseModeDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		cfg.Defense = value and true or false
		if not cfg.Defense then
			stopDefense()
		end
	end,
}), "defenseMode", "defenseModeDesc")

bind(AimTab:Toggle({
	Title = T("defenseAutoFire"),
	Desc = T("defenseAutoFireDesc"),
	Icon = safeIcon("sword"),
	Value = true,
	Callback = function(value)
		cfg.DefenseAutoFire = value and true or false
	end,
}), "defenseAutoFire", "defenseAutoFireDesc")

bind(AimTab:Slider({
	Title = T("retaliateFor"),
	Desc = T("retaliateForDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 15,
		Default = 5,
	},
	Callback = function(value)
		cfg.RetaliateFor = tonumber(value) or cfg.RetaliateFor
	end,
}), "retaliateFor", "retaliateForDesc")

bind(AimTab:Section({ Title = T("sectionEquip") }), "sectionEquip")

bind(AimTab:Toggle({
	Title = T("autoEquip"),
	Desc = T("autoEquipDesc"),
	Icon = safeIcon("backpack"),
	Value = false,
	Callback = function(value)
		cfg.AutoEquip = value and true or false
	end,
}), "autoEquip", "autoEquipDesc")

bind(AimTab:Slider({
	Title = T("hotbarSlot"),
	Desc = T("hotbarSlotDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 5,
		Default = 1,
	},
	Callback = function(value)
		cfg.HotbarSlot = tonumber(value) or cfg.HotbarSlot
	end,
}), "hotbarSlot", "hotbarSlotDesc")

bind(AimTab:Section({ Title = T("sectionFilter") }), "sectionFilter")

bind(AimTab:Toggle({
	Title = T("teamCheck"),
	Desc = T("teamCheckDesc"),
	Icon = safeIcon("shield-check"),
	Value = false,
	Callback = function(value)
		cfg.TeamCheck = value and true or false
	end,
}), "teamCheck", "teamCheckDesc")

bind(AimTab:Toggle({
	Title = T("crewCheck"),
	Desc = T("crewCheckDesc"),
	Icon = safeIcon("users"),
	Value = false,
	Callback = function(value)
		cfg.CrewCheck = value and true or false
	end,
}), "crewCheck", "crewCheckDesc")

bind(AimTab:Toggle({
	Title = T("friendsCheck"),
	Desc = T("friendsCheckDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.FriendCheck = value and true or false
		if cfg.FriendCheck then
			refreshAllFriends()
		end
	end,
}), "friendsCheck", "friendsCheckDesc")

local function playerSearchList()
	local list = {}
	local query = st.whitelistQuery:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local name = player.Name
			if query == "" or name:lower():find(query, 1, true) or player.DisplayName:lower():find(query, 1, true) then
				list[#list + 1] = name
			end
		end
	end
	table.sort(list)
	if #list == 0 then
		list[1] = "-"
	end
	return list
end

local function whitelistText()
	local names = {}
	for name, on in pairs(cfg.Whitelist) do
		if on then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	if #names == 0 then
		return T("whitelistEmpty")
	end
	return table.concat(names, ", ")
end

local function refreshWhitelistUi()
	local list = playerSearchList()
	pcall(function()
		if st.whitelistDropdown and st.whitelistDropdown.Refresh then
			st.whitelistDropdown:Refresh(list)
		elseif st.whitelistDropdown and st.whitelistDropdown.SetValues then
			st.whitelistDropdown:SetValues(list)
		end
	end)
	pcall(function()
		if st.whitelistParagraph and st.whitelistParagraph.SetDesc then
			st.whitelistParagraph:SetDesc(whitelistText())
		end
	end)
	if list[1] ~= "-" then
		st.whitelistSelected = st.whitelistSelected or list[1]
	end
end
st.refreshWhitelistUi = refreshWhitelistUi

bind(AimTab:Input({
	Title = T("whitelistSearch"),
	Desc = T("whitelistSearchDesc"),
	Placeholder = "Name",
	Callback = function(value)
		st.whitelistQuery = tostring(value or ""):lower()
		refreshWhitelistUi()
	end,
}), "whitelistSearch", "whitelistSearchDesc")

st.whitelistDropdown = AimTab:Dropdown({
	Title = T("whitelist"),
	Desc = T("whitelistDesc"),
	Values = playerSearchList(),
	Callback = function(value)
		if value and value ~= "-" then
			st.whitelistSelected = value
		end
	end,
})
bind(st.whitelistDropdown, "whitelist", "whitelistDesc")

bind(AimTab:Button({
	Title = T("whitelistToggle"),
	Icon = safeIcon("user-check"),
	Callback = function()
		local name = st.whitelistSelected
		if not name or name == "-" then
			return
		end
		if cfg.Whitelist[name] then
			cfg.Whitelist[name] = nil
			notify("Xi Pro", name .. " " .. T("whitelistOff"))
		else
			cfg.Whitelist[name] = true
			notify("Xi Pro", name .. " " .. T("whitelistOn"))
		end
		refreshWhitelistUi()
	end,
}), "whitelistToggle")

st.whitelistParagraph = bind(AimTab:Paragraph({
	Title = T("whitelist"),
	Desc = T("whitelistEmpty"),
}), "whitelist")

bind(AimTab:Toggle({
	Title = T("roleFilter"),
	Desc = T("roleFilterDesc"),
	Icon = safeIcon("flag"),
	Value = false,
	Callback = function(value)
		cfg.RoleFilter = value and true or false
	end,
}), "roleFilter", "roleFilterDesc")

for _, roleName in ipairs(ROLE_ORDER) do
	local role = roleName
	local localeKey = ROLE_LOCALE[role]
	bind(AimTab:Toggle({
		Title = T(localeKey),
		Value = cfg.Roles[role] == true,
		Callback = function(value)
			cfg.Roles[role] = value and true or false
		end,
	}), localeKey)
end

bind(AimTab:Toggle({
	Title = T("wantedOnly"),
	Desc = T("wantedOnlyDesc"),
	Icon = safeIcon("user"),
	Value = false,
	Callback = function(value)
		cfg.WantedOnly = value and true or false
	end,
}), "wantedOnly", "wantedOnlyDesc")

track(UserInputService.InputBegan:Connect(function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q then
		setAimToggle(not cfg.AimAssist)
		notify("Xi Pro", cfg.AimAssist and T("aimOn") or T("aimOff"))
	end
end))

track(Players.PlayerAdded:Connect(function(player)
	refreshFriend(player)
	task.delay(0.2, refreshWhitelistUi)
end))
track(Players.PlayerRemoving:Connect(function()
	task.delay(0.2, refreshWhitelistUi)
end))
track(LocalPlayer.CharacterAdded:Connect(function()
	task.delay(0.5, function()
		if cfg.JumpEnabled or cfg.InfiniteJump then
			startJumpBoost()
		end
		if cfg.Noclip then
			startNoclip()
		end
		if cfg.Fly then
			stopFly()
			task.wait(0.2)
			startFly()
		end
		if ghost.on then
			local character = getCharacter(LocalPlayer)
			ghost.transParts = {}
			ghostApplyVisual(character, true)
			local root = getRootPart(character)
			if root then
				st.ghostDesyncPos = st.ghostDesyncPos or root.Position
				ghost.hideCF = ghostComputeHideCF(root.CFrame)
			end
		end
		if cfg.Stealth then
			setStealth(true)
		end
		if cfg.InfAmmo or cfg.NoReload then
			st.ammoChar = nil
			tickAmmo()
		end
	end)
end))
pcall(refreshAllFriends)
pcall(function()
	track(LocalPlayer.FriendStatusChanged:Connect(function(player, status)
		if player then
			st.friendCache[player.UserId] = status == Enum.FriendStatus.Friend
		end
	end))
end)

task.spawn(function()
	local ok = pcall(function()
		local remote = ReplicatedStorage:FindFirstChild("Remote") or ReplicatedStorage:WaitForChild("Remote", 10)
		local event = remote and (remote:FindFirstChild("PlayerEvent") or remote:WaitForChild("PlayerEvent", 10))
		if not (event and event:IsA("RemoteEvent")) then
			return
		end
		st.playerEvent = event
		track(event.OnClientEvent:Connect(function(...)
			if not cfg.Defense then
				return
			end
			local packed = table.pack(...)
			local isBullet, info = false, nil
			for i = 1, packed.n do
				local item = packed[i]
				if type(item) == "string" and item:lower() == "bullet" then
					isBullet = true
				elseif type(item) == "table" and item.plr ~= nil then
					info = item
				end
			end
			if isBullet and info then
				recordIncomingShot(info.plr, info.pos)
			end
		end))
	end)
	if not ok then
		warn("[Xi Pro] Defense Mode: couldn't hook Remote.PlayerEvent")
	end
end)

track(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
	dt = dt or 0
	if ghost and ghost.on then
		tickGhost()
	end
	if cfg.InfStamina or cfg.InfHunger then
		if not st.coreModule then
			loadCoreModule()
		elseif not st.staminaHooked then
			pcall(hookStaminaFood)
		end
	end
	if cfg.AntiPrisonPull then
		if not st.coreModule then
			loadCoreModule()
		else
			pcall(hookPrisonNotify)
		end
	end
	if cfg.KillAura then
		tickKillAura()
	end
	if cfg.InfAmmo or cfg.NoReload then
		tickAmmo()
	end
	if st.touchDown and (os.clock() - st.lastTouchPulse > 0.12 or not cfg.AutoShoot or not cfg.AimAssist) then
		setTouchFire(false)
	end

	st.silentCircleClock += dt
	if st.silentCircleClock >= 0.2 then
		st.silentCircleClock = 0
		updateAimCircle()
	end

	if cfg.Defense then
		local myChar = getCharacter(LocalPlayer)
		local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local health = humanoid.Health
			if st.lastHealth and health < st.lastHealth - 0.01 and health > 0 then
				startDefense(findAttacker())
			end
			st.lastHealth = health
		else
			st.lastHealth = nil
		end
		if st.defenseUntil > 0 then
			local expired = os.clock() > st.defenseUntil
			if not expired and st.defenseTarget then
				expired = not isPlayerValid(st.defenseTarget, math.huge)
			end
			if expired then
				stopDefense()
			end
		end
	elseif st.lastHealth then
		st.lastHealth = nil
	end

	if not cfg.SilentAim then
		st.lastSilentSeq = st.silentSeq
		st.silentAutoCount = 0
		st.silentAutoClock = 0
		return
	end

	if not hasGunOut() then
		st.silentAutoTarget = nil
	end

	if st.silentSeq ~= st.lastSilentSeq then
		st.lastSilentSeq = st.silentSeq
		local ok, target = pcall(pickSilentTarget)
		if ok and target then
			teleportShot(target, math.max(1, cfg.SilentBurst))
			if cfg.SilentAutoFire and os.clock() >= st.silentAutoCooldown and st.silentAutoTarget ~= target then
				st.silentAutoTarget = target
				st.silentAutoCount = 0
			end
		end
	end

	local gun = getGunConfig()
	local defendNow = os.clock() < st.defenseUntil and st.defenseTarget
	if defendNow and cfg.DefenseAutoFire and gun and not UserInputService:GetFocusedTextBox() then
		pcall(tryEquip)
		local rpm = tonumber(gun.RPM) or 500
		local waitTime = math.clamp(60 / math.max(1, rpm), 0.05, 0.6)
		st.silentAutoClock += dt
		if st.silentAutoClock >= waitTime then
			st.silentAutoClock = 0
			if IS_MOBILE then
				pcall(silentFireAt, st.defenseTarget, 1)
			else
				pcall(mouseClick)
			end
		end
		return
	end

	local limit = math.max(1, cfg.SilentAutoShots)
	local canAuto = cfg.SilentAutoFire
		and pickSilentTarget()
		and not UserInputService:GetFocusedTextBox()
		and gun
	if canAuto and st.silentAutoCount < limit then
		pcall(tryEquip)
		local rpm = tonumber(gun.RPM) or 500
		local waitTime = math.clamp(60 / math.max(1, rpm), 0.05, 0.6)
		st.silentAutoClock += dt
		if st.silentAutoClock >= waitTime then
			st.silentAutoClock = 0
			st.silentAutoCount += 1
			if st.silentAutoTarget then
				if IS_MOBILE then
					pcall(silentFireAt, st.silentAutoTarget, 1)
				else
					pcall(mouseClick)
				end
			end
		end
	else
		st.silentAutoClock = 0
		if st.silentAutoTarget and st.silentAutoCount >= limit then
			st.silentAutoTarget = nil
			st.silentAutoCount = 0
			st.silentAutoCooldown = os.clock() + 1.5
		end
	end
end)))

bind(SettingsTab:Paragraph({
	Title = T("infoTitle"),
	Desc = T("infoDesc"),
	Image = "swords",
	ImageSize = 22,
}), "infoTitle", "infoDesc")

bind(SettingsTab:Dropdown({
	Title = T("language"),
	Desc = T("languageDesc"),
	Values = { "中文", "English" },
	Value = currentLang == "en" and "English" or "中文",
	Callback = function(value)
		local nextLang = value == "English" and "en" or "zh"
		if nextLang == currentLang then
			return
		end
		currentLang = nextLang
		host.XiProLanguage = currentLang
		applyLanguage()
		pcall(refreshWhitelistUi)
		pcall(refreshRagePartUi)
		notify("Xi Pro", T("switched"))
	end,
}), "language", "languageDesc")

bind(PlayerTab:Section({ Title = T("sectionProtect") }), "sectionProtect")

bind(PlayerTab:Toggle({
	Title = T("antiRagdoll"),
	Desc = T("antiRagdollDesc"),
	Icon = safeIcon("bandage"),
	Value = false,
	Callback = function(value)
		setAntiRagdoll(value and true or false)
	end,
}), "antiRagdoll", "antiRagdollDesc")

bind(PlayerTab:Toggle({
	Title = T("antiArrest"),
	Desc = T("antiArrestDesc"),
	Icon = safeIcon("lock"),
	Value = false,
	Callback = function(value)
		setAntiArrest(value and true or false)
	end,
}), "antiArrest", "antiArrestDesc")

bind(PlayerTab:Toggle({
	Title = T("antiAfk"),
	Desc = T("antiAfkDesc"),
	Icon = safeIcon("clock"),
	Value = false,
	Callback = function(value)
		setAntiAfk(value and true or false)
	end,
}), "antiAfk", "antiAfkDesc")

bind(PlayerTab:Toggle({
	Title = T("noDamage"),
	Desc = T("noDamageDesc"),
	Icon = safeIcon("shield-check"),
	Value = false,
	Callback = function(value)
		cfg.NoDamage = value and true or false
		if cfg.NoDamage then
			pcall(ensureSilentHook)
		end
	end,
}), "noDamage", "noDamageDesc")

bind(PlayerTab:Toggle({
	Title = T("antiPrisonPull"),
	Desc = T("antiPrisonPullDesc"),
	Icon = safeIcon("key"),
	Value = false,
	Callback = function(value)
		setAntiPrisonPull(value and true or false)
	end,
}), "antiPrisonPull", "antiPrisonPullDesc")

bind(PlayerTab:Section({ Title = T("sectionMove") }), "sectionMove")

bind(PlayerTab:Toggle({
	Title = T("noclip"),
	Desc = T("noclipDesc"),
	Icon = safeIcon("move"),
	Value = false,
	Callback = function(value)
		cfg.Noclip = value and true or false
		if cfg.Noclip then
			startNoclip()
		else
			stopNoclip()
		end
	end,
}), "noclip", "noclipDesc")

bind(PlayerTab:Toggle({
	Title = T("jumpEnabled"),
	Desc = T("jumpEnabledDesc"),
	Icon = safeIcon("chevrons-up"),
	Value = false,
	Callback = function(value)
		cfg.JumpEnabled = value and true or false
		refreshJumpBoost()
	end,
}), "jumpEnabled", "jumpEnabledDesc")

bind(PlayerTab:Slider({
	Title = T("jumpPower"),
	Desc = T("jumpPowerDesc"),
	Step = 1,
	Value = {
		Min = 50,
		Max = 400,
		Default = 50,
	},
	Callback = function(value)
		cfg.JumpPower = tonumber(value) or cfg.JumpPower
	end,
}), "jumpPower", "jumpPowerDesc")

bind(PlayerTab:Slider({
	Title = T("jumpMultiplier"),
	Desc = T("jumpMultiplierDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 10,
		Default = 1,
	},
	Callback = function(value)
		cfg.JumpMultiplier = tonumber(value) or cfg.JumpMultiplier
	end,
}), "jumpMultiplier", "jumpMultiplierDesc")

bind(PlayerTab:Toggle({
	Title = T("infiniteJump"),
	Desc = T("infiniteJumpDesc"),
	Icon = safeIcon("repeat"),
	Value = false,
	Callback = function(value)
		cfg.InfiniteJump = value and true or false
		refreshJumpBoost()
	end,
}), "infiniteJump", "infiniteJumpDesc")

bind(PlayerTab:Toggle({
	Title = T("fly"),
	Desc = T("flyDesc"),
	Icon = safeIcon("plane"),
	Value = false,
	Callback = function(value)
		cfg.Fly = value and true or false
		if cfg.Fly then
			startFly()
		else
			stopFly()
		end
	end,
}), "fly", "flyDesc")

bind(PlayerTab:Slider({
	Title = T("flySpeed"),
	Desc = T("flySpeedDesc"),
	Step = 1,
	Value = {
		Min = 10,
		Max = 200,
		Default = 30,
	},
	Callback = function(value)
		cfg.FlySpeed = tonumber(value) or cfg.FlySpeed
	end,
}), "flySpeed", "flySpeedDesc")

bind(PlayerTab:Section({ Title = T("sectionSurvive") }), "sectionSurvive")

bind(PlayerTab:Toggle({
	Title = T("godMode"),
	Desc = T("godModeDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		setGhost(value and true or false)
	end,
}), "godMode", "godModeDesc")

bind(PlayerTab:Toggle({
	Title = T("stealth"),
	Desc = T("stealthDesc"),
	Icon = safeIcon("eye"),
	Value = false,
	Callback = function(value)
		setStealth(value and true or false)
	end,
}), "stealth", "stealthDesc")

bind(PlayerTab:Toggle({
	Title = T("infStamina"),
	Desc = T("infStaminaDesc"),
	Icon = safeIcon("activity"),
	Value = false,
	Callback = function(value)
		cfg.InfStamina = value and true or false
		if cfg.InfStamina then
			loadCoreModule()
		end
	end,
}), "infStamina", "infStaminaDesc")

bind(PlayerTab:Toggle({
	Title = T("infHunger"),
	Desc = T("infHungerDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.InfHunger = value and true or false
		if cfg.InfHunger then
			loadCoreModule()
		end
	end,
}), "infHunger", "infHungerDesc")

bind(PoliceTab:Section({ Title = T("sectionPoliceArrest") }), "sectionPoliceArrest")

bind(PoliceTab:Toggle({
	Title = T("autoCuff"),
	Desc = T("autoCuffDesc"),
	Icon = safeIcon("lock"),
	Value = false,
	Callback = function(value)
		setAutoCuff(value and true or false)
		notify("Xi Pro", cfg.AutoCuff and T("cuffOn") or T("cuffOff"))
	end,
}), "autoCuff", "autoCuffDesc")

bind(PoliceTab:Toggle({
	Title = T("cuffTeleport"),
	Desc = T("cuffTeleportDesc"),
	Icon = safeIcon("move"),
	Value = false,
	Callback = function(value)
		cfg.CuffTeleport = value and true or false
	end,
}), "cuffTeleport", "cuffTeleportDesc")

bind(PoliceTab:Toggle({
	Title = T("cuffCombat"),
	Desc = T("cuffCombatDesc"),
	Icon = safeIcon("swords"),
	Value = false,
	Callback = function(value)
		cfg.CuffCombat = value and true or false
	end,
}), "cuffCombat", "cuffCombatDesc")

bind(PoliceTab:Section({ Title = T("sectionPoliceRange") }), "sectionPoliceRange")

bind(PoliceTab:Slider({
	Title = T("cuffRange"),
	Desc = T("cuffRangeDesc"),
	Step = 5,
	Value = {
		Min = 10,
		Max = 500,
		Default = 200,
	},
	Callback = function(value)
		cfg.CuffRange = tonumber(value) or cfg.CuffRange
	end,
}), "cuffRange", "cuffRangeDesc")

bind(PoliceTab:Slider({
	Title = T("cuffInterval"),
	Desc = T("cuffIntervalDesc"),
	Step = 0.1,
	Value = {
		Min = 0.1,
		Max = 3,
		Default = 0.5,
	},
	Callback = function(value)
		cfg.CuffInterval = tonumber(value) or cfg.CuffInterval
	end,
}), "cuffInterval", "cuffIntervalDesc")

bind(CombatTab:Section({ Title = T("sectionAura") }), "sectionAura")

bind(CombatTab:Toggle({
	Title = T("killAura"),
	Desc = T("killAuraDesc"),
	Icon = safeIcon("swords"),
	Value = false,
	Callback = function(value)
		cfg.KillAura = value and true or false
		if cfg.KillAura then
			pcall(resolvePlayerEvent)
			pcall(resolveHeadPart)
		end
	end,
}), "killAura", "killAuraDesc")

st.auraPoliceToggle = bind(CombatTab:Toggle({
	Title = T("auraPolice"),
	Desc = T("auraPoliceDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.AuraPolice = value and true or false
		if cfg.AuraPolice and cfg.AuraCivilian then
			cfg.AuraCivilian = false
			setLockToggle(st.auraCivilianToggle, false)
		end
	end,
}), "auraPolice", "auraPoliceDesc")

st.auraCivilianToggle = bind(CombatTab:Toggle({
	Title = T("auraCivilian"),
	Desc = T("auraCivilianDesc"),
	Icon = safeIcon("user"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.AuraCivilian = value and true or false
		if cfg.AuraCivilian and cfg.AuraPolice then
			cfg.AuraPolice = false
			setLockToggle(st.auraPoliceToggle, false)
		end
	end,
}), "auraCivilian", "auraCivilianDesc")

bind(CombatTab:Toggle({
	Title = T("auraCombat"),
	Desc = T("auraCombatDesc"),
	Icon = safeIcon("activity"),
	Value = false,
	Callback = function(value)
		cfg.AuraCombat = value and true or false
	end,
}), "auraCombat", "auraCombatDesc")

bind(CombatTab:Slider({
	Title = T("auraRange"),
	Desc = T("auraRangeDesc"),
	Step = 5,
	Value = {
		Min = 10,
		Max = 500,
		Default = 50,
	},
	Callback = function(value)
		cfg.AuraRange = tonumber(value) or cfg.AuraRange
	end,
}), "auraRange", "auraRangeDesc")

bind(CombatTab:Slider({
	Title = T("auraDamage"),
	Desc = T("auraDamageDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 100,
		Default = 5,
	},
	Callback = function(value)
		cfg.AuraDamage = tonumber(value) or cfg.AuraDamage
	end,
}), "auraDamage", "auraDamageDesc")

bind(CombatTab:Slider({
	Title = T("auraInterval"),
	Desc = T("auraIntervalDesc"),
	Step = 0.01,
	Value = {
		Min = 0.01,
		Max = 1,
		Default = 0.05,
	},
	Callback = function(value)
		cfg.AuraInterval = tonumber(value) or cfg.AuraInterval
	end,
}), "auraInterval", "auraIntervalDesc")

bind(CombatTab:Section({ Title = T("sectionCombatBlock") }), "sectionCombatBlock")

bind(CombatTab:Toggle({
	Title = T("combatBlock"),
	Desc = T("combatBlockDesc"),
	Icon = safeIcon("shield-check"),
	Value = false,
	Callback = function(value)
		cfg.CombatBlock = value and true or false
		if cfg.CombatBlock then
			pcall(ensureSilentHook)
		end
	end,
}), "combatBlock", "combatBlockDesc")

bind(CombatTab:Section({ Title = T("sectionAmmo") }), "sectionAmmo")

bind(CombatTab:Toggle({
	Title = T("infAmmo"),
	Desc = T("infAmmoDesc"),
	Icon = safeIcon("zap"),
	Value = false,
	Callback = function(value)
		cfg.InfAmmo = value and true or false
		if cfg.InfAmmo then
			st.ammoChar = nil
			pcall(tickAmmo)
		end
	end,
}), "infAmmo", "infAmmoDesc")

bind(CombatTab:Toggle({
	Title = T("noReload"),
	Desc = T("noReloadDesc"),
	Icon = safeIcon("repeat"),
	Value = false,
	Callback = function(value)
		cfg.NoReload = value and true or false
		if cfg.NoReload then
			st.ammoChar = nil
			pcall(tickAmmo)
		end
	end,
}), "noReload", "noReloadDesc")

bind(MoneyTab:Section({ Title = T("sectionHack") }), "sectionHack")

bind(MoneyTab:Toggle({
	Title = T("autoHack"),
	Desc = T("autoHackDesc"),
	Icon = safeIcon("cpu"),
	Value = false,
	Callback = function(value)
		setAutoHack(value and true or false)
	end,
}), "autoHack", "autoHackDesc")

bind(MoneyTab:Toggle({
	Title = T("autoAtm"),
	Desc = T("autoAtmDesc"),
	Icon = safeIcon("key"),
	Value = false,
	Callback = function(value)
		cfg.AutoAtm = value and true or false
		startMoneyLoops()
	end,
}), "autoAtm", "autoAtmDesc")

bind(MoneyTab:Section({ Title = T("sectionPickup") }), "sectionPickup")

bind(MoneyTab:Toggle({
	Title = T("pickMoney"),
	Desc = T("pickMoneyDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.PickMoney = value and true or false
		startMoneyLoops()
	end,
}), "pickMoney", "pickMoneyDesc")

bind(MoneyTab:Section({ Title = T("sectionMission") }), "sectionMission")

bind(MoneyTab:Toggle({
	Title = T("autoMission"),
	Desc = T("autoMissionDesc"),
	Icon = safeIcon("flag"),
	Value = false,
	Callback = function(value)
		cfg.AutoMission = value and true or false
		startMoneyLoops()
	end,
}), "autoMission", "autoMissionDesc")

bind(MoneyTab:Toggle({
	Title = T("missionHighPay"),
	Desc = T("missionHighPayDesc"),
	Icon = safeIcon("zap"),
	Value = false,
	Callback = function(value)
		cfg.MissionHighPay = value and true or false
	end,
}), "missionHighPay", "missionHighPayDesc")

bind(MoneyTab:Slider({
	Title = T("missionInterval"),
	Desc = T("missionIntervalDesc"),
	Step = 0.5,
	Value = {
		Min = 0.5,
		Max = 10,
		Default = 2,
	},
	Callback = function(value)
		cfg.MissionInterval = tonumber(value) or cfg.MissionInterval
	end,
}), "missionInterval", "missionIntervalDesc")

bind(MoneyTab:Section({ Title = T("sectionJobs") }), "sectionJobs")

bind(MoneyTab:Toggle({
	Title = T("farmBus"),
	Desc = T("farmBusDesc"),
	Icon = safeIcon("bot"),
	Value = false,
	Callback = function(value)
		cfg.FarmBus = value and true or false
		startMoneyLoops()
	end,
}), "farmBus", "farmBusDesc")

bind(MoneyTab:Toggle({
	Title = T("farmTaxi"),
	Desc = T("farmTaxiDesc"),
	Icon = safeIcon("car"),
	Value = false,
	Callback = function(value)
		cfg.FarmTaxi = value and true or false
		if cfg.FarmTaxi then
			local root = getRootPart(getCharacter(LocalPlayer))
			st.taxiOrigin = root and root.Position or st.taxiOrigin
			st.taxiLastPos = nil
		end
		startMoneyLoops()
	end,
}), "farmTaxi", "farmTaxiDesc")

bind(MoneyTab:Toggle({
	Title = T("taxiSafe"),
	Desc = T("taxiSafeDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		cfg.TaxiSafe = value and true or false
		if cfg.TaxiSafe then
			local root = getRootPart(getCharacter(LocalPlayer))
			st.taxiOrigin = root and root.Position or st.taxiOrigin
		end
	end,
}), "taxiSafe", "taxiSafeDesc")

bind(MoneyTab:Toggle({
	Title = T("farmFarmer"),
	Desc = T("farmFarmerDesc"),
	Icon = safeIcon("leaf"),
	Value = false,
	Callback = function(value)
		cfg.FarmFarmer = value and true or false
		startMoneyLoops()
	end,
}), "farmFarmer", "farmFarmerDesc")

bind(MoneyTab:Toggle({
	Title = T("farmChef"),
	Desc = T("farmChefDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.FarmChef = value and true or false
		startMoneyLoops()
	end,
}), "farmChef", "farmChefDesc")

bind(MoneyTab:Toggle({
	Title = T("farmGolf"),
	Desc = T("farmGolfDesc"),
	Icon = safeIcon("flag"),
	Value = false,
	Callback = function(value)
		cfg.FarmGolf = value and true or false
		st.golfReady = false
		startMoneyLoops()
	end,
}), "farmGolf", "farmGolfDesc")

initVehicle()

bind(VehicleTab:Section({ Title = T("sectionSpeedHud") }), "sectionSpeedHud")

bind(VehicleTab:Toggle({
	Title = T("speedHud"),
	Desc = T("speedHudDesc"),
	Icon = safeIcon("gauge"),
	Value = false,
	Callback = function(value)
		cfg.SpeedHud = value and true or false
		veh.start()
	end,
}), "speedHud", "speedHudDesc")

bind(VehicleTab:Section({ Title = T("sectionCar") }), "sectionCar")

bind(VehicleTab:Button({
	Title = T("bringCar"),
	Icon = safeIcon("navigation"),
	Callback = function()
		veh.bring()
	end,
}), "bringCar", "bringCarDesc")

bind(VehicleTab:Button({
	Title = T("enterCar"),
	Icon = safeIcon("log-in"),
	Callback = function()
		veh.enter()
	end,
}), "enterCar", "enterCarDesc")

bind(VehicleTab:Section({ Title = T("sectionDrive") }), "sectionDrive")

bind(VehicleTab:Toggle({
	Title = T("cruise"),
	Desc = T("cruiseDesc"),
	Icon = safeIcon("gauge"),
	Value = false,
	Callback = function(value)
		cfg.Cruise = value and true or false
		if cfg.Cruise then
			veh.start()
		end
	end,
}), "cruise", "cruiseDesc")

bind(VehicleTab:Toggle({
	Title = T("collisionStop"),
	Desc = T("collisionStopDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		cfg.CollisionStop = value and true or false
		if cfg.CollisionStop then
			veh.start()
		end
	end,
}), "collisionStop", "collisionStopDesc")

bind(VehicleTab:Toggle({
	Title = T("offroad"),
	Desc = T("offroadDesc"),
	Icon = safeIcon("map"),
	Value = false,
	Callback = function(value)
		cfg.Offroad = value and true or false
	end,
}), "offroad", "offroadDesc")

st.groundLockToggle = bind(VehicleTab:Toggle({
	Title = T("groundLock"),
	Desc = T("groundLockDesc"),
	Icon = safeIcon("locate"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.GroundLock = value and true or false
		if cfg.GroundLock then
			cfg.Float = false
			st.syncingToggle = true
			pcall(function()
				if st.floatToggle and st.floatToggle.Set then
					st.floatToggle:Set(false)
				elseif st.floatToggle and st.floatToggle.SetValue then
					st.floatToggle:SetValue(false)
				end
			end)
			st.syncingToggle = false
			veh.start()
		end
	end,
}), "groundLock", "groundLockDesc")

bind(VehicleTab:Slider({
	Title = T("rideHeight"),
	Desc = T("rideHeightDesc"),
	Step = 1,
	Value = {
		Min = -20,
		Max = 20,
		Default = 0,
	},
	Callback = function(value)
		cfg.RideHeight = tonumber(value) or cfg.RideHeight
	end,
}), "rideHeight", "rideHeightDesc")

st.floatToggle = bind(VehicleTab:Toggle({
	Title = T("floatCar"),
	Desc = T("floatCarDesc"),
	Icon = safeIcon("wind"),
	Value = false,
	Callback = function(value)
		if st.syncingToggle then
			return
		end
		cfg.Float = value and true or false
		if cfg.Float then
			cfg.GroundLock = false
			st.syncingToggle = true
			pcall(function()
				if st.groundLockToggle and st.groundLockToggle.Set then
					st.groundLockToggle:Set(false)
				elseif st.groundLockToggle and st.groundLockToggle.SetValue then
					st.groundLockToggle:SetValue(false)
				end
			end)
			st.syncingToggle = false
			veh.start()
		end
	end,
}), "floatCar", "floatCarDesc")

bind(VehicleTab:Slider({
	Title = T("floatHeight"),
	Desc = T("floatHeightDesc"),
	Step = 1,
	Value = {
		Min = 0,
		Max = 30,
		Default = 8,
	},
	Callback = function(value)
		cfg.FloatHeight = tonumber(value) or cfg.FloatHeight
	end,
}), "floatHeight", "floatHeightDesc")

bind(VehicleTab:Section({ Title = T("sectionVehStats") }), "sectionVehStats")

bind(VehicleTab:Toggle({
	Title = T("noCrashes"),
	Desc = T("noCrashesDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		cfg.NoCrashes = value and true or false
		if cfg.NoCrashes then
			veh.start()
		end
	end,
}), "noCrashes", "noCrashesDesc")

bind(VehicleTab:Toggle({
	Title = T("fullFuel"),
	Desc = T("fullFuelDesc"),
	Icon = safeIcon("flame"),
	Value = false,
	Callback = function(value)
		cfg.FullFuel = value and true or false
		if cfg.FullFuel then
			veh.start()
		end
	end,
}), "fullFuel", "fullFuelDesc")

bind(VehicleTab:Section({ Title = T("sectionRam") }), "sectionRam")

bind(VehicleTab:Toggle({
	Title = T("ramInstant"),
	Desc = T("ramInstantDesc"),
	Icon = safeIcon("zap"),
	Value = true,
	Callback = function(value)
		cfg.RamInstant = value and true or false
	end,
}), "ramInstant", "ramInstantDesc")

bind(VehicleTab:Slider({
	Title = T("ramDelay"),
	Desc = T("ramDelayDesc"),
	Step = 1,
	Value = {
		Min = 2,
		Max = 30,
		Default = 6,
	},
	Callback = function(value)
		cfg.RamDelay = tonumber(value) or cfg.RamDelay
	end,
}), "ramDelay", "ramDelayDesc")

bind(VehicleTab:Slider({
	Title = T("ramRange"),
	Desc = T("ramRangeDesc"),
	Step = 10,
	Value = {
		Min = 60,
		Max = 4000,
		Default = 2000,
	},
	Callback = function(value)
		cfg.RamRange = tonumber(value) or cfg.RamRange
	end,
}), "ramRange", "ramRangeDesc")

bind(VehicleTab:Toggle({
	Title = T("autoRam"),
	Desc = T("autoRamDesc"),
	Icon = safeIcon("zap"),
	Value = false,
	Callback = function(value)
		cfg.AutoRam = value and true or false
		if cfg.AutoRam then
			veh.start()
		end
	end,
}), "autoRam", "autoRamDesc")

bind(VehicleTab:Toggle({
	Title = T("killCheck"),
	Desc = T("killCheckDesc"),
	Icon = safeIcon("swords"),
	Value = true,
	Callback = function(value)
		cfg.KillCheck = value and true or false
	end,
}), "killCheck", "killCheckDesc")

st.vehDropdown = VehicleTab:Dropdown({
	Title = T("vehTarget"),
	Desc = T("vehTargetDesc"),
	Values = veh.playerNames(),
	Callback = function(value)
		if value and value ~= "-" then
			veh.targetName = value
		end
	end,
})
bind(st.vehDropdown, "vehTarget", "vehTargetDesc")
veh.refreshDropdown()

bind(VehicleTab:Button({
	Title = T("manualRam"),
	Icon = safeIcon("user"),
	Callback = function()
		veh.ram()
	end,
}), "manualRam", "manualRamDesc")

bind(VehicleTab:Section({ Title = T("sectionFollow") }), "sectionFollow")

bind(VehicleTab:Toggle({
	Title = T("followPlayer"),
	Desc = T("followPlayerDesc"),
	Icon = safeIcon("user"),
	Value = false,
	Callback = function(value)
		cfg.FollowPlayer = value and true or false
		if cfg.FollowPlayer then
			veh.start()
		end
	end,
}), "followPlayer", "followPlayerDesc")

bind(VehicleTab:Slider({
	Title = T("followGap"),
	Desc = T("followGapDesc"),
	Step = 1,
	Value = {
		Min = 10,
		Max = 120,
		Default = 30,
	},
	Callback = function(value)
		cfg.FollowGap = tonumber(value) or cfg.FollowGap
	end,
}), "followGap", "followGapDesc")

bind(VehicleTab:Button({
	Title = T("sendCar"),
	Icon = safeIcon("send"),
	Callback = function()
		veh.send()
	end,
}), "sendCar", "sendCarDesc")

initEsp()

bind(EspTab:Section({ Title = T("sectionEspVisual") }), "sectionEspVisual")

bind(EspTab:Toggle({
	Title = T("espTracers"),
	Desc = T("espTracersDesc"),
	Icon = safeIcon("spline"),
	Value = false,
	Callback = function(value)
		cfg.EspTracers = value and true or false
		esp.start()
	end,
}), "espTracers", "espTracersDesc")

bind(EspTab:Toggle({
	Title = T("espOffscreen"),
	Desc = T("espOffscreenDesc"),
	Icon = safeIcon("radar"),
	Value = false,
	Callback = function(value)
		cfg.EspOffscreen = value and true or false
		if cfg.EspTracers then
			esp.start()
		end
	end,
}), "espOffscreen", "espOffscreenDesc")

bind(EspTab:Toggle({
	Title = T("espDots"),
	Desc = T("espDotsDesc"),
	Icon = safeIcon("circle-dot"),
	Value = false,
	Callback = function(value)
		cfg.EspDots = value and true or false
		esp.start()
	end,
}), "espDots", "espDotsDesc")

bind(EspTab:Toggle({
	Title = T("espDetails"),
	Desc = T("espDetailsDesc"),
	Icon = safeIcon("tag"),
	Value = false,
	Callback = function(value)
		cfg.EspDetails = value and true or false
		esp.start()
	end,
}), "espDetails", "espDetailsDesc")

bind(EspTab:Toggle({
	Title = T("espHealth"),
	Desc = T("espHealthDesc"),
	Icon = safeIcon("heart"),
	Value = false,
	Callback = function(value)
		cfg.EspHealth = value and true or false
		esp.start()
	end,
}), "espHealth", "espHealthDesc")

bind(EspTab:Toggle({
	Title = T("espWanted"),
	Desc = T("espWantedDesc"),
	Icon = safeIcon("badge-alert"),
	Value = false,
	Callback = function(value)
		cfg.EspWanted = value and true or false
	end,
}), "espWanted", "espWantedDesc")

bind(EspTab:Section({ Title = T("sectionEspFilter") }), "sectionEspFilter")

bind(EspTab:Toggle({
	Title = T("espHideDead"),
	Desc = T("espHideDeadDesc"),
	Icon = safeIcon("skull"),
	Value = true,
	Callback = function(value)
		cfg.EspHideDead = value and true or false
	end,
}), "espHideDead", "espHideDeadDesc")

bind(EspTab:Toggle({
	Title = T("espPoliceOnly"),
	Desc = T("espPoliceOnlyDesc"),
	Icon = safeIcon("shield"),
	Value = false,
	Callback = function(value)
		cfg.EspPoliceOnly = value and true or false
	end,
}), "espPoliceOnly", "espPoliceOnlyDesc")

bind(EspTab:Toggle({
	Title = T("espWantedOnly"),
	Desc = T("espWantedOnlyDesc"),
	Icon = safeIcon("target"),
	Value = false,
	Callback = function(value)
		cfg.EspWantedOnly = value and true or false
	end,
}), "espWantedOnly", "espWantedOnlyDesc")

bind(EspTab:Section({ Title = T("sectionEspRange") }), "sectionEspRange")

bind(EspTab:Slider({
	Title = T("espRange"),
	Desc = T("espRangeDesc"),
	Step = 10,
	Value = {
		Min = 100,
		Max = 5000,
		Default = 1000,
	},
	Callback = function(value)
		cfg.EspRange = tonumber(value) or cfg.EspRange
	end,
}), "espRange", "espRangeDesc")

initTeleport()

bind(TeleportTab:Section({ Title = T("sectionTpPlayer") }), "sectionTpPlayer")

st.tpPlayerDropdown = TeleportTab:Dropdown({
	Title = T("tpPlayer"),
	Desc = T("tpPlayerDesc"),
	Values = tp.playerNames(),
	Callback = function(value)
		if value and value ~= "-" then
			tp.playerName = value
		end
	end,
})
bind(st.tpPlayerDropdown, "tpPlayer", "tpPlayerDesc")
tp.refreshPlayers()

bind(TeleportTab:Button({
	Title = T("tpToPlayer"),
	Icon = safeIcon("navigation"),
	Callback = function()
		tp.toPlayer()
	end,
}), "tpToPlayer")

bind(TeleportTab:Button({
	Title = T("tpViewPlayer"),
	Icon = safeIcon("eye"),
	Callback = function()
		tp.viewPlayer()
	end,
}), "tpViewPlayer")

bind(TeleportTab:Button({
	Title = T("tpStopView"),
	Icon = safeIcon("eye-off"),
	Callback = function()
		tp.stopView()
		notify("Xi Pro", T("tpViewOff"))
	end,
}), "tpStopView")

bind(TeleportTab:Section({ Title = T("sectionTpBlink") }), "sectionTpBlink")

bind(TeleportTab:Toggle({
	Title = T("tpBlink"),
	Desc = T("tpBlinkDesc"),
	Icon = safeIcon("mouse-pointer-click"),
	Value = false,
	Callback = function(value)
		if value then
			tp.startBlink()
		else
			tp.stopBlink()
		end
		notify("Xi Pro", cfg.Blink and T("tpBlinkOn") or T("tpBlinkOff"))
	end,
}), "tpBlink", "tpBlinkDesc")

bind(TeleportTab:Section({ Title = T("sectionTpMarker") }), "sectionTpMarker")

bind(TeleportTab:Button({
	Title = T("tpMarker"),
	Icon = safeIcon("map-pin"),
	Callback = function()
		tp.toMarker()
	end,
}), "tpMarker", "tpMarkerDesc")

bind(TeleportTab:Section({ Title = T("sectionTpLocation") }), "sectionTpLocation")

bind(TeleportTab:Input({
	Title = T("tpLocSearch"),
	Desc = T("tpLocSearchDesc"),
	Placeholder = "...",
	Callback = function(value)
		tp.locQuery = tostring(value or ""):lower()
		tp.refreshLocs()
	end,
}), "tpLocSearch", "tpLocSearchDesc")

st.tpLocDropdown = TeleportTab:Dropdown({
	Title = T("tpLocation"),
	Desc = T("tpLocationDesc"),
	Values = { "-" },
	Callback = function(value)
		if value and value ~= "-" then
			tp.locName = value
		end
	end,
})
bind(st.tpLocDropdown, "tpLocation", "tpLocationDesc")
tp.refreshLocs()

bind(TeleportTab:Button({
	Title = T("tpToLocation"),
	Icon = safeIcon("navigation"),
	Callback = function()
		tp.toLocation()
	end,
}), "tpToLocation")

bind(TeleportTab:Button({
	Title = T("tpViewLocation"),
	Icon = safeIcon("eye"),
	Callback = function()
		tp.viewLocation()
	end,
}), "tpViewLocation")

bind(TeleportTab:Section({ Title = T("sectionTpCrime") }), "sectionTpCrime")

st.tpCrimeFilterDropdown = TeleportTab:Dropdown({
	Title = T("tpCrimeFilter"),
	Desc = T("tpCrimeFilterDesc"),
	Values = tp.crimeFilterLabels(),
	Callback = function(value)
		tp.setCrimeFilter(value)
	end,
})
bind(st.tpCrimeFilterDropdown, "tpCrimeFilter", "tpCrimeFilterDesc")

st.tpCrimeDropdown = TeleportTab:Dropdown({
	Title = T("tpCrime"),
	Desc = T("tpCrimeDesc"),
	Values = { "-" },
	Callback = function(value)
		if value and value ~= "-" then
			tp.crimeName = value
		end
	end,
})
bind(st.tpCrimeDropdown, "tpCrime", "tpCrimeDesc")
tp.refreshCrimes()

bind(TeleportTab:Button({
	Title = T("tpToCrime"),
	Icon = safeIcon("navigation"),
	Callback = function()
		tp.toCrime()
	end,
}), "tpToCrime")

bind(TeleportTab:Button({
	Title = T("tpCrimeRefresh"),
	Icon = safeIcon("refresh-cw"),
	Callback = function()
		tp.refreshCrimes()
	end,
}), "tpCrimeRefresh")

bind(TeleportTab:Section({ Title = T("sectionTpSurface") }), "sectionTpSurface")

bind(TeleportTab:Button({
	Title = T("tpSurface"),
	Icon = safeIcon("arrow-up"),
	Callback = function()
		tp.surface()
	end,
}), "tpSurface", "tpSurfaceDesc")

initShop()

bind(ShopTab:Section({ Title = T("sectionShopBrowse") }), "sectionShopBrowse")

bind(ShopTab:Input({
	Title = T("shopSearch"),
	Desc = T("shopSearchDesc"),
	Placeholder = "...",
	Callback = function(value)
		shop.query = tostring(value or ""):lower()
		shop.refresh()
	end,
}), "shopSearch", "shopSearchDesc")

st.shopCatDropdown = ShopTab:Dropdown({
	Title = T("shopCategory"),
	Desc = T("shopCategoryDesc"),
	Values = shop.catLabels(),
	Callback = function(value)
		shop.setFilter(value)
	end,
})
bind(st.shopCatDropdown, "shopCategory", "shopCategoryDesc")

st.shopItemDropdown = ShopTab:Dropdown({
	Title = T("shopItem"),
	Desc = T("shopItemDesc"),
	Values = shop.labels(),
	Callback = function(value)
		if value and value ~= "-" then
			shop.selected = value
		end
	end,
})
bind(st.shopItemDropdown, "shopItem", "shopItemDesc")
shop.refresh()

bind(ShopTab:Button({
	Title = T("shopRefresh"),
	Icon = safeIcon("refresh-cw"),
	Callback = function()
		shop.refresh()
	end,
}), "shopRefresh")

bind(ShopTab:Section({ Title = T("sectionShopBuy") }), "sectionShopBuy")

bind(ShopTab:Slider({
	Title = T("shopQty"),
	Desc = T("shopQtyDesc"),
	Step = 1,
	Value = {
		Min = 1,
		Max = 20,
		Default = 1,
	},
	Callback = function(value)
		shop.qty = math.max(1, math.floor(tonumber(value) or 1))
	end,
}), "shopQty", "shopQtyDesc")

bind(ShopTab:Button({
	Title = T("shopBuy"),
	Icon = safeIcon("shopping-bag"),
	Callback = function()
		shop.buy()
	end,
}), "shopBuy")

bind(ShopTab:Button({
	Title = T("shopRefill"),
	Icon = safeIcon("repeat"),
	Callback = function()
		shop.refill()
	end,
}), "shopRefill")

initPlayers()

bind(PlayersTab:Section({ Title = T("sectionPlList") }), "sectionPlList")

bind(PlayersTab:Input({
	Title = T("plSearch"),
	Desc = T("plSearchDesc"),
	Placeholder = "...",
	Callback = function(value)
		pl.query = tostring(value or ""):lower()
		pl.refresh()
	end,
}), "plSearch", "plSearchDesc")

st.plSortDropdown = PlayersTab:Dropdown({
	Title = T("plSort"),
	Desc = T("plSortDesc"),
	Values = pl.sortLabels(),
	Callback = function(value)
		pl.setSort(value)
	end,
})
bind(st.plSortDropdown, "plSort", "plSortDesc")

st.plDropdown = PlayersTab:Dropdown({
	Title = T("plSelect"),
	Desc = T("plSelectDesc"),
	Values = pl.labels(),
	Callback = function(value)
		if value and value ~= "-" then
			pl.selected = value
			pl.paint()
		end
	end,
})
bind(st.plDropdown, "plSelect", "plSelectDesc")

st.plInfo = bind(PlayersTab:Paragraph({
	Title = T("plInfo"),
	Desc = T("plInfoEmpty"),
}), "plInfo")
pl.refresh()

bind(PlayersTab:Button({
	Title = T("plRefresh"),
	Icon = safeIcon("refresh-cw"),
	Callback = function()
		pl.refresh()
	end,
}), "plRefresh")

bind(PlayersTab:Section({ Title = T("sectionPlActions") }), "sectionPlActions")

bind(PlayersTab:Button({
	Title = T("plTeleport"),
	Icon = safeIcon("navigation"),
	Callback = function()
		pl.teleport()
	end,
}), "plTeleport")

bind(PlayersTab:Button({
	Title = T("plView"),
	Icon = safeIcon("eye"),
	Callback = function()
		pl.view()
	end,
}), "plView")

bind(PlayersTab:Button({
	Title = T("plStopView"),
	Icon = safeIcon("eye-off"),
	Callback = function()
		pl.stopView()
	end,
}), "plStopView")

bind(PlayersTab:Button({
	Title = T("plFollow"),
	Icon = safeIcon("user"),
	Callback = function()
		pl.follow()
	end,
}), "plFollow")

bind(PlayersTab:Button({
	Title = T("plStopFollow"),
	Icon = safeIcon("user"),
	Callback = function()
		pl.stopFollow()
	end,
}), "plStopFollow")

bind(PlayersTab:Button({
	Title = T("plLockAim"),
	Icon = safeIcon("crosshair"),
	Callback = function()
		pl.lock()
	end,
}), "plLockAim")

bind(PlayersTab:Button({
	Title = T("plNeverAim"),
	Icon = safeIcon("user-x"),
	Callback = function()
		pl.whitelist()
	end,
}), "plNeverAim")

bind(PlayersTab:Button({
	Title = T("plRam"),
	Icon = safeIcon("zap"),
	Callback = function()
		pl.ram()
	end,
}), "plRam")

bind(PlayersTab:Button({
	Title = T("plHunt"),
	Icon = safeIcon("zap"),
	Callback = function()
		pl.hunt()
	end,
}), "plHunt")

bind(PlayersTab:Button({
	Title = T("plSendCar"),
	Icon = safeIcon("send"),
	Callback = function()
		pl.send()
	end,
}), "plSendCar")

bind(PlayersTab:Button({
	Title = T("plPin"),
	Icon = safeIcon("pin"),
	Callback = function()
		pl.pin()
	end,
}), "plPin")

bind(PlayersTab:Button({
	Title = T("plCopy"),
	Icon = safeIcon("copy"),
	Callback = function()
		pl.copy()
	end,
}), "plCopy")

bind(PlayersTab:Section({ Title = T("sectionPlWatch") }), "sectionPlWatch")

bind(PlayersTab:Toggle({
	Title = T("plWatch"),
	Desc = T("plWatchDesc"),
	Icon = safeIcon("bell"),
	Value = false,
	Callback = function(value)
		cfg.PlrWatch = value and true or false
		table.clear(pl.nearAt)
		if cfg.PlrWatch then
			pl.start()
		end
	end,
}), "plWatch", "plWatchDesc")

st.plWatchDropdown = PlayersTab:Dropdown({
	Title = T("plWatchFor"),
	Desc = T("plWatchForDesc"),
	Values = pl.watchLabels(),
	Callback = function(value)
		pl.setWatch(value)
	end,
})
bind(st.plWatchDropdown, "plWatchFor", "plWatchForDesc")

bind(PlayersTab:Slider({
	Title = T("plWatchDist"),
	Desc = T("plWatchDistDesc"),
	Step = 5,
	Value = {
		Min = 30,
		Max = 500,
		Default = 150,
	},
	Callback = function(value)
		cfg.PlrWatchDist = tonumber(value) or cfg.PlrWatchDist
	end,
}), "plWatchDist", "plWatchDistDesc")

local function unload()
	cfg.AimAssist = false
	cfg.SilentAim = false
	cfg.Defense = false
	cfg.Ragebot = false
	cfg.JumpEnabled = false
	cfg.InfiniteJump = false
	cfg.AntiRagdoll = false
	cfg.AntiArrest = false
	cfg.AntiAfk = false
	cfg.AntiPrisonPull = false
	cfg.NoDamage = false
	cfg.Noclip = false
	cfg.Fly = false
	cfg.Ghost = false
	cfg.Stealth = false
	cfg.InfStamina = false
	cfg.InfHunger = false
	cfg.AutoCuff = false
	cfg.CuffTeleport = false
	cfg.KillAura = false
	cfg.CombatBlock = false
	cfg.InfAmmo = false
	cfg.NoReload = false
	cfg.AutoHack = false
	cfg.AutoAtm = false
	cfg.PickMoney = false
	cfg.AutoMission = false
	cfg.FarmBus = false
	cfg.FarmTaxi = false
	cfg.FarmFarmer = false
	cfg.FarmChef = false
	cfg.FarmGolf = false
	cfg.SpeedHud = false
	cfg.Cruise = false
	cfg.CollisionStop = false
	cfg.GroundLock = false
	cfg.Float = false
	cfg.NoCrashes = false
	cfg.FullFuel = false
	cfg.AutoRam = false
	cfg.FollowPlayer = false
	cfg.EspTracers = false
	cfg.EspOffscreen = false
	cfg.EspDots = false
	cfg.EspDetails = false
	cfg.EspHealth = false
	cfg.Blink = false
	cfg.PlrWatch = false
	st.moneyStarted = false
	st.rageRunning = false
	st.silentAutoTarget = nil
	pcall(stopDefense)
	pcall(stopJumpBoost)
	pcall(stopGhost)
	pcall(stopStealth)
	pcall(stopFly)
	pcall(stopNoclip)
	pcall(setAntiRagdoll, false)
	pcall(setAntiArrest, false)
	pcall(setAntiAfk, false)
	pcall(setAntiPrisonPull, false)
	pcall(setAutoCuff, false)
	pcall(setAutoHack, false)
	pcall(function()
		if veh and veh.stop then
			veh.stop()
		end
	end)
	pcall(function()
		if esp and esp.stop then
			esp.stop()
		end
	end)
	pcall(function()
		if tp and tp.stop then
			tp.stop()
		end
	end)
	pcall(function()
		if pl and pl.stop then
			pl.stop()
		end
	end)
	if st.ammoAddedConn then
		pcall(function()
			st.ammoAddedConn:Disconnect()
		end)
		st.ammoAddedConn = nil
	end
	stopFiring()
	for _, conn in ipairs(connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(connections)
	st.renderConn = nil
	if st.circleGui then
		pcall(function()
			st.circleGui:Destroy()
		end)
		st.circleGui = nil
		st.circleFrame = nil
	end
	if st.infoCard then
		pcall(function()
			st.infoCard:Destroy()
		end)
		st.infoCard = nil
	end
	if TopCharacter then
		pcall(function()
			TopCharacter:Destroy()
		end)
		TopCharacter = nil
	end
	pcall(function()
		if Window and Window.Destroy then
			Window:Destroy()
		elseif Window and Window.Close then
			Window:Close()
		end
	end)
	host.XiProSaintUnload = nil
end

host.XiProSaintUnload = unload
pcall(function()
	if Window.OnDestroy then
		Window:OnDestroy(unload)
	end
end)

notify("Xi Pro", T("loaded"))
task.defer(function()
	task.wait(0.8)
	notify("Xi Pro", T("riskNoticeShort"))
end)
pcall(function()
	Window:SelectTab(1)
end)
end
buildUi()
