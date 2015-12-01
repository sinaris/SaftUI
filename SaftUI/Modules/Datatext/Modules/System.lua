local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local DT = S:GetModule('DataText')

local logCPU = GetCVar('scriptProfile') == 1
local systemTable = {}
local totemMemory = 0

local function UpdateSystemTable()
	totalMemory = 0
	systemTable = {}


	for i=1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		local usage = GetAddOnMemoryUsage(i)*1024
		systemTable[i] = {
			name = title,
			memory = usage,
		}
		totalMemory = totalMemory + usage
	end

	sort(systemTable, function(a,b) return a.memory>b.memory end)
end

local function UpdateTooltip(self)
	local Upload, Download = GetNetStats();
	
	DT:PositionTooltip(self)
	UpdateAddOnMemoryUsage()
	UpdateSystemTable()

	GameTooltip:AddDoubleLine('Total Memory', F:FileSizeFormat(totalMemory, 2), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddLine(' ')

	for i,system in pairs(systemTable) do
		if system.memory > 0 then
			GameTooltip:AddDoubleLine(system.name, F:FileSizeFormat(system.memory, 2), 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

local function Update(self, elapsed)
	self.lastUpdate = self.lastUpdate + elapsed; 	
	while (self.lastUpdate > 1) do
		local fps, ms = F:Round(GetFramerate()), F:Round(select(4, GetNetStats()))
		self.Text:SetFormattedText('%s FPS : %s MS', fps, ms)
		self.lastUpdate = self.lastUpdate - 1;
	end
end

local function Enable(self)
	-- SetCVar('scriptProfile', 1) --make sure CPu usage is enabled
	self.lastUpdate = 0
	self:SetScript('OnEnter', UpdateTooltip)
	self:SetScript('OnLeave', S.HideGameTooltip)
	self:SetScript('OnUpdate', Update)
	self:Update(1)
end

local function Disable(self)
	self:SetScript('OnEnter', nil)
	self:SetScript('OnLeave', nil)
	self:SetScript('OnUpdate', nil)
end

DT:RegisterDataModule('System', Enable, Disable, Update)