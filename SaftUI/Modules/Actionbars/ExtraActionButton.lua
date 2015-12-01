local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local AB = S:GetModule('ActionBars')

function AB:SetupExtraButton()
	local holder = CreateFrame('Frame', nil, UIParent)
	holder:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 150)
	holder:SetSize(ExtraActionBarFrame:GetSize())
	
	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', holder, 'CENTER')
		
	ExtraActionBarFrame.ignoreFramePositionManager  = true
	
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		if _G["ExtraActionButton"..i] then
			_G["ExtraActionButton"..i].noResize = true;
			_G["ExtraActionButton"..i].pushed = true
			_G["ExtraActionButton"..i].checked = true
			
			self:SkinActionButton(_G["ExtraActionButton"..i], true)
			_G["ExtraActionButton"..i]:SetTemplate()
			_G["ExtraActionButton"..i..'Icon']:SetDrawLayer('ARTWORK')
			local tex = _G["ExtraActionButton"..i]:CreateTexture(nil, 'OVERLAY')
			tex:SetTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			_G["ExtraActionButton"..i]:SetCheckedTexture(tex)
		end
	end
	
	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end
end