local base = {}

function base.Setup(map, health)
	base.Model = map:FindFirstChild("Base")
	if not base.Model then
		error(" La map ne contient pas un modèle nommé 'Base' !")
	end

	local gui = base.Model:FindFirstChild("HealthGui")
	if not gui then
		error(" HealthGui est manquant dans le fichier Base !")
	end

	if not gui:FindFirstChild("CurrentHealth") then
		error(" CurrentHealth est manquant dans HealthGui !")
	end
	if not gui:FindFirstChild("Title") then
		error(" Fichier Title est manquant dans HealthGui !")
	end

	base.currentHealth = health
	base.maxHealth = health

	base.UpdateHealth()
end

function base.UpdateHealth(damage)
	if damage then
		base.currentHealth -= damage
		if base.currentHealth < 0 then
			base.currentHealth = 0
		end
	end

	local gui = base.Model.HealthGui
	local percent = base.currentHealth / base.maxHealth

	gui.CurrentHealth.Size = UDim2.new(percent, 0, 0.5, 0)

	-- Change le texte si la vie est à zéro
	if base.currentHealth == 0 then
		gui.Title.Text = "Base : DESTROY"
	else
		gui.Title.Text = "Base : " .. base.currentHealth .. "/" .. base.maxHealth
	end
end

return base
