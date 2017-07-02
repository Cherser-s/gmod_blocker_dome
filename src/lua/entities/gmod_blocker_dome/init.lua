include('shared.lua')
include('includes/BlockData.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('includes/DomeFrameUI.lua')
AddCSLuaFile('includes/DomePermissionEditor.lua')
AddCSLuaFile('includes/DomeShapeEditor.lua')

util.AddNetworkString("dome_edit_data")



local function makeDissolve(self,ent,damage)
		if !ent:IsValid() then return end
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

local PreventFuncs = {

	
	
	Players = {
		-- teleport
		function(self,ply)
			local selfpos = self:GetPos()
			local vv = ((ply:GetPos()-selfpos):GetNormalized())*(self.Block_Data.Radius+10)
			ply:SetPos(selfpos+vv)
		end,
		
		--damage dissolve
		function(self,ply)
			makeDissolve(self,ply,15)
		end,
		--dissolve
		function(self,ply)
			makeDissolve(self,ply,ply:Health())
		end
	},
	Props = {
		function(self,ent)
			
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
	
	
	local function isInSphere(ent)		
		return self:GetPos():DistToSqr(ent:GetPos())<=(self.Block_Data.Shape.Radius)^2
	end
	
	local function checkPlayer(ply)
		--use within sphere
		if (!self.Block_Data:IsPermitted(pwner)) then 
			PreventFuncs.Players[self.Block_Data:GetPreventMode()](self,ply)
		end
	end
	
	local function checkNPC(ply)
		--use within sphere
		local pwner = getOwner(ply)
		if  pwner and (!self.Block_Data:IsPermitted(pwner)) then
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
		if !isInSphere(V) then continue end
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