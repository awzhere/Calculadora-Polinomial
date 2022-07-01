local Terms = {}
local prototype = {}
Terms.__index = prototype


local function copyLiterals(literalTable)
    local result = {}
    for literal, expoent in pairs(literalTable) do
        result[literal] = expoent
    end
    return result
end


function Terms.new(coeff, literal) --  literal : expoent dictionary
    local orderedLiterals = {}
    local self = {}
    self.Coeff = coeff;
    self.Literal = literal;
    self.orderedExpoents = ""
    
    local _expoentSum = 0
    for key, value in pairs(literal) do
        _expoentSum = _expoentSum + value
        table.insert(orderedLiterals, key)
    end
    self.Degree = _expoentSum --// Grau do polinomio
    
    table.sort(orderedLiterals)

    for _, key in ipairs(orderedLiterals) do
        self.orderedExpoents = self.orderedExpoents .. self.Literal[key]
    end
    self.allLiteral = orderedLiterals
    setmetatable(self.allLiteral, {__newindex = function(tab, i, v)
        rawset(tab, i, v)
        table.sort(tab)
    end})
    return setmetatable(self, Terms)
end

function Terms.is(term)
    local metatable = getmetatable(term)
    return metatable and rawget(metatable, "is") and metatable == Terms
end

function Terms.isSimilar(term_1, term_2)
    local sameLiterals = table.concat(term_1.allLiteral) == table.concat(term_2.allLiteral);

    if sameLiterals then
        for literal, expoent in pairs(term_1.Literal) do
            if term_2.Literal[literal] ~= expoent then
                return false
            end
        end
    end

    return sameLiterals
end

function Terms.__tostring(obj)
    local fmt = "\n %s : %d"
    local str = "Coefficient : " .. obj.Coeff
    local LiteralsTable = table.concat(obj.allLiteral)
    for literal in string.gmatch(LiteralsTable, ".") do
        local expoent = obj.Literal[literal]
        if expoent >= 1 then
            str = str .. fmt:format(literal, expoent)
        end
    end

    return str
end

function prototype:sum(monomial)
    local Similar = Terms.is(monomial) and Terms.isSimilar(self, monomial)
    if Similar then
        monomial.Coeff = monomial.Coeff + self.Coeff
    end
    return monomial.Coeff == 0
end

function prototype:mult(monomial, destructive)
    if Terms.is(monomial) then
        local newCoeff = self.Coeff * monomial.Coeff
        local newLiterals = copyLiterals(self.Literal)
        local newAllLiteral = {}
        local orderedExpoents = ""
        for literal, expoent in pairs(monomial.Literal) do
            
            local termOneExpoent = newLiterals[literal]
            if termOneExpoent then
                newLiterals[literal] = termOneExpoent + expoent;
            else
                newLiterals[literal] = expoent
                table.insert(newAllLiteral, literal)
            end
        end
        for _, key in ipairs(newAllLiteral) do
            orderedExpoents = orderedExpoents .. newLiterals[key]
        end
        if destructive then
            self.Coeff = newCoeff
            self.Literal = newLiterals
            for _, literal in ipairs(newAllLiteral) do
                table.insert(self.allLiteral, literal)
            end
            self.orderedExpoents = orderedExpoents
            return true
        end
        return Terms.new(newCoeff, newLiterals)
    end
end

function prototype:serialize()
    local result = {}
    result.Coeff = self.Coeff
    result.Term = copyLiterals(self.Literal)
    return result
end

function prototype:_isDivByMonomial(monomial)
    local term = Terms.is(monomial) and monomial or monomial.Terms[1] --// Verificar se o parametro é um termo ou um polinomio de apenas um termo
    for literal, expoent in pairs(term.Literal) do
        if not self.Literal[literal] or self.Literal[literal] < expoent then
            return false
        end
    end
    return true
end

function prototype:divByMonomial(monomial)
    local resultCoeff = nil;
    local resultTerms = copyLiterals(self.Literal)
    if self:_isDivByMonomial(monomial) then
        local monomialTerm = Terms.is(monomial) and monomial or monomial.Terms[1]
        resultCoeff = self.Coeff / monomialTerm.Coeff
        for literal, expoent in pairs(monomialTerm.Literal) do
            resultTerms[literal] = self.Literal[literal] - expoent
            if resultTerms[literal] == 0 then
                resultTerms[literal] = nil
            end
        end
        return Terms.new(resultCoeff, resultTerms)
    else
        return false
    end
end

return Terms
