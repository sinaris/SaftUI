local S, L, F = SaftUI:unpack()
local LSM = LibStub('LibSharedMedia-3.0')

local CHT = S:GetModule('Chat')

S.options.args['Chat'] = {
	type = 'group',
	name = 'Chat',
	args = {
		general = {
			type = 'group',
			name = 'General',
			order = 1,
			guiInline = true,
			get = function(info) return S.Saved.profile.Chat[info[#info]] end,
			set = function(info, value) S.Saved.profile.Chat[info[#info]] = value; end,
			args = {
				['rightchat'] = { --font face
					type = 'select',
					order = 1,
					name = 'Right Chat',
					get = function(info) return S.Saved.profile.Chat.rightchat end,
					set = function(info, value) 
						local oldRightChat = S.Saved.profile.Chat.rightchat
						S.Saved.profile.Chat.rightchat = value;
						CHT:PositionChatFrame(oldRightChat)
						CHT:PositionChatFrame(S.Saved.profile.Chat.rightchat)
					end,
					values = CHT:GetChannelHash(),
				},
				['linespacing'] = {
					type = 'range',
					order = 2,
					name = 'Line Spacing',
					desc = '|cffcc4d4dWarning: requires a UI reload to take effect.|r',
					get = function(info) return S.Saved.profile.Chat[info[#info]] end,
					set = function(info, value) S.Saved.profile.Chat[info[#info]] = value; CHT:UpdateChatFonts() end,
					min=0,max=10,step=1,
				},
			},
		},
	},
}

for i,SIDE in pairs({'Left', 'Right'}) do
	S.options.args.Chat.args[SIDE] = {
		type = 'group',
		name = SIDE..' Panel',
		guiInline = true,
		order = i+2,
		get = function(info) return S.Saved.profile.Chat[SIDE][info[#info]] end,
		set = function(info, value) S.Saved.profile.Chat[SIDE][info[#info]] = value; CHT:UpdatePanels() end,
		args = {
			background = {
				type = 'toggle',
				order = 1,
				name = 'Background',
			},
			height = {
				order = 2,
				type = 'range',
				name = 'Height',
				min = 80, max = 600, step = 1,
			},
			width = {
				order = 3,
				type = 'range',
				name = 'Width',
				min = 250, max = 600, step = 1,
			},
			framelevel = {
				order = 4,
				name = 'Frame Level',
				type = 'range',
				min=0,max=99,step=1,
			},
			point = {
				type = 'group',
				name = 'Position',
				inline = true,
				order = 5,
				get = function(info) return tostring(S.Saved.profile.Chat[SIDE][info[#info-1]][tonumber(info[#info])]) end,
				set = function(info, value) S.Saved.profile.Chat[SIDE][info[#info-1]][tonumber(info[#info])] = value; CHT:UpdatePanels() end,
				args = {
					['1'] = {
						order = 1,
						width = 'half',
						name = 'Point',
						type = 'select',
						values = S:GetPointsTable(),
					},
					['2'] = {
						order = 2,
						validate = function(info, value) return S.ValidateInput(value, 'frame') end,
						name = 'Anchor Frame',
						desc = 'The global name of the frame that you wish to anchor this bar to. type /fstack and mouse over a frame to get its global name.',
						type = 'input',
					},
					['3'] = {
						order = 3,
						width = 'half',
						name = 'Relative Point',
						type = 'select',
						values = S:GetPointsTable(),
					},
					['4'] = {
						order = 4,
						width = 'half',
						validate = function(info, value) return S.ValidateInput(value, 'number') end,
						name = 'X-Offset',
						type = 'input',
					},
					['5'] = {
						order = 5,
						width = 'half',
						validate = function(info, value) return S.ValidateInput(value, 'number') end,
						name = 'Y-Offset',
						type = 'input',
					},
				}
			},
		},
	}
end
		