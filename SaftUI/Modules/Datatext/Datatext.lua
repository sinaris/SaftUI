local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:NewModule('DataText')

DT.Modules = {}
DT.Panels = {}

function DT:RegisterDataModule(name, Enable, Disable, Update)
	assert(not DT.Modules[name], 'Module named ' .. name .. ' already exists.')

	local module = CreateFrame("Frame", nil, UIParent)
	module.Text = S.CreateFontString(module)
	module.Text:SetAllPoints(module)

	module.name = name
	module.key = strlower(name:gsub(' ', '')) --for table access
	module.Enable = Enable
	module.Disable = Disable
	module.Update = Update
	
	DT.Modules[module.key] = module
end

function DT:GetModuleHash()
	local hash = {}
		hash['none'] = '-'
		for _,module in pairs(self.Modules) do
			hash[module.key] = module.name
		end
	return hash
end

function DT:PositionTooltip(panel)
	local parent = panel:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(panel, 'ANCHOR_RIGHT', -panel:GetWidth(), S.borderinset)
	GameTooltip:ClearLines()
end

function DT:InitializeDataPanels()
	local bottom = CreateFrame('Frame', 'SaftUI_DataText_BottomPanel', UIParent)
	bottom:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', -S.borderinset, -S.borderinset)
	bottom:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', S.borderinset, -S.borderinset)
	bottom:SetHeight(15)
	bottom:SetFrameStrata('BACKGROUND')
	-- bottom:SetTemplate('TS')

	self.BottomPanel = bottom
end

function DT:CreateStartMenu()
	local start = S.CreateButton('SaftUI_DataText_StartButton', self.BottomPanel, '|cff00aaffS|rUI')
	start:SetSize(26, S.Saved.profile.DataText.height)
	start:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 4, 4)
	start:SetTemplate('TS')
	start:HookScript('OnEnter', function(self) self.text:SetText('|cff00aaffSUI|r') end)
	start:HookScript('OnLeave', function(self) self.text:SetText('|cff00aaffS|rUI') end)
	self.StartButton = start


	start.MenuFrame = CreateFrame("Frame", "SaftUIMicroButtonsDropDown", start, "UIDropDownMenuTemplate")
	start.MenuFrame:Hide()
	start.MenuFrame:SetPoint('BOTTOMLEFT', start, 'BOTTOMLEFT', 0, S.borderinset+2)
	start.MenuTable = {
		{text = CHARACTER_BUTTON, 								func = function() ToggleCharacter("PaperDollFrame") end},
		{text = SPELLBOOK_ABILITIES_BUTTON, 					func = function() ToggleFrame(SpellBookFrame) end},
		{text = TALENTS_BUTTON, 								func = function() if not PlayerTalentFrame then TalentFrame_LoadUI() end; ShowUIPanel(PlayerTalentFrame) end},
		{text = ACHIEVEMENT_BUTTON, 							func = function() ToggleAchievementFrame() end},
		{text = QUESTLOG_BUTTON, 								func = function() ToggleFrame(QuestLogFrame) end},
		{text = MOUNTS_AND_PETS, 								func = function() TogglePetJournal() end},
		{text = FRIENDS_LIST, 									func = function() ToggleFriendsFrame(1) end},
		{text = DUNGEONS_BUTTON, 								func = function() PVEFrame_ToggleFrame(); end},
		{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP, 	func = function() if not PVPUIFrame then PVP_LoadUI() end; PVPUIFrame_ShowFrame() end},
		{text = ACHIEVEMENTS_GUILD_TAB, func = function() 
			if IsInGuild() then 
				if not GuildFrame then GuildFrame_LoadUI() end 
				GuildFrame_Toggle() 
			else 
				if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end 
				LookingForGuildFrame_Toggle() 
			end
		end},
		{text = RAID, 											func = function() ToggleFriendsFrame(4) end},
		{text = HELP_BUTTON, 									func = function() ToggleHelpFrame() end},
		{text = CALENDAR_VIEW_EVENT, 							func = function() if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end	Calendar_Toggle() end},
		{text = ENCOUNTER_JOURNAL, 								func = function() ToggleEncounterJournal() end},
		{text = 'SaftUI Config', 								func = function() S:LoadConfig() end},
	}

	 -- need to be opened at least one time before logging in, or big chance of taint later ...
	ToggleFrame(SpellBookFrame)
	PetJournal_LoadUI()
	
	-- UIDropDownMenu_Initialize(start.MenuFrame, EasyMenu_Initialize, nil, nil, start.MenuTable);

	start:SetScript('OnClick', function(self)
		EasyMenu(start.MenuTable, start.MenuFrame, start, 0, 200, "MENU", 2)
		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint('BOTTOMLEFT', start, 'TOPLEFT', 0, 6)
	end)

	-- -- need to be opened at least one time before logging in, or big chance of taint later ...
	-- local taint = CreateFrame("Frame")
	-- taint:RegisterEvent("ADDON_LOADED")
	-- taint:SetScript("OnEvent", function(self, event, addon)
	-- 	if addon ~= "Tukui" then return end
		
	-- end)
end

function DT:OnEnable()
	if not S.Saved.profile.DataText.enable then return end 

	self:InitializeDataPanels()
	self:CreateStartMenu()
	local lastModule
	for i,moduleKey in pairs(S.Saved.profile.DataText.Positions) do
		local module = self.Modules[moduleKey]
		if module then 
			module:SetPoint('LEFT', lastModule or self.StartButton, 'RIGHT', 4, 0)
			module:Enable()
			module:SetSize(module:GetAttribute('width') or 100, S.Saved.profile.DataText.height)
			module:SetTemplate('TS')
			module:SetFrameLevel(4)
			lastModule = module
		end
	end
end