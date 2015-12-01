local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat



--This function creates a basic default configuration table 
-- for a unitframe. The parameter overwrite is an optional
-- table which you can pass to overwrite whichever values
-- you wish, such as the default width and position.
local function CreateUnitConfigTable(overwrite)
	return table.merge({
		enable = true,
		backdrop = {
			enable = true,
			transparent = true,
		},
		width = 197,
		height = 30,
		point = {'TOPRIGHT','UIParent','CENTER',0, 0},
		--Commented modules are not yet implemented
		health = {
			enable = true,
			vertical = false,
			reversefill = false,
			backdrop = {
				enable = false,
				transparent = true,
				insets = {
					left = 1,
					right = 1,
					top = 1,
					bottom = 1,
				},
			},
			height = 27,
			width = 197,
			point = 'TOP',
			xoffset = 0,
			yoffset = 0,
			framelevel = 2,
			color = {
				Tapping      = true,
				Disconnected = true,
				Smooth       = false,
				Custom       = true,
				Class        = false,
				Reaction     = false,
			},
			text = {
				enable = true,
				hideFullValue = false,
				point = 'TOPRIGHT',
				xoffset = -3,
				yoffset =-4,
				customtext = {
					enable = false,
					funcString = '',
				},
			},
		},
		power = {
			enable = true,
			vertical = false,
			reversefill = false,
			backdrop = {
				enable = false,
				transparent = true,
				insets = {
					left = 1,
					right = 1,
					top = 1,
					bottom = 1,
				},
			},
			height = 2,
			width = 197,
			point = 'BOTTOM',
			xoffset = 0,
			yoffset = 0,
			framelevel = 4,
			fullwhendead = true, -- Show full power when unit is dead
			fullifnopower = true, -- Show full if npc doesn't have power
			color = {
				Smooth        = false,
				Custom          = false,
				Class         = true,
				Reaction      = true,
				Power         = false,
			},
			text = {
				enable = false,
				hideFullValue = false,
				point = 'TOPLEFT',
				xoffset = 4,
				yoffset = -4,
				customtext = {
					enable = false,
					funcString = '',
				},
			},
		},
		portrait = {
			enable = true,
			-- position = '',
			-- alpha = 0.1,
		},
		name = {
			enable = true,
			maxlength = 16,
			showlevel = false,
			point = 'TOPLEFT',
			xoffset = 4,
			yoffset = -4,
		},
		castbar = {
			enable = false,
			point = {'TOP', '', 'BOTTOM', 0, -3},
			height = 14,
			width = 197,
			framelevel = 4,
			color    = { 0.6, 0.8, 1.0 },
			altcolor = { 1.0, 0.8, 0.8 }, --interrupt color
			backdrop = {
				enable = true,
				transparent = true,
				insets = {
					left = 1,
					right = 1,
					top = 1,
					bottom = 1,
				},
			},
		},
		raiddebuffs={
			enable=false,
			size=20,
		},
		gridindicators = {
			enable = false,
			size = 8,
		},
		buffs = {
			enable = false,
			point = {'BOTTOM', 'TOP', 0, 5},
			position = 'TOP',			-- Position on unit frame
			disableCooldown = false,	-- Disables the cooldown spiral. Defaults to false.
			size = 22,					-- Aura icon size. Defaults to 16.
			onlyShowPlayer = false,		-- Only show auras created by player/vehicle.
			desaturateNonPlayer = true,	-- Disature auras not cast by player
			showStealableBuffs = true,	-- Display the stealable texture on buffs that can be
			spacing = 3,				-- Spacing between each icon. Defaults to 0.
			initialAnchor = 'BOTTOMLEFT', -- Anchor point for the icons. Defaults to BOTTOMLEFT.
			xGrowth = 'RIGHT',
			yGrowth = 'UP',
			num = 8,				-- Maximum amount of buffs shown
			perrow = 8,					-- Buffs shown in each row
		},
		debuffs = {
			enable = false,
			point = {'BOTTOM', 'TOP', 0, 30},
			position = 'TOP',			-- Position on unit frame
			disableCooldown = false,	-- Disables the cooldown spiral. Defaults to false.
			size = 22,					-- Aura icon size. Defaults to 16.
			onlyShowPlayer = false,		-- Only show auras created by player/vehicle.
			desaturateNonPlayer = true,	-- Disature auras not cast by player
			showStealableBuffs  = true,	-- Display the stealable texture on debuffs that can be
			spacing = 3,				-- Spacing between each icon. Defaults to 0.
			initialAnchor = 'BOTTOMLEFT', -- Anchor point for the icons. Defaults to BOTTOMLEFT.
			num = 8,				-- Maximum amount of debuffs shown
			perrow = 8,				
		},
	}, overwrite or {});
end


function S:CreateClassBarConfigTable(moduleType, overwrite)
	local defaults = {
		enable = true,
		height = 13,
		width = 197,
		orientation = 'horizontal',
		reverse = false,
		point = {'CENTER', UIParent, 'CENTER',0, -200},
	}

	if moduleType == 'stacks' then
		defaults.showEmpty = true
	elseif moduleType == 'bars' then
		defaults.fillDirection = 'right'
	end

	return table.merge(defaults, overwrite or {});
end

function S:CreateActionBarConfigTable(overwrite)

	return table.merge({
		enabled = true,
		mouseover = false,
		numbuttons = 12,
		buttonsize = 27,
		buttonspacing = 3,
		vertical = false,
		background = {
			enable = false,
			transparent = true,
			anchor = 'BOTTOM',
			width = 12,
			height = 1,
			insets = {
				left = 1,
				right = 1,
				top = 1, 
				bottom = 1,
			}
		},
		point = {'CENTER', 'UIParent', 'CENTER', 0, 0},
	}, overwrite or {})
end

S.DefaultConfig = { profile = {
	General = {
		borderpadding = 4,
		shadows = false,
		barTexture = 'SaftUI Flat',
		Colors = {
			backdrop = { .1, .12, .14, 1},
			border = { .1, .12, .14, 1},
			buttonbackdrop = { .08, .09, .1, 1},
			buttonborder = {.08, .09, .1, 1 },
			transparentbackdrop = { .14, .18, .22, .7 },
			transparentborder = { .14, .18, .22 , 0},
			hover = {0/255, 170/255, 255/255},
			click = {0.7, 0.6, 0.1},
		},
		Fonts = {
			general = { 'Agency FB', 12, 'NONE'},
			pixel = { 'Visitor', 12, 'MONOCHROMEOUTLINE'},
			chat = { 'Agency FB', 12, 'NONE'},
		}
	},

	ActionBars = {
		enable = true,
		buttonsize = 27,
		buttonspacing = 3,
		showgrid = true,
		macrotext = false,
		hotkeytext = true,
		pixelfont = true,
		Bars = {
			[1] = S:CreateActionBarConfigTable({
				point = {'BOTTOM', 'UIParent', 'BOTTOM', 0, 10},
				background = {
					enable = true,
					height = 2,
				},
			}),
			[2] = S:CreateActionBarConfigTable({
				point = {'BOTTOM','SaftUI_ActionBar1','TOP',0,3},
			}),
			[3] = S:CreateActionBarConfigTable({
				point = {'BOTTOM','SaftUI_ActionBar2','TOP',0,3},
				enabled = false,
			}),
			[4] = S:CreateActionBarConfigTable({
				point = {'RIGHT','UIParent','RIGHT',-10,0},
				vertical = true,
				enabled = false,
			}),
			[5] = S:CreateActionBarConfigTable({
				point = {'RIGHT','SaftUI_ActionBar4','LEFT',-3,0},
				vertical = true,
				enabled = false,
			}),
			['pet'] = S:CreateActionBarConfigTable({
				numbuttons = 10,
				point = {'BOTTOM','SaftUI_ActionBar3','TOP',0,3},
				background = {
					width = 10,
					enable = true,
				}
			})
		}
	},

	Chat = {
		Left = {
			backdrop = true,
			tabbackdrop = false,
			height = 151,
			width = 377,
			point = {'BOTTOMLEFT', 'SaftUI_DataText_StartButton', 'TOPLEFT', 0, 4},
			framelevel = 2, 
		},
		Right = {
			backdrop = false,
			tabbackdrop = false,
			height = 151,
			width = 377,
			point = {'BOTTOMRIGHT', 'SaftUI_ExpBar', 'TOPRIGHT', 0, 4},
			framelevel = 2, 
		},
		shadows = true,
		rightchat = 0,
		linespacing = 3,
		pixelfonttab = true,
	},

	DataText = {
		enable = false,
		pixelfont = true,
		height = 20,
		Positions = {
			[1] = 'time',
			[2] = 'system',
			[3] = 'gold',
			[4] = 'talents',
		}
	},

	Experience = {
		enable = true,
		pixelfont = true,
		height = 20,
		width = 377,
		point = {'BOTTOMRIGHT', 'UIParent', 'BOTTOMRIGHT', -4, 4},
		textvisibility = 'ALWAYS',
		framelevel = 0,
		backdrop = {
			enable = true,
			transparent = true,
			insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1,
			},
		},
	},

	Inventory = {
		enable = true,
		slotsize = 34,
		slotspacing = 1,
		perrow = 10,
		autosort = true,
		vendorgreys = true,
		autorepair = true
	},

	Auras = {
		enable = true,
		pixelfont = true,
		timertext = false,
		buffposition = {'TOPRIGHT', 'Minimap', 'TOPLEFT', -5, 0},
		buffdirection = 'LEFT',
		debuffposition = {'BOTTOMRIGHT', 'Minimap', 'BOTTOMLEFT', -5, 0},
		debuffdirection = 'LEFT',
		count = {
			enable = true,
			position = {'BOTTOMRIGHT', 'BOTTOMRIGHT', 0, 3},
			framelevel = 3,
		},
		timertext = {
			enable = false,
			position = {'TOP', 'BOTTOM', 0, -4},
			framelevel = 5,
		},
		timerbar = {
			enable = false,
			vertical = false,
			reversefill = false,
			height = 3,
			width = 30,
			position = { 'TOP', 'BOTTOM', 0, 0 },
			framelevel = 4,
			backdrop = {
				enable = true,
				transparent = true,
				insets = {
					left = 1,
					right = 1,
					top = 1, 
					bottom = 1,
				},
			},
		},
		backdrop = {
			enable = true,
			transparent = true,
			insets = {
				left = 6,
				right = 1,
				top = 6, 
				bottom = 6,
			},
		},
	},
	Minimap = {
		enable = true,
		position = {'TOPRIGHT', 'UIParent', 'TOPRIGHT', -5, -5},
		height = 100,
		width = 140,
		backdrop = {
			enable = true,
			transparent = true,
			insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1,
			},
		},
	},
	UnitFrames = {
		enable = true,
		pixelfont = true,
		portrait = {
			enable = true,
			alpha = .1,
		},
		Units = {
			['player'] = CreateUnitConfigTable({
				point = {'TOPRIGHT','UIParent','CENTER',-200,-150},
				name = {enable = false},
				power = {text = {enable = true}},
				castbar = {enable = true},
			}),
			['target'] = CreateUnitConfigTable({
				point = {'TOPLEFT','UIParent','CENTER', 200,-150}, 	
				castbar = {	enable = true},
				buffs = {enable = true},
				debuffs = {enable = true},
				name = {showlevel = true},
			}),
			['targettarget'] = CreateUnitConfigTable({
				width = 150, 
				health = {width=150},
				power = {width= 150},
				point = {'LEFT','SaftUI_Target','RIGHT',10,0},
			}),
			['pet'] = CreateUnitConfigTable({
				width = 150, 
				health = {width = 150},
				power = {width =  150},
				point = {'RIGHT','SaftUI_Player','LEFT',-10,0},
			}),
			['pettarget'] = CreateUnitConfigTable({
				enable = false,
				width = 100,
				point = {'RIGHT','SaftUI_Pet','LEFT',-10,0},
				health = {
					width = 100,
					text = {
						enable = false,
					}
				},
				power = {
					width = 100,
				},
			}),
			['focus'] = CreateUnitConfigTable({
				point = {'BOTTOM','SaftUI_Player','TOP',0,150},
			}),
			['focustarget']	 = CreateUnitConfigTable({
				enable = false,
				width = 150, 
				health = {width = 150},
				power = {width =  150},
				point = {'RIGHT','SaftUI_Focus','LEFT',-10,0},
			}),

			['arena'] = CreateUnitConfigTable({
				point = {'BOTTOM','SaftUI_Target','TOP',0,100},
				castbar = {enable = true}
			}),
			
			['boss'] = CreateUnitConfigTable({
				point = {'BOTTOM','SaftUI_Target','TOP',0,100},		
				buffs = {
					enable = true,
					point = {'LEFT', 'RIGHT', 5, 0},
					num = 4,
					perrow = 4,
					initialAnchor = 'BOTTOMLEFT'
				},
				debuffs = {
					enable = true,
					point = {'RIGHT', 'LEFT', -5, 0},
					num = 4,
					perrow = 4,
					initialAnchor = 'BOTTOMRIGHT',
					xGrowth = 'LEFT',
					onlyShowPlayer = true
				},
			}),
			
			['raid'] = CreateUnitConfigTable({
				width = 60,
				point = {'BOTTOMLEFT','SaftUI_ChatPanelLeft','TOPLEFT',0,10},
				ooralpha = 1,
				growUp = true,
				raiddebuffs = {enable = true},
				backdrop = {enable=false},
				gridindicators = {enable = true},
				name = {
					point = 'TOPLEFT',
					xoffset = 4,
					yoffset = -4,
					maxlength = 4
				},
				power = {
					width = 60,
					text = { enable = false }
				},
				health = {
					width = 60,
					text = {
						enable = true,
						point = 'BOTTOMLEFT',
						xoffset =  3,
						yoffset = 4
					}
				},
			}),
		},
	},
	ClassBars = {
		enable = true,
		pixelfont = true,
		fulmination 	= S:CreateClassBarConfigTable('stacks', {enable=false}),
		totemtimers 	= S:CreateClassBarConfigTable('bars', {enable=false}),
		combopoints 	= S:CreateClassBarConfigTable('stacks', {showEmpty=false}),
		runebar 		= S:CreateClassBarConfigTable('bars'),
		holypower		= S:CreateClassBarConfigTable('stacks'),
		eclipsebar		= S:CreateClassBarConfigTable('bars'),
		demonicfury		= S:CreateClassBarConfigTable('bars'),
		soulshards		= S:CreateClassBarConfigTable('stacks'),
		burningembers	= S:CreateClassBarConfigTable('bars'),
		shadoworbs		= S:CreateClassBarConfigTable('stacks'),
		chi				= S:CreateClassBarConfigTable('stacks'),
	},
	Colors = {
		tapped = {},
		disconnected = {},
		custom = {},
	},
}, global = {}, char = {}, realm = { gold={} }, class = {}, race={}, faction={}, factionrealm={}}