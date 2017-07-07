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

function DOME_ENT.player_panel:SetPanelRemovedListener(listener)
	if not isfunction(listener) then error("Expected function, got ".. type(listener)) end
	self.OnPanelRemoved = listener

end

function DOME_ENT.player_panel:PerformLayout()
	local w,h = self:GetSize()
	self.NickPanel:SetPos(w*0.1,h*0.05)
	self.NickPanel:SetSize(w*0.8,h*0.3)
	self.SteamIDPanel:SetPos(w*0.1,h*0.35)
	self.SteamIDPanel:SetSize(w*0.8,h*0.3)
end

function DOME_ENT.player_panel:GetPlayer()
	return self.plyID
end




function DOME_ENT.player_panel:SetPlayer(plyID)
	if isstring(plyID) then
		self.plyID = plyID
		local ply = player.GetBySteamID(plyID)
		if ply then
			self.NickPanel:SetText(ply:Nick())
		else
			self.NickPanel:SetText("Player is offline or don't exist.")
		end
		
		self.SteamIDPanel:SetText(self.plyID)
		
	elseif IsEntity(plyID) and plyID:IsPlayer() then
		
		self.plyID = plyID:SteamID()
				
		self.SteamIDPanel:SetText(self.plyID)
		self.NickPanel:SetText(plyID:Nick())
	end
end

function DOME_ENT.player_panel:OnMousePressed(KEYCODE)
	if KEYCODE == MOUSE_LEFT then
		local menu = DermaMenu()
		menu:AddOption("delete",function()
			self:Remove()
		end)
		menu:Open()
	end
end

function DOME_ENT.player_panel:Paint(width,height)
	local left,top,right,bottom = self:GetDockPadding()
	right = width - right
	bottom = height - bottom
	ww = right - left
	hh = bottom - top
	draw.RoundedBox( math.min(ww,hh)/10, left, top, ww, hh, Color( 170, 0, 0 ) )
end

vgui.Register("DDomeManager_playerpanel",DOME_ENT.player_panel,"Panel")