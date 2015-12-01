local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local UF = S:GetModule('UnitFrames')
local oUF = UF.oUF

--Create an environment for custom text functions
local environment = {F = F, S = S, L = L, gradient = oUF.ColorGradient}
setmetatable(environment, {__index = _G})



function UF.PostUpdateHealth(health, unit, min, max)
	local self = health:GetParent()
	local uCon = S.Saved.profile.UnitFrames.Units[self.baseunit]

	--status bar
	local tapped = health.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)
	local disconnected = health.colorDisconnected and not UnitIsConnected(unit)
	local r, g, b

	--colorCustom (uhh this isn't custom..)
	if health.colorCustom and not (tapped or disconnected) then
		r, g, b = .3,.33,.3
		if health.colorSmooth then r, g, b = oUF.ColorGradient(min,max, 0.7,0.2,0.2, 0.2,0.2,0.2, 0.2,0.2,0.2) end
		health:SetStatusBarColor(r, g, b)
	end

	r, g, b = health:GetStatusBarColor()
	if health.backdrop then health.backdrop:SetBackdropColor(r/4,g/4,b/4) end

	--text
	if health.text then
		local customtext = uCon.health.text.customtext
		if customtext.enable then 
			environment['unit'] = unit
			environment['baseunit'] = self.baseunit
			environment['min'] = min
			environment['max'] = max
			environment['config'] = S.Saved.profile
			environment['health'] = health

			local textFunc, error = loadstring(customtext.funcString)
			if textFunc and not error then
				setfenv(textFunc, environment)
				health.text:SetText(textFunc())
			end
		else
			if UnitIsDead(unit) then
				health.text:SetText('|cffcc6666Dead|r')
			elseif UnitIsGhost(unit) then
				health.text:SetText('|cffcc6666Ghost|r')
			elseif  min == max then
				health.text:SetText(health.hideFullValue and '' or F:ShortFormat(min, 1))
			else
				health.text:SetFormattedText('%s (%.f)', F:ShortFormat(min, 1), min/max*100)
			end
		end
	end
end

function UF.PostUpdatePower(power, unit, min, max)
	local self = power:GetParent()
	local uCon = S.Saved.profile.UnitFrames.Units[self.baseunit]

	--status bar
	local r, g, b

	--wtf is this
	if power.colorCustom then
		r, g, b = 0.3, 0.3, 0.3
		if generalConfig.colorSmooth then r, g, b = oUF.ColorGradient(min,max, 0.7,0.2,0.2, 0.2,0.2,0.2, 0.2,0.2,0.2) end
		power:SetStatusBarColor(r, g, b)
	end

	r, g, b = power:GetStatusBarColor()
	if power.backdrop then power.backdrop:SetBackdropColor(r/4, g/4, b/4) end

	if uCon.power.fullwhendead and (UnitIsDead(unit) or UnitIsGhost(unit)) then
		power:SetValue(max)
	end

	if uCon.power.fullifnopower and max == 0 then
		power:SetMinMaxValues(0, 1)
		power:SetValue(1)
	end

	--text
	if power.text then
		local customtext = uCon.power.text.customtext
		if customtext.enable then 
			environment['unit'] = unit
			environment['baseunit'] = self.baseunit
			environment['min'] = min
			environment['max'] = max
			environment['config'] = S.Saved.profile
			environment['power'] = power
			
			gsub(customtext.funcString, "||", "|")
			local textFunc, error = loadstring(customtext.funcString)
			if textFunc and not error then
				setfenv(textFunc, environment)
				power.text:SetText(textFunc())
			end
		else
			if max == min or min == 0 then
				power.text:SetText(power.hideFullValue and '' or F:ShortFormat(min))
			else
				-- power.text:SetText(F:ShortFormat(min))
				power.text:SetFormattedText('%s (%.f)', F:ShortFormat(min), min/max*100)
			end
		end
	end
	
	
	-- if UnitPowerMax(unit) > 0 or power:GetParent().Health.colorCustom then
	-- 	local r, g, b = power:GetStatusBarColor()
	-- elseif UnitPowerMax(unit) <= 0 then
	-- 	--Make it transparent if there's no power
	-- 	power.backdrop:SetTemplate('T')
	-- end
end


function UF.PostCreateAuraBar(bar)
	bar:CreateBackdrop()
	bar.backdrop:SetPoint('LEFT', bar.icon, 'LEFT', -S.borderinset, 0)

	bar.icon:Kill()
	bar:SetPoint('LEFT', 0, 0)
	bar:SetPoint('RIGHT', 0, 0)

	bar:SetStatusBarTexture(LSM:Fetch('statusbar', 'SaftUI Flat'))
	-- bar:SetStatusBarColor(.3, .3, .8, 0.5)
	-- bar.bg:Kill()

	bar.spellname:SetFontTemplate()
	bar.spellname:SetPoint('LEFT', 3, 0)

	bar.spelltime:SetFontTemplate()
	bar.spelltime:SetPoint('RIGHT', -3, 0)
end

function UF.PostCastStart(self, unit, name, castid)
	if unit == 'vehicle' then unit = 'player' end	
	if not S.Saved.profile.UnitFrames.Units[unit] then print(unit) return end
	if not S.Saved.profile.UnitFrames.Units[unit].castbar then return end
	
	local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

	if unit ~= 'player' and notInterruptible then
		self:SetStatusBarColor(unpack(S.Saved.profile.UnitFrames.Units[unit].castbar.altcolor))
	else
		self:SetStatusBarColor(unpack(S.Saved.profile.UnitFrames.Units[unit].castbar.color))
	end
end

function UF.PostUpdateAuraBar(self, bar)
	bar:SetStatusBarColor(0, .4, .8)
end

function UF.AuraBarFilter(name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable)
	if not unitCaster then return end

	--If you can steal the buff, show it
	if isStealable then return true end

	--Find out if it's a buff or a debuff
	local isHarmful = not UnitBuff(unitCaster, name)

	--Hide auras and spells with a duration greater than one minute
  if duration > 60 then return false end

  --Only show auras cast by player
 	if unitCaster ~= 'player' then return false end

  return true;
end

function UF.PostCreateStatusIcons(statusicons)
	statusicons:SetTemplate()
	for _,icon in pairs(statusicons.Icons) do
		icon:CreateBackdrop()
	end
end


--[[ :PostUpdateIcon(unit, icon, index, offset)

 Callback which is called after the aura icon was updated.

 Arguments

 self   - The widget that holds the aura icon.
 unit   - The unit that has the aura.
 button   - The button that was updated.
 index  - The index of the aura.
 offset - The offset the button was created at.
]]

function UF.PostUpdateBuffIcon(self, unit, button, index, offset)
	local name, rank, _, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossBuff, value1, value2, value3 = UnitBuff(unit, index)

	if isStealable then
		button:SetBackdropBorderColor(1, 1, .3)
	elseif S.Saved.profile.General.thinborder then
		button:SetBackdropBorderColor(0, 0, 0)
	else
		button:SetBackdropBorderColor(unpack(S.Saved.profile.General.Colors.border))
	end

	--Don't bother showing timers for buffs over 5 min
	if duration > 300 and button.cd then
		button.cd:Hide()
	end
end

function UF.PostUpdateDebuffIcon(self, unit, button, index, offset)
	local name, rank, _, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3 = UnitDebuff(unit, index)

	if isBossDebuff or caster == 'player' then
		button.icon:SetDesaturated(nil)
	else
		button.icon:SetDesaturated(1)
		button:SetBackdropBorderColor(.3, .3, .3)
	return end

	if DebuffTypeColor[debuffType] then 
		button:SetBackdropBorderColor(unpack(DebuffTypeColor[debuffType]))
	else
		button:SetBackdropBorderColor(.8, .3, .3)
	end
end

function UF.PostCreateAuraIcon(self, button)
	button:SetTemplate('S')
	button.icon:SetInside()
	button.icon:SetTexCoord(.08,.92,.08,.92)

	button.cd:SetInside()

	if button.stealable then button.stealable:Kill() end

	button.count:SetFontTemplate('pixel')
	button.count:ClearAllPoints()
	button.count:SetPoint('BOTTOMRIGHT', 1, 1)
end

function UF.PostCreateAuraWatchIcon(self, icon, spellID, spellName, unitframe)
	icon:SetTemplate("Default")
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexture(unpack(icon.color))
	if (icon.cd) then
		icon.cd.noOCC = true
		icon.cd:SetReverse()
	end
	icon.count:Kill()
	icon.overlay:SetTexture()
end