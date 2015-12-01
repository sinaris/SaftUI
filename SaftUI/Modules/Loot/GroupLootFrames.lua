local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LT = S:GetModule('Loot')

local q = ITEM_QUALITY_COLORS
local QUALITY_COLORS = {
	[0] = { q[0].r, q[0].g, q[0].b },
	[1] = { q[1].r, q[1].g, q[1].b },
	[2] = { 0.4, 1.0, 0.4 },
	[3] = { 0.2, 0.6, 1.0 },
	[4] = { 0.6, 0.4, 1.0 },
	[5] = { 1.0, 0.6, 0.4 },
	[6] = { q[6].r, q[6].g, q[6].b },
	[7] = { q[7].r, q[7].g, q[7].b },
}

LT.GroupLootFrames = {}
local cancelled_rolls = {}

local barHeight = 25

-- OnUpdate function for frame
function LT:UpdateGroupLootFrame(rollframe, elapsed)

	local timeleft = GetLootRollTimeLeft(rollframe.rollid)
	rollframe.StatusBar:SetValue(timeleft)
	rollframe.TimeText:SetText(F:ToClock(floor(timeleft/1000)))

	if timeleft == 0 then
		self:PurgeGroupLootFrame(rollframe)
	end
end

function LT:GetLootFrameByRollID(rollid)
	for _,frame in pairs(self.GroupLootFrames) do
		if frame.rollid == rollid then return frame end
	end
end

--Make sure the frames are properly purged if a roll is confirmed elsewhere
hooksecurefunc('ConfirmLootRoll', function(rollid, selection)
	local rollframe = LT:GetLootFrameByRollID(rollid)

	if rollframe then
		LT:PurgeGroupLootFrame(rollframe)
	end
end)

function LT:CreateGroupLootFrame()
	local index = #self.GroupLootFrames + 1

	local rollframe = CreateFrame('frame', 'SaftUI_GroupLootFrame'..index, UIParent)
	rollframe:SetID(index)
	rollframe:EnableMouse(true)
	rollframe:SetSize(300, barHeight-6)
	rollframe:SetTemplate()
	rollframe:SetPoint('BOTTOM', index == 1 and self.GroupLootAnchor or self.GroupLootFrames[index-1], 'TOP', 0, S.borderinset + 8)
	LT:HookScript(rollframe, 'OnEnter', 'DisplayItemTooltip')
	LT:HookScript(rollframe, 'OnLeave', 'HideItemTooltip')
	LT:HookScript(rollframe, 'OnMouseDown', 'ClickGroupLootFrame')
	rollframe:SetFrameLevel(5)

	statusbar = S.CreateStatusBar(rollframe)
	statusbar:SetSize(298, barHeight)
	statusbar:SetPoint('CENTER')
	statusbar:SetFrameLevel(4)
	statusbar:CreateBackdrop('T')
	rollframe.StatusBar = statusbar

	--Test values
	statusbar:SetMinMaxValues(0, 1)
	statusbar:SetValue(math.random())
	statusbar:SetStatusBarColor(unpack(QUALITY_COLORS[index]))

	local nametext = S.CreateFontString(rollframe, 'pixel')
	nametext:SetText('Some Shitty Gear of the Owl')
	nametext:SetPoint('LEFT', 5, 0)
	rollframe.NameText = nametext

	local hoverColor = select(4, S.GetColors())

	local buttonsize = rollframe:GetHeight()

	local prev
	for i,table in ipairs({
		[1] = { 'Pass', 'X', {0.8, 0.4, 0.4}, 0 },
		[2]	= { 'Disenchant', 'D', {0.6, 0.4, 0.8}, 3 },
		[3] = { 'Greed', 'G', {0.8, 0.8, 0.0}, 2 },
		[4] = { 'Need', 'N', {0.8, 0.8, 0.8}, 1 },
	}) do
		local button = S.CreateButton(rollframe:GetName()..table[1]..'Button', rollframe, table[2])
		button:SetBackdrop(nil)
		-- local button = _G['GroupLootFrame'..index..table[1]..'Button']
		-- button:SkinButton(nil, table[2])
		button.rollframe = rollframe
		button:SetSize(buttonsize-3, buttonsize)
		button:HookScript('OnEnter', function(self) self.text:SetTextColor(unpack(hoverColor)) end)
		button:HookScript('OnLeave', function(self) self.text:SetTextColor(unpack(table[3])) end)
		button:HookScript('OnDisable', function(self) self:SetAlpha(0.25) end)
		button:HookScript('OnEnable', function(self) self:SetAlpha(1) end)
		button:HookScript('OnClick', function(self)
			-- local _, _, _, _, bop = GetLootRollItemInfo(self.rollid)
			-- if not IsShiftKeyPressed() and bop then end
			local rollframe = self.rollframe
			if rollframe.rollid then ConfirmLootRoll(rollframe.rollid, table[4]) end
			LT:PurgeGroupLootFrame(rollframe)
		end)
		button.text:SetFontTemplate('pixel')
		button.text:SetTextColor(unpack(table[3]))
		if prev then
			button:SetPoint('RIGHT', prev, 'LEFT', -S.borderinset, 0)
		else
			button:SetPoint('RIGHT', rollframe, 'RIGHT', -S.borderinset, 0)
		end
		prev = button
		rollframe[table[1]..'Button'] = button
	end

	local timetext = S.CreateFontString(rollframe, 'pixel')
	timetext:SetText(F:ToClock(floor(math.random()*300)))
	timetext:SetPoint('RIGHT', rollframe.NeedButton, 'LEFT', -S.borderinset, 0)
	rollframe.TimeText = timetext

	self.GroupLootFrames[index] = rollframe

	return rollframe
end

function LT:GetGroupLootFrame()
	--Find the first available loot frame
	for i,rollframe in ipairs(self.GroupLootFrames) do
		if not rollframe.rollid then return rollframe end
	end

	--Create a new one if they're all in use
	return self:CreateGroupLootFrame()
end

function LT:PurgeGroupLootFrame(rollframe)
	rollframe.rollid = nil
	rollframe:Hide()
	self:Unhook(rollframe, 'OnUpdate')
end

function LT:ClickGroupLootFrame(rollframe)
	if IsControlKeyDown() then DressUpItemLink(rollframe.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(rollframe.link) end
end

function LT:DisplayItemTooltip(rollframe)
	if not rollframe.link then return end
	GameTooltip:SetOwner(rollframe, "ANCHOR_TOPLEFT")
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint('BOTTOMRIGHT', rollframe, 'BOTTOMLEFT', -S.borderinset, 0)
	GameTooltip:SetHyperlink(rollframe.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

function LT:HideItemTooltip()
	GameTooltip:Hide()
	ResetCursor()
end


function LT:HandleNewGroupRoll(event, rollid, time)
	if cancelled_rolls[rollid] then return end

	local rollframe = self:GetGroupLootFrame()
	rollframe.rollid = rollid
	rollframe.time = time

	rollframe:Show()

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollid)
	rollframe.link = GetLootRollItemLink(rollid)

	local namestring = name
	if count > 1 then namestring = namestring .. format(' [%d]', count) end
	if bop then namestring = namestring .. ' [BoP]' end
	rollframe.NameText:SetText(namestring)

	if canNeed then rollframe.NeedButton:Enable() else rollframe.NeedButton:Disable() end
	if canGreed then rollframe.GreedButton:Enable() else rollframe.GreedButton:Disable() end
	if canDisenchant then rollframe.DisenchantButton:Enable() else rollframe.DisenchantButton:Disable() end

	rollframe.StatusBar:SetMinMaxValues(0, time)
	rollframe.StatusBar:SetStatusBarColor(unpack(QUALITY_COLORS[quality]))

	self:HookScript(rollframe, 'OnUpdate', 'UpdateGroupLootFrame')	
end

function LT:InitializeGroupLootFrames()
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	self.GroupLootAnchor = CreateFrame('frame', 'SaftUI_GroupLootAnchor', UIParent)
	self.GroupLootAnchor:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 200)
	self.GroupLootAnchor:SetSize(300, 20)
	-- self.GroupLootAnchor:SetTemplate()

	-- self:RegisterEvent('START_LOOT_ROLL')
	-- self:SecureHook('START_LOOT_ROLL', HandleNewGroupRoll)
end