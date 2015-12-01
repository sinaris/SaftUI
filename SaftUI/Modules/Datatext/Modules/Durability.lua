local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local slots = { 
	["SecondaryHandSlot"] = -1, 
	["MainHandSlot"] = -1, 
	["FeetSlot"] = -1, 
	["LegsSlot"] = -1, 
	["HandsSlot"] = -1, 
	["WristSlot"] = -1, 
	["WaistSlot"] = -1, 
	["ChestSlot"] = -1, 
	["ShoulderSlot"] = -1, 
	["HeadSlot"] = -1,
}

local function UpdateTooltip(self)
	DT:PositionTooltip(self)

	for slot,dura in pairs(slots) do 
		if dura > 0 then
			GameTooltip:AddDoubleLine(_G[strupper(slot)], format('%d%%', dura*100), 1,1,1, 1,1,1)
		end
	end
	GameTooltip:Show()
end

local function Update(self)
	local totalDurability = 0
	local maxDurability = 0

	for slot,_ in pairs(slots) do 
		local slotID = GetInventorySlotInfo(slot)
		local current, max = GetInventoryItemDurability(slotID)
		if current then
			slots[slot] = current/max

			totalDurability = totalDurability + current
			maxDurability = maxDurability + max
		end
	end

	if maxDurability > 0 then --Can't divide by zero :x
		self.Text:SetFormattedText('Durability: %d%%', floor((totalDurability/maxDurability)*100)+.5)
	else
		self.Text:SetText('Durability: 100%')
	end
end

local function Enable(self)
	self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
	self:SetScript('OnEvent', Update)
	self:SetScript('OnEnter', UpdateTooltip)
	self:SetScript('OnLeave', function() GameTooltip:Hide() end)
	self:SetScript('OnMouseDown', function() ToggleFrame(CharacterFrame) end)
	self:Update()
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self:SetScript('OnEnter', nil)
	self:SetScript('OnLeave', nil)
	self:SetScript('OnMouseDown', nil)
end

DT:RegisterDataModule('Durability', Enable, Disable, Update)