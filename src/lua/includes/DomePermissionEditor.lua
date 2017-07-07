include('includes/PlayerDataPanel.lua')
if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.GUI_manager_permission_editor = {}

local function isSteamID(steamId)
	local finder=string.match(steamId,"STEAM_0:[%d]+:[%d]+")
	if not finder then 
		return false
	else 
		return true
	end
end

function DOME_ENT.GUI_manager_permission_editor:Init()
	self.scrPanel  = vgui.Create("DScrollPanel",self)
	
	self.menu = vgui.Create("DMenuBar",self)
	self.menu:DockMargin( -3, -6, 0, 0 )	
	
	self.allowbox = vgui.Create("DCheckBoxLabel",self)
	self.allowbox:SetText("Allow players in the list get in zone")
	self.allowbox:SizeToContents()
	
	self.listt = vgui.Create("DListLayout",self.scrPanel)
	self.listt:Dock(FILL)
	
	local addmenu=self.menu:AddMenu("Add")
	addmenu:AddOption("Add by Steam ID",function()
		Derma_StringRequest("Add Steam ID","Enter the valid steam id:","",function(text)
			if isSteamID(text) then 
				self:AddPlayerById(text,true)
			else
				Derma_Message("You have entered invalid steam ID","Message","OK")
			end
		end)
	end)
	addmenu:AddOption("Add player",function()
		--[[local menu = DermaMenu()
		local players = player.GetAll()
		for K,V in pairs(players) do
			menu:AddOption(V:Nick(),function()
				self:AddPlayerEntity(V,true)
			end)
		end
		menu:Open(gui.MouseX(),gui.MouseY(),nil, self)]]
		self:MakePlayerDialog()
	end)
	
	self.allowbox.OnChange = function(panel,value)
		if self.Block_Data then
			self.Block_Data.permission_type = value
		end
	end
end

function DOME_ENT.GUI_manager_permission_editor:GetData()
	return self.Block_Data
end

function DOME_ENT.GUI_manager_permission_editor:AddPlayerItem(plyData,refreshList)
	if self.Block_Data != nil then		
	
		if refreshList == nil then refreshList = false end
		--add item
		local lbl = vgui.Create("DDomeManager_playerpanel")
		
		lbl:SetPlayer(plyData)
		lbl:SetPanelRemovedListener(function(selfpanel)
			if #self.Block_Data.permittedSteamID>0 then
				table.RemoveByValue(self.Block_Data.permittedSteamID,selfpanel:GetPlayer())
			end
		end)
		self.listt:Add(lbl)
		lbl:SetHeight(80)
		if refreshList then 
			self:InvalidateLayout()
		end
	end
end

function DOME_ENT.GUI_manager_permission_editor:AddPlayerEntity(ply,refreshList)
	if not ply:IsValid() then return end
	local steamID = ply:SteamID()
	if self.Block_Data != nil and (!table.HasValue(self.Block_Data.permittedSteamID,steamID)) then
		table.insert(self.Block_Data.permittedSteamID,steamID)
		--add item
		self:AddPlayerItem(ply,refreshList)
	end
end

function DOME_ENT.GUI_manager_permission_editor:AddPlayerById(steamID,refreshList)
	if self.Block_Data != nil and (!table.HasValue(self.Block_Data.permittedSteamID,steamID)) then
		table.insert(self.Block_Data.permittedSteamID,steamID)
		--add item
		self:AddPlayerItem(steamID,refreshList)
	end
end

function DOME_ENT.GUI_manager_permission_editor:SetData(data)
	self.Block_Data = data
	self.listt:Clear()
	for K,V in pairs(self.Block_Data.permittedSteamID) do
		self:AddPlayerItem(V)
	end
	--set perm type
	self.allowbox:SetValue(data.permission_type)
end



function DOME_ENT.GUI_manager_permission_editor:PerformLayout()
	local w,h = self:GetSize()
	self.allowbox:SetPos(0.1*w,h*0.05)
	self.scrPanel:SetPos(0,h*0.2)
	self.scrPanel:SetSize(w,h*0.7)
end

function DOME_ENT.GUI_manager_permission_editor:MakePlayerDialog()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300,150)
	frame:SetTitle("Add a player")
	local p  = vgui.Create("DPanel",frame)
	p:Dock(FILL)	
	
	local plypanel = vgui.Create("DComboBox",p)
	plypanel:Dock(TOP)
	plypanel:SetValue("Select any player you want to add")
	for K,V in pairs(player.GetAll()) do
		plypanel:AddChoice(V:Nick(),V)
	end
	
	local okbutton = vgui.Create("DButton",p)
	okbutton:Dock(BOTTOM)
	okbutton:SetText("OK")
	
	okbutton.DoClick = function(panel)
		str,ply = plypanel:GetSelected()
		if ply then
			self:AddPlayerEntity(ply,true)
			frame:Close()
		end
	end
	
	frame:Center()
	frame:MakePopup()
end

vgui.Register("DDomeManager_permeditor",DOME_ENT.GUI_manager_permission_editor,"Panel")