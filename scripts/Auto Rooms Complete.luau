-- SERVICES --

local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local pathfinding = game:GetService("PathfindingService")
local run = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local virtualUser = game:GetService("VirtualUser")

-- PLAYER --

local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local character:Model
local humanoid:Humanoid
local root:BasePart
local head:BasePart

-- GUI --

local playerGui = player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")
local cameraScript:LocalScript = mainUI.Initiator.Main_Game.Camera
local a90:Frame = mainUI:WaitForChild("Jumpscare"):WaitForChild("Jumpscare_A90")

-- SPEED BOOS --

local speedBoost = 0

-- ANTI AFK --

local antiAFKenabled = false

-- FULLBRIGHT --

local fullbrightEnabled = false

-- AUTO WALK --

local path = pathfinding:CreatePath({
	WaypointSpacing = 1,
	AgentCanJump = true,
	AgentRadius = 2,
})

local autoWalkEnabled = false
local currentGoal:BasePart = nil
local prevGoal:BasePart = currentGoal
local currentRoom:Model = nil

local waypoints = {}
local waypointIndex = 1

local lastComputed = 0

local currentAction = ""
local prevAction = nil

local camLockObject:BasePart = nil

local currentRooms:Folder = workspace:WaitForChild("CurrentRooms")
local latestRoom:StringValue = game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")
local camLock:RemoteEvent = game.ReplicatedStorage.RemotesFolder.CamLock

-- FUNCTIONS --

local function updateCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	head = character:WaitForChild("Head")
end

local function firePrompt(prompt: ProximityPrompt)
	if not prompt then return end
	local part = prompt.Parent
	local savedCFrame = camera.CFrame

	if part:IsA("Model") then
		part = part.PrimaryPart
	end

	camLockObject = part
	task.wait(0.3)
	fireproximityprompt(prompt)
	task.wait(prompt.HoldDuration)
	camLockObject = nil
end

local function getLocker()
	local closestLocker:BasePart
	for _,prompt:ProximityPrompt in pairs(currentRooms:GetDescendants()) do
		if not prompt:IsA("ProximityPrompt") or prompt.Name ~= "HidePrompt" then continue end
		
		local locker:Model = prompt.Parent
		local base:BasePart = locker:FindFirstChild("Base")
		local hiddenPlayer:ObjectValue = locker:FindFirstChild("HiddenPlayer")
		if not base or not hiddenPlayer or hiddenPlayer.Value then continue end
		
		if not closestLocker then
			closestLocker = base
		else
			local newDistance = (base.Position - root.Position).Magnitude
			local closestDistance = (closestLocker.Position - root.Position).Magnitude
			if newDistance < closestDistance then closestLocker = base end
		end
	end
	return closestLocker
end

local function checkAction()
	local danger = {"A60","A120"}
	for _,entity in pairs(danger) do
		local entity = workspace:FindFirstChild(entity)
		if entity then return "locker" end
	end
	return "door"
end

local function getGoal() : BasePart
	local room:Model = currentRooms:FindFirstChild(tostring(latestRoom.Value))
	if not room then return end
	
	currentAction = checkAction()
	currentRoom = room
	
	if currentAction ~= "locker" and prevAction == "locker" then
		camLock:FireServer()
	end
	
	prevAction = currentAction
	
	if currentAction == "locker" then
		return getLocker()
	end
	
	local door1 = room:FindFirstChild("Door")
	if not door1 then return end

	local door2:BasePart = door1:FindFirstChild("Door")
	if not door2 then return end

	local lock:BasePart = door1:FindFirstChild("Lock")

	return door2
end

local function completePath()
	if currentAction == "locker" then
		local locker:Model = currentGoal.Parent
		local prompt:ProximityPrompt = locker:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then return end
		
		if a90.Visible then
			repeat task.wait() until not a90.Visible
		end
		firePrompt(prompt)
	end
end

local function stopPath()
	waypointIndex = 1
	waypoints = {}
end

local function computePath()
	local currentTime = os.clock()
	if currentTime-lastComputed < 1 and prevGoal == currentGoal then return end
	lastComputed = currentTime
	
	if prevGoal ~= currentGoal then
		stopPath()
	end
	prevGoal = currentGoal

	local targetPos = currentGoal.Position

	if currentAction == "door" then
		targetPos = targetPos+(-currentGoal.CFrame.LookVector)*2
	elseif currentAction == "locker" then
		targetPos = targetPos+(currentGoal.CFrame.LookVector)*3
	end

	local success, err = pcall(function()
		path:ComputeAsync(root.Position, targetPos)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		waypoints = path:GetWaypoints()
		waypointIndex = 2
		return
	end

	prevGoal = nil
end

-- UI --

local GIFui
if run:IsStudio() then
	GIFui = require(RS:FindFirstChild("GIFui"))
else
	GIFui = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifkits/refs/heads/main/lib/GIFui.luau"))()
end

local window = GIFui:CreateWindow("Rooms Auto Walk V2")
local mainTab = window:CreateTab("script")

mainTab:CreateLabel("made by GIFKITS", Color3.new(1,1,1))

mainTab:CreateLabel("pathfinding")
mainTab:CreateToggle("Auto Walk (Rooms)","complete the rooms automatically",false,function(value)
	autoWalkEnabled = value
	if not value then stopPath() prevGoal = nil end
end)

mainTab:CreateSlider("Speed Boost", "adjust character walking speed", 0, 7, 0, function(value)
	speedBoost = value
end)

mainTab:CreateLabel("comfort")
mainTab:CreateToggle("Fullbright","you can see in the dark",false,function(value)
	fullbrightEnabled = value
end)

mainTab:CreateToggle("Anti-AFK","you won't be kicked after 20 mins",false,function(value)
	antiAFKenabled = value
end)

-- CONNECTIONS --

updateCharacter()

table.insert(window._conns,player.Idled:Connect(function()
	if not antiAFKenabled then return end
	virtualUser:CaptureController()
	virtualUser:ClickButton2(Vector2.new())
end))

head:WaitForChild("PointLight"):AddTag("default")
table.insert(window._conns, head.ChildAdded:Connect(function(child)
	if child:IsA("PointLight") and not child:HasTag("default") then child:Destroy() end
end))

table.insert(window._conns, player.CharacterAdded:Connect(updateCharacter))
table.insert(window._conns, run.RenderStepped:Connect(function(deltaTime)
	character:SetAttribute("SpeedBoost", tonumber(speedBoost))
	
	if fullbrightEnabled then
		lighting.Ambient = Color3.new(1,1,1)
	end
	
	if camLockObject and head then
		cameraScript.Enabled = false
		local targetCFrame = CFrame.new(head.CFrame.Position, camLockObject.Position)
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, deltaTime * 12)
	else
		cameraScript.Enabled = true
	end

	if not humanoid or not root then return end
	if not autoWalkEnabled then return end

	root.CanCollide = not autoWalkEnabled
	character.Collision.CanCollide = not autoWalkEnabled

	currentGoal = getGoal()
	computePath()

	if waypointIndex > #waypoints then
		stopPath()
		return
	end

	local targetPos = waypoints[waypointIndex].Position
	local offset = (targetPos-root.Position)*Vector3.new(1,0,1)
	local distance = offset.Magnitude

	if distance < 2 then
		waypointIndex += 1
		if waypointIndex > #waypoints then completePath() end
	else
		humanoid:MoveTo(targetPos)
	end
end))
