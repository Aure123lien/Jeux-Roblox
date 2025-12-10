local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:WaitForChild("Events")
local spawnTowerEvent = events:WaitForChild("SpawnTower")
local animateTowerEvent = events:WaitForChild("AnimateTower")

local tower = {}

-- Trouver la cible la plus proche
local function FindNearestTarget(newTower)
	local maxDistance = 20
	local nearestTarget = nil

	for _, target in ipairs(workspace.Mobs:GetChildren()) do
		if target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
			local distance = (target.HumanoidRootPart.Position - newTower.HumanoidRootPart.Position).Magnitude
			if distance < maxDistance then
				nearestTarget = target
				maxDistance = distance
			end
		end
	end

	return nearestTarget
end

-- Fonction d'attaque
function tower.Attack(newTower)
	while newTower and newTower.Parent do
		local target = FindNearestTarget(newTower)
		if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
			
			local targetCFrame = CFrame.lookAt(newTower.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
			newTower.HumanoidRootPart.BodyGyro.CFrame = targetCFrame
			-- Jouer l'animation d'attaque
			animateTowerEvent:FireAllClients(newTower, "Attack")
			if target:FindFirstChild("Humanoid") then
				target.Humanoid:TakeDamage(10)
			end
		else
			-- Pas de cible → jouer Idle
			animateTowerEvent:FireAllClients(newTower, "Idle")
		end
		task.wait(1) -- vérifie toutes les secondes
	end
end

-- Fonction pour spawn une tour
function tower.Spawn(player, name, cframe)
	local towerTemplate = ReplicatedStorage:WaitForChild("Towers"):FindFirstChild(name)
	if towerTemplate then
		local newTower = towerTemplate:Clone()
		newTower.HumanoidRootPart.CFrame = cframe

		-- Ajouter la tour dans Workspace
		newTower.Parent = workspace
		newTower.HumanoidRootPart:SetNetworkOwner(nil)
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 0
		bodyGyro.CFrame = newTower.HumanoidRootPart.CFrame
		bodyGyro.Parent = newTower.HumanoidRootPart

		-- Collision group
		for _, object in ipairs(newTower:GetDescendants()) do
			if object:IsA("BasePart") or object:IsA("MeshPart") then
				-- Utilisation de la nouvelle propriété CollisionGroup
				object.CollisionGroup = "Tower"
			end
		end

		-- Lancer l'attaque en parallèle
		coroutine.wrap(tower.Attack)(newTower)
	end
end

spawnTowerEvent.OnServerEvent:Connect(tower.Spawn)

return tower
