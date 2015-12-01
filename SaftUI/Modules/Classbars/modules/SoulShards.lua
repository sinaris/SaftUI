local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Color = {0.6, 0.4, 0.8}


local function OnEvent(self, event, unit, powerType)
	if event == 'UNIT_POWER' and not (unit == 'player' and powerType == 'SOUL_SHARDS') then return end

	if event == 'PLAYER_TALENT_UPDATE' then
		if GetSpecialization() == SPEC_WARLOCK_AFFLICTION then
			self:Enable()
		else
			return self:Disable()
		end
	end

	self:SetActiveStacks(UnitPower('player', SPELL_POWER_SOUL_SHARDS))
end


local function Trigger(self)
	if S.myclass == 'WARLOCK' then
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		return true
	end
end

local function Enable(self)
	--Force an initial check for Affliction spec
	OnEvent(self, 'PLAYER_TALENT_UPDATE')

	self:SetScript('OnEvent', OnEvent)
	self:RegisterEvent('UNIT_POWER')		
end

local function Disable(self)
	self:UnregisterEvent('UNIT_POWER')
end

CB:RegisterModule('SoulShards', Trigger, Enable, Disable, 'stacks', 4, Color)
