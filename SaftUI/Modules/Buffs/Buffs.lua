local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local AU = S:NewModule('Auras')

--Change default debuff colors to fit a specific color theme
-- DebuffTypeColor = { };
DebuffTypeColor["none"]	   = { r = .8, g = .3, b = .3 };
DebuffTypeColor["Magic"]	 = { r = .3, g = .6, b = .8 };
DebuffTypeColor["Curse"]	 = { r = .6, g = .3, b = .8 };
DebuffTypeColor["Disease"] = { r = .8, g = .6, b = .3 };
DebuffTypeColor["Poison"]	 = { r = .3, g = .6, b = .3 };


local function GetDurationColor(time)
	if time > 60 then
		return .9, .9, .9 -- white
	elseif time > 5 then
		return .8, .6, .3	-- yellow
	else
		return .8, .3, .3 -- red
	end
end

function AU.OnAttributeChanged(self, attribute, value)
	if attribute == 'index' then
		AU.UpdateAura(self, value)
	elseif attribute == 'target-slot' then
		self.Bar:SetMinMaxValues(0, 3600)
		AU.UpdateTempEnchant(self, value)
	end
end

local function OnUpdate(self, elapsed)
	local timeLeft
	
	-- Handle refreshing of temporary enchants.
	if (self.offset) then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if (expiration) then
			timeLeft = expiration / 1e3
		else
			timeLeft = 0
		end
	else
		timeLeft = self.timeLeft - elapsed		
	end
	

	if (timeLeft <= 0) then
		-- Kill the tracker so we don't end up with stuck timers.
		self.timeLeft = nil

		self.Timer:SetText('')
		self:SetScript('OnUpdate', nil)
	else
		self.timeLeft = timeLeft

		self.Bar:SetValue(self.timeLeft)
		if not self.filter == 'HARMFUL' then
			self.Bar:SetStatusBarColor(S:GetModule('UnitFrames').oUF.ColorGradient(self.timeLeft, self.duration, .8,.3,.3, .8,.8,.3, .3,.8,.3))
		end

		self.Timer:SetTextColor(GetDurationColor(timeLeft))		
		self.Timer:SetText(F:ToTime(timeLeft))
	end
end

function AU.UpdateAura(self, index)
	local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(self:GetParent():GetAttribute'unit', index, self.filter)
	if not name then return end
	
	if (duration > 0 and expirationTime) then
		local timeLeft = expirationTime - GetTime()
		self.duration = duration
		
		if (not self.timeLeft) then
			self.timeLeft = timeLeft
			self:SetScript('OnUpdate', OnUpdate)
		else
			self.timeLeft = timeLeft
		end

		if S.Saved.profile.Auras.timerbar then
			self.Bar:Show()
			self.Bar:SetMinMaxValues(0, duration)
		end
	else
		self.timeLeft = nil
		self.Timer:SetText('')
		self:SetScript('OnUpdate', nil)
		
		self.Bar:Hide()
		-- local min, max  = self.Bar:GetMinMaxValues()
		-- self.Bar:SetValue(max)
		-- self.Bar:SetStatusBarColor(1, 1, 1)
	end

	self.Count:SetText(count > 1 and count or '')

	if (self.filter == 'HARMFUL') then
		local color = DebuffTypeColor[dtype or 'none']
		
		if self.Bar then
			self.Bar:SetStatusBarColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor(color.r, color.g, color.b)	
		end
	end

	self.Icon:SetTexture(texture)
end

function AU.UpdateTempEnchant(self, slot)
	-- set the icon
	self.Icon:SetTexture(GetInventoryItemTexture('player', slot))
	
	-- time left
	local offset
	local weapon = self:GetName():sub(-1)
	
	if weapon:match('1') then
		offset = 2
	elseif weapon:match('2') then
		offset = 5
	end
	
	local expiration = select(offset, GetWeaponEnchantInfo())
	
	if (expiration) then
		self.duration = 3600
		self.offset = offset
		self:SetScript('OnUpdate', OnUpdate)
	else
		self.offset = nil
		self.timeLeft = nil
		self:SetScript('OnUpdate', nil)
	end
end

function AU:CreateAura(aura)
	local Icon = aura:CreateTexture(nil, 'BORDER')
	Icon:SetTexCoord(.08, .92, .08, .92)
	Icon:SetAllPoints(aura)
	aura:SetFrameLevel(2)
	aura.Icon = Icon

	aura:CreateBackdrop()

	local Count = S.CreateFontString(aura, 'pixel')
	aura.Count = Count

	local Timer = S.CreateFontString(aura, 'pixel')
	aura.Timer = Timer

	local Bar = S.CreateStatusBar(aura)
	Bar:CreateBackdrop()
	aura.Bar = Bar

	aura.filter = aura:GetParent():GetAttribute('filter')

	tinsert(self.Auras, aura)
	self:UpdateAuraDisplay(aura)

	aura.Initialized = true
end

--Update displays based on config changes
function AU:UpdateAuraDisplay(aura)
	local conf = S.Saved.profile.Auras

	if conf.count.enable then
		aura.Count:Show()
		aura.Count:SetFontTemplate(conf.pixelfont and 'pixel' or 'general')

		aura.Count:ClearAllPoints()
		local point, relativePoint, xOffset, yOffset = unpack(conf.count.position)
		aura.Count:SetPoint(point, aura, relativePoint, xOffset, yOffset)
	else
		aura.Count:Hide()
	end

	if conf.timerbar.enable then
		aura.Bar:Show()
		aura.Bar:SetSize(conf.timerbar.width, conf.timerbar.height)
		
		aura.Bar:SetOrientation(conf.timerbar.vertical and 'VERTICAL' or 'HORIZONTAL')
		aura.Bar:SetReverseFill(conf.timerbar.reversefill)

		aura.Bar:ClearAllPoints()
		local point, relativePoint, xOffset, yOffset = unpack(conf.timerbar.position)
		aura.Bar:SetPoint(point, aura, relativePoint, xOffset, yOffset)
		aura.Bar:SetFrameLevel(conf.count.framelevel)

		if conf.timerbar.backdrop.enable then
			aura.Bar.backdrop:SetTemplate(conf.timerbar.backdrop.transparent and 'T' or '')
			aura.Bar.backdrop:ClearAllPoints()
			aura.Bar.backdrop:SetPoint('TOPLEFT', aura.Bar, 'TOPLEFT', -S.Saved.profile.Auras.timerbar.backdrop.insets.left, S.Saved.profile.Auras.timerbar.backdrop.insets.top)
			aura.Bar.backdrop:SetPoint('BOTTOMRIGHT', aura.Bar, 'BOTTOMRIGHT', S.Saved.profile.Auras.timerbar.backdrop.insets.right, -S.Saved.profile.Auras.timerbar.backdrop.insets.bottom)
		else
			aura.Bar.backdrop:SetBackdrop(nil)
		end
	else
		aura.Bar:Hide()
	end

	if conf.timertext.enable then
		aura.Timer:Show()
		aura.Timer:SetFontTemplate(conf.pixelfont and 'pixel' or 'general')

		aura.Timer:ClearAllPoints()
		local point, relativePoint, xOffset, yOffset = unpack(conf.timertext.position)
		aura.Timer:SetPoint(point, aura, relativePoint, xOffset, yOffset)
	else
		aura.Timer:Hide()
	end

	if conf.backdrop.enable then
		aura.backdrop:SetTemplate(conf.backdrop.transparent and 'T' or '')
		aura.backdrop:ClearAllPoints()
		aura.backdrop:SetPoint('TOPLEFT', aura, 'TOPLEFT', -S.Saved.profile.Auras.backdrop.insets.left, S.Saved.profile.Auras.backdrop.insets.top)
		aura.backdrop:SetPoint('BOTTOMRIGHT', aura, 'BOTTOMRIGHT', S.Saved.profile.Auras.backdrop.insets.right, -S.Saved.profile.Auras.backdrop.insets.bottom)
	else
		aura.backdrop:SetBackdrop(nil)
	end
end

function AU:UpdateAllAuraDisplays()
	for _,aura in pairs(self.Auras) do
		self:UpdateAuraDisplay(aura)
	end

end

function AU:CreateBuffHeader()
	local buffs = CreateFrame('Frame', 'SaftUI_BuffHeader', UIParent, 'SecureAuraHeaderTemplate')
	buffs:SetAttribute('minHeight', 80)
	buffs:SetAttribute('minWidth', 600)

	buffs:SetAttribute('includeWeapons', 1)
	buffs:SetAttribute('template', 'SecureAuraTemplate')
	buffs:SetAttribute('weaponTemplate', 'SecureAuraTemplate')
	buffs:SetAttribute('filter', 'HELPFUL')

	buffs:SetAttribute('wrapAfter', 20)
	buffs:SetAttribute('wrapYOffset', -50)
	
	RegisterAttributeDriver(buffs, 'unit', '[vehicleui] vehicle; player')

	buffs:Show()
	AU.BuffHeader = buffs
end

function AU:CreateDebuffHeader()
	local debuffs = CreateFrame('Frame', 'SaftUI_DebuffHeader', UIParent, 'SecureAuraHeaderTemplate')
	debuffs:SetAttribute('minHeight', 30)
	debuffs:SetAttribute('minWidth', 600)

	debuffs:SetAttribute('template', 'SecureAuraTemplate')
	debuffs:SetAttribute('filter', 'HARMFUL')
	
	RegisterAttributeDriver(debuffs, 'unit', '[vehicleui] vehicle; player')

	debuffs:Show()
	AU.DebuffHeader = debuffs
end

function AU:UpdateHeaderPosition()
	local conf = S.Saved.profile.Auras
	local buffs, debuffs = self.BuffHeader, self.DebuffHeader

	buffs:ClearAllPoints()
	debuffs:ClearAllPoints()

	buffs:SetPoint(unpack(conf.buffposition))
	debuffs:SetPoint(unpack(conf.debuffposition))

	if conf.buffdirection == 'LEFT' then
		buffs:SetAttribute('xOffset', -35)
		buffs:SetAttribute('point', 'TOPRIGHT')
	else
		buffs:SetAttribute('xOffset', 35)
		buffs:SetAttribute('point', 'TOPLEFT')
	end

	if conf.debuffdirection == 'LEFT' then
		debuffs:SetAttribute('xOffset', -35)
		debuffs:SetAttribute('point', 'TOPRIGHT')
	else
		debuffs:SetAttribute('xOffset', 35)
		debuffs:SetAttribute('point', 'TOPLEFT')
	end


end

function AU:OnInitialize()

	--Store all auras here for easier iteration
	self.Auras = {}

	BuffFrame:Kill()
	TemporaryEnchantFrame:Kill()

	AU:CreateBuffHeader()
	AU:CreateDebuffHeader()

	AU:UpdateHeaderPosition()
end