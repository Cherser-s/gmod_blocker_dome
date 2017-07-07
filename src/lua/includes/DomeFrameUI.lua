include('includes/DomePermissionEditor.lua')
include('includes/DomeShapeEditor.lua')
include('includes/BlockModePanel.lua')
if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.GUI_manager = {}


function DOME_ENT.GUI_manager:Init()
	self.Block_Data = {}
	local propSheet = vgui.Create("DPropertySheet",self)
	propSheet:Dock(FILL)
	self.ShapeBox = vgui.Create("DDomeManager_Shape_Editor")
	propSheet:AddSheet("Shape",self.ShapeBox)
	self.PermitBox = vgui.Create("DDomeManager_permeditor")
	propSheet:AddSheet("Permissions",self.PermitBox)
	self.BlockModeBox = vgui.Create("DDomeManager_blockPanel")
	propSheet:AddSheet("Blocking mode",self.BlockModeBox)
end


function DOME_ENT.GUI_manager:GetData()
	return self.Block_Data,self.ent_sender
end

function DOME_ENT.GUI_manager:SetData(data,entity)
	self.Block_Data = data
	self.ent_sender = entity
	
	self.ShapeBox:SetData(data)
	self.PermitBox:SetData(data)
	self.BlockModeBox:SetData(data)
end

function DOME_ENT.GUI_manager:OnRemove()
	self.ent_sender:SendInfoBack(self.Block_Data)
end

vgui.Register("DDomeManager",DOME_ENT.GUI_manager,"Panel")

