local ServerStorage = game:GetService("ServerStorage")

local bindables = ServerStorage:WaitForChild("Bindables")
local gameOverEvent = bindables:WaitForChild("GameOver")
local updateBaseHealth = bindables:WaitForChild("UpdateHealth") -- Ajouté

local base = require(script.Base)
local mob = require(script.Mob)
local tower = require(script.Tower)
local map = workspace.Map1

local gameOver = false

-- Setup de la base
base.Setup(map, 500)

-- Connexion des événements
gameOverEvent.Event:Connect(function()
	gameOver = true
end)

-- Connexion pour recevoir les dégâts des mobs
updateBaseHealth.Event:Connect(function(damage)
	base.UpdateHealth(damage)
end)

-- Vérifie que le dossier workspace.Mobs existe
if not workspace:FindFirstChild("Mobs") then
	local mobsFolder = Instance.new("Folder")
	mobsFolder.Name = "Mobs"
	mobsFolder.Parent = workspace
end

-- Boucle des vagues
for wave = 1, 4 do
	if wave == 1 then
		mob.Spawn("Noob", 5, map)
	elseif wave == 2 then
		mob.Spawn("Noob", 7, map)
		mob.Spawn("Speedy", 3, map)
	elseif wave == 3 then
		mob.Spawn("Noob", 10, map)
		mob.Spawn("Speedy", 4, map)
		mob.Spawn("Red", 1, map)
	elseif wave == 4 then
		mob.Spawn("Noob", 12, map)
		mob.Spawn("Speedy", 5, map)
		mob.Spawn("Red", 2, map)
		mob.Spawn("Yellow", 1, map)
	end

	-- Attend que tous les mobs soient morts ou fin de partie
	repeat
		task.wait(1)
	until #workspace.Mobs:GetChildren() == 0 or gameOver

	if gameOver then
		warn("Game over")
		break
	end

	task.wait(1)
end
