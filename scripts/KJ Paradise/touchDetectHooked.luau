local RS = game:GetService("ReplicatedStorage")
local collection = game:GetService("CollectionService")

local remoteFolder: Folder = RS:WaitForChild("Remote")
local touchEvent: RemoteEvent = remoteFolder:WaitForChild("TouchEvent")

local scriptedFolder: Folder = workspace:WaitForChild("Scripted")
local transformBrickFolder: Folder = scriptedFolder:WaitForChild("TransformBrick")

local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 2
overlapParams.FilterType = Enum.RaycastFilterType.Include

local module = {
	isListActive = false,
	ignoreList = {},
	thread = nil,
	connection = nil,
}

local function castInBound(parts)
	local touchedParts = {}
	for _,bodyPart: BasePart in pairs(parts) do
		if not bodyPart:IsA("BasePart") then continue end
		local partsInPart = workspace:GetPartsInPart(bodyPart, overlapParams)
		
		for _,touchedPart in pairs(partsInPart) do
			if table.find(touchedParts, touchedPart) or (module.ignoreList[touchedPart] and module.isListActive) then continue end
			table.insert(touchedParts, touchedPart)
			touchEvent:FireServer(touchedPart, bodyPart)
		end
	end
	return touchedParts
end

function module.update(character)
	module.remove()

	local leftLeg = character:WaitForChild("Left Leg")
	local rightLeg = character:WaitForChild("Right Leg")
	local head = character:WaitForChild("Head")
	local torso = character:WaitForChild("Torso")
	
	for _,infectPart in pairs(transformBrickFolder:GetDescendants()) do
		if not infectPart:IsA("BasePart") or module.ignoreList[infectPart] then return end
		module.ignoreList[infectPart] = true
	end
	
	module.connection = transformBrickFolder.DescendantAdded:Connect(function(infectPart)
		if not infectPart:IsA("BasePart") or module.ignoreList[infectPart] then return end
		module.ignoreList[infectPart] = true
	end)

	module.thread = task.spawn(function()
		while character and character.Parent do
			task.wait(0.12)
			
			if workspace:GetAttribute(character.Name) then
				continue
			end
			
			overlapParams.FilterDescendantsInstances = collection:GetTagged("TouchPart")
			castInBound({
				leftLeg,
				rightLeg,
				head,
				torso
			})
		end
	end)
end

function module.remove()
	if module.thread then task.cancel(module.thread) module.thread = nil end
	if module.connection then module.connection:Disconnect() module.connection = nil end
end

return module
