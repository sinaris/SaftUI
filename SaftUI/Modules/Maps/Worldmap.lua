local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local WM = S:NewModule('Worldmap', 'AceHook-3.0', 'AceEvent-3.0')
local lastUpdate = 0
local updateInterval = 0.01

function WM:UpdatePlayerCoords()
	local posX, posY = GetPlayerMapPosition("player")
	self.playerCoords.text:SetFormattedText('P: %02d,%02d', floor(posX*100), floor(posY*100))
end

function WM:UpdateMouseCoords()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width, height = WorldMapDetailFrame:GetSize()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()

	local posX = (x / scale - (centerX - (width/2))) / width
	local posY = (centerY + (height/2) - y / scale) / height	

	if (posX >= 0  and posY >= 0 and posX <=1 and posY <=1) then
		self.mouseCoords.text:SetFormattedText('M: %s,%s', floor(posX*100), floor(posY*100))
	else
		self.mouseCoords.text:SetFormattedText('M: %s,%s', '00','00')
	end
end

function WM:UpdateCoords(frame, elapsed)
	lastUpdate = lastUpdate + elapsed

	if (lastUpdate > updateInterval) then
		self:UpdateMouseCoords()
		self:UpdatePlayerCoords()

		lastUpdate = 0
	end
end

function WM:EnableCoordUpdates()
	self:HookScript(WorldMapFrame, 'OnUpdate', 'UpdateCoords')
end

function WM:DisableCoordUpdates()
	self:Unhook(WorldMapFrame, 'OnUpdate')
end

function WM:SkinMap()
	local border = S.borderinset

	WorldMapFrame:StripTextures()

	WorldMapButton:CreateBackdrop()
	WorldMapButton.backdrop:SetFrameStrata('BACKGROUND')

	WorldMapFrameTitle:SetInside(WorldMapTitleButton)

	local playerCoords = CreateFrame('frame', 'WorldMapFramePlayerCoordinates', WorldMapFrame)
	playerCoords:SetTemplate()
	playerCoords:SetHeight(20)
	playerCoords:SetWidth(60)
	playerCoords:SetPoint('BOTTOMLEFT', WorldMapButton, 'TOPLEFT', -border, border+1)
	playerCoords.text = S.CreateFontString(playerCoords)
	playerCoords.text:SetAllPoints(playerCoords)
	self.playerCoords = playerCoords
	self:UpdatePlayerCoords()


	local mouseCoords = CreateFrame('frame', 'WorldMapFrameMouseCoordinates', WorldMapFrame)
	mouseCoords:SetTemplate()
	mouseCoords:SetHeight(20)
	mouseCoords:SetWidth(60)
	mouseCoords:SetPoint('LEFT', playerCoords, 'RIGHT', border, 0)
	mouseCoords.text = S.CreateFontString(mouseCoords)
	mouseCoords.text:SetAllPoints(mouseCoords)
	self.mouseCoords = mouseCoords
	self:UpdateMouseCoords()

	WorldMapTitleButton:ClearAllPoints()
	WorldMapTitleButton:SetPoint('LEFT', mouseCoords, 'RIGHT', border, 0)
	WorldMapTitleButton:SetPoint('RIGHT', WorldMapShowDropDown, 'LEFT', -(border), 0)
	WorldMapTitleButton:SetHeight(20)
	WorldMapTitleButton:CreateBackdrop()
	WorldMapTitleButton.backdrop:SetInside(0)
	WorldMapTitleButton.backdrop:SetFrameStrata('BACKGROUND')

	WorldMapShowDropDown:ClearAllPoints()
	WorldMapShowDropDown:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -border, 0)
	WorldMapShowDropDown:SetFrameLevel(91)
	WorldMapShowDropDown:SkinDropDown(100, 20)

	WorldMapLevelDropDown:SkinDropDown(150, 20)
	WorldMapLevelDropDown:ClearAllPoints()
	WorldMapLevelDropDown:SetPoint('TOPLEFT', WorldMapButton, 'TOPLEFT', border+2, -(border+2))

	WorldMapFrameSizeUpButton:Kill()

	WorldMapFrameCloseButton:SkinButton(false, 'x')
	WorldMapFrameCloseButton:SetSize(20, 20)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint('BOTTOMRIGHT', WorldMapButton, 'TOPRIGHT', border, border+1)

	--There's no reason to ever need the info on this, and it gets in the way of click POIs
	WorldMapPlayerUpper:EnableMouse(false)
end

function WM:OnEnable()
	self:SkinMap()

	self:HookScript(WorldMapFrame, 'OnShow', 'EnableCoordUpdates')
	self:HookScript(WorldMapFrame, 'OnHide', 'DisableCoordUpdates')

	self:LoadFogOfwar()
end