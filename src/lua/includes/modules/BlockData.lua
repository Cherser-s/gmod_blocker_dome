

local Block_Data = {}
	Block_Data.permitted = {}
	Block_Data.preventMode = 3 --1 teleport, 2 damage and dissolve, 3 just dissolve
	Block_Data.permission_type = false --false : accept players out of the list, true - in the list
	
	Block_Data.Shape = {}
	Block_Data.Shape.Radius = 512 --default
	Block_Data.Shape.Type = "Sphere"
	
function Block_Data:GetShapeMode()
	return Block_Data.Shape.Type 
end
	
function Block_Data:GetPreventMode()
	return self.preventMode
end
	
function Block_Data:SetSphere(radius)
	if not isnumber(radius) then return end
	self.Shape.Radius = radius
	self.Shape.Type = "Sphere"	
end

function Block_Data:GetSphereRadius()
	if self.Shape.Type == "Sphere" then
		return self.Shape.Radius
	end
end

function Block_Data:IsPermitted(ply)
	if self.permission_type then
		return table.HasValue(self.permitted,ply)
	else
		return not table.HasValue(self.permitted,ply)
	end
end

function Block_Data:GetPermittedPlayers()
	return self.permitted
end
	
function Block_Data:GetPermissionType()
	return self.permission_type
end
	
function Block_Data:SetPermissionType(ptype)
	if not isbool(ptype) then
		error("expected boolean, got "..type(ptype))
		return 
	end
	self.permission_type = ptype
end
	
return Block_Data
