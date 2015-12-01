local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local MB = S:NewModule('Mailbox', 'AceHook-3.0', 'AceEvent-3.0')



function MB:LootAllItems()
	local numItems, totalItems = GetInboxNumItems();
	for index = 1, numItems do
		packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity = GetInboxHeaderInfo(index);
		if itemCount and itemCount > 0 then
			AutoLootMailItem(index)
		end
	end
	-- for i=1, INBOXITEMS_TO_DISPLAY do
	-- 	if ( index <= numItems ) then
	-- 		-- Setup mail item
	-- 		packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity = GetInboxHeaderInfo(index);
	-- 		if itemCount > 0 then
	-- 			AutoLootMailItem(index)
	-- 		end
	-- 	end
	-- end
end

function MB:CollectAllMoney()

end

function MB:SkinMailbox()
	local height = S:GetModule('Skinning').UI_PANEL_HEIGHT
	local width = MailFrame:GetWidth()

	local itemheight = 40

	MailFrame:SetTemplate('KTS')
	MailFrameInset:StripTextures()
	MailFrame:SetHeight(height)

	InboxFrame:StripTextures()

	MailFrameCloseButton:SkinCloseButton()
	MailFrameCloseButton:ClearAllPoints()
	MailFrameCloseButton:SetPoint('TOPRIGHT', -6, -6)

	InboxPrevPageButton:SkinButton(nil, '<')
	InboxNextPageButton:SkinButton(nil, '>')

	local prevItem
	for i=1, INBOXITEMS_TO_DISPLAY do
		local name = "MailItem"..i
		local item = _G[name]
		local button = _G[name.."Button"]
		local icon = _G[name.."ButtonIcon"]
		local slot = _G[name.."ButtonSlot"]

		item:SetHeight(itemheight)

		item:SetWidth(MailFrame:GetWidth()-12)
		item:StripTextures()
		item:CreateBackdrop()
		item.backdrop:SetInside(0)
		item.backdrop:SetPoint('LEFT', itemheight+4, 0)

		button:SkinActionButton()
		button:SetSize(itemheight, itemheight)
		button:SetPoint('TOPLEFT', item)
		icon:TrimIcon()
		icon:SetInside(button)

		slot:TrimIcon()
		slot:SetInside(button)

		item:ClearAllPoints()
		if prevItem then
			item:SetPoint('TOPLEFT', prevItem, 'BOTTOMLEFT', 0, -6)
		else
			item:SetPoint('TOPLEFT', 6, -40)			
		end

		prevItem = item
	end

end

function MB:OnEnable()
	self:SkinMailbox()

	local LootItemsButton = S.CreateButton(nil, InboxFrame, 'Loot Items')
	LootItemsButton:SetPoint('BOTTOMRIGHT', MailFrameInset, 'BOTTOM', -2, 10)
	LootItemsButton:SetSize(80, 20)
	self:HookScript(LootItemsButton, 'OnClick', 'LootAllItems')
	self.LootItemsButton = LootItemsButton

	local CollectMoneyButton = S.CreateButton(nil, InboxFrame, 'Loot Gold')
	CollectMoneyButton:SetPoint('BOTTOMLEFT', MailFrameInset, 'BOTTOM', 2, 10)
	CollectMoneyButton:SetSize(80, 20)
	self:HookScript(CollectMoneyButton, 'OnClick', 'CollectAllMoney')
	self.CollectMoneyButton = CollectMoneyButton
end