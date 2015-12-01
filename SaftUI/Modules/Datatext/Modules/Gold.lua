local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local function Update(self)
	self.Text:SetText(F:GoldFormat(GetMoney(), true))

	S.Saved.realm.gold[S.myname] = GetMoney()
end

local function UpdateTooltip(self)
	DT:PositionTooltip(self)
	local totalGold = 0
	for toonName, gold in pairs(S.Saved.realm.gold) do 
		GameTooltip:AddDoubleLine(toonName, F:GoldFormat(gold), 1,1,1, 1,1,1)
		totalGold = totalGold + gold
	end
	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine('Total', F:GoldFormat(totalGold))
	GameTooltip:Show()
end



local function Enable(self)
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript('OnEvent', Update)
	self:SetScript('OnMouseDown', ToggleAllBags)
	self:SetScript('OnEnter', UpdateTooltip)
	self:SetScript('OnLeave', function() GameTooltip:Hide() end)
	self:SetAttribute('width', 80)

	self:Update()
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self:SetScript('OnMouseDown', nil)
end


DT:RegisterDataModule('Gold', Enable, Disable, Update)