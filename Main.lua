local Polynomial = require("Modules/Polynomials")
local Converter = require("Modules/Converter")
local Solver = require ("Modules/Solver")

local format = "Resultado calculado em %.3f segundos!"

local function clear()
    os.execute("cls")
end

local input = ""
while input ~= "-1" do
    if input ~= "" then
        local time = os.clock()
        local PolynomialsQueue = {}
        local terms = Converter.StringToTable(input)

        for i = 1, #terms do
            table.insert(PolynomialsQueue, Polynomial.new(terms[i]))
        end
        local OPs = Converter.getPolyOPs(input)

        Solver.solve(PolynomialsQueue, OPs)

        if PolynomialsQueue[1] then
            print("=====RESULTADO=====")
            for _, v in ipairs(PolynomialsQueue[1].Terms) do
                print(v)
            end
        end
        if PolynomialsQueue[2] then
            print("=====RESTO=====")
            for _, v in ipairs(PolynomialsQueue[2].Terms) do
                print(v)
            end
        end
        print(string.format(format, os.clock() - time))
        print("Continuar...")
        io.read()
   end
    clear()
    print("Regras de formatacao: \n1- Os operadores devem ser espacados, com excecao do unario '-' e do '^'.\n2- Cada polinomio ou monomio deve estar dentro de parenteses.\n\n")
    print("Exemplo de expressao valida: (-x^3 + 2x - 1) - (x^3 - 3x) * (x)\n\n")
    print("Insira uma expressao polinomial, ou digite -1 para encerrar o programa")
    input = io.read()
end