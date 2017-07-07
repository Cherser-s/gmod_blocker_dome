if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.block_panel = {}

DOME_ENT.block_panel.GUI_TEXTS = {
	LabelText = {"Pushes the player or the prop out of zone.",
	"Damages the player in the zone, also dissolves the props in it.",
	"Just dissolves everything in the zone."},
	PreventModes = {"Push","Damage the player, dissolve the prop","Dissolve everything"}
}

function DOME_ENT.block_panel:Init()
	self.preventcbx = vgui.Create("DComboBox",self)
	self.preventcbx:SetSortItems(false)
	for K,V in pairs(DOME_ENT.block_panel.GUI_TEXTS.PreventModes) do
		self.preventcbx:AddChoice(V,K)
	end
	
	self.modelbl = vgui.Create("DLabel",self)
	self.modelbl:SetText("")
	
	
	self.preventcbx.OnSelect = function(panel,index,value,data)
		self:SetPreventMode(data)
	end
	
end

function DOME_ENT.block_panel:SetPreventMode(mode)
	if not isnumber(mode) then error("Expected number, got "..type(mode)) end
	if mode<1 or mode>4 then error("Mode must be in range 1..3") end
	if self.Block_Data and mode != self.Block_Data.preventMode then 
		self.Block_Data.preventMode = mode
		self.modelbl:SetText(DOME_ENT.block_panel.GUI_TEXTS.LabelText[mode])
		self.preventcbx:ChooseOptionID(mode)
	end
end

function DOME_ENT.block_panel:SetData(data)
	self.Block_Data = data
	self.modelbl:SetText(DOME_ENT.block_panel.GUI_TEXTS.LabelText[data.preventMode])
	self.preventcbx:ChooseOptionID(data.preventMode)
end

function DOME_ENT.block_panel:PerformLayout()
	local w,h = self:GetSize()
	self.preventcbx:SetPos(w*0.05,h*0.1)
	self.preventcbx:SetWidth(w*0.85)
	local cbxw,cbxh = self.preventcbx:GetSize()
	self.modelbl:SetPos(w*0.05,h*0.15+cbxh)
	self.modelbl:SetSize(w*0.85,h * 0.8 - cbxh)
end

vgui.Register("DDomeManager_blockPanel",DOME_ENT.block_panel,"Panel")