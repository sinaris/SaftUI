local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')
local CHT = S:GetModule('Chat')

local function SetConfig()
	Recount.db.profile.MainWindow.ShowScrollbar = false
	Recount.db.profile.BarTexture = S.Saved.profile.General.barTexture
	Recount.db.profile.Font = S.Saved.profile.General.Fonts.pixel

end

local function SkinMainWindow()
	Recount.MainWindow:SetTemplate('TS')

	Recount.MainWindow:ClearAllPoints()

	Recount.MainWindow.Title:ClearAllPoints()
	Recount.MainWindow.Title:SetPoint('TOPLEFT', 6, -6)

	Recount.MainWindow.CloseButton:ClearAllPoints()
	Recount.MainWindow.CloseButton:SetPoint('TOPRIGHT', -2, -2)

	Recount.MainWindow:SetInside(CHT.Panels.Right, S.Saved.profile.Chat.Right.background and 6 or 0)
	Recount:LockWindows(true)
	
	local offs = Recount.db.profile.MainWindow.HideTotalBar and 1 or 0
	local rowheight = Recount.db.profile.MainWindow.RowHeight
	local rowspacing = Recount.db.profile.MainWindow.RowSpacing
	for i,row in pairs(Recount.MainWindow.Rows) do
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT",Recount.MainWindow,"TOPLEFT", 2, -(10+(rowheight+rowspacing)*(i-1+offs)) )
	end

	function Recount:SetFont()
		for _,row in pairs(Recount.MainWindow.Rows) do
			row.LeftText:SetFontTemplate('pixel')
			row.RightText:SetFontTemplate('pixel')
		end

		Recount.MainWindow.Title:SetFontTemplate()
	end

end



S:GetModule('Skinning').AddonSkins['Recount'] = function()
	SetConfig()

	Recount:UpdateBarTextures()
	Recount:ResizeMainWindow()
	SkinMainWindow()
end


