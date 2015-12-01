local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local NP = S:NewModule('Nameplates', 'AceHook-3.0')
local LNP = LibStub('LibNameplate-1.0')
local oUF = S:GetModule('UnitFrames').oUF or oUF

local childCount = 0
-- local lastUpdate = 0
local updateInterval = 0.2

local NP_WIDTH, NP_HEIGHT = 150, 19
NP.Plates = {}

function NP:ScanForNameplates(self, elapsed)
	--Make sure to only do this if more nameplates are found
	local newChildCount = WorldFrame:GetNumChildren()
	if newChildCount ~= childCount then
		childCount = newChildCount

		for _,frame in pairs({WorldFrame:GetChildren()}) do
			if (not frame.IsSkinned) and strmatch(frame:GetName() or '', 'NamePlate%d+') then
				NP:ConstructNameplate(frame)
			end
		end
	end

	-- lastUpdate = lastUpdate + elapsed
	-- if (lastUpdate > updateInterval) then
	-- 	lastUpdate = 0
	-- end
end
	

function NP:OnEnable()
	self.frame = CreateFrame('frame')
	self:HookScript(self.frame, 'OnUpdate', 'ScanForNameplates')
end

local COLORS = {
	['FRIENDLYPLAYER'] = { 0.4, 0.4, 0.6 },
	['HOSTILE']	 = { 0.8, 0.4, 0.4 },
	['NEUTRAL']  = { 0.8, 0.8, 0.4 },
	['FRIENDLY'] = { 0.4, 0.8, 0.4 },
}

local function ColorToString(r,g,b) return "C"..math.floor((100*r) + 0.5)..math.floor((100*g) + 0.5)..math.floor((100*b) + 0.5) end
local ClassReference = {}
do
	for classname, color in pairs(RAID_CLASS_COLORS) do
		local r, g, b = color.r, color.g, color.b
		local colorstring = ColorToString(r, g, b)
		ClassReference[colorstring] = classname
	end
	ClassReference["C010060"] = "MONK"
end

--debug reference for when colors fail
-- for k,v in pairs(ClassReference) do print(v,k) end

--Safely hide old nameplate without damaging information
function NP:StripNameplate(oldplate)
	local mainFrame, nameFrame = oldplate:GetChildren()
	local health, castbar = mainFrame:GetChildren()
	
	local name = nameFrame:GetRegions()
	local threat, hpborder, highlight, level, skullicon, raidicon, eliteicon = mainFrame:GetRegions()
	local castborder, shield, spellicon, castname, castshadow =  select(2, castbar:GetRegions())

	function oldplate:GetUnitInfo()
		local unitlevel = tonumber(level:GetText()) or -1
		local unitname = name:GetText()
		local isElite = eliteicon:IsShown()
		local isBoss = skullicon:IsShown()
		local _, maxHealth = health:GetMinMaxValues()
		return unitname, unitlevel, isElite, isBoss, maxHealth
	end

	function oldplate:GetUnitHealth()
		return health:GetValue()
	end

	function oldplate:GetUnitReaction()
		local red, green, blue = oldplate.health:GetStatusBarColor()
		    if red < .01 and blue < .01 and green > .99 then return "FRIENDLY", "NPC" 
		elseif red < .01 and blue > .99 and green < .01 then return "FRIENDLY", "PLAYER"
		elseif red > .99 and blue < .01 and green > .99 then return "NEUTRAL", "NPC"
		elseif red > .99 and blue < .01 and green < .01 then return "HOSTILE", "NPC"
														else return "HOSTILE", "PLAYER", self:GetClass()
		end
	end

	function oldplate:GetClass()
		local color = ClassReference[ColorToString(health:GetStatusBarColor())]
		-- print(ColorToString(health:GetStatusBarColor()))
		return color or nil
	end

	health:Hide()
	castbar:SetStatusBarTexture(nil)

	threat:SetTexCoord(0, 0, 0, 0)
	hpborder:SetTexCoord(0, 0, 0, 0)
	castborder:SetTexCoord(0, 0, 0, 0)
	shield:SetTexCoord(0, 0, 0, 0)
	skullicon:SetTexCoord(0, 0, 0, 0)
	eliteicon:SetTexCoord(0, 0, 0, 0)
	name:SetWidth(000.1)
	level:SetWidth(000.1)
	castname:Hide() castname.Show = S.dummy
	spellicon:SetTexCoord(0, 0, 0, 0)
	spellicon:SetWidth(.001)
	castshadow:SetTexture('')
	highlight:SetTexture('')

	oldplate.health = health
	oldplate.highlight = highlight
	oldplate.castbar = castbar
	oldplate.castbar.name = castname
	oldplate.castbar.shield = shield
	oldplate.skullicon = skullicon
	oldplate.eliteicon = eliteicon
end

function NP:DisplayNameplate(oldplate)
	self:SecureHookScript(oldplate, 'OnUpdate', 'UpdateNameplate')
end

function NP:HideNameplate(oldplate)
	self:Unhook(oldplate, 'OnUpdate')
end

function NP:GetLevelString(level, elite, boss)
	level = tonumber(level)
	local color = GetQuestDifficultyColor(level > 0 and level or 9999)

	--Don't show level if it's the same as the player's level
	if level == UnitLevel('player') then
		return ''
	end

	--Add appropriate mob classifications
	if boss or level == -1 then level = "??" end	
	if elite then level = level .. "+" end

	return F:ColorString(level, color.r, color.g, color.b)
end

function NP:UpdateNameplate(oldplate, elapsed)
	local unitname, unitlevel, isElite, isBoss, maxHealth = oldplate:GetUnitInfo()
	local nameplate = self.Plates[oldplate.ID]
	local unithealth = oldplate:GetUnitHealth()

	-- nameplate.NameText:SetFormattedText('%s %s', self:GetLevelString(unitlevel, isElite, isBoss), unitname)
	nameplate.NameText:SetText(unitname)
	nameplate.LevelText:SetText(self:GetLevelString(unitlevel, isElite, isBoss))
	nameplate.HealthBar:SetMinMaxValues(0, maxHealth)
	nameplate.HealthBar:SetValue(unithealth)

	nameplate.HealthText:SetText(F:ShortFormat(unithealth))

	local reaction, unittype, class = oldplate:GetUnitReaction()
	local classColor = oUF.colors.class[class]
	if classColor then
		nameplate.HealthBar:SetStatusBarColor(unpack(classColor))
	else
		local hpcolor = COLORS[reaction..unittype] or COLORS[reaction]
		nameplate.HealthBar:SetStatusBarColor(unpack(hpcolor))
	end
end

function NP:DisplayCastbar(oldplate)
	self.Plates[oldplate.ID].Castbar:Show()
	self:SecureHookScript(oldplate.castbar, 'OnValueChanged', 'UpdateCastbar')

	local castbar = self.Plates[oldplate.ID].Castbar
	if oldplate.castbar.shield:IsShown() then
		castbar:SetStatusBarColor(unpack(S.Saved.profile.UnitFrames.Units.player.castbar.altcolor))
	else
		castbar:SetStatusBarColor(unpack(S.Saved.profile.UnitFrames.Units.player.castbar.color))
	end

end

function NP:HideCastbar(oldplate)
	self.Plates[oldplate.ID].Castbar:Hide()
	self:Unhook(oldplate.castbar, 'OnValueChanged')
end

function NP:UpdateCastbar(oldcastbar)
	local oldplate = oldcastbar:GetParent():GetParent()
	local castbar = self.Plates[oldplate.ID].Castbar
	castbar:SetMinMaxValues(oldcastbar:GetMinMaxValues())
	castbar:SetValue(oldcastbar:GetValue())
	castbar.NameText:SetText(oldcastbar.name:GetText())
end

--Construct a new nameplate to latch onto the old one
function NP:ConstructNameplate(oldplate)
	
	self:StripNameplate(oldplate)

	local ID = strmatch(oldplate:GetName(), '%d+')

	local nameplate = CreateFrame('frame', 'SaftUI_Nameplate'..ID, oldplate)
	nameplate:SetScale(UIParent:GetScale())
	nameplate:SetSize(NP_WIDTH, NP_HEIGHT-6)
	nameplate:SetPoint('CENTER', oldplate, 'CENTER', 0, 0)
	nameplate:SetFrameLevel(4)
	nameplate:SetTemplate('')

	oldplate.ID = ID
	nameplate.ID = ID

	local nametext = S.CreateFontString(nameplate, 'pixel')
	nametext:SetPoint('LEFT', nameplate, 5, 0)
	nametext:SetPoint('RIGHT', nameplate, -2, 0)
	nametext:SetJustifyH('LEFT')
	nameplate.NameText = nametext
	
	local leveltext = S.CreateFontString(nameplate, 'pixel')
	leveltext:SetPoint('RIGHT', nameplate, 'LEFT', -2, 0)
	nameplate.LevelText = leveltext

	local healthtext = S.CreateFontString(nameplate, 'pixel')
	healthtext:SetPoint('RIGHT', nameplate, -2, 0)
	nameplate.HealthText = healthtext

	local healthbar = S.CreateStatusBar(nameplate, nameplate:GetName()..'HealthBar')
	healthbar:SetSize(NP_WIDTH-2, NP_HEIGHT)
	healthbar:SetPoint('CENTER')
	healthbar:SetFrameLevel(3)
	healthbar:CreateBackdrop('TS')
	nameplate.HealthBar = healthbar

	local castbar = S.CreateStatusBar(nameplate, nameplate:GetName()..'CastBar')
	castbar:SetSize(NP_WIDTH-2, NP_HEIGHT-8)
	castbar:CreateBackdrop('TS')
	castbar:Hide()
	castbar:SetPoint('TOP', healthbar, 'BOTTOM', 0, -3)
	local castname = S.CreateFontString(castbar, 'pixel')
	castname:SetPoint('LEFT', 5, 0)
	castbar.NameText = castname

	nameplate.Castbar = castbar

	self.Plates[ID] = nameplate

	self:UpdateNameplate(oldplate)

	oldplate.castbar:HookScript('OnShow', function(self) NP:DisplayCastbar(oldplate) end)
	oldplate.castbar:HookScript('OnHide', function(self) NP:HideCastbar(oldplate) end)

	oldplate.health:HookScript('OnValueChanged', function(self) NP:UpdateNameplate(oldplate) end)
	self:SecureHookScript(oldplate, 'OnShow', 'DisplayNameplate')
	self:SecureHookScript(oldplate, 'OnHide', 'HideNameplate')

	oldplate.IsSkinned = true
end