local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LAB = LibStub("LibActionButton-1.0")
local LSM = LibStub('LibSharedMedia-3.0')
local strfind = string.find

local AB = S:GetModule('ActionBars')

AB.BindTarget = nil 
local HB_Initialized = false
local HB_Enabled = false
local CurrentHover

--Make sure nobody can modify HB_Enabled
function AB:HoverBind_IsEnabled()
	return HB_Enabled
end

function AB:HoverBind_Initialize()
	if HB_Initialized then return end

	for button,_ in pairs(LAB:GetAllButtons()) do
		button.bindings = { GetBindingKey(button.bindString) }

		button:HookScript('OnEnter',             function(btn) CurrentHover = btn; if not HB_Enabled then return end; self:HoverBind_DisplayTooltip(); end)
		button:HookScript('OnLeave',             function(btn) CurrentHover = nil; if not HB_Enabled then return end; GameTooltip:Hide(); end)
		button:HookScript("OnKeyUp",        function(btn, key) if not HB_Enabled then return end; self:HoverBind_Listener(key) end)
		button:HookScript("OnMouseUp",      function(btn, key) if not HB_Enabled then return end; self:HoverBind_Listener(key) end)
		button:HookScript("OnMouseWheel", function(btn, delta) if not HB_Enabled then return end; self:HoverBind_Listener(delta>0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN") end)
	end

	HB_Initialized = true
end

function AB:HoverBind_Enable()
	StaticPopup_Show('SAFTUI_BINDMODE')
	HB_Enabled = true
	
	--In case mouse is hovering a button when bind mode is activated
	if CurrentHover then self:HoverBind_DisplayTooltip() end

	for button,_ in pairs(LAB:GetAllButtons()) do
		button.bindings = {GetBindingKey(button.bindString)}
		button:EnableKeyboard(true)
		button:EnableMouseWheel(true)
	end
end

function AB:HoverBind_Disable(Save)
	HB_Enabled = false
	CurrentHover = nil

	for button,_ in pairs(LAB:GetAllButtons()) do
		button.bindings = {GetBindingKey(button.bindString)}
		button:EnableKeyboard(false)
		button:EnableMouseWheel(false)
	end

	if Save then
		SaveBindings(2)
		S:print('Bindings saved.')
	else
		LoadBindings(2)
		S:print('Bindings discarded.')
	end
end

function AB:HoverBind()
	if not HB_Initialized then self:HoverBind_Initialize() end

	if HB_Enabled then
		self:HoverBind_Disable()
	else
		self:HoverBind_Enable()
	end
end

function AB:HoverBind_Listener(key)
	if not CurrentHover then return end
	
	local btn = CurrentHover
	local bindString = btn.bindString

	if key == "ESCAPE" or key == "RightButton" then
		for _,bind in pairs(btn.bindings) do
			SetBinding(bind)
		end

		--Update bindings table
		btn.bindings = {GetBindingKey(btn.bindString)}
		--Update the tooltip
		AB:HoverBind_DisplayTooltip()

		-- self:Update(btn, self.spellmacro)
		-- if self.spellmacro~="MACRO" then GameTooltip:Hide() end
		return
	end
	
	if key == "LSHIFT"
	or key == "RSHIFT"
	or key == "LCTRL"
	or key == "RCTRL"
	or key == "LALT"
	or key == "RALT"
	or key == "UNKNOWN"
	or key == "LeftButton"
	then return end
	
	if key == "MiddleButton" then key = "BUTTON3" end
	if key == "Button4" then key = "BUTTON4" end
	if key == "Button5" then key = "BUTTON5" end
	
	local mods = format('%s%s%s', IsAltKeyDown() and 'ALT-' or '', IsControlKeyDown() and "CTRL-" or "", IsShiftKeyDown() and "SHIFT-" or "")
	
	SetBinding(mods..key, bindString)

	-- if not self.spellmacro or self.spellmacro=="PET" or self.spellmacro=="STANCE" then
	-- 	SetBinding(mods..key, bindString)
	-- else
	-- 	SetBinding(mods..key, self.spellmacro.." "..btn.name)
	-- end
	-- self:Update(btn, self.spellmacro)
	-- if self.spellmacro~="MACRO" then GameTooltip:Hide() end

	--Update bindings table
	btn.bindings = {GetBindingKey(btn.bindString)}
	--Update the tooltip
	AB:HoverBind_DisplayTooltip()
end

function AB:HoverBind_DisplayTooltip()
	if not CurrentHover then return end
	local btn = CurrentHover
	GameTooltip:SetOwner(btn, 'ANCHOR_CURSOR')
	GameTooltip:ClearLines()
	GameTooltip:AddLine('Hoverbind')
	GameTooltip:AddDoubleLine('Key: ', btn.bindString)
	GameTooltip:AddDoubleLine('Current Bindings:', table.concat(btn.bindings, ', '))
	GameTooltip:AddLine('Press escape or right click the button to clear its binds')
	GameTooltip:Show()
end

SlashCmdList.MOUSEOVERBIND = function() AB:HoverBind() end
SLASH_MOUSEOVERBIND1 = "/bindkey"
SLASH_MOUSEOVERBIND2 = "/kb"
