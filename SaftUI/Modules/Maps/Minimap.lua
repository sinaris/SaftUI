local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local MM = S:NewModule('Minimap', 'AceHook-3.0', 'AceEvent-3.0')

function MM:CleanseMinimap()
	for _,frame in pairs({
		MinimapBorder,
		MinimapBorderTop,
		MinimapZoomIn,
		MinimapZoomOut,
		MiniMapVoiceChatFrame,
		MinimapZoneTextButton,
		TimeManagerClockButton,
		-- MiniMapTracking,
		GameTimeFrame,
	}) do frame:Hide() end

	for _,frame in pairs({
		MinimapCluster,
		MiniMapWorldMapButton,
	}) do frame:Kill() end

	for _,frame in pairs({MiniMapInstanceDifficulty, GuildInstanceDifficulty}) do
		frame:ClearAllPoints()
		frame:SetParent(Minimap)
		frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
		frame:SetAlpha(0)
	end

	Minimap:HookScript('OnEnter', function(self)
		MiniMapInstanceDifficulty:SetAlpha(1)
		GuildInstanceDifficulty:SetAlpha(1)
	end)

	Minimap:HookScript('OnLeave', function(self)
		MiniMapInstanceDifficulty:SetAlpha(0)
		GuildInstanceDifficulty:SetAlpha(0)
	end)

	_G['MinimapNorthTag']:SetTexture(nil)
end

function MM:KillClock(event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function MM:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	else
		self:SkinIcons()
	end
end

function MM:SkinQueueIcon()
	local button  = QueueStatusMinimapButton
	local icon    = QueueStatusMinimapButtonIcon
	local texture = QueueStatusMinimapButtonIconTexture

	button:Show()
	icon:Show()

	button:SetSize(20,20)
	button:ClearAllPoints()
	button:SetPoint('TOPRIGHT', Minimap, 'TOPRIGHT', -7, -7)
	button:StripTextures()
end

function MM:UpdateDisplay()
	local conf = S.Saved.profile.Minimap

	--update position

	self.Container:ClearAllPoints()
	self.Container:SetPoint(unpack(S.Saved.profile.Minimap.position))

	--Update size
	Minimap:SetSize(conf.width, conf.height)
	self.Container:SetSize(conf.width, conf.height)


	--update backdrop
	if conf.backdrop.enable then
		self.Container.backdrop:SetTemplate(conf.backdrop.transparent and 'T' or '')
		self.Container.backdrop:ClearAllPoints()
		self.Container.backdrop:SetPoint('TOPLEFT', self.Container, 'TOPLEFT', -conf.backdrop.insets.left, conf.backdrop.insets.top)
		self.Container.backdrop:SetPoint('BOTTOMRIGHT', self.Container, 'BOTTOMRIGHT', conf.backdrop.insets.right, -conf.backdrop.insets.bottom)
	else
		self.Container.backdrop:SetTemplate('N')
	end
end

function MM:OnInitialize()
	self:CleanseMinimap()

	local container = CreateFrame('Frame', 'SaftUI_Minimap', UIParent)
	container:CreateBackdrop()
	
	Minimap:ClearAllPoints()
	Minimap:SetPoint('CENTER', container, 'CENTER', 0, 0)
	Minimap:SetParent(container)

	Minimap:SetMaskTexture(LSM:Fetch('background','SaftUI Blank'))

	self.Container = container
	self:UpdateDisplay()

	self:SkinQueueIcon()
	
	-- Enable mouse scrolling
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, d)
		if d > 0 then
			_G.MinimapZoomIn:Click()
		elseif d < 0 then
			_G.MinimapZoomOut:Click()
		end
	end)

	-- For others mods with a minimap button, set minimap buttons position in square mode.
	function GetMinimapShape() return "SQUARE" end

	self:InitializeIconTray()
	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD','SkinIcons')
	self:SkinMailIcon()
	self:SkinTrackingIcon()
end


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

-- QueueTimers.lua

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

if true then return end

local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local QT = S:NewModule('QueueTimers', 'AceHook-3.0', 'AceEvent-3.0')

function QT:NewTimer()

end

function QT:OnInitialize()
	QT.Timers = {}

	self:RegisterEvent('BATTLEFIELD_QUEUE_TIMEOUT')
end