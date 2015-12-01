local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')
local Colors = {
	[1] = {0,.3,1},
	[2] = {0,.4,1},
	[3] = {0,.5,1},
	[4] = {0,.6,1},
	[5] = {0,.7,1},
	[6] = {0,.8,1},
}

local function OnEvent(self, event, ...)
	if event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_LEVEL_UP' then
		if IsSpellKnown(88766) then
			self:Enable()
		else
			return self:Disable()
		end
	end
	local stacks = select(4, UnitBuff('player', 'Lightning Shield')) or 0
	self:SetActiveStacks(stacks-1)
end

local function Trigger(self)
	if S.myclass == 'SHAMAN' then
		self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		self:RegisterEvent('PLAYER_LEVEL_UP')

		return true
	end
end

local function Enable(self)
	--Force an initial check for Fulmination
	OnEvent(self, 'ACTIVE_TALENT_GROUP_CHANGED')

	self:RegisterEvent('UNIT_AURA')
	self:SetScript('OnEvent', OnEvent)
end

local function Disable(self)
	self:UnregisterEvent('UNIT_AURA')
end

CB:RegisterModule('Fulmination', Trigger, Enable, Disable, 'stacks', 6, Colors)
