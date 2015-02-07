------------------------------------------------------
-- City View
-- coded by bc1 from 1.0.3.276 brave new world code
-- code is common using gk_mode and bnw_mode switches
-- compatible with Gazebo's City-State Diplomacy Mod (CSD) for Brave New World v21
-- compatible with JFD's Piety & Prestige for Brave New World
-- compatible with GameInfo.Yields() iterator broken by Communitas
-- todo: sell building button
------------------------------------------------------
Events.SequenceGameInitComplete.Add(function()
print("Loading EUI city view...",os.clock(),[[ 
  ____ _ _       __     ___               
 / ___(_) |_ _   \ \   / (_) _____      __
| |   | | __| | | \ \ / /| |/ _ \ \ /\ / /
| |___| | |_| |_| |\ V / | |  __/\ V  V / 
 \____|_|\__|\__, | \_/  |_|\___| \_/\_/  
             |___/                        
]])

--todo: upper left corner
--todo: add meters
--todo: add meter cues
--todo: selection list with all buildable items
--todo: mod case where several buildings are allowed

local civ5_mode = InStrategicView ~= nil
local civBE_mode = not civ5_mode
local gk_mode = civBE_mode or Game.GetReligionName ~= nil
local bnw_mode = civBE_mode or Game.GetActiveLeague ~= nil
local civ5bnw_mode = civ5_mode and bnw_mode
local g_iconCurrency = civ5_mode and "[ICON_GOLD]" or "[ICON_ENERGY]"
local g_yieldCurrency = civ5_mode and YieldTypes.YIELD_GOLD or YieldTypes.YIELD_ENERGY
local g_focusCurrency = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD or CityAIFocusTypes.CITY_AI_FOCUS_TYPE_ENERGY

include( "EUI_utilities" )
include( "EUI_tooltips" ); local GetHelpTextForUnit = GetHelpTextForUnit; local GetHelpTextForBuilding = GetHelpTextForBuilding; local GetHelpTextForProject = GetHelpTextForProject; local GetHelpTextForProcess = GetHelpTextForProcess; local GetFoodTooltip = GetFoodTooltip; local GetGoldTooltip = civ5_mode and GetGoldTooltip or GetEnergyTooltip; local GetScienceTooltip = GetScienceTooltip; local GetProductionTooltip = GetProductionTooltip; local GetCultureTooltip = GetCultureTooltip; local GetFaithTooltip = GetFaithTooltip; local GetTourismTooltip = GetTourismTooltip
include( "SupportFunctions" ); local TruncateString = TruncateString
if not civ5_mode then
	include( "IntrigueHelper" )
end
local IconLookup = EUI.IconLookup
local IconHookup = EUI.IconHookup
local CivIconHookup = EUI.CivIconHookup
local CityPlots = EUI.CityPlots
local InstanceStackManager = EUI.InstanceStackManager
local table = EUI.table
local YieldIcons = EUI.YieldIcons

-------------------------------
-- minor lua optimizations
-------------------------------

local math = math
--local os = os
--local pairs = pairs
local ipairs = ipairs
local pcall = pcall
--local print = print
local select = select
--local string = string
--local table = table
--local tonumber = tonumber
local tostring = tostring
--local type = type
local unpack = unpack

local UI = UI
--local UIManager = UIManager
local Controls = Controls
local ContextPtr = ContextPtr
local Players = Players
--local Teams = Teams
local GameInfo = EUI.GameInfoCache -- warning! use iterator ONLY with table field conditions, NOT string SQL query
--local GameInfoActions = GameInfoActions
local GameInfoTypes = GameInfoTypes
local GameDefines = GameDefines
--local InterfaceDirtyBits = InterfaceDirtyBits
local CityUpdateTypes = CityUpdateTypes
local ButtonPopupTypes = ButtonPopupTypes
local YieldTypes = YieldTypes
local GameOptionTypes = GameOptionTypes
--local DomainTypes = DomainTypes
--local FeatureTypes = FeatureTypes
--local FogOfWarModeTypes = FogOfWarModeTypes
local OrderTypes = OrderTypes
--local PlotTypes = PlotTypes
--local TerrainTypes = TerrainTypes
local InterfaceModeTypes = InterfaceModeTypes
local NotificationTypes = NotificationTypes
--local ActivityTypes = ActivityTypes
--local MissionTypes = MissionTypes
--local ActionSubTypes = ActionSubTypes
local GameMessageTypes = GameMessageTypes
local TaskTypes = TaskTypes
--local CommandTypes = CommandTypes
--local DirectionTypes = DirectionTypes
--local DiploUIStateTypes = DiploUIStateTypes
--local FlowDirectionTypes = FlowDirectionTypes
--local PolicyBranchTypes = PolicyBranchTypes
--local FromUIDiploEventTypes = FromUIDiploEventTypes
--local CoopWarStates = CoopWarStates
--local ThreatTypes = ThreatTypes
--local DisputeLevelTypes = DisputeLevelTypes
--local LeaderheadAnimationTypes = LeaderheadAnimationTypes
--local TradeableItems = TradeableItems
--local EndTurnBlockingTypes = EndTurnBlockingTypes
--local ResourceUsageTypes = ResourceUsageTypes
--local MajorCivApproachTypes = MajorCivApproachTypes
--local MinorCivTraitTypes = MinorCivTraitTypes
--local MinorCivPersonalityTypes = MinorCivPersonalityTypes
--local MinorCivQuestTypes = MinorCivQuestTypes
local CityAIFocusTypes = CityAIFocusTypes
--local AdvisorTypes = AdvisorTypes
--local GenericWorldAnchorTypes = GenericWorldAnchorTypes
--local GameStates = GameStates
--local GameplayGameStateTypes = GameplayGameStateTypes
--local CombatPredictionTypes = CombatPredictionTypes
--local ChatTargetTypes = ChatTargetTypes
--local ReligionTypes = ReligionTypes
--local BeliefTypes = BeliefTypes
--local FaithPurchaseTypes = FaithPurchaseTypes
--local ResolutionDecisionTypes = ResolutionDecisionTypes
--local InfluenceLevelTypes = InfluenceLevelTypes
--local InfluenceLevelTrend = InfluenceLevelTrend
--local PublicOpinionTypes = PublicOpinionTypes
--local ControlTypes = ControlTypes

--local PreGame = PreGame
local Game = Game
--local Map = Map
local OptionsManager = OptionsManager
local Events = Events
local Mouse = Mouse
--local MouseEvents = MouseEvents
--local MouseOverStrategicViewResource = MouseOverStrategicViewResource
local Locale = Locale
local L = Locale.ConvertTextKey
--getmetatable("").__index.L = L
if civBE_mode then
	function InStrategicView()
		return false
	end
end
local InStrategicView = InStrategicView

-------------------------------
-- Globals
-------------------------------

local g_options = Modding.OpenUserData( "Enhanced User Interface Options", 1)
local g_isAdvisor = true

local g_activePlayerID = Game.GetActivePlayer()
local g_activePlayer = Players[ g_activePlayerID ]
local g_finishedItems = {}

local g_workerHeadingOpen = OptionsManager.IsNoCitizenWarning()

local g_rightTipControls = {}
local g_leftTipControls = {}
TTManager:GetTypeControlTable( "EUI_CityViewRightTooltip", g_rightTipControls )
TTManager:GetTypeControlTable( "EUI_CityViewLeftTooltip", g_leftTipControls )

local g_worldPositionOffset = { x = 0, y = 0, z = 30 }
local g_worldPositionOffset2 = { x = 0, y = 35, z = 0 }
local g_portraitSize = Controls.PQportrait:GetSizeX()
local g_screenHeight = select(2, UIManager:GetScreenSizeVal() )
local g_leftStackHeigth = g_screenHeight - 40 - Controls.CityInfoBG:GetOffsetY() - Controls.CityInfoBG:GetSizeY()

local g_PlotButtonIM	= InstanceStackManager( "PlotButtonInstance", "PlotButtonAnchor", Controls.PlotButtonContainer )
local g_BuyPlotButtonIM	= InstanceStackManager( "BuyPlotButtonInstance", "BuyPlotButtonAnchor", Controls.PlotButtonContainer )
local g_ProdQueueIM, g_SpecialBuildingsIM, g_GreatWorkIM, g_WondersIM, g_BuildingsIM, g_GreatPeopleIM, g_SlackerIM, g_UnitSelectIM, g_BuildingSelectIM, g_WonderSelectIM, g_ProcessSelectIM, g_FocusSelectIM

local g_citySpecialists = {}

local g_queuedItemNumber = false
local g_isRazeButtonDisabled = false
local g_isViewingMode = true
local g_BuyPlotMode = not ( g_options and g_options.GetValue and g_options.GetValue( "CityPlotPurchaseIsOff" ) == 1 )
local g_previousCity, g_isCityViewDirty, g_isCityHexesDirty
local g_toolTipHandler, g_toolTipControl, RequestToolTip

local g_autoUnitCycleRequest -- workaround hack

local g_slotTexture = {
	SPECIALIST_CITIZEN = "CitizenUnemployed.dds",
	SPECIALIST_SCIENTIST = "CitizenScientist.dds",
	SPECIALIST_MERCHANT = "CitizenMerchant.dds",
	SPECIALIST_ARTIST = "CitizenArtist.dds",
	SPECIALIST_MUSICIAN = "CitizenArtist.dds",
	SPECIALIST_WRITER = "CitizenArtist.dds",
	SPECIALIST_ENGINEER = "CitizenEngineer.dds",
	SPECIALIST_CIVIL_SERVANT = "CitizenCivilServant.dds",	-- Compatibility with Gazebo's City-State Diplomacy Mod (CSD) for Brave New World
	SPECIALIST_JFD_MONK = "CitizenMonk.dds", -- Compatibility with JFD's Piety & Prestige for Brave New World
}
local g_slackerTexture = civBE_mode and "UnemployedIndicator.dds" or g_slotTexture[ (GameInfo.Specialists[GameDefines.DEFAULT_SPECIALIST or -1] or {}).Type ] or "Blank.dds"

--local g_colorWhite = {x=1, y=1, z=1, w=1}
--local g_colorGreen = {x=0, y=1, z=0, w=1}
--local g_colorYellow = {x=1, y=1, z=0, w=1}
--local g_colorRed = {x=1, y=0, z=0, w=1}
local g_colorCulture = {x=1, y=0, z=1, w=1}
local g_nullOffset = {x=0, y=0}

local g_gameInfo = {
[OrderTypes.ORDER_TRAIN] = GameInfo.Units,
[OrderTypes.ORDER_CONSTRUCT] = GameInfo.Buildings,
[OrderTypes.ORDER_CREATE] = GameInfo.Projects,
[OrderTypes.ORDER_MAINTAIN] = GameInfo.Processes,
}
local g_avisorRecommended = {
[OrderTypes.ORDER_TRAIN] = Game.IsUnitRecommended,
[OrderTypes.ORDER_CONSTRUCT] = Game.IsBuildingRecommended,
[OrderTypes.ORDER_CREATE] = Game.IsProjectRecommended,
}
local g_advisorControls = {
[AdvisorTypes.ADVISOR_ECONOMIC] = "EconomicRecommendation",
[AdvisorTypes.ADVISOR_MILITARY] = "MilitaryRecommendation",
[AdvisorTypes.ADVISOR_SCIENCE] = "ScienceRecommendation",
[AdvisorTypes.ADVISOR_FOREIGN] = "ForeignRecommendation",
}

local function SetupCallbacks( controls, toolTips, tootTipType, callBacks )
	local control
	-- Setup Tootips
	for name, callback in pairs( toolTips ) do
		control = controls[name]
		if control then
			control:SetToolTipCallback( callback )
			control:SetToolTipType( tootTipType )
		end
	end
	-- Setup Callbacks
	for name, eventCallbacks in pairs( callBacks ) do
		control = controls[name]
		if control then
			for event, callback in pairs( eventCallbacks ) do
				control:RegisterCallback( event, callback )
			end
		end
	end
end

local function ResizeProdQueue()
	local selectionPanelHeight = 0
	local queuePanelHeight = math.min( 190, Controls.QueueStack:IsHidden() and 0 or Controls.QueueStack:GetSizeY() )	-- 190 = 5 x 38=instance height
	if not Controls.SelectionScrollPanel:IsHidden() then
		Controls.SelectionStacks:CalculateSize()
		selectionPanelHeight = math.max( math.min( g_leftStackHeigth - queuePanelHeight, Controls.SelectionStacks:GetSizeY() ), 64 )
--		Controls.SelectionBackground:SetSizeY( selectionPanelHeight + 85 )
		Controls.SelectionScrollPanel:SetSizeY( selectionPanelHeight )
		Controls.SelectionScrollPanel:CalculateInternalSize()
		Controls.SelectionScrollPanel:ReprocessAnchoring()
	end
	Controls.QueueSlider:SetSizeY( queuePanelHeight + 38 )				-- 38 = Controls.PQbox:GetSizeY()
	Controls.QueueScrollPanel:SetSizeY( queuePanelHeight )
	Controls.QueueScrollPanel:CalculateInternalSize()
	Controls.QueueBackground:SetSizeY( queuePanelHeight + selectionPanelHeight + 152 )	-- 125 = 38=Controls.PQbox:GetSizeY() + 87 + 27
	return Controls.QueueBackground:ReprocessAnchoring()
end

local function ResizeRightStack()
	Controls.BoxOSlackers:SetHide( Controls.SlackerStack:IsHidden() )
	Controls.BoxOSlackers:SetSizeY( Controls.SlackerStack:GetSizeY() )
	Controls.WorkerManagementBox:CalculateSize()
	Controls.WorkerManagementBox:ReprocessAnchoring()
	Controls.RightStack:CalculateSize()
	local rightStackHeight = Controls.RightStack:GetSizeY() + 85
	Controls.BuildingListBackground:SetSizeY( math.max( math.min( g_screenHeight + 48, rightStackHeight ), 160 ) )
	Controls.RightScrollPanel:SetSizeY( math.min( g_screenHeight - 38, rightStackHeight ) )
	Controls.RightScrollPanel:CalculateInternalSize()
	return Controls.RightScrollPanel:ReprocessAnchoring()
end

local function isActivePlayerTurn()
	return g_activePlayer:IsTurnActive()
end

local function isActivePlayerAllowed()
	return not g_isViewingMode and isActivePlayerTurn()
end

local cityIsCanPurchase
if gk_mode then
	function cityIsCanPurchase( city, ... )
		return city:IsCanPurchase( ... )
	end
else
	function cityIsCanPurchase( city, bTestPurchaseCost, bTestTrainable, unitID, buildingID, projectID, yieldID )
		if yieldID == g_yieldCurrency then
			return city:IsCanPurchase( not bTestPurchaseCost, unitID, buildingID, projectID )
							-- bOnlyTestVisible
		else
			return false
		end
	end
end

local function cityCouldEverBuild( city, buildingID )
-- TODO
end

-------------------------------------------------
-- Clear out the UI so that when a player changes
-- the next update doesn't show the previous player's
-- values for a frame
-------------------------------------------------
local function ClearCityUIInfo()
	g_ProdQueueIM.ResetInstances()
	g_ProdQueueIM.Commit()
	Controls.PQrank:SetHide( true )
	Controls.PQremove:SetHide( true )
	Controls.PQname:SetText("")
	Controls.PQturns:SetText("")
	return Controls.ProductionPortraitButton:SetHide(true)
end

--------------------
-- Selling Buildings
--------------------
local function OnBuildingClicked( buildingID )

	local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()

	-- Can this building be sold?
	if city and city:IsBuildingSellable(buildingID) then

		-- Build info string
		local building = GameInfo.Buildings[ buildingID ]

		Controls.SellBuildingPopupText:SetText( L(building.Description) .. ": "
			.. L( "TXT_KEY_SELL_BUILDING_INFO", city:GetSellBuildingRefund(buildingID), building.GoldMaintenance or 0 ) )
--todo energy


		Controls.YesButton:SetVoids( city:GetID(), buildingID )

		return Controls.SellBuildingConfirm:SetHide(false)
	end
end

local function CancelBuildingSale()
	Controls.SellBuildingConfirm:SetHide(true)
	return Controls.YesButton:SetVoids( -1, -1 )
end

local function GotoNextCity()
	CancelBuildingSale()
	Controls.RightScrollPanel:SetScrollValue(0)
	return Game.DoControl( GameInfoTypes.CONTROL_NEXTCITY )
end

local function GotoPrevCity()
	CancelBuildingSale()
	Controls.RightScrollPanel:SetScrollValue(0)
	return Game.DoControl( GameInfoTypes.CONTROL_PREVCITY )
end

local function ExitCityScreen()
	-- clear any rogue leftover tooltip
	g_leftTipControls.Box:SetHide( true )
	g_rightTipControls.Box:SetHide( true )
	g_toolTipHandler = nil
	return Events.SerialEventExitCityScreen()
end

----------------------------------------------------------------
-- Input handling
----------------------------------------------------------------
ContextPtr:SetInputHandler(
function( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			if Controls.SellBuildingConfirm:IsHidden() then
				ExitCityScreen()
			else
				CancelBuildingSale()
			end
			return true
		elseif wParam == Keys.VK_LEFT then
			GotoPrevCity()
			return true
		elseif wParam == Keys.VK_RIGHT then
			GotoNextCity()
			return true
		end
	end
	return false
end)

-------------------------------
-- Pedia
-------------------------------
local function UnitClassPedia( unitClassID )
	return Events.SearchForPediaEntry( GameInfo.UnitClasses[ unitClassID ].Description )
end

local function BuildingPedia( buildingID )
	return Events.SearchForPediaEntry( GameInfo.Buildings[ buildingID ].Description )
end

local function SpecialistPedia( buildingID )
	local building = buildingID and GameInfo.Buildings[ buildingID ]
	local specialistType = building and building.SpecialistType
	local specialistID = specialistType and GameInfoTypes[specialistType] or GameDefines.DEFAULT_SPECIALIST
	local specialist = specialistID and GameInfo.Specialists[ specialistID ]
	return Events.SearchForPediaEntry( specialist and specialist.Description or "" )
end

local function SelectionPedia( orderID, itemID )
	local item = g_gameInfo[ orderID ]
	item = item and item[ itemID ]
	if item then
		return Events.SearchForPediaEntry( item.Description )
	end
end

local function ProductionPedia( queuedItemNumber )
	local city = UI.GetHeadSelectedCity()
	if city and queuedItemNumber then
		return SelectionPedia( city:GetOrderFromQueue( queuedItemNumber ) )
	end
end

-------------------------------
-- Tooltips
-------------------------------

local function GetSpecialistYields( city, specialist )
	local yieldTips = table()
	local specialistID = specialist.ID
	if city then
		-- Culture
		local cultureFromSpecialist = city:GetCultureFromSpecialist( specialistID )
		-- Yield
		for yieldID = 0, YieldTypes.NUM_YIELD_TYPES-1 do
			local specialistYield = city:GetSpecialistYield( specialistID, yieldID )
			-- COMMUNITY PATCH BEGINS
				local extraYield = city:GetSpecialistYieldChange( specialistID, yieldID)
				if(specialistYield > 0) then
					specialistYield = (specialistYield + extraYield)
				end
			-- COMMUNITY PATCH ENDS
			if specialistYield > 0 then
				yieldTips:insert( specialistYield .. (YieldIcons[yieldID] or "") )
				if yieldID == YieldTypes.YIELD_CULTURE then
					cultureFromSpecialist = 0
				end
			end
		end
		if cultureFromSpecialist > 0 then
			yieldTips:insert( cultureFromSpecialist .. "[ICON_CULTURE]" )
		end
	end
	if civ5_mode and (specialist.GreatPeopleRateChange or 0) > 0 then
		yieldTips:insert( specialist.GreatPeopleRateChange .. "[ICON_GREAT_PEOPLE]" )
	end
	return yieldTips:concat(" ")
end

local function SpecialistTooltipNow( control )
	local buildingID = control:GetVoid1()
	local building = buildingID and GameInfo.Buildings[ buildingID ]
	local specialistType = building and building.SpecialistType
	local specialistID = specialistType and GameInfoTypes[specialistType] or GameDefines.DEFAULT_SPECIALIST
	local specialist = GameInfo.Specialists[ specialistID ]
	local strToolTip = L(specialist.Description) .. " " .. GetSpecialistYields( UI.GetHeadSelectedCity(), specialist )
	local slotTable = building and g_citySpecialists[buildingID]
	if slotTable and not slotTable[control:GetVoid2()] then
		strToolTip = L"TXT_KEY_CITYVIEW_EMPTY_SLOT".."[NEWLINE]("..strToolTip..")"
	end
	g_rightTipControls.Text:SetText( strToolTip )
	IconHookup( specialist.PortraitIndex, g_rightTipControls.Portrait:GetSizeY(), specialist.IconAtlas, g_rightTipControls.Portrait )
	g_rightTipControls.Box:SetHide( false )
	return g_rightTipControls.Box:DoAutoSize()
end
local function SpecialistTooltip( control )
	return RequestToolTip( SpecialistTooltipNow, control )
end

local function BuildingToolTipNow( control )
	local buildingID = control:GetVoid1()
	local building = GameInfo.Buildings[ buildingID ]
	local city = UI.GetHeadSelectedCity()
	if city and building then

		local strToolTip = GetHelpTextForBuilding( buildingID, false, false, city:GetNumFreeBuilding(buildingID) > 0, city )

		-- Can we sell this thing?
		if not g_isViewingMode and city:IsBuildingSellable(buildingID) then
			strToolTip = strToolTip .. "[NEWLINE]----------------[NEWLINE][COLOR_YELLOW]" .. L"TXT_KEY_CLICK_TO_SELL" .. "[ENDCOLOR] -> " .. city:GetSellBuildingRefund(buildingID) .. g_iconCurrency
		end
		g_rightTipControls.Text:SetText( strToolTip )
		IconHookup( building.PortraitIndex, g_rightTipControls.Portrait:GetSizeY(), building.IconAtlas, g_rightTipControls.Portrait )
		g_rightTipControls.Box:SetHide( false )
		return g_rightTipControls.Box:DoAutoSize()
	end
end
local function BuildingToolTip( control )
	return RequestToolTip( BuildingToolTipNow, control )
end

local function OrderItemTooltip( city, isDisabled, purchaseYieldID, orderID, itemID )
	local itemInfo, strToolTip, strDisabledInfo, portraitOffset, portraitAtlas
	if city then
		if orderID == OrderTypes.ORDER_TRAIN then
			itemInfo = GameInfo.Units
			portraitOffset, portraitAtlas = UI.GetUnitPortraitIcon( itemID, city:GetOwner() )
			strToolTip = GetHelpTextForUnit( itemID, true )

			if isDisabled then
				if purchaseYieldID == g_yieldCurrency then
					strDisabledInfo = city:GetPurchaseUnitTooltip(itemID)
				elseif purchaseYieldID == YieldTypes.YIELD_FAITH then
					strDisabledInfo = city:GetFaithPurchaseUnitTooltip(itemID)
				else
					strDisabledInfo = city:CanTrainTooltip(itemID)
				end
			end

		elseif orderID == OrderTypes.ORDER_CONSTRUCT then
			itemInfo = GameInfo.Buildings
			strToolTip = GetHelpTextForBuilding( itemID, false, false, city:GetNumFreeBuilding(itemID) > 0, city )
			if isDisabled then
				if purchaseYieldID == g_yieldCurrency then
					strDisabledInfo = city:GetPurchaseBuildingTooltip(itemID)
				elseif purchaseYieldID == YieldTypes.YIELD_FAITH then
					strDisabledInfo = city:GetFaithPurchaseBuildingTooltip(itemID)
				else
					strDisabledInfo = city:CanConstructTooltip(itemID)
				end
			end

		elseif orderID == OrderTypes.ORDER_CREATE then
			itemInfo = GameInfo.Projects
			strToolTip = GetHelpTextForProject( itemID, true )
		elseif orderID == OrderTypes.ORDER_MAINTAIN then
			itemInfo = GameInfo.Processes
			strToolTip = GetHelpTextForProcess( itemID, true )
		else
			strToolTip = L"TXT_KEY_PRODUCTION_NO_PRODUCTION"
		end
		if strToolTip then
			if strDisabledInfo and #strDisabledInfo > 0 then
				strToolTip = "[COLOR_WARNING_TEXT]" .. (strDisabledInfo:gsub("^%[NEWLINE%]","")):gsub("^%[NEWLINE%]","") .. "[ENDCOLOR][NEWLINE][NEWLINE]"..strToolTip
			elseif purchaseYieldID then
				if not isDisabled then
					strToolTip = "[COLOR_YELLOW]"..L"TXT_KEY_CITYVIEW_PURCHASE_TT".."[ENDCOLOR][NEWLINE][NEWLINE]"..strToolTip
				end
			elseif isDisabled then
				strToolTip = "[COLOR_YIELD_FOOD]"..L"TXT_KEY_CITYVIEW_QUEUE_PROD_TT".."[ENDCOLOR][NEWLINE][NEWLINE]"..strToolTip
			end
		end
		local item = itemInfo and itemInfo[itemID]
		item = item and IconHookup( portraitOffset or item.PortraitIndex, g_leftTipControls.Portrait:GetSizeY(), portraitAtlas or item.IconAtlas, g_leftTipControls.Portrait )
		g_leftTipControls.Text:SetText( strToolTip )
		g_leftTipControls.PortraitFrame:SetHide( not item )
		g_leftTipControls.Box:DoAutoSize()
	end
	return g_leftTipControls.Box:SetHide( not strToolTip )
end

local function ProductionToolTipNow( control )
	local city = UI.GetHeadSelectedCity()
	local queuedItemNumber = control:GetVoid1()
	if city and queuedItemNumber and not Controls.QueueSlider:IsTrackingLeftMouseButton() then
		return OrderItemTooltip( city, false, false, city:GetOrderFromQueue( queuedItemNumber ) )
	end
end
local function ProductionToolTip( control )
	return RequestToolTip( ProductionToolTipNow, control )
end

local function SelectionToolTipNow( control )
	return OrderItemTooltip( UI.GetHeadSelectedCity(), true, false, control:GetVoid1(), control:GetVoid2() )
end
local function SelectionToolTip( control )
	return RequestToolTip( SelectionToolTipNow, control )
end

-------------------------------
-- Specialist Managemeent
-------------------------------
local function OnSlackersSelected( buildingID, slotID )
	local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
	if city then
		for i=1, slotID<=0 and city:GetSpecialistCount( GameDefines.DEFAULT_SPECIALIST ) or 1 do
			Network.SendDoTask( city:GetID(), TaskTypes.TASK_REMOVE_SLACKER, 0, -1, false )
		end
	end
end

local function ToggleSpecialist( buildingID, slotID )
	local city = buildingID and slotID and isActivePlayerAllowed() and UI.GetHeadSelectedCity()
	if city then

		-- If Specialists are automated then you can't change things with them
		if civ5_mode and not city:IsNoAutoAssignSpecialists() then
			Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS, -1, -1, true)
			Controls.NoAutoSpecialistCheckbox:SetCheck(true)
			if bnw_mode then
				Controls.NoAutoSpecialistCheckbox2:SetCheck(true)
			end
		end

		local specialistID = GameInfoTypes[(GameInfo.Buildings[ buildingID ] or {}).SpecialistType] or -1
		local specialistTable = g_citySpecialists[buildingID]
		if specialistTable[slotID] then
			if city:GetNumSpecialistsInBuilding(buildingID) > 0 then
				specialistTable[slotID] = false
				specialistTable.n = specialistTable.n - 1
				return Game.SelectedCitiesGameNetMessage( GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_REMOVE_SPECIALIST, specialistID, buildingID )
			end
		elseif city:IsCanAddSpecialistToBuilding(buildingID) then
			specialistTable[slotID] = true
			specialistTable.n = specialistTable.n + 1
			return Game.SelectedCitiesGameNetMessage( GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_ADD_SPECIALIST, specialistID, buildingID )
		end
	end
end

-------------------------------
-- Great Work Managemeent
-------------------------------
local function GreatWorkPopup( greatWorkID )
	local greatWork = GameInfo.GreatWorks[ Game.GetGreatWorkType( greatWorkID or -1 ) or -1 ]

	if greatWork and greatWork.GreatWorkClassType ~= "GREAT_WORK_ARTIFACT" then
		return Events.SerialEventGameMessagePopup{
			Type = ButtonPopupTypes.BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER,
			Data1 = greatWorkID,
			Priority = PopupPriority.Current
			}
	end
end

local function YourCulturePopup( greatWorkID )
	return Events.SerialEventGameMessagePopup{
		Type = ButtonPopupTypes.BUTTONPOPUP_CULTURE_OVERVIEW,
		Data1 = 1,
		Data2 = 1,
		}
end

local function ThemingTooltip( buildingClassID, void2, control )
	control:SetToolTipString( UI.GetHeadSelectedCity():GetThemingTooltip( buildingClassID ) )
end

local function GreatWorkTooltip( greatWorkID, greatWorkSlotID, slot )
	if greatWorkID >= 0 then
		return slot:SetToolTipString( Game.GetGreatWorkTooltip( greatWorkID, UI.GetHeadSelectedCity():GetOwner() ) )
	else
		return slot:LocalizeAndSetToolTip( ( GameInfo.GreatWorkSlots[ greatWorkSlotID ] or {}).EmptyToolTipText or "" )
	end
end

-------------------------------------------------
-- City Buildings List
-------------------------------------------------

local function sortBuildings(a,b)
	if a and b then
		if a[4] ~= b[4] then
			return a[4] < b[4]
		elseif a[3] ~= b[3] then
			return a[3] > b[3]
		end
		return a[2] < b[2]
	end
end

local function SetupBuildingList( city, buildings, buildingIM )
	buildingIM.ResetInstances()
	buildings:sort( sortBuildings )
-- Get the active perk types.  It is better to get this once and pass it around, rather than having each function re-get it every time.
-- local activePerkTypes = civBE_mode and g_activePlayer:GetAllActivePlayerPerkTypes()
	for i = 1, #buildings do

		local building, buildingName, greatWorkCount = unpack(buildings[i])
		local buildingID = building.ID
		local instance = buildingIM.GetInstance()
		local buildingButton = instance.Button
		local slotStack = instance.SlotStack
		slotStack:DestroyAllChildren()

		if civ5_mode and building.IsReligious then
			buildingName = L( "TXT_KEY_RELIGIOUS_BUILDING", buildingName, Players[city:GetOwner()]:GetStateReligionKey() )
		end
		if city:GetNumFreeBuilding( buildingID ) > 0 then
			buildingName = buildingName .. " (" .. L"TXT_KEY_FREE" .. ")"
		end
		instance.Name:SetText( buildingName )
--BE portrait size is bigger

		instance.Portrait:SetHide( not IconHookup( building.PortraitIndex, 64, building.IconAtlas, instance.Portrait ) )

--[[!!!BE MODE
		-- Build stats/bonuses (most logic pulled from InfoToolTipInclude.lua)			
		local buildingClass = building.BuildingClass
		local buildingClassID = GameInfoTypes( buildingClass )
		local lines = {}
		local strBuildingStats = ""

--		for _, yieldInfo in ipairs(CachedYieldInfoArray) do
		for yieldID = 0, YieldTypes.NUM_YIELD_TYPES-1 do

			-- Yield changes from the building
			local yieldChange = Game.GetBuildingYieldChange( buildingID, yieldID )
			if city then
				yieldChange = yieldChange + city:GetReligionBuildingClassYieldChange( buildingClassID, yieldID )
							+ g_activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, yieldID)
							+ city:GetLeagueBuildingClassYieldChange( buildingClassID, yieldID )
			end
			-- Yield changes from PLAYER PERKS
			yieldChange = yieldChange + GetPlayerPerkBuildingFlatYieldChanges(activePerkTypes, g_activePlayerID, buildingID, yieldID)

			if yieldChange ~= 0 then
				table.insert(lines, Locale.ConvertTextKey("TXT_KEY_STAT_POSITIVE_YIELD", yieldInfo.IconString, yieldChange))
			end

			-- MOD Yield from the building
			local yieldModifier = Game.GetBuildingYieldModifier( buildingID, yieldID )
			-- MOD from Virtues
						+ g_activePlayer:GetPolicyBuildingClassYieldModifier( buildingClassID, yieldID )
			-- MOD from Player Perks
						+ GetPlayerPerkBuildingPercentYieldChanges( activePerkTypes, g_activePlayerID, buildingID, yieldID )

			if yieldModifier ~= 0 then
				table.insert(lines, Locale.ConvertTextKey("TXT_KEY_STAT_POSITIVE_YIELD_MOD", yieldInfo.IconString, yieldModifier))
			end
		end
		
		-- FLAT Health
		local iHealthTotal = 0
		local iHealth = building.Health
		if (iHealth ~= nil) then
			iHealthTotal = iHealthTotal + iHealth
		end
		if(building.UnmoddedHealth ~= nil) then
			local iHealth = building.UnmoddedHealth
			if (iHealth ~= nil) then
				iHealthTotal = iHealthTotal + iHealth
			end
		end
		-- Health from Virtues
		iHealthTotal = iHealthTotal + g_activePlayer:GetExtraBuildingHealthFromPolicies( buildingID )
		-- Health from Player Perks
		local iHealthFromPerks = GetPlayerPerkBuildingFlatHealthChanges(activePerkTypes, g_activePlayerID, buildingID)
		iHealthTotal = iHealthTotal + iHealthFromPerks

		if (iHealthTotal ~= 0) then
			table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HEALTH", iHealthTotal))
		end

		-- MOD Health
		local iHealthMod = building.HealthModifier
		-- MOD from Player Perks
		local iHealthModFromPerks = GetPlayerPerkBuildingPercentHealthChanges(activePerkTypes, g_activePlayerID, buildingID)
		iHealthMod = iHealthMod + iHealthModFromPerks

		if (iHealthMod ~= nil and iHealthMod ~= 0) then
			table.insert(lines, Locale.ConvertTextKey("TXT_KEY_STAT_POSITIVE_YIELD_MOD", HEALTH_ICON, iHealthMod))
		end
	
		-- City Strength
		local iCityStrength = building.Defense
		-- City Strength from PLAYER PERKS
		local iCityStrengthFromPerks = GetPlayerPerkBuildingCityStrengthChanges(activePerkTypes, g_activePlayerID, buildingID)
		if (iCityStrengthFromPerks ~= nil and iCityStrengthFromPerks ~= 0) then
			iCityStrength = iCityStrength + iCityStrengthFromPerks
		end
		if (iCityStrength ~= nil and iCityStrength ~= 0) then
			table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_DEFENSE", iCityStrength / 100))
		end
	
		-- City Hit Points
		local iHitPoints = building.ExtraCityHitPoints
		-- City Hit Points from PLAYER PERKS
		local iCityHPFromPerks = GetPlayerPerkBuildingCityHPChanges(activePerkTypes, g_activePlayerID, buildingID)
		if (iCityHPFromPerks ~= nil and iCityHPFromPerks ~= 0) then
			iHitPoints = iHitPoints + iCityHPFromPerks
		end
		if (iHitPoints ~= nil and iHitPoints ~= 0) then
			table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HITPOINTS", iHitPoints))
		end

		-- If there are standard yields to add
		if #lines > 0 then
			strBuildingStats = strBuildingStats .. table.concat(lines, "  ")
			lines = {}
		end

		controlTable.BuildingStats:SetString( strBuildingStats )
--BE MODE ]]
		-------------------
		-- Great Work Slots
		if greatWorkCount > 0 then
			local buildingGreatWorkSlotType = building.GreatWorkSlotType
			if buildingGreatWorkSlotType then
				local buildingGreatWorkSlot = GameInfo.GreatWorkSlots[ buildingGreatWorkSlotType ]
				local buildingClassID = GameInfoTypes[ building.BuildingClass ]

				if city:IsThemingBonusPossible( buildingClassID ) then
					local labelInstance = {}
					ContextPtr:BuildInstanceForControl( "LabelInstance", labelInstance, slotStack )
					labelInstance.Text:SetText( " +" .. city:GetThemingBonus( buildingClassID ) )
					labelInstance.Text:SetVoid1( buildingClassID )
					labelInstance.Text:RegisterCallback( Mouse.eLClick, YourCulturePopup )
					labelInstance.Text:RegisterCallback( Mouse.eMouseEnter, ThemingTooltip )
				end

				for i = 0, greatWorkCount - 1 do
					local instance = {}
					ContextPtr:BuildInstanceForControl( "SlotInstance2", instance, slotStack )
					local slot = instance.Button
					local greatWorkID = city:GetBuildingGreatWork( buildingClassID, i )
					slot:SetVoid1( greatWorkID )
					if greatWorkID >= 0 then
						slot:SetTexture( buildingGreatWorkSlot.FilledIcon )
						slot:RegisterCallback( Mouse.eRClick, GreatWorkPopup )
					else
						slot:SetTexture( buildingGreatWorkSlot.EmptyIcon )
						slot:SetVoid2( buildingGreatWorkSlot.ID )
						slot:ClearCallback( Mouse.eRClick )
					end
					slot:RegisterCallback( Mouse.eLClick, YourCulturePopup )
					slot:RegisterCallback( Mouse.eMouseEnter, GreatWorkTooltip )
				end
			end
		end

		-------------------
		-- Specialist Slots
		local numSpecialistsInBuilding = city:GetNumSpecialistsInBuilding( buildingID )
		local specialistTable = g_citySpecialists[buildingID] or {}
		if specialistTable.n ~= numSpecialistsInBuilding then
			specialistTable = { n = numSpecialistsInBuilding }
			for i = 1, numSpecialistsInBuilding do
				specialistTable[i] = true
			end
			g_citySpecialists[buildingID] = specialistTable
		end
		local specialistType = building.SpecialistType
		local specialist = GameInfo.Specialists[specialistType]
		if specialist then
			for slotID = 1, city:GetNumSpecialistsAllowedByBuilding( buildingID ) do
				local instance = {}
				ContextPtr:BuildInstanceForControl( "SlotInstance", instance, slotStack )
				local slot = instance.Button
				if civ5_mode then
					slot:SetTexture( specialistTable[ slotID ] and g_slotTexture[ specialistType ] or "CitizenEmpty.dds" )
				else
					IconHookup( specialist.PortraitIndex, 45, specialist.IconAtlas, instance.Portrait )
					instance.Portrait:SetHide( not specialistTable[ slotID ] )
				end
				slot:SetVoids( buildingID, slotID )
				slot:SetToolTipCallback( SpecialistTooltip )
				if g_isViewingMode then
					slot:ClearCallback( Mouse.eLClick )
				else
					slot:RegisterCallback( Mouse.eLClick, ToggleSpecialist )
				end
				slot:RegisterCallback( Mouse.eRClick, SpecialistPedia )

			end -- Specialist Slots
		end
		buildingButton:SetVoid1( buildingID )
		buildingButton:RegisterCallback( Mouse.eRClick, BuildingPedia )
		buildingButton:SetToolTipCallback( BuildingToolTip )

		-- Can we sell this thing?
		if not g_isViewingMode and city:IsBuildingSellable( buildingID ) then
			buildingButton:RegisterCallback( Mouse.eLClick, OnBuildingClicked )
			instance.ButtonHighlight:SetHide( false )
		-- We have to clear the data out here or else the instance manager will recycle it in other cities!
		else
			buildingButton:ClearCallback( Mouse.eLClick )
			instance.ButtonHighlight:SetHide( true )
		end
		slotStack:CalculateSize()
		buildingButton:SetSizeY( math.max(64, slotStack:GetSizeY() + 32) )
	end
	return buildingIM.Commit()
end

-------------------------------------------
-- Production Selection List Management
-------------------------------------------

local function SelectionPurchase( orderID, itemID, yieldID, soundKey )
	local city = UI.GetHeadSelectedCity()
	if city then
		local cityOwnerID = city:GetOwner()
		if cityOwnerID == g_activePlayerID
			and ( not city:IsPuppet() or ( bnw_mode and g_activePlayer:MayNotAnnex() ) )
							----------- Venice exception -----------
		then
			local cityID = city:GetID()
			local isPurchase
			if orderID == OrderTypes.ORDER_TRAIN then
				if cityIsCanPurchase( city, true, true, itemID, -1, -1, yieldID ) then
					Game.CityPurchaseUnit( city, itemID, yieldID )
					isPurchase = true
				end
			elseif orderID == OrderTypes.ORDER_CONSTRUCT then
				if cityIsCanPurchase( city, true, true, -1, itemID, -1, yieldID ) then
					Game.CityPurchaseBuilding( city, itemID, yieldID )
--					city:DoReallocateCitizens()
					Network.SendUpdateCityCitizens( cityID )
					isPurchase = true
				end
			elseif orderID == OrderTypes.ORDER_CREATE then
				if cityIsCanPurchase( city, true, true, -1, -1, itemID, yieldID ) then
					Game.CityPurchaseProject( city, itemID, yieldID )
					isPurchase = true
				end
			end
			if isPurchase then
				Events.SpecificCityInfoDirty( cityOwnerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER )
				Events.SpecificCityInfoDirty( cityOwnerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION )
				if soundKey then
					Events.AudioPlay2DSound( soundKey )
				end
			end
		end
	end
end

local function AddSelectionItem( city, item,
				selectionList,
				orderID,
				cityCanProduce,
				unitID, buildingID, projectID,
				cityGetProductionTurnsLeft,
				cityGetGoldCost,
				cityGetFaithCost )

	local itemID = item.ID
	local name = item.Description
	local turnsLeft = not g_isViewingMode and cityCanProduce( city, itemID, 0, 1 )	-- 0 = /continue, 1 = testvisible, nil = /ignore cost
	local canProduce = not g_isViewingMode and cityCanProduce( city, itemID )	-- nil = /continue, nil = /testvisible, nil = /ignore cost
	local canBuyWithGold, goldCost, canBuyWithFaith, faithCost
	if unitID then
		if civBE_mode then
			local bestUpgradeInfo = GameInfo.UnitUpgrades[ g_activePlayer:GetBestUnitUpgrade(unitID) ]
			name = bestUpgradeInfo and bestUpgradeInfo.Description or name
		end
		if cityGetGoldCost then
			canBuyWithGold = cityIsCanPurchase( city, true, true, unitID, buildingID, projectID, g_yieldCurrency )
			goldCost = cityIsCanPurchase( city, false, false, unitID, buildingID, projectID, g_yieldCurrency )
					and cityGetGoldCost( city, itemID ) .. g_iconCurrency
		end
		if cityGetFaithCost then
			canBuyWithFaith = cityIsCanPurchase( city, true, true, unitID, buildingID, projectID, YieldTypes.YIELD_FAITH )
			faithCost = cityIsCanPurchase( city, false, false, unitID, buildingID, projectID, YieldTypes.YIELD_FAITH )
					and cityGetFaithCost( city, itemID, true ) .. "[ICON_PEACE]"
		end
	end
	if turnsLeft or goldCost or faithCost then
		turnsLeft = turnsLeft and ( cityGetProductionTurnsLeft and cityGetProductionTurnsLeft( city, itemID ) or -1 )
		return selectionList:insert{ item, orderID, L(name), turnsLeft, canProduce, goldCost, canBuyWithGold, faithCost, canBuyWithFaith }
	end
end

local function SortSelectionList(a,b)
	return a[3]<b[3] 
end

local g_SelectionListCallBacks = {
	Button = {
		[Mouse.eLClick] = function( orderID, itemID )
			local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
			if city then
				local cityOwnerID = city:GetOwner()
				if cityOwnerID == g_activePlayerID and not city:IsPuppet() then
					-- cityPushOrder( city, orderID, itemID, bAlt, bShift, bCtrl )
					-- cityPushOrder( city, orderID, itemID, bAlt, replaceQueue, bottomOfQueue )
					Game.CityPushOrder( city, orderID, itemID, UI.AltKeyDown(), UI.ShiftKeyDown(), not UI.CtrlKeyDown() )
					Events.SpecificCityInfoDirty( cityOwnerID, city:GetID(), CityUpdateTypes.CITY_UPDATE_TYPE_BANNER )
					return Events.SpecificCityInfoDirty( cityOwnerID, city:GetID(), CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION )
				end
			end
		end,
		[Mouse.eRClick] = SelectionPedia,
	},
	GoldButton = {
		[Mouse.eLClick] = function( orderID, itemID )
			return SelectionPurchase( orderID, itemID, g_yieldCurrency, "AS2D_INTERFACE_CITY_SCREEN_PURCHASE" )
		end,
	},
	FaithButton = {
		[Mouse.eLClick] = function( orderID, itemID )
			return SelectionPurchase( orderID, itemID, YieldTypes.YIELD_FAITH, "AS2D_INTERFACE_FAITH_PURCHASE" )
		end,
	},
}
local g_SelectionListTooltips = {
	Button = SelectionToolTip,
	GoldButton = function( control )
		return OrderItemTooltip( UI.GetHeadSelectedCity(), control:IsDisabled(), g_yieldCurrency, control:GetVoid1(), control:GetVoid2() )
	end,
	FaithButton = function( control )
		return OrderItemTooltip( UI.GetHeadSelectedCity(), control:IsDisabled(), YieldTypes.YIELD_FAITH, control:GetVoid1(), control:GetVoid2() )
	end,
}

local function SetupSelectionList( itemList, selectionIM, getUnitPortraitIcon )
	itemList:sort( SortSelectionList )
	selectionIM.ResetInstances()
	for i = 1, #itemList do
		local item, orderID, itemDescription, turnsLeft, canProduce, goldCost, canBuyWithGold, faithCost, canBuyWithFaith = unpack( itemList[i] )
		local itemID = item.ID
		local instance, isNewInstance = selectionIM.GetInstance()
		if isNewInstance then
			SetupCallbacks( instance, g_SelectionListTooltips, "EUI_CityViewLeftTooltip", g_SelectionListCallBacks )
		end
		instance.DisabledProduction:SetHide( canProduce or not(canBuyWithGold or canBuyWithFaith) )
		instance.Disabled:SetHide( canProduce or canBuyWithGold or canBuyWithFaith )
		if getUnitPortraitIcon then
			local iconIndex, iconAtlas = getUnitPortraitIcon( itemID, cityOwnerID )
			IconHookup( iconIndex, 45, iconAtlas, instance.Portrait )
		else
			IconHookup( item.PortraitIndex, 45, item.IconAtlas, instance.Portrait )
		end
		instance.Name:SetText( itemDescription )
		if not turnsLeft then
		elseif turnsLeft > -1 and turnsLeft <= 999 then
			instance.Turns:LocalizeAndSetText( "TXT_KEY_STR_TURNS", turnsLeft )
		else
			instance.Turns:LocalizeAndSetText( "TXT_KEY_PRODUCTION_HELP_INFINITE_TURNS" )
		end
		instance.Turns:SetHide( not turnsLeft )
		instance.Button:SetVoids( orderID, itemID )

		instance.GoldButton:SetHide( not goldCost )
		instance.GoldButton:SetDisabled( not canBuyWithGold )
		instance.GoldButton:SetAlpha( canBuyWithGold and 1 or 0.5 )
		instance.GoldButton:SetVoids( orderID, itemID )
		instance.GoldCost:SetText( goldCost )

		instance.FaithButton:SetHide( not faithCost )
		instance.FaithButton:SetDisabled( not canBuyWithFaith )
		instance.FaithButton:SetAlpha( canBuyWithFaith and 1 or 0.5 )
		instance.FaithButton:SetVoids( orderID, itemID )
		instance.FaithCost:SetText( faithCost )

		local avisorRecommended = g_isAdvisor and g_avisorRecommended[ orderID ]
		for advisorID, advisorName in pairs(g_advisorControls) do
			local advisorControl = instance[ advisorName ]
			if advisorControl then
				advisorControl:SetHide( not (avisorRecommended and avisorRecommended( itemID, advisorID )) )
			end
		end
	end
	return selectionIM.Commit()
end

-------------------------------
-- Production Queue Managemeent
-------------------------------
local function RemoveQueueItem( queuedItemNumber )
	local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
	if city then
		local queueLength = city:GetOrderQueueLength()
		if city:GetOwner() == g_activePlayerID and queueLength > queuedItemNumber then
			Game.SelectedCitiesGameNetMessage( GameMessageTypes.GAMEMESSAGE_POP_ORDER, queuedItemNumber )
			if queueLength < 2 then
				local strTooltip = L( "TXT_KEY_NOTIFICATION_NEW_CONSTRUCTION", city:GetNameKey() )
				g_activePlayer:AddNotification( NotificationTypes.NOTIFICATION_PRODUCTION, strTooltip, strTooltip, city:GetX(), city:GetY(), -1, -1 )
			end
		end
	end
end

local function SwapQueueItem( queuedItemNumber )
	if g_queuedItemNumber and Controls.QueueSlider:IsTrackingLeftMouseButton() then
		local a, b = g_queuedItemNumber, queuedItemNumber
		if a>b then a, b = b, a end
		for i=a, b-1 do
			Game.SelectedCitiesGameNetMessage( GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, i )
		end
		for i=b-2, a, -1 do
			Game.SelectedCitiesGameNetMessage( GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, i )
		end
	end
	g_queuedItemNumber = queuedItemNumber or g_queuedItemNumber
end

local function UpdateCityProductionQueueNow( city, cityID, cityOwnerID, isVeniceException )
	-------------------------------------------
	-- Update Production Queue
	-------------------------------------------
	local queueLength = city:GetOrderQueueLength()
	local currentProductionPerTurnTimes100 = city:GetCurrentProductionDifferenceTimes100(false, false)
	local isGeneratingProduction = not bnw_mode or ( currentProductionPerTurnTimes100 > 0)
	local isMaintain = false
	local isQueueEmpty = queueLength < 1
	Controls.ProductionFinished:SetHide( true )

	-- Production stored and needed
	local storedProduction = city:GetProduction() + city:GetOverflowProduction() + city:GetFeatureProduction()
	local productionNeeded = 1E-99
	if isGeneratingProduction and not isQueueEmpty and not city:IsProductionProcess() then
		productionNeeded = city:GetProductionNeeded()
	end

	-- Progress info for meter
	local storedProductionPlusThisTurn = storedProduction + currentProductionPerTurnTimes100 / 100

	Controls.PQmeter:SetPercents( storedProduction / productionNeeded, storedProductionPlusThisTurn / productionNeeded )

	Controls.ProdPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", currentProductionPerTurnTimes100 / 100 )

	Controls.ProductionPortraitButton:SetHide( false )

	g_ProdQueueIM.ResetInstances()
	local queueItems = {}

	for queuedItemNumber = 0, math.max( queueLength-1, 0 ) do

		local orderID, itemID = -1, -1
		if isQueueEmpty then
			local item = g_finishedItems[ cityID ]
			if item then
				orderID, itemID = unpack( item )
				Controls.ProductionFinished:SetHide( false )
			end
		else
			orderID, itemID = city:GetOrderFromQueue( queuedItemNumber )
			queueItems[ orderID / 64 + itemID ] = true
		end
		local instance, portraitSize
		if queuedItemNumber == 0 then
			instance = Controls
			portraitSize = g_portraitSize
		else
			portraitSize = 45
			instance = g_ProdQueueIM.GetInstance()
			instance.PQdisabled:SetHide( not isMaintain )
		end
		instance.PQbox:SetVoid1( queuedItemNumber )
		instance.PQbox:RegisterCallback( Mouse.eMouseEnter, SwapQueueItem )
		instance.PQbox:RegisterCallback( Mouse.eRClick, ProductionPedia )
		instance.PQbox:SetToolTipCallback( ProductionToolTip )

		instance.PQremove:SetHide( isQueueEmpty or g_isViewingMode )
		instance.PQremove:SetVoid1( queuedItemNumber )
		instance.PQremove:RegisterCallback( Mouse.eLClick, RemoveQueueItem )
		instance.PQrank:SetHide( queueLength < 2 )
		instance.PQrank:SetText( (queuedItemNumber+1).."." )

		local itemInfo, turnsRemaining, portraitOffset, portraitAtlas

		if orderID == OrderTypes.ORDER_TRAIN then
			itemInfo = GameInfo.Units
			turnsRemaining = city:GetUnitProductionTurnsLeft( itemID, queuedItemNumber )
			portraitOffset, portraitAtlas = UI.GetUnitPortraitIcon( itemID, cityOwnerID )
		elseif orderID == OrderTypes.ORDER_CONSTRUCT then
			itemInfo = GameInfo.Buildings
			turnsRemaining = city:GetBuildingProductionTurnsLeft( itemID, queuedItemNumber )
		elseif orderID == OrderTypes.ORDER_CREATE then
			itemInfo = GameInfo.Projects
			turnsRemaining = city:GetProjectProductionTurnsLeft( itemID, queuedItemNumber )
		elseif orderID == OrderTypes.ORDER_MAINTAIN then
			itemInfo = GameInfo.Processes
			isMaintain = true
		end
		if itemInfo then
			local item = itemInfo[itemID]
			itemInfo = IconHookup( portraitOffset or item.PortraitIndex, portraitSize, portraitAtlas or item.IconAtlas, instance.PQportrait )
			instance.PQname:LocalizeAndSetText( item.Description )
			if isMaintain or isQueueEmpty then
			elseif isGeneratingProduction then
				instance.PQturns:LocalizeAndSetText( "TXT_KEY_PRODUCTION_HELP_NUM_TURNS", turnsRemaining )
			else
				instance.PQturns:LocalizeAndSetText( "TXT_KEY_PRODUCTION_HELP_INFINITE_TURNS" )
			end
		else
			instance.PQname:LocalizeAndSetText( "TXT_KEY_PRODUCTION_NO_PRODUCTION" )
		end
		instance.PQturns:SetHide( isMaintain or isQueueEmpty or not itemInfo )
		instance.PQportrait:SetHide( not itemInfo )
	end

	g_ProdQueueIM.Commit()

	-------------------------------------------
	-- Update Selection List
	-------------------------------------------
	local isSelectionList = not g_isViewingMode or isVeniceException
	Controls.SelectionScrollPanel:SetHide( not isSelectionList )
	if isSelectionList then
		unitSelectList = table()
		buildingSelectList = table()
		wonderSelectList = table()
		processSelectList = table()

		if g_isAdvisor then
			Game.SetAdvisorRecommenderCity( city )
		end
		-- Units
		local orderID = OrderTypes.ORDER_TRAIN
		for item in GameInfo.Units() do
			AddSelectionItem( city, item,
						unitSelectList,
						orderID,
						city.CanTrain,
						item.ID, -1, -1,
						city.GetUnitProductionTurnsLeft,
						city.GetUnitPurchaseCost,
						city.GetUnitFaithPurchaseCost )
		end

		-- Buildings & Wonders
		local orderID = OrderTypes.ORDER_CONSTRUCT
		local code = orderID / 64
		for item in GameInfo.Buildings() do
			local buildingClass = GameInfo.BuildingClasses[item.BuildingClass]
			local isWonder = buildingClass and (buildingClass.MaxGlobalInstances > 0 or buildingClass.MaxPlayerInstances == 1 or buildingClass.MaxTeamInstances > 0)
			if not queueItems[ code + item.ID ] then

				AddSelectionItem( city, item,
						isWonder and wonderSelectList or buildingSelectList,
						orderID,
						city.CanConstruct,
						-1, item.ID, -1,
						city.GetBuildingProductionTurnsLeft,
						city.GetBuildingPurchaseCost,
						city.GetBuildingFaithPurchaseCost )
			end
		end
		-- Projects
		local orderID = OrderTypes.ORDER_CREATE
		local code = orderID / 64
		for item in GameInfo.Projects() do
			if not queueItems[ code + item.ID ] then
				AddSelectionItem( city, item,
						wonderSelectList,
						orderID,
						city.CanCreate,
						-1, -1, item.ID,
						city.GetProjectProductionTurnsLeft,
						city.GetProjectPurchaseCost,
						city.GetProjectFaithPurchaseCost )	-- nil
			end
		end
		-- Processes
		local orderID = OrderTypes.ORDER_MAINTAIN
		local code = orderID / 64
		for item in GameInfo.Processes() do
			if not queueItems[ code + item.ID ] then
				AddSelectionItem( city, item,
						processSelectList,
						orderID,
						city.CanMaintain )
			end
		end

		SetupSelectionList( unitSelectList, g_UnitSelectIM, UI.GetUnitPortraitIcon )
		SetupSelectionList( buildingSelectList, g_BuildingSelectIM )
		SetupSelectionList( wonderSelectList, g_WonderSelectIM )
		SetupSelectionList( processSelectList, g_ProcessSelectIM )

	end
	return ResizeProdQueue()
end

-------------------------------------------------
-- City Hex Clicking & Mousing
-------------------------------------------------
local function PlotButtonClicked( plotIndex )
	local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
	local plot = city and city:GetCityIndexPlot( plotIndex )
	if plot then
		local outside = city ~= plot:GetWorkingCity()
		-- calling this with the city center (0 in the third param) causes it to reset all forced tiles
		Network.SendDoTask( city:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, plotIndex, -1, false )
		if outside then
--			return city:DoReallocateCitizens()
			return Network.SendUpdateCityCitizens( city:GetID() )
		end
	end
end

local function BuyPlotAnchorButtonClicked( plotIndex )
	if isActivePlayerAllowed() then
		local city = UI.GetHeadSelectedCity()
		if city then
			local plot = city:GetCityIndexPlot( plotIndex )
			local plotX = plot:GetX()
			local plotY = plot:GetY()
			Network.SendCityBuyPlot(city:GetID(), plotX, plotY)
--			city:DoReallocateCitizens()
			Network.SendUpdateCityCitizens( city:GetID() )
			UI.UpdateCityScreen()
			Events.AudioPlay2DSound("AS2D_INTERFACE_BUY_TILE")
		end
		return true
	end
end

-------------------------------------------------
-- City Hexes Update
-------------------------------------------------
local function UpdateWorkingHexesNow()

	g_isCityHexesDirty = false
	local city = UI.GetHeadSelectedCity()
	if city and UI.IsCityScreenUp() then

		Events.ClearHexHighlightStyle( "Culture" )
		Events.ClearHexHighlightStyle( "WorkedFill" )
		Events.ClearHexHighlightStyle( "WorkedOutline" )
		Events.ClearHexHighlightStyle( "OverlapFill" )
		Events.ClearHexHighlightStyle( "OverlapOutline" )
		Events.ClearHexHighlightStyle( "VacantFill" )
		Events.ClearHexHighlightStyle( "VacantOutline" )
		Events.ClearHexHighlightStyle( "EnemyFill" )
		Events.ClearHexHighlightStyle( "EnemyOutline" )
		Events.ClearHexHighlightStyle( "BuyFill" )
		Events.ClearHexHighlightStyle( "BuyOutline" )

		g_PlotButtonIM.ResetInstances()
		g_BuyPlotButtonIM.ResetInstances()

		-- Show plots that will be acquired by culture
		local purchasablePlots = {city:GetBuyablePlotList()}
		for i = 1, #purchasablePlots do
			local plot = purchasablePlots[i]
			Events.SerialEventHexHighlight( ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }, true, g_colorCulture, "Culture" )
			purchasablePlots[ plot ] = true
		end


--		Events.RequestYieldDisplay( YieldDisplayTypes.CITY_OWNED, city:GetX(), city:GetY() )
		Events.RequestYieldDisplay( YieldDisplayTypes.AREA, 3, city:GetX(), city:GetY() )

		-- display worked plots buttons
		local cityOwnerID = city:GetOwner()
		local notInStrategicView = not InStrategicView()

		for cityPlotIndex = 0, city:GetNumCityPlots() - 1 do
			local plot = city:GetCityIndexPlot( cityPlotIndex )

			if plot and plot:GetOwner() == cityOwnerID then

				local hexPos = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
				local worldPos = HexToWorld( hexPos )
				local iconID, tipKey
				if city:IsWorkingPlot( plot ) then

					-- The city itself
					if cityPlotIndex == 0 then
						iconID = 11
						tipKey = "TXT_KEY_CITYVIEW_CITY_CENTER"

					-- FORCED worked plot
					elseif city:IsForcedWorkingPlot( plot ) then
						iconID = 10
						tipKey = "TXT_KEY_CITYVIEW_FORCED_WORK_TILE"

					-- AI-picked worked plot
					else
						iconID = 0
						tipKey = "TXT_KEY_CITYVIEW_GUVNA_WORK_TILE"
					end
					if notInStrategicView then
						Events.SerialEventHexHighlight( hexPos , true, nil, "WorkedFill" )
						Events.SerialEventHexHighlight( hexPos , true, nil, "WorkedOutline" )
					end
				else
					local workingCity = plot:GetWorkingCity()
					-- worked by another one of our Cities
					if workingCity:IsWorkingPlot( plot ) then
						iconID = 12
						tipKey = "TXT_KEY_CITYVIEW_NUTHA_CITY_TILE"

					-- Workable plot
					elseif workingCity:CanWork( plot ) then
						iconID = 9
						tipKey = "TXT_KEY_CITYVIEW_UNWORKED_CITY_TILE"

					-- Blockaded water plot
					elseif plot:IsWater() and city:IsPlotBlockaded( plot ) then
						iconID = 13
						tipKey = "TXT_KEY_CITYVIEW_BLOCKADED_CITY_TILE"
						cityPlotIndex = nil

					-- Enemy Unit standing here
					elseif plot:IsVisibleEnemyUnit( cityOwnerID ) then
						iconID = 13
						tipKey = "TXT_KEY_CITYVIEW_ENEMY_UNIT_CITY_TILE"
						cityPlotIndex = nil
					end
					if notInStrategicView then
						if workingCity ~= city then
							Events.SerialEventHexHighlight( hexPos , true, nil, "OverlapFill" )
							Events.SerialEventHexHighlight( hexPos , true, nil, "OverlapOutline" )
						elseif cityPlotIndex then
							Events.SerialEventHexHighlight( hexPos , true, nil, "VacantFill" )
							Events.SerialEventHexHighlight( hexPos , true, nil, "VacantOutline" )
						else
							Events.SerialEventHexHighlight( hexPos , true, nil, "EnemyFill" )
							Events.SerialEventHexHighlight( hexPos , true, nil, "EnemyOutline" )
						end
					end
				end
				if iconID and g_workerHeadingOpen then
					local instance = g_PlotButtonIM.GetInstance()
					instance.PlotButtonAnchor:SetWorldPositionVal( worldPos.x + g_worldPositionOffset.x, worldPos.y + g_worldPositionOffset.y, worldPos.z + g_worldPositionOffset.z ) --todo: improve code
					instance.PlotButtonImage:LocalizeAndSetToolTip( tipKey )
					IconHookup( iconID, 45, "CITIZEN_ATLAS", instance.PlotButtonImage )
					local button = instance.PlotButtonImage
					if not cityPlotIndex or g_isViewingMode then
						button:ClearCallback( Mouse.eLCLick )
					else
						button:SetVoid1( cityPlotIndex )
						button:RegisterCallback( Mouse.eLCLick, PlotButtonClicked )
					end
					button:SetDisabled( g_isViewingMode )
				end
			end
		end --loop

		-- display buy plot buttons
--		Events.RequestYieldDisplay( YieldDisplayTypes.CITY_PURCHASABLE, city:GetX(), city:GetY() )
		if g_BuyPlotMode and not g_isViewingMode then
			for cityPlotIndex = 0, city:GetNumCityPlots() - 1 do
				local plot = city:GetCityIndexPlot( cityPlotIndex )
				if plot then
					local x, y = plot:GetX(), plot:GetY()
					local hexPos = ToHexFromGrid{ x=x, y=y }
					local worldPos = HexToWorld( hexPos )
					if city:CanBuyPlotAt( x, y, true ) then
						local instance = g_BuyPlotButtonIM.GetInstance()
						local button = instance.BuyPlotAnchoredButton
						instance.BuyPlotButtonAnchor:SetWorldPositionVal( worldPos.x + g_worldPositionOffset2.x, worldPos.y + g_worldPositionOffset2.y, worldPos.z + g_worldPositionOffset2.z ) --todo: improve code
						local plotCost = city:GetBuyPlotCost( x, y )
						local tip, txt
						local canBuy = city:CanBuyPlotAt( x, y, false )
						if canBuy then
							tip = L( "TXT_KEY_CITYVIEW_CLAIM_NEW_LAND", plotCost )
							txt = plotCost
							button:SetVoid1( cityPlotIndex )
							button:RegisterCallback( Mouse.eLCLick, BuyPlotAnchorButtonClicked )
							if notInStrategicView then
								Events.SerialEventHexHighlight( hexPos , true, nil, "BuyFill" )
								if not purchasablePlots[ plot ] then
									Events.SerialEventHexHighlight( hexPos , true, nil, "BuyOutline" )
								end
							end
						else
							tip = L( "TXT_KEY_CITYVIEW_NEED_MONEY_BUY_TILE", plotCost )
							txt = "[COLOR_WARNING_TEXT]"..plotCost.."[ENDCOLOR]"
						end
						button:SetDisabled( not canBuy )
--todo
						button:SetToolTipString( tip )
						instance.BuyPlotAnchoredButtonLabel:SetText( txt )
					end
				end
			end --loop
		end
		g_PlotButtonIM.Commit()
		g_BuyPlotButtonIM.Commit()

	end -- city
end

-------------------------------------------------
-- City View Update
-------------------------------------------------
local function UpdateCityViewNow()

	g_isCityViewDirty = false
	local city = UI.GetHeadSelectedCity()

	if city then

		if g_citySpecialists.city ~= city then
			g_citySpecialists = { city = city }
		end
		if g_previousCity ~= city then
			g_previousCity = city
--[[
			Events.ClearHexHighlightStyle("CityLimits")
			if not InStrategicView() then
				for cityPlotIndex = 0, city:GetNumCityPlots() - 1 do
					local plot = city:GetCityIndexPlot( cityPlotIndex )
					if plot then
						local hexPos = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
						Events.SerialEventHexHighlight( hexPos , true, nil, "CityLimits" )
					end
				end
			end
--]]
		end
		local cityID = city:GetID()
		local cityOwnerID = city:GetOwner()
		local cityOwner = Players[cityOwnerID]
		local isActivePlayerCity = cityOwnerID == Game.GetActivePlayer()
		local isCityCaptureViewingMode = UI.IsPopupTypeOpen(ButtonPopupTypes.BUTTONPOPUP_CITY_CAPTURED)
		g_isViewingMode = city:IsPuppet() or not isActivePlayerCity or isCityCaptureViewingMode

		if civ5_mode then
			-- Auto Specialist checkbox
			local isNoAutoAssignSpecialists = city:IsNoAutoAssignSpecialists()
			Controls.NoAutoSpecialistCheckbox:SetCheck( isNoAutoAssignSpecialists )
			Controls.NoAutoSpecialistCheckbox:SetDisabled( g_isViewingMode )
			if bnw_mode then
				Controls.TourismPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", city:GetBaseTourism() )
				Controls.NoAutoSpecialistCheckbox2:SetCheck( isNoAutoAssignSpecialists )
				Controls.NoAutoSpecialistCheckbox2:SetDisabled( g_isViewingMode )
			end
		end

		-------------------------------------------
		-- City Banner
		-------------------------------------------

		-- Update capital icon
		local isCapital = city:IsCapital()
		Controls.CityCapitalIcon:SetHide(not isCapital)

		-- Connected to capital?
		if city:GetTeam() == Game.GetActiveTeam() then
			if not isCapital and cityOwner:IsCapitalConnectedToCity(city) and not city:IsBlockaded() then
				Controls.ConnectedIcon:SetHide(false)
				Controls.ConnectedIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_CONNECTED")
			else
				Controls.ConnectedIcon:SetHide(true)
			end
		end

		-- Blockaded
		if city:IsBlockaded() then
			Controls.BlockadedIcon:SetHide(false)
			Controls.BlockadedIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_BLOCKADED")
		else
			Controls.BlockadedIcon:SetHide(true)
		end

		-- Being Razed
		if city:IsRazing() then
			Controls.RazingIcon:SetHide(false)
			Controls.RazingIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_BURNING", city:GetRazingTurns())
		else
			Controls.RazingIcon:SetHide(true)
		end

		-- Puppet Status
		if city:IsPuppet() then
			Controls.PuppetIcon:SetHide(false)
			Controls.PuppetIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_PUPPET")
		else
			Controls.PuppetIcon:SetHide(true)
		end

		-- In Resistance
		if city:IsResistance() then
			Controls.ResistanceIcon:SetHide(false)
			Controls.ResistanceIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_RESISTANCE", city:GetResistanceTurns())
		else
			Controls.ResistanceIcon:SetHide(true)
		end

		-- Occupation Status
--todo
		if civ5_mode and city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
			Controls.OccupiedIcon:SetHide(false)
			Controls.OccupiedIcon:LocalizeAndSetToolTip("TXT_KEY_CITY_OCCUPIED")
		else
			Controls.OccupiedIcon:SetHide(true)
		end

		local cityName = Locale.ToUpper( city:GetNameKey() )

		if city:IsRazing() then
			cityName = cityName .. " (" .. L"TXT_KEY_BURNING" .. ")"
		end

		local size = isCapital and Controls.CityCapitalIcon:GetSizeX() or 0
		Controls.CityNameTitleBarLabel:SetOffsetX( size / 2 )
		TruncateString( Controls.CityNameTitleBarLabel, math.abs(Controls.NextCityButton:GetOffsetX()) * 2 - Controls.NextCityButton:GetSizeX() - size, cityName )

		-- COMMUNITY PATCH
	
		local iNumOccupiedCities = 0;
		for city in cityOwner:Cities() do
			if (city:IsOccupied() and not city:IsNoOccupiedUnhappiness()) then
				iNumOccupiedCities = iNumOccupiedCities + 1;
			end
		end
		local iCityCountMod = cityOwner:GetCapitalUnhappinessMod();
		local iNumNormalCities = cityOwner:GetNumCities() - iNumOccupiedCities;
		local iUnhappinessFromCityCount = Locale.ToNumber( cityOwner:GetUnhappinessFromCityCount() / 100, "#.##" );
		local iCityYield = (iUnhappinessFromCityCount / iNumNormalCities);
		local iStarvingUnhappiness = city:GetUnhappinessFromStarving();
		local iPillagedUnhappiness = city:GetUnhappinessFromPillaged();
		local iGoldUnhappiness = city:GetUnhappinessFromGold();
		local iDefenseUnhappiness = city:GetUnhappinessFromDefense();
		local iConnectionUnhappiness = city:GetUnhappinessFromConnection();
		local iMinorityUnhappiness = city:GetUnhappinessFromMinority();
		local iScienceUnhappiness = city:GetUnhappinessFromScience();
		local iCultureUnhappiness = city:GetUnhappinessFromCulture();
		
		local iTotalUnhappiness = iScienceUnhappiness + iCultureUnhappiness + iDefenseUnhappiness	+ iGoldUnhappiness + iConnectionUnhappiness + iPillagedUnhappiness + iStarvingUnhappiness + iMinorityUnhappiness + iCityYield;

		local iPuppetMod = cityOwner:GetPuppetUnhappinessMod();
		local iCultureYield = city:GetUnhappinessFromCultureYield() / 100;
		local iDefenseYield = city:GetUnhappinessFromDefenseYield() / 100;
		local iGoldYield = city:GetUnhappinessFromGoldYield() / 100;
		local iCultureNeeded = city:GetUnhappinessFromCultureNeeded() / 100;
		local iDefenseNeeded = city:GetUnhappinessFromDefenseNeeded() / 100;
		local iGoldNeeded = city:GetUnhappinessFromGoldNeeded() / 100;
		local iScienceYield = city:GetUnhappinessFromScienceYield() / 100;
		local iScienceNeeded = city:GetUnhappinessFromScienceNeeded() / 100;

		strOccupationTT = Locale.ConvertTextKey("TXT_KEY_EO_CITY_LOCAL_UNHAPPINESS", iTotalUnhappiness);

		if (city:IsCapital()) then
			if (iCityCountMod == 0) then
				if(iCityYield ~= 0) then
					strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CITYCOUNT_UNHAPPINESS", iCityYield);
				end
			end
		end
		
		if (not city:IsCapital()) then
			if (iCityYield ~= 0) then
				if (not city:IsOccupied()) then
					strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CITYCOUNT_UNHAPPINESS", iCityYield);
				end
			end
		end

		if (not city:IsCapital()) then
			if (iCityYield ~= 0) then
				if (city:IsOccupied()) then
					if(city:IsNoOccupiedUnhappiness()) then
						strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CITYCOUNT_UNHAPPINESS", iCityYield);
					end
				end
			end
		end

		if(city:IsPuppet()) then
			if (iPuppetMod ~= 0) then
				strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PUPPET_UNHAPPINESS_MOD", iPuppetMod);
			end
		end
		
		-- Starving tooltip
		if (iStarvingUnhappiness ~= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_STARVING_UNHAPPINESS", iStarvingUnhappiness);
		end
		-- Pillaged tooltip
		if (iPillagedUnhappiness ~= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PILLAGED_UNHAPPINESS", iPillagedUnhappiness);
		end
		-- Gold tooltip
		if (iGoldUnhappiness > 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_GOLD_UNHAPPINESS", iGoldUnhappiness, iGoldYield, iGoldNeeded);
		end
		if ((iGoldYield - iGoldNeeded) >= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_GOLD_UNHAPPINESS_SURPLUS", (iGoldYield - iGoldNeeded));
		end
		-- Defense tooltip
		if (iDefenseUnhappiness > 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DEFENSE_UNHAPPINESS", iDefenseUnhappiness, iDefenseYield, iDefenseNeeded);
		end
		if ((iDefenseYield - iDefenseNeeded) >= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_DEFENSE_UNHAPPINESS_SURPLUS", (iDefenseYield - iDefenseNeeded));
		end
		-- Connection tooltip
		if (iConnectionUnhappiness ~= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CONNECTION_UNHAPPINESS", iConnectionUnhappiness);
		end
		-- Minority tooltip
		if (iMinorityUnhappiness ~= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_MINORITY_UNHAPPINESS", iMinorityUnhappiness);
		end
		-- Science tooltip
		if (iScienceUnhappiness > 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_SCIENCE_UNHAPPINESS", iScienceUnhappiness, iScienceYield, iScienceNeeded);
		end
		if ((iScienceYield - iScienceNeeded) >= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_SCIENCE_UNHAPPINESS_SURPLUS", (iScienceYield - iScienceNeeded));
		end
		-- Culture tooltip
		if (iCultureUnhappiness > 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_UNHAPPINESS", iCultureUnhappiness, iCultureYield, iCultureNeeded);
		end
		if ((iCultureYield - iCultureNeeded) >= 0) then
			strOccupationTT = strOccupationTT .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_UNHAPPINESS_SURPLUS", (iCultureYield - iCultureNeeded));
		end

		Controls.CityNameTitleBarLabel:LocalizeAndSetToolTip(strOccupationTT);
		-- END
		
		Controls.Defense:SetText( math.floor( city:GetStrengthValue() / 100 ) )

 		CivIconHookup( cityOwnerID, 64, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true )

		-------------------------------------------
		-- City Damage
		-------------------------------------------
		local cityDamage = city:GetDamage()
		if cityDamage > 0 then
			local cityHealthPercent = 1 - cityDamage / ( gk_mode and city:GetMaxHitPoints() or GameDefines.MAX_CITY_HIT_POINTS )

			Controls.HealthMeter:SetPercent( cityHealthPercent )
			if cityHealthPercent > 0.66 then
				Controls.HealthMeter:SetTexture("CityNamePanelHealthBarGreen.dds")
			elseif cityHealthPercent > 0.33 then
				Controls.HealthMeter:SetTexture("CityNamePanelHealthBarYellow.dds")
			else
				Controls.HealthMeter:SetTexture("CityNamePanelHealthBarRed.dds")
			end
			Controls.HealthFrame:SetHide( false )
		else
			Controls.HealthFrame:SetHide( true )
		end

		-------------------------------------------
		-- Growth Meter
		-------------------------------------------
		local iCurrentFood = city:GetFood()
		local iFoodNeeded = city:GrowthThreshold()
		local iFoodPerTurn = city:FoodDifference()
		local iCurrentFoodPlusThisTurn = iCurrentFood + iFoodPerTurn

		local fGrowthProgressPercent = iCurrentFood / iFoodNeeded
		local fGrowthProgressPlusThisTurnPercent = iCurrentFoodPlusThisTurn / iFoodNeeded
		if (fGrowthProgressPlusThisTurnPercent > 1) then
			fGrowthProgressPlusThisTurnPercent = 1
		end

		local iTurnsToGrowth = city:GetFoodTurnsLeft()

		local cityPopulation = math.floor(city:GetPopulation())
		Controls.CityPopulationLabel:SetText(tostring(cityPopulation))
		Controls.PeopleMeter:SetPercent( city:GetFood() / city:GrowthThreshold() )

		--Update suffix to use correct plurality.
		Controls.CityPopulationLabelSuffix:LocalizeAndSetText("TXT_KEY_CITYVIEW_CITIZENS_TEXT", cityPopulation)


		-------------------------------------------
		-- Citizen Focus & Slackers
		-------------------------------------------

		Controls.AvoidGrowthButton:SetCheck( city:IsForcedAvoidGrowth() )

		local slackerCount = city:GetSpecialistCount( GameDefines.DEFAULT_SPECIALIST )

		local focusType = city:GetFocusType()
		if focusType == CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE then
			Controls.BalancedFocusButton:SetCheck( true )
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD then
			Controls.FoodFocusButton:SetCheck( true )
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION then
			Controls.ProductionFocusButton:SetCheck( true )
		elseif focusType == g_focusCurrency then
			Controls.GoldFocusButton:SetCheck( true )
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE then
			Controls.ResearchFocusButton:SetCheck( true )
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE then
			Controls.CultureFocusButton:SetCheck( true )
		elseif focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE then
			Controls.GPFocusButton:SetCheck( true )
		elseif gk_mode and focusType == CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH then
			Controls.FaithFocusButton:SetCheck( true )
		else
			Controls.BalancedFocusButton:SetCheck( true )
		end
		if city:GetNumForcedWorkingPlots() > 0 or slackerCount > 0 then
			Controls.ResetButton:SetHide( false )
			Controls.ResetFooter:SetHide( false )
		else
			Controls.ResetButton:SetHide( true )
			Controls.ResetFooter:SetHide( true )
		end

		g_SlackerIM.ResetInstances()
		for i = 1, slackerCount do
			local instance = g_SlackerIM.GetInstance()
			local slot = instance.Button
			slot:SetVoids( -1, i )
			slot:SetToolTipCallback( SpecialistTooltip )
			slot:SetTexture( g_slackerTexture )
			if g_isViewingMode then
				slot:ClearCallback( Mouse.eLClick )
			else
				slot:RegisterCallback( Mouse.eLClick, OnSlackersSelected )
			end
			slot:RegisterCallback( Mouse.eRClick, SpecialistPedia )
		end
		g_SlackerIM.Commit()

		-------------------------------------------
		-- Great Person Meters
		-------------------------------------------
		if civ5_mode then
			g_GreatPeopleIM.ResetInstances()
			for specialist in GameInfo.Specialists() do

				local gpuClass = specialist.GreatPeopleUnitClass	-- nil / UNITCLASS_ARTIST / UNITCLASS_SCIENTIST / UNITCLASS_MERCHANT / UNITCLASS_ENGINEER ...
				local unitClass = gpuClass and GameInfo.UnitClasses[ gpuClass ]
				if unitClass then
					local gpThreshold = city:GetSpecialistUpgradeThreshold(unitClass.ID)
					local gpProgress = city:GetSpecialistGreatPersonProgressTimes100(specialist.ID) / 100
					local gpChange = specialist.GreatPeopleRateChange * city:GetSpecialistCount( specialist.ID )
					for building in GameInfo.Buildings{SpecialistType = specialist.Type} do
						if city:IsHasBuilding(building.ID) then
							gpChange = gpChange + building.GreatPeopleRateChange
						end
					end

					local gpChangePlayerMod = cityOwner:GetGreatPeopleRateModifier()
					local gpChangeCityMod = city:GetGreatPeopleRateModifier()
					local gpChangePolicyMod = 0
					local gpChangeWorldCongressMod = 0
					local gpChangeGoldenAgeMod = 0
					local isGoldenAge = cityOwner:GetGoldenAgeTurns() > 0

					if bnw_mode then
						-- Generic GP mods

						gpChangePolicyMod = cityOwner:GetPolicyGreatPeopleRateModifier()

						local worldCongress = (Game.GetNumActiveLeagues() > 0) and Game.GetActiveLeague()

						-- GP mods by type
						if specialist.GreatPeopleUnitClass == "UNITCLASS_WRITER" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatWriterRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatWriterRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetArtsyGreatPersonRateModifier()
							end
							if isGoldenAge and cityOwner:GetGoldenAgeGreatWriterRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatWriterRateModifier()
							end
						elseif specialist.GreatPeopleUnitClass == "UNITCLASS_ARTIST" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatArtistRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatArtistRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetArtsyGreatPersonRateModifier()
							end
							if isGoldenAge and cityOwner:GetGoldenAgeGreatArtistRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatArtistRateModifier()
							end
						elseif specialist.GreatPeopleUnitClass == "UNITCLASS_MUSICIAN" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatMusicianRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatMusicianRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetArtsyGreatPersonRateModifier()
							end
							if isGoldenAge and cityOwner:GetGoldenAgeGreatMusicianRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatMusicianRateModifier()
							end
						elseif specialist.GreatPeopleUnitClass == "UNITCLASS_SCIENTIST" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatScientistRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatScientistRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetScienceyGreatPersonRateModifier()
							end
--CBP
							if isGoldenAge and cityOwner:GetGoldenAgeGreatScientistRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatScientistRateModifier()
							end
-- END
						elseif specialist.GreatPeopleUnitClass == "UNITCLASS_MERCHANT" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatMerchantRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatMerchantRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetScienceyGreatPersonRateModifier()
							end
--CBP
							if isGoldenAge and cityOwner:GetGoldenAgeGreatMerchantRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatMerchantRateModifier()
							end
-- END
						elseif specialist.GreatPeopleUnitClass == "UNITCLASS_ENGINEER" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatEngineerRateModifier()
							gpChangePolicyMod = gpChangePolicyMod + cityOwner:GetPolicyGreatEngineerRateModifier()
							if worldCongress then
								gpChangeWorldCongressMod = gpChangeWorldCongressMod + worldCongress:GetScienceyGreatPersonRateModifier()
							end
--CBP
							if isGoldenAge and cityOwner:GetGoldenAgeGreatEngineerRateModifier() > 0 then
								gpChangeGoldenAgeMod = gpChangeGoldenAgeMod + cityOwner:GetGoldenAgeGreatEngineerRateModifier()
							end
-- END
						-- Compatibility with Gazebo's City-State Diplomacy Mod (CSD) for Brave New World
						elseif cityOwner.GetGreatDiplomatRateModifier and specialist.GreatPeopleUnitClass == "UNITCLASS_GREAT_DIPLOMAT" then
							gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetGreatDiplomatRateModifier()
						end

						-- Player mod actually includes policy mod and World Congress mod, so separate them for tooltip

						gpChangePlayerMod = gpChangePlayerMod - gpChangePolicyMod - gpChangeWorldCongressMod

					elseif gpuClass == "UNITCLASS_SCIENTIST" then

						gpChangePlayerMod = gpChangePlayerMod + cityOwner:GetTraitGreatScientistRateModifier()

					end

					local gpChangeMod = gpChangePlayerMod + gpChangePolicyMod + gpChangeWorldCongressMod + gpChangeCityMod + gpChangeGoldenAgeMod
					gpChange = (gpChangeMod / 100 + 1) * gpChange

					if gpProgress > 0 or gpChange > 0 then
						local instance = g_GreatPeopleIM.GetInstance()
						local percent = gpProgress / gpThreshold
						instance.GPMeter:SetPercent( percent )
						local labelText = L(unitClass.Description)
						local tips = table( "[COLOR_YIELD_FOOD]" .. Locale.ToUpper( labelText ) .. "[ENDCOLOR]"
									.. " " .. gpProgress .. "[ICON_GREAT_PEOPLE] / " .. gpThreshold .. "[ICON_GREAT_PEOPLE]" )
	--					tips:insert( L( "TXT_KEY_PROGRESS_TOWARDS", "[COLOR_YIELD_FOOD]" .. Locale.ToUpper( labelText ) .. "[ENDCOLOR]" )
						if gpChange > 0 then
							local gpTurns = math.ceil( (gpThreshold - gpProgress) / gpChange )
							tips:insert( "[COLOR_YIELD_FOOD]" .. Locale.ToUpper( L( "TXT_KEY_STR_TURNS", gpTurns ) ) .. "[ENDCOLOR]  "
										 .. gpChange .. "[ICON_GREAT_PEOPLE] " .. L"TXT_KEY_GOLD_PERTURN_HEADING4_TITLE" )
							labelText = labelText .. ": " .. Locale.ToLower( L( "TXT_KEY_STR_TURNS", gpTurns ) )
						end
						instance.GreatPersonLabel:SetText( labelText )
						if gk_mode then
							if gpChangePlayerMod ~= 0 then
								tips:insert( L( "TXT_KEY_PLAYER_GP_MOD", gpChangePlayerMod ) )
							end
							if gpChangePolicyMod ~= 0 then
								tips:insert( L( "TXT_KEY_POLICY_GP_MOD", gpChangePolicyMod ) )
							end
							if gpChangeCityMod ~= 0 then
								tips:insert( L( "TXT_KEY_CITY_GP_MOD", gpChangeCityMod ) )
							end
							if gpChangeGoldenAgeMod ~= 0 then
								tips:insert( L( "TXT_KEY_GOLDENAGE_GP_MOD", gpChangeGoldenAgeMod ) )
							end
							if gpChangeWorldCongressMod ~= 0 then
								if gpChangeWorldCongressMod < 0 then
									tips:insert( L( "TXT_KEY_WORLD_CONGRESS_NEGATIVE_GP_MOD", gpChangeWorldCongressMod ) )
								else
									tips:insert( L( "TXT_KEY_WORLD_CONGRESS_POSITIVE_GP_MOD", gpChangeWorldCongressMod ) )
								end
							end
						elseif gpChangeMod ~= 0 then
							tips:insert( "[ICON_BULLET] "..("%+i"):format( gpChangeMod ).."[ICON_GREAT_PEOPLE]" )
						end
						instance.GPBox:SetToolTipString( tips:concat("[NEWLINE]") )
						instance.GPBox:SetVoid1( unitClass.ID )
						instance.GPBox:RegisterCallback( Mouse.eRClick, UnitClassPedia )

						local portraitOffset, portraitAtlas = UI.GetUnitPortraitIcon( GameInfoTypes[ unitClass.DefaultUnit ], cityOwnerID )
						instance.GPImage:SetHide(not IconHookup( portraitOffset, 64, portraitAtlas, instance.GPImage ) )
					end
				end
			end
			g_GreatPeopleIM.Commit()
		end

		-------------------------------------------
		-- Buildings
		-------------------------------------------

		local greatWorkBuildings = table()
		local specialistBuildings = table()
		local wonders = table()
		local otherBuildings = table()
		local noWondersWithSpecialistInThisCity = true

		for building in GameInfo.Buildings() do
			local buildingID = building.ID
			if city:IsHasBuilding(buildingID) then
				local buildingClass = GameInfo.BuildingClasses[ building.BuildingClass ]
				local buildings
				local greatWorkCount = civ5bnw_mode and building.GreatWorkCount or 0
				local areSpecialistsAllowedByBuilding = city:GetNumSpecialistsAllowedByBuilding(buildingID) > 0

				if buildingClass.MaxGlobalInstances > 0
				or buildingClass.MaxTeamInstances > 0
				or ( buildingClass.MaxPlayerInstances == 1 and not areSpecialistsAllowedByBuilding )
				then
					buildings = wonders
					if areSpecialistsAllowedByBuilding then
						noWondersWithSpecialistInThisCity = false
					end
				elseif areSpecialistsAllowedByBuilding then
					buildings = specialistBuildings
				elseif greatWorkCount > 0 then
					buildings = greatWorkBuildings
				elseif greatWorkCount == 0 then		-- compatibility with Firaxis code exploit for invisibility
					buildings = otherBuildings
				end
				if buildings then
					buildings:insert{ building, L(building.Description), greatWorkCount, areSpecialistsAllowedByBuilding and GameInfoTypes[building.SpecialistType] or 999 }
				end
			end
		end
		local strMaintenanceTT = L( "TXT_KEY_BUILDING_MAINTENANCE_TT", city:GetTotalBaseBuildingMaintenance() )
		Controls.SpecialBuildingsHeader:SetToolTipString(strMaintenanceTT)
		Controls.BuildingsHeader:SetToolTipString(strMaintenanceTT)
		Controls.GreatWorkHeader:SetToolTipString(strMaintenanceTT)
		Controls.SpecialistControlBox:SetHide( #specialistBuildings < 1 )
		Controls.SpecialistControlBox2:SetHide( noWondersWithSpecialistInThisCity )

		SetupBuildingList( city, specialistBuildings, g_SpecialBuildingsIM )
		SetupBuildingList( city, wonders, g_WondersIM )
		SetupBuildingList( city, greatWorkBuildings, g_GreatWorkIM )
		SetupBuildingList( city, otherBuildings, g_BuildingsIM )

		ResizeRightStack()

		-------------------------------------------
		-- Buying Plots
		-------------------------------------------
--		szText = L"TXT_KEY_CITYVIEW_BUY_TILE"
--		Controls.BuyPlotButton:LocalizeAndSetToolTip( "TXT_KEY_CITYVIEW_BUY_TILE_TT" )
--		Controls.BuyPlotText:SetText(szText)
--		Controls.BuyPlotButton:SetDisabled( g_isViewingMode or (GameDefines.BUY_PLOTS_DISABLED ~= 0 and city:CanBuyAnyPlot()) )

		-------------------------------------------
		-- Resource Demanded
		-------------------------------------------

		local szResourceDemanded = "??? (Research Required)"

		if (city:GetResourceDemanded(true) ~= -1) then
			local pResourceInfo = GameInfo.Resources[ city:GetResourceDemanded() ]
			szResourceDemanded = L(pResourceInfo.IconString) .. " " .. L(pResourceInfo.Description)
			Controls.ResourceDemandedBox:SetHide(false)

		else
			Controls.ResourceDemandedBox:SetHide(true)
		end

		local iNumTurns = city:GetWeLoveTheKingDayCounter()
		if (iNumTurns > 0) then
			szText = L( "TXT_KEY_CITYVIEW_WLTKD_COUNTER", tostring(iNumTurns) )
			Controls.ResourceDemandedBox:LocalizeAndSetToolTip( "TXT_KEY_CITYVIEW_RESOURCE_FULFILLED_TT" )
		else
			szText = L( "TXT_KEY_CITYVIEW_RESOURCE_DEMANDED", szResourceDemanded )
			Controls.ResourceDemandedBox:LocalizeAndSetToolTip( "TXT_KEY_CITYVIEW_RESOURCE_DEMANDED_TT" )
		end

		Controls.ResourceDemandedString:SetText(szText)
		Controls.ResourceDemandedBox:SetSizeX(Controls.ResourceDemandedString:GetSizeX() + 10)

		Controls.IconsStack:CalculateSize()
		Controls.IconsStack:ReprocessAnchoring()

		Controls.NotificationStack:CalculateSize()
		Controls.NotificationStack:ReprocessAnchoring()

		-------------------------------------------
		-- Raze / Unraze / Annex City Buttons
		-------------------------------------------

		local hideButton = false
		local disableButton = false
		local buttonToolTip = "Error"
		local buttonLabel = "Error"
		local taskID
		if not isActivePlayerCity then
			hideButton = true

		elseif city:IsRazing() then

			-- We can unraze this city
			taskID = TaskTypes.TASK_UNRAZE
			buttonLabel = L"TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TEXT"
			buttonToolTip = L"TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TT"

		elseif city:IsPuppet() and not(bnw_mode and cityOwner:MayNotAnnex()) then

			-- We can annex this city
			taskID = TaskTypes.TASK_ANNEX_PUPPET
			buttonLabel = L"TXT_KEY_POPUP_ANNEX_CITY"
-- todo
			if civ5_mode then
				buttonToolTip = L( "TXT_KEY_POPUP_CITY_CAPTURE_INFO_ANNEX", cityOwner:GetUnhappinessForecast(city, nil) - cityOwner:GetUnhappiness() )
			end
		elseif not g_isViewingMode and cityOwner:CanRaze( city, true ) then
			buttonLabel = L"TXT_KEY_CITYVIEW_RAZE_BUTTON_TEXT"

			if cityOwner:CanRaze( city, false ) then

				-- We can actually raze this city
				taskID = TaskTypes.TASK_RAZE
				buttonToolTip = L"TXT_KEY_CITYVIEW_RAZE_BUTTON_TT"
			else
				-- We COULD raze this city if it weren't a capital
				disableButton = true
				buttonToolTip = L"TXT_KEY_CITYVIEW_RAZE_BUTTON_DISABLED_BECAUSE_CAPITAL_TT"
			end
		else
			hideButton = true
		end

		Controls.CityTaskLabel:SetText( buttonLabel )
		local CityTaskButton = Controls.CityTaskButton
		CityTaskButton:SetSizeX( Controls.CityTaskLabel:GetSizeX() + 30 )
		CityTaskButton:ReprocessAnchoring()
		CityTaskButton:SetVoids( cityID, taskID )
		CityTaskButton:SetToolTipString( buttonToolTip )
		CityTaskButton:SetDisabled( disableButton )
		CityTaskButton:SetHide( hideButton )

		UpdateWorkingHexesNow()
		UpdateCityProductionQueueNow( city, cityID, cityOwnerID, isActivePlayerCity and not isCityCaptureViewingMode and civ5_mode and bnw_mode and cityOwner:MayNotAnnex() and city:IsPuppet() )

		-- display gold income
		local iGoldPerTurn = city:GetYieldRateTimes100( g_yieldCurrency ) / 100
		Controls.GoldPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", iGoldPerTurn )

		-- display science income
		if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
			Controls.SciencePerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_OFF" )
		else
			local iSciencePerTurn = city:GetYieldRateTimes100(YieldTypes.YIELD_SCIENCE) / 100
			Controls.SciencePerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", iSciencePerTurn )
		end

		local culturePerTurn, cultureStored, cultureNext
		-- thanks for Firaxis Cleverness !
		if civ5_mode then
			culturePerTurn = city:GetJONSCulturePerTurn()
			cultureStored = city:GetJONSCultureStored()
			cultureNext = city:GetJONSCultureThreshold()
		else
			culturePerTurn = city:GetCulturePerTurn()
			cultureStored = city:GetCultureStored()
			cultureNext = city:GetCultureThreshold()
		end
		Controls.CulturePerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", culturePerTurn )
		local cultureDiff = cultureNext - cultureStored
		if culturePerTurn > 0 then
			local cultureTurns = math.max(math.ceil(cultureDiff / culturePerTurn), 1)
			Controls.CultureTimeTillGrowthLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_TURNS_TILL_TILE_TEXT", cultureTurns )
			Controls.CultureTimeTillGrowthLabel:SetHide( false )
		else
			Controls.CultureTimeTillGrowthLabel:SetHide( true )
		end
		local percentComplete = cultureStored / cultureNext
		Controls.CultureMeter:SetPercent( percentComplete )

		if gk_mode then
			if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
				Controls.FaithPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_OFF" )
			else
				Controls.FaithPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", city:GetFaithPerTurn() )
			end
			Controls.FaithFocusButton:SetDisabled( g_isViewingMode )
		end

		local cityGrowth = city:GetFoodTurnsLeft()
		if city:IsFoodProduction() or city:FoodDifferenceTimes100() == 0 then
			Controls.CityGrowthLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_STAGNATION_TEXT" )
		elseif city:FoodDifference() < 0 then
			Controls.CityGrowthLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_STARVATION_TEXT" )
		else
			Controls.CityGrowthLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_TURNS_TILL_CITIZEN_TEXT", cityGrowth )
		end
		local iFoodPerTurn = city:FoodDifferenceTimes100() / 100

		if (iFoodPerTurn >= 0) then
			Controls.FoodPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT", iFoodPerTurn )
		else
			Controls.FoodPerTurnLabel:LocalizeAndSetText( "TXT_KEY_CITYVIEW_PERTURN_TEXT_NEGATIVE", iFoodPerTurn )
		end

		-------------------------------------------
		-- Disable Buttons as Appropriate
		-------------------------------------------
		local bIsLock = g_isViewingMode or (cityOwner:GetNumCities() <= 1)
		Controls.PrevCityButton:SetDisabled( bIsLock )
		Controls.NextCityButton:SetDisabled( bIsLock )

		Controls.BalancedFocusButton:SetDisabled( g_isViewingMode )
		Controls.FoodFocusButton:SetDisabled( g_isViewingMode )
		Controls.ProductionFocusButton:SetDisabled( g_isViewingMode )
		Controls.GoldFocusButton:SetDisabled( g_isViewingMode )
		Controls.ResearchFocusButton:SetDisabled( g_isViewingMode )
		Controls.CultureFocusButton:SetDisabled( g_isViewingMode )
		Controls.GPFocusButton:SetDisabled( g_isViewingMode )

		Controls.AvoidGrowthButton:SetDisabled( g_isViewingMode )
		Controls.ResetButton:SetDisabled( g_isViewingMode )

		Controls.BoxOSlackers:SetDisabled( g_isViewingMode )

		Controls.EditButton:SetHide( g_isViewingMode )
	end
end

local function UpdateStuffNow()
	if IsGameCoreBusy() then
		return
	end
	ContextPtr:ClearUpdate()
	if g_isCityViewDirty then
		UpdateCityViewNow()
	end
	if g_isCityHexesDirty then
		UpdateWorkingHexesNow()
	end
	if g_toolTipHandler then
		if g_toolTipControl:HasMouseOver() then
			g_toolTipHandler( g_toolTipControl )
		else
print( g_toolTipControl:GetID(), "does not have  mouse over" )
		end
		g_toolTipHandler = nil
	end
end
RequestToolTip = function( ... )
	g_toolTipHandler, g_toolTipControl = ...
	return ContextPtr:SetUpdate( UpdateStuffNow )
end
local function UpdateCityView()
	g_isCityViewDirty = true
	return ContextPtr:SetUpdate( UpdateStuffNow )
end
local function UpdateWorkingHexes()
	g_isCityHexesDirty = true
	return ContextPtr:SetUpdate( UpdateStuffNow )
end

local function UpdateOptionsAndCityView()
	g_isAdvisor = not ( g_options and g_options.GetValue and g_options.GetValue( "CityAdvisorIsOff" ) == 1 )
	g_FocusSelectIM.Collapse( not OptionsManager.IsNoCitizenWarning() )
	Controls.BuyPlotCheckBox:SetCheck( g_BuyPlotMode )
	return UpdateCityView()
end

g_SpecialBuildingsIM	= InstanceStackManager( "BuildingInstance", "Button", Controls.SpecialBuildingsStack, Controls.SpecialBuildingsHeader, ResizeRightStack )
g_GreatWorkIM		= InstanceStackManager( "BuildingInstance", "Button", Controls.GreatWorkStack, Controls.GreatWorkHeader, ResizeRightStack )
g_WondersIM		= InstanceStackManager( "BuildingInstance", "Button", Controls.WondersStack, Controls.WondersHeader, ResizeRightStack )
g_BuildingsIM		= InstanceStackManager( "BuildingInstance", "Button", Controls.BuildingsStack, Controls.BuildingsHeader, ResizeRightStack )
g_GreatPeopleIM		= InstanceStackManager( "GPInstance", "GPBox", Controls.GPStack, Controls.GPHeader, ResizeRightStack )
g_SlackerIM		= InstanceStackManager( "SlotInstance", "Button", Controls.SlackerStack, Controls.SlackerHeader, ResizeRightStack )
g_ProdQueueIM		= InstanceStackManager( "ProductionInstance", "PQbox", Controls.QueueStack, Controls.ProdBox, ResizeProdQueue, true )
g_UnitSelectIM		= InstanceStackManager( "SelectionInstance", "Button", Controls.UnitButtonStack, Controls.UnitButton, ResizeProdQueue )
g_BuildingSelectIM	= InstanceStackManager( "SelectionInstance", "Button", Controls.BuildingButtonStack, Controls.BuildingsButton, ResizeProdQueue )
g_WonderSelectIM	= InstanceStackManager( "SelectionInstance", "Button", Controls.WonderButtonStack, Controls.WondersButton, ResizeProdQueue )
g_ProcessSelectIM	= InstanceStackManager( "SelectionInstance", "Button", Controls.OtherButtonStack, Controls.OtherButton, ResizeProdQueue )
g_FocusSelectIM		= InstanceStackManager( "", "", Controls.WorkerManagementBox, Controls.WorkerHeader, function(self, collapsed) g_workerHeadingOpen = not collapsed ResizeRightStack() UpdateWorkingHexes() end, true, not g_workerHeadingOpen )
local g_toolTipFunc

local function SetToolTipStringNow()
	g_leftTipControls.Text:SetText( g_toolTipFunc( UI.GetHeadSelectedCity() ) )
	g_leftTipControls.PortraitFrame:SetHide( true )
	return g_leftTipControls.Box:DoAutoSize()
end
local function SetToolTipString( control, toolTipFunc )
	g_toolTipFunc = toolTipFunc
	return RequestToolTip( SetToolTipStringNow, control )
end

local g_toolTips = {
	ProdBox = function( control )
		return SetToolTipString( control, GetProductionTooltip )
	end,
	FoodBox = function( control )
		return SetToolTipString( control, GetFoodTooltip )
	end,
	GoldBox = function( control )
		return SetToolTipString( control, GetGoldTooltip )
	end,
	ScienceBox = function( control )
		return SetToolTipString( control, GetScienceTooltip )
	end,
	CultureBox = function( control )
		return SetToolTipString( control, GetCultureTooltip )
	end,
	FaithBox = function( control )
		return SetToolTipString( control, GetFaithTooltip )
	end,
	TourismBox = function( control )
		return SetToolTipString( control, GetTourismTooltip )
	end,
	ProductionPortraitButton = ProductionToolTip
}
g_toolTips.PopulationBox = g_toolTips.FoodBox
Controls.ProductionPortraitButton:SetVoid1(0)

--------------
-- Rename City
local function RenameCity()
	local city = UI.GetHeadSelectedCity()
	if city then
		return Events.SerialEventGameMessagePopup{
				Type = ButtonPopupTypes.BUTTONPOPUP_RENAME_CITY,
				Data1 = city:GetID(),
				Data2 = -1,
				Data3 = -1,
				Option1 = false,
				Option2 = false
				}
	end
end

----------------
-- Citizen Focus
local FocusButtonBehavior = {
	[Mouse.eLClick] = function( focus )
		if isActivePlayerAllowed() then
			local city = UI.GetHeadSelectedCity()
			if city then
				Network.SendSetCityAIFocus( city:GetID(), focus )
--				return city:DoReallocateCitizens()
				return Network.SendUpdateCityCitizens( city:GetID() )
			end
		end
	end,
}

local g_callBacks = {
	BalancedFocusButton = FocusButtonBehavior,
	FoodFocusButton = FocusButtonBehavior,
	ProductionFocusButton = FocusButtonBehavior,
	GoldFocusButton = FocusButtonBehavior,
	ResearchFocusButton = FocusButtonBehavior,
	CultureFocusButton = FocusButtonBehavior,
	GPFocusButton = FocusButtonBehavior,
	FaithFocusButton = FocusButtonBehavior,

	AvoidGrowthButton = {
		[Mouse.eLClick] = function()
			local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
			if city then
				Network.SendSetCityAvoidGrowth( city:GetID(), not city:IsForcedAvoidGrowth() )
--				return city:DoReallocateCitizens()
				return Network.SendUpdateCityCitizens( city:GetID() )
			end
		end,
	},
	CityTaskButton = {
		[Mouse.eLClick] = function( cityID, taskID, button )
			local city = taskID and isActivePlayerTurn() and UI.GetHeadSelectedCity()
			if city and city:GetID() == cityID then
				return Events.SerialEventGameMessagePopup{
					Type = ButtonPopupTypes.BUTTONPOPUP_CONFIRM_CITY_TASK,
					Data1 = cityID,
					Data2 = taskID,
					Text = button:GetToolTipString()
					}
			end
		end,
	},
	YesButton = {
		[Mouse.eLClick] = function( cityID, buildingID )
			Controls.SellBuildingConfirm:SetHide( true )
			if isActivePlayerAllowed() and cityID and buildingID and buildingID > 0 then
				Network.SendSellBuilding( cityID, buildingID )
--				city:DoReallocateCitizens()
				Network.SendUpdateCityCitizens( cityID )
			end
			return Controls.YesButton:SetVoids( -1, -1 )
		end,
	},
	NoButton = {
		[Mouse.eLClick] = CancelBuildingSale,
	},
	NextCityButton = {
		[Mouse.eLClick] = GotoNextCity,
	},
	PrevCityButton = {
		[Mouse.eLClick] = GotoPrevCity,
	},
	ReturnToMapButton = {
		[Mouse.eLClick] = ExitCityScreen,
	},
	ProductionPortraitButton = {
		[Mouse.eRClick] = ProductionPedia,
	},
	BoxOSlackers = {
		[Mouse.eLClick] = OnSlackersSelected,
	},
	ResetButton = {
		[Mouse.eLClick] = PlotButtonClicked,
	},
	NoAutoSpecialistCheckbox = {
		[Mouse.eLClick] = function()
			return Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS, -1, -1, not UI.GetHeadSelectedCity():IsNoAutoAssignSpecialists() )
		end,
	},
--	BuyPlotButton = {
--		[Mouse.eLClick] = function()
--			local city = isActivePlayerAllowed() and UI.GetHeadSelectedCity()
--			if city then
--				return UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_PURCHASE_PLOT)
--			end
--		end,
--	},
	EditButton = {
		[Mouse.eLClick] = RenameCity,
	},
	CityNameTitleBarLabel = {
		[Mouse.eRClick] = RenameCity,
	},
}
g_callBacks.NoAutoSpecialistCheckbox2 = g_callBacks.NoAutoSpecialistCheckbox

--Controls.ResetButton:SetVoid1( 0 )	-- calling with 0 = city center causes reset of all forced tiles
--Controls.BoxOSlackers:SetVoids(-1,-1)
--Controls.ProductionPortraitButton:SetVoid1( 0 )
Controls.BalancedFocusButton:SetVoid1( CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE )
Controls.FoodFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD )
Controls.ProductionFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION )
Controls.GoldFocusButton:SetVoid1( g_focusCurrency )
Controls.ResearchFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE )
Controls.CultureFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE )
Controls.GPFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE )
if gk_mode then
	Controls.FaithFocusButton:SetVoid1( CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH )
end
Controls.GPFocusButton:SetHide( civBE_mode )
Controls.FaithBox:SetHide( civBE_mode or not gk_mode )
Controls.FaithFocusButton:SetHide( civBE_mode or not gk_mode )
Controls.TourismBox:SetHide( not civ5bnw_mode )

SetupCallbacks( Controls, g_toolTips, "EUI_CityViewLeftTooltip", g_callBacks )

Controls.BuyPlotCheckBox:RegisterCheckHandler( function( isChecked ) -- Void1, Void2, control )
	g_BuyPlotMode = isChecked
	g_options.SetValue( "CityPlotPurchaseIsOff", isChecked and 0 or 1 )
	return UpdateCityView()
end )

----------------------------------------------
-- Register Events
----------------------------------------------

Events.SerialEventCityScreenDirty.Add( UpdateCityView )
Events.SerialEventCityInfoDirty.Add( UpdateCityView )
Events.GameOptionsChanged.Add( UpdateOptionsAndCityView )
Events.SerialEventCityHexHighlightDirty.Add( UpdateWorkingHexes )
UpdateOptionsAndCityView()

--------------------------
-- Enter City Screen Event
Events.SerialEventEnterCityScreen.Add(
function()

--	local city = UI.GetHeadSelectedCity()
--	if city then
--		Network.SendUpdateCityCitizens( city:GetID() )
--		city:DoReallocateCitizens()
--	end

	LuaEvents.TryQueueTutorial("CITY_SCREEN", true)

	g_queuedItemNumber = false
	g_previousCity = false
--TODO other scroll panels
	Controls.RightScrollPanel:SetScrollValue(0)
	-- Hack / restore unit cycling
	if g_autoUnitCycleRequest then
		g_autoUnitCycleRequest = false
		OptionsManager.SyncGameOptionsCache()
		OptionsManager.SetAutoUnitCycle_Cached( true )
		OptionsManager.CommitGameOptions()
	end
end)

-------------------------
-- Exit City Screen Event
Events.SerialEventExitCityScreen.Add(
function()
	Events.ClearHexHighlights()

	-- We may get here after a player change, clear the UI if this is not the active player's city
	local city = UI.GetHeadSelectedCity()
	if not city or city:GetOwner() ~= g_activePlayerID then
		ClearCityUIInfo()
	end
	UI.ClearSelectedCities()
	LuaEvents.TryDismissTutorial("CITY_SCREEN")

	CancelBuildingSale()

	-- Try and re-select the last unit selected
	if not UI.GetHeadSelectedUnit() and UI.GetLastSelectedUnit() then
		UI.SelectUnit(UI.GetLastSelectedUnit())
		UI.LookAtSelectionPlot()
	end
	g_isViewingMode = true
	return UI.SetCityScreenViewingMode(false)
end)
if civ5_mode then
	------------------------------------
	-- Strategic View State Change Event
	local NormalWorldPositionOffset = g_worldPositionOffset
	local NormalWorldPositionOffset2 = g_worldPositionOffset2
	local StrategicViewWorldPositionOffset = { x = 0, y = 20, z = 0 }
	Events.StrategicViewStateChanged.Add(
	function( bStrategicView )
		if bStrategicView then
			g_worldPositionOffset = StrategicViewWorldPositionOffset
			g_worldPositionOffset2 = StrategicViewWorldPositionOffset
		else
			g_worldPositionOffset = NormalWorldPositionOffset
			g_worldPositionOffset2 = NormalWorldPositionOffset2
		end
		g_previousCity = false
		return UpdateCityView()
	end)
end
--------------------------------------------
-- 'Active' (local human) player has changed
Events.GameplaySetActivePlayer.Add(
function( activePlayerID, previousActivePlayerID )
	g_activePlayerID = activePlayerID
	g_activePlayer = Players[ g_activePlayerID ]
	g_finishedItems = {}
	ClearCityUIInfo()
	if UI.IsCityScreenUp() then
		return ExitCityScreen()
	end
end)

Events.ActivePlayerTurnEnd.Add(
function()
	g_finishedItems = {}
end)

Events.SerialEventGameMessagePopup.Add(
function( popupInfo )
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION then
		return
	end
	Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION, 0)
	Events.SerialEventGameMessagePopupShown( popupInfo )

	local cityID = popupInfo.Data1		-- city id
	local orderID = popupInfo.Data2		-- finished order id
	local itemID = popupInfo.Data3		-- finished item id
	local city = cityID and g_activePlayer:GetCityByID( cityID )

	if city and not UI.IsCityScreenUp() then
		if orderID >= 0 and itemID >= 0 then
			g_finishedItems[ cityID ] = { orderID, itemID }
		end
		return UI.DoSelectCityAtPlot( city:Plot() )	--force open city screen
	end
end)

Events.NotificationAdded.Add(
function( notificationID, notificationType, toolTip, strSummary, data1, data2, playerID )
	if notificationType == NotificationTypes.NOTIFICATION_PRODUCTION and playerID == g_activePlayerID and data1 >= 0 and data2 >=0 then
		-- Hack to find city
		for city in g_activePlayer:Cities() do
			if strSummary == L( "TXT_KEY_NOTIFICATION_NEW_CONSTRUCTION", city:GetNameKey() ) then
				g_finishedItems[ city:GetID() ] = { data1, data2 }
			end
		end
	end
end)

Events.SerialEventCityCreated.Add(
function( hexPos, playerID, cityID ) --, cultureType, eraType, continent, populationSize, size, fowState )
	-- enter city view mode
	if playerID == g_activePlayerID and not UI.IsCityScreenUp() then
		local city = g_activePlayer:GetCityByID(cityID)
		if city then
			-- Hack to prevent immediate closure by unit auto cycling
			g_autoUnitCycleRequest = OptionsManager.GetAutoUnitCycle()
			if g_autoUnitCycleRequest then
				OptionsManager.SyncGameOptionsCache()
				OptionsManager.SetAutoUnitCycle_Cached( false )
				OptionsManager.CommitGameOptions()
			end
			return UI.DoSelectCityAtPlot( city:Plot() )
		end
	end
end)

print("Finished loading EUI city view",os.clock())
end)

---------------------------------
-- Support for Modded Add-in UI's
---------------------------------
g_uiAddins = {}
for addin in Modding.GetActivatedModEntryPoints("CityViewUIAddin") do
	local addinFile = Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File)
	local addinPath = addinFile.EvaluatedPath

	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinPath)
	local path = addinPath:sub( 1, #addinPath - #extension )
	local ok, result = pcall( ContextPtr.LoadNewContext, ContextPtr, path )
	if ok then
		table.insert( g_uiAddins, result )
	else
		print( addinPath, result )
	end
end
