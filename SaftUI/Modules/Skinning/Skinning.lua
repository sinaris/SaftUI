local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local SK = S:NewModule('Skinning', 'AceHook-3.0', 'AceEvent-3.0')

SK.AddonSkins = {}
SK.Skinned = {} --store skinned addons here
SK.GeneralSkins = {} --deprecated
SK.FrameSkins = {}

SK.UI_PANEL_HEIGHT = 442

function SK:SkinAddon(event, addon)
	if self.AddonSkins[addon] then
		self.AddonSkins[addon]()
		self.Skinned[addon] = true
	end
end

function SK:SkinFrames()

	for _,func in pairs(self.GeneralSkins) do func() end

	for i=1, GetNumAddOns() do
		addon = GetAddOnInfo(i)
		local loaded = IsAddOnLoaded(addon)
		if self.AddonSkins[addon] and loaded then
			self.AddonSkins[addon]()
			self.Skinned[addon] = true
		end
	end
	
	self:UnregisterEvent('PLAYER_ENTERING_WORLD') --Make sure this only runs once
end

SK:RegisterEvent('ADDON_LOADED', 'SkinAddon')
SK:RegisterEvent('PLAYER_ENTERING_WORLD', 'SkinFrames')