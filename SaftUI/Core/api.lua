local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(S.HiddenFrame)
	end
	object._Show = object.Show
	object.Show = object.Hide
	
	object:Hide()
end

local function TrimIcon(self, customTrim)
	if self.SetTexCoord then
		local trim = customTrim or .08
		self:SetTexCoord(trim, 1-trim, trim, 1-trim)
	else
		S:print("function SetTexCoord does not exist for",self:GetName() or self)
	end
end

local function StripTextures(object, kill)
	if object.SetNormalTexture    then object:SetNormalTexture("")    end	
	if object.SetHighlightTexture then object:SetHighlightTexture("") end
	if object.SetPushedTexture    then object:SetPushedTexture("")    end	
	if object.SetDisabledTexture  then object:SetDisabledTexture("")  end	

	local name = object.GetName and object:GetName()
	if name then 
	if _G[name.."Left"] then _G[name.."Left"]:SetAlpha(0) end
	if _G[name.."Middle"] then _G[name.."Middle"]:SetAlpha(0) end
	if _G[name.."Right"] then _G[name.."Right"]:SetAlpha(0) end	
	end
	if object.Left then object.Left:SetAlpha(0) end
	if object.Right then object.Right:SetAlpha(0) end	
	if object.Middle then object.Middle:SetAlpha(0) end

	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == "Texture" then
			if kill then
				region:Kill()
			else
				region:SetTexture(nil)
			end
		end
	end	 
end

local function UnpackFont(font)
	local face, size, outline = unpack(font)
	return LSM:Fetch('font', face), size, outline
end
S.UnpackFont = UnpackFont


local function SetFontTemplate(self, style, shadow)
	local sOff = shadow and 1.3 or 0

	if self.SetShadowOffset then self:SetShadowOffset(sOff, -sOff) end

	if not S.Saved then
		S.FontsToSet[self] = style or 'general'
	else
		-- self:SetFont(S.FontObjects[style or 'general']:GetFont())
		self:SetFontObject(S.FontObjects[style or 'general'])
	end
end

local function SetBarTemplate(self, texName)
	if texName then
		self:SetStatusBarTexture(LSM:Fetch('statusbar', texName))
	elseif not S.Saved then
		self:SetStatusBarTexture(LSM:Fetch('statusbar', S.DefaultConfig.profile.General.barTexture))
		tinsert(S.BarsToSet, self)
	else
		self:SetStatusBarTexture(LSM:Fetch('statusbar', S.Saved.profile.General.barTexture))
		if not self.stored then tinsert(S.StatusBars, self) self.stored = true end
	end
end

local function SetGlossTemplate(self, texName)
	self:SetTexture(LSM:Fetch('statusbar', texName or 'SaftUI Gloss'))
	self:SetVertexColor(.4,.4,.4)
end

local function RegisterEvents(self, events)
	--If a string is passed only one event needs to be registered, so fallback on the normal RegisterEvent function
	if type(events) == 'string' then
		self:RegisterEvent(events)
	else
		for _,event in pairs(events) do
			self:RegisterEvent(event)
		end
	end
end

local function SetInside(obj, anchor, customOffset)
	if customOffset then obj.offset = customOffset end	
	local offset = obj.offset or S.borderinset

	anchor = anchor or obj:GetParent()

	obj:ClearAllPoints()
	obj:SetPoint('TOP', anchor, 'TOP', 0, -offset)
	obj:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, offset)
	obj:SetPoint('LEFT', anchor, 'LEFT', offset, 0)
	obj:SetPoint('RIGHT', anchor, 'RIGHT', -offset, 0)
end

local function SetOutside(obj, anchor, customOffset) 
	if customOffset then obj.offset = customOffset end
	local offset = obj.offset or S.borderinset
	
	anchor = anchor or obj:GetParent()

	obj:ClearAllPoints()
	obj:SetPoint('TOP', anchor, 'TOP', 0, offset)
	obj:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, -offset)
	obj:SetPoint('LEFT', anchor, 'LEFT', -offset, 0)
	obj:SetPoint('RIGHT', anchor, 'RIGHT', offset, 0)
end

local function SetBottom(obj, anchor, customOffset)  
	if customOffset then obj.offset = customOffset end
	local offset = obj.offset or S.borderinset
	
	anchor = anchor or obj:GetParent()
	
	obj:ClearAllPoints()
	obj:SetPoint('BOTTOM', anchor, 'BOTTOM', 0, offset)
	obj:SetPoint('LEFT', anchor, 'LEFT', offset, 0)
	obj:SetPoint('RIGHT', anchor, 'RIGHT', -offset, 0)
end

local function SetTop(obj, anchor, customOffset)  
	if customOffset then obj.offset = customOffset end
	local offset = obj.offset or S.borderinset

	anchor = anchor or obj:GetParent()

	obj:ClearAllPoints()
	obj:SetPoint('TOP', anchor, 'TOP', 0, -offset)
	obj:SetPoint('LEFT', anchor, 'LEFT', offset, 0)
	obj:SetPoint('RIGHT', anchor, 'RIGHT', -offset, 0)
end

local function CreateBackdrop(self, mods, offset)
	local name = self.GetName and self:GetName() and self:GetName().."Backdrop"
	local b = CreateFrame("Frame", name, self)

	b:SetOutside(self, offset)
	b:SetTemplate(mods)
	b:SetFrameLevel(max(0, self:GetFrameLevel()-1))
	
	self.backdrop = b
end

local function CreateShadow(self)
	if self.shadow then return end

	local ins = S.borderinset

	local shadow = CreateFrame("Frame", nil, self)
	shadow:SetFrameLevel(max(0, self:GetFrameLevel()-1))
	shadow:SetFrameStrata(self:GetFrameStrata())
	shadow:SetOutside(self, ins+1)
	shadow:SetBackdrop({ 
		edgeFile = LSM:Fetch("border", "SaftUI Glow Border"), edgeSize = 3,
		insets = {left = ins+3, right = ins+3, top = ins+3, bottom = ins+3},
	})
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, .7)
	self.shadow = shadow
end


local function SetTemplate(self, mods)
	mods = mods or ''
	self.mods = mods

	if strmatch(strlower(mods), 'n') then self:SetBackdrop(nil) return end

	local button = strmatch(strlower(mods), 'b')
	local transparent = strmatch(strlower(mods), 't')
	local strip = strmatch(strlower(mods), 'k')

	--If saved variables haven't been loaded yet, store the frame in a table and set the template after saved variables are loaded
	if not S.Saved then tinsert(S.TemplatesToSet, self) return end

	-- tinsert(S.AllFrameTemplates, self)

	if strip then self:StripTextures() end
	local colors = S.Saved.profile.General.Colors

	local border,backdrop
	
	if button then
		backdrop = colors.buttonbackdrop
		border = colors.buttonborder
	elseif transparent then 
		backdrop = colors.transparentbackdrop
		border = colors.transparentborder
	else
		backdrop = colors.backdrop
		border = colors.border
	end
	
	self:SetBackdrop(S.backdrop)
	self:SetBackdropColor(unpack(backdrop))
	self:SetBackdropBorderColor(unpack(border))
end

local function EnableMoving(self,onShift)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:HookScript('OnMouseDown', function(self)
		if (not onShift) or IsShiftKeyDown() then
			self:StartMoving()
		end
	end)
	self:HookScript('OnMouseUp', function(self) self:StopMovingOrSizing() end)
end


local function SkinActionButton(button, preserveTextures) 
	button:SetTemplate(preserveTextures and 'G' or 'KG')

	if button.SetHighlightTexture and not button.hover then
		local hover = button:CreateTexture("frame", nil, self)
		hover:SetTexture(1, 1, 1, 0.3)
		hover:SetInside()
		button.hover = hover
		button:SetHighlightTexture(hover)
	end

	if button.SetPushedTexture and not button.pushed then
		local pushed = button:CreateTexture("frame", nil, self)
		pushed:SetTexture(0, 0.6, 1, 0.3)
		pushed:SetInside()
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture and not button.checked then
		local checked = button:CreateTexture("frame", nil, self)
		checked:SetTexture(0,1,0,.3)
		checked:SetInside()
		button.checked = checked
		button:SetCheckedTexture(checked)
	end

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"] or button.cooldown
	if cooldown then
		cooldown:SetInside()
		if not button.cooldown then button.cooldown = cooldown end
	end

	if button.icon then
		button.icon:TrimIcon(); button.icon:SetDrawLayer('BACKGROUND', 1)
	end
end

local function SkinButton(button, preserveTextures, text)

	local colors = S.Saved.profile.General.Colors
	local backdropColor = colors.buttonbackdrop
	local borderColor = colors.buttonborder
	local hoverColor = colors.hover

	if not preserveTextures then button:StripTextures() end
	button:SetTemplate('B')
	button:HookScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
	button:HookScript('OnLeave', function(self)
		self:SetBackdropBorderColor(unpack(borderColor))
	end)

	button.text = (button:GetName() and _G[button:GetName()..'Text']) or S.CreateFontString(button)
	if text then
		button.text:SetFontTemplate()
		button.text:SetAllPoints(button)
		button.text:SetText(text)
	end

	if button.LockHighlight then
		local r,g,b = unpack(hoverColor)
		hooksecurefunc(button, 'LockHighlight', function(self) self.locked = true; self:SetBackdropColor(r*.3,g*.3,b*.3) end)
		hooksecurefunc(button, 'UnlockHighlight', function(self) self.locked = false; self:SetBackdropColor(unpack(backdropColor)) end)
	end

end

local function SkinCloseButton(button,...)
	SkinButton(button,...)
	button.text:SetFontTemplate('pixel')
	button.text:SetText('x')
	button.text:SetPoint('CENTER', 1, 1)

	button:SetSize(20, 20)
end

local function SkinCheckBox(checkbox)
	local hoverColor = select(4, S.GetColors()) -- replace this select call with whatever color you want
	checkbox:StripTextures()

	checkbox.Display = CreateFrame('Frame', nil, checkbox)
	checkbox.Display:SetSize(12, 12)
	checkbox.Display:SetTemplate()
	checkbox.Display:SetPoint('CENTER')
	
	checkbox:SetFrameLevel(checkbox:GetFrameLevel()+1)
	checkbox.Display:SetFrameLevel(checkbox:GetFrameLevel()-1)

	--Time to sexify these textures
	local checked = checkbox.Display:CreateTexture(nil, 'OVERLAY')
	checked:SetGlossTemplate()
	checked:SetVertexColor(unpack(hoverColor))
	checked:SetInside(checkbox.Display)
	checkbox:SetCheckedTexture(checked)

	local hover = checkbox.Display:CreateTexture(nil, 'OVERLAY')
	hover:SetGlossTemplate()
	hover:SetVertexColor(1, 1, 1, 0.3)
	hover:SetInside(checkbox.Display)
	checkbox:SetHighlightTexture(hover)

	local name = checkbox:GetName()
	local text = checkbox.Text or name and _G[name..'Text']
	if text then
		text:SetFontTemplate()
	end
end

local function SkinEditBox(editbox, height, width)
	local _,borderColor,_,hoverColor = S.GetColors()

	if editbox:GetName() then
		if _G[editbox:GetName().."Left"] then Kill(_G[editbox:GetName().."Left"]) end
		if _G[editbox:GetName().."Middle"] then Kill(_G[editbox:GetName().."Middle"]) end
		if _G[editbox:GetName().."Right"] then Kill(_G[editbox:GetName().."Right"]) end
		if _G[editbox:GetName().."Mid"] then Kill(_G[editbox:GetName().."Mid"]) end
	else

	end

	editbox:SetTemplate('B')
	

	editbox:HookScript('OnEditFocusGained', function(self) self:HighlightText() end)
	editbox:HookScript('OnEditFocusLost', function(self) self:HighlightText(0,0) end)

	-- editbox:HookScript('OnEditFocusGained', function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
	-- editbox:HookScript('OnEditFocusLost', function(self) self:SetBackdropBorderColor(unpack(borderColor)) end)

	if editbox:GetName() and editbox:GetName():find("Silver") or editbox:GetName():find("Copper") then
		Point(editbox.backdrop, "BOTTOMRIGHT", -12, -2)
	end

	editbox:SetHeight(height or 20)
	if width then editbox:SetWidth(width) end
end

local function SkinDropDown(frame, width, height)
	local button = _G[frame:GetName().."Button"]
	local text = _G[frame:GetName().."Text"]
	local label = _G[frame:GetName().."Label"]


	if not frame.skinned then

		if label then
			local anchorPoint, anchorFrame, anchorFrom, offX, offY = label:GetPoint()
			if anchorPoint == 'RIGHT' then
				label:SetPoint('RIGHT', anchorFrame, 'LEFT', -5, 0)
			end

		end

		local framelevel = frame:GetFrameLevel()

		frame:SetFrameLevel(framelevel+1)
		button:SetFrameLevel(framelevel)

		frame:EnableMouse(false)
		
		StripTextures(frame)

		frame._SetHeight = frame.SetHeight
		frame._SetWidth = frame.SetWidth
		frame.SetHeight = S.dummy
		frame.SetWidth = S.dummy			

		text:ClearAllPoints()
		text:SetPoint("RIGHT", button, "RIGHT", -2, 0)
		text:SetPoint('LEFT', button, 'LEFT', 5, 0)
		text:SetJustifyH('LEFT')

		button:ClearAllPoints()
		button:SetAllPoints()
		button.SetPoint = S.dummy
		button:SkinButton()
		button.arrow = S.CreateFontString(button, 'pixel')
		button.arrow:SetPoint('RIGHT', -4, 0)
		button.arrow:SetText('v')
	
		-- SkinNextPrevButton(button, true)

	end

	frame:_SetHeight(height or 25)
	frame:_SetWidth(width or 155)

	frame.skinned = true
end

local function SkinColorSwatch(self)
	local bg = _G[self:GetName()..'selfBg']
	if bg then
		self:SetTemplate()
		if not self.skinned then 
			bg:Kill()
			
			if _G[self:GetName().."NormalTexture"] then
				_G[self:GetName().."NormalTexture"]:SetTexture(LSM:Fetch('background','SaftUI Blank'))
				_G[self:GetName().."NormalTexture"]:SetInside(self)
			end
			self.skinned = true
		end
	end
end

local function SkinScrollBar(self, customWidth)
	local parent = self:GetParent()
	local name = self:GetName()
	local _,_,_,hoverColor = S.GetColors()

	local up, down = _G[ name.."ScrollUpButton" ], _G[ name.."ScrollDownButton" ]

	for _,tex in pairs({
		_G[name.."BG"],
		_G[name.."Track"],
		_G[name.."Top"],
		_G[name.."Middle"],
		_G[name.."Bottom"],
	}) do
		if tex then tex:SetTexture(nil) end
	end

	local width = customWidth or 20+(S.borderinset*2)

	local thumb = _G[name.."ThumbTexture"]

	thumb:SetTexture(nil)
	thumb:SetWidth(width-2)
	thumb.BG = CreateFrame('Frame', nil, self)
	thumb.BG:SetTemplate()
	local ins = S.borderinset
	thumb.BG:SetPoint('TOPLEFT', thumb, 'TOPLEFT', ins-1, -ins)
	thumb.BG:SetPoint('BOTTOMRIGHT', thumb, 'BOTTOMRIGHT', -(ins-1), ins)

	self:StripTextures()

	-- Standardized positioning for all scrollbars
	up:ClearAllPoints()
	down:ClearAllPoints()
	self:ClearAllPoints()
	up:SetPoint('TOPLEFT', parent, 'TOPRIGHT', S.borderinset, 0)
	down:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT', S.borderinset, 0)
	self:SetPoint('TOP', up, 'BOTTOM', 0, -S.borderinset)
	self:SetPoint('BOTTOM', down, 'TOP', 0, S.borderinset)
	-- self:SetPoint('TOPLEFT', parent, 'TOPRIGHT', S.borderinset, -(17-S.borderinset))
	-- self:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT', S.borderinset, (17-S.borderinset))
	up.SetPoint = S.dummy
	down.SetPoint = S.dummy
	self.SetPoint = S.dummy


	self:SetWidth(width)
	self:CreateBackdrop("T")
	self.backdrop:SetInside(self, 1)

	for i,btn in pairs({up, down}) do
		btn:StripTextures()
		btn:SetWidth(width-2)
		if not btn:IsEnabled() then btn:SetTemplate() end
		btn:HookScript('OnDisable', function(self) self:SetTemplate() end)
		btn:HookScript('OnEnable', function(self) self:SetTemplate('')end)
		btn:SkinActionButton()
	end
end

local function SkinSlider(self)
	local name = self:GetName()
	local thumb = self:GetThumbTexture()
	local _,_,_,hoverColor = S.GetColors()
	local disabledColor = {.5, .5, .5}

	self:SetThumbTexture('')
	thumb.tex = self:CreateTexture(nil, 'OVERLAY')
	thumb.tex:SetTexture(unpack(self:IsEnabled() and hoverColor or disabledColor))
	self:HookScript('OnEnable', function(self) self:GetThumbTexture().tex:SetTexture(unpack(hoverColor)) end)
	self:HookScript('OnDisable', function(self) self:GetThumbTexture().tex:SetTexture(unpack(disabledColor)) end)

	self:SetTemplate()

	local ins = S.borderinset
	if self:GetOrientation() == 'VERTICAL' then
		thumb:SetSize(10,8)
		thumb.tex:SetPoint('TOPLEFT', thumb, 'TOPLEFT', 1, -2)
		thumb.tex:SetPoint('BOTTOMRIGHT', thumb, 'BOTTOMRIGHT', -1, 2)
		self:SetWidth(12)
	else
		thumb:SetSize(12, 10)
		thumb.tex:SetPoint('TOPRIGHT', thumb, 'TOPRIGHT', -ins, -(ins-1))
		thumb.tex:SetPoint('BOTTOMLEFT', thumb, 'BOTTOMLEFT', ins, ins-1)
		self:SetHeight(12)
	end

	local text, low, high = _G[name..'Text'], _G[name..'Low'], _G[name..'High']
	

	text:SetFontTemplate()
	low:SetFontTemplate()
	low:ClearAllPoints()
	low:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 1, -3)
	high:SetFontTemplate()
	high:ClearAllPoints()
	high:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', -1, -3)
end



local function Point(self)

	self:SetPoint(point, relativeTo, relativePoint, floor(xOffset), floor(yOffset))
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Kill then mt.Kill = Kill end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetBottom then mt.SetBottom = SetBottom end
	if not object.SetTop then mt.SetTop = SetTop end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.ClearTemplate then mt.ClearTemplate = ClearTemplate end
	if not object.SetFontTemplate then mt.SetFontTemplate = SetFontTemplate end
	if not object.SetBarTemplate then mt.SetBarTemplate = SetBarTemplate end
	if not object.SetGlossTemplate then mt.SetGlossTemplate = SetGlossTemplate end
	if not object.RegisterEvents then mt.RegisterEvents = RegisterEvents end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.EnableMoving then mt.EnableMoving = EnableMoving end
	if not object.TrimIcon then mt.TrimIcon = TrimIcon end
	if not object.SkinActionButton then mt.SkinActionButton = SkinActionButton end
	if not object.SkinButton then mt.SkinButton = SkinButton end
	if not object.SkinCloseButton then mt.SkinCloseButton = SkinCloseButton end
	if not object.SkinCheckBox then mt.SkinCheckBox = SkinCheckBox end
	if not object.SkinEditBox then mt.SkinEditBox = SkinEditBox end
	if not object.SkinColorSwatch then mt.SkinColorSwatch = SkinColorSwatch end
	if not object.SkinScrollBar then mt.SkinScrollBar = SkinScrollBar end
	if not object.SkinSlider then mt.SkinSlider = SkinSlider end
	if not object.SkinDropDown then mt.SkinDropDown = SkinDropDown end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())


getmetatable(CreateFrame('CheckButton')).__index.Skin = SkinCheckBox
getmetatable(CreateFrame('Button')).__index.Skin = SkinButton
getmetatable(CreateFrame('Slider')).__index.Skin = SkinSlider
local editbox = CreateFrame('EditBox')
editbox:SetAutoFocus(false) --WHY IS THIS NOT DISABLED BY DEFAULT WHAT THE HELL
getmetatable(editbox).__index.Skin = SkinEditBox



object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end
	
	object = EnumerateFrames(object)
end