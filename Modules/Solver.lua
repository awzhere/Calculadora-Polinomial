local Solver = {}
local Converter = require("Modules/Converter")

function Solver.solve(polynomialsTab, OPs)
    --// realizando primeiro as multiplicações e divisões
    local toRemove = {}
    local indexCorrection = 0
    local hasRemainder = Converter.returnRemainder(OPs)
    for index, operations in ipairs(OPs) do
        local trueIndex = index - indexCorrection
        local nextIndex = trueIndex + 1
        if operations == "*" then
            local t = polynomialsTab[nextIndex]
            polynomialsTab[trueIndex] = polynomialsTab[trueIndex]:mult(t)
            table.remove(polynomialsTab, nextIndex)
            indexCorrection = indexCorrection + 1
            table.insert(toRemove, index)
        elseif operations == "/" then
            if index == #OPs and hasRemainder then --// Retornando o resto
                polynomialsTab[trueIndex], polynomialsTab[nextIndex] = polynomialsTab[trueIndex]:div(polynomialsTab[nextIndex])
                return
            end
            polynomialsTab[trueIndex] = polynomialsTab[trueIndex]:div(polynomialsTab[nextIndex])
            table.remove(polynomialsTab, nextIndex)
            indexCorrection = indexCorrection + 1
            table.insert(toRemove, index)
        end
    end
    indexCorrection = 0
    --// Removendo as operações de multiplicação e divisão
    for i, index in ipairs(toRemove) do
        local correction = i - 1
        table.remove(OPs, index - correction)
    end
    --// Realizando as adições e subtrações
    for index, operations in ipairs(OPs) do
        local trueIndex = index - indexCorrection
        local nextIndex = trueIndex + 1
        if operations == "+" then
            polynomialsTab[1] = polynomialsTab[1]:sum(polynomialsTab[nextIndex])
            table.remove(polynomialsTab, nextIndex)
            indexCorrection = indexCorrection + 1
        elseif operations == "-" then
            polynomialsTab[1] = polynomialsTab[1]:sub(polynomialsTab[nextIndex])
            table.remove(polynomialsTab, nextIndex)
            indexCorrection = indexCorrection + 1
        end
    end
end

return Solver