local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Color = {1.0, 0.8, 0.4}

local function Update(self, event, unit, powerType)
	if (unit == 'player' and powerType and powerType == 'CHI') then
		local maxStacks = UnitPowerMax('player', SPELL_POWER_CHI)

		if maxStacks ~= self.ShownUnits then
			self:SetMaxUnits(maxStacks)
		end
		
		self:SetActiveStacks(UnitPower('player', SPELL_POWER_CHI))
	end
end

local function Trigger(self)
	return S.myclass == 'MONK'
end

local function Enable(self)
	self:RegisterEvent('UNIT_POWER')
	self:SetScript('OnEvent', Update)
	Update(self, 'UNIT_POWER', 'player', 'CHI')
end

local function Disable(self)
	self:UnregisterEvent('UNIT_POWER')
	self:SetScript('OnEvent', nil)
end

CB:RegisterModule('Chi', Trigger, Enable, Disable, 'stacks', 3, Color)