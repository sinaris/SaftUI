local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DEV = S:NewModule('Development', 'AceHook-3.0')


function DEV:OnInitialize()
	ExtraActionBarFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 100)

	DEV:SecureHook('EquipmentFlyout_UpdateItems', function()

		local flyout = EquipmentFlyoutFrame;
		local buttons = flyout.buttons;
		local buttonAnchor = flyout.buttonFrame;
		local itemButton = flyout.button;
		local id = itemButton.id or itemButton:GetID();	
		local flyoutSettings = itemButton:GetParent().flyoutSettings;

		local flyoutHeight = itemButton:GetHeight()

		flyout:SetAllPoints(itemButton)
		flyout:StripTextures()
		buttonAnchor:ClearAllPoints()
		buttonAnchor:SetPoint('TOPLEFT', flyout, 'TOPRIGHT', 4, 0)

		-- local totalItems = flyout.totalItems;
		-- local currentPage = flyout.currentPage or 1;
		local padding = S.borderinset*2+1
		local btnSize = flyoutHeight-padding*2
		local numShownButtons = 0
		local numrows = 1

		for i,button in ipairs(buttons) do
			if button:IsShown() then
				numShownButtons = numShownButtons + 1
				button:SetSize(btnSize, btnSize)
				button:ClearAllPoints()
				
				if i == 1 then
					button:SetPoint('TOPLEFT', buttonAnchor, 'TOPLEFT', padding, -padding)
				elseif i % (EQUIPMENTFLYOUT_ITEMS_PER_ROW) == 1 then
					button:SetPoint('TOP', buttons[i-EQUIPMENTFLYOUT_ITEMS_PER_ROW], 'BOTTOM', 0, -padding)
					numrows = numrows + 1
				else
					button:SetPoint('LEFT',	buttons[i-1], 'RIGHT', padding, 0)
				end
			end
		end

		--if more than one row
		if numrows > 1 then
			buttonAnchor:SetHeight(flyoutHeight*numrows - padding*(numrows-1))
			buttonAnchor:SetWidth((EQUIPMENTFLYOUT_ITEMS_PER_ROW+1)*padding + EQUIPMENTFLYOUT_ITEMS_PER_ROW*btnSize)
		else --single row
			buttonAnchor:SetHeight(flyoutHeight)
			buttonAnchor:SetWidth((numShownButtons+1)*padding + numShownButtons*btnSize)
		end

		EquipmentFlyoutFrameButtons:SetTemplate()
	end)

	DEV:SecureHook('EquipmentFlyout_CreateButton', function()
		local buttons = EquipmentFlyoutFrame.buttons
		local button = buttons[#buttons]
		button:SkinActionButton()
		button:SetSize(34,34)
	end)
end

local autoDecline = CreateFrame('frame', nil, UIParent)
autoDecline:RegisterEvent("PLAYER_ENTERING_WORLD")
autoDecline:RegisterEvent("BN_FRIEND_INVITE_ADDED")
autoDecline:SetScript('OnEvent', function(self, event, ...)

	local i = 1
	while i <= BNGetNumFriendInvites() do
		inviteID, givenName, surname, message, timeSent, days = BNGetFriendInviteInfo(i)
		local isSpam = false
		local siteURL = strmatch(message or '', "www%.([_A-Za-z0-9-]+)%.(%S+)%s?")
		if siteURL then isSpam = true end

		if isSpam then
			S:print('BNet invite from|cffffaaaa', givenName, '|rdeclined due to spam detection ('..siteURL..').')
			BNDeclineFriendInvite(inviteID)
		else
			i = i + 1
		end

	end
end)

--------------------------------------------
-- AUCTION QUICK BUY -----------------------
--------------------------------------------

--300G, 00S, 00C
BUYOUT_LIMIT = 3000000

local function OnClick(self, button)
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	local ID = self:GetID()

	local name, texture, count, quality, canUse, level, minBid, minIncrement, _, buyoutPrice, highBidder, owner, saleStatus = GetAuctionItemInfo("list", offset + ID);

	SetSelectedAuctionItem("list", ID + offset)

	if IsShiftKeyDown() and buyoutPrice <= BUYOUT_LIMIT then
		PlaceAuctionBid("list", offset + ID, buyoutPrice);
	end
end

local function QuickBuy_Initialize()
	for i=1, NUM_BROWSE_TO_DISPLAY do
		_G["BrowseButton"..i]:HookScript('OnClick', OnClick)
	end
end

local frame  = CreateFrame('frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, addon)
	if addon == 'Blizzard_AuctionUI' then
		QuickBuy_Initialize()
	end
end)

--------------------------------------------
-- SHIFT QUICK QUEST ABANDON ---------------
--------------------------------------------
QuestLogFrameAbandonButton:HookScript('OnClick', function(self, button)
	if IsShiftKeyDown() then
		StaticPopup1Button1:Click()
	end
end)

-----



local time = debugprofilestop()
S:print(format('Loaded in %dms (%ssec)', time, F:Round(time/1000, 4)))