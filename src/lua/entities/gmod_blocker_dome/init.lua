include('shared.lua')
include('includes/BlockData.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('includes/DomeFrameUI.lua')
AddCSLuaFile('includes/DomePermissionEditor.lua')
AddCSLuaFile('includes/DomeShapeEditor.lua')
AddCSLuaFile('includes/PlayerDataPanel.lua')
AddCSLuaFile('includes/BlockModePanel.lua')
util.AddNetworkString("dome_edit_data")
util.AddNetworkString("gmod_dome_data_edited")
util.AddNetworkString("dome_get_type_data")

local RESTRICTED_CLASSES = {
	"npc_helicopter",
	"npc_combinegunship",
	"npc_combinedropship"
}


local function makeDissolve(self,ent,damage)

		if !ent:IsValid() then return end
		if table.HasValue(RESTRICTED_CLASSES,ent:GetClass()) then return end
 		if (ent:IsPlayer() or ent:IsNPC()) then
 			local Dmg=DamageInfo()
 			Dmg:SetDamage(damage)
 			Dmg:SetDamageType(DMG_DISSOLVE)
			Dmg:SetAttacker(self)
			Dmg:SetDamagePosition(ent:GetPos())
 			ent:TakeDamageInfo(Dmg)
 		else
			local ind=tostring(ent:EntIndex())
			ent:SetName(ind)
			local dissolver = ents.Create( "env_entity_dissolver" )
			dissolver:SetPos( ent:GetPos() )
			dissolver:Spawn()
			dissolver:Activate()
			dissolver:SetKeyValue( "target",ind)
			dissolver:SetKeyValue( "magnitude", 100 )
			dissolver:SetKeyValue( "dissolvetype", 1)
			dissolver:Fire( "Dissolve" )
			timer.Simple(0.01,function() if dissolver:IsValid() then dissolver:Remove() end end)
		end
end

local function getOwner(entity)
		if entity == nil then return end
		
		if entity.GetPlayer then
			local ply = entity:GetPlayer()
			if IsValid(ply) then return ply end
		end

		local OnDieFunctions = entity.OnDieFunctions
		if OnDieFunctions then
			if OnDieFunctions.GetCountUpdate then
				if OnDieFunctions.GetCountUpdate.Args then
					if OnDieFunctions.GetCountUpdate.Args[1] then return OnDieFunctions.GetCountUpdate.Args[1] end
				end
			end
			if OnDieFunctions.undo1 then
				if OnDieFunctions.undo1.Args then
					if OnDieFunctions.undo1.Args[2] then return OnDieFunctions.undo1.Args[2] end
				end
			end
		end

		if entity.GetOwner then
			local ply = entity:GetOwner()
			if IsValid(ply) then return ply end
		end

		return nil	
	end

local PreventFuncs = {

	
	
	Players = {
		-- teleport
		function(self,ply)
			local selfpos = self:GetPos()
			local vv = ((ply:GetPos()-selfpos):GetNormalized())
			if ply:GetMoveType() == MOVETYPE_NOCLIP then
				vv= vv*(self.Block_Data.Shape.Radius+10)
				ply:SetPos(selfpos+vv)
			else
				ply:SetVelocity(vv*2000)
			end
		end,
		
		--damage dissolve
		function(self,ply)
			makeDissolve(self,ply,5)
		end,
		--dissolve
		function(self,ply)
			makeDissolve(self,ply,ply:Health())
		end
	},
	Props = {
		function(self,ent)
		--highly doubt that parented entities has their own physObjects
			if not ent:GetParent() then
				local phys = ent:GetPhysicsObject()
				--check if physics object is present
				if IsValid(phys) then
					local selfpos = self:GetPos()
					local vv = ((ply:GetPos()-selfpos):GetNormalized())
					phys:ApplyForceCenter(vv*ent:GetInertia()*20)
				end
				
			end
			
		end,
		
		--damage dissolve
		function(self,ent)
			makeDissolve(self,ent,0)
		end,
		--dissolve
		function(self,ent)
			makeDissolve(self,ent,0)
		end
	}


}

function ENT:Initialize()
	self:SetModel("models/props_lab/reciever01b.mdl")--didn't choose the model :( will make "ERROR" model
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self.Block_Data = DOME_ENT.BlockData()
end

function ENT:Use(activator,caller,usetype,value)
	if IsValid(caller) and caller:IsPlayer() then
		net.Start("dome_edit_data")
		net.WriteEntity(self)
		net.WriteTable(self.Block_Data)
		--Send data
		net.Send(caller)
	end
end


function ENT:Think()
	if not (self:IsValid() and self.Block_Data) then return end
	local i = 0
	
	self.Block_Data:MakeFromSteamID()
	--empty list
	if #self.Block_Data:GetPermittedPlayers() < 1 then return end
	
	local function InsideDome(ent)	
		if self.Block_Data.Shape.Type == "Sphere" then
			return self:GetPos():DistToSqr(ent:GetPos())<=(self.Block_Data.Shape.Radius)^2
		else 
			return false
		end
		
	end
	
	local function checkPlayer(ply)
		--use within sphere
		if (!self.Block_Data:IsPermitted(ply)) then 
			PreventFuncs.Players[self.Block_Data:GetPreventMode()](self,ply)
		end
	end
	
	local function checkNPC(ply)
		--use within sphere
		local pwner = getOwner(ply)
		if  not (pwner and pwner:IsPlayer() and (self.Block_Data:IsPermitted(pwner))) then
			PreventFuncs.Players[self.Block_Data:GetPreventMode()](self,ply)
		end
	end
		
	local function processProp(prop)
		
		if prop == self then return end		
		
		local pwner = getOwner(prop)
		if  pwner and (!self.Block_Data:IsPermitted(pwner)) then
			PreventFuncs.Props[self.Block_Data:GetPreventMode()](self,prop)
		end
	end
	
	local props = ents.GetAll()
	--push all players off
	for K,V in ipairs(props) do
		if !InsideDome(V) then continue end
		if V:IsPlayer() then 
			checkPlayer(V) 
		elseif V:IsNPC() then
			checkNPC(V)
		else
			--then props
			processProp(V)
			
		end
	end
	
end


function ENT:OnBlockDataEdited(data)
	self.Block_Data:MakeFromCopy(data)
	
	net.Start("dome_get_type_data")
	net.WriteEntity(self)
	net.WriteTable(self.Block_Data.Shape)
	net.Broadcast()
end

net.Receive("gmod_dome_data_edited",
function(len,ply)
	if len<2 then return end
	local ent = net.ReadEntity()
	local data = net.ReadTable()
	if (getOwner(ent)==ply) then
		ent:OnBlockDataEdited(data)
	end
end)