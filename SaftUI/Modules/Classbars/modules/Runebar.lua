local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Colors = {
	[1] = {.69,.31,.31}, -- blood
	[2] = {.33,.59,.33}, -- unholy
	[3] = {.31,.45,.63}, -- frost
	[4] = {.84,.75,.65}, -- death
}
local fadeMult = 0.6

local function UpdateRuneTimer(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed
	if self.lastUpdate > 0.01 then

		local startTime, duration, runeReady = GetRuneCooldown(self.ID)
		local activeTime = GetTime() - startTime
		local timeLeft = startTime + duration - GetTime()

		if timeLeft <= 0 or runeReady then
			self.Text:SetText('')
			self.StatusBar:SetValue(1)
		else
			self.Text:SetText(F:ToTime(timeLeft))
			self.StatusBar:SetValue((activeTime / duration))
		end

		self.lastUpdate = 0
	end
end

local function UpdateRune(self, event, runeID)
	local start, duration, runeReady = GetRuneCooldown(runeID)
	local runeType = GetRuneType(runeID)
	local r,g,b = unpack(Colors[runeType])

	if event == 'RUNE_POWER_UPDATE' then
		if runeReady then
			self[runeID]:SetScript('OnUpdate', nil)
			self[runeID].Text:SetText('')
			self[runeID].StatusBar:SetValue(1)
		else
			self[runeID].lastUpdate = 0
			self[runeID]:SetScript('OnUpdate', UpdateRuneTimer)
		end
	end

	if runeReady then
		self[runeID].StatusBar:SetStatusBarColor(r,g,b)
	else
		self[runeID].StatusBar:SetStatusBarColor(r*fadeMult, g*fadeMult, b*fadeMult)
	end
end


local function Trigger(self)
	return S.myclass == 'DEATHKNIGHT'
end

local function Enable(self)
	self:RegisterEvent('RUNE_POWER_UPDATE')
	self:RegisterEvent('RUNE_TYPE_UPDATE')
	self:SetScript('OnEvent', UpdateRune)
	for i=1,6 do UpdateRune(self, nil, i) end
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
end

CB:RegisterModule('RuneBar', Trigger, Enable, Disable, 'bars', 6)
