local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

-- Because of the size and similarity of the stat datatexts, I packed them all into one file

-- There's no reason why you would need an Enable and Disable function for each separate stat DT, sothey  use these general ones:

local function Enable(self)
	self.lastUpdate = 0
	self:SetScript('OnUpdate', self.Update)
	self:Update(1)
end

local function Disable(self)
	self:SetScript('OnUpdate', nil)
end

--------------
-- Crit ------
--------------

local function Update(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed; 	
	while (self.lastUpdate > 1) do
		local critchance = S.myclass == 'HUNTER' and GetRangedCritChance() or math.max(GetCritChance(), GetSpellCritChance(1))

		self.Text:SetFormattedText('Crit: %.2f%%', critchance)
		self.lastUpdate = self.lastUpdate - 1;
	end
end

DT:RegisterDataModule('Crit', Enable, Disable, Update)

--------------
-- Regen -----
--------------
local function Update(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed; 	
	while (self.lastUpdate > 1) do
		local base, casting = GetManaRegen();
		local regen = (InCombatLockdown() and casting or base)*5

		self.Text:SetFormattedText('Mp5: %d', regen)
		self.lastUpdate = self.lastUpdate - 1;
	end
end

DT:RegisterDataModule('Regen', Enable, Disable, Update)

--------------
-- Armor -----
--------------
local function Update(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed; 	
	while (self.lastUpdate > 1) do
		self.Text:SetFormattedText('Armor: %d', select(2, UnitArmor("player")))
		self.lastUpdate = self.lastUpdate - 1;
	end
end

DT:RegisterDataModule('Armor', Enable, Disable, Update)