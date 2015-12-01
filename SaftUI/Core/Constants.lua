local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

S.dummy = function() end

S.version = tonumber(GetAddOnMetadata(..., 'Version'))
S.name = ...
S.title = GetAddOnMetadata(..., 'Title')
S.buildtext = GetBuildInfo()

S.myname = select(1, UnitName("player"))
S.myclass = select(2, UnitClass("player"))
S.myrace = select(2, UnitRace("player"))
S.myfaction = UnitFactionGroup("player")
S.level = function() return UnitLevel('player') end
S.myrealm = GetRealmName()

S.blanktex = [[Interface\BUTTONS\WHITE8X8]]
S.iconcoords = {.08, .92, .08, .92}
S.borderinset = 1
S.backdrop = {
	bgFile = S.blanktex, 
	edgeFile = S.blanktex,
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = 1, right = 1, top = 1, bottom = 1}
}

--resolution information
S.resolution = GetCVar("gxResolution")
S.screenheight = tonumber(string.match(S.resolution, "%d+x(%d+)"))
S.screenwidth = tonumber(string.match(S.resolution, "(%d+)x+%d"))

S.mediapath = format('Interface\\AddOns\\%s\\Media\\', S.name)

FONT_OUTLINE_TYPES = {
	['NONE'] = 'None', 
	['OUTLINE'] = 'Thin Outline', 
	['THICKOUTLINE'] = 'Thick Outline', 
	['MONOCHROME'] = 'Monochrome', 
	['MONOCHROMEOUTLINE'] = 'Monochrome Outline'
}

StaticPopupDialogs["SAFTUI_CONFIGRELOAD"] = {
	text = 'One or more of the changes you have made require a ReloadUI.',
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = false,
}

StaticPopupDialogs["SAFTUI_BINDMODE"] = {
	text = 'Hover and Click brah',
	button1 = 'Save Binds',
	button2 = 'Discard Binds',
	OnAccept = function() S:GetModule('ActionBars'):HoverBind_Disable(true) end,
	OnCancel = function() S:GetModule('ActionBars'):HoverBind_Disable(false) end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = false,
}

function S:GetPointsTable(addBlankSlot, blankLabel)
	local POINTS_TABLE = {
		['TOP'] = 'Top',
		['TOPLEFT'] = 'Top Left',
		['TOPRIGHT'] = 'Top right',
		['BOTTOM'] = 'Bottom',
		['BOTTOMLEFT'] = 'Bottom left',
		['BOTTOMRIGHT'] = 'Bottom right',
		['LEFT'] = 'Left',
		['RIGHT'] = 'Right',
		['CENTER'] = 'Center',
	}

	if addBlankSlot then
		POINTS_TABLE['NONE'] = blankLabel or '-'
	end

	return POINTS_TABLE
end

OPPOSITE_POINTS = {
	['TOP'] = 'BOTTOM',
	['TOPLEFT'] = 'BOTTOMLEFT',
	['TOPRIGHT'] = 'BOTTOMRIGHT',
	['BOTTOM'] = 'TOP',
	['BOTTOMLEFT'] = 'TOPLEFT',
	['BOTTOMRIGHT'] = 'TOPRIGHT',
	['LEFT'] = 'RIGHT',
	['RIGHT'] = 'LEFT',
	['CENTER'] = 'CENTER',
}

S.TEXTURE_PATHS = {
	['mail'] = S.mediapath..'Textures\\mail.tga',
	['cornerbr'] = S.mediapath..'Textures\\cornerarrowbottomright.tga',
	['goldstring'] = S.mediapath..'Textures\\goldstring',
	['search'] = S.mediapath..'Textures\\search'
}