if !DOME_ENT then
	DOME_ENT = {}
end

local BlockData = {}
BlockData.__index = BlockData

function BlockData:GetShapeMode()
	return self.Shape.Type 
end
	
function BlockData:GetPreventMode()
	return self.preventMode
end
	
function BlockData:SetSphere(radius)
	if not isnumber(radius) then return end
	self.Shape.Radius = radius
	self.Shape.Type = "Sphere"	
end

function BlockData:GetSphereRadius()
	if self.Shape.Type == "Sphere" then
		return self.Shape.Radius
	end
end

function BlockData:IsPermitted(ply)
	if self.permission_type then
		return table.HasValue(self.permitted,ply)
	else
		return not table.HasValue(self.permitted,ply)
	end
end

function BlockData:GetPermittedPlayers()
	return self.permitted
end

function BlockData:GetPermissionType()
	return self.permission_type
end
	
function BlockData:SetPermissionType(ptype)
	if not isbool(ptype) then
		error("expected boolean, got "..type(ptype))
		return 
	end
	self.permission_type = ptype
end

function BlockData:MakeFromSteamID()
	self.permitted = {}
	for K,V in pairs(self.permittedSteamID) do
		local ply = player.GetBySteamID(V)
		if ply then table.insert(self.permitted,ply) end
	end
end

function BlockData:MakeFromCopy(data)
	self.permittedSteamID = data.permittedSteamID --we copy only steamid data
	self.preventMode = data.preventMode --1 teleport, 2 damage and dissolve, 3 just dissolve
	self.permission_type = data.permission_type --false : accept players out of the list, true - in the list
	
	self.Shape = data.Shape
end

function BlockData:create()
	local data = {}
	data.permitted = {}
	self.permittedSteamID = {}
	data.preventMode = 3 --1 teleport, 2 damage and dissolve, 3 just dissolve
	data.permission_type = false --false : accept players out of the list, true - in the list
	
	data.Shape = {}
	data.Shape.Radius = 512 --default
	data.Shape.Type = "Sphere"
	setmetatable(data,BlockData)
	return data
end

setmetatable(BlockData,{
	__call = function(self)
		return self:create()
	end
})

DOME_ENT.BlockData = BlockData

