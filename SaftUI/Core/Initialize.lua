local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local LSM = LibStub('LibSharedMedia-3.0')
-- local ACR = LibStub('AceConfigRegistry-3.0')

S.HiddenFrame = CreateFrame('Frame', 'SaftUI_HiddenFrame', UIParent)
S.HiddenFrame.Show = S.HiddenFrame.Hide

S.FontsToSet = {}
S.TemplatesToSet = {}

S.StatusBars = {}
S.AllFontTemplates = {}
S.AllFrameTemplates = {}

function S:SetOnLoadTemplates()
	for _,frame in pairs(self.TemplatesToSet) do
		frame:SetTemplate(frame.templateMods or '')
	end

	for fontstring, style in pairs(self.FontsToSet) do
		fontstring:SetFontTemplate(style or 'general')
	end
end

function S:SetConsoleVariables()		
	for variable, value in pairs({
		-- ['uiScale'] = min(2, max(.64, 768/string.match(S.resolution, "%d+x(%d+)")))
	}) do SetCVar(variable, value) end
end

function S:LoadConfig()
	if InCombatLockdown() then S:print("Cannot load config in combat.") return end


	
	
	if not IsAddOnLoaded("SaftUI_Config") then
		LoadAddOn("SaftUI_Config")
		LibStub('AceConfig-3.0'):RegisterOptionsTable(S.name, S.options)
		hooksecurefunc(LibStub('AceConfigDialog-3.0'), 'Close', function()
			S:GetModule('UnitFrames').oUF:SetTestMode(false)
		end)
	end

	local ACD = LibStub('AceConfigDialog-3.0')
	ACD:SetDefaultSize(self.name, 975, 700)
	ACD:Open(self.name)

	-- S:GetModule('UnitFrames').oUF:SetTestMode(true)
end

function S:UpdateFontObjects(objectName)
	if objectName and self.Saved.profile.General.Fonts[objectName] then
		object:SetFont(self.UnpackFont(self.Saved.profile.General.Fonts[objectName]))
	else
		for name, object in pairs(self.FontObjects) do
			object:SetFont(self.UnpackFont(self.Saved.profile.General.Fonts[name]))
		end
	end
end

function S:UpdateStatusBarTextures()
	for _,statusbar in pairs(self.StatusBars) do
		statusbar:SetBarTemplate()
	end
end

function S:OnInitialize()
	self.Saved = LibStub("AceDB-3.0"):New("SaftUISaved", self.DefaultConfig)

	self.FontObjects = {
		['pixel'] = CreateFont('SaftUIFont_Pixel'),
		['general'] = CreateFont('SaftUIFont_General'),
		['chat'] = CreateFont('SaftUIFont_Chat'),
	}
	self:UpdateFontObjects()
	-- self:FixBlizzardFontObjects()

	for name, module in self:IterateModules() do
		--Only change loading if config is available for specific module
		if self.Saved.profile[name] then
			--Make sure the 'enable' variable isn't nil
			local enable = (self.Saved.profile[name].enable ~= nil and self.Saved.profile[name].enable) or true
			module:SetEnabledState(enable)
			-- self:print(name, ': ', enable and 'Enabled' or 'Disabled')
		else
			-- self:print(name, ': Enabled [D]')
		end
	end		

	self:print(format('Welcome to SaftUI version %s. To configure, type /sui or press the SUI button in the bottom left corner.', self.version))

	self:SetConsoleVariables()
	self:SetOnLoadTemplates()
	self:RegisterChatCommand('sui', 'LoadConfig')
	self:RegisterChatCommand('saftui', 'LoadConfig')
end