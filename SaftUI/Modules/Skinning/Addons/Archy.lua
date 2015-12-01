local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat
local LSM = LibStub('LibSharedMedia-3.0')

local function SkinDigSiteFrame()
	ArchyDigSiteFrame:SetTemplate('TKS')
	ArchyDigSiteFrame:SetScale(1)
end

local function SkinArtifactFrame()
	ArchyArtifactFrame:SetTemplate('TKS')
	ArchyArtifactFrame:SetScale(1)
	ArchyArtifactFrame:SetWidth(250)

	ArchyArtifactFrameSkillBar:SetBarTemplate()
	ArchyArtifactFrameSkillBar:SetWidth(240)
	ArchyArtifactFrameSkillBar.border:Kill()
	ArchyArtifactFrameSkillBar:CreateBackdrop('T')
	ArchyArtifactFrameSkillBar.text:SetFontTemplate('pixel')
	ArchyArtifactFrameSkillBar.text:SetTextColor(1,1,1)
	ArchyArtifactFrameSkillBarBackground:Kill()

	local iconsize = 21

	local prev
	for i, child in pairs(ArchyArtifactFrame.children) do
		-- child:SetTemplate()
		child:SetWidth(240)

		child.icon:SetTemplate()
		child.icon:SetSize(iconsize,iconsize)
		child.icon.texture:SetInside(child.icon)
		child.icon.texture:TrimIcon()

		child.solveButton.icon = child.solveButton:GetNormalTexture()
		child.solveButton.icon:SetInside(child.solveButton)
		child.solveButton:SkinActionButton(true)
		child.solveButton:SetSize(iconsize,iconsize)

		child.fragmentBar:SetWidth(169)

		child.fragmentBar:ClearAllPoints()
		child.fragmentBar:SetPoint('TOPLEFT', child.icon, 'TOPRIGHT', 4, -S.borderinset)
		child.fragmentBar:SetBarTemplate()
		child.fragmentBar:SetHeight(iconsize-S.borderinset*2)
		child.fragmentBar:CreateBackdrop()
		child.fragmentBar.barBackground:Kill()
		child.fragmentBar.artifact:SetFontTemplate('pixel')
		child.fragmentBar.artifact:ClearAllPoints()
		child.fragmentBar.artifact:SetPoint('LEFT', child.fragmentBar, 5, 0)
		child.fragmentBar.artifact:SetPoint('RIGHT', child.fragmentBar.keystones, 'LEFT', -5, 0)
		child.fragmentBar.artifact:SetWordWrap(false)
		child.fragmentBar.fragments:SetFontTemplate('pixel')
		child.fragmentBar.fragments:ClearAllPoints()
		child.fragmentBar.fragments:SetPoint('RIGHT', child.fragmentBar, -5, 0)

		child.fragmentBar.keystones.count:SetFontTemplate('pixel')
		child.fragmentBar.keystones:ClearAllPoints()
		child.fragmentBar.keystones:SetPoint('RIGHT', child.fragmentBar, 'RIGHT', -60, 0)

		child.crest.texture:SetInside(child.crest)
		child.crest:SetSize(iconsize,iconsize)

		child:SetHeight(iconsize)

		if child:IsShown() then
			child:ClearAllPoints()
			if not prev then
				child:SetPoint('TOPLEFT', ArchyArtifactFrameSkillBar.backdrop, 'BOTTOMLEFT', 0, -3)
			else
				child:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -3)
			end
			prev = child
		end
	end

	
end

S:GetModule('Skinning').AddonSkins['Archy'] = function()
	hooksecurefunc(Archy, 'UpdateDigSiteFrame', SkinDigSiteFrame)
	hooksecurefunc(Archy, 'RefreshRacesDisplay', SkinArtifactFrame)
	hooksecurefunc(Archy, 'UpdateRacesFrame', SkinArtifactFrame)
end


