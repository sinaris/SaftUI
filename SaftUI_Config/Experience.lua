local S, L, F = SaftUI:unpack()
local LSM = LibStub('LibSharedMedia-3.0')

local XP = S:GetModule('Experience')


S.options.args['Experience'] = {
	type = 'group',
	name = 'Experience',
	get = function(info) return S.Saved.profile.Experience[info[#info]] end,
	set = function(info, value) S.Saved.profile.Experience[info[#info]] = value; XP:UpdateDisplay() end,
	args = {
		enable = {
			order = 1,
			width = 'half',
			type = 'toggle',
			name = 'Enable',
		},
		height = {
			order = 2,
			type = 'range',
			name = 'Height',
			min = 1, softMax = 50, step = 1,
		},
		width = {
			order = 3,
			type = 'range',
			name = 'Width',
			min = 1, softMax = 600, step = 1,
		},
		textvisibility = {
			type = 'select',
			order = 1,
			width = 'half',
			name = 'Text visibility',
			values = {['ALWAYS'] = 'Always', ['MOUSEOVER'] = 'Mouseover', ['NEVER'] = 'Never'},
		},
		point = {
			type = 'group',
			name = 'Position',
			inline = true,
			order = 4,
			get = function(info) return tostring(S.Saved.profile.Experience[info[#info-1]][tonumber(info[#info])]) end,
			set = function(info, value) S.Saved.profile.Experience[info[#info-1]][tonumber(info[#info])] = value; XP:UpdateDisplay() end,
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
		backdrop = {
			type = 'group',
			name = 'Backdrop', 
			order = 4,
			inline = true,
			get = function(info) return S.Saved.profile.Experience['backdrop'][info[#info]] end,
			set = function(info, value) S.Saved.profile.Experience['backdrop'][info[#info]] = value; XP:UpdateDisplay() end,
			args = {
				enable = {
					order = 1,
					name = 'Enable', 
					type = 'toggle',
					width = 'half',
				},
				transparent = {
					order = 2,
					name = 'Transparent',
					type = 'toggle',
					width = 'half',
				},
				insets = {
					type = 'group',
					name = 'insets',
					order = 3,
					inline = true,
					get = function(info) return tostring(S.Saved.profile.Experience['backdrop']['insets'][info[#info]]) end,
					set = function(info, value) S.Saved.profile.Experience['backdrop']['insets'][info[#info]] = tonumber(value); XP:UpdateDisplay() end,
					args = {
						left = {
							type = 'input',
							order = 1,
							name = 'Left',
							pattern = '%d',
							width = 'half',
						},
						top = {
							type = 'input',
							order = 2,
							name = 'Top',
							pattern = '%d',
							width = 'half',
						},
						right = {
							type = 'input',
							order = 3,
							name = 'Right',
							pattern = '%d',
							width = 'half',
						},
						bottom = {
							type = 'input',
							order = 4,
							name = 'Bottom',
							pattern = '%d',
							width = 'half',
						},
					},	
				},
			},
		},
	}
}