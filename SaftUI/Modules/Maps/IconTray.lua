local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local MM = S:GetModule('Minimap')

--Icons to ignore when looping through minimap children
local BLACKLIST = {
	MinimapMailFrame = true,
	MinimapBackdrop = true,
	GameTimeFrame = true,
	MiniMapVoiceChatFrame = true,
	MiniMapInstanceDifficulty = true,
	GuildInstanceDifficulty = true,
	TimeManagerClockButton = true,
}

--Certain icons need to have their textures changed, add then here with texture paths
local NewIconTextures = {
	['DBMMinimapButton']		= "Interface\\Icons\\INV_Helmet_30",
	['SmartBuff_MiniMapButton'] = select(3, GetSpellInfo(12051)),
}

--Contains names of all icons that have been skinned
local SkinnedIcons = {}

--Need to throw this in the config at some point
local ICON_SIZE = 22

--Special stuff for mail icon
function MM:SkinMailIcon()
	local mail = MiniMapMailFrame
	mail:ClearAllPoints()
	mail:SetPoint('TOPRIGHT', Minimap, 'TOPRIGHT', -5, -2)
	mail:SetSize(16, 16)
	MiniMapMailIcon:SetAllPoints(mail)
	-- MiniMapMailIcon:SetTexCoord(unpack(S.iconcoords))
	MiniMapMailIcon:SetTexture(S.TEXTURE_PATHS.mail)
	MiniMapMailBorder:SetTexture(nil)
end

function MM:SkinTrackingIcon()
	local track = MiniMapTracking
	track.button = MiniMapTrackingButton
	track.icon = MiniMapTrackingIcon

	local name = track:GetName()

	track.button:SkinButton(true)
	track.button:SetPushedTexture(nil)
	track.button:SetHighlightTexture(nil)
	track.button:SetDisabledTexture(nil)
	track.button:SetAllPoints(track)

	track.icon:SetAllPoints(track)
	track.icon:SetDrawLayer('OVERLAY')
	track.icon:SetParent(track.button)
	track.button:HookScript('Onclick', function() track.icon:SetAllPoints() end)

	track:SetSize(ICON_SIZE, ICON_SIZE)
	track:SetParent(MM.IconTray)
	track:SetTemplate('TS')

	for _,region in pairs({track.button:GetRegions()}) do
		if region:GetObjectType() == 'Texture' then
			local texture = region:GetTexture()
			if not texture then return end

			if texture:find('Background') or texture:find('Border') or texture:find('AlphaMask') then
					region:SetTexture(nil)
			else
				-- region:ClearAllPoints()
				-- region:SetInside(track.button)
				-- region:SetTexCoord(unpack(S.iconcoords))
				-- region:SetDrawLayer('OVERLAY')
				-- track.button:SetTemplate("TS")
			end
		end
	end

	SkinnedIcons[name] = true
end

--Create the tray
function MM:InitializeIconTray()
	local iconTray = CreateFrame('frame', 'SaftUI_IconTray', Minimap)
	iconTray:SetPoint('TOPRIGHT', self.Container, 'BOTTOMRIGHT', 0, -S.borderinset)
	iconTray:SetSize(ICON_SIZE, 1)
	iconTray:Hide()

	local open = CreateFrame('frame', 'SaftUI_IconTrayButton', Minimap)
	iconTray.open = open

	local r, g, b = unpack(S.Saved.profile.General.Colors.backdrop)

	open.icon = open:CreateTexture(nil, 'OVERLAY')
	open.icon:SetTexture(S.TEXTURE_PATHS.cornerbr)
	open.icon:SetVertexColor(r, g, b)
	open.icon:SetAllPoints()

	open:SetSize(16, 16)
	open:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMRIGHT', 0, 0)

	open:EnableMouse(true)
	open:SetScript('OnEnter', function(self) self.icon:SetVertexColor(0, 170/255, 1) end)
	open:SetScript('OnLeave', function(self) self.icon:SetVertexColor(r, g, b) end)
	open:SetScript('OnMouseDown', function() ToggleFrame(iconTray) end)

	self.IconTray = iconTray
end

--Takes care of the actual icon skinning
function MM:SkinIcon(frame)
	local name = frame:GetName()

	frame:SkinButton(true)
	frame:SetPushedTexture(nil)
	frame:SetHighlightTexture(nil)
	frame:SetDisabledTexture(nil)
	
	frame:SetSize(ICON_SIZE, ICON_SIZE)
	frame:SetParent(MM.IconTray)

	for _,region in pairs({frame:GetRegions()}) do
		if region:GetObjectType() == 'Texture' then
			local texture = region:GetTexture()
			if not texture then return end

			if texture:find('Background') or texture:find('Border') or texture:find('AlphaMask') then
					region:SetTexture(nil)
			else
				region:ClearAllPoints()
				region:SetInside(frame)
				region:SetTexCoord(unpack(S.iconcoords))
				region:SetDrawLayer('ARTWORK')
				if NewIconTextures[name] then region:SetTexture(NewIconTextures[name]) end
				frame:SetTemplate("TS")
			end
		end
	end

	SkinnedIcons[name] = true
end

--Loops through minimap children to check for icons that need to be skinned, then organizes icons
function MM:SkinIcons()
	for _,child in pairs({Minimap:GetChildren()}) do
		local name = child:GetName()
		if name and child:GetObjectType() == 'Button' and not (BLACKLIST[name] or SkinnedIcons[name]) then
			self:SkinIcon(child)
		end
	end

	self:OrganizeIcons()
end

--Anchors icons to the tray
function MM:OrganizeIcons()
	local prev
	for name,_ in pairs(SkinnedIcons) do
		local frame = _G[name]
		if frame:IsShown() then
			if not prev then
				frame:ClearAllPoints()
				frame:SetPoint('TOP', self.IconTray, 'TOP', 0, 0)
			else
				frame:SetPoint('TOP', prev, 'BOTTOM', 0, -S.borderinset)
			end
			prev = frame
		end
	end
end