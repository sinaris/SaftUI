local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
-- local LIS = LibStub('LibItemSearch-1.0')

local INV = S:NewModule('Inventory', 'AceHook-3.0', 'AceEvent-3.0')
local LIS = LibStub('LibItemSearch-1.2')

local BACKPACK_IDS = {0, 1, 2, 3, 4}
local BANK_IDS = {-1, 5, 6, 7, 8, 9, 10, 11}
local BAG_TYPES = {
	[0x0008] =   { 1, .8, .3}, --Leatherworking Bag
	[0x0010] =   {.3, .3, .8}, --Inscription Bag
	[0x0020] =   {.3, .8, .3}, --Herb Bag
	[0x0040] =   {.8, .3, .8}, --Enchanting Bag
	[0x0080] =   {.8, .6, .3}, --Engineering Bag
	[0x0200] =   {.3, .6, .8}, --Gem Bag
	[0x0400] =   {.8, .3,  0}, --Mining Bag
	[0x10000] =  {.8, .3, .3}, --Cooking Bag
	[0x100000] = { 0, .8,  1}, --Tackle Box
}

INV.BagSlots = {}
INV.BankSlots = {}
INV.Bags = {}
INV.Bank = {}


------------------------------------------------
-- Slot functions ------------------------------
------------------------------------------------

local function DisplayTooltip(self)
	if not self.bagID and self.slotID then print('bagID: ', bagID or '', 'slotID: ', slotID or '') end
	GameTooltip:SetBagItem(self.bagID, self.slotID)
	GameTooltip:Show()
end

--Create the base for a slot
function INV:CreateBagSlot(bank)
	local slot 
	if bank then
		slot = CreateFrame('Button', 'SaftUI_BankSlot'..(#self.BankSlots+1), self.BankFrame, 'BankItemButtonGenericTemplate')
		slot:SetID(#self.BankSlots+1)
	else
		slot = CreateFrame('Button', 'SaftUI_BagSlot'..(#self.BagSlots+1), self.BagFrame, 'ContainerFrameItemButtonTemplate')
		slot:SetID(#self.BagSlots+1)
	end

	slot.count = _G[slot:GetName() .. "Count"]
	slot.icon = _G[slot:GetName() .. "IconTexture"]
	slot.border = _G[slot:GetName() .. "NormalTexture"]
	slot.cooldown = _G[slot:GetName() .. "Cooldown"]

	self:StyleBagSlot(slot)

	return slot
end

--Update the look of a specific slot, mostly used inside an update loop
function INV:StyleBagSlot(slot)
	local conf = S.Saved.profile.Inventory
	slot:SetSize(conf.slotsize, conf.slotsize)
	slot:SetTemplate('B')

	slot.icon:SetTexCoord(.08, .92, .08, .92)
	slot.icon:SetInside()

	slot.count:SetFontTemplate('pixel')
	slot.count:ClearAllPoints()
	slot.count:SetPoint('BOTTOMRIGHT', 0, 3)

	slot.cooldown:SetAllPoints(slot)

	slot:HookScript('OnEnter', DisplayTooltip)
	slot:HookScript('OnLeave', S.HideGameTooltip)

	slot:SkinActionButton()
	slot:Show()
end

--Assign a slot frame to an actual slot, doing this allows for instant sorting without actually having to pickup items
function INV:AssignSlot(slotNum, bagID, slotID, bank)
	local slot = self[bank and 'BankSlots' or 'BagSlots'][slotNum]

	slot:SetParent(self.Bags[bagID])
	self.Bags[bagID][slotID] = slot

	local texture, count, locked, _, _, _, clink = GetContainerItemInfo(bagID,slotID)
	local name, rarity, ilvl, reqlvl, type, subtype;
	if clink then name, _, rarity, ilvl, reqlvl, type, subtype = GetItemInfo(clink) end

	--Don't update buttons for no reason
	if texture == slot.texture and slot.count == count and slot.rarity == rarity and slot.locked == locked then return end

	slot.slotID = slotID
	slot.bagID = bagID
	slot:SetID(slotID)

	slot.texture = texture
	slot.count = count
	slot.name = name
	slot.rarity = rarity
	slot.locked = locked
	slot.link = clink
	slot.sortString = name and (rarity .. (ilvl or 0) .. name .. type .. subtype .. (count or 0)) or ''

	slot:SetTemplate('B')

	if clink then
		if not slot.locked and slot.rarity and slot.rarity > 1 then
			slot:SetBackdropBorderColor(GetItemQualityColor(slot.rarity))
		end
	else
		slot.name, slot.rarity = nil, nil
	end

	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5)
end

-- Return number of available slots for either bag or bank
function INV:GetNumBagSlots(bank)
	local numSlots = 0
	for _,BagID in pairs(bank and BANK_IDS or BACKPACK_IDS) do
		numSlots = numSlots + GetContainerNumSlots(BagID)
	end
	return numSlots
end

--simple comparison using concatenation of multiple factors into a string
local function compare(a, b)
	return (a.sortString > b.sortString)
end

--Update cooldown spirals on usable items
function INV:UpdateCooldowns()
	for _,bagID in ipairs(BACKPACK_IDS) do
		for slotID=1, GetContainerNumSlots(bagID) do
			local button = INV.Bags[bagID][slotID]
		    if ( GetContainerItemInfo(bagID, slotID) ) then
			    local start, duration, enable = GetContainerItemCooldown(bagID, slotID);
			    CooldownFrame_SetTimer(button.cooldown, start, duration, enable);
			    if ( duration > 0 and enable == 0 ) then
			        SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
			    else
			        SetItemButtonTextureVertexColor(button, 1, 1, 1);
			    end
	        else
	            button.cooldown:Hide()
	        end
	    end
    end
end


------------------------------------------------
-- Bags ----------------------------------------
------------------------------------------------

--Initial setup for inventory
function INV:SetupBags()
	local bags = CreateFrame('frame', 'SaftUI_Bags', UIParent)
	bags:SetTemplate('T')

	--Make sure the bag is always on top of other frames
	bags:SetToplevel(true)

	--Needed for buttontemplates to properly identify items
	for _,bagID in pairs(BACKPACK_IDS) do
		local bag = CreateFrame('Frame', 'SaftUI_Bag'..bagID, bags)
		bag:SetID(bagID)
		self.Bags[bagID] = bag
	end

	bags:Hide()
	bags:EnableMoving()

	self.BagFrame = bags

	self:CreateGoldString()
	self:CreateSearchBar()

	self:UpdateBags()
end

-- Update the amount of slot frames to reflect available slots
function INV:UpdateNumBagSlots()
	for i = #self.BagSlots+1, self:GetNumBagSlots() do
		self.BagSlots[i] = self:CreateBagSlot()
	end
end

--Update the visuals of the bag and sort items
function INV:UpdateBags()
	self:UpdateNumBagSlots()

	local conf = S.Saved.profile.Inventory
	local rows = ceil(self:GetNumBagSlots()/conf.perrow)

	self.BagFrame:SetWidth(conf.slotsize*conf.perrow + conf.slotspacing*(conf.perrow-1) + 20)
	self.BagFrame:SetHeight(conf.slotsize*rows + conf.slotspacing*(rows-1) + 60)

	local i = 1
	for _, bagID in ipairs(BACKPACK_IDS) do
		for slotID=1, GetContainerNumSlots(bagID) do
			self:AssignSlot(i, bagID, slotID)
			i=i+1
		end
	end

	if conf.autosort then
		table.sort(self.BagSlots, compare)
	end

	--Position bag slots
	for slotID,slot in ipairs(self.BagSlots) do
		slot:ClearAllPoints()
		if slotID == 1 then
			slot:SetPoint('TOPLEFT', self.BagFrame, 'TOPLEFT', 10, -10)
		elseif slotID%conf.perrow == 1 then
			slot:SetPoint('TOP', self.BagSlots[slotID-conf.perrow], 'BOTTOM', 0, -conf.slotspacing)
		else
			slot:SetPoint('LEFT', self.BagSlots[slotID-1], 'RIGHT', conf.slotspacing, 0)
		end	
	end

	--Due to contents having shifted, reupdate these calls
	if strlen(self.BagFrame.Search:GetText()) > 0 then
		INV:FilterSearch(self.BagFrame.Search, self.BagFrame.Search:GetText())
	end

	if self.BankFrame and self.BankFrame:IsShown() then
		self:UpdateBank()
	end

	self:UpdateCooldowns()
end
------------------------------------------------
-- Bank ----------------------------------------
------------------------------------------------

--Make sure original bank frame stays out of the way
function INV:DisableBlizzardBank()
	BankFrame:ClearAllPoints()
	BankFrame:SetPoint('BOTTOMRIGHT', UIParent, 'TOPLEFT', -100, 100)
	BankFrame.SetPoint = S.dummy
end

--Initial setup for bank
function INV:SetupBank()
	local bank = CreateFrame('frame', 'SaftUI_Bank', UIParent)
	bank:SetTemplate('T')

	--Make sure the bag is always on top of other frames
	bank:SetToplevel(true)

	--Needed for buttontemplates to properly identify items
	for _,bagID in pairs(BANK_IDS) do
		local bag = CreateFrame('Frame', 'SaftUI_Bag'..bagID, bank)
		bag:SetID(bagID)
		self.Bags[bagID] = bag
	end

	bank:EnableMoving()

	bank:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 5, 5)
	self.BankFrame = bank

	self:DisableBlizzardBank()

	self:UpdateBank()
end

-- Update the amount of slot frames to reflect available slots
function INV:UpdateNumBankSlots()
	for i = #self.BankSlots+1, self:GetNumBagSlots(true) do
		self.BankSlots[i] = self:CreateBagSlot(true)
	end
end

--Update the visuals of the bag and sort items
function INV:UpdateBank()
	self:UpdateNumBankSlots()

	local conf = S.Saved.profile.Inventory
	local rows = ceil(self:GetNumBagSlots(true)/conf.perrow)

	self.BankFrame:SetWidth(conf.slotsize*conf.perrow + conf.slotspacing*(conf.perrow-1) + 20)
	self.BankFrame:SetHeight(conf.slotsize*rows + conf.slotspacing*(rows-1) + 60)

	local i = 1
	for _, bagID in ipairs(BANK_IDS) do
		for slotID=1, GetContainerNumSlots(bagID) do
			self:AssignSlot(i, bagID, slotID, true)
			i=i+1
		end
	end

	if conf.autosort then
		table.sort(self.BankSlots, compare)
	end

	for slotID,slot in ipairs(self.BankSlots) do
		slot:ClearAllPoints()
		if slotID == 1 then
			slot:SetPoint('TOPLEFT', self.BankFrame, 'TOPLEFT', 10, -10)
		elseif slotID%conf.perrow == 1 then
			slot:SetPoint('TOP', self.BankSlots[slotID-conf.perrow], 'BOTTOM', 0, -conf.slotspacing)
		else
			slot:SetPoint('LEFT', self.BankSlots[slotID-1], 'RIGHT', conf.slotspacing, 0)
		end	
	end
end

--Open bank, also initialize bank if it's the first time to be opened this session
function INV:OpenBank()
	--If this is the first time opening bank during this session, run setup
	if not self.BankFrame then self:SetupBank() end

	self.BankFrame:Show()
end

function INV:CloseBank()
	self.BankFrame:Hide()
end

------------------------------------------------
-- Merchant automation -------------------------
------------------------------------------------
--Handles all vendor things such as automatic repairs and vendoring trash items
function INV:HandleMerchant()
	local conf = S.Saved.profile.Inventory
	
	-- Vendor greys and other selected items
	if conf.vendorgreys then
		local profit = 0
		for _,bagID in pairs(BACKPACK_IDS) do
			for slotID=1, GetContainerNumSlots(bagID) do
				local link = GetContainerItemLink(bagID, slotID)
				if link and select(11, GetItemInfo(link)) then
					local _,_,quality,_,_,_,_,_,_,_,price = GetItemInfo(link)
					local count = select(2, GetContainerItemInfo(bagID, slotID))
					local stackPrice = price*count

					if quality == 0 and stackPrice > 0 then
						UseContainerItem(bagID, slotID)
						PickupMerchantItem()

						profit = profit + stackPrice
					end
				end
			end
		end

		if profit > 0 then
			S:print('Total gold gained from vendoring greys: ' .. GetCoinTextureString(profit))
		end
	end

	-- Auto repair gear
	if conf.autorepair and CanMerchantRepair() then
		local repairAllCost, canRepair = GetRepairAllCost()

		if canRepair and CanGuildBankRepair() then
			RepairAllItems(1)
		end

		repairAllCost, canRepair = GetRepairAllCost()

		if canRepair and repairAllCost < GetMoney() then
			RepairAllItems()
			S:print('Repaired all items for ' .. GetCoinTextureString(repairAllCost))
		else
			S:print('Insufficient funds for gear repair.')
		end

	end
end

------------------------------------------------
-- Gold string and tooltip ---------------------
------------------------------------------------
--display all currencies and realm wide gold
function INV:DisplayCurrenciesTooltip()
	GameTooltip:SetOwner(self.BagFrame, "ANCHOR_BOTTOMLEFT", 1, self.BagFrame:GetHeight())
	GameTooltip:ClearLines()
	
	GameTooltip:AddLine('Currencies')

	--List your characters currencies
	for i = 1, GetCurrencyListSize() do
		local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(i)
		if isHeader then
			--stop when you get to the unused header
			if select(4, GetCurrencyListInfo(i+1)) then break end

			GameTooltip:AddLine(name)
		elseif count > 0 and not isUnused then
			GameTooltip:AddDoubleLine(name, count, 1,1,1, 1,1,1)
		end
	end

	GameTooltip:AddLine(' ')
	GameTooltip:AddLine('Account Gold')
	
	--List server wide gold
	local totalGold = 0
	for toonName, gold in pairs(S.Saved.realm.gold) do 
		GameTooltip:AddDoubleLine(toonName, F:GoldFormat(gold), 1,1,1)
		totalGold = totalGold + gold
	end
	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine('Total', F:GoldFormat(totalGold))

	GameTooltip:Show()
end

function INV:CreateGoldString()
	local goldstring = CreateFrame('frame', nil, self.BagFrame)

	goldstring:EnableMouse(true)
	goldstring:SetPoint('BOTTOMRIGHT', self.BagFrame, 'BOTTOMRIGHT', -10, 10)
	goldstring:SetPoint('BOTTOMLEFT', self.BagFrame, 'BOTTOM', 0, 10)
	goldstring:SetHeight(30)
	goldstring:SetWidth(1)

	local coppericon = '|T'..S.TEXTURE_PATHS.goldstring .. ':8:16:0:0:16:32:0:16:00:08|t'
	local silvericon = '|T'..S.TEXTURE_PATHS.goldstring .. ':8:16:0:0:16:32:0:16:12:20|t'
	local goldicon   = '|T'..S.TEXTURE_PATHS.goldstring .. ':8:16:0:0:16:32:0:16:24:32|t'
	goldstring.FormatString = '%d' .. goldicon .. '%d' .. silvericon .. '%d' .. coppericon

	goldstring.text = S.CreateFontString(goldstring, 'pixel')
	goldstring.text:SetPoint('RIGHT', goldstring, 'RIGHT', -5, 0)

	goldstring:SetScript('OnEnter', function() INV:DisplayCurrenciesTooltip() end)
	goldstring:SetScript('OnLeave', S.HideGameTooltip)

	self.BagFrame.GoldString = goldstring
	self:UpdateGoldString()
end

function INV:UpdateGoldString()
	local money = GetMoney()
	local gold = floor(abs(money / 10000))
	local silver = floor(abs(mod(money / 100, 100)))
	local copper = floor(abs(mod(money, 100)))

	S.Saved.realm.gold[S.myname] = money

	self.BagFrame.GoldString.text:SetFormattedText(self.BagFrame.GoldString.FormatString, gold, silver, copper)
end

function INV:CreateSearchBar()
	local search = S.CreateEditBox('SaftUI_BagsSearch', self.BagFrame)
	search:SetBackdropColor(0, 0, 0, 0)
	search:SetBackdropBorderColor(0, 0, 0, 0)

	search:SetHeight(30)
	search:SetPoint('BOTTOMLEFT', self.BagFrame, 'BOTTOMLEFT', 10, 10)
	search:SetPoint('BOTTOMRIGHT', self.BagFrame, 'BOTTOM', 0, 20)
	search:SetScript('OnTextChanged', function(self, userInput) INV:FilterSearch(self, userInput) end)
	search:HookScript('OnEscapePressed', function(self, userInput) INV:ResetSearch(self) end)
	search:HookScript('OnEditFocusGained', function(self) self:SetBackdropColor(0,0,0,.2); self:SetBackdropBorderColor(0,0,0,.2) end)
	search:HookScript('OnEditFocusLost', function(self) self:SetBackdropColor(0,0,0,0); self:SetBackdropBorderColor(0,0,0,0) end)
	search:SetTextInsets(27, 5, 0, 0)
	search.icon = search:CreateTexture(nil, 'OVERLAY')
	search.icon:SetSize(16, 16)
	search.icon:SetTexture(S.TEXTURE_PATHS.search)
	search.icon:SetPoint('LEFT', search, 'LEFT', 5, 0)
	search.icon:SetVertexColor(.6, .7,.85, .7)

	self.BagFrame.Search = search
end


------------------------------------------------
-- Search functions ----------------------------
------------------------------------------------

function INV:GetQueryMatched(slot, query)
	name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(GetContainerItemLink(slot.bagID,slot:GetID()))
	if not query then return false end

	for q, t in pairs(QUERY_TRANSLATIONS) do query = query:gsub(q, t) end
	query = strlower(query)

	if name and strfind(strlower(name), query) then return true end
	
	--loadstring creates a function formatted with the items itemLevel, and the operand and number found within the query, and returns the inequality
	local operand, number = strmatch(query:gsub(' ',''), '(=?<?>?=?)(%d+)')
	if iLevel and (operand and strlen(operand) > 0) and number then 
		if operand == '=' then operand = '==' end
		if operand == '=>' then operand = '>=' end
		if operand == '=<' then operand = '<=' end
		if loadstring(format("return %d %s %d", iLevel, operand, number))() then return true end
	end

	if strfind(query, strlower(class)) or strfind(query, strlower(subclass)) then return true end

	return false
end

function INV:ResetSearch(editbox)
	editbox:SetText('')
	for i,slot in pairs(INV.BagSlots) do
		slot:SetAlpha(1)
	end
end

function INV:FilterSearch(editbox, userInput)
	if not userInput then return end
	local query = editbox:GetText()
	local empty = strlen(query:gsub(' ', '')) == 0

	for i,slot in pairs(INV.BagSlots) do
		if empty or LIS:Matches(slot.link, query) then
			slot:SetAlpha(1)
		else
			slot:SetAlpha(.3)

		end
	end
	if INV.BankFrame and INV.BankFrame:IsShown() then
		for i,slot in pairs(INV.BankSlots) do
			if empty or LIS:Matches(slot.link, query) then
				slot:SetAlpha(1)
			else
				slot:SetAlpha(.3)

			end
		end
	end
end

------------------------------------------------
-- Initialization ------------------------------
------------------------------------------------
function INV:ToggleBags() ToggleFrame(INV.BagFrame) end
function INV:ShowBags() INV.BagFrame:Show() end
function INV:HideBags() INV.BagFrame:Hide() end

function INV:OnEnable()
	self:SetupBags()

	--Overwrite all blizzard bag functions
	ToggleBackpack		= INV.ToggleBags
	ToggleBag 			= INV.ToggleBags
	ToggleAllBags 		= INV.ToggleBags
	OpenAllBags 		= INV.ShowBags
	OpenBackpack 		= INV.ShowBags
	CloseAllBags 		= INV.HideBags
	CloseBackpack 		= INV.HideBags

	--Temp default position
	self.BagFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -5, 5)

	--Bag events
	self:RegisterEvent('BAG_UPDATE', 'UpdateBags')
	self:RegisterEvent('ITEM_LOCK_CHANGED', 'UpdateBags')
	self:RegisterEvent('ITEM_UNLOCKED', 'UpdateBags')

	--Bank events
	self:RegisterEvent('BANKFRAME_OPENED', 'OpenBank')
	self:RegisterEvent('BANKFRAME_CLOSED', 'CloseBank')
	-- self:RegisterEvent('PLAYERBANKSLOTS_CHANGED', 'UpdateBank')

	--Misc events
	self:RegisterEvent('PLAYER_MONEY', 'UpdateGoldString')
	self:RegisterEvent('MERCHANT_SHOW', 'HandleMerchant')
	self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateCooldowns')

	hooksecurefunc('ContainerFrameItemButton_OnEnter', function() GameTooltip:SetOwner(self.BagFrame, "ANCHOR_BOTTOMLEFT", 1, self.BagFrame:GetHeight()) end)
end