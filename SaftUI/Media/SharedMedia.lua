local AddonName = ...

local LSM = LibStub('LibSharedMedia-3.0')
local media_path = format('Interface\\AddOns\\%s\\Media\\', AddonName)

LSM:Register('background','SaftUI Blank', [[Interface\BUTTONS\WHITE8X8]])
LSM:Register('border', 'SaftUI Glow Border', media_path..'Textures\\glowTex.tga')
LSM:Register('border', 'SaftUI Solid Border', media_path..'Textures\\borderTex.tga')

local function RegisterFont(displayName, fileName)
	LSM:Register('font', displayName, media_path .. 'Fonts\\' .. (fileName or displayName) .. '.ttf')
end

RegisterFont('BigNoodleTitling')
RegisterFont('PT Sans Narrow')
RegisterFont('Visitor', 'Visitor TT2')
RegisterFont('Agency FB', 'AgencyFB_Bold')
RegisterFont('Semplice Reg')
RegisterFont('Semplice Ext')
RegisterFont('Munica Reg')
RegisterFont('Munica Ext')
RegisterFont('Munro')
RegisterFont('MunroSmall')
RegisterFont('MunroNarrow')
RegisterFont('ProFontWindows')


LSM:Register('statusbar','SaftUI Gloss', media_path..'Textures\\normTex.tga')
LSM:Register('statusbar','SaftUI Flat', [[Interface\BUTTONS\WHITE8X8]])

---------------------
-- Ishtara's Media --
---------------------
for _,fileName in pairs({
	"cabaret1","cabaret2","cabaret3","cabaret4","cabaret5",
	"DsmB1","DsmB2","DsmB3","DsmB4","DsmB5","DsmB6","DsmB7","DsmB8","DsmB9","DsmV1","DsmV2","DsmV3","DsmV4","DsmV5","DsmV6","DsmV7","DsmV8","DsmV9",
	"DsmOpaqueV1","DsmOpaqueV2","DsmOpaqueV3","DsmOpaqueV4","DsmOpaqueV5","DsmOpaqueV6","DsmOpaqueV7","DsmOpaqueV8",
	"DukeB","DukeG",
	"fade1","fade2",
	"Gradient1","Gradient2",
	"HalA","HalB","HalC","HalD","HalE","HalF","HalG","HalH","HalI","HalJ","HalK","HalL","HalM","HalN","HalO","HalP","HalQ","HalR","HalS","HalT","HalU","HalV","HalW","HalX",
	"Ish00","Ish01","Ish02","Ish03","Ish04","Ish05","Ish06","Ish07","Ish08","Ish09","Ish10","Ish11","Ish12","Ish13","Ish14","Ish15","Ish16","Ish17","Ish18",
	"Led01","Led02","Led03","pHish01",
	"pHish02","pHish03","pHish04","pHish05","pHish06","pHish07","pHish08","pHish09","pHish10","pHish11",
	"savant1","savant2","savant3","savant4","savant5","savant6","savant7","savant8",
	"tap1","tap2","tap3","tap4",
}) do LSM:Register('statusbar', fileName, media_path.."IshtaraMedia\\statusbar\\"..fileName) end