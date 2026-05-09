local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remote")
ReplicatedStorage:WaitForChild("Module")
function _G.ClientRemoteEvent(arg1, arg2) -- Line 9
	require(game.ReplicatedStorage:FindFirstChild(arg1, true))(arg2)
end
local LocalPlayer_upvr = game:GetService("Players").LocalPlayer

local playerScripts = LocalPlayer_upvr:WaitForChild("PlayerScripts")
local core = playerScripts:WaitForChild("Core")

return function() -- Line 14
    --[[ Upvalues[1]:
        [1]: LocalPlayer_upvr (readonly)
    ]]
	game.ReplicatedStorage.Remote.ClientRemoteEvent.OnClientEvent:Connect(function(arg1, arg2) -- Line 17
		require(game.ReplicatedStorage:FindFirstChild(arg1, true))(arg2)
	end)
	for _, v in pairs(core.Default:GetChildren()) do
		if v:IsA("ModuleScript") then
			require(v)()
		end
	end
	local tbl_upvr = {}
	for _, v_2 in pairs(core.Local:GetChildren()) do
		if v_2:IsA("ModuleScript") then
			tbl_upvr[v_2.Name] = require(v_2)
		end
	end
	if LocalPlayer_upvr.Character then
		for _, v_3 in pairs(tbl_upvr) do
			v_3(LocalPlayer_upvr.Character)
		end
	end
	LocalPlayer_upvr.CharacterAdded:Connect(function(arg1) -- Line 39
        --[[ Upvalues[1]:
            [1]: tbl_upvr (readonly)
        ]]
		for _, v_4 in pairs(tbl_upvr) do
			v_4(arg1)
		end
	end)
end
