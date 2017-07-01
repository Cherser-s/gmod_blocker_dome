include('shared.lua')


local DrawFuncs = {
	Sphere = 
	function(self,ent)
		render.DrawSphere(ent:GetPos(),self.Radius,60,60,Color(255,255,255,170))
	end
}


local function PickDrawType(drawType)
--actually replace with table to provide faster check
	drawType.drawFunc = DrawFuncs[drawType.shape_type]
	return drawType
end

function ENT:Initialize()
	self.drawType = {}
	self.drawType.shape_type = "Sphere"
	self.drawType.Radius = 512
	PickDrawType(self.drawType)
	self:MakeHollowProp()
end

function ENT:Draw()
	self:DrawModel()
	
end

net.Receive("dome_get_type_data",function(len)
	if len<2 then error("expected at least two items in stream") end
	local ent = net.ReadEntity()
	if ent:GetClass()!= ENT.ClassName then 
		error("Expected ent with specified class") 
	end
	ent.drawType = net.ReadTable()
end)

function ENT:OnRemove()
	if self.c_prop then
		self.c_prop:Remove() --remove the client prop
	end
end

function ENT:MakeHollowProp()
	if self.c_prop then
		self.c_prop:Remove()
		self.c_prop=nil
	end
	
	local drawer = self.drawType
	if drawer.shape_type=="Sphere" then 
		self.c_prop = ClientsideModel("models/props/sphere.mdl",RENDERGROUP_TRANSLUCENT )		
		self.c_prop:SetModelScale(self.drawType.Radius/20)
	end
	
	if self.c_prop then
		self.c_prop:SetPos(self:GetPos())
		self.c_prop:SetParent(self)
		self.c_prop:SetMaterial("models/shadertest/shader3")
				
		self.c_prop:Spawn()
	end
end

