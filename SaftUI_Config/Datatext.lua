local S, L, F = SaftUI:unpack()
local DT = S:GetModule('DataText')

function DT:AddConfigSlot(index)
	print(getn(S.options.args['DataText'].args)+1)
	S.options.args['DataText'].args[tostring(index)] = {
		type = 'select',
		order = index,
		name = ' ',
		width = 'half',
		values = DT:GetModuleHash(),
		get = function(info) return S.Saved.profile.DataText.Positions[tostring(index)] end,
		set = function(info, value) DT:UpdateModuleConfig(value, index) end,
	}
end

function DT:RemoveConfigSlot(slot)
	S.options.args['DataText'].args[tostring(slot)]=nil
end

S.options.args['DataText'] = {
	type = 'group',
	name = 'Data Text',
	order = 3,
	args = {
	},
}