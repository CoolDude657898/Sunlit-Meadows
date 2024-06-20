local colorSequenceModule = {}

function colorSequenceModule.getColorSequencePoint(x, colorSequence)
    if x == 0 then return colorSequence.Keypoints[1].Value end
    if x == 1 then return colorSequence.Keypoints[#colorSequence.Keypoints].Value end

    for i = 1, #colorSequence.Keypoints - 1 do
        local current = colorSequence.Keypoints[i]
        local next = colorSequence.Keypoints[1 + i]

        if x >= current.Time and x < next.Time then
            local alpha = (x - current.Time) / (next.Time - current.Time)

            return current.Value:Lerp(next.Value, alpha)
        end
    end
end

return colorSequenceModule