local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local CB = S:NewModule('ClassBars')

CB.Modules = {}

function CB:UpdateModulePosition(moduleName)
	local module = self.Modules[moduleName]
	module:ClearAllPoints()
	module:SetPoint(unpack(S.Saved.profile.ClassBars[moduleName].point))
end

function CB:UpdateModuleOrientation(moduleName)
	local module = self.Modules[moduleName]
	local config = S.Saved.profile.ClassBars[moduleName]

	local pos1,pos2
	local offset = config.reverse and -S.borderinset or S.borderinset

	if config.orientation == 'vertical' then
		pos1 = config.reverse == true and 'TOP' or 'BOTTOM'
		pos2 = config.reverse == true and 'BOTTOM' or 'TOP'
	else
		pos1 = config.reverse == true and 'RIGHT' or 'LEFT'
		pos2 = config.reverse == true and 'LEFT' or 'RIGHT'		
	end

	local totalSpacing = (module.ShownUnits-1)*S.borderinset
	local totalWidth = module:GetWidth()
	local totalHeight = module:GetHeight()

	for i = 1, module.ShownUnits do

		if config.orientation == 'vertical' then
			module[i]:SetHeight((totalHeight-totalSpacing)/module.ShownUnits)
			module[i]:SetWidth(totalWidth)
		else
			module[i]:SetHeight(totalHeight)
			module[i]:SetWidth((totalWidth-totalSpacing)/module.ShownUnits)
		end

		module[i]:ClearAllPoints()
		if i == 1 then
			module[i]:SetPoint(pos1, module, pos1, 0, 0)
		else
			if config.orientation == 'vertical' then
				module[i]:SetPoint(pos1, module[i-1], pos2, 0, offset)
			else
				module[i]:SetPoint(pos1, module[i-1], pos2, offset, 0)				
			end
			if i == module.ShownUnits then 
				module[i]:SetPoint(pos2, module, pos2, 0, 0)
			end
		end
	end
end

local function SetActiveStacks(self,count)
	local showEmpty = S.Saved.profile.ClassBars[self.ModuleName].showEmpty
	for i=1, self.ShownUnits do
		if i > (count or 0) then
			if showEmpty then
				self[i].Texture:SetVertexColor(.2,.2,.2)
			else
				self[i]:Hide()
			end
		else
			if showEmpty then
				local color = self.ColorType == 'single' and self.Colors or self.Colors[i]
				self[i].Texture:SetVertexColor(unpack(color))
			else
				self[i]:Show()
			end
		end
	end
end

function CB:CreateUnit(module, ID)
	local unit = CreateFrame('Frame', nil, module)
	unit:SetTemplate()
	local color = module.ColorType == 'single' and module.Colors or module.Colors[ID]
	unit.ID = ID

	--Create unit frames with specific type
	if module.UnitType == 'stacks' then
		unit.Texture = unit:CreateTexture(nil, 'OVERLAY')
		unit.Texture:SetInside(unit)
		unit.Texture:SetGlossTemplate()
		unit.Texture:SetVertexColor(unpack(color))
	elseif module.UnitType == 'bars' then
		unit.StatusBar = CreateFrame('StatusBar', nil, module)
		unit.StatusBar:SetInside(unit)
		unit.StatusBar:SetBarTemplate()
		unit.StatusBar:SetStatusBarColor(unpack(color))
		unit.StatusBar:SetMinMaxValues(0, 1)
		unit.Text = S.CreateFontString(unit.StatusBar, 'pixel')
		unit.Text:SetPoint('CENTER')
	end

	module[ID] = unit
end

local function SetMaxUnits(self, maxUnits)
	--If no change is needed and all units are created, stop here
	if maxUnits == self.ShownUnits and self[maxUnits] then return end

	self.ShownUnits = maxUnits
	self.TotalUnits = math.max(maxUnits, self.TotalUnits)

	for i=1, self.TotalUnits do
		if i > self.ShownUnits  then
			self[i]:Hide()
		elseif self[i] then
			self[i]:Show()
		else
			CB:CreateUnit(self,i)
		end
	end

	CB:UpdateModuleOrientation(self.ModuleName)
end

function CB:InitializeModule(moduleName)
	local module = self.Modules[moduleName]
	local config = S.Saved.profile.ClassBars[moduleName]

	
	module:SetSize(config.width, config.height)

	module:SetMaxUnits(module.ShownUnits)
	self:UpdateModulePosition(moduleName)

	module:EnableMoving(true)
	hooksecurefunc(module, 'StopMovingOrSizing', function(self)
		local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint()
		S.Saved.profile.ClassBars[moduleName].point = {
			point, relativeTo, relativePoint, S.Round(xOffset), S.Round(yOffset) }

		CB:UpdateModulePosition(moduleName)		
	end)
end

function CB:RegisterModule(moduleName, Trigger, Enable, Disable, UnitType, NumUnits, Colors)
	assert(not self.Modules[strlower(moduleName)], 'The '..moduleName..' module is already registered.')

	local module = CreateFrame('frame', "SaftUIClassBar"..moduleName, UIParent)

	module.Colors = Colors or {1,1,1}
	module.ColorType = type(module.Colors[1]) == 'table' and 'multiple' or 'single'
	module.UnitType = strlower(UnitType)
	module.ShownUnits = NumUnits --Amount of units to show
	module.TotalUnits = NumUnits --Total units created
	module.ModuleName = strlower(moduleName)

	module:Hide()

	function module:Enable()
		if not self.Initialized then
			CB:InitializeModule(self.ModuleName)
		end

		if not self.Enabled then
			self:Show()
			self.Enabled = true
			Enable(self)
		end
	end

	function module:Disable()
		if self.Enabled then
			self:Hide()
			self.Enabled = false
			Disable(self)
		end
	end
	
	function module:IsEnabled()
		return self.Enabled
	end

	module.SetActiveStacks = SetActiveStacks
	module.Trigger = Trigger
	module.SetMaxUnits = SetMaxUnits

	self.Modules[module.ModuleName] = module
end

function CB:OnEnable()
	for moduleName,module in pairs(self.Modules) do
		local config = S.Saved.profile.ClassBars[moduleName]
		assert(config, 'Default config missing for ' .. moduleName .. ' module.')
		if module:Trigger() and config.enable then
			module:Enable()
		end
	end
end

function CB:OnDisable()
	for _,module in pairs(self.Modules) do
		module:Disable()
	end
end