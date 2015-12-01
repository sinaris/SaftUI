local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

local Colors = {
	[1] = {.8, .3, .3},
	[2] = {.8, .8, .3},
	[3] = {.8, .8, .3},
	[4] = {.3, .8, .3},
	[5] = {.3, .8, .3},
}

local function Update(self)
	self:SetActiveStacks(GetComboPoints('player', 'target'))
end

local function Trigger(self)
	return true
end

local function Enable(self)
	self:RegisterEvent('UNIT_COMBO_POINTS')
	self:SetScript('OnEvent', Update)
	Update(self)
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
end

CB:RegisterModule('ComboPoints', Trigger, Enable, Disable, 'stacks', 5, Colors)