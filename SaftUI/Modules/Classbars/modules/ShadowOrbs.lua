local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Color = {0.6, 0.4, 0.8}


local function OnEvent(self, event, unit, powerType)
	if event == 'UNIT_POWER' and not (unit == 'player' and powerType == 'SHADOW_ORBS') then return end

	if event == 'PLAYER_TALENT_UPDATE' then
		if GetSpecialization() == SPEC_PRIEST_SHADOW then
			self:Enable()
		else
			return self:Disable()
		end
	end

	self:SetActiveStacks(UnitPower('player', SPELL_POWER_SHADOW_ORBS))
end


local function Trigger(self)
	if S.myclass == 'PRIEST' then
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		return true
	end
end

local function Enable(self)
	--Force an initial check for Shadow spec
	OnEvent(self, 'PLAYER_TALENT_UPDATE')

	self:SetScript('OnEvent', OnEvent)
	self:RegisterEvent('UNIT_POWER')		
end

local function Disable(self)
	self:UnregisterEvent('UNIT_POWER')
end

CB:RegisterModule('ShadowOrbs', Trigger, Enable, Disable, 'stacks', 3, Color)
