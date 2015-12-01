local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CHT = S:GetModule('Chat')


local gsub = gsub
local color = "00aaff"

local function PrintURL(url)
	return "|cff"..color.."|Hurl:"..url.."|h["..url.."]|h|r "
end

local FindURL = function(self, event, msg, ...)
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", PrintURL("%1://%2"))
	if found > 0 then return false, newMsg, ... end
	
	newMsg, found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", PrintURL("www.%1.%2"))
	if found > 0 then return false, newMsg, ... end

	newMsg, found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", PrintURL("%1@%2%3%4"))
	if found > 0 then return false, newMsg, ... end
end

for _,event in pairs({
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_YELL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_CONVERSATION",
}) do ChatFrame_AddMessageEventFilter(event, FindURL) end

local currentLink = nil
local ChatFrame_OnHyperlinkShow_Original = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(self, link, ...)
	if (link):sub(1, 3) == "url" then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		currentLink = (link):sub(5)
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:Insert(currentLink)
		ChatFrameEditBox:HighlightText()
		currentLink = nil
		return
	end
	ChatFrame_OnHyperlinkShow_Original(self, link, ...)
end