local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LT = S:GetModule('Loot')

function LT:CheckAutoRoll(event, rollid, time)
	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollid)
	local autoroll = false

	--If you can't need on the item, then there is no decision to make
	if not canNeed then autoroll = true end
	if quality == 2 then autoroll = true end
	if strfind(name,'Timeless') then autoroll = true end

	if autoroll then ConfirmLootRoll(rollid, 2) end	
end

function LT:InitializeAutoLoot()

	-- self:SecureHook('START_LOOT_ROLL', CheckAutoRoll)

	-- local autoroll = CreateFrame('frame')
	-- autoroll:RegisterEvent('START_LOOT_ROLL')
	-- autoroll:SetScript('OnEvent', self.CheckAutoRoll)
	-- self:RegisterEvent('START_LOOT_ROLL', CheckAutoRoll)
end