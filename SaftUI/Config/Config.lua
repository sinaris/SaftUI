local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local CF = S:NewModule('Config')

local REQUIRED_ITEMS = {'label', 'type', 'get', 'set'}

CF.Movers = {}
CF.MoversParent = CreateFrame('frame', 'SaftUIConfig_MoversParent', UIParent)
CF.MoversParent:Hide()
function S:RegisterMover(frame, moduleTitle, configFunc)
	if not frame.mover then
		frame:SetMovable(true)
		local mover = S.CreateButton(nil, CF.MoversParent)
		mover:SetFrameStrata('HIGH')

		local backdropColor, borderColor, transparency, hoverColor, clickColor = S.GetColors()
		mover:SetAllPoints(frame)
		mover:SetTemplate()
		local r, g, b = unpack(hoverColor)
		mover:SetBackdropColor(r, g, b, .3)

		mover.label = S.CreateFontString(mover, 'pixel')
		mover.label:SetPoint('CENTER', mover, 'CENTER', 0, 0)
		mover.label:SetText(moduleTitle)


		mover:SetScript('OnMouseDown', function(self, button)
			if button == 'LeftButton' then
				frame:StartMoving()
			end
		end)

		mover:SetScript('OnMouseUp', function(self, button)
			frame:StopMovingOrSizing()
			if button == 'RightButton' and configFunc then
				configFunc(frame)
			end
		end)

		frame.mover = mover
	end

	CF.Movers[frame] = frame.mover
end

function S:UnregisterMover(frame)
	CF.Movers[frame] = nil
end

function CF:SetConfigTable(frame, moduleConfig)
	self:ClearConfig()

	local moduleTitle = frame.mover.label:GetText()
	self.ConfigPanel.Title:SetText(moduleTitle)

	-- used to acumulate width of configs in order to
	--  decide if a new row needs to be started
	local collectiveWidth = 0

	--Loop through each option within a module's config table
	for i,optionConfig in pairs(moduleConfig) do
		
		local anchor = self:GetNextAnchor()
		local moduleWidth = math.min(optionConfig.width or 1, 1)
		local offset = moduleWidth < 1 and 3 or 0

		anchor:SetWidth(((self.ConfigPanel:GetWidth()-12) * moduleWidth) - offset )
		for _,key in pairs(REQUIRED_ITEMS) do
			assert(optionConfig[key], format('Required value \'%s\' is missing from config table for \'%s\'.', key, moduleTitle))
		end

		local optionType = string.lower(optionConfig.type)
		local optionFrame, optionLabel

		if optionType == 'editbox' then
			local editbox = CF:GetNext('editbox')
			editbox.Label:SetText(optionConfig.label)
			editbox:SetText(optionConfig.get())
			editbox:SetScript('OnEnterPressed', function(self)
				self:ClearFocus()
				local value = F:SanitizeNumber(self:GetText(), optionConfig.min, optionConfig.max)
				optionConfig.set(value)
			end)

			editbox:SetWidth(anchor:GetWidth()*(optionConfig.boxwidth or .5))
			editbox:SetJustifyH(optionConfig.textJustify or 'LEFT')

			optionLabel = editbox.Label
			optionFrame = editbox
		
		elseif optionType == 'checkbox' then
			local checkbox = CF:GetNext('checkbox')
			checkbox:SetSize(20, 20)
			checkbox:SetText(optionConfig.label)
			checkbox:SetChecked(optionConfig.get())
			checkbox:SetScript('OnClick', function(self)
				optionConfig.set(checkbox:GetChecked() and true or false)
			end)

			optionLabel = checkbox.Text
			optionFrame = checkbox
		end

		
		local prevAnchor = anchor:GetPreviousAnchor()
		anchor:Show()

		collectiveWidth = collectiveWidth + moduleWidth
		if prevAnchor then
			if collectiveWidth == 0 then
				anchor:SetPoint('TOPLEFT', prevAnchor, 'BOTTOMLEFT', 0, -6)
				if moduleWidth < 1 then
					collectiveWidth = collectiveWidth + moduleWidth
				end

			elseif collectiveWidth > 1 then
				anchor:SetPoint('TOPLEFT', prevAnchor, 'BOTTOMLEFT', 0, -6)		
				collectiveWidth = 0

			else
				anchor:SetPoint('LEFT', prevAnchor, 'RIGHT', 6, 0)

			end

		else
			anchor:SetPoint('TOPLEFT', self.ConfigPanel.Title, 'BOTTOMLEFT', 6, -6)

		end

		optionLabel:ClearAllPoints()
		optionLabel:SetPoint('LEFT', anchor, 'LEFT', 3, 0)
		optionLabel:SetJustifyH(optionConfig.labelJustify or 'LEFT')

		optionFrame:Show()
		optionFrame:ClearAllPoints()
		optionFrame:SetPoint('RIGHT', anchor, 'RIGHT', 0, 0)
	end

	self.ConfigPanel:Show()
end

function CF:SetConfigMode(enable)
	self.ConfigMode = enable or false

	if enable then
		self.MoversParent:Show()
		self.ConfigPanel:Show()
	else
		self.MoversParent:Hide()
		self.ConfigPanel:Hide()
	end
end

function CF:ToggleConfigMode()
	self:SetConfigMode(not self.ConfigMode)
end

function CF:OnInitialize()
	local cPanel = CreateFrame('Frame', 'SaftUI_ConfigPanel', UIParent)
	cPanel:SetTemplate()
	cPanel:SetSize(200, 286)
	cPanel:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
	cPanel.Title = S.CreateFontString(cPanel)
	cPanel.Title:SetPoint('TOP', cPanel, 'TOP', 0, 0)
	cPanel.Title:SetHeight(20)
	cPanel.Title:SetWidth(cPanel:GetWidth())
	cPanel:EnableMouse(true)
	cPanel.TitleRegion = cPanel:CreateTitleRegion()
	cPanel.TitleRegion:SetAllPoints(cPanel.Title)

	cPanel.CloseButton = S.CreateButton(nil, cPanel)
	cPanel.CloseButton:SkinCloseButton()
	cPanel.CloseButton:SetPoint('TOPRIGHT', -4, -4)
	cPanel.CloseButton:SetSize(16, 16)
	cPanel.CloseButton:HookScript('OnClick', function(self)
		CF:SetConfigMode(false)
	end)

	self.ConfigPanel = cPanel

	self.ConfigItems = {}
	for _,itemType in pairs({'editbox', 'checkbox'}) do
		self.ConfigItems[itemType] = {
			TotalCount = 0,
			UsedCount = 0,
			Frames = {}
		}
	end

	self.Anchors = {
		TotalCount = 0,
		UsedCount = 0,
		Frames = {},
	}

	self.ConfigMode = false

	cPanel:Hide()
end

function CF:GetNext(itemType)
	assert(self.ConfigItems[itemType], 'invalid item type: ' .. itemType)

	self.ConfigItems[itemType].UsedCount = self.ConfigItems[itemType].UsedCount + 1

	--Can localize this value since it won't be changed anywhere else in the function
	local usedCount = self.ConfigItems[itemType].UsedCount

	if self.ConfigItems[itemType].TotalCount < usedCount then
		if itemType == 'editbox' then
			local editbox = S.CreateEditBox('SaftUI_ConfigPanelEditBox'..usedCount, self.ConfigPanel)
			editbox.Label = S.CreateFontString(editbox)
			self.ConfigItems[itemType].Frames[usedCount] = editbox
		elseif itemType == 'checkbox' then
			self.ConfigItems[itemType].Frames[usedCount] = S.CreateCheckBox('SaftUI_ConfigPanelEditBox'..usedCount, self.ConfigPanel)
		end
		self.ConfigItems[itemType].TotalCount = usedCount

	end
	
	return self.ConfigItems[itemType].Frames[usedCount]
end

function CF:GetNextAnchor()
	self.Anchors.UsedCount = self.Anchors.UsedCount + 1

	local usedCount = self.Anchors.UsedCount

	if self.Anchors.TotalCount < usedCount then
		local anchor = CreateFrame('Frame', self.ConfigPanel:GetName()..'_Anchor'..usedCount, self.ConfigPanel)
		anchor:SetHeight(20)
		anchor:SetWidth(self.ConfigPanel:GetWidth()-12)
		-- anchor:SetTemplate()

		function anchor:GetPreviousAnchor()
			if usedCount > 1 then
				return CF.Anchors.Frames[usedCount-1]
			end
		end
		self.Anchors.Frames[usedCount] = anchor

		self.Anchors.TotalCount = usedCount
	end

	return self.Anchors.Frames[usedCount]
end

function CF:ClearConfig()
	for itemType,itemTable in pairs(self.ConfigItems) do
		for _,item in pairs(itemTable.Frames) do
			item:ClearAllPoints()
			item:Hide()
		end
		self.ConfigItems[itemType].UsedCount = 0
	end

	for _,anchor in pairs(self.Anchors.Frames) do
		anchor:ClearAllPoints()
		anchor:Hide()
	end
	self.Anchors.UsedCount = 0
end

function CF:OnEnable()

end

function CF:OnDisable()

end