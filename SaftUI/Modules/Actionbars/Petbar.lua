local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LAB = LibStub("LibActionButton-1.0")

local AB = S:GetModule('ActionBars')

-- if true then return end

local petbar = CreateFrame('Frame', 'SaftUI_ActionBarPet', UIParent, 'SecureHandlerStateTemplate')

function AB:PetBar_Update(event, unit)
	if(event == "UNIT_AURA" and unit ~= "pet") then return end
	
	for i=1, NUM_PET_ACTION_SLOTS do
		local buttonName = "PetActionButton"..i
		local button = _G[buttonName]
		local icon = _G[buttonName.."Icon"]
		local autoCast = _G[buttonName.."AutoCastable"]
		local shine = _G[buttonName.."Shine"]	
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

		if not isToken then
			icon:SetTexture(texture)
			button.tooltipName = name
		else
			icon:SetTexture(_G[texture])
			button.tooltipName = _G[name]
		end		
		
		button.isToken = isToken
		button.tooltipSubtext = subtext	
		
		if isActive and name ~= "PET_ACTION_FOLLOW" then
			button:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(button)
			end
		else
			button:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(button)
			end			
		end		
		
		if autoCastAllowed then	autoCast:Show()	else autoCast:Hide() end
		if autoCastEnabled then AutoCastShine_AutoCastStart(shine) else AutoCastShine_AutoCastStop(shine) end
			
		-- button:SetAlpha(1)

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(icon, nil)
			else
				SetDesaturation(icon, 1)
			end
			icon:Show()
		else
			icon:Hide()
		end		
		
		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(button)
			SetDesaturation(icon, 1)
			button:SetChecked(0)
		end		

		button:GetCheckedTexture():SetAlpha(0.3)
	end
end

function AB:PetBar_UpdatePosition()
	local config = S.Saved.profile.ActionBars
	local bar = self.Bars.pet
	local autocastsize = .3*config.buttonsize--(config.buttonsize / 2) - (config.buttonsize / 7.5)

	bar:ClearAllPoints()
	bar:SetPoint(unpack(config.Bars.pet.point))
	if vertical then
		bar:SetHeight(NUM_PET_ACTION_SLOTS*config.buttonsize + (NUM_PET_ACTION_SLOTS-1)*config.buttonspacing)
		bar:SetWidth(config.buttonsize)
	else
		bar:SetHeight(config.buttonsize)
		bar:SetWidth(NUM_PET_ACTION_SLOTS*config.buttonsize + (NUM_PET_ACTION_SLOTS-1)*config.buttonspacing)
	end

	for i=1, NUM_PET_ACTION_SLOTS do
		local button = _G["PetActionButton"..i]
		local lastButton = _G["PetActionButton"..i-1]
		local autoCast = _G["PetActionButton"..i..'AutoCastable']

		button:ClearAllPoints()
		button:SetSize(config.buttonsize, config.buttonsize)

		autoCast:SetInside(button, autocastsize)

		if i == 1 then
			button:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
		else
			if vertical then
				button:SetPoint('TOP', bar.buttons[i-1], 'BOTTOM', 0, -config.buttonspacing)
			else
				button:SetPoint('LEFT', bar.buttons[i-1], 'RIGHT', config.buttonspacing, 0)
			end
		end
	end
end

function AB:PetBar_Initialize()
	petbar.buttons = {}
	for i=1, NUM_PET_ACTION_SLOTS do
		local button = _G["PetActionButton"..i]
		button:SetParent(petbar)

		button:SkinActionButton()
		button.SetNormalTexture = S.dummy

		if not button.CheckFixed then 
			hooksecurefunc(button:GetCheckedTexture(), 'SetAlpha', function(self, value)
				if value == 1 then
					self:SetAlpha(0.5)
				end
			end)
			button.CheckFixed = true;
		end

		petbar.buttons[i] = button
	end

	petbar:SetAttribute("_onstate-show", [[		
		if newstate == "hide" then
			self:Hide()
		else
			self:Show()
		end	
	]])

	petbar:CreateBackdrop()
	petbar:SetFrameLevel(10)
	self.Bars.pet = petbar

	PetActionBarFrame.showgrid = 1;
	PetActionBar_ShowGrid();

	for _,event in pairs({
		'PLAYER_CONTROL_GAINED',
		'PLAYER_ENTERING_WORLD',
		'PLAYER_CONTROL_LOST',
		'PET_BAR_UPDATE',
		'UNIT_PET',
		'UNIT_FLAGS',
		'UNIT_AURA',
		'PLAYER_FARSIGHT_FOCUS_CHANGED',
	}) do self:RegisterEvent(event, 'PetBar_Update') end
	
	self:RegisterEvent('PET_BAR_UPDATE_COOLDOWN', PetActionBar_UpdateCooldowns)

	self:PetBar_UpdatePosition()

	self:UpdateActionBar('pet')

	RegisterStateDriver(petbar, "show", "[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide")
end