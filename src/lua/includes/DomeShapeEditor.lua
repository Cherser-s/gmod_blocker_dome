if !DOME_ENT then
	DOME_ENT = {}
end
DOME_ENT.GUI_manager_shape_editor = {}
local ShapeTypes = {Sphere=1,Box=2}
local PropTypes = {
	Sphere = function(panel)
		panel.props:Clear()
		local RadiusRow = panel.props:CreateRow( "Sphere Parameters", "Radius" )
		RadiusRow:Setup( "float" )
		RadiusRow:SetValue( panel.Block_Data.Shape.Radius or 0.0  )
		RadiusRow.DataChanged = function( _, val ) 
			panel.Block_Data.Shape.Radius = val
		end
	end,
	Box = function(panel)
		panel.props:Clear()	
		
		
	end
}

function DOME_ENT.GUI_manager_shape_editor:Init()
	self.cbox = vgui.Create("DComboBox",self)
	self.cbox:Dock(TOP)
	for K,V in pairs(ShapeTypes) do
		self.cbox:AddChoice(K,K)
	end
	--sphere by default
	self.ChosenType = "Sphere"
	self.cbox.OnSelect=function(cbox,index,value)
		self:SetShapeIndex(index,value)
	end
	
	self.props = vgui.Create("DProperties",self)
	self.props:Dock(BOTTOM)
end

function DOME_ENT.GUI_manager_shape_editor:SetShapeIndex(index,value)
	if self.ChosenType != value then 
		self.ChosenType = value
		self:GetData().Shape = {}
		self:GetData().Shape.Type = value
		PropTypes[value](self)
	end
end


function DOME_ENT.GUI_manager_shape_editor:GetData()
	return self.Block_Data
end

function DOME_ENT.GUI_manager_shape_editor:SetData(data)
	self.Block_Data = data
	self.cbox:ChooseOption(data.Shape.Type)
	PropTypes[value](self)
end

function DOME_ENT.GUI_manager_shape_editor:PerformLayout(w,h)
	
end

vgui.Register("DDomeManager_Shape_Editor",DOME_ENT.GUI_manager_shape_editor,"Panel")