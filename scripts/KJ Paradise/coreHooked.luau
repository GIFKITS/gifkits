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

	local set_identity = setthreadidentity or setidentity or setthreadcontext

	for _, defaultModule: ModuleScript in pairs(core.Default:GetChildren()) do
		if defaultModule:IsA("ModuleScript") then
			if set_identity then set_identity(2) end 
			local success, moduleData = pcall(require, defaultModule)
			if set_identity then set_identity(7) end 
			if success and type(moduleData) == "function" then
				task.spawn(moduleData)
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
