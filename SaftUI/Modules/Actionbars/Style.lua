local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LAB = LibStub("LibActionButton-1.0")
local gsub = string.gsub

local AB = S:GetModule('ActionBars')

AB.Hotkeys = {
	['SHIFT%-']			= 'S',
	['CTRL%-']			= 'C',
	['ALT%-']			= 'A',
	['MOUSEBUTTON']		= 'M',
	['BUTTON']			= 'M',
	['MIDDLEMOUSE']		= 'M3',
	['MOUSEWHEELUP']	= 'MU',
	['MOUSEWHEELDOWN']	= 'MD',
	['NUMPAD']			= 'N',
	['PAGEUP']			= 'PU',
	['PAGEDOWN']		= 'PD',
	['SPACEBAR']		= 'SpB',
	['INSERT']			= 'Ins',
	['HOME']			= 'Hm',
	['DELETE']			= 'Del',
	['NMULTIPLY']		= "*",
	['NMINUS']			= "N-",
	['NPLUS']			= "N+",
}

function AB.FixKeybind(self)
	local hotkey = self.hotkey
	local text = hotkey:GetText();
	
	if not text then return end
	
	for key,val in pairs(AB.Hotkeys) do
		text = gsub(text, key, val)
	end
	
	hotkey:SetText(text)
end


function AB:SkinActionButton(self)
	local name = self:GetName()

	local border  = _G[name..'Border']
	local shine = _G[name..'Shine']
	local float = _G[name..'FloatingBG']
	local fontStyle = S.Saved.profile.ActionBars.pixelfont and 'pixel' or 'general'

	if self.count then
		self.count:SetFontTemplate(fontStyle)
		self.count:ClearAllPoints()
		self.count:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 1, 1)
	end

	if self.hotkey then
		self.hotkey:SetFontTemplate(fontStyle)
		self.hotkey:ClearAllPoints()
		self.hotkey:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 1, 0)
	end
	
	if self.macro then 
		self.macro:SetFontTemplate(fontStyle)
		self.macro:ClearAllPoints()
		self.macro:SetPoint('BOTTOM', 0, 2)
	end

	if self.icon then self.icon:SetInside() end

	if not self.isSkinned then
		self:SetNormalTexture('')
		if self.normalTexture then self.normalTexture:SetTexture(nil); self.normalTexture:Kill(); self.normalTexture:SetAlpha(0) end
		if self.border then self.border:Kill() end
		if self.flash then self.flash:SetTexture(nil) end
		if float then float:SetTexture(nil) end
		if shine then shine:SetAllPoints() end

		
		if self.icon then self.icon:SetTexCoord(.08,.92,.08,.92); self.icon:SetDrawLayer('BACKGROUND', 1) end

		self:SkinActionButton()
		
		self.isSkinned = true
	end
end