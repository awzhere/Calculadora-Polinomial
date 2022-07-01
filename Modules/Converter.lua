local Converter = {}

function Converter.RemoveSpacesAndPuncs(str)
    return string.gsub(str, "%s[-+]%s", "")
end

function Converter.GetCoeffnLiteral(term) --// x^1y^1z^1
    local Coeffs
    local TermFound = {}
    local isNegative = string.sub(term, 1, 1) == "-"
    Coeffs = tonumber(string.match(term, "^-?%d+")) or isNegative and -1 or 1
    for i in string.gmatch(term, "%a") do
        local startIndex = string.find(term, i)
        local expoent = tonumber(string.match(term, "^%d+", startIndex + 2)) or 1
        TermFound[i] = expoent
    end
    return {Coeff = Coeffs, Term = TermFound}
end

function Converter.getTermOPs(term)
    local OPs = {}
    local OPList = {
        ["*"] = "mult",
        ["+"] = "sum",
        ["-"] = "sub",
    }
    for i in string.gmatch(term, "%s%p%s") do
        local op = i:sub(2, 2)
        table.insert(OPs, OPList[op])
    end
    return OPs
end
--// Irá retornar os termos do polinomio em formato de string.
function Converter.GetLiteralsFromTerm(polynomialString)
    local result = {}
    local original_string = polynomialString
    local string_no_spaces = Converter.RemoveSpacesAndPuncs(polynomialString) --// Termos sem espaçamento e pontos
    local termsLength = 0

    while termsLength ~= #string_no_spaces do
        local startIndex, lastIndex = string.find(original_string, "[%p%d]?[%a%p%d+]+")
        if not startIndex then
            break
        end
        local termFound = string.sub(original_string, startIndex, lastIndex)
        termsLength = termsLength + #termFound
        table.insert(result, termFound)
        original_string = string.sub(original_string, lastIndex + 4, #original_string)
    end
    return result
end
function Converter.polyStringToTable(polyTerms)
    local result = {}
    for index, terms in ipairs(polyTerms) do
        table.insert(result, Converter.GetCoeffnLiteral(terms))
    end
    return result
end

function Converter.StringToTable(str)--"(x^1y^1z^1 + 2) * (x^2) - (-3x^2 + y^2) + (-3)"
    local result = {}
    local stringTerms = {}
    local operations = {}
    local PolynomialOperations = {}

    for i in string.gmatch(str, "%b()") do
        local withoutParent = string.sub(i, 2, #i - 1) --// Aqui temos os termos do polinomio sem os parenteses
        --// Separado por operadores(+, -, /, *)
       -- print("Without Parenthesis :" .. withoutParent)
        table.insert(operations, Converter.getTermOPs(withoutParent))
        table.insert(stringTerms, Converter.GetLiteralsFromTerm(withoutParent))
    end
    for i = 1, #stringTerms do 
        table.insert(result, Converter.polyStringToTable(stringTerms[i]))
    end
    for i = 1, #operations do 
        for j = 1, #operations[i] do --// Quantidade de operações do termo
            local op = operations[i][j]
            if op == "sub" then
                op = "sum"
                result[i][j + 1].Coeff = -result[i][j + 1].Coeff
                result[i][j].OP = op
            else
                result[i][j].OP = op
            end
        end
    end
    return result
end

function Converter.getPolyOPs(str)
    local result = {}
    local totalLength = 0
    for i in string.gmatch(str, "%b()") do
        totalLength = totalLength + #i + 3
        local OP = string.sub(str, totalLength - 1,  totalLength - 1)
        if totalLength >= #str then break end
        table.insert(result, OP)
    end
    return result
end

function Converter.returnRemainder(OPs)
    for i = 1, #OPs do
        if OPs[i] == "+" or OPs[i] == "-" then
            return false
        end
    end
    if OPs[#OPs] == "/" then
        return true
    end
    return false
end

return Converter

