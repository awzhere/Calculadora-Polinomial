local Terms = require("Modules/Terms")
local PolyAux = require("Modules/PolyAux")

local Polynomials = {}
local prototype = {}
Polynomials.__index = prototype

function Polynomials.new(polynomial) -- { {Coeff = 3, Term = {x = 3, y = 2}}}
    local self = {}
    self.Operations = {}
    self.Terms = setmetatable({}, {__newindex = function(tab, i, v)
        rawset(tab, i, v)
        table.insert(self.Operations, "sum")
    end})
    for _, indexedTerms in ipairs(polynomial) do
        rawset(self.Terms, #self.Terms + 1, Terms.new(indexedTerms.Coeff, indexedTerms.Term))
        table.insert(self.Operations, indexedTerms.OP)
    end

    setmetatable(self, Polynomials)

    PolyAux.trySimplificatePoly(self.Terms, self.Operations)
    PolyAux.ordenateByDegree(self.Terms)
    return self
end

function prototype:sum(polynomial)
    --// Agrupar todos os termos para em sequência tentar fazer uma simplificação dos termos semelhantes
    local allTerms = {}

    for _, firstTerms in pairs(self.Terms) do
        local serializedTerm = firstTerms:serialize()
        table.insert(allTerms, serializedTerm)
    end

    for _, secondTerm in pairs(polynomial.Terms) do
        local serializedTerm = secondTerm:serialize()
        table.insert(allTerms, serializedTerm)
    end
    for i = 1, #allTerms - 1 do
        allTerms[i].OP = "sum"
    end

    local newPoly = Polynomials.new(allTerms)
    local removeQueue = PolyAux.tryToSum(newPoly.Terms)
    PolyAux.removePoly(allTerms, newPoly.Operations, removeQueue)

    return newPoly
end

--// Distributiva: pois ambos os polinomios vão estar simplificados a simples adições e subtrações
function prototype:mult(polynomial)
    local Terms = {}
    --// Realizando a multiplicacão usando a propriedade distributiva e inserindo os Termos na tabela 'Terms'
    for i, termsOne in pairs(self.Terms) do
        for j, termsTwo in pairs(polynomial.Terms) do
            local termoResultante = termsOne:mult(termsTwo, false)
            table.insert(Terms, termoResultante:serialize())
        end
    end

    --//Agora será inserido as devidas operações
    local size = #Terms
    if size > 1 then
        for i = 1, size - 1 do
            Terms[i].OP = "sum"
        end
    end

    return Polynomials.new(Terms)
end

--//Negar o polinomio, agrupar em um só polinomio e simplificar os termos semelhantes
function prototype:sub(polynomial)
    PolyAux.negatePoly(polynomial)

    return self:sum(polynomial)
end

function prototype:div(polynomial)
    if PolyAux.isMonomial(polynomial) then
        local resultTerm = {}
        local terms, remainder = PolyAux.getTermsDivMonomial(self, polynomial)
        for _, t in ipairs(terms) do
            table.insert(resultTerm, t:divByMonomial(polynomial):serialize())
        end
        for i = 1, #resultTerm - 1 do
            resultTerm[i].OP = "sum"
        end
        for i = 1, #remainder do
            remainder[i] = remainder[i]:serialize()
            remainder[i].OP = "sum"
        end
        return Polynomials.new(resultTerm), Polynomials.new(remainder)
    else
        local dividend = self.Terms --// Dividendo será dinamico
        local divisor = polynomial.Terms --// Divisor sempre fixo 
        local DIVISOR_LENGTH = #divisor
        local Quotient = {}
        local polyDegree = PolyAux.getPolyDegree(self)
        for i = 1, polyDegree do
            local qResult = dividend[1] ~= nil and dividend[1]:divByMonomial(divisor[1])
            if qResult then
                table.insert(Quotient, qResult)
                for termIndex = 1, DIVISOR_LENGTH do
                    local multResult = Quotient[#Quotient]:mult(divisor[termIndex])
                    multResult.Coeff = -multResult.Coeff --//Negando o resultado
                    table.insert(dividend, termIndex, multResult) --// Adicionando no dividendo
                end
                local removeQueue = PolyAux.tryToSum(dividend)
                PolyAux.removePoly(dividend, self.Operations, removeQueue)
            else
                local remainderPoly = Polynomials.new(PolyAux.termsToTable(dividend))
                local quotientPoly = Polynomials.new(PolyAux.termsToTable(Quotient))
                return quotientPoly, remainderPoly
            end
        end
        local remainderPoly = Polynomials.new(PolyAux.termsToTable(dividend))
        local quotientPoly = Polynomials.new(PolyAux.termsToTable(Quotient))
        return quotientPoly, remainderPoly
    end
end

return Polynomials