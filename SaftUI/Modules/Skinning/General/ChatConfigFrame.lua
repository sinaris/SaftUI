local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

S:GetModule('Skinning').GeneralSkins['ChatConfigFrame'] = function()
	
	ChatConfigFrame:EnableMoving()
	
	ChatConfigFrame:SetTemplate('T')
	ChatConfigBackgroundFrame:SetTemplate('T')--Backdrop(nil)
	ChatConfigCategoryFrame:SetTemplate()
	ChatConfigChatSettingsClassColorLegend:SetTemplate()
	ChatConfigChannelSettingsClassColorLegend:SetTemplate()

	hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
		
		local checkBoxNameString = frame:GetName().."CheckBox";
		local checkBox, baseName, colorClasses, colorSwatch;
		frame:SetTemplate()
		for index, value in ipairs(frame.checkBoxTable) do
			baseName = checkBoxNameString..index;
			
			local bg = _G[baseName]
			bg:SetBackdrop(nil)

			--Skin left-bound check boxes
			checkBox = _G[baseName.."Check"];
			if ( checkBox ) then
				checkBox:SkinCheckBox()
				-- S.SkinCheckBox(checkBox)
			end

			--Skin color swatch
			colorSwatch = _G[baseName.."ColorSwatch"];
			if ( colorSwatch ) then
				colorSwatch:SkinColorSwatch()
			end

			--Skin right-bound check boxes
			colorClasses = _G[baseName.."ColorClasses"];
			if ( colorClasses ) then
				colorClasses:SkinCheckBox()
			end
		end
	end)
end