local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local CHT = S:GetModule('Chat')

local PRIMARY_SPEC = GetSpellInfo(63645);
local SECONDARY_SPEC = GetSpellInfo(63644);

local strings = {
	gsub(ERR_LEARN_SPELL_S, '%%s.', ''),
	gsub(ERR_LEARN_ABILITY_S, '%%s.', ''),
	gsub(ERR_LEARN_PASSIVE_S, '%%s.', ''),
	gsub(ERR_SPELL_UNLEARNED_S, '%%s.', ''),
	gsub(ERR_PET_LEARN_SPELL_S, '%%s.', ''),
	gsub(ERR_PET_LEARN_ABILITY_S, '%%s.', ''),
	gsub(ERR_PET_SPELL_UNLEARNED_S, '%%s.', ''),
	gsub(NEW_TITLE_EARNED, '\'%%s\'.', ''),
	gsub(OLD_TITLE_LOST, '\'%%s\'.', ''),
}

local function TalentSpamFilter(self, event, msg)
	for _,string in pairs(strings) do
		if strfind(msg, string) then
			return true
		end
	end
end

function CHT:SetRespecState(event, unit, spellName)
	-- We don't care about anything other than these two
	if not ((spellName == PRIMARY_SPEC) or (spellName == SECONDARY_SPEC)) then return end

	-- If spellcast is started and either spec is found as spell, set to true
	if event == 'UNIT_SPELLCAST_START' then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TalentSpamFilter);

	-- If spellcast is stopped and either spec is found as spell, set to false
	elseif event == 'UNIT_SPELLCAST_STOP' then
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", TalentSpamFilter);
	end
end