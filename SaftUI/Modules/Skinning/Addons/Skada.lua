local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat


local LSM = LibStub('LibSharedMedia-3.0')
local CHT = S:GetModule('Chat')

local function StripOptions(self, win, options)
	options.titleoptions.args.enable = nil
	options.titleoptions.args.height = nil
	options.titleoptions.args.font = nil
	options.titleoptions.args.fontsize = nil
	options.titleoptions.args.fontflags = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil

	options.windowoptions = nil

	options.baroptions.args.barfont = nil
	options.baroptions.args.barfontsize = nil
	options.baroptions.args.barfontflags = nil
	options.baroptions.args.bartexture = nil
	options.baroptions.args.reversegrowth = nil
	options.baroptions.args.bgcolor = nil
end

local function SkinWindow(self, win)

	local skada = win.bargroup

	-- win.db.barfont, win.db.barfontsize, win.db.barfontflags = unpack(S.Saved.profile.General.Fonts.pixel)
	
	skada:SetTexture(LSM:Fetch('statusbar',S.Saved.profile.General.barTexture))
	skada:SetFrameLevel(15)

	-- title bar
	skada.button:SetNormalFontObject(S.FontObjects.pixel)
	skada.button:SetTemplate('TK')
	skada.button:SetHeight(CHT.Panels.Right.TabBG:GetHeight())

	-- bar window
	skada:SetBackdrop(nil)
	if not skada.backdrop then
		skada:CreateBackdrop('T')
	end

	if S.Saved.profile.Chat.Right.background then
		skada:ClearAllPoints()
		skada:SetPoint('TOPLEFT', CHT.Panels.Right.TabBG, 'BOTTOMLEFT', S.borderinset, -6)
		skada:SetPoint('TOPRIGHT', CHT.Panels.Right.TabBG, 'BOTTOMRIGHT', -S.borderinset, -6)
		skada:SetPoint('BOTTOM', CHT.Panels.Right, 'BOTTOM', 0, 6+S.borderinset)

		skada.button:ClearAllPoints()
		skada.button:SetPoint('BOTTOMLEFT', skada, 'TOPLEFT', -S.borderinset, 6)
		skada.button:SetPoint('BOTTOMRIGHT', skada, 'TOPRIGHT', S.borderinset, 6)
	else
		skada:SetInside(CHT.Panels.Right, S.borderinset)
		skada:SetPoint('TOP', CHT.Panels.Right, 'TOP', 0, -skada.button:GetHeight())

		skada.button:ClearAllPoints()
		skada.button:SetPoint('BOTTOMLEFT', skada, 'TOPLEFT', -S.borderinset, 0)
		skada.button:SetPoint('BOTTOMRIGHT', skada, 'TOPRIGHT', S.borderinset, 0)
	end
end

local function FixBarText(self, win)
	local bars = win.bargroup:GetBars()
	if bars then 
		for _,bar in pairs(bars) do
			bar.label:SetFontTemplate('pixel')
			bar.timerLabel:SetFontTemplate('pixel')
		end
	end
end

S:GetModule('Skinning').AddonSkins['Skada'] = function()
	hooksecurefunc(Skada.displays.bar, 'AddDisplayOptions', StripOptions)
	hooksecurefunc(Skada.displays.bar, 'ApplySettings', SkinWindow)
	hooksecurefunc(Skada.displays.bar, 'Update', FixBarText)
end