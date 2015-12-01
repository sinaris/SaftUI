local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local function Update(self)

		local free, total, used = 0, 0, 0
	
		--Calculate slot status
		for i = 0, NUM_BAG_SLOTS do
			free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
		end
		used = total - free

		--Get color based on how full your bags are
		local color
		local perc = used/total
		if perc > .93 then
			color = {.8, .3, .3}
		elseif perc > .8 then
			color = {.8, .8, .3}
		else
			color = {1, 1, 1}
		end

		self.Text:SetFormattedText('Bags: |cff%s%d/%d|r', F:ToHex(unpack(color)), used, total)
end

local function Enable(self)
	self:RegisterEvent('BAG_UPDATE')
	self:SetScript('OnEvent', Update)
	self:SetScript('OnMouseDown', function() ToggleAllBags() end)
	self:SetAttribute('width', 90)

	self:Update()
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self:SetScript('OnMouseDown', nil)
end

DT:RegisterDataModule('Bags', Enable, Disable, Update)