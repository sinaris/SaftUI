local S, L, F = SaftUI:unpack()

local UF = S:GetModule('UnitFrames')
local LSM = LibStub('LibSharedMedia-3.0')
local testmode = false

S.options.args['UnitFrames'] = {
	type = 'group',
	name = 'Unit Frames',
	args = {
		enable = {
			type = 'toggle',
			name = 'Enable',
			width='half',
			order = 1,
			get = function(info) return S.Saved.profile.UnitFrames[info[#info]] end,
			set = function(info, value) S.Saved.profile.UnitFrames[info[#info]] = value; if value then UF:OnEnable() else UF:OnDisable() end; end,
		},
		testmode = {
			order = 1,
			type = 'toggle',
			name = 'Enable Test Mode',
			desc = 'Forces every unitframe to be shown. |cff'.. F:ToHex(.8,.3,.3) ..' Do not enable this if you have a chance of going into combat!|r',
			get = function(info) return testmode end,
			set = function(info, value) testmode = not testmode; UF.oUF:SetTestMode(testmode) end,
		},
		portrait = {
			type = 'group',
			name = 'Portrait',
			guiInline = true, --Pull this out of the tabs
			order = 2,
			get = function(info) return S.Saved.profile.UnitFrames.portrait[info[#info]] end,
			set = function(info, value) S.Saved.profile.UnitFrames.portrait[info[#info]] = value; UF:UpdateAllUnits() end,
			args = {
				enable = {	
					order = 1,
					type = 'toggle',
					name = 'Enable',
				},
				alpha = {
					order = 2,
					type  = 'range',
					name = 'Alpha',
					min = 0, max = 1, step = .01,
				},
			},
		},
	},
}

for unit,_ in pairs(S.DefaultConfig.profile.UnitFrames.Units) do
	S.options.args.UnitFrames.args[unit] = {
		type = 'group',
		childGroups = 'tab',
		name = unit,
		order = #S.options.args.UnitFrames.args+1,
		get = function(info) return S.Saved.profile.UnitFrames.Units[unit][info[#info]] end,
		set = function(info, value) S.Saved.profile.UnitFrames.Units[unit][info[#info]] = value; UF:UpdateUnit(unit, info[#info]); end,
		args = {
			enable = {
				order = 1,
				type = 'toggle',
				name = 'Enable',
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit][info[#info]] = value; UF:UpdateUnit(unit, 'position'); end,
			},
			height = {
				order = 2,
				type = 'input',
				name = 'Height',
				get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit][info[#info]]) end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit][info[#info]] = tonumber(value); UF:UpdateUnit(unit, 'size'); end,
				pattern = '%d',
			},
			width = {
				order = 3,
				type = 'input',
				name = 'Width',
				get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit][info[#info]]) end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit][info[#info]] = tonumber(value); UF:UpdateUnit(unit, 'size'); end,
				pattern = '%d',
			},
			point = {
				type = 'group',
				name = 'Position',
				inline = true,
				order = 4,
				get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit].point[tonumber(info[#info])]) end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit].point[tonumber(info[#info])] = value; UF:UpdateUnit(unit, 'position') end,
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
						name = 'Parent',
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
				width = 'half',
				order = 4,
				inline = true,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['backdrop'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['backdrop'][info[#info]] = value UF:UpdateUnit(unit, 'position') end,
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
				},
			},
			name = {
				type = 'group',
				name = 'Name', 
				order = 5,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['name'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['name'][info[#info]] = value; UF:UpdateUnit(unit, 'name') end,
				args = {
					enable = {
						order = 1,
						name = 'Enable', 
						type = 'toggle',
					},
					maxlength = {
						order = 2,
						type  = 'range',
						name = 'length',
						min = 1, max = 30, step = 1,
					},
					showlevel = {
						order=3,
						name = 'Show Level',
						type = 'toggle',
					},
					point = {
						order = 4, 
						name = 'Point',
						type = 'select',
						values = S:GetPointsTable(),
					},
					xoffset = {
						order = 5,
						name = 'X-Offset',
						type = 'range',
						softMin=-50,softMax=50,step=1,
					},
					yoffset = {
						order = 6,
						name = 'Y-Offset',
						type = 'range',
						softMin=-50,softMax=50,step=1,
					},
				},
			},
			portrait = {
				type = 'group',
				name = 'Portrait',
				order = 8,
				-- inline = true,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['portrait'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['portrait'][info[#info]] = value; UF:UpdateUnit(unit, 'portrait') end,
				args = {
					enable = {	
						order = 1,
						type = 'toggle',
						name = 'Enable',
					},
				},
			},
			health = {
				type = 'group',
				name = 'Health',
				order = 9,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['health'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health'][info[#info]] = value; UF:UpdateUnit(unit, 'power'); UF:UpdateUnit(unit, 'health') end,
				args = {
					enable = {
						type = 'toggle',
						name = 'Enable', 
						order = 1,
					},
					vertical = {
						type = 'toggle',
						name = 'Fill Vertical',
						desc = 'Health bar fills/shrinks vertically instead of horizontally',
						order = 2,				},
					reversefill = {
						type = 'toggle',
						name = 'Reverse Fill',
						desc = 'Health bar drains towards the right (or towards the top if vertically oriented)',
						order = 3,
					},
					position = {
						type = 'group',
						name = 'Position',
						order = 4,
						inline = true,
						get = function(info)
							return S.Saved.profile.UnitFrames.Units[unit]['health'][info[#info]];
						end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health'][info[#info]] = value UF:UpdateUnit(unit, 'health') end,
						args = {
							height = {
								order = 1,
								type = 'range',
								name = 'Height',
								min = 1, softMax = 50, step = 1,
							},
							width = {
								order = 2,
								type = 'range',
								name = 'Width',
								min = 1, softMin = 20,
								max = 600, step = 1,
							},
							point = {
								order = 3,
								name = 'Point',
								type = 'select',
								values = S:GetPointsTable(),
							},
							xoffset = {
								order = 4,
								name = 'X-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							yoffset = {
								order = 5,
								name = 'Y-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							framelevel = {
								order = 6,
								name = 'Frame Level',
								type = 'range',
								min=0,max=99,step=1,
							},
						},
					},
					backdrop = {
						type = 'group',
						name = 'Backdrop', 
						order = 4,
						inline = true,
						get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['health']['backdrop'][info[#info]] end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health']['backdrop'][info[#info]] = value UF:UpdateUnit(unit, 'health') end,
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
								get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit]['health']['backdrop']['insets'][info[#info]]) end,
								set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health']['backdrop']['insets'][info[#info]] = tonumber(value); UF:UpdateUnit(unit, 'health') end,
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
					text = {
						type = 'group',
						name = 'Text', 
						order = 5,
						inline = true,
						get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['health']['text'][info[#info]] end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health']['text'][info[#info]] = value UF:UpdateUnit(unit, 'health') end,
						args = {
							enable = {
								order = 1,
								name = 'Enable', 
								type = 'toggle',
							},
							hideFullValue = {
								order = 2,
								name = 'Hide if full', 
								type = 'toggle',
							},
							point = {
								order = 4, 
								name = 'Point',
								type = 'select',
								values = S:GetPointsTable(),
							},
							xoffset = {
								order = 5,
								name = 'X-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							yoffset = {
								order = 6,
								name = 'Y-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							customtext ={
								type = 'group',
								name = 'Custom Text',
								order = 7,
								inline = true,
								get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['health']['text']['customtext'][info[#info]] end,
								set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health']['text']['customtext'][info[#info]] = value; UF:UpdateUnit(unit, 'health') end,
								args = {
									enable = {
										order = 1,
										name = 'Enable', 
										type = 'toggle',
									},
									funcString = {
										order = 2,
										name = 'Custom Text Function',
										type = 'input',
										width = 'full',
										get = function(info) return gsub(S.Saved.profile.UnitFrames.Units[unit]['health']['text']['customtext'][info[#info]], "|", "||") end,
										set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['health']['text']['customtext'][info[#info]] = gsub(value, "|+", "|"); UF:UpdateUnit(unit, 'health') end,
										disabled = function() return not S.Saved.profile.UnitFrames.Units[unit].health.text.customtext.enable end,
										hidden = function() return not S.Saved.profile.UnitFrames.Units[unit].health.text.customtext.enable end,
										multiline = 15,
										validate = function(info, string) return select(2, loadstring(string)) or true end,
									}
								}
							}
						},			
					},
				},
			},
			power = {
				type = 'group',
				name = 'Power',
				order = 10,
				-- inline = true,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['power'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power'][info[#info]] = value; UF:UpdateUnit(unit, 'power'); UF:UpdateUnit(unit, 'health') end,
				args = {
					enable = {
						type = 'toggle',
						name = 'Enable', 
						order = 1,
					},
					vertical = {
						type = 'toggle',
						name = 'Fill Vertical',
						desc = 'Power bar fills/shrinks vertically instead of horizontally',
						order = 2,
					},
					reversefill = {
						type = 'toggle',
						name = 'Reverse Fill',
						desc = 'Power bar drains towards the right (or towards the top if vertically oriented)',
						order = 3,
					},
					position = {
						type = 'group',
						name = 'Position',
						order = 4,
						inline = true,
						get = function(info)
							return S.Saved.profile.UnitFrames.Units[unit]['power'][info[#info]];
						end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power'][info[#info]] = value UF:UpdateUnit(unit, 'power') end,
						args = {
							height = {
								order = 1,
								type = 'range',
								name = 'Height',
								min = 1, softMax = 50, step = 1,
							},
							width = {
								order = 2,
								type = 'range',
								name = 'Width',
								min = 1, softMin = 20,
								max = 600, step = 1,
							},
							point = {
								order = 3,
								name = 'Point',
								type = 'select',
								values = S:GetPointsTable(),
							},
							xoffset = {
								order = 4,
								name = 'X-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							yoffset = {
								order = 5,
								name = 'Y-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							framelevel = {
								order = 6,
								name = 'Frame Level',
								type = 'range',
								min=0,max=99,step=1,
							},
						},
					},
					backdrop = {
						type = 'group',
						name = 'Backdrop', 
						order = 4,
						inline = true,
						get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['power']['backdrop'][info[#info]] end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power']['backdrop'][info[#info]] = value UF:UpdateUnit(unit, 'power') end,
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
								get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit]['power']['backdrop']['insets'][info[#info]]) end,
								set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power']['backdrop']['insets'][info[#info]] = tonumber(value); UF:UpdateUnit(unit, 'power') end,
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
					text = {
						type = 'group',
						name = 'Power Text', 
						order = 5,
						inline = true,
						get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['power']['text'][info[#info]] end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power']['text'][info[#info]] = value UF:UpdateUnit(unit, 'power') end,
						args = {
							enable = {
								width = 'half',
								order = 1,
								name = 'Enable', 
								type = 'toggle',
							},
							hideFullValue = {
								width = 'half',
								order = 2,
								name = 'Hide if full', 
								type = 'toggle',
							},
							point = {
								order = 4, 
								name = 'Point',
								type = 'select',
								values = S:GetPointsTable()
							},
							xoffset = {
								order = 5,
								name = 'X-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							yoffset = {
								order = 6,
								name = 'Y-Offset',
								type = 'range',
								softMin=-50,softMax=50,step=1,
							},
							customtext ={
								type = 'group',
								name = 'Custom Text',
								order = 7,
								inline = true,
								get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['power']['text']['customtext'][info[#info]] end,
								set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power']['text']['customtext'][info[#info]] = value; UF:UpdateUnit(unit, 'power') end,
								args = {
									enable = {
										order = 1,
										name = 'Enable', 
										type = 'toggle',
									},
									funcString = {
										order = 2,
										name = 'Custom Text Function',
										type = 'input',
										width = 'full',
										get = function(info) return gsub(S.Saved.profile.UnitFrames.Units[unit]['power']['text']['customtext'][info[#info]], "|", "||") end,
										set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['power']['text']['customtext'][info[#info]] = gsub(value, "|+", "|"); UF:UpdateUnit(unit, 'power') end,
										disabled = function() return not S.Saved.profile.UnitFrames.Units[unit].power.text.customtext.enable end,
										multiline = 15,
										validate = function(info, string) return select(2, loadstring(string)) or true end,
									}
								}
							},
						},
					},	
				},
			},
			castbar = {
				type = 'group',
				name = 'Castbar',
				order = 10,
				-- inline = true,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['castbar'][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['castbar'][info[#info]] = value; UF:UpdateUnit(unit, 'castbar'); end,
				args = {
					enable = {
						type = 'toggle',
						name = 'Enable', 
						order = 1,
					},
					height = {
						order = 1,
						type = 'range',
						name = 'Height',
						min = 1, softMax = 50, step = 1,
					},
					width = {
						order = 2,
						type = 'range',
						name = 'Width',
						min = 1, softMin = 20,
						max = 600, step = 1,
					},
					point = {
						type = 'group',
						name = 'Position',
						inline = true,
						order = 4,
						get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit].castbar.point[tonumber(info[#info])]) end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit].castbar.point[tonumber(info[#info])] = value; UF:UpdateUnit(unit, 'castbar') end,
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
								desc = 'If left blank, unit frame will be used as anchor',
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
						get = function(info) return S.Saved.profile.UnitFrames.Units[unit]['castbar']['backdrop'][info[#info]] end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['castbar']['backdrop'][info[#info]] = value; UF:UpdateUnit(unit, 'castbar') end,
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
								get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit]['castbar']['backdrop']['insets'][info[#info]]) end,
								set = function(info, value) S.Saved.profile.UnitFrames.Units[unit]['castbar']['backdrop']['insets'][info[#info]] = tonumber(value); UF:UpdateUnit(unit, 'castbar') end,
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
			buffs = {
				type = 'group',
				name = 'Buffs',
				order = 11,
				get = function(info) return S.Saved.profile.UnitFrames.Units[unit][info[#info-1]][info[#info]] end,
				set = function(info, value) S.Saved.profile.UnitFrames.Units[unit][info[#info-1]][info[#info]] = value UF:UpdateUnit(unit, 'buffs') end,
				args = {
					enable = {
						order = 1,
						name = 'Enable', 
						type = 'toggle',
					},
					size = {
						type = 'range',
						name = 'Size', 
						order = 2,
						min=5, max=50, step=1,
					},
					spacing = {
						type = 'range',
						name = 'Spacing', 
						order = 2,
						softMin=0, softMax=15, step=1,
					},
					point = {
						type = 'group',
						name = 'Position',
						inline = true,
						order = 4,
						get = function(info) return tostring(S.Saved.profile.UnitFrames.Units[unit].buffs.point[tonumber(info[#info])]) end,
						set = function(info, value) S.Saved.profile.UnitFrames.Units[unit].buffs.point[tonumber(info[#info])] = value; UF:UpdateUnit(unit, 'buffs') end,
						args = {
							['1'] = {
								order = 1,
								name = 'Point',
								type = 'select',
								values = S:GetPointsTable(),
							},
							['2'] = {
								order = 2,
								name = 'Relative Point',
								type = 'select',
								values = S:GetPointsTable(),
							},
							['3'] = {
								order = 3,
								width = 'half',
								validate = function(info, value) return S.ValidateInput(value, 'number') end,
								name = 'X-Offset',
								type = 'input',
							},
							['4'] = {
								order = 4,
								width = 'half',
								validate = function(info, value) return S.ValidateInput(value, 'number') end,
								name = 'Y-Offset',
								type = 'input',
							},
						}
					},
				}
			},
		},
	}
end

S.options.args.UnitFrames.args['raid'].args['raiddebuffs'] = {
	type = 'group',
	name = 'Raid Debuffs',
	order = 9,
	get = function(info) return S.Saved.profile.UnitFrames.Units['raid']['raiddebuffs'][info[#info]] end,
	set = function(info, value) S.Saved.profile.UnitFrames.Units['raid']['raiddebuffs'][info[#info]] = value UF:UpdateUnit('raid', 'raiddebuffs') end,
	args = {
		enable = {
			type = 'toggle',
			name = 'Enable',
			order = 1,
		},
		size = {
			type = 'range',
			name = 'Size', 
			order = 2,
			min=5, max=50, step=1,
		},
	}
}