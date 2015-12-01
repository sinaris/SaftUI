-- local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local AddonName, Engine = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", 'AceHook-3.0');
-- local Locale = LibStub("AceLocale-3.0"):GetLocale(AddonName, false);

Engine[1] = Addon; -- Addon/Functions/Utilities
Engine[2] = {} --Locale -- Locales
Engine[3] = LibStub('LibStringFormat-1.0')

function Engine:unpack()
	return self[1], self[2], self[3]
end

_G.SaftUI = Engine

--Create a basic options table for Ace GUI
Addon.options = {
	name = AddonName,
	type = 'group',
	handler = Addon,
	args = {},
}