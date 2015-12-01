local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LAB = LibStub("LibActionButton-1.0")

local AB = S:GetModule('ActionBars')

--[[
        An edited lightweight OmniCC for Tukui
                A featureless, 'pure' version of OmniCC.
                This version should work on absolutely everything, but I've removed pretty much all of the options
--]]

if IsAddOnLoaded("OmniCC") or IsAddOnLoaded("ncCooldown") then return end

--constants!
OmniCC = true --hack to work around detection from other addons for OmniCC
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local CD = S:NewModule('Cooldowns')
--configuration settings
CD.MinimumDuration = 2.5 --the minimum duration to show cooldown text for

local EXPIRING_DURATION = 8
local EXPIRING_FORMAT = '|cff' .. F:ToHex(1, 0, 0) .. '%.1f|r'   --format for timers that are soon to expire
local SECONDS_FORMAT = '|cff' .. F:ToHex(1, 1, 0) .. '%d|r'  --format for timers that have seconds remaining
local MINUTES_FORMAT = '|cff' .. F:ToHex(1, 1, 1) .. '%dm|r'  --format for timers that have minutes remaining
local HOURS_FORMAT = '|cff' .. F:ToHex(0.4, 1, 1) .. '%dh|r'  --format for timers that have hours remaining
local DAYS_FORMAT = '|cff' .. F:ToHex(0.4, 0.4, 1) .. '%dh|r'  --format for timers that have days remaining

--local bindings!
local floor = math.floor
local min = math.min
local GetTime = GetTime

--returns both what text to display, and how long until the next update
local function getTimeText(s)
	--format text as seconds when below a minute
	if s < MINUTEISH then
		local seconds = tonumber(F:Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - 0.51)
		else
			return EXPIRING_FORMAT, s, 0.051
		end
	--format text as minutes when below an hour
	elseif s < HOURISH then
		local minutes = tonumber(F:Round(s/MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	--format text as hours when below a day
	elseif s < DAYISH then
		local hours = tonumber(F:Round(s/HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	--format text as days
	else
		local days = tonumber(F:Round(s/DAY))
		return DAYS_FORMAT, days,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

--stops the timer
local function Timer_Stop(self)
	self.enabled = nil
	self:Hide()
end

--forces the given timer to update on the next frame
local function Timer_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

--update timer text, if it needs to be
--hide the timer if done
local function Timer_OnUpdate(self, elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if tonumber(F:Round(remain)) > 0 then
			local formatStr, time, nextUpdate = getTimeText(remain)
			self.text:SetFormattedText(formatStr, time)
			self.nextUpdate = nextUpdate
		else
			Timer_Stop(self)
		end
	end
end

--returns a new timer object
local function Timer_Create(self)
	local timer = CreateFrame('Frame', nil, self); timer:Hide()
	timer:SetAllPoints(self)
	timer:SetScript('OnUpdate', Timer_OnUpdate)

	local text = S.CreateFontString(timer, 'pixel')
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text
	if timer.enabled then Timer_ForceUpdate(timer) end

	self.timer = timer
	return timer
end

--hook the SetCooldown method of all cooldown frames
--ActionButton1Cooldown is used here since its likely to always exist
--and I'd rather not create my own cooldown frame to preserve a tiny bit of memory
local function Timer_Start(self, start, duration)
	if self.noOCC then return end
	--start timer
	if start > 0 and duration > CD.MinimumDuration then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		timer:Show()

	--stop timer
	else
		local timer = self.timer
		if timer then
			Timer_Stop(timer)
		end
	end
end

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", Timer_Start)

local active = {}
local hooked = {}

local function cooldown_OnShow(self)
	active[self] = true
end

local function cooldown_OnHide(self)
	active[self] = nil
end

local function cooldown_ShouldUpdateTimer(self, start, duration)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

S.UpdateActionButtonCooldown = function(self)
	local button = self:GetParent()
	local start, duration, enable = GetActionCooldown(button.action)
	local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(button.action)
	
	if charges and charges > 0 then return end
	
	if cooldown_ShouldUpdateTimer(self, start, duration) then
		Timer_Start(self, start, duration)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function(self, event)
	for cooldown in pairs(active) do
		S.UpdateActionButtonCooldown(cooldown)
	end
end)
EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

local function actionButton_Register(frame)
	local cooldown = frame.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", cooldown_OnShow)
		cooldown:HookScript("OnHide", cooldown_OnHide)
		hooked[cooldown] = true
	end
end

if _G["ActionBarButtonEventsFrame"].frames then
	for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)