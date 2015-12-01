local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local function UpdateTimePlayed()
	S.Saved.global.time[S.myname] = RequestTimePlayed()
end

local function UpdateTooltip(self)
	DT:PositionTooltip(self)	

	GameTooltip:AddLine("World Boss(s)")
	for boss, completed in pairs({
		['Sha of Anger'] = IsQuestFlaggedCompleted(32099) or false,
		['Galleon'] 	 = IsQuestFlaggedCompleted(32098) or false,
		['Oondasta']	 = IsQuestFlaggedCompleted(32519) or false,
		['Nalak']		 = IsQuestFlaggedCompleted(32518) or false,
	}) do
		GameTooltip:AddDoubleLine(boss, completed and 'Defeated' or 'Undefeated', 1, 1, 1, 1, 1, 1)
	end
	
	if IsShiftKeyDown() then
		UpdateTimePlayed()
		local total = 0
		for toon,time in pairs(S.Saved.global.time) do
			total = total + time
		end
		GameTooltip:AddLine('Time Played')
		GameTooltip:AddDoubleLine(S.myname, S.Saved.global.time[S.myname])
		GameTooltip:AddDoubleLine('Total', total)
	end

	GameTooltip:Show()
end

local function Update(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed; 	
	while (self.lastUpdate > 1) do
		local hr, min = GetGameTime()
		local meridiem = TIMEMANAGER_AM
		
		if hr > 12 then
			hr = hr - 12
			meridiem = TIMEMANAGER_PM
		elseif hr == 0 then
			hr = 12
		end
		
		local color = CalendarGetNumPendingInvites() > 0 and F:ToHex(.8, .3, .3) or 'ffffff'

		self.Text:SetFormattedText('|cff%s%d:%02d %s|r', color, hr, min, meridiem)
		
		self.lastUpdate = self.lastUpdate - 1;
	end
end

local function Enable(self)
	self.lastUpdate = 0
	self:SetScript('OnEnter', UpdateTooltip)
	self:SetScript('OnLeave', S.HideGameTooltip)
	self:SetScript('OnUpdate', Update)
	self:SetScript('OnMouseDown', function() GameTimeFrame:Click() end)
	self:Update(1)
	self:SetAttribute('width', 55)
	self:RegisterEvent('PLAYER_LOGOUT')
	self:RegisterEvent('PLAYER_LOGIN')
	
	if not S.Saved.global.time then S.Saved.global.time = {} end

	self:SetScript('OnEvent', function(self, event, ...)
		UpdateTimePlayed()
	end)
end

local function Disable(self)
	self:SetScript('OnUpdate', nil)
	self:SetScript('OnEnter', nil)
	self:SetScript('OnLeave', nil)
end

DT:RegisterDataModule('Time', Enable, Disable, Update)