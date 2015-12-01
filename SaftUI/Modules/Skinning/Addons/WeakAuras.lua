local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat


local function SkinIcon(parent, region, data)
	if not region.backdrop then
		region:CreateBackdrop()
		-- hooksecurefunc(region.icon, 'SetAlpha', function(self, ...) selS.backdrop:SetAlpha(...) end)
		region.icon:SetTexCoord(unpack(S.iconcoords))
		region.icon.SetTexCoord = S.dummy
		region.stacks:SetFontTemplate('pixel')
	end
end

S:GetModule('Skinning').AddonSkins['WeakAuras'] = function()
	hooksecurefunc(WeakAuras.regionTypes.icon, 'modify', SkinIcon)
end