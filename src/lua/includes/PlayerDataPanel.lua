if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.player_panel = {}

function DOME_ENT.player_panel:Init()
	self.NickPanel =  vgui.Create("DLabel",self)
	self.SteamIDPanel = vgui.Create("DLabel",self)
end

function DOME_ENT.player_panel:OnRemove()
	--call event so parent gui will remove data from attached table
	if self.OnPanelRemoved then
		self.OnPanelRemoved(self)
	end
end

function DOME_ENT.player_panel:PerformLayout()
	local w,h = self:GetSize()
	self.NickPanel:SetSize(w,h*0.3)
	self.SteamIDPanel:SetPos(0,h*0.35)
	self.SteamIDPanel:SetSize(w,h*0.3)
end

function DOME_ENT.player_panel:GetPlayer()
	return self.ply
end


function DOME_ENT.player_panel:SetPlayer(plySteamID)
	self.plyID = plySteamID
	local ply = player.GetBySteamID(plySteamID)
	if ply then
		self.NickPanel:SetText(ply:Nick())
	else
		self.NickPanel:SetText("Player is offline or don't exist.")
	end
	
	self.SteamIDPanel:SetText(plySteamID)
end

vgui.Register("DDomeManager_playerpanel",DOME_ENT.player_panel,"Panel")