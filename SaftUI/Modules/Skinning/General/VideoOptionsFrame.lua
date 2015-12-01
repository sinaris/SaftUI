local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

S:GetModule('Skinning').GeneralSkins['VideoOptionsFrame'] = function()
	VideoOptionsFrame:SetMovable(true)
	VideoOptionsFrame:SetScript('OnMouseDown', function(self) self:StartMoving() end)
	VideoOptionsFrame:SetScript('OnMouseUp', function(self) self:StopMovingOrSizing() end)

	local FramesToSkin = {
		['VideoOptionsFrame'] = 'TS',
		['VideoOptionsFrameCategoryFrame'] = '',
		['VideoOptionsFramePanelContainer'] = '',
		['AudioOptionsSoundPanelVolume'] = '',
		['AudioOptionsSoundPanelHardware'] = '',
		['AudioOptionsSoundPanelPlayback'] = '',
		['AudioOptionsVoicePanelTalking'] = '',
		['AudioOptionsVoicePanelBinding'] = '',
		['AudioOptionsVoicePanelListening'] = '',
	}

	for frameName, mods in pairs(FramesToSkin) do
		local frame = _G[frameName]
		if not frame then return end
		frame:SetTemplate((mods or '') .. 'K')
	end

	for _,btn in pairs({
		VideoOptionsFrameApply,
		VideoOptionsFrameCancel,
		VideoOptionsFrameOkay,
		VideoOptionsFrameDefaults,
	}) do btn:SkinButton() end
	

	VideoOptionsFrameApply:SetFrameLevel(3)
	Graphics_RightQuality:Kill() --What the fuck is this frame even for?
end
