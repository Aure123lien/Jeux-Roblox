local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:WaitForChild("Events")
local animateTowerEvent = events:WaitForChild("AnimateTower")

-- Préparer l'animation
local function setAnimation(object, animName)
	local humanoid = object:FindFirstChild("Humanoid")
	local animationFolder = object:FindFirstChild("Animations")
	if humanoid and animationFolder then
		local animationObject = animationFolder:FindFirstChild(animName)
		if animationObject then
			local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
			
			local playingTracks = animator:GetPlayingAnimationTracks()
			for i, track in pairs(playingTracks) do
				if track.Name == animName then
					return track
				end
			end
			
			return animator:LoadAnimation(animationObject)
		end
	end
end

-- Jouer l'animation
local function playAnimation(object, animName)
	local animationTrack = setAnimation(object, animName)
	if animationTrack then
		animationTrack:Play()
	else
		warn("Animation '" .. animName .. "' n'existe pas pour " .. object.Name)
	end
end

-- Détecter quand un mob est ajouté
workspace.Mobs.ChildAdded:Connect(function(Object)
	if Object:FindFirstChild("Humanoid") and Object:FindFirstChild("Animations") then
		playAnimation(Object, "Walk")
	end
end)

-- Détecter quand une tour est ajoutée dans Workspace
workspace.ChildAdded:Connect(function(Object)
	if Object:FindFirstChild("Humanoid") and Object:FindFirstChild("Animations") then
		playAnimation(Object, "Idle")
	end
end)

-- Jouer une animation spécifique demandée par le serveur
animateTowerEvent.OnClientEvent:Connect(function(tower, animName)
	if tower and tower.Parent then
		playAnimation(tower, animName)
	end
end)
