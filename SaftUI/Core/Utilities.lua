local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSF = LibStub('LibStringFormat-1.0')

--------------------------------------------------
-- STRING FORMATTING -----------------------------
--------------------------------------------------

-- prefix special messages with addon name
function S:print(...)	print(S.title, ':', ...) end
S.Print = S.print

-- create a global function for this instead of having this same code in every file that uses
function S.HideGameTooltip() GameTooltip:Hide() end

function iteratechildren(frame)
	for k,v in pairs(getmetatable(frame)) do
		print(k,v:GetName())
	end
end

-- local backdropColor, borderColor, transparency, hoverColor, clickColor = S.GetColors()
function S.GetColors()
	local C = S.Saved.profile.General.Colors
	
	assert(C, 'This function must be called only after SaftUI has been initialized.')
	return C.backdrop, C.border, C.transparency, C.hover, C.click
end

function S.Round(num, decimals)
  local mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

function S.CreateButton(name, parent, text)
	local button = CreateFrame('Button', name, parent or UIParent)
	button:SkinButton(nil, text or ' ')

	return button
end

function S.CreateCheckBox(name, parent, text)
	local checkbox = CreateFrame('CheckButton', name, parent or UIParent)
	checkbox.Text = S.CreateFontString(checkbox)
	checkbox.Text:SetPoint('LEFT', checkbox, 'RIGHT', 6, 0)
	checkbox:SkinCheckBox()

	function checkbox:SetText(text)
		checkbox.Text:SetText(text)
	end

	function checkbox:GetText(text)
		return checkbox.Text:GetText()
	end

	return checkbox
end

function S.CreateEditBox(name, parent, width, height, point)
	local editbox = CreateFrame('EditBox', name or nil, parent or UIParent)
	editbox:SetSize(width or 150, height or 20)
	if point then editbox:SetPoint(unpack(point)) end
	editbox:SetTemplate()
	editbox:SetAutoFocus(false)
	editbox:SetTextInsets(5, 5, 0, 0)
	editbox:Skin(height, width)

	editbox:SetFontTemplate()
	editbox:SetTextColor(1, 1, 1)

	--Just some basic scripts to make sure your cursor doesn't get stuck in the edit box
	editbox:HookScript('OnEnterPressed',  function(self) self:ClearFocus() end)
	editbox:HookScript('OnEscapePressed', function(self) self:ClearFocus() end)

	return editbox
end

function S.CreateStatusBar(parent, name, barTex)
	local sb = CreateFrame('StatusBar', name or nil, parent or UIParent)
	sb:SetBarTemplate(barTex)
	return sb
end

function S.CreateFontString(self, style)
	local fs = self:CreateFontString(nil, 'OVERLAY')
	fs:SetFontTemplate(style)
	return fs
end

function S.GetUnitColor(unit)
	if (UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return F:ToHex(r, g, b), r, g, b	
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b		
		return F:ToHex(r, g, b), r, g, b		
	end
end

--Make a copy of a table
function table.copy(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == 'table' then
			nt[k] = table.copy(v, deep, seen)
		else
			nt[k] = v
		end
	end
	setmetatable(nt, table.copy(getmetatable(t), deep, seen))
	seen[t] = nt
	return nt
end

--Merge two tables, with variables from t2 overwriting t1 when a duplicate is found
function table.merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
		   table.merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

--Purge any variable of t1 who's value is set to the same as t2
function table.purge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			table.purge(t1[k], t2[k])
		else
			if t1[k] == v then
				t1[k] = nil
			end
		end
	end
	return t1
end

function table.print(table)
	for key, val in pairs(table) do
		print(key, '=>', val)
	end
end


--Add time before calling a function
--Usage T.Delay(seconds, functionToCall, ...)
local waitTable = {}
local waitFrame
function S.Delay(delay, func, ...)
	if(type(delay)~="number" or type(func)~="function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate",function (self,elapse)
			local count = #waitTable
			local i = 1
			while(i<=count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d>elapse) then
				  tinsert(waitTable,i,{d-elapse,f,p})
				  i = i + 1
				else
				  count = count - 1
				  f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end