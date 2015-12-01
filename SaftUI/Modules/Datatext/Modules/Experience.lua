local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local function Update(self, event, ...)
	if UnitLevel('player') ~= MAX_PLAYER_LEVEL then
		local XP, maxXP = UnitXP("player"), UnitXPMax("player")
		local restXP = GetXPExhaustion()
		local percXP = F:Round(XP/maxXP*100)
		if restXP then
			self.Text:SetFormattedText('XP: %s%%|cff00aaff +%s%%|r', percXP, F:Round(restXP/maxXP*100))
		else
			self.Text:SetFormattedText('XP: %s%%', percXP)
		end
	elseif GetWatchedFactionInfo() then
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		self.Text:SetFormattedText("%d/%d (%d%%)", value-minRep, maxRep-minRep, (value-minRep)/(maxRep-minRep)*100)
	else
		self.Text:SetText('-')
	end
end

local function DisplayTooltip(self)
	local isFirst = true

	DT:PositionTooltip(self)

	if UnitLevel('player') ~= MAX_PLAYER_LEVEL then
		local XP, maxXP = UnitXP("player"), UnitXPMax("player")
		local restXP = GetXPExhaustion()
		local percXP = F:Round(XP/maxXP*100)

		if not isFirst then GameTooltip:AddLine() end
		isFirst = false

		GameTooltip:AddLine('Experience')
		GameTooltip:AddDoubleLine('Current XP:', format('%s/%s (%s%%)', XP, maxXP, percXP))
		-- if restXP then GameTooltip:AddDoubleLine('Rested XP:', format('|cff00aaff%d (%s%%)|r'), restXP, F:Round(restXP/maxXP*100)) end
	end

	if GetWatchedFactionInfo() then
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local label = _G['FACTION_STANDING_LABEL'..rank]
		local color = S:GetModule('UnitFrames').Colors.reaction[rank]

		if not isFirst then GameTooltip:AddLine() end
		isFirst = false

		GameTooltip:AddLine('Reputation')
		GameTooltip:AddDoubleLine(format('|cff%s%s|r', F:ToHex(unpack(color)), name), format('|cff%s%s|r', F:ToHex(unpack(color)), label))
		GameTooltip:AddDoubleLine('Current Rep', format("%d/%d (%d%%)", value-minRep, maxRep-minRep, (value-minRep)/(maxRep-minRep)*100))
	end

	GameTooltip:Show()
end

local function Enable(self)
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:RegisterEvent("UPDATE_FACTION")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript('OnEvent', Update)

	self:SetScript('OnEnter', DisplayTooltip)
	self:SetScript('OnLeave', S.HideGameTooltip)

	Update(self)
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
end


DT:RegisterDataModule('Experience', Enable, Disable, Update)