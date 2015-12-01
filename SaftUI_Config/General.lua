local S, L, F = SaftUI:unpack()
local LSM = LibStub('LibSharedMedia-3.0')

local MM = S:GetModule('Minimap')
local XP = S:GetModule('Experience')
local AU = S:GetModule('Auras')

--Create Profiles Table
S.options.args['profiles'] = LibStub("AceDBOptions-3.0"):GetOptionsTable(S.Saved);
LibStub('AceConfig-3.0'):RegisterOptionsTable("SaftUIProfiles", S.options.args.profiles)
S.options.args.profiles.order = -99 --make sure it's always at the bottom

local function CreateFontConfig(overwrite)
	return table.merge({
		type = 'group',
		name = 'Font',
		get = function(info) return S.Saved.profile.General.Fonts[info[#info-1]][tonumber(info[#info])] end,
		set = function(info, value) S.Saved.profile.General.Fonts[info[#info-1]][tonumber(info[#info])] = value; S:UpdateFontObjects(); end,
		order = 2,
		guiInline = true,
		args = {
			['1'] = {
				type = 'select',
				name = 'Font Face',
				order = 1,
				dialogControl = 'LSM30_Font',
				values = LSM:HashTable('font'),
			},
			['2'] = {
				type = 'range',
				name = 'Font Size',
				order = 2,
				min = 5, max = 16, step = 1,
			},
			['3'] = {
				type = 'select',
				name = 'Font Outline',
				order = 3,
				values = FONT_OUTLINE_TYPES,
			}
		},
	}, overwrite)
end

S.options.args['General'] = {
	type = 'group',
	name = 'General',
	order = 1,
	args = {
		style = {
			type = 'group',
			name = 'Style',
			order = 1,
			guiInline = true,
			get = function(info) return S.Saved.profile.General[info[#info]] end,
			set = function(info, value) S.Saved.profile.General[info[#info]] = value; StaticPopup_Show('SAFTUI_CONFIGRELOAD') ;end,
			args = {
				thinborder = {
					type = 'toggle',
					order = 1,
					name = 'Thin Border',
				},
				shadows = {
					type = 'toggle',
					order = 2,
					name = 'Shadows',
				},
				barTexture = {
					type = 'select',
					name = 'Bar Texture',
					get = function(info) return S.Saved.profile.General.barTexture end,
					set = function(info, value) S.Saved.profile.General.barTexture = value; S:UpdateStatusBarTextures(); end,
					order = 3,
					dialogControl = 'LSM30_Statusbar',
					values = LSM:HashTable('statusbar'),
				},
			},
		},
		fonts = {
			type = 'group',
			name = 'Fonts',
			order = 2,
			guiInline = true,
			args = {
				general = CreateFontConfig({name = 'General Font'}),
				pixel = CreateFontConfig({name = 'Pixel Font'}),
				chat = CreateFontConfig({name = 'Chat Font'}),
			},
		},
		minimap = {
			type = 'group',
			name = 'Minimap',
			order = 2,
			guiInline = true,
			args = {
				width = {
					order = 1,
					type = 'range',
					name = 'Minimap size',
					get = function(info) return S.Saved.profile.Minimap[info[#info]] end,
					set = function(info, value) S.Saved.profile.Minimap[info[#info]] = value; MM:UpdateDisplay() end,
					min = 80, max = 140, step = 1,
				},
				height = {
					order = 2,
					type = 'range',
					name = 'Minimap size',
					get = function(info) return S.Saved.profile.Minimap[info[#info]] end,
					set = function(info, value) S.Saved.profile.Minimap[info[#info]] = value; MM:UpdateDisplay() end,
					min = 80, max = 140, step = 1,
				},
				position = {
					type = 'group',
					name = 'Position',
					inline = true,
					order = 4,
					get = function(info) return tostring(S.Saved.profile.Minimap.position[tonumber(info[#info])]) end,
					set = function(info, value) S.Saved.profile.Minimap.position[tonumber(info[#info])] = value; MM:UpdateDisplay() end,
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
							validate = function(info, value) return value == '' or S.ValidateInput(value, 'frame') end,
							name = 'Parent',
							desc = 'Frame to anchor Minimap to',
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
					get = function(info) return S.Saved.profile.Minimap['backdrop'][info[#info]] end,
					set = function(info, value) S.Saved.profile.Minimap['backdrop'][info[#info]] = value; MM:UpdateDisplay() end,
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
							get = function(info) return tostring(S.Saved.profile.Minimap['backdrop']['insets'][info[#info]]) end,
							set = function(info, value) S.Saved.profile.Minimap['backdrop']['insets'][info[#info]] = tonumber(value); MM:UpdateDisplay() end,
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
			},
		},
		auras = {
			type = 'group',
			name = 'Auras',
			order = 4,
			guiInline = true,
			args = {
				position = {
					type = 'select',
					order = 1,
					name = 'Position',
					desc = 'Which side of the screen to place buffs and debuffs',
					get = function(info) return S.Saved.profile.Auras[info[#info]] end,
					set = function(info, value) S.Saved.profile.Auras[info[#info]] = value; AU:UpdateHeaderPosition() end,
					values = {['LEFT'] = 'Left', ['RIGHT'] = 'Right'},
				},
			},
		},
	},
}