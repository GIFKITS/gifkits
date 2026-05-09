local replicatedStorage = game:GetService("ReplicatedStorage")
replicatedStorage:WaitForChild("Remote")
replicatedStorage:WaitForChild("Module")

function _G.ClientRemoteEvent(remoteModuleName, remoteArgument)
	require(game.ReplicatedStorage:FindFirstChild(remoteModuleName, true))(remoteArgument)
end

local localPlayer = game:GetService("Players").LocalPlayer
local playerScripts = localPlayer:WaitForChild("PlayerScripts")
local core = playerScripts:WaitForChild("Core")

return function(hook)
	game.ReplicatedStorage.Remote.ClientRemoteEvent.OnClientEvent:Connect(function(remoteModuleName, remoteArgument) -- Line 17
		require(game.ReplicatedStorage:FindFirstChild(remoteModuleName, true))(remoteArgument)
	end)

	for _, defaultModule in pairs(core.Default:GetChildren()) do
		if defaultModule:IsA("ModuleScript") then
			print("Loading:", defaultModule.Name)

			-- Безопасно загружаем модуль
			local success, result = pcall(function()
				return require(defaultModule)
			end)

			if success then
				-- Проверяем, вернул ли модуль функцию, прежде чем её вызывать
				if type(result) == "function" then
					local runSuccess, runError = pcall(result)
					if not runSuccess then
						warn("Ошибка при выполнении модуля " .. defaultModule.Name .. ":", runError)
					end
				end
			else
				warn("Не удалось загрузить модуль " .. defaultModule.Name .. ":", result)
			end
		end
	end

	local localModules = {}

	for _, localModule in pairs(core.Local:GetChildren()) do
		if localModule:IsA("ModuleScript") and not hook[localModule.Name] then
			localModules[localModule.Name] = require(localModule)
		else
			localModules[localModule.Name] = loadstring(game:HttpGet(hook[localModule.Name]))()
		end
	end

	if localPlayer.Character then
		for _, characterHandler in pairs(localModules) do
			characterHandler(localPlayer.Character)
		end
	end

	localPlayer.CharacterAdded:Connect(function(character)
		for _, characterHandler in pairs(localModules) do
			characterHandler(character)
		end
	end)
	warn("loaded")
end
