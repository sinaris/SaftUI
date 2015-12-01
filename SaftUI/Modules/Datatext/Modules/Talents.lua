local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local function Update(self)
	if not GetSpecialization() then
		self.Text:SetText('No Spec') 
	else
		self.Text:SetFormattedText('%s', select(2,GetSpecializationInfo(GetSpecialization())) or '')
	end
end

local function ChangeSpec()
	SetActiveSpecGroup(GetActiveSpecGroup() == 1 and 2 or 1)
end

local function Enable(self)
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("CONFIRM_TALENT_WIPE")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:SetScript('OnEvent', Update)
	self:SetScript('OnMouseDown', ChangeSpec)
	self:Update()
end

local function Disable(self)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self:SetScript('OnMouseDown', nil)
end

DT:RegisterDataModule('Talents', Enable, Disable, Update)