include('includes/PlayerDataPanel.lua')
if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.GUI_manager_permission_editor = {}

function DOME_ENT.GUI_manager_permission_editor:Init()
	self.scrPanel  = vgui.Create("DScrollPanel",self)
	self.listt = vgui.Create("DListLayout",self.scrPanel)
	self.listt:Dock(FILL)
end

function DOME_ENT.GUI_manager_permission_editor:GetData()
	return self.Block_Data
end

function DOME_ENT.GUI_manager_permission_editor:SetData(data)
	self.Block_Data = data
	self.listt:Clear()
	for K,V in pairs(player.GetAll()) do
		local lbl = vgui.Create("DDomeManager_playerpanel")
		lbl:SetHeight(80)
		lbl:SetPlayer(V:SteamID())
		self.listt:Add(lbl)
	end
	
end

function DOME_ENT.GUI_manager_permission_editor:PerformLayout()
	local w,h = self:GetSize()
	self.scrPanel:SetPos(0,h*0.1)
	self.scrPanel:SetSize(w,h*0.8)
end

vgui.Register("DDomeManager_permeditor",DOME_ENT.GUI_manager_permission_editor,"Panel")