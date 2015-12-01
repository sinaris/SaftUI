local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local function SkinDropDownList(level, index)
	for i = 1, UIDROPDOWNMENU_MAXLEVELS do
		local menubackdrop = _G["DropDownList"..i.."MenuBackdrop"]
		if menubackdrop and not menubackdrop.isSkinned then
			menubackdrop:SetTemplate("T")
			menubackdrop.isSkinned = true
		end
		
		local backdrop = _G["DropDownList"..i.."Backdrop"]
		if backdrop and not backdrop.isSkinned then
			backdrop:SetTemplate("T")
			backdrop.isSkinned = true
		end
	end
end

S:GetModule('Skinning').GeneralSkins['DropDownList'] = function()
	hooksecurefunc("UIDropDownMenu_CreateFrames", SkinDropDownList)
end

