local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 2
overlapParams.FilterType = Enum.RaycastFilterType.Include

local touchEvent = game:GetService("ReplicatedStorage").Remote:WaitForChild("TouchEvent")

local function castInBound(...)
    local touchedParts = {}

    for _, bodyPart in pairs(...) do
        for _, touchedPart in pairs(workspace:GetPartsInPart(bodyPart, overlapParams)) do
            if not table.find(touchedParts, touchedPart) then
                table.insert(touchedParts, touchedPart)
                touchEvent:FireServer(touchedPart, bodyPart)
            end
        end
    end

    return touchedParts
end

local collectionService = game:GetService("CollectionService")

return function(character)
    warn("LOADED")
    local leftLeg = character:WaitForChild("Left Leg")
    local rightLeg = character:WaitForChild("Right Leg")
    local head = character:WaitForChild("Head")
    local torso = character:WaitForChild("Torso")

    task.spawn(function()
        while task.wait(0.12) and character and character.Parent do
            if not workspace:GetAttribute(character.Name) then
                overlapParams.FilterDescendantsInstances = collectionService:GetTagged("TouchPart")

                castInBound({
                    leftLeg,
                    rightLeg,
                    head,
                    torso
                })
            end
        end
    end)
end
