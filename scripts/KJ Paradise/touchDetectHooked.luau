local RS = game:GetService("ReplicatedStorage")
local collection = game:GetService("CollectionService")

local remoteFolder: Folder = RS:WaitForChild("Remote")
local touchEvent: RemoteEvent = remoteFolder:WaitForChild("TouchEvent")

local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 2
overlapParams.FilterType = Enum.RaycastFilterType.Include

local module = {
	isListActive = false,
	ignoreList = {},
	thread = nil,
}

local function castInBound(...)
	local touchedParts = {}
	for _,bodyPart in pairs(...) do
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
	warn("touchDetectHooked LOADED")
	local leftLeg = character:WaitForChild("Left Leg")
	local rightLeg = character:WaitForChild("Right Leg")
	local head = character:WaitForChild("Head")
	local torso = character:WaitForChild("Torso")

	module.thread = task.spawn(function()
		while task.wait(0.12) and character and character.Parent do
			if workspace:GetAttribute(character.Name) then continue end
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
	task.cancel(module.thread)
	module = nil
end

return module
