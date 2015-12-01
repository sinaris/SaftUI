local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat



if true then return end --http://us.battle.net/wow/en/forum/topic/6607331970#10

S:GetModule('Skinning').GeneralSkins['InterfaceOptionsFrame'] = function()

	hooksecurefunc('BlizzardOptionsPanel_CheckButton_Refresh', function(self) self:SkinCheckBox() end)
	hooksecurefunc('BlizzardOptionsPanel_DropDown_Refresh', function(self) self:SkinDropDown() end)
	hooksecurefunc('BlizzardOptionsPanel_Slider_Refresh', function(self) self:SkinSlider() end)

	InterfaceOptionsFrame:EnableMoving()
	
	local ButtonsToSkin = {
		InterfaceOptionsFrameOkay,
		InterfaceOptionsFrameCancel,
		InterfaceOptionsFrameDefaults,
	}

	for _,button in pairs(ButtonsToSkin) do
		button:StripTextures()
		button:SkinActionButton()
	end

	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:SetPoint('TOPLEFT', InterfaceOptionsFrameCategories, 'BOTTOMLEFT', 0, -8)

	InterfaceOptionsFrameCancel:ClearAllPoints()
	InterfaceOptionsFrameCancel:SetPoint('TOPRIGHT', InterfaceOptionsFramePanelContainer, 'BOTTOMRIGHT', 0, -8)

	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint('RIGHT', InterfaceOptionsFrameCancel, 'LEFT', -(2+S.borderinset), 0)

	local FramesToSkin = {
		['InterfaceOptionsFrame'] = 'TS',
		['InterfaceOptionsFrameCategories'] = '',
		['InterfaceOptionsFrameAddOns'] = '',
		['InterfaceOptionsControlsPanel'] = 'N',
		['InterfaceOptionsCombatPanel'] = 'N',
		['InterfaceOptionsDisplayPanel'] = 'N',
		['InterfaceOptionsObjectivesPanel'] = 'N',
		['InterfaceOptionsSocialPanel'] = 'N',
		['InterfaceOptionsNamesPanel'] = 'N',
		['InterfaceOptionsCombatTextPanel'] = 'N',
		['InterfaceOptionsStatusTextPanel'] = 'N',
		['InterfaceOptionsUnitFramePanel'] = 'N',
		['InterfaceOptionsActionBarsPanel'] = 'N',
		['InterfaceOptionsBattlenetPanel'] = 'N',
		['InterfaceOptionsCameraPanel'] = 'N',
		['InterfaceOptionsMousePanel'] = 'N',
		['InterfaceOptionsHelpPanel'] = 'N',
		['InterfaceOptionsFramePanelContainer'] = '',
	}

	for frameName, mods in pairs(FramesToSkin) do
		local frame = _G[frameName]
		if not frame then return end

		frame:SetTemplate((mods or '') .. 'K')

		-- --Find any related tabs and set the font
		i = 1
		while _G[format('%sTab%d', frameName, i)] do
			_G[format('%sTab%d', frameName, i)]:SetTemplate('NK')			
			i = i + 1
		end
	end

	--Disable certain config menus that are overwritten by SaftUI
	local menuIndecies = {6, 10, 11, 12}
	for _, i in pairs(menuIndecies) do
		local option = _G[format('InterfaceOptionsFrameCategoriesButton%d', i)]
		local text = _G[format('InterfaceOptionsFrameCategoriesButton%dText', i)]
		option:Disable()
		text:SetTextColor(.5, .5, .5)
		
		option.overlay = CreateFrame('Frame', nil, option)
		option.overlay:SetAllPoints()
		option.overlay:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
			GameTooltip:ClearLines()
			local title = strlower(text:GetText())
			GameTooltip:AddLine(format('The %s configuration menu is disabled\n by SaftUI. To configure the %s, please use the SaftUI config (Type /saftui).', title, title))
			GameTooltip:Show()
		end)
		option.overlay:SetScript('OnLeave', S.HideGameTooltip)
	end
end