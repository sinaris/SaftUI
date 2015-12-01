local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat


local LSM = LibStub('LibSharedMedia-3.0')

S:GetModule('Skinning').AddonSkins['DBM-Core'] = function()
	
end





local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat


local LSM = LibStub('LibSharedMedia-3.0')

S:GetModule('Skinning').AddonSkins['Blizzard_GuildBankUI'] = function()
	GuildBankFrame:SetTemplate('KT')
	GuildBankEmblemFrame:Kill()

	--Skin the buttons
	for c=1, NUM_GUILDBANK_COLUMNS do
		_G['GuildBankColumn'..c]:StripTextures()
		for b=1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			_G['GuildBankColumn'..c..'Button'..b]:SkinActionButton()
		end
	end

	--Skin the tabs
	for t=1, MAX_GUILDBANK_TABS do

	end
end