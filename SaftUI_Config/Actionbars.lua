local S, L, F = SaftUI:unpack()
-- local UF = S:GetModule('UnitFrames')
-- local AB = S:GetModule('ActionBars')
-- local CT = S:GetModule('Chat')
local LSM = LibStub('LibSharedMedia-3.0')
local AB = S:GetModule('ActionBars')

S.options.args['ActionBars'] = {
	type = 'group',
	name = 'Action Bars',
	childGroups = 'tab',
	order = 2,
	args = {
		enable = {
			type = 'toggle',
			name = 'Enable',
			descStyle = 'inline',
			width='full',
			order = 1,
			get = function(info) return S.Saved.profile.ActionBars[info[#info]] end,
			set = function(info, value) S.Saved.profile.ActionBars[info[#info]] = value; if value then AB:OnEnable() else AB:OnDisable() end; end,
		},
		style = {
			type = 'group',
			name = 'Style',
			guiInline = true, --Pull this out of the tabs
			order = 2,
			get = function(info) return S.Saved.profile.ActionBars[info[#info]] end,
			set = function(info, value) S.Saved.profile.ActionBars[info[#info]] = value; AB:UpdateActionBar(); AB:UpdateButtonConfig() end,
			args = {
				showgrid = {
					type = 'toggle',
					order = 1,
					name = 'Show empty slots',
				},
				hotkeytext = {
					type = 'toggle',
					order = 2,
					name = 'Show hotkeys',
				},
				showmacrotext = {
					type = 'toggle',
					order = 3,
					name = 'Show macro text',
				},
			},
		},
	},
}

function S.ValidateInput(input, desiredType, message)
	if desiredType == 'frame' then
		if _G[input] then
			return true

		else 
			return message or 'Frame does not exist'
		end
	elseif desiredType == 'number' then
		if tonumber(input) then
			return true
		else
			return message or 'Input must be a number'
		end
	end
end

for i=1, 5 do
	S.options.args.ActionBars.args['bar'..i] = {
		type = 'group',
		name = 'Bar '..i,
		order = i+2,
		get = function(info) return S.Saved.profile.ActionBars.Bars[i][info[#info]] end,
		set = function(info, value) S.Saved.profile.ActionBars.Bars[i][info[#info]] = value; AB:UpdateActionBar(i) end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = 'Enable',
				width='half',
			},
			vertical = {
				order = 2,
				type = 'toggle',
				name = 'Vertical',
				width='half',
			},
			mouseover = {
				order = 3,
				type = 'toggle',
				name = 'Show on hover',
				desc = 'Enable to only show this action bar when hovering over it',
				set = function(info, value) S.Saved.profile.ActionBars.Bars[i][info[#info]] = value; AB:UpdateActionBarVisibility(i) end,
			},
			buttonsize = {
				order = 4,
				type = 'range',
				name = 'Button size',
				min = 10, max = 50, step = 1,
			},
			buttonspacing = {
				order = 5,
				type = 'range',
				name = 'Button spacing',
				min = -5, max = 20, step = 1,
			},
			numbuttons = {
				order = 6,
				type = 'range',
				name = 'Number of buttons',
				min = 1, max = 12, step = 1,
			},
			point = {
				type = 'group',
				name = 'Position',
				inline = true,
				order = 7,
				get = function(info) return tostring(S.Saved.profile.ActionBars.Bars[i].point[tonumber(info[#info])]) end,
				set = function(info, value) S.Saved.profile.ActionBars.Bars[i].point[tonumber(info[#info])] = value; AB:UpdateActionBar(i) end,
				args = {
					['1'] = {
						order = 1,
						-- width = 'half',
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
						-- width = 'half',
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
			background = {
				type = 'group',
				inline = true,
				order = 8,
				name = 'Background',
				get = function(info) return S.Saved.profile.ActionBars.Bars[i].background[info[#info]] end,
				set = function(info, value) S.Saved.profile.ActionBars.Bars[i].background[info[#info]] = value; AB:UpdateActionBarBackground(i) end,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
					},
					anchor = {
						order = 1,
						name = 'Point',
						type = 'select',
						values = S:GetPointsTable(),
					},
					width = {
						order = 3,
						type = 'range',
						name = 'Width',
						min = 1, softMax = 24, max = 48, step = 1,
					},
					height = {
						order = 4,
						type = 'range',
						name = 'Width',
						min = 1, softMax = 24, max = 48, step = 1,

					},
				},
			},
		}
	}
end


--pet
S.options.args.ActionBars.args['petbar'] = {
		type = 'group',
		name = 'Pet Bar',
		order = 8,
		get = function(info) return S.Saved.profile.ActionBars.Bars['pet'][info[#info]] end,
		set = function(info, value) S.Saved.profile.ActionBars.Bars['pet'][info[#info]] = value; AB:UpdateActionBar('pet') end,
		args = {
			enabled = {
				order = 1,
				type = 'toggle',
				name = 'Enable',
				width='half',
			},
			vertical = {
				order = 2,
				type = 'toggle',
				name = 'Vertical',
				width='half',
			},
			mouseover = {
				order = 3,
				type = 'toggle',
				name = 'Show on hover',
				desc = 'Enable to only show this action bar when hovering over it',
				set = function(info, value) S.Saved.profile.ActionBars.Bars['pet'][info[#info]] = value; AB:UpdateActionBarVisibility('pet') end,
			},
			buttonsize = {
				order = 4,
				type = 'range',
				name = 'Button size',
				min = 10, max = 50, step = 1,
			},
			buttonspacing = {
				order = 5,
				type = 'range',
				name = 'Button spacing',
				min = -5, max = 20, step = 1,
			},
			point = {
				type = 'group',
				name = 'Position',
				inline = true,
				order = 7,
				get = function(info) return tostring(S.Saved.profile.ActionBars.Bars['pet'].point[tonumber(info[#info])]) end,
				set = function(info, value) S.Saved.profile.ActionBars.Bars['pet'].point[tonumber(info[#info])] = value; AB:UpdateActionBar('pet') end,
				args = {
					['1'] = {
						order = 1,
						-- width = 'half',
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
						-- width = 'half',
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
			background = {
				type = 'group',
				inline = true,
				order = 8,
				name = 'Background',
				get = function(info) return S.Saved.profile.ActionBars.Bars['pet'].background[info[#info]] end,
				set = function(info, value) S.Saved.profile.ActionBars.Bars['pet'].background[info[#info]] = value; AB:UpdateActionBarBackground('pet') end,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
					},
					anchor = {
						order = 1,
						name = 'Point',
						type = 'select',
						values = S:GetPointsTable(),
					},
					width = {
						order = 3,
						type = 'range',
						name = 'Width',
						min = 1, softMax = 24, max = 48, step = 1,
					},
					height = {
						order = 4,
						type = 'range',
						name = 'Width',
						min = 1, softMax = 24, max = 48, step = 1,

					},
				},
			},
		}
	}