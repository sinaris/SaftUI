local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local SK = S:GetModule('Skinning')


local numButtons = 9

function SaftUI_FriendsFrame_UpdateFriends()
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local scrollOffset = HybridScrollFrame_GetOffset(scrollFrame)
	local BNTotal,BNOnline = BNGetNumFriends()

	for i,button in pairs(scrollFrame.buttons) do
		local index = i+scrollOffset
		
		if index <= BNOnline and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local client = select(7, BNGetFriendInfo(index)) -- local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(button.id);
			if client then
				button.gameIcon.icon:SetTexture(BNet_GetClientTexture(client))
			end
		end
	end


    local totalHeight = (BNGetNumFriends() + GetNumFriends()+1) * FRIENDS_BUTTON_NORMAL_HEIGHT
    local displayHeight = (numButtons * FRIENDS_BUTTON_NORMAL_HEIGHT) + ((numButtons-1)*(S.borderinset+1) + 1)
    FriendsFrameFriendsScrollFrame:SetHeight(displayHeight)
    HybridScrollFrame_Update(scrollFrame, totalHeight, displayHeight);
end

local function SaftUI_SkinFriendsList()
	hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', SaftUI_FriendsFrame_UpdateFriends)
	hooksecurefunc('FriendsFrame_UpdateFriends', SaftUI_FriendsFrame_UpdateFriends)

	--Scroll of Ressurection
	FriendsTabHeaderSoRButton:SkinButton(true)
	FriendsTabHeaderSoRButtonIcon:TrimIcon()
	FriendsTabHeaderSoRButtonIcon:SetInside()
	FriendsTabHeaderSoRButtonIcon:SetDrawLayer('OVERLAY')
	FriendsTabHeaderSoRButton:SetSize(20, 20)
	FriendsTabHeaderSoRButton:ClearAllPoints()
	FriendsTabHeaderSoRButton:SetPoint('TOPRIGHT', FriendsFrameCloseButton, 'TOPLEFT', -(S.borderinset+1), 0)

	-- FriendsTabHeaderRecruitAFriendButton
	FriendsTabHeaderRecruitAFriendButton:SkinButton(true)
	FriendsTabHeaderRecruitAFriendButtonIcon:TrimIcon()
	FriendsTabHeaderRecruitAFriendButtonIcon:SetInside()
	FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer('OVERLAY')
	FriendsTabHeaderRecruitAFriendButton:SetSize(20, 20)
	FriendsTabHeaderRecruitAFriendButton:ClearAllPoints()
	FriendsTabHeaderRecruitAFriendButton:SetPoint('TOPRIGHT', FriendsTabHeaderSoRButton, 'TOPLEFT', -(S.borderinset+1), 0)

	--Skin Add Friend & Send Message buttons
	FriendsFrameAddFriendButton:SkinButton()
	FriendsFrameAddFriendButton:ClearAllPoints()
	FriendsFrameAddFriendButton:SetPoint('BOTTOMLEFT', FriendsFrame.Anchor, 'BOTTOMLEFT', 0, 0)
	
	FriendsFrameSendMessageButton:SkinButton()
	FriendsFrameSendMessageButton:ClearAllPoints()
	FriendsFrameSendMessageButton:SetPoint('BOTTOMRIGHT', FriendsFrame.Anchor, 'BOTTOMRIGHT', 0, 0)
	
	--Skin friends/ignore/pending tabs
	FriendsTabHeader:SetHeight(20)
	FriendsTabHeader:SetWidth(180+(S.borderinset+1)*2)
	FriendsTabHeader:ClearAllPoints()
	FriendsTabHeader:SetPoint('TOPLEFT', FriendsFrame.Anchor, 'TOPLEFT', 0, 0)

	local lastTab
	for i = 1, FriendsTabHeader.numTabs do
		local tab = _G["FriendsTabHeaderTab"..i]
		tab:ClearAllPoints()
		if lastTab then
			tab:SetPoint('LEFT', _G["FriendsTabHeaderTab"..(i-1)], 'RIGHT', S.borderinset+1, 0)
		else
			tab:SetPoint('TOPLEFT', FriendsTabHeader, 'TOPLEFT', 0, 0)
		end
		lastTab = tab

		tab:SetSize(60, FriendsTabHeader:GetHeight())
		tab:SkinButton()
    end

    --Status Dropdown
    FriendsFrameStatusDropDown:ClearAllPoints()
	FriendsFrameStatusDropDown:SetPoint('LEFT', lastTab, 'RIGHT', S.borderinset+1, 0)
	FriendsFrameStatusDropDown:SkinDropDown(20,20)
	FriendsFrameStatusDropDownStatus:ClearAllPoints()
	FriendsFrameStatusDropDownStatus:SetPoint('CENTER')
	FriendsFrameStatusDropDownMouseOver:SetAllPoints()
	FriendsFrameStatusDropDownMouseOver:EnableMouse(false)

	--Mold Bnet frame and Broadcast button into one
	local BroadcastButton = FriendsFrameBattlenetFrame.BroadcastButton
	local BroadcastFrame = FriendsFrameBattlenetFrame.BroadcastFrame

	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:EnableMouse(false)
	FriendsFrameBattlenetFrame:SetHeight(20)
	FriendsFrameBattlenetFrame:ClearAllPoints()
	FriendsFrameBattlenetFrame:SetPoint('TOPLEFT', FriendsFrameStatusDropDown, 'TOPRIGHT', S.borderinset+1, 0)
	FriendsFrameBattlenetFrame:SetPoint('TOPRIGHT', FriendsFrame.Anchor, 'TOPRIGHT', 0, 0)

	BroadcastButton:SkinButton()
	BroadcastButton:SetAllPoints(FriendsFrameBattlenetFrame)
	BroadcastButton:SetFrameLevel(FriendsFrameBattlenetFrame:GetFrameLevel()-1)
	BroadcastButton.SetHighlightTexture = S.dummy
	BroadcastButton.SetNormalTexture = S.dummy
	BroadcastButton.SetPushedTexture = S.dummy

	BroadcastFrame:SetTemplate('KT')
	BroadcastFrame.ScrollFrame.UpdateButton:SkinButton()
	BroadcastFrame.ScrollFrame.CancelButton:SkinButton()

	BroadcastFrame.ScrollFrame:SetTemplate('KN')

	-- Skin friends scrollframe
	FriendsFrameFriendsScrollFrame:StripTextures()
	FriendsFrameFriendsScrollFrameScrollBar:SkinScrollBar()
    FriendsFrameFriendsScrollFrame:ClearAllPoints()
    FriendsFrameFriendsScrollFrame:SetPoint('TOPLEFT', FriendsTabHeader, 'BOTTOMLEFT', 0, -3)
    FriendsFrameFriendsScrollFrame:SetWidth(305)

	-- Remove offline header
	FriendsFrameOfflineHeader:Kill()

	--Skin all ofthe scrollframe buttons
	for i,button in pairs(FriendsFrameFriendsScrollFrame.buttons) do
		button.background:Kill()
		button:SkinButton()
		button:SetHighlightTexture('')


		if i > 1 then
			button:ClearAllPoints()
			button:SetPoint('TOP', FriendsFrameFriendsScrollFrame.buttons[i-1], 'BOTTOM', 0, -(S.borderinset+1))
		end

		button:SetWidth(FriendsFrameFriendsScrollFrame:GetWidth())

		local gameIconTexture = button.gameIcon
		button.gameIcon = CreateFrame('frame', nil, button)
		button.gameIcon:SetTemplate()
		button.gameIcon:SetSize(24, 24)
		button.gameIcon:ClearAllPoints()
		button.gameIcon:SetPoint('RIGHT', button.travelPassButton, 'LEFT', -(S.borderinset+1), 0)
		button.gameIcon.SetPoint = S.dummy

		gameIconTexture:SetParent(button.gameIcon)
		gameIconTexture:SetInside(button.gameIcon)
		gameIconTexture:TrimIcon(.16)

		button.gameIcon.icon = gameIconTexture --re-store it within the button
		button.gameIcon.SetTexture = S.dummy --Make sure blizzard's set texture doesn't interfere

		button.summonButton:SkinActionButton()

		-- button.travelPassButton:SkinButton(false, '+')
	end
end

function SaftUI_WhoList_Update()
	local numWhos, totalCount = GetNumWhoResults();
    local name, guild, level, race, class, zone;
    local button, buttonText, classTextColor, classFileName;
    local columnTable;
    local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);
    local whoIndex;
    local showScrollBar = numWhos > WHOS_TO_DISPLAY

	for i=1,17 do
		local button = _G['WhoFrameButton'..i]
		button:SetPoint('RIGHT', showScrollBar and WhoListScrollFrame or WhoFrame)
	end

	WhoFrameColumn_SetWidth(WhoFrameColumnHeader4, 90);
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 115);
	WhoFrameDropDown:SkinDropDown(WhoFrameColumnHeader2:GetSize())
end

function SaftUI_SkinWhoList()
	hooksecurefunc('WhoList_Update', SaftUI_WhoList_Update)

	WhoFrame:SetAllPoints(FriendsFrame.Anchor)
	WhoFrame:SetSize(FriendsFrame.Anchor:GetSize()) --Just incase anything else pulls from the size of this
	WhoFrameListInset:Kill()

	WhoListScrollFrame:StripTextures()
	WhoListScrollFrame:ClearAllPoints()
	WhoListScrollFrame:SetPoint('TOPLEFT', WhoFrameColumnHeader1, 'BOTTOMLEFT', 0, -(S.borderinset+1))
	WhoListScrollFrame:SetPoint('RIGHT', WhoFrame, 'RIGHT', -(20+S.borderinset), 0)
	WhoListScrollFrame:SetHeight(322)
	WhoListScrollFrameScrollBar:SkinScrollBar()

	--Skin the tabs at the top of the list
	local lastHeader
	for i=1, 4 do
		local header = _G['WhoFrameColumnHeader'..i]
		header:SetHeight(20)

		if i == 2 then
			header:StripTextures()
			header.SetTexture = S.dummy
		else
			header:SkinButton()
		end	

		header:ClearAllPoints()
		if not lastHeader then
			header:SetPoint('TOPLEFT', WhoFrame, 'TOPLEFT', 0, 0)
		else
			header:SetPoint('LEFT', lastHeader, 'RIGHT', S.borderinset+1, 0)
		end
		lastHeader = header
	end

	--Skin the dropdown connected to WhoFrameColumnHeader2
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 115);
	WhoFrameDropDown:SkinDropDown(WhoFrameColumnHeader2:GetSize())
	WhoFrameDropDown:ClearAllPoints()
	WhoFrameDropDown:SetPoint('CENTER')

	-- Skin list rows
	local lastButton
	for i=1, 17 do
		local button = _G['WhoFrameButton'..i]
		button:SetTemplate()
		button:SetPushedTexture('')
		button:SetNormalTexture('')
		button:SetHighlightTexture('')
		button:SkinButton()
		button:SetHeight(18)
		button:SetTemplate()

		button:ClearAllPoints()
		if lastButton then
			button:SetPoint('TOPLEFT', lastButton, 'BOTTOMLEFT', 0, -1)
		else
			button:SetPoint('TOPLEFT', WhoListScrollFrame, 'TOPLEFT', 0, 0)
		end

		local buttonText

		buttonText = _G["WhoFrameButton"..i.."Name"];
		buttonText:SetPoint('TOP', button)
		buttonText:SetPoint('BOTTOM', button, 0, 2)
		buttonText:SetPoint('LEFT', WhoFrameColumnHeader1)
		buttonText:SetPoint('RIGHT', WhoFrameColumnHeader1)

		buttonText = _G["WhoFrameButton"..i.."Variable"];
		buttonText:SetPoint('TOP', button)
		buttonText:SetPoint('BOTTOM', button)
		buttonText:SetPoint('LEFT', WhoFrameColumnHeader2, 5, 0)
		buttonText:SetPoint('RIGHT', WhoFrameColumnHeader2, -5, 0)

		buttonText = _G["WhoFrameButton"..i.."Level"];
		buttonText:SetPoint('TOP', button)
		buttonText:SetPoint('BOTTOM', button)
		buttonText:SetPoint('LEFT', WhoFrameColumnHeader3)
		buttonText:SetPoint('RIGHT', WhoFrameColumnHeader3)
		
		buttonText = _G["WhoFrameButton"..i.."Class"];
		buttonText:SetPoint('TOP', button)
		buttonText:SetPoint('BOTTOM', button)
		buttonText:SetPoint('LEFT', WhoFrameColumnHeader4, 5, 0)
		buttonText:SetPoint('RIGHT', WhoFrameColumnHeader4, -5, 0)
		-- buttonText:SetJustifyH('RIGHT')
		
		lastButton = button
	end

	WhoFrameWhoButton:SkinButton(nil, '>')
	WhoFrameWhoButton:SetWidth(20)
	WhoFrameWhoButton:ClearAllPoints()
	WhoFrameWhoButton:SetPoint('BOTTOMRIGHT', FriendsFrame.Anchor, 'BOTTOMRIGHT', 0, 0)
	WhoFrameAddFriendButton:Kill()
	WhoFrameGroupInviteButton:Kill()

	WhoFrameEditBox:SkinEditBox()
	WhoFrameEditBox:SetAllPoints(WhoFrameEditBoxInset)
	WhoFrameEditBoxInset:StripTextures()
	WhoFrameEditBoxInset:ClearAllPoints()
	WhoFrameEditBoxInset:SetPoint('BOTTOMLEFT', FriendsFrame.Anchor, 'BOTTOMLEFT', 0, 0)
	WhoFrameEditBoxInset:SetPoint('TOPRIGHT', WhoFrameWhoButton, 'TOPLEFT', -S.borderinset, 0)
	WhoFrameEditBoxInset:SetHeight(20)
	-- WhoFrameEditBoxInset:SetTemplate()

	


end

function SaftUI_SkinChatList()

end

function SaftUI_SkinRaidList()

end


SK.GeneralSkins['ChatConfigFrame'] = function()
	--Use as a margin to align items more easily
	local contentAnchor = CreateFrame('frame', 'FriendsFrameContentAnchor', FriendsFrame)
	contentAnchor:ClearAllPoints()
	local height, width = FriendsFrame:GetSize()
	contentAnchor:SetPoint('TOPLEFT', FriendsFrame, 6, -40)
	contentAnchor:SetPoint('BOTTOMRIGHT', FriendsFrame, -6, 31)
	FriendsFrame.Anchor = contentAnchor

	FriendsFrameInset:StripTextures()

	FriendsFrame:SetHeight(SK.UI_PANEL_HEIGHT)
	FriendsFrame:SetTemplate('KT')

	FriendsFrameTitleText:ClearAllPoints()
	FriendsFrameTitleText:SetPoint('TOP', FriendsFrame, 'TOP', 0, -6)
	FriendsFrameTitleText:SetHeight(20)
	
	FriendsFrameCloseButton:SkinCloseButton()
	FriendsFrameCloseButton:ClearAllPoints()
	FriendsFrameCloseButton:SetPoint('TOPRIGHT', -6, -6)

	FriendsFrameIcon:Kill()

	local lastTab
	for i=1, 4 do
		local tab = _G['FriendsFrameTab'..i]
		tab:SkinButton()

		tab:SetHeight(20)
		tab.text:ClearAllPoints()
		tab.text:SetPoint('CENTER')
		tab.text.SetPoint = S.dummy

		tab:ClearAllPoints()
		if lastTab then
			tab:SetPoint('LEFT', lastTab, 'RIGHT', 6, 0)
		else
			tab:SetPoint('BOTTOMLEFT', FriendsFrame, 'BOTTOMLEFT', 6, 6)
		end
		lastTab = tab
	end

	SaftUI_SkinFriendsList()
	SaftUI_SkinWhoList()
	SaftUI_SkinChatList()
	SaftUI_SkinRaidList()
end