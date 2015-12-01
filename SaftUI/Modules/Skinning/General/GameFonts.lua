local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

S:GetModule('Skinning').GeneralSkins['GameFonts'] = function()
	-- local SetFont = function(obj, f, s, o, shadow) obj:SetFont(f,s,o); if shadow then obj:SetShadowOffset(0, 0) end end
	-- local LSM = LibStub('LibSharedMedia-3.0')

	-- local NORMAL     = LSM:Fetch('font', S.Saved.profile.General.Fonts.general[1])
	-- local PIXEL, PIXELFACE, PIXELOUTLINE = S.UnpackFont(S.Saved.profile.General.Fonts.pixel)
	-- local NUMBER     = NORMAL

	-- UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	-- CHAT_FONT_HEIGHTS = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	-- UNIT_NAME_FONT     = NORMAL
	-- NAMEPLATE_FONT     = NORMAL
	-- STANDARD_TEXT_FONT = NORMAL

	-- -- Base fonts
	-- SetFont(GameTooltipHeader,                  NORMAL, 12)
	-- SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 12, "OUTLINE")
	-- SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE")
	-- SetFont(NumberFont_Outline_Large,           NUMBER, 15, "OUTLINE")
	-- SetFont(NumberFont_Outline_Med,             NUMBER, 12, "OUTLINE")
	-- SetFont(NumberFont_Shadow_Med,              NORMAL, 12)
	-- SetFont(NumberFont_Shadow_Small,            NORMAL, 12)
	-- SetFont(QuestFont,                          NORMAL, 14)
	-- SetFont(QuestFont_Large,                    NORMAL, 14)
	-- SetFont(SystemFont_Large,                   NORMAL, 15)
	-- SetFont(SystemFont_Med1,                    NORMAL, 12)
	-- SetFont(SystemFont_Med3,                    NORMAL, 12)
	-- SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, "THICKOUTLINE")
	-- SetFont(SystemFont_Outline_Small,           NUMBER, 12, "OUTLINE")
	-- SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	-- SetFont(SystemFont_Shadow_Med1,             NORMAL, 12)
	-- SetFont(SystemFont_Shadow_Med3,            	NORMAL, 12)
	-- SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, "OUTLINE")
	-- SetFont(SystemFont_Shadow_Small,            NORMAL, 12)
	-- SetFont(SystemFont_Small,                   NORMAL, 12)
	-- SetFont(SystemFont_Tiny,                    NORMAL, 12)
	-- SetFont(Tooltip_Med,                        NORMAL, 12)
	-- SetFont(Tooltip_Small,                      NORMAL, 12)
	-- SetFont(SystemFont_Shadow_Huge1,            NORMAL, 20, "THINOUTLINE")
	-- SetFont(ZoneTextString,                     NORMAL, 32, "OUTLINE")
	-- SetFont(SubZoneTextString,                  NORMAL, 25, "OUTLINE")
	-- SetFont(PVPInfoTextString,                  NORMAL, 22, "THINOUTLINE")
	-- SetFont(PVPArenaTextString,                 NORMAL, 22, "THINOUTLINE")
	-- SetFont(FriendsFont_Normal,                 NORMAL, 12)
	-- SetFont(FriendsFont_Small,                  NORMAL, 12)
	-- SetFont(FriendsFont_Large,                  NORMAL, 14)
	-- SetFont(FriendsFont_UserText,               NORMAL, 12)       
end

