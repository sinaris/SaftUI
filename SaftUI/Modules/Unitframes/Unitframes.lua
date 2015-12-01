local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local UF = S:NewModule('UnitFrames', 'AceEvent-3.0', 'AceHook-3.0')

local _, ns = ...
local oUF = ns.oUF
assert(oUF, 'SaftUI was unable to locate oUF.')
UF.oUF = oUF

UF.Units = {} --Unitframes
UF.Headers = {} --Group headers
UF.Layouts = {} --General layouts

--Sadly I can't see a clean way to do this
-- without hardcoding it
UF.TextModuleHash = {
	['none'] = '-',
	['power'] = 'Power',
	['name'] = 'Name',
	['health'] = 'Health',
}

UF.CustomTextFunctions = {
	health = {
		percent = '',
	},
}

--dropdown menu
local dropdown = CreateFrame('Frame', 'SaftUI_oUFDropDown', UIParent, 'UIDropDownMenuTemplate')
S.SpawnMenu = function(self)
	dropdown:SetParent(self)
	return ToggleDropDownMenu(nil, nil, dropdown, 'cursor', 0, 0)
end

local initdropdown = function(self)
	local unit = self:GetParent().unit
	local menu, name, id

	if (not unit) then return end

	if(UnitIsUnit(unit, 'player')) then
		menu = 'SELF'
	elseif(UnitIsUnit(unit, 'vehicle')) then
		menu = 'VEHICLE'
	elseif(UnitIsUnit(unit, 'pet')) then
		menu = 'PET'
	elseif(UnitIsPlayer(unit)) then
		id = UnitInRaid(unit)
		if(id) then
			menu = 'RAID_PLAYER'
			name = GetRaidRosterInfo(id)
		elseif(UnitInParty(unit)) then
			menu = 'PARTY'
		else
			menu = 'PLAYER'
		end
	else
		menu = 'TARGET'
		name = RAID_TARGET_ICON
	end

	if(menu) then
		UnitPopup_ShowMenu(self, menu, unit, name, id)
	end
end
UIDropDownMenu_Initialize(dropdown, initdropdown, 'MENU')

--Create the core of each unit
function UF.ConstructUnit(self, unit)
	self.baseunit = strmatch(unit, '%D+') -- store the basic unit string for config access (unit without numbers)
	self.unitID = tonumber(strmatch(unit, '%d+')) --store the number for when you need an integer value (such as for positioning)
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self.menu = S.SpawnMenu
	self.colors = UF.Colors
	self:CreateBackdrop('T')
	-- self.backdrop:SetAllPoints()
	-- self.backdrop:Hide()

	local fontProfile = S.Saved.profile.UnitFrames.pixelfont and 'pixel'

	-- Create health bar
	local health = S.CreateStatusBar(self)
	health:CreateBackdrop()
	health.Smooth = true
	health.PostUpdate = UF.PostUpdateHealth
	self.Health = health

	-- Create power bar
	local power = S.CreateStatusBar(self)
	power:CreateBackdrop()
	power.Smooth = true
	power.PostUpdate = UF.PostUpdatePower
	self.Power = power

	-- Create castbar
	local castbar = S.CreateStatusBar(self)
	castbar:CreateBackdrop()

	local time = S.CreateFontString(castbar, fontProfile)
	time:SetPoint('RIGHT', castbar, 'RIGHT', -4, 0)
	castbar.Time = time

	local name = S.CreateFontString(castbar, fontProfile)
	name:SetPoint('LEFT', castbar, 'LEFT', 4, 0)
	name:SetPoint('RIGHT', castbar, 'RIGHT', -45, 0)
	name:SetJustifyH('LEFT')
	castbar.Text = name
	
	-- local safezone = castbar:CreateTexture(nil, 'OVERLAY')
	-- safezone:SetInside(castbar)
	-- safezone:SetTexture(.8,.3,.3,0.5)
	-- castbar.SafeZone = safezone

	-- castbar.PostCastNotInterruptible = UF.PostUninterruptibleCast
	-- castbar.PostCastInterruptible    = UF.PostInterruptibleCast

	self.Castbar = castbar

	-- Create portrait
	local portrait = CreateFrame('PlayerModel', nil, self)
	self.Portrait = portrait

	-- Create text frame
	local raisedFrame = CreateFrame('Frame', nil, self)
	raisedFrame:SetAllPoints(health) --make sure text is anchored properly
	self.RaisedFrame = raisedFrame

	-- Create health text
	local healthText = S.CreateFontString(raisedFrame, fontProfile)
	self.Health.text = healthText
	
	-- Create power text
	local powerText = S.CreateFontString(raisedFrame, fontProfile)
	self.Power.text = powerText

	-- Create name text
	local name = S.CreateFontString(raisedFrame, fontProfile)
	self.Name = name

	-- Create buff icons
	local buffs = CreateFrame('Frame', nil, self)
	buffs.PostUpdateIcon = UF.PostUpdateBuffIcon
	buffs.PostCreateIcon = UF.PostCreateAuraIcon
	self.Buffs = buffs

	-- Create debuff icons
	local debuffs = CreateFrame('Frame', nil, self)
	debuffs.PostUpdateIcon = UF.PostUpdateDebuffIcon
	debuffs.PostCreateIcon = UF.PostCreateAuraIcon
	self.Debuffs = debuffs

	if self.baseunit == 'boss' then
		buffs:SetPoint('LEFT', self, 'RIGHT', 3, 0)
	end

	-- Create raid debuff icon
	local raidDebuffs = CreateFrame('Frame', nil, self)
	raidDebuffs:SetSize(S.Saved.profile.UnitFrames.Units.raid.raiddebuffs.size, S.Saved.profile.UnitFrames.Units.raid.raiddebuffs.size)
	raidDebuffs:SetTemplate()

	if self.baseunit == 'raid' then
		raidDebuffs:SetPoint('CENTER', self, 'CENTER', 0, 0)
		self.Range = {insideAlpha = 1, outsideAlpha = S.Saved.profile.UnitFrames.Units.raid.ooralpha}
	end

	raidDebuffs.icon = raidDebuffs:CreateTexture(nil, 'OVERLAY')
	raidDebuffs.icon:SetTexCoord(unpack(S.iconcoords))
	raidDebuffs.icon:SetPoint('TOPLEFT', 2, -2)
	raidDebuffs.icon:SetPoint('BOTTOMRIGHT', -2, 2)

	raidDebuffs.count = S.CreateFontString(raidDebuffs.cd or raidDebuffs, fontProfile)
	raidDebuffs.count:SetPoint('BOTTOMRIGHT', raidDebuffs, 'BOTTOMRIGHT', 0, 2)

	self.RaidDebuffs = raidDebuffs

	-- Create grid corner icons

	if self.baseunit == 'raid' then
		--Create aura watch for corner buffs
		local auras = CreateFrame('frame', nil, self)
		auras:SetInside(self)
		auras:SetFrameLevel(50)
		auras.presentAlpha = 1
		auras.missingAlpha = 0
		auras.PostCreateIcon = UF.PostCreateAuraWatchIcon
		auras.icons = {}

		if UF.AuraWatchSpellIDs[S.myclass] then
			for i, values in pairs(UF.AuraWatchSpellIDs[S.myclass]) do
				local sid, position, color, anyUnit = unpack(values)

				local icon = CreateFrame('Frame', self:GetName()..'_RaidAura'..i, auras)
				icon.color = color or {1, 1, 1} --store it for use in PostCreateIcon function
				icon.spellID = sid

				icon.anyUnit = anyUnit
				icon:SetSize(8, 8)
				local xoff, yoff = unpack(UF.AuraWatchPositionOffsets[position])
				icon:SetPoint(position, self.Health, xoff, yoff)

				auras.icons[sid] = icon
			end
			self.AuraWatch = auras
		end
		
		-- Create group role indicator
		local LFDRole = CreateFrame('Frame', nil, self)
		LFDRole:SetSize(8, 3)
		LFDRole:SetPoint('BOTTOM', self.Health, 0, -1)
		LFDRole:SetTemplate()
		LFDRole.Icon = LFDRole:CreateTexture(nil, 'OVERLAY')	
		LFDRole.Icon:SetInside(LFDRole)
		LFDRole:SetFrameLevel(self.Health:GetFrameLevel()+2)
		local ROLE_COLORS = {
			['TANK']    = { 0.0, 0.6, 1.0 },
			['HEALER']  = { 0.4, 1.0, 0.4 },
			['DAMAGER'] = { 1.0, 0.4, 0.4 },
		}
		LFDRole.Override = function(self, event)
			local lfdrole = self.LFDRole
			local role = UnitGroupRolesAssigned(self.unit)

			if(lfdrole.PreUpdate) then lfdrole:PreUpdate(role)	end

			if role == 'NONE' then
				lfdrole:Hide()
			else
				lfdrole:Show()
				lfdrole.Icon:SetTexture(unpack(ROLE_COLORS[role]))
			end

			if(lfdrole.PostUpdate) then	return lfdrole:PostUpdate(role)	end	
		end
		self.LFDRole = LFDRole

		-- Create group leader indicator
		local leader = CreateFrame('Frame', nil, self)
		leader:SetSize(8, 3)
		leader:SetPoint('BOTTOMRIGHT', self.Health, 1, -1)
		leader:SetTemplate()
		leader:SetFrameLevel(self.Health:GetFrameLevel()+2)

		leader.Icon = leader:CreateTexture(nil, 'OVERLAY')
		leader.Icon:SetInside(leader)
		leader.Icon:SetTexture(1.0, 1.0, 0.2)
		self.Leader = leader

		local readycheck = CreateFrame('frame', 'readycheckthing', self)
		readycheck:SetSize(8, 3)
		readycheck:SetPoint('BOTTOMLEFT', self.Health, -1, -1)
		readycheck:SetTemplate()
		readycheck:SetFrameLevel(self.Health:GetFrameLevel()+2)
		readycheck:Hide()

		readycheck.Icon = readycheck:CreateTexture(nil, 'OVERLAY')
		readycheck.Icon:SetInside(readycheck)
		
		local READY_CHECK_TEXTURES = {
			[READY_CHECK_WAITING_TEXTURE] = { 1.0, 1.0, 0.2 },
			[READY_CHECK_READY_TEXTURE] = { 0.4, 1.0, 0.4 },
			[READY_CHECK_NOT_READY_TEXTURE] = { 1.0, 0.4, 0.4 },
		}		
		
		readycheck.SetTexture = function(self, texture)
			if READY_CHECK_TEXTURES[texture] then
				self.Icon:SetTexture(unpack(READY_CHECK_TEXTURES[texture]))
			end
		end
		self.ReadyCheck = readycheck

		UF:UpdateUnit(self)
	end

	return self
end

function UF:UpdateUnit(frameOrUnit, moduleName, ...)
	-- if InCombatLockdown() then return end

	local frame, unit

	if type(frameOrUnit) == 'string' then
		unit = frameOrUnit

		if unit == 'arena' or unit == 'boss' then
			for i=1, 5 do self:UpdateUnit(unit..i, module) end
			return
		end

		if unit == 'raid' then UF:UpdateGroupHeader('raid', moduleName, ...); return end

		frame = self.Units[unit]
	else
		frame = frameOrUnit
		unit = frame.unit
	end

	local gCon = S.Saved.profile.UnitFrames
	local uCon = gCon.Units[frame.baseunit]

	if moduleName then 
		local module = UF.Updaters[strlower(moduleName)]
		if module then module(frame, gCon, uCon, frame.baseunit == 'raid', ...) end
	else
		for modName,module in pairs(UF.Updaters) do
			module(frame, gCon, uCon, frame.baseunit == 'raid', ...)
		end
	end
end

function UF:UpdateAllUnits(moduleName)
	-- if InCombatLockdown() then return end

	for _,unit in pairs(self.Units) do
		self:UpdateUnit(unit, moduleName)
	end
	self:UpdateGroupHeader('raid', moduleName)
end

UF.Updaters = {
	['position'] = function(frame, gCon, uCon, raidUnit)
		if uCon.enable then
			frame.backdrop:SetTemplate(uCon.backdrop.enable and (uCon.backdrop.transparent and 'T' or '') or 'N')

			-- Do not run this if unit is part of a group raidUnit	
			if InCombatLockdown() or raidUnit then return end

			frame:Enable()
			--Update Unitframe Position
			frame:ClearAllPoints()
			if frame.unitID and frame.unitID > 1 then
				frame:SetPoint('BOTTOM', UF.Units[frame.baseunit..(frame.unitID-1)], 'TOP', 0, 20)
			else
				frame:SetPoint(unpack(uCon.point))
			end	
		else
			frame:Disable()
		end
	end,

	['size'] = function(frame, gCon, uCon)
		frame:SetSize(uCon.width, uCon.height)
	end,

	['raiddebuffs'] = function(frame, gCon, uCon)
		if not frame.RaidDebuffs then return end

		if uCon.raiddebuffs.enable then
			frame.RaidDebuffs:Show()
			frame.RaidDebuffs:SetFrameLevel(50)
			frame.RaidDebuffs:SetSize(uCon.raiddebuffs.size, uCon.raiddebuffs.size)
		else
			frame.RaidDebuffs:Hide()
		end
	end,

	['aurawatch'] = function(frame, gCon, uCon)
		if not frame.AuraWatch then return end

	end,

	['gridindicators'] = function(frame, gCon, uCon)
		if not frame.AuraWatch then return end

		if uCon.gridindicators.enable then
			for _,icon in pairs(frame.AuraWatch.icons) do
				icon:SetSize(uCon.gridindicators.size, uCon.gridindicators.size)
			end
			if not frame.AuraWatch:IsShown() then frame.AuraWatch:Show() end
		else
			if frame.AuraWatch:IsShown() then frame.AuraWatch:Hide() end
		end
	end,

	['buffs'] = function(frame, gCon, uCon)
		if uCon.buffs.enable then
			local point, relPoint, xOff, yOff = unpack(uCon.buffs.point)

			frame.Buffs.disableCooldown = uCon.buffs.disableCooldown
			frame.Buffs.size = uCon.buffs.size
			frame.Buffs.onlyShowPlayer = uCon.buffs.onlyShowPlayer
			frame.Buffs.desaturateNonPlayer = uCon.buffs.desaturateNonPlayer
			frame.Buffs.showStealableBuffs = uCon.buffs.showStealableBuffs
			frame.Buffs.spacing = uCon.buffs.spacing
			frame.Buffs.initialAnchor = uCon.buffs.initialAnchor
			frame.Buffs.num = uCon.buffs.num
			frame.Buffs.perrow = uCon.buffs.perrow
			frame.Buffs['growth-x'] = uCon.buffs.xGrowth
			frame.Buffs['growth-y'] = uCon.buffs.yGrowth

			local rows = ceil(uCon.buffs.num/uCon.buffs.perrow)
			frame.Buffs:SetHeight(rows*uCon.buffs.size + (rows-1)*uCon.buffs.spacing)
			frame.Buffs:SetWidth(uCon.buffs.num*uCon.buffs.size + (uCon.buffs.num-1)*uCon.buffs.spacing)
			frame.Buffs:ClearAllPoints()
			frame.Buffs:SetPoint(point, frame, relPoint, xOff, yOff)
		end

		if uCon.debuffs.enable then
			local point, relPoint, xOff, yOff = unpack(uCon.debuffs.point)

			frame.Debuffs.disableCooldown = uCon.debuffs.disableCooldown
			frame.Debuffs.size = uCon.debuffs.size
			frame.Debuffs.onlyShowPlayer = uCon.debuffs.onlyShowPlayer
			frame.Debuffs.desaturateNonPlayer = uCon.debuffs.desaturateNonPlayer
			frame.Debuffs.showStealableBuffs = uCon.debuffs.showStealableBuffs
			frame.Debuffs.spacing = uCon.debuffs.spacing
			frame.Debuffs.initialAnchor = uCon.debuffs.initialAnchor
			frame.Debuffs.num = uCon.debuffs.num
			frame.Debuffs.perrow = uCon.debuffs.perrow
			frame.Debuffs['growth-x'] = uCon.debuffs.xGrowth
			frame.Debuffs['growth-y'] = uCon.debuffs.yGrowth

			local rows = ceil(uCon.debuffs.num/uCon.debuffs.perrow)
			frame.Debuffs:SetHeight(rows*uCon.debuffs.size + (rows-1)*uCon.debuffs.spacing)
			frame.Debuffs:SetWidth(uCon.debuffs.num*uCon.debuffs.size + (uCon.debuffs.num-1)*uCon.debuffs.spacing)
			frame.Debuffs:ClearAllPoints()
			frame.Debuffs:SetPoint(point, frame, relPoint, xOff, yOff)
		end
	end,

	['portrait'] = function(frame, gCon, uCon)
		assert(frame.Portrait, format('Portrait does not exist for %s.',frame.unit or frame:GetName()))
		
		--Update portrait visibility
		if gCon.portrait.enable and uCon.portrait.enable then
			if not frame.Portrait:IsShown() then frame.Portrait:Show() end

			frame.Portrait:SetInside(frame.Health, 0)
			frame.Portrait:SetPoint('BOTTOM', frame.Health, 'BOTTOM', 0, 1)


			--Update portrait alpha
			if not (frame.Portrait:GetAlpha() == gCon.portrait.alpha) then frame.Portrait:SetAlpha(gCon.portrait.alpha) end

		else
			if frame.Portrait:IsShown() then frame.Portrait:Hide() end
		end
	end,

	['visibility'] = function(frame, gCon, uCon)
		if uCon.enable then
			frame:Enable()
		else
			frame:Disable()
		end
	end,

	['castbar'] = function(frame, gCon, uCon)
		if uCon.castbar.enable then
			frame:EnableElement('Castbar', frame.unit)

			frame.Castbar:ClearAllPoints()

			local point, parent, parentPoint, xOffset, yOffset = unpack(uCon.castbar.point)
			--If no parent specified or if parent doesn't exist, anchor to frame
			if parent == '' or not _G[parent] then parent = frame end

			frame.Castbar:SetPoint(point, parent, parentPoint, xOffset, yOffset)
			frame.Castbar:SetSize(uCon.castbar.width, uCon.castbar.height)

			frame.Castbar.PostCastStart = UF.PostCastStart

			frame.Castbar.backdrop:SetTemplate(uCon.castbar.backdrop.enable and (uCon.castbar.backdrop.transparent and 'T' or '') or 'N')
			frame.Castbar.backdrop:ClearAllPoints()
			frame.Castbar.backdrop:SetPoint('TOPLEFT',     frame.Castbar, 'TOPLEFT', -uCon.castbar.backdrop.insets.left,  uCon.castbar.backdrop.insets.top)
			frame.Castbar.backdrop:SetPoint('BOTTOMRIGHT', frame.Castbar, 'BOTTOMRIGHT',  uCon.castbar.backdrop.insets.right, -uCon.castbar.backdrop.insets.bottom)

		else
			frame:DisableElement('Castbar')

			frame.Castbar.PostCastStart = nil --For some reason this is running on frames that have castbar disabled..
		end
	end,

	['health'] = function(frame, gCon, uCon)
		if uCon.health.enable then
			frame.Health:Show()

			frame.Health:SetOrientation(uCon.health.vertical and 'VERTICAL' or 'HORIZONTAL')
			frame.Health:SetReverseFill(uCon.health.reversefill)

			frame.Health:SetFrameLevel(uCon.health.framelevel)
			
			frame.Health:ClearAllPoints()
			frame.Health:SetPoint(uCon.health.point, frame, uCon.health.point, uCon.health.xoffset, uCon.health.yoffset)
			frame.Health:SetSize(uCon.health.width, uCon.health.height)
			
			-- Toggle health text at full health
			frame.Health.hideFullValue = uCon.health.text.hideFullValue

			--Update bar colors
			frame.Health.colorTapping      = uCon.health.color.Tapping      
			frame.Health.colorDisconnected = uCon.health.color.Disconnected 
			frame.Health.colorSmooth       = uCon.health.color.Smooth       
			frame.Health.colorCustom       = uCon.health.color.Custom       
			frame.Health.colorClass        = uCon.health.color.Class        
			frame.Health.colorReaction     = uCon.health.color.Reaction     

			frame.Health.backdrop:SetTemplate(uCon.health.backdrop.enable and (uCon.health.backdrop.transparent and 'T' or '') or 'N')
			frame.Health.backdrop:ClearAllPoints()
			frame.Health.backdrop:SetPoint('TOPLEFT',     frame.Health, 'TOPLEFT', -uCon.health.backdrop.insets.left,  uCon.health.backdrop.insets.top)
			frame.Health.backdrop:SetPoint('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT',  uCon.health.backdrop.insets.right, -uCon.health.backdrop.insets.bottom)
		else
			frame.Health:Hide()
		end

		--handle text separately, as text can be enabled despite not having the bar enabled
		if uCon.health.text.enable then
			frame.Health.text:Show()
			frame.Health.text:ClearAllPoints()
			frame.Health.text:SetPoint(uCon.health.text.point, frame.Health, uCon.health.text.point, uCon.health.text.xoffset, uCon.health.text.yoffset)
		else
			frame.Health.text:Hide()
		end

		frame.Health:PostUpdate(frame.unit, UnitHealth(frame.unit), UnitHealthMax(frame.unit))
	end,

	['power'] = function(frame, gCon, uCon)
		if uCon.power.enable then
			frame.Power:Show()

			frame.Power:SetOrientation(uCon.power.vertical and 'VERTICAL' or 'HORIZONTAL')
			frame.Power:SetReverseFill(uCon.power.reversefill)

			frame.Power:SetFrameLevel(uCon.power.framelevel)

			frame.Power:ClearAllPoints()
			frame.Power:SetPoint(uCon.power.point, frame, uCon.power.point, uCon.power.xoffset, uCon.power.yoffset)
			frame.Power:SetSize(uCon.power.width, uCon.power.height)

			-- Toggle power text at full power
			frame.Power.hideFullValue = uCon.power.text.hideFullValue

			frame.Power.colorSmooth   = uCon.power.color.Smooth   --false
			frame.Power.colorCustom   = uCon.power.color.Custom   --false
			frame.Power.colorClass    = uCon.power.color.Class    --true
			frame.Power.colorReaction = uCon.power.color.Reaction --true
			frame.Power.colorPower    = uCon.power.color.Power    --false

			frame.Power.backdrop:SetTemplate(uCon.power.backdrop.enable and (uCon.power.backdrop.transparent and 'T' or '') or 'N')
			frame.Power.backdrop:ClearAllPoints()
			frame.Power.backdrop:SetPoint('TOPLEFT',     frame.Power, 'TOPLEFT', -uCon.power.backdrop.insets.left,  uCon.power.backdrop.insets.top)
			frame.Power.backdrop:SetPoint('BOTTOMRIGHT', frame.Power, 'BOTTOMRIGHT',  uCon.power.backdrop.insets.right, -uCon.power.backdrop.insets.bottom)
		else
			frame.Power:Hide()
		end

		--handle text separately, as text can be enabled despite not having the bar enabled
		if uCon.power.text.enable then
			frame.Power.text:Show()
			frame.Power.text:ClearAllPoints()
			frame.Power.text:SetPoint(uCon.power.text.point, frame.Health, uCon.power.text.point, uCon.power.text.xoffset, uCon.power.text.yoffset)
		else
			frame.Power.text:Hide()
		end
		
		frame.Power:PostUpdate(frame.unit, UnitPower(frame.unit), UnitPowerMax(frame.unit))
	end,

	['name'] = function(frame, gCon, uCon)
		--handle text separately, as text can be enabled despite not having the bar enabled
		if uCon.name.enable then
			frame.Name:Show()
			frame.Name:ClearAllPoints()
			frame.Name:SetPoint(uCon.name.point, frame.Health, uCon.name.point, uCon.name.xoffset, uCon.name.yoffset)
			if uCon.name.showlevel then
				frame:Tag(frame.Name, format('[geniuslevel] [name:%d]', uCon.name.maxlength))
			else
				frame:Tag(frame.Name, format('[name:%d]', uCon.name.maxlength))
			end
			frame:UpdateAllElements('PLAYER_TARGET_CHANGED') --force an update to show new tag
		else
			frame.Name:Hide()
		end
	end,

	-- ['fonts'] = function(frame, gCon, uCon)

	-- end,
}

function UF:OnEnable()
	if not S.Saved.profile.UnitFrames.enable then return end

	oUF:RegisterStyle('SaftUI', UF.ConstructUnit)
	oUF:SetActiveStyle('SaftUI')

	self.Units['player'] 		= oUF:Spawn('player' 		,'SaftUI_Player')
	self.Units['target'] 		= oUF:Spawn('target' 		,'SaftUI_Target')
	self.Units['targettarget'] 	= oUF:Spawn('targettarget'	,'SaftUI_TargetTarget')
	self.Units['focus'] 		= oUF:Spawn('focus' 		,'SaftUI_Focus')
	self.Units['focustarget'] 	= oUF:Spawn('focustarget' 	,'SaftUI_FocusFarget')
	self.Units['pet'] 			= oUF:Spawn('pet' 			,'SaftUI_Pet')
	self.Units['pettarget'] 	= oUF:Spawn('pettarget' 	,'SaftUI_PetTarget')

	--Spawn arena frames
	for i = 1, 5 do
		local unit = format('arena%d', i)
		self.Units[unit] = oUF:Spawn(unit, format('SaftUI_Arena%d',i))
	end

	--Spawn boss frames
	for i = 1, 5 do
		local unit = format('boss%d', i)
		self.Units[unit] = oUF:Spawn(unit, format('SaftUI_Boss%d',i))
	end

	-- oUF:RegisterUnitEvent('UNIT_HEALTH','boss1','boss2','boss3','boss4','boss5')
	-- oUF:RegisterUnitEvent('UNIT_POWER','boss1','boss2','boss3','boss4','boss5')
	-- oUF:RegisterUnitEvent('UNIT_NAME_UPDATE','boss1','boss2','boss3','boss4','boss5')

	self:InitializeHeaders()
	self:UpdateAllUnits()	
end

function UF:OnDisable()
	StaticPopup_Show('SAFTUI_CONFIGRELOAD')
end

local RAIDMEMBERS = 25;
local TestRaid = {};
local TestParty = {};
for i=1, 4 do
	TestRaid[i] = {}
	TestRaid[i].class = CLASS_SORT_ORDER[math.floor(math.random()*#CLASS_SORT_ORDER)+1]
	TestRaid[i].name = 'Party'..i
	TestRaid[i].healthmax = math.random(300000)+300000
	TestRaid[i].powermax = TestRaid[i].class == 'ROGUE' or TestRaid[i].class == 'WARRIOR' or TestRaid[i].class == 'DEATHKNIGHT' and 100 or 300000
	TestRaid[i].subgroup = math.floor((i-1)/5)+1

	TestRaid['party'..i] = TestRaid[i]
end
for i=1, RAIDMEMBERS-1 do
	TestRaid[i] = {}
	TestRaid[i].class = CLASS_SORT_ORDER[math.floor(math.random()*#CLASS_SORT_ORDER)+1]
	TestRaid[i].name = 'Raid'..i
	TestRaid[i].healthmax = math.random(300000)+300000
	TestRaid[i].powermax = TestRaid[i].class == 'ROGUE' or TestRaid[i].class == 'WARRIOR' or TestRaid[i].class == 'DEATHKNIGHT' and 100 or 300000
	TestRaid[i].subgroup = math.floor((i-1)/5)+1

	TestRaid['raid'..i] = TestRaid[i]
end

local ORIGINAL_FUNCTIONS = {}
ORIGINAL_FUNCTIONS.UnitClass		 = UnitClass
ORIGINAL_FUNCTIONS.UnitName 		 = UnitName
ORIGINAL_FUNCTIONS.UnitIsUnit		 = UnitIsUnit
ORIGINAL_FUNCTIONS.UnitHealth		 = UnitHealth
ORIGINAL_FUNCTIONS.UnitHealthMax 	 = UnitHealthMax
ORIGINAL_FUNCTIONS.UnitPower 		 = UnitPower
ORIGINAL_FUNCTIONS.UnitPowerMax 	 = UnitPowerMax
ORIGINAL_FUNCTIONS.GetNumRaidMembers = GetNumRaidMembers
ORIGINAL_FUNCTIONS.IsRaidLeader		 = IsRaidLeader
ORIGINAL_FUNCTIONS.IsInRaid		 	 = IsInRaid
ORIGINAL_FUNCTIONS.GetRaidRosterInfo = GetRaidRosterInfo

TEST_FUNCTIONS = {
	UnitClass = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitClass('player')
		elseif TestRaid[unit] then
			return TestRaid[unit].class, TestRaid[unit].class
		else
			return ORIGINAL_FUNCTIONS.UnitClass(unit)
		end
	end,
	
	UnitName = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitName('player')
		elseif TestRaid[unit] then
			return TestRaid[unit].name
		else
			return ORIGINAL_FUNCTIONS.UnitName(unit)
		end
	end,
	
	UnitIsUnit = function(unit1, unit2)
		if (unit1 == 'raid'..RAIDMEMBERS and unit2 == 'player') or (unit2 == 'raid'..RAIDMEMBERS and unit1 == 'player') then
			return true
		else
			return ORIGINAL_FUNCTIONS.UnitIsUnit(unit1, unit2)
		end
	end,
	
	UnitHealth = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitHealth('player')
		elseif TestRaid[unit] then
			return math.random(TestRaid[unit].healthmax)
		else
			return ORIGINAL_FUNCTIONS.UnitHealth(unit)
		end
	end,
	
	UnitHealthMax = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitHealthMax('player')
		elseif TestRaid[unit] then
			return TestRaid[unit].healthmax
		else
			return ORIGINAL_FUNCTIONS.UnitHealthMax(unit)
		end
	end,
	
	UnitPower = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitPower('player')
		elseif TestRaid[unit] then
			return math.random(TestRaid[unit].powermax)
		else
			return ORIGINAL_FUNCTIONS.UnitPower(unit)
		end
	end,
	
	UnitPowerMax = function(unit)
		if unit == 'raid'..RAIDMEMBERS then
			return ORIGINAL_FUNCTIONS.UnitPowerMax('player')
		elseif TestRaid[unit] then
			return TestRaid[unit].powermax
		else
			return ORIGINAL_FUNCTIONS.UnitPowerMax(unit)
		end
	end,
	
	GetNumRaidMembers = function(unit)
		return RAIDMEMBERS
	end,
	
	IsRaidLeader = function(unit)
		return true
	end,

	IsInRaid = function()
		return true
	end,
	
	GetRaidRosterInfo = function(index)
		if index == RAIDMEMBERS then
			return UnitName('player'), 2, (math.floor((RAIDMEMBER-1)/5)+1), MAX_PLAYER_LEVEL, S.myclass, S.myclass, '', true, false, nil, nil
		elseif TestRaid[unit] then
			return TestRaid[unit].name, 0, TestRaid[unit].subgroup, MAX_PLAYER_LEVEL, TestRaid[unit].class, TestRaid[unit].class, '', true, false, nil, nil
		end
	end,
}

local function ToggleTestRaid(enable)
	if enable then 
		UnitClass		  = TEST_FUNCTIONS.UnitClass
		UnitName 		  = TEST_FUNCTIONS.UnitName
		UnitIsUnit		  = TEST_FUNCTIONS.UnitIsUnit
		UnitHealth		  = TEST_FUNCTIONS.UnitHealth
		UnitHealthMax 	  = TEST_FUNCTIONS.UnitHealthMax
		UnitPower 		  = TEST_FUNCTIONS.UnitPower
		UnitPowerMax 	  = TEST_FUNCTIONS.UnitPowerMax
		GetNumRaidMembers = TEST_FUNCTIONS.GetNumRaidMembers
		IsRaidLeader	  = TEST_FUNCTIONS.IsRaidLeader
		GetRaidRosterInfo = TEST_FUNCTIONS.GetRaidRosterInfo
	else
		UnitClass		  = ORIGINAL_FUNCTIONS.UnitClass
		UnitName 		  = ORIGINAL_FUNCTIONS.UnitName
		UnitIsUnit		  = ORIGINAL_FUNCTIONS.UnitIsUnit
		UnitHealth		  = ORIGINAL_FUNCTIONS.UnitHealth
		UnitHealthMax 	  = ORIGINAL_FUNCTIONS.UnitHealthMax
		UnitPower 		  = ORIGINAL_FUNCTIONS.UnitPower
		UnitPowerMax 	  = ORIGINAL_FUNCTIONS.UnitPowerMax
		GetNumRaidMembers = ORIGINAL_FUNCTIONS.GetNumRaidMembers
		IsRaidLeader	  = ORIGINAL_FUNCTIONS.IsRaidLeader
		GetRaidRosterInfo = ORIGINAL_FUNCTIONS.GetRaidRosterInfo
	end
end

-- ToggleTestRaid(true)

function oUF:SetTestMode(enable)
	ToggleTestRaid(enable)
	if enable then
		for unit,frame in pairs(UF.Units) do
			frame.unit = 'player'

			frame._Hide = frame.Hide
			frame.Hide = S.dummy
			frame:Show()

			frame:PLAYER_ENTERING_WORLD('PLAYER_ENTERING_WORLD')
		end
	else
		for unit,frame in pairs(UF.Units) do
			frame.unit = unit

			frame.Hide = frame._Hide
			frame._Hide = nil
			
			UF:UpdateUnit(unit)

			frame:PLAYER_ENTERING_WORLD('PLAYER_ENTERING_WORLD')
		end
	end
end