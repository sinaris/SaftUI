local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local CHT = S:NewModule('Chat', 'AceEvent-3.0')

CHT.Panels = {}

function CHT:GetChannelHash()
	local hash = { [0] = 'None' } -- 0 for no right chat
	for i = 2, NUM_CHAT_WINDOWS do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i)

		if shown or docked then hash[i] = name end
	end
	return hash
end

function CHT:CreatePanels()
	for i,name in pairs({'Left', 'Right'}) do
		local panel = CreateFrame('Frame', 'SaftUI_ChatPanel'..name, UIParent)
		panel:SetFrameStrata('BACKGROUND')

		-- S:RegisterMover(panel)
	
		local TabBG = CreateFrame('Frame', panel:GetName() .. '_TabsBG', panel)
		TabBG:SetFrameStrata('BACKGROUND')
		TabBG:SetFrameLevel(panel:GetFrameLevel()+2)
		TabBG:SetPoint('TOP', panel, 'TOP', 0, -6)
		panel.TabBG = TabBG

		self.Panels[name] = panel
	end
end

function CHT:UpdatePanels()
	local gCon = S.Saved.profile.Chat

	for i,side in pairs({'Left', 'Right'}) do
		local sCon = gCon[side]

		local panel = self.Panels[side]
		panel:ClearAllPoints()
		panel:SetPoint(unpack(sCon.point))

		panel:SetFrameLevel(sCon.framelevel)
		panel.TabBG:SetFrameLevel(sCon.framelevel+1)

		panel:SetSize(sCon.width, sCon.height)
		panel.TabBG:SetSize(sCon.width-12,20)

		panel:SetTemplate(sCon.backdrop and 'TS' or 'N')
		panel.TabBG:SetTemplate(sCon.tabbackdrop and '' or 'N')

		if side == 'Right' then
			local frame = _G['ChatFrame'..gCon.rightchat]
			if frame then
				frame:SetFrameLevel(sCon.framelevel+2)
				if frame.editbox then
					frame.editbox.backdrop:SetTemplate(sCon.backdrop and '' or 'N')
				end
			end
		else
			for i, frameName in pairs(CHAT_FRAMES) do
				if i ~= tonumber(gCon.rightchat) then
					local frame = _G[frameName]
					frame:SetFrameLevel(sCon.framelevel+2)
					if frame.editbox then
						frame.editbox.backdrop:SetTemplate(sCon.backdrop and '' or 'N')
					end
				end
			end
		end
	end

	for i=1, NUM_CHAT_WINDOWS do
		local frame = _G['ChatFrame'..i]

		local panel = S.Saved.profile.Chat.rightchat == i and self.Panels.Right or self.Panels.Left
		
		local width = panel:GetWidth()-12
		local height = panel:GetHeight()-panel.TabBG:GetHeight()-18


		frame:SetParent(panel)
		frame:SetMinResize(100,40)
		frame:SetSize(width, height)
		SetChatWindowSavedDimensions(i, width, height)
		FCF_SavePositionAndDimensions(frame)
	end
end

function CHT:PositionChatFrame(frameIndex)
	if not frameIndex then 
		for i=1, NUM_CHAT_WINDOWS do
			self:PositionChatFrame(frameIndex)
		end
	end

	local frame = _G['ChatFrame'..frameIndex]

	--Only update if frame exists and it shown
	if not (frame and frame:IsShown()) then return end

	local gCon = S.Saved.profile.Chat
	local panel = gCon.rightchat == frameIndex and self.Panels.Right or self.Panels.Left
	local tabFading = not (gCon.rightchat == frameIndex and gCon.Right.background or gCon.Left.background)
	
	local width = panel:GetWidth()-12
	local height = panel:GetHeight()-panel.TabBG:GetHeight()-18


	frame:SetParent(panel)
	frame:SetMinResize(100,40)
	frame:SetSize(width, height)
	frame:ClearAllPoints()
	frame:SetPoint('BOTTOM', panel, 'BOTTOM', 0, 8)
	local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(frameIndex);

	if gCon.rightchat == frameIndex then
		FCF_UnDockFrame(frame)
	elseif frameIndex > 1 and shown then
		FCF_DockFrame(frame)
	end

	SetChatWindowSavedDimensions(frameIndex, width, height)
	FCF_SavePositionAndDimensions(frame)
end

function CHT:InitializeChatFrames()
	local gCon = S.Saved.profile.Chat

	-- FCF_ResetChatWindows()

	for i=1, NUM_CHAT_WINDOWS do
		self:PositionChatFrame(i)
		self:SkinChatFrame(_G['ChatFrame'..i])
	end

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
end

function CHT:SkinChatFrame(frame)
	if frame.SKINNED then return end

	local ID = frame:GetID()
	local name = frame:GetName()
	local tab = _G[name.."Tab"]
	local editbox = _G[name.."EditBox"]

	--Store it for easier access elsewhere
	frame.tab, frame.editbox = tab, editbox
   	editbox.header = _G[name..'EditBoxHeader']
	tab.text = _G[name.."TabText"]
		
	frame:SetFading(false)
	frame:SetClampRectInsets(0,0,0,0)
	frame:SetClampedToScreen(false)
	frame:StripTextures()

	FCF_SetChatWindowFontSize(nil, frame, S.Saved.profile.General.Fonts.chat[2])
	frame.tab.text:SetFontTemplate(S.Saved.profile.Chat.pixelfonttab and 'pixel' or 'general')
	frame.tab.text.SetFont = S.dummy
	-- frame.tab:SetScript('OnEnter', function(self) self.text:SetFontTemplate(S.Saved.profile.Chat.pixelfonttab and 'pixel' or 'general') end)
	-- frame.tab:SetScript('OnLeave', function(self) self.text:SetFontTemplate(S.Saved.profile.Chat.pixelfonttab and 'pixel' or 'general') end)
	frame:SetFontTemplate('chat', S.Saved.profile.Chat.shadows)
	frame.editbox:SetFontTemplate('chat', S.Saved.profile.Chat.shadows)
	frame.editbox.header:SetFontTemplate('chat', S.Saved.profile.Chat.shadows)


	tab:SetAlpha(1)
	tab.SetAlpha = UIFrameFadeRemoveFrame

	tab:StripTextures()
	tab:HookScript("OnClick", function() frame.editbox:Hide() end) -- hide edit box every time we click on a frame.tab
	if frame.tab.conversationIcon then frame.tab.conversationIcon:Kill() end -- bubble tex & glow killing from privates

	_G[format("ChatFrame%sButtonFrameUpButton", ID)]:Kill()
	_G[format("ChatFrame%sButtonFrameDownButton", ID)]:Kill()
	_G[format("ChatFrame%sButtonFrameBottomButton", ID)]:Kill()
	_G[format("ChatFrame%sButtonFrameMinimizeButton", ID)]:Kill()
	_G[format("ChatFrame%sButtonFrame", ID)]:Kill()

	local a, b, c = select(6, frame.editbox:GetRegions()); a:Kill(); b:Kill(); c:Kill()
	_G[format("ChatFrame%sEditBoxFocusLeft", ID)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusMid", ID)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusRight", ID)]:Kill()

	-- editbox:ClearAllPoints()
	editbox:SetInside(self.Panels.Left.TabBG)
	editbox:CreateBackdrop()
	editbox.backdrop:SetFrameStrata("LOW")
	editbox.backdrop:SetFrameLevel(1)

	editbox:SetAltArrowKeyMode(false)

	editbox:Hide()
	editbox:HookScript("OnEditFocusLost", function(self) self:Hide() end)-- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style	

	frame.SKINNED = true
end

function CHT:OnInitialize()
	self:CreatePanels()
	ChatFontNormal = S.FontObjects.chat
end

function CHT:OnEnable()
	-- Kill stuff
	ChatConfigFrameDefaultButton:Kill()
	ChatFrameMenuButton:Kill()
	FriendsMicroButton:Kill()

	BNToastFrame:SetTemplate('KT')
	BNToastFrame:SetPoint('BOTTOMLEFT', self.Panels.Left, 'TOPLEFT', 0, 4)
	hooksecurefunc('BNToastFrame_UpdateAnchor', function() BNToastFrame:ClearAllPoints(); BNToastFrame:SetPoint('BOTTOMLEFT', self.Panels.Left, 'TOPLEFT', 0, 4) end)
	BNToastFrameCloseButton:SkinCloseButton()

	self:UpdatePanels()
	self:InitializeChatFrames()
	self:UpdatePanels() --call it once more to fix editbox (need to find a better way to do this)

	--Silence the respec spam
	self:RegisterEvent('UNIT_SPELLCAST_START', 'SetRespecState')
	self:RegisterEvent('UNIT_SPELLCAST_STOP', 'SetRespecState')
end