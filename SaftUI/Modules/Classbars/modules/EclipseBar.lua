local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CB = S:GetModule('ClassBars')

--CAST WRATH(NATURE) ON MOON, AND STARFALL(ARCANE) ON SUN

local Colors = {
	[1] = {1.0, 0.8, 0.4},
	[2] = {0.4, 0.6, 0.8}
}
local fadeMult = 0.3

local ECLIPSE_BAR_SOLAR_BUFF_ID = ECLIPSE_BAR_SOLAR_BUFF_ID
local ECLIPSE_BAR_LUNAR_BUFF_ID = ECLIPSE_BAR_LUNAR_BUFF_ID
local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
local MOONKIN_FORM = MOONKIN_FORM

local function UpdateVisibility(self)
	if GetShapeshiftFormID() == MOONKIN_FORM then
		self:Enable()
	else
		self:Disable()
	end
end

local function OnEvent(self, event, unit, powerType)
	if event == 'PLAYER_TALENT_UPDATE' or event == 'UPDATE_SHAPESHIFT_FORM' then
		UpdateVisibility(self)
	end

	if event == 'UNIT_POWER' and not (unit == 'player' and powerType == 'ECLIPSE') then return end
	


	local min = UnitPower('player', SPELL_POWER_ECLIPSE)+100
	local max = UnitPowerMax('player', SPELL_POWER_ECLIPSE)+100
	self[1].StatusBar:SetValue(min/max)

	local direction = GetEclipseDirection()
	local text = min

	self[1].StatusBar.Lunar:SetAlpha(1)
	self[1].StatusBar:GetStatusBarTexture():SetAlpha(1)

	if direction == 'moon' then
		-- self[1].StatusBar.Lunar:SetAlpha(fadeMult)
		text = '<' .. text
	elseif direction == 'sun' then
		-- self[1].StatusBar:GetStatusBarTexture():SetAlpha(fadeMult)
		text = text .. '>'
	end
	self[1].Text:SetText(text)
end

local function Trigger(self)
	if S.myclass == 'DRUID' then
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		return true
	end
end

local function Enable(self)
	self:RegisterEvent('ECLIPSE_DIRECTION_CHANGE') --ECLIPSE_DIRECTION_CHANGE
	self:RegisterEvent('UNIT_AURA') --UNIT_AURA
	self:RegisterEvent('UNIT_POWER') --UNIT_POWER
	self:RegisterEvent('PLAYER_TALENT_UPDATE') --UpdateVisibility
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM') --UpdateVisibility

	if not self[1].StatusBar.Lunar then
		local lunar = self[1].StatusBar:CreateTexture(nil, 'OVERLAY')
		lunar:SetPoint('TOPLEFT', self[1].StatusBar:GetStatusBarTexture(), 'TOPRIGHT')
		lunar:SetPoint('BOTTOMRIGHT', self[1].StatusBar, 'BOTTOMRIGHT')
		lunar:SetGlossTemplate()
		lunar:SetVertexColor(unpack(Colors[2]))
		self[1].StatusBar.Lunar = lunar
	end

	OnEvent(self, 'PLAYER_TALENT_UPDATE')
	self:SetScript('OnEvent', OnEvent)		
end

local function Disable(self)
	self:RegisterEvent('ECLIPSE_DIRECTION_CHANGE')
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_POWER')
end

CB:RegisterModule('EclipseBar', Trigger, Enable, Disable, 'bars', 1, Colors)
