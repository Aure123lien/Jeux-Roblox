local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local bindable = ServerStorage:WaitForChild("Bindables")
local updateBaseHealth = bindable:WaitForChild("UpdateHealth")

local mob = {}

-- Fonction pour appliquer un CollisionGroup à tous les BasePart du modèle
local function applyCollisionGroup(model, groupName)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.CollisionGroup = groupName
		end
	end
end

-- Fonction pour déplacer un mob
function mob.Move(mobModel, map)
	local humanoid = mobModel:WaitForChild("Humanoid")
	local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)

	-- Récupération animations
	local mobName = mobModel.Name
	local mobFolder = ServerStorage:WaitForChild("Mobs"):FindFirstChild(mobName)
	if not mobFolder then return end

	local animFolder = mobFolder:FindFirstChild("Animations")
	if not animFolder then return end

	local walkAnim = animFolder:FindFirstChild("Walk")
	local walkTrack
	if walkAnim then
		walkTrack = animator:LoadAnimation(walkAnim)
		walkTrack:Play()
	end

	-- Récupération et tri des waypoints placer sur les routes
	local waypoints = map:WaitForChild("Waypoints"):GetChildren()
	table.sort(waypoints, function(a, b)
		return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
	end)

	-- Déplacement du mob
	for index, point in ipairs(waypoints) do
		humanoid:MoveTo(point.Position)
		humanoid.MoveToFinished:Wait()

		-- Fin du trajet
		if index == #waypoints then
			if walkTrack then walkTrack:Stop() end

			-- Inflige les dégâts égaux aux PV actuels du mob
			local amount = humanoid.Health
			updateBaseHealth:Fire(amount)

			-- Détruit le mob
			mobModel:Destroy()
		end
	end
end

-- Fonction pour spawn des mobs
function mob.Spawn(name, quantity, map)
	local mobExists = ServerStorage:WaitForChild("Mobs"):FindFirstChild(name)
	if not mobExists then return end

	for i = 1, quantity do
		task.wait(0.5)

		local newMob = mobExists:Clone()
		newMob.HumanoidRootPart.CFrame = map.Start.CFrame
		newMob.Parent = workspace.Mobs
		newMob.HumanoidRootPart:SetNetworkOwner(nil)

		applyCollisionGroup(newMob, "Mob")

		-- Détruit le mob quand il meurt
		newMob.Humanoid.Died:Connect(function()
			task.wait(1)
			newMob:Destroy()
		end)

		coroutine.wrap(mob.Move)(newMob, map)
	end
end

return mob
