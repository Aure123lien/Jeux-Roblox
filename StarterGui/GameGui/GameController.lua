local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local camera = workspace.CurrentCamera
local item = nil

local function MouseRaycat()
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseRay= camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000)
	
	return raycastResult
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if item:IsA("BasePart") then
			item.color = Color3.new(0, 0, 1)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local result = MouseRaycat()
	if result and result.Instance then
		item = result.Instance
	end
end)
