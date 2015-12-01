local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Color = {1.0, 0.4, 0.2}


local function OnEvent(self, event, unit, powerType)
	if event == 'UNIT_POWER' and not (unit == 'player' and powerType == 'BURNING_EMBERS') then return end

	if event == 'PLAYER_TALENT_UPDATE' then
		if GetSpecialization() == SPEC_WARLOCK_DESTRUCTION then
			self:Enable()
		else
			return self:Disable()
		end
	end

	local power = UnitPower('player', SPELL_POWER_BURNING_EMBERS, true)
	local stacks = (power / self.maxPower) * self.maxStacks 

	for i=1, self.maxStacks do
		if stacks >= 1 then
			self[i].StatusBar:SetValue(1)
			stacks = stacks - 1
			self[i].Text:SetText('')
		elseif stacks == 0 then
			self[i].Text:SetText('')
			self[i].StatusBar:SetValue(0)
		else
			self[i].StatusBar:SetValue(stacks)

			self[i].Text:SetText(stacks*10)
			stacks = 0
		end
	end
end


local function Trigger(self)
	if S.myclass == 'WARLOCK' then
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		return true
	end
end

local function Enable(self)
	self.maxStacks = UnitPowerMax('player', SPELL_POWER_BURNING_EMBERS)
	self.maxPower = UnitPowerMax('player', SPELL_POWER_BURNING_EMBERS, true)

	--Force an initial check for Destruction spec
	OnEvent(self, 'PLAYER_TALENT_UPDATE')

	self:SetScript('OnEvent', OnEvent)
	self:RegisterEvent('UNIT_POWER')		
end

local function Disable(self)
	self:UnregisterEvent('UNIT_POWER')
end

CB:RegisterModule('BurningEmbers', Trigger, Enable, Disable, 'bars', 4, Color)
