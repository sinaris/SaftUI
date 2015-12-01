local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local SK = S:GetModule('Skinning')

local CHARACTER_SLOTS = {
	-- [0] = "Ammo",
	[1] = "Head",
	[2] = "Neck",
	[3] = "Shoulder",
	[4] = "Shirt",
	[5] = "Chest",
	[6] = "Waist",
	[7] = "Legs",
	[8] = "Feet",
	[9] = "Wrist",
	[10] = "Hands",
	[11] = "Finger0",
	[12] = "Finger1",
	[13] = "Trinket0",
	[14] = "Trinket1",
	[15] = "Back",
	[16] = "MainHand",
	[17] = "SecondaryHand",
	-- [18] = "Ranged",
	[19] = "Tabard",
}
local slotFrames = {}


local function FixTabPosition()
	local lastShown
	for i=1, 4 do
		local tab =  _G['CharacterFrameTab' .. i]
		if tab:IsShown() then
			tab:_ClearAllPoints()
			if not lastShown then
				tab:_SetPoint('BOTTOMLEFT', CharacterFrame, 'BOTTOMLEFT', 6, 6)	
			else
				tab:_SetPoint('LEFT', lastShown, 'RIGHT', 4, 0)
			end
			lastShown = tab
		end	
	end
end

local function FixStatPaneHeight(categoryFrame)
	local categoryInfo = PAPERDOLL_STATCATEGORIES[categoryFrame.Category]
	
	local i = 1
	repeat
		statFrame = _G[categoryFrame:GetName().."Stat"..i]
		if statFrame.Bg then
			statFrame.Bg:SetPoint("RIGHT", categoryFrame, "RIGHT", -S.borderinset, 0)
			statFrame.Bg:SetPoint("LEFT", categoryFrame, "LEFT", S.borderinset, 0)
		end
		i=i+1
	until not _G[categoryFrame:GetName().."Stat"..i]

end

local function SkinTitles()
	if PaperDollTitlesPane.skinned then return end

	local buttons = PaperDollTitlesPane.buttons
	local parentWidth = PaperDollTitlesPane:GetWidth()

	local border = S.borderinset
	PaperDollTitlesPane.buttonHeight = 20 + border
	PaperDollTitlesPane:SetTemplate()

	local lastButton
	for i,button in pairs(buttons) do
		button.text:SetFontTemplate()
		button.text:SetPoint('LEFT', 5, 0)
		button.text:SetPoint('RIGHT', -5, 0)
		button:SetWidth(parentWidth-2)

		if button.Stripe then button.Stripe:Kill() end
		button:StripTextures()
	end

	PaperDollTitlesPane.skinned = true
end

--Buttons used to toggle between equipment manager, titles, and character stats
local function FixSidebarTabs()
	PaperDollSidebarTabs:Show()

	CharacterFrameInsetRight:SetAlpha(1)

	if not PaperDollSidebarTabs.skinned then
		local text = {'Stats', 'Titles', 'Sets', 'Portrait'}

		PaperDollSidebarTabs.DecorLeft:Kill()
		PaperDollSidebarTabs.DecorRight:Kill()


		PAPERDOLL_SIDEBARS[4] = {
			name = 'Character Portrait',
			frame = 'CharacterModelFrame',
			icon = nil,
			texCoords = {0,0,0,0},
		}

		for i=1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]

			tab:ClearAllPoints()
			if i == 1 then
				tab:SetPoint('LEFT', PaperDollSidebarTabs)
			else
				tab:SetPoint('LEFT', _G["PaperDollSidebarTab"..(i-1)], 'RIGHT', 4, 0)
			end

			if tab.Highlight then tab.Highlight:Kill() end
			if tab.Hider then tab.Hider:Kill() end
			if tab.TabBg then tab.TabBg:Kill() end
			if tab.Icon then tab.Icon:Kill() end

			tab:SkinButton(false, text[i])
			tab:SetHeight(PaperDollSidebarTabs:GetHeight())
			local widthOffset = (#PAPERDOLL_SIDEBARS-1)*4
			tab:SetWidth((CharacterFrameInfoPanel:GetWidth()-widthOffset)/#PAPERDOLL_SIDEBARS)
		end
		PaperDollSidebarTabs.skinned = true
	end
end

local function SetSidebarActiveTab(self, index)
	if not PaperDollSidebarTab1.text then return end

	for i = 1, #PAPERDOLL_SIDEBARS do
		if i == index then
			 _G['PaperDollSidebarTab'..i].text:SetTextColor(1,1,1)
		else
	        _G['PaperDollSidebarTab'..i].text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b) --Change for proper global variable
	    end
    end
end

local function SkinCharacterFrameTextures()
	--General Frames
	for _,frame in pairs({
		CharacterFrame,
		CharacterFrameInset,
		CharacterFrameInsetRight,
		PaperDollFrame,
		PaperDollItemsFrame,
		PaperDollTitlesPane,
		PaperDollEquipmentManagerPane,
		CharacterStatsPane,
	}) do frame:StripTextures() end
	
	--Skin Scroll Bars
	CharacterStatsPaneScrollBar:SkinScrollBar(nil, true)
	ReputationListScrollFrameScrollBar:SkinScrollBar(nil, true)
	TokenFrameContainerScrollBar:SkinScrollBar(nil, true)
	GearManagerDialogPopupScrollFrameScrollBar:SkinScrollBar(nil, true)
	PaperDollTitlesPaneScrollBar:SkinScrollBar(nil, true)
	PaperDollEquipmentManagerPaneScrollBar:SkinScrollBar(nil, true)

	--Remove top-right portrait
	CharacterFramePortrait:Kill()

	-- General frame skin
	CharacterFrame:CreateBackdrop('T')
	CharacterFrame:SetHeight(SK.UI_PANEL_HEIGHT)

	CharacterFrameCloseButton:SkinCloseButton()
	CharacterFrameCloseButton:SetPoint('TOPRIGHT', -6, -6)

	--Fix level text position
	CharacterLevelText:ClearAllPoints()
	CharacterLevelText:SetPoint('TOP', CharacterFrameTitleText, 'BOTTOM', 0, -6)
	CharacterLevelText.SetPoint = S.dummy
	CharacterLevelText:SetHeight(20)
end

local function SetItemSlotBorderColor(slotID)
	local itemID = GetInventoryItemID("player", slotID)
	local slotFrame = slotFrames[slotID]--_G['Character'..CHARACTER_SLOTS[slotID]..'Slot']
	if not itemID then print(slotID); slotFrame:SetTemplate() return end

	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)

	if not quality then return end
	
	local r, g, b, hex = GetItemQualityColor(quality)

	slotFrame:SetBackdropBorderColor(r,g,b)
end

local function UpdateDurabilityIndicators()
	for slotID,slot in pairs(slotFrames) do

		local current, max = GetInventoryItemDurability(slot.slotID)		
		if current and max and current/max <= 0.5 then 
			slot.durability:Show()
			if current/max <= 0.2 then
				slot.durability.Texture:SetTexture(0.8, 0.2, 0.2)
			else
				slot.durability.Texture:SetTexture(1.0, 0.8, 0.4)
			end
		else
			slot.durability:Hide()
		end

		local link = GetInventoryItemLink('player', slot.slotID)
		if link then
			local _, _, _, iLevel = GetItemInfo(link)
			slot.ilvl:SetText(iLevel)
			slot.ilvl:Show()
		else
			slot.ilvl:Hide()
		end

	end
end

local function SkinAndPositionGearSlots()
	-- Reposition item slots
	CharacterHeadSlot:ClearAllPoints()
	CharacterHeadSlot:SetPoint('TOPLEFT', 6, -40)
	
	CharacterHandsSlot:ClearAllPoints()
	CharacterHandsSlot:SetPoint('TOPLEFT', CharacterHeadSlot, 'TOPRIGHT', 4, 0)

	CharacterMainHandSlot:ClearAllPoints()
	CharacterMainHandSlot:SetPoint('TOPRIGHT', CharacterWristSlot, 'BOTTOMRIGHT', 0, -4)

	CharacterSecondaryHandSlot:ClearAllPoints()
	CharacterSecondaryHandSlot:SetPoint('TOPLEFT', CharacterMainHandSlot, 'TOPRIGHT', 4, 0)

	for slotID,slotName in ipairs(CHARACTER_SLOTS) do
		local slot = _G['Character'..slotName..'Slot']
		
		slot.verticalFlyout = false

		slot:StripTextures()
		slot:SkinActionButton()
		slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])

		_G['Character'..slotName..'SlotPopoutButton']:Kill()
		_G['Character'..slotName..'SlotIconTexture']:SetInside()
		_G['Character'..slotName..'SlotIconTexture']:SetTexCoord(unpack(S.iconcoords))

		local dura = CreateFrame('frame', nil, slot)
		dura:SetPoint('TOPLEFT', 3, -3)
		dura:SetSize(7,7)
		dura:SetTemplate()
		dura.Texture = dura:CreateTexture(nil, 'OVERLAY')
		dura.Texture:SetInside(dura)
		dura:Hide()
		slot.durability = dura

		local ilvl = S.CreateFontString(slot, 'pixel')
		ilvl:SetPoint('BOTTOMRIGHT', -2, 3)
		ilvl:SetJustifyH('RIGHT')
		ilvl:SetText(400)
		slot.ilvl = ilvl

		slot.slotName = slotName
		slot.slotID = slotID
		slotFrames[slotID] = slot

		SetItemSlotBorderColor(slotID)

	end

	UpdateDurabilityIndicators()

	local frame = CreateFrame('frame')
	frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
	frame:SetScript('OnEvent', function(self, event, slotID, hasItem)
		if event == 'PLAYER_EQUIPMENT_CHANGED' then
			SetItemSlotBorderColor(slotID)
		end
		UpdateDurabilityIndicators()		
	end)
end

local function UpdateItemSlotBorders()
	for slotID,slotName in ipairs(CHARACTER_SLOTS) do
		SetItemSlotBorderColor(slotID)
	end
end


local function SkinPetFrame()
	PetModelFrame:CreateBackdrop('T')
	PetModelFrame:SetPoint('BOTTOM', 0, 40)
	PetPaperDollPetModelBg:SetInside(PetModelFrame)
	PetPaperDollPetModelBg:SetTexCoord(.03, .62, .03, .68)
end

local function SkinCharacterModelFrame()
	CharacterModelFrame:SetWidth(CharacterFrameInfoPanel:GetWidth())
	CharacterModelFrame:SetTemplate('K')
	CharacterModelFrame.BackgroundTopLeft.SetTexture = S.dummy
    CharacterModelFrame.BackgroundTopRight.SetTexture = S.dummy
    CharacterModelFrame.BackgroundBotLeft.SetTexture = S.dummy
    CharacterModelFrame.BackgroundBotRight.SetTexture = S.dummy
	CharacterModelFrame:Hide()

	CharacterModelFrameControlFrame:Kill()
end

local function SkinBottomTabs()
	for i=1, 4 do
		local tab =  _G['CharacterFrameTab' .. i]
		tab:SetWidth(65);  tab._SetWidth  = tab.SetWidth;  tab.SetWidth  = S.dummy
		tab:SetHeight(25); tab._SetHeight = tab.SetHeight; tab.SetHeight = S.dummy


		--Don't let blizzard move these
		tab._SetPoint = tab.SetPoint
		tab.SetPoint = S.dummy
		tab.SetAllPoints = S.dummy
		tab._ClearAllPoints = tab.ClearAllPoints
		tab.ClearAllPoints = S.dummy

		tab:HookScript('OnShow', FixTabPosition)
		-- tab:SetTemplate('KB')
		tab:StripTextures()
		tab:SkinButton(false, ({'Character', 'Pet', 'Reputation', 'Currency'})[i])

		local tabtext = _G['CharacterFrameTab' .. i .. 'Text']
		tabtext:ClearAllPoints()
		tabtext:SetPoint('CENTER')
		tabtext:SetDrawLayer('OVERLAY')
		tabtext.SetPoint = S.dummy
	end
end

local function UpdateReputationFrame()
	for i=1, NUM_FACTIONS_DISPLAYED do
		local factionIndex = FauxScrollFrame_GetOffset(ReputationListScrollFrame) + i
		local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
	    local factionRow = _G["ReputationBar"..i]
		local factionBar = _G["ReputationBar"..i.."ReputationBar"]
		local factionLFGBonusButton = factionRow.LFGBonusRepButton

		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex)

		factionBar:SetInside(factionRow)

		factionButton:ClearAllPoints()
		factionButton:SetPoint('RIGHT', factionRow, 'LEFT', -S.borderinset, 0)

        local factionTitle = _G["ReputationBar"..i.."FactionName"]

		factionLFGBonusButton:SetPoint("RIGHT", factionBar, "LEFT", -3, 0);

        if isHeader then
        	factionTitle:SetParent(factionButton)
        	factionTitle:SetPoint('LEFT', factionRow, 6, 0)

        	if isChild then
	        	factionRow:SetPoint('LEFT', ReputationListScrollFrame, 20, 0)
	        else
	        	factionRow:SetPoint('LEFT', ReputationListScrollFrame, 0, 0)
	        end
        else
        	factionTitle:SetParent(factionBar)

        	if isChild then
	        	factionRow:SetPoint('LEFT', ReputationListScrollFrame, 40, 0)
	        else
	        	factionRow:SetPoint('LEFT', ReputationListScrollFrame, 20, 0)
	        end
        end

		
		if factionRow.isCollapsed then
			factionButton.text:SetText('+')
		else
			factionButton.text:SetText('-')
		end
	end
end

local function SkinReputationFrame()
	local offset = 20 + S.borderinset

	ReputationListScrollFrame:StripTextures()
	ReputationListScrollFrame:SetAllPoints(CharacterFrameInset)
	ReputationListScrollFrame:SetPoint('BOTTOMRIGHT', CharacterFrameInset, -offset, 7)
	
	ReputationFrameFactionLabel:Hide()
	ReputationFrameStandingLabel:Hide()

	CharacterFrameInset:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', 6, -40)
	CharacterFrameInset:SetPoint('BOTTOMRIGHT', CharacterFrame, 'BOTTOMRIGHT', -6, 30)

	ReputationDetailFrame:SetTemplate('KT')
	ReputationDetailAtWarCheckBox:SkinCheckBox()
	ReputationDetailInactiveCheckBox:SkinCheckBox()
	ReputationDetailMainScreenCheckBox:SkinCheckBox()
	ReputationDetailLFGBonusReputationCheckBox:SkinCheckBox()


	ReputationBar1:SetPoint('TOPRIGHT', ReputationListScrollFrame, 'TOPRIGHT', ReputationListScrollFrame:IsShown() and 0 or offset, 0)
	ReputationListScrollFrame:SetScript('OnShow', function(self)
		ReputationBar1:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, 0)
	end)

	ReputationListScrollFrame:SetScript('OnHide', function(self)
		ReputationBar1:SetPoint('TOPRIGHT', self, 'TOPRIGHT', offset, 0)
	end)

	--Skin Reputation Bars
	for i=1, NUM_FACTIONS_DISPLAYED do
		local factionIndex = FauxScrollFrame_GetOffset(ReputationListScrollFrame) + i
        local factionRow = _G["ReputationBar"..i]
        local factionTitle = _G["ReputationBar"..i.."FactionName"]
        local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
		local factionLeftLine = _G["ReputationBar"..i.."LeftLine"]
		local factionBottomLine = _G["ReputationBar"..i.."BottomLine"]
		local factionStanding = _G["ReputationBar"..i.."ReputationBarFactionStanding"]
		local factionBackground = _G["ReputationBar"..i.."Background"]
		local factionBar = _G["ReputationBar"..i.."ReputationBar"]
		local factionBonusIcon = factionBar.BonusIcon
		local factionLFGBonusButton = factionRow.LFGBonusRepButton

		factionBonusIcon:ClearAllPoints()
		factionBonusIcon:SetPoint('LEFT', factionTitle, 'RIGHT', 5, 0)

		factionLFGBonusButton:SkinCheckBox()
		-- factionLFGBonusButton.Display:SetBackdropBorderColor(.3, .3, .3)

        factionRow:SetTemplate()

		factionButton:SetNormalTexture('')
		factionButton.SetNormalTexture = S.dummy
		factionButton:SkinButton(false, '+')
		factionButton:ClearAllPoints()
		factionButton:SetPoint('LEFT', factionRow, 'RIGHT', S.borderinset, 0)
		factionButton:SetSize(factionRow:GetHeight(), factionRow:GetHeight())
		factionButton.text:SetFontTemplate('pixel')
		factionButton.text:ClearAllPoints()
		factionButton.text:SetPoint('RIGHT', -6, 0)

		factionStanding:ClearAllPoints()
		factionStanding:SetPoint('RIGHT', -6, 0)

		factionBar:StripTextures()
		factionBar:SetBarTemplate()

		factionBackground:Kill()
	end

	UpdateReputationFrame()
end

local function SkinEquipmentManager()
	PaperDollEquipmentManagerPane:SetWidth(CharacterFrameInfoPanel:GetWidth())
	PaperDollEquipmentManagerPaneSaveSet:SkinButton()
	PaperDollEquipmentManagerPaneEquipSet:SkinButton()
end

local function UpdateStatsPaneCategoryPositions()
	for i=1, 6 do
		local category = _G['CharacterStatsPaneCategory'..i]
		local _,parentAnchor,_,xOff,yOff =  category:GetPoint()
		if parentAnchor == CharacterStatsPaneScrollChild then
			category:ClearAllPoints()
			category:SetPoint('TOPLEFT', CharacterStatsPaneScrollChild, 0, 0)
		end
	end
end


-- PaperDollFrame_UpdateStatCategory

function PaperDollFrame_UpdateStatScrollChildHeight()
	local index = 1
	local totalHeight = 0
	while(_G["CharacterStatsPaneCategory"..index]) do
		if (_G["CharacterStatsPaneCategory"..index]:IsShown()) then
			totalHeight = totalHeight + _G["CharacterStatsPaneCategory"..index]:GetHeight() + 4
		end
		index = index + 1
	end

	-- CharacterStatsPaneScrollChild:SetHeight(totalHeight + 10)  
	CharacterStatsPaneScrollChild:SetHeight(totalHeight - 4) 
end

 
local function UpdatePaperDollTitlesPane()
	local titleCount = 1 
       
    for i = 1, GetNumTitles() do
        if ( IsTitleKnown(i) ~= 0 ) then       
          local tempName, playerTitle = GetTitleName(i)
            if ( tempName and playerTitle ) then
                titleCount = titleCount + 1
            end
        end
    end
    HybridScrollFrame_Update(PaperDollTitlesPane, titleCount * PLAYER_TITLE_HEIGHT + 8 , PaperDollTitlesPane:GetHeight())
    PaperDollTitlesPane_UpdateScrollFrame()
end

local function SkinCharacterStatsPane()
	for i=1, 6 do
		_G['CharacterStatsPaneCategory'..i]:SetTemplate('KG')
		_G['CharacterStatsPaneCategory'..i]:SetWidth(CharacterStatsPane:GetWidth())
	end
end

SK.GeneralSkins['CharacterFrame'] = function()
	hooksecurefunc('PaperDollFrame_UpdateStatCategory', FixStatPaneHeight)
	hooksecurefunc('PaperDollTitlesPane_UpdateScrollFrame', SkinTitles)
	hooksecurefunc('PaperDollEquipmentManagerPane_OnLoad',SkinEquipmentManager)
	-- hooksecurefunc('PaperDollEquipmentManagerPane_OnShow', SkinEquipmentManager)
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabs)
	hooksecurefunc('PaperDollTitlesPane_Update', UpdatePaperDollTitlesPane)
	hooksecurefunc('PaperDoll_UpdateCategoryPositions', UpdateStatsPaneCategoryPositions)
	hooksecurefunc('PaperDollFrame_SetSidebar', SetSidebarActiveTab)
	
	hooksecurefunc('CharacterFrame_ShowSubFrame', function(frameName)
		-- if frameName == 'PaperDollFrame' then
		-- 	SetSidebarActiveTab(PaperDollSidebarTab1, 1)
		-- end
	end)
	
	SkinCharacterFrameTextures()	
	SkinAndPositionGearSlots()
	SkinPetFrame()
	SkinBottomTabs()

	NUM_FACTIONS_DISPLAYED = 16

	
	CHARACTERFRAME_EXPANDED_WIDTH = PANEL_DEFAULT_WIDTH --Make sure character frame doesn't change width when expanding anymore
	CharacterFrameExpandButton:Kill() --Disallow user from expanding

	local contentAnchor = CreateFrame('frame', 'CharacterFrameContentAnchor', CharacterFrame)
	contentAnchor:ClearAllPoints()
	contentAnchor:SetPoint('TOPLEFT', CharacterFrame, 6, -40)
	contentAnchor:SetPoint('BOTTOMRIGHT', CharacterFrame, -6, 37)
	CharacterFrame.Anchor = contentAnchor


	local infoPanel = CreateFrame('frame', 'CharacterFrameInfoPanel', CharacterFrame)
	infoPanel:SetPoint('TOPRIGHT', contentAnchor, 'TOPRIGHT', 0, 0)
	infoPanel:SetWidth(243)
	infoPanel:SetHeight(365)

	SetCVar("characterFrameCollapsed", false)

	PaperDollSidebarTabs:ClearAllPoints()
	PaperDollSidebarTabs:SetWidth(infoPanel:GetWidth())
	PaperDollSidebarTabs:SetHeight(20)
	PaperDollSidebarTabs:SetPoint('TOP', infoPanel, 'TOP', 0, 0)

	SkinReputationFrame()
	hooksecurefunc('ReputationFrame_Update', UpdateReputationFrame)

	for frameName, scrollBarPadding in pairs({
		['CharacterStatsPane'] = true,
		['PaperDollTitlesPane'] = true,
		['PaperDollEquipmentManagerPane'] = true,
		['CharacterModelFrame'] = false,
	}) do
		local frame = _G[frameName]
		frame:ClearAllPoints()
		frame:SetPoint('TOPLEFT', PaperDollSidebarTabs, 'BOTTOMLEFT', 0, -6)
		frame:SetHeight(infoPanel:GetHeight()-PaperDollSidebarTabs:GetHeight()-6)

		local padding = scrollBarPadding and 20 + S.borderinset or 0
		frame:SetWidth(infoPanel:GetWidth()-padding)
	end


	SkinCharacterStatsPane()
	SkinCharacterModelFrame()
	
end