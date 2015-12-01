local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local UF = S:GetModule('UnitFrames')
local oUF = UF.oUF

------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

for i=1, 30 do
	oUF.Tags.Events['name:'..i] = 'UNIT_NAME_UPDATE'
	oUF.Tags.Methods['name:'..i] = function(unit)
		if not (unit and UnitName(unit)) then return end
		return F:UTF8strsub(UnitName(unit), i)
	end
end

oUF.Tags.Events['geniuslevel'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
oUF.Tags.Methods['geniuslevel'] = function(unit)
	local level = UnitLevel(unit)
	local color = GetQuestDifficultyColor(level > 0 and level or 9999)
	if level < 0 then level = "??" end

	local unitClass = UnitClassification(u)
	local c = ''
	if(unitClass == 'rare') then
		c = 'R'
	elseif(unitClass == 'eliterare') then
		c = 'R+'
	elseif(unitClass == 'elite') then
		c = '+'
	elseif(unitClass == 'worldboss') then
		c = 'B'
	end

	return F:ColorString(level .. c, color.r, color.g, color.b)
	-- return format('|cff%02x%02x%02x%d%s|r', r*255, g*255, b*255, level, c)
end