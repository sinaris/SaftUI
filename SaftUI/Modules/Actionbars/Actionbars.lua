local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LAB = LibStub("LibActionButton-1.0")

local AB = S:NewModule('ActionBars', 'AceEvent-3.0', 'AceHook-3.0')

--Settings specific to each bar, do not touch this table
local BAR_SETTINGS = {
	[1] = { bind = "ACTIONBUTTON", 			page = 1, visibility = '[petbattle] hide; show' },
	[2] = { bind = "MULTIACTIONBAR1BUTTON", page = 6, visibility = '[vehicleui] hide; [overridebar] hide; [petbattle] hide; show' },
	[3] = { bind = "MULTIACTIONBAR2BUTTON", page = 5, visibility = '[vehicleui] hide; [overridebar] hide; [petbattle] hide; show' },
	[4] = { bind = "MULTIACTIONBAR4BUTTON", page = 4, visibility = '[vehicleui] hide; [overridebar] hide; [petbattle] hide; show' },
	[5] = { bind = "MULTIACTIONBAR3BUTTON", page = 3, visibility = '[vehicleui] hide; [overridebar] hide; [petbattle] hide; show' }
}

--Page settings, don't touch this either
local BAR_PAGES = {
	['DEFAULT']	 = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex()),
	['DRUID']	 = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- ['WARRIOR']	 = "[stance:1] 7; [stance:2] 8; [stance:3] 9;",
	['PRIEST']	 = "[bonusbar:1] 7;",
	['ROGUE']	 = "[bonusbar:1] 7; [stance:3] 10;",
	['MONK']	 = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	['WARLOCK']	 = "[stance:1] 10;",
}

-- http://www.wowace.com/addons/libactionbutton-1-0/pages/button-configuration/
local ButtonConfig = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	showGrid = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 }
	},
	hideElements = {
		macro = true,
		hotkey = false,
		equipped = false,
	},
	keyBoundTarget = false,
	clickOnDown = false,
	flyoutDirection = "UP",
}

AB.customExitButton = {
	func = function(button)
		if UnitExists('vehicle') then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE,
}

function AB:GetActionBarPage(BarID)
	if BarID == 1 then
		local conditions = BAR_PAGES['DEFAULT']
		if BAR_PAGES[S.myclass] then 
			conditions = conditions .. ' ' .. BAR_PAGES[S.myclass]
		end
		return conditions .. BAR_SETTINGS[BarID]['page']
	end
	
	return BAR_SETTINGS[BarID]['page']
end

--Creates a normal action bar with 12 buttons
function AB:CreateActionBar(BarID)
	local config = S.Saved.profile.ActionBars
	local barname = 'bar'..BarID

	local bar = CreateFrame('Frame', 'SaftUI_ActionBar'..BarID, UIParent, 'SecureHandlerStateTemplate')
	bar.BarID = BarID
	bar.buttons = {}
	bar.config = BAR_SETTINGS[BarID]
	bar.buttonconfig = table.copy(ButtonConfig)

	bar:CreateBackdrop(config.Bars[BarID].background.transparent and "T" or '')
	bar.backdrop:SetInside(bar, -((S.borderinset+config.buttonspacing)))

	bar:SetFrameLevel(10)

	--Enable mouseover fading scripts
	bar:HookScript('OnEnter', function(self)	if self.mouseover then self:SetAlpha(1) end end)
	bar:HookScript('OnLeave', function(self)	if self.mouseover then self:SetAlpha(0) end end)

	for i=1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		bar.buttons[i].bind = bar.config.bind..i
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 14 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end

		bar.buttons[i].PostUpdateHotkey = AB.FixKeybind
		self:SkinActionButton(bar.buttons[i])


		bar.buttons[i]:HookScript('OnEnter', function(self) if bar.mouseover then bar:SetAlpha(1) end end)
		bar.buttons[i]:HookScript('OnLeave', function(self) if bar.mouseover then bar:SetAlpha(0) end end)

		if i == 12 then
			bar.buttons[i]:SetState(12, "custom", AB.customExitButton)
		end	
	end

	bar:SetAttribute("_onstate-page", [[ 
		self:SetAttribute("state", newstate)
		control:ChildUpdate("state", newstate)
	]])

	RegisterStateDriver(bar, 'page', self:GetActionBarPage(BarID))
	RegisterStateDriver(bar, "visibility", bar.config.visibility);


	self.Bars[BarID] = bar
	AB:UpdateButtonConfig(BarID)
	AB:UpdateActionBarVisibility(BarID)
	
	return bar
end

function AB:UpdateButtonConfig(BarID)
	local bar = self.Bars[BarID]
	--when no bar is specified, recursively update all bars
	if not bar then for i=1, 5 do self:UpdateButtonConfig(i) end return end

	local config = S.Saved.profile.ActionBars
	
	--update text/grid visibility
	bar.buttonconfig.hideElements.macro = not config.macrotext
	bar.buttonconfig.hideElements.hotkey = not config.hotkeytext
	bar.buttonconfig.showGrid = config.showgrid

	for i,button in pairs(bar.buttons) do
		-- self:SkinActionButton(button)
		bar.buttonconfig.keyBoundTarget = bar.config.bind..i
		button.bindString = bar.config.bind..i
		button:SetAttribute("buttonlock", true)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)

		button:UpdateConfig(bar.buttonconfig)
	end
end

function AB:UpdateActionBar(BarID)
	if not BarID then
		for id,_ in pairs(self.Bars) do
			self:UpdateActionBar(id)
		end
		return
	end
	local bar = self.Bars[BarID]
	assert(bar, 'No bars found with the BarID '.. BarID)
	
	local gCon = S.Saved.profile.ActionBars
	local bCon = gCon.Bars[BarID]

	local size, spacing = bCon.buttonsize, bCon.buttonspacing
	local numbuttons = bCon.numbuttons
	local vertical = bCon.vertical
	
	if bar.config then 
		if bCon.enabled then
			RegisterStateDriver(bar, "visibility", bar.config.visibility);
			bar:Show()
		else
			UnregisterStateDriver(bar, "visibility", bar.config.visibility);
			bar:Hide()
		return end
	end

	self:UpdateActionBarBackground(BarID)
	self:UpdateActionBarVisibility(BarID)

	--Position the bar
	bar:ClearAllPoints()
	bar:SetPoint(unpack(bCon.point))

	--Set bar orientation
	local long = size * (numbuttons) + spacing * (numbuttons-1)
	if vertical then
		bar:SetSize(size, long)
	else
		bar:SetSize(long, size)
	end
	
	--Set button orientation and size (and show/hide buttons as needed)
	for i,button in pairs(bar.buttons) do
		button:SetSize(size, size)
		button:ClearAllPoints()
		if BarID ~= 'pet' then button:Show() end

		if i == 1 then
			button:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
		elseif i > numbuttons then
			button:SetPoint('BOTTOM', UIParent, 'TOP', 500, 0)
			if BarID ~= 'pet' then button:Hide() end
		else
			if vertical then
				button:SetPoint('TOP', bar.buttons[i-1], 'BOTTOM', 0, -spacing)
			else
				button:SetPoint('LEFT', bar.buttons[i-1], 'RIGHT', spacing, 0)
			end
		end
	end
end

function AB:Bar_OnEnter(bar)
	bar:SetAlpha(1)
end

function AB:Bar_OnLeave(bar)
	bar:SetAlpha(0)
end

function AB:Button_OnEnter(buttons)
	buttons:GetParent():SetAlpha(1)
end

function AB:Button_OnLeave(buttons)
	buttons:GetParent():SetAlpha(0)
end

function AB:UpdateActionBarVisibility(BarID)
	local bar = self.Bars[BarID]
	assert(bar, 'No bars found with the BarID '.. BarID)

	bar.mouseover = S.Saved.profile.ActionBars.Bars[BarID].mouseover
	bar:SetAlpha(bar.mouseover and 0 or 1)
end

function AB:UpdateActionBarBackground(BarID)
	local bar = self.Bars[BarID]
	assert(bar, 'No bars found with the BarID '.. BarID)
	
	local gCon = S.Saved.profile.ActionBars
	local bCon = gCon.Bars[BarID]

	local size, spacing = bCon.buttonsize, bCon.buttonspacing

	if bCon.background.enable then
		local width = (bCon.background.width * size) + ((bCon.background.width+1) * spacing)
		local height = (bCon.background.height * size) + ((bCon.background.height+1) * spacing)
		
		if bar.backdrop and not bar.backdrop:IsShown() then bar.backdrop:Show() end

		bar.backdrop:ClearAllPoints()
		local anchor = strupper(bCon.background.anchor)

		local xOff = strfind(anchor, 'LEFT') and -spacing or strfind(anchor, 'RIGHT') and spacing or 0
		local yOff = strfind(anchor, 'BOTTOM') and -spacing or strfind(anchor, 'TOP') and spacing or 0
		bar.backdrop:SetPoint(bCon.background.anchor, bar, bCon.background.anchor, xOff, yOff-5)
		bar.backdrop:SetSize(width+10, height+10)

		bar.backdrop:SetTemplate(bCon.background.transparent and 'T' or '')
	else
		if bar.backdrop:IsShown() then bar.backdrop:Hide() end
	end
end

-- Cleanly hides/disables blizzard's default action bars
function AB:DisableBlizzardBars()

	MultiBarBottomLeft:SetParent(S.HiddenFrame)
	MultiBarBottomRight:SetParent(S.HiddenFrame)
	MultiBarLeft:SetParent(S.HiddenFrame)
	MultiBarRight:SetParent(S.HiddenFrame)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)
	
		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)
		
		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)
		
		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)
		
		if _G["VehicleMenuBarActionButton" .. i] then
			_G["VehicleMenuBarActionButton" .. i]:Hide()
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true)
		end
		
		if _G['OverrideActionBarButton'..i] then
			_G['OverrideActionBarButton'..i]:Hide()
			_G['OverrideActionBarButton'..i]:UnregisterAllEvents()
			_G['OverrideActionBarButton'..i]:SetAttribute("statehidden", true)
		end
		
		_G['MultiCastActionButton'..i]:Hide()
		_G['MultiCastActionButton'..i]:UnregisterAllEvents()
		_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	
	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(S.HiddenFrame)
	MainMenuExpBar:SetScript('OnShow', function(self) self:Hide() end)

	for i=1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(S.HiddenFrame)
		end
	end

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(S.HiddenFrame)	
	ReputationWatchBar:SetScript('OnShow', function(self) self:Hide() end)

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(S.HiddenFrame)
	
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(S.HiddenFrame)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(S.HiddenFrame)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(S.HiddenFrame)

	-- PetActionBarFrame:UnregisterAllEvents()
	-- PetActionBarFrame:Hide()
	-- PetActionBarFrame:SetParent(S.HiddenFrame)
	
	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(S.HiddenFrame)
	
	--This frame puts spells on the damn actionbar, fucking obliterate that shit
	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(S.HiddenFrame)

	--InterfaceOptionsFrameCategoriesButton6:SetScale(0.00001)
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:OnEnable()
	if not S.Saved.profile.ActionBars.enable then return end

	self.Bars = {}
	self:DisableBlizzardBars()
	for i=1, 5 do self:CreateActionBar(i) end
	self:SetupExtraButton()
	for i=1, 5 do self:UpdateActionBar(i) end

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PET_BATTLE_CLOSE", "UPDATE_BINDINGS")
	self:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')

	-- self:PetBar_Initialize()
	self:UPDATE_BINDINGS()

end

function AB:OnDisable()
	StaticPopup_Show('SAFTUI_CONFIGRELOAD')
end

function AB:UPDATE_BINDINGS(event)
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end	
	for i=1, 5 do
		local bar = self.Bars[i]		
		ClearOverrideBindings(bar)
		for i,button in pairs(bar.buttons) do
			local name = button:GetName()

			for k=1, select('#', GetBindingKey(button.bind)) do
				local key = select(k, GetBindingKey(button.bind))
				if key and key ~= "" then
					SetOverrideBindingClick(bar, false, key, name)
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end	
	for i=1, 5 do
		local bar = self.Bars[i]
		if not bar then return end
		
		ClearOverrideBindings(bar)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end