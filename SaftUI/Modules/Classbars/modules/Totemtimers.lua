local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime

local Colors = {
	[1] = {0.8, 0.3, 0.0},
	[2] = {1.0, 0.8, 0.0},		
	[3] = {0.0, 0.4, 0.8},
	[4] = {0.6, 1.0, 1.0},
}

local function UpdateTimer(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed
	if self.lastUpdate > 0.01 then
		local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(self.ID)
		local activeTime = GetTime() - startTime
		local timeLeft = startTime + duration - GetTime()

		if timeLeft > 0 then
			self.Text:SetText(F:ToTime(timeLeft))
			self.StatusBar:SetValue(1 - (activeTime / duration))
		else
			self.Text:SetText('')
			self.StatusBar:SetValue(0)
		end

		self.lastUpdate = 0
	end
end

local function UpdateSlot(self, slot)
	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
	if haveTotem and duration >= 0 then
		self[slot].lastUpdate = 0
		UpdateTimer(self[slot], 1)
		self[slot]:SetScript('OnUpdate', UpdateTimer)
	else
		self[slot]:SetScript('OnUpdate', nil)
		self[slot].Text:SetText('')
		self[slot].StatusBar:SetValue(0)
	end
end

local function Trigger(self)
	return S.myclass == 'SHAMAN'
end

local function Enable(self)
	self:RegisterEvent('PLAYER_TOTEM_UPDATE')
	for i=1,4 do UpdateSlot(self, i) end
	self:SetScript('OnEvent', function(self, event, slot) UpdateSlot(self, slot) end)
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
end

CB:RegisterModule('TotemTimers', Trigger, Enable, Disable, 'bars', 4, Colors)
