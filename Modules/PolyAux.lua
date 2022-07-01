local Terms = require("Modules/Terms")

local PolyAux = {}

--// Remove os termos do polinomio de acordo com a queue.
--// A queue é limpa depois de ter o termo removido
--// A array queue necessita estar organizada

local function clearTable(tab)
    for index in pairs(tab) do 
        tab[index] = nil
    end
end

function PolyAux.removePoly(polynomials, operations, queue)
    local removedFactor = 0 --// Ajuste de Index
    for index, termPos in pairs(queue) do
       local trueIndex = termPos - removedFactor
       table.remove(polynomials, trueIndex)
       table.remove(operations, trueIndex)
       removedFactor = removedFactor + 1
       queue[index] = nil
    end
end
--//Tenta somar os termos semelhantes. Esse método é usado depois de realizar as operações de multiplicação
function PolyAux.tryToSum(polynomials)
    local ocurrencies = {}
    local removeQueue = {}
    --//Colocando os indexes dos termos similares na array ocurrencies
    for termPos, terms in ipairs(polynomials) do
        local literal = table.concat(terms.allLiteral)
        local expoent = terms.orderedExpoents
        local key = literal .. expoent
        if not ocurrencies[key] then
            ocurrencies[key] = {}
            ocurrencies[key][1] = termPos
        else
            table.insert(ocurrencies[key], termPos)
        end
    end

    --//Fazendo as somas necessárias e colocando os termos a serem removidos na Queue
    for _, tab in pairs(ocurrencies) do
        if #tab > 1 then
            for i = 1, #tab - 1 do
                local termPos = tab[i]
                local nextTermPos = tab[i + 1]
                local BaseTerm = polynomials[termPos]
                local nextTerm = polynomials[nextTermPos]
                local isZero = BaseTerm:sum(nextTerm)
                table.insert(removeQueue, termPos)
                if isZero and i == #tab - 1 then --//Caso a soma resulta em coficiente 0 e seja a ultima iteração
                    table.insert(removeQueue, nextTermPos)
                end
            end
            table.sort(removeQueue)
        end
    end

    return removeQueue
end

function PolyAux.trySimplificatePoly(polynomials, operations)
    local multTable = {}
    local removeQueue = {}
    for i = 1, #polynomials - 1 do
        local OP = operations[i]
        if OP == "mult" then
            table.insert(multTable, i)
        end
    end
    
    --Primeiro simplificar os termos com operações de multiplicação
    for _, termPosition in ipairs(multTable) do
        polynomials[termPosition + 1]:mult(polynomials[termPosition], true)
        table.insert(removeQueue, termPosition)

    end
    PolyAux.removePoly(polynomials, operations, removeQueue)
    local sumRemoveQueue = PolyAux.tryToSum(polynomials)
    PolyAux.removePoly(polynomials, operations, sumRemoveQueue)
end

function PolyAux.negatePoly(polynomialObject)
    for _, termObject in ipairs(polynomialObject.Terms) do
        termObject.Coeff = -termObject.Coeff
    end
end

function PolyAux.isMonomial(polynomialObject)
    return #polynomialObject.Terms <= 1
end

function PolyAux.getTermsDivMonomial(polynomialObject, monomial)
    local Terms = {}
    local Remainder = {}
    for index, term in ipairs(polynomialObject.Terms) do
        local canDiv = term:_isDivByMonomial(monomial)
        if canDiv then
            table.insert(Terms, term)
        else
            table.insert(Remainder, term)
        end
    end

    return Terms, Remainder
end

function PolyAux.getPolyDegree(polynomialObject)
    local greaterDegree = 0
    for index, term in ipairs(polynomialObject.Terms) do
        if term.Degree > greaterDegree then
            greaterDegree = term.Degree
        end
    end
    return greaterDegree
end

function PolyAux.ordenateByDegree(poly_oneTerms)
    local tmp = nil
    for i = 1, #poly_oneTerms do
        for j = 1, #poly_oneTerms - i do
            if poly_oneTerms[j].Degree < poly_oneTerms[j + 1].Degree then
                tmp = poly_oneTerms[j + 1]
                poly_oneTerms[j + 1] = poly_oneTerms[j]
                poly_oneTerms[j] = tmp
            end
        end
    end
end

function PolyAux.termsToTable(Terms)
    local result = {}
    for _, terms in ipairs(Terms) do
        table.insert(result, terms:serialize())
    end
    for i = 1, #result do
        result[i].OP = "sum"
    end
    return result
end

return PolyAux
