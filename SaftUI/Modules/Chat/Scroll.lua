local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local CHT = S:GetModule('Chat')

--Lets improve the default scroll:
-- No modifier - scrolls 3 lines at a time
-- Alt 				 - scrolls 1 line at a time
-- Shift 			 - scrolls a page at a time
-- Ctrl 			 - scrolls all the way up or down

local numlines = 3
function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta < 0 then
		if IsControlKeyDown() then
			self:ScrollToBottom()
		elseif IsShiftKeyDown() then
			self:PageDown()
		elseif IsAltKeyDown() then
			self:ScrollDown()
		else
			for i=1, numlines do
				self:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsControlKeyDown() then
			self:ScrollToTop()
		elseif IsShiftKeyDown() then
			self:PageUp()
		elseif IsAltKeyDown() then
			self:ScrollUp()
		else
			for i=1, numlines do
				self:ScrollUp()
			end
		end
	end
end