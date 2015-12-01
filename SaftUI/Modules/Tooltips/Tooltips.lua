local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local TT = S:NewModule('Tooltips')
local INV = S:GetModule('Inventory')
local CHT = S:GetModule('Chat')

TT.AllTooltips = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3
}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}

local function UpdateTooltipPosition(self)
	if self:GetAnchorType() == "ANCHOR_NONE" then
		self:ClearAllPoints()
		
		if INV.BagFrame and INV.BagFrame:IsShown() then
			self:SetPoint('TOPRIGHT', INV.BagFrame, 'TOPLEFT', -3, 0)
		else
			self:SetPoint('BOTTOMRIGHT', CHT.Panels.Right, 'TOPRIGHT', 0, 36)
		end
	end
end
GameTooltip:HookScript("OnUpdate", function(self, ...) UpdateTooltipPosition(self) end)

local function SetTooltipDefaultAnchor(self, parent)
	self:SetOwner(parent, "ANCHOR_NONE")
	self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -111111, -111111) -- hack to update GameStatusBar instantly.
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", SetTooltipDefaultAnchor)

local function OnTooltipSetUnit(self)
	local lines = self:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	
	-- A mage's mirror images sometimes doesn't return a unit, this would fix it
	unit = unit or UnitExists('mouseover') and 'mouseover'
	
	-- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
	if not unit then self:Hide() return end
		
	-- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
	if (UnitIsUnit(unit,"mouseover")) then unit = 'mouseover' end

	local race = UnitRace(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guild, guildRank = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)
	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = '|cff' .. (S.GetUnitColor(unit) or 'ffffff')
	-- if not color then color = "FFFFFF" end -- just safe mode for when GetColor(unit) return nil for unit too far away

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name or '', realm and realm ~= "" and " - "..realm.."|r" or "|r")

	if (UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guild then
			local guildName = IsInGuild() and GetGuildInfo("player") == guild and "|cff0090ff"..guild.."|r" or "|cff00ff10"..guild.."|r"
			_G["GameTooltipTextLeft2"]:SetFormattedText("%s (%s)", guildName, guildRank)
			offset = offset + 1
		end

		for i= offset, lines do
			if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level > 0 and level or "??", race, color, class.."|r")
				break
			end
		end
	else
		for i = 2, lines do
			if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				if level == -1 and classif == "elite" then classif = "worldboss" end
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level ~= 0 and level or "", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	local pvpLine
	for i = 1, lines do
		local text = _G["GameTooltipTextLeft"..i]:GetText()
		if text and text == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end

	-- ToT line
	local totName = UnitName(unit..'target')
	if totName then
		if totName == S.myname then
			totName = format('|cff%sYOU|r', F:ToHex(.8, .3, .3))
		else
			local hex, r, g, b = S.GetUnitColor(unit.."target")
			totName = format('|cff%s%s|r', hex or 'ffffff', totName)
		end
		GameTooltip:AddLine(format('Targetting %s', totName))
	end
end
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

local function SkinFriendsTooltip()
FriendsTooltip:SetTemplate()


	local lines = {
		_G['FriendsTooltipToon1Info'],
		_G['FriendsTooltipToon1Name'],
		_G['FriendsTooltipNoteText'],
		_G['FriendsTooltipBroadcastText'],
		_G['FriendsTooltipHeader'],
		_G['FriendsTooltipLastOnline'],
	}
	for _,line in pairs(lines) do
		if line then
			line:SetFontTemplate()
		end
	end
end

local function SkinTooltip(self)
	local name = self:GetName()
	for i=1, self:NumLines() do
		local left = _G[format('%sTextLeft%d', name, i)]
		local right = _G[format('%sTextRight%d', name, i)]

		-- if right then right:SetFontTemplate() end
		-- if left then left:SetFontTemplate() end
	end

	if _G[name..'MoneyFrame1'] then
		_G[name..'MoneyFrame1PrefixText']:SetFontTemplate()
		_G[name..'MoneyFrame1SuffixText']:SetFontTemplate()
		_G[name.."MoneyFrame1GoldButtonText"]:SetFontTemplate()
		_G[name.."MoneyFrame1SilverButtonText"]:SetFontTemplate()
		_G[name.."MoneyFrame1CopperButtonText"]:SetFontTemplate()
	end

	self:SetTemplate('TS')
	-- TT:SetBorderColor(self)
end

local function SkinHealthBar()
	local health = GameTooltipStatusBar
	health:CreateBackdrop()
	health:SetBarTemplate()
	health:SetHeight(6)
	health:ClearAllPoints()
	health:SetStatusBarColor(0.2, 0.2, 0.2)
	health:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", S.borderinset, 5)
	health:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -S.borderinset, 5)
	GameTooltip.health = health
end

function TT:OnEnable()
		SkinHealthBar() --health bar on GameTooltip

		for _, tip in pairs(self.AllTooltips) do
			tip:HookScript("OnShow", SkinTooltip)

			--Stat comparisons
			if tip.SetHyperlinkCompareItem then
				hooksecurefunc(tip, 'SetHyperlinkCompareItem', SkinTooltip)
			end
		end

		hooksecurefunc('GameTooltip_OnTooltipAddMoney', SkinTooltip)
		
		ItemRefTooltip:HookScript("OnTooltipSetItem", SkinTooltip)
		ItemRefTooltip:HookScript("OnShow", SkinTooltip)	
		
		SkinFriendsTooltip()
end