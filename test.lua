-- CPU Stress Tester in Lua
local iterations = 15000

-- Function to perform a simple calculation
local function stressTest()
    local result = 0
    for i = 1, iterations do
        result = result + (i * math.sqrt(i))
        print(i, result)
    end
    return result
end

stressTest()