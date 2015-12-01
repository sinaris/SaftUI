local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local MM  = S:GetModule('Minimap')
local XP = S:NewModule('Experience', 'AceHook-3.0', 'AceEvent-3.0')

function XP:CreateExpBar()
	local exp = CreateFrame('Frame', 'SaftUI_ExpBar', UIParent)
	exp:CreateBackdrop()

	S:RegisterMover(exp, 'Experience Bar', self.Config)

	local bar = S.CreateStatusBar(exp)
	bar:SetInside(exp)
	bar:SetStatusBarColor(.6, .3, .8)
	exp.StatusBar = bar

	local rest = S.CreateStatusBar(exp)
	rest:SetInside(exp)
	rest:SetStatusBarColor(.3, .6, .8)	rest:Hide()
	exp.RestBar = rest

	local text = S.CreateFontString(bar)
	text:SetText('0/0')
	text:SetPoint('CENTER')
	exp.Text = text

	exp:SetScript('OnEnter', function() self:OnEnter() end)
	exp:SetScript('OnLeave', function() self:OnLeave() end)
	bar:SetScript('OnEnter', function() self:OnEnter() end)
	bar:SetScript('OnLeave', function() self:OnLeave() end)

	self.ExpBar = exp
end

function XP:UpdateValues()
	local exp = self.ExpBar
	if MAX_PLAYER_LEVEL ~= UnitLevel('player') then
		if not exp:IsShown() then exp:Show() end

		local current, max = UnitXP('player'), UnitXPMax('player')
		local rest = GetXPExhaustion()

		exp.StatusBar:SetMinMaxValues(0, max)
		exp.StatusBar:SetValue(current)

		if rest then
			if not exp.RestBar:IsShown() then exp.RestBar:Show() end
			exp.RestBar:SetMinMaxValues(0, max)
			exp.RestBar:SetValue(current+rest)
		elseif exp.RestBar:IsShown() then
			exp.RestBar:Hide()
		end

		exp.Text:SetFormattedText('%s/%s (%s%%)', F:ShortFormat(current), F:ShortFormat(max), F:Round(current/max*100))
	elseif GetWatchedFactionInfo() then
		if not exp:IsShown() then exp:Show() end

		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep

		exp.StatusBar:SetMinMaxValues(0, max)
		exp.StatusBar:SetValue(current)
		
		local c = FACTION_BAR_COLORS[rank]
		exp.StatusBar:SetStatusBarColor(c.r, c.g, c.b)

		if exp.RestBar:IsShown() then exp.RestBar:Hide(); end

		exp.Text:SetFormattedText('%s/%s (%d%%)', F:ShortFormat(current), F:ShortFormat(max), F:Round(current/max*100))
	else
		if exp:IsShown() then exp:Hide() end
	end
end

function XP:OnEnter()
	if S.Saved.profile.Experience.textvisibility ~= 'NEVER' then
		self.ExpBar.Text:SetAlpha(1)
	end

	if self.ExpBar:GetLeft() > GetScreenWidth()/2 then
		--Right size of screen
		GameTooltip:SetOwner(self.ExpBar, 'ANCHOR_LEFT', -3, -self.ExpBar:GetHeight())
	else
		--Left size of screen
		GameTooltip:SetOwner(self.ExpBar, 'ANCHOR_RIGHT', 3, -self.ExpBar:GetHeight())
	end
	GameTooltip:ClearLines()
	if MAX_PLAYER_LEVEL ~= UnitLevel('player') then
		local current, max = UnitXP('player'), UnitXPMax('player')
		local rest = GetXPExhaustion()

		GameTooltip:AddDoubleLine('Current XP:', format('%s/%s (%s%%)', F:ShortFormat(current), F:ShortFormat(max), F:Round(current/max*100)), nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine('To go:', F:CommaFormat(max-current), nil,nil,nil, 1,1,1)
		if rest then
			GameTooltip:AddDoubleLine('Rested:', format('%s (%s%%)', F:CommaFormat(rest), F:Round(rest/max*100)), nil,nil,nil, 0,.6,1)
		end
	end

	if GetWatchedFactionInfo() then
		--Add a space between exp and rep
		if MAX_PLAYER_LEVEL ~= UnitLevel('player') then GameTooltip:AddLine('  ') end

		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep
		local c = FACTION_BAR_COLORS[rank]

		GameTooltip:AddDoubleLine(name, _G['FACTION_STANDING_LABEL'..rank], nil,nil,nil, c.r, c.g, c.b)
		GameTooltip:AddDoubleLine('Current:', format('%s/%s (%d%%)', F:ShortFormat(current), F:ShortFormat(max), F:Round(current/max*100)), nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine('To go:', F:CommaFormat(max-current), nil,nil,nil, 1,1,1)

	end
	GameTooltip:Show()
end

function XP:OnLeave()
	S.HideGameTooltip()
	if S.Saved.profile.Experience.textvisibility ~= 'ALWAYS' then
		self.ExpBar.Text:SetAlpha(0)
	end
end

--Update position, size, and visibility options
function XP:UpdateDisplay()

	local conf = S.Saved.profile.Experience
	local exp = self.ExpBar

	exp:ClearAllPoints()
	exp:SetPoint(unpack(conf.point))
	exp:SetSize(conf.width, conf.height)

	exp.Text:SetFontTemplate(conf.pixelfont and 'pixel' or 'general')
	exp.Text:SetAlpha(conf.textvisibility == 'ALWAYS' and 1 or 0)

	exp:SetFrameLevel(conf.framelevel)
	exp.RestBar:SetFrameLevel(conf.framelevel+1)
	exp.StatusBar:SetFrameLevel(conf.framelevel+2)

		--update backdrop
	if conf.backdrop.enable then
		exp.backdrop:SetTemplate(conf.backdrop.transparent and 'T' or '')
		exp.backdrop:ClearAllPoints()
		exp.backdrop:SetPoint('TOPLEFT', exp, 'TOPLEFT', -conf.backdrop.insets.left, conf.backdrop.insets.top)
		exp.backdrop:SetPoint('BOTTOMRIGHT', exp, 'BOTTOMRIGHT', conf.backdrop.insets.right, -conf.backdrop.insets.bottom)
	else
		exp.backdrop:SetTemplate('N')
	end

	self:UpdateValues()
end

function XP:OnInitialize()
	self:CreateExpBar()
end

function XP:OnEnable()
	self:UpdateDisplay()--Update it even if disabled in order to not break other frames
	if not S.Saved.profile.Experience.enable then return self:Disable() end
	self:RegisterEvent('PLAYER_LEVEL_UP', 'UpdateValues')
	self:RegisterEvent('UPDATE_EXHAUSTION', 'UpdateValues')
	self:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE', 'UpdateValues')
	self:RegisterEvent('UPDATE_FACTION', 'UpdateValues')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateValues')
	self:RegisterEvent('PLAYER_XP_UPDATE', 'UpdateValues')
	self.ExpBar:Show()
end

function XP:OnDisable()
	self:UnregisterAllEvents()
	self.ExpBar:Hide()
end