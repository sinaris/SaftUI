local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local UF = S:GetModule('UnitFrames')
local oUF = UF.oUF

local function HideRaid()
	local isShown = CompactRaidFrameManager_GetSetting("IsShown")
	if isShown and isShown ~= 0 then
		CompactRaidFrameManager_SetSetting('IsShown', '0')
	end
end

function UF:KillBlizzardRaid()
	HideRaid()
	CompactRaidFrameManager:HookScript('OnShow', HideRaid)
	hooksecurefunc('CompactRaidFrameManager_UpdateShown', HideRaid)
	CompactRaidFrameManager:UnregisterAllEvents();
	CompactRaidFrameManager:Hide();
	hooksecurefunc("CompactUnitFrame_RegisterEvents", CompactUnitFrame_UnregisterEvents)
end

function UF:GetHeaderUnits(header)
	local units = {}
	for i,frame in pairs({header:GetChildren()}) do
		--make sure only valid unitframes get through
		if frame.unit and frame:GetName() then
			units[frame.unit] = frame
		end
	end
	return units
end

-- Since headers are a bit more complex, if UpdateUnit is given a header
-- to update, such as raid, it passes it on to this function
function UF:UpdateGroupHeader(headerName, moduleName, ...)
	if not self.GroupHeaders then return end
	
	local gCon = S.Saved.profile.UnitFrames
	local uCon = gCon.Units[headerName]
	local header = self.GroupHeaders[headerName]
	assert(header, format('Header \'%s\' does not exist', headerName))

	-- All code that requies you to be out of combat goes below here
	if InCombatLockdown() then return end

	for _,frame in pairs(UF:GetHeaderUnits(header)) do
		UF:UpdateUnit(frame, moduleName, ...)
	end

	header:ClearAllPoints()
	header:SetPoint(unpack(uCon.point))	
	
	self:SetRaidHeaderVisibility()

	--[[
		update specific attributes
		such as max groups
	]]
end


function UF.SetRaidHeaderVisibility(self)
	if InCombatLockdown() then return end
	local raid = UF.GroupHeaders.raid
	--Is there another way to disable a group header..?
	if not S.Saved.profile.UnitFrames.Units.raid.enable then
		raid:SetAttribute('groupFilter', '')
		return
	end

	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if maxPlayers == 25 then
		raid:SetAttribute('groupFilter', '1,2,3,4,5')
	elseif maxPlayers == 10 then
		raid:SetAttribute('groupFilter', '1,2')
	else
		raid:SetAttribute('groupFilter', '1,2,3,4,5,6,7,8')
	end
end

function UF:InitializeHeaders()
	self:KillBlizzardRaid()
	self.GroupHeaders = {}

	local offset = S.borderinset + 2
	
	self.GroupHeaders['raid'] = oUF:SpawnHeader('SaftUI_UnitFrames_RaidHeader', nil, 'solo,party,raid',
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", S.Saved.profile.UnitFrames.Units.raid.width,
		"initial-height", S.Saved.profile.UnitFrames.Units.raid.height,
		"showSolo", false,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"xOffset", offset,
		"yOffset", offset,
		"point", "LEFT",
		"groupFilter", "1,2,3,4,5",
		"groupingOrder", "1,2,3,4,5",
		"groupBy", "GROUP",
		"maxColumns", 40,
		"unitsPerColumn", 1,
		"columnSpacing", offset,
		"columnAnchorPoint", "TOP"
	)

	self.GroupHeaders.raid:CreateBackdrop('T')
	self.GroupHeaders.raid.backdrop:ClearAllPoints()
	self.GroupHeaders.raid.backdrop:SetPoint('TOPLEFT', -6, 6)
	self.GroupHeaders.raid.backdrop:SetPoint('BOTTOMRIGHT', 6, -6)

	self:UpdateGroupHeader('raid')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', UF.SetRaidHeaderVisibility)
end