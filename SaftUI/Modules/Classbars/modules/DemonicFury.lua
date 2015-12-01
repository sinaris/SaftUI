local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Color = {0.6, 0.4, 0.8}


local function OnEvent(self, event, unit, powerType)
	if event == 'UNIT_POWER' and not (unit == 'player' and powerType == 'DEMONIC_FURY') then return end

	if event == 'PLAYER_TALENT_UPDATE' then
		if GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY then
			self:Enable()
		else
			return self:Disable()
		end
	end

	local min, max = UnitPower('player', SPELL_POWER_DEMONIC_FURY), UnitPowerMax('player', SPELL_POWER_DEMONIC_FURY)
	self[1].StatusBar:SetValue(min/max)
	self[1].Text:SetText(min)
end

local function Trigger(self)
	if S.myclass == 'WARLOCK' then
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		return true
	end
end

local function Enable(self)
	--Force an initial check for Demonology spec
	OnEvent(self, 'PLAYER_TALENT_UPDATE')

	self:RegisterEvent('UNIT_POWER')
	self:SetScript('OnEvent', OnEvent)		
end

local function Disable(self)
	self:UnregisterEvent('UNIT_POWER')
end

CB:RegisterModule('DemonicFury', Trigger, Enable, Disable, 'bars', 1, Color)
