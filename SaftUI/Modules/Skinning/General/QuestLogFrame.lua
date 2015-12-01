local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

if true then return end 
local fontstrings = {
	normal = {
		QuestInfoDescriptionText,
		QuestInfoObjectivesText,
		QuestInfoGroupSize,
		QuestInfoRewardText,
		QuestInfoItemChooseText,
		QuestInfoItemReceiveText,
		QuestInfoSpellLearnText,
		QuestInfoXPFrameReceiveText,
		QuestProgressText,
	},
	headers = {
		QuestInfoTitleHeader,
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader,
		QuestInfoRewardsHeader,
		QuestProgressTitleText,
		QuestProgressRequiredItemsText,
		QuestProgressRequiredMoneyText,
	}
}

local function FixQuestInfoText(template, parentFrame, acceptButton, material)
	for _,fs in pairs(fontstrings.normal) do
		fs:SetTextColor(1, 1, 1)
		fs:SetShadowOffset(0,0)
	end
	
	for _,fs in pairs(fontstrings.headers) do
		fs:SetTextColor(1, 1, .3)
		local font, _, flags = S.UnpackFont(S.Saved.profile.General.Fonts.general)			
		fs:SetFont(font, 18, flags)
	end

	local numObjectives = GetNumQuestLeaderBoards()
	local objective
	local numVisibleObjectives = 0
	for i = 1, numObjectives do
		local _, type, finished = GetQuestLogLeaderBoard(i)
		if (type ~= "spell") then
			numVisibleObjectives = numVisibleObjectives+1
			objective = _G["QuestInfoObjective"..numVisibleObjectives]
			if ( finished ) then
				objective:SetTextColor(.3, .8, .3)
			else
				objective:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end

	if QuestInfoItem1:IsShown() then
		-- QuestInfoItemReceiveText:ClearAllPoints()
		-- QuestInfoItemReceiveText:SetPoint('TOPLEFT', QuestInfoItem1, 'BOTTOMLEFT', 0, -10)
	end
end

local function FixScrollFrameButtons()
	local newWidth = QuestLogScrollFrame:GetWidth()-15
	for i=1, GetNumQuestLogEntries() do
		local button = _G['QuestLogScrollFrameButton'..i]
		if button then button:SetWidth(newWidth) end
	end
end

local function UpdatePortrait()
	if ( UnitExists("questnpc") ) then
		QuestFramePortraitFrame:Show()
		QuestFramePortraitFrame.model:ClearModel()
		QuestFramePortraitFrame.model:SetCamDistanceScale(1)
		QuestFramePortraitFrame.model:SetPortraitZoom(1)
		QuestFramePortraitFrame.model:SetPosition(0,0,0)
		QuestFramePortraitFrame.model:SetUnit('questnpc')
		QuestFramePortraitFrame.model.guid = guid
	else
		QuestFramePortraitFrame:Hide()
	end
end

local function SkinQuestProgressFrame()
	FixQuestInfoText()
	local prev
	for i=1, GetNumQuestItems() do
		local item = _G["QuestProgressItem"..i]
		if item.skinned then prev = item return end

		item.icon = _G["QuestProgressItem"..i.."IconTexture"]
		item.count = _G["QuestProgressItem"..i.."Count"]
		item.text = _G["QuestProgressItem"..i.."Name"]

		-- item.icon:SetScript('OnEnter', function(self)
		-- 	-- GameTooltip:Hide()
		-- 	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', -self:GetWidth(), S.borderinset)
		-- 	GameTooltip:ClearLines()
		-- end)
		-- item.icon:SetScript('OnLeave', S.HideGameTooltip)

		item.text:Hide()
		if prev then
			item:ClearAllPoints()
			item:SetPoint('LEFT', prev, 'RIGHT', off, 0)
			item.SetPoint = S.dummy
		end

		item:SetSize(28, 28)		
		item:SetTemplate('K')
		item:SetFrameLevel(item:GetFrameLevel() + 2)
		item.icon:SetTexCoord(.08, .92, .08, .92)
		item.icon:SetDrawLayer("OVERLAY")
		item.icon:SetInside(item)

		item.count:SetDrawLayer("OVERLAY")
		item.count:SetFontTemplate('pixel')

		prev = item

		item.skinned = true
	end
end

local function HighlightQuestReward(self)
	if ( self.type == "choice" ) then
		QuestInfoItemHighlight:SetInside(self, 0)--("TOPLEFT", self, "TOPLEFT", -8, 7);
		QuestInfoItemHighlight:Show();
		QuestInfoFrame.itemChoice = self:GetID();
	end
end

local function QuestLogDetailFrame_UpdatePosition()
	if QuestLogDetailFrame.attached then
		QuestLogDetailScrollFrame:ClearAllPoints()
		QuestLogDetailScrollFrame:SetPoint('TOPLEFT', QuestLogScrollFrameScrollBarScrollUpButton, 'TOPRIGHT', S.borderinset+1, 0)
	else
		QuestLogDetailScrollFrame:ClearAllPoints()
		QuestLogDetailScrollFrame:SetPoint('TOPLEFT', QuestLogDetailFrame, 'TOPLEFT', 10, -10)
	end
end

hooksecurefunc('QuestLogDetailFrame_AttachToQuestLog', QuestLogDetailFrame_UpdatePosition)
hooksecurefunc('QuestLogDetailFrame_DetachFromQuestLog', QuestLogDetailFrame_UpdatePosition)
QuestLogDetailFrame:SetScript('OnShow', QuestLogDetailFrame_UpdatePosition)
hooksecurefunc('QuestInfoItem_OnClick', HighlightQuestReward)

S:GetModule('Skinning').GeneralSkins['QuestLogFrame'] = function()
	local off = S.borderinset

	--Background layer of quest log
	QuestLogFrame:SetTemplate('KTS')
	QuestLogFrame:SetHeight(480)
	QuestLogTitleText:Hide()
	QuestLogFrameCloseButton:Kill()
	EmptyQuestLogFrame:StripTextures()
	QuestLogFrameInset:StripTextures()

	--Left-hand scroll frame
	QuestLogScrollFrameScrollBar:SkinScrollBar(nil, true)
	QuestLogScrollFrame:SetTemplate('TK')
	QuestLogScrollFrame:ClearAllPoints()
	QuestLogScrollFrame:SetPoint('TOPLEFT', QuestLogFrame, 'TOPLEFT', 10, -10)
	QuestLogScrollFrame:SetSize(301+off*2, 435)
	QuestLogScrollFrameScrollChild:ClearAllPoints()
	QuestLogScrollFrameScrollChild:SetPoint('TOPLEFT', 5, -5)
	QuestLogScrollFrameScrollChild:SetSize(QuestLogScrollFrame:GetWidth()-10, QuestLogScrollFrame:GetHeight()-10)

	QuestLogDetailFrame:SetTemplate('KTS')
	QuestLogDetailFrameInset:StripTextures()
	QuestLogDetailFrame:SetSize(342, 480)
	QuestLogDetailTitleText:Kill()

	--Right-hand scroll frame
	QuestLogDetailScrollFrameScrollBar:SkinScrollBar(nil, true)
	QuestLogDetailScrollFrame:SetTemplate('TK')
	QuestLogDetailScrollFrame:SetSize(QuestLogScrollFrame:GetWidth()+1, QuestLogScrollFrame:GetHeight())
	QuestLogDetailScrollChildFrame:ClearAllPoints()
	QuestLogDetailScrollChildFrame:SetPoint('TOPLEFT', 5, -5)
	-- QuestLogDetailScrollChildFrame:SetSize(QuestDetailScrollChildFrame:GetWidth()-10, QuestLogDetailScrollFrame:GetHeight()-10)
	QuestLogDetailScrollChildFrame.SetSize = S.dummy
	QuestLogDetailScrollChildFrame.SetHeight = S.dummy
	QuestLogDetailScrollChildFrame.SetWidth = S.dummy

	local prev
	for i,button in pairs({
		QuestLogFrameAbandonButton,
		QuestLogFramePushQuestButton,
		QuestLogFrameTrackButton,
		QuestLogCount,
		QuestLogFrameShowMapButton,
		QuestLogFrameCancelButton,
	}) do
		if i == 4 then 
			button:SetTemplate('KG')
		else
			button:SkinButton();
		end
		button:SetSize(106, 20);
		button:ClearAllPoints()
		if not prev then 
			button:SetPoint('BOTTOMLEFT', QuestLogFrame, 'BOTTOMLEFT', 10, 10)
		else
			button:SetPoint("LEFT", prev, "RIGHT", off+1, 0)
		end
		if i == 6 then button:SetPoint('BOTTOMRIGHT', QuestLogFrame, 'BOTTOMRIGHT', -10, 10) end
		prev = button

		button._SetPoint = button.SetPoint
		button.SetPoint = S.dummy --just to be sure
	end


	-- --Quest count
	-- QuestLogCount:StripTextures()
	-- QuestLogCount:ClearAllPoints()
	-- QuestLogCount:SetSize(QuestLogFrameAbandonButton:GetSize())
	-- QuestLogCount:SetTemplate('G')
	-- QuestLogQuestCount:SetPoint('CENTER')
	QuestLogQuestCount:SetInside(QuestLogCount)
	QuestLogQuestCount:SetJustifyH('CENTER')
	QuestLogFrameShowMapButtonText:SetInside(QuestLogFrameShowMapButton)
	QuestLogFrameShowMapButtonText:SetJustifyH('CENTER')


	-- QuestLogFrameShowMapButton:SetPoint('RIGHT', QuestLogFrameCancelButton, 'LEFT', -off, 0)
	-- QuestLogCount:SetPoint('RIGHT', QuestLogFrameShowMapButton, 'LEFT', -off, 0)
	-- QuestLogFrameAbandonButton:SetPoint('BOTTOMLEFT', QuestLogFrame, 'BOTTOMLEFT', 10, 10)
	-- QuestLogFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", off, 0)
	-- QuestLogFrameTrackButton:SetPoint("LEFT", QuestLogFramePushQuestButton, "RIGHT", off, 0)
	-- QuestLogFrameCancelButton:SetPoint('BOTTOMRIGHT', QuestLogFrame, 'BOTTOMRIGHT', -10, 10)

	local prev
	for i=1, MAX_NUM_ITEMS do
		local item = _G["QuestInfoItem"..i]
		item.icon = _G["QuestInfoItem"..i.."IconTexture"]
		item.count = _G["QuestInfoItem"..i.."Count"]
		item.text = _G["QuestInfoItem"..i.."Name"]

		item.text:Hide()
		if prev then
			item:ClearAllPoints()
			item:SetPoint('LEFT', prev, 'RIGHT', off, 0)
			item.SetPoint = S.dummy
		else
			
		end

		item:SetSize(28, 28)		
		item:SetTemplate('K')
		item:SetFrameLevel(item:GetFrameLevel() + 2)
		item.icon:SetTexCoord(.08, .92, .08, .92)
		item.icon:SetDrawLayer("OVERLAY")
		item.icon:SetInside(item)

		item.count:SetDrawLayer("OVERLAY")
		item.count:SetFontTemplate('pixel')

		prev = item
	end

	QuestInfoSkillPointFrame:StripTextures()
	QuestInfoSkillPointFrame:SetTemplate()
	QuestInfoSkillPointFrame:SetWidth(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(.08, .92, .08, .92)
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:SetPoint("TOPLEFT", 2, -2)
	QuestInfoSkillPointFrameIconTexture:SetSize(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:SetTemplate()
	QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFramePoints:ClearAllPoints()
	QuestInfoSkillPointFramePoints:SetPoint("BOTTOMRIGHT", QuestInfoSkillPointFrameIconTexture, "BOTTOMRIGHT")

	QuestInfoItemHighlight:SetTemplate('K')
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:SetSize(142, 40)

	-- SKin the quest frame when interacting with npcs
	QuestFrame:SetTemplate('KTS')
	QuestFrameInset:StripTextures()
	QuestFrameInset:ClearAllPoints()
	QuestFrameInset:SetPoint('TOPLEFT', QuestFrame, 'TOPLEFT', 10, -30)

	QuestFrameInset:SetSize(298,430)
	QuestDetailScrollChildFrame:SetSize(298,390)
	QuestDetailScrollFrame:SetSize(292,427)
	QuestDetailScrollFrameScrollBar:SetHeight(430)
	QuestDetailScrollFrameScrollBar.SetHeight = S.dummy
	QuestDetailScrollFrame:ClearAllPoints()
	QuestDetailScrollFrame:SetPoint('TOPLEFT', QuestFrame, 'TOPLEFT', 10, -30)

	QuestFrameDetailPanel:SetTemplate('K')
	QuestFrameDetailPanel:SetAllPoints(QuestFrameInset)
	QuestDetailScrollFrame:StripTextures()
	QuestDetailScrollFrameScrollBar:SkinScrollBar(21)
	QuestDetailScrollFrameScrollBar:SetPoint('BOTTOMLEFT', QuestDetailScrollFrame, 'BOTTOMRIGHT', 6, 13)

	QuestFrameProgressPanel:SetTemplate('K')
	QuestProgressScrollChildFrame:SetSize(298,390)
	QuestProgressScrollFrame:SetSize(292,427)
	QuestProgressScrollFrameScrollBar:SetHeight(430)
	QuestProgressScrollFrameScrollBar.SetHeight = S.dummy
	QuestProgressScrollFrame:ClearAllPoints()
	QuestProgressScrollFrame:SetPoint('TOPLEFT', QuestFrame, 'TOPLEFT', 10, -30)
	QuestProgressScrollFrame:StripTextures()
	QuestProgressScrollFrameScrollBar:SkinScrollBar(21)
	QuestProgressScrollFrameScrollBar:SetPoint('BOTTOMLEFT', QuestProgressScrollFrame, 'BOTTOMRIGHT', 6, 13)

	QuestFrameRewardPanel:SetTemplate('K')
	QuestRewardScrollChildFrame:SetSize(298,390)
	QuestRewardScrollFrame:SetSize(292,427)
	QuestRewardScrollFrameScrollBar:SetHeight(430)
	QuestRewardScrollFrameScrollBar.SetHeight = S.dummy
	QuestRewardScrollFrame:ClearAllPoints()
	QuestRewardScrollFrame:SetPoint('TOPLEFT', QuestFrame, 'TOPLEFT', 10, -30)
	QuestRewardScrollFrame:StripTextures()
	QuestRewardScrollFrameScrollBar:SkinScrollBar(21)
	QuestRewardScrollFrameScrollBar:SetPoint('BOTTOMLEFT', QuestProgressScrollFrame, 'BOTTOMRIGHT', 6, 13)

	QuestFrameAcceptButton:SkinButton()
	QuestFrameAcceptButton:ClearAllPoints()
	QuestFrameAcceptButton:SetPoint('BOTTOMLEFT', QuestFrame, 'BOTTOMLEFT', 10, 10)
	QuestFrameDeclineButton:SkinButton()
	QuestFrameDeclineButton:ClearAllPoints()
	QuestFrameDeclineButton:SetPoint('LEFT', QuestFrameAcceptButton, 'RIGHT', off, 0)

	QuestFrameCompleteQuestButton:SkinButton()
	QuestFrameCompleteQuestButton:ClearAllPoints()
	QuestFrameCompleteQuestButton:SetPoint('BOTTOMLEFT', QuestFrame, 'BOTTOMLEFT', 10, 10)
	QuestFrameCompleteButton:SkinButton()
	QuestFrameCompleteButton:ClearAllPoints()
	QuestFrameCompleteButton:SetPoint('BOTTOMLEFT', QuestFrame, 'BOTTOMLEFT', 10, 10)
	QuestFrameGoodbyeButton:SkinButton()
	QuestFrameGoodbyeButton:ClearAllPoints()
	QuestFrameGoodbyeButton:SetPoint('LEFT', QuestFrameCompleteButton, 'RIGHT', off, 0)


	local SIZE = 19 -- just a variable for consistency between the frames below

	QuestFramePortrait:Kill()
	QuestFramePortraitFrame = CreateFrame('frame', nil, QuestFrame)
	QuestFramePortraitFrame.model = CreateFrame('PlayerModel', nil, QuestFramePortraitFrame)
	QuestFramePortraitFrame:SetSize(64, SIZE)
	QuestFramePortraitFrame:SetTemplate()
	QuestFramePortraitFrame.model:SetInside(QuestFramePortraitFrame)
	QuestFramePortraitFrame.model:SetPoint('BOTTOM', 0, 2)
	QuestFramePortraitFrame:SetPoint('BOTTOMLEFT', QuestFrameInset, 'TOPLEFT', 0, off)

	QuestFrameCloseButton:SkinButton(false, 'X')
	QuestFrameCloseButton:ClearAllPoints()
	QuestFrameCloseButton:SetPoint('BOTTOMRIGHT', QuestDetailScrollFrameScrollBarScrollUpButton, 'TOPRIGHT', 0, off)
	QuestFrameCloseButton:SetSize(SIZE, SIZE)

	QuestLogDetailFrameCloseButton:SkinButton(false, 'X')
	QuestLogDetailFrameCloseButton:ClearAllPoints()
	QuestLogDetailFrameCloseButton:SetPoint('BOTTOMRIGHT', QuestDetailScrollFrameScrollBarScrollUpButton, 'TOPRIGHT', 0, off)
	QuestLogDetailFrameCloseButton:SetSize(SIZE, SIZE)

	QuestNpcNameFrame:ClearAllPoints()
	QuestNpcNameFrame:SetHeight(SIZE)
	QuestNpcNameFrame:SetPoint('LEFT', QuestFramePortraitFrame, 'RIGHT', S.borderinset, 0)
	QuestNpcNameFrame:SetPoint('RIGHT', QuestFrameCloseButton, 'LEFT', -S.borderinset, 0)
	QuestNpcNameFrame:SetTemplate()

	hooksecurefunc('QuestFrameProgressItems_Update', SkinQuestProgressFrame)
	hooksecurefunc("QuestInfo_Display", FixQuestInfoText)
	hooksecurefunc('QuestLog_Update', FixScrollFrameButtons)
	hooksecurefunc('QuestFrame_SetPortrait', UpdatePortrait)
end