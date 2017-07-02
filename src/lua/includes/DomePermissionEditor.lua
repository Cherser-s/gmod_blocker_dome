if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.GUI_manager_permission_editor = {}

function DOME_ENT.GUI_manager_permission_editor:Init()
	
end

function DOME_ENT.GUI_manager_permission_editor:GetData()
	return self.Block_Data
end

function DOME_ENT.GUI_manager_permission_editor:SetData(data)
	self.Block_Data = data
end



vgui.Register("DDomeManager_permeditor",DOME_ENT.GUI_manager_permission_editor,"Panel")