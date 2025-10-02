-- main.lua (versão 100% final e corrigida)
-- Disciplina: Sistemas Inteligentes 2
-- Aluno: Guilherme R. Beira

print("Carregando módulos...")
local M = require("matlib")
local NeuralNet = require("neural_net")
local PlotLib = require("plotlib")

print("Configurando o problema...")
local X = {{0, 0}, {0, 1}, {1, 0}, {1, 1}}
local T = {0, 1, 1, 0}
local Wh_inicial = {{0.20, 0.35}, {0.15, 0.18}}
local Wo_inicial = {{0.10}, {0.12}}
local theta_h_inicial = {0.05, 0.06}
local theta_o_inicial = {0.07}

local hiperparametros = {
    optimizer = "adam",        -- Opções: "sgd", "adam"
    eta = 0.1,                 -- Adam geralmente prefere taxas de aprendizado menores
    epochs = 100000,              -- Número de épocas aumentado para melhor convergência
    beta1 = 0.9,               -- Parâmetro beta1 para Adam, se não for usado, pode ser ignorado
    beta2 = 0.999,             -- Parâmetro beta2 para Adam, se não for usado, pode ser ignorado
    epsilon = 1e-8,            -- Pequeno valor para evitar divisão por zero em Adam, se não for usado, pode ser ignorado
    activation = "sigmoid"       -- Opções: "cubic", "sigmoid", "soft_cubic (tanh)"
}

-- CORREÇÃO FINAL: A ordem das variáveis no retorno agora está correta.
local Wh_final, Wo_final, theta_h_final, theta_o_final, historico_de_erros, historico_de_acuracia = NeuralNet.training(
    X, T,
    Wh_inicial, Wo_inicial,
    theta_h_inicial, theta_o_inicial,
    hiperparametros
)

print("Gerando visualizações com a PlotLib...")

-- Gráfico 1: Curva de Aprendizagem
local grafico_erro = PlotLib.new()
grafico_erro:set_title("Curva de Aprendizagem (Otimizador: " .. hiperparametros.optimizer .. ")")
grafico_erro:set_labels("Época", "Erro Quadrático Médio")
grafico_erro:add_line_series(historico_de_erros, "Erro do Modelo")
grafico_erro:render("grafico_curva_erro.png")

-- Gráfico 2: Acurácia ao Longo do Treinamento
local grafico_acuracia = PlotLib.new()
grafico_acuracia:set_title("Acurácia ao Longo do Treinamento (Otimizador: " .. hiperparametros.optimizer .. ")")
grafico_acuracia:set_labels("Época", "Acurácia")
grafico_acuracia:add_line_series(historico_de_acuracia, "Acurácia do Modelo")
grafico_acuracia:render("grafico_curva_acuracia.png")

-- Gráfico 3: Fronteira de Decisão
local grid_data, pontos_xor_data = {}, {}
do
    for i = 1, #X do table.insert(pontos_xor_data, {X[i][1], X[i][2], T[i]}) end
    local activation = hiperparametros.activation == "cubic" and function(x) return x^3 + 0.5 end
        or hiperparametros.activation == "sigmoid" and function(x) return 1 / (1 + math.exp(-x)) end
        or hiperparametros.activation == "soft_cubic" and function(x) return 0.5 * (math.tanh(x^3) + 1) end
        or error("Função de ativação desconhecida: " .. hiperparametros.activation)
    local step = 0.01
    for x1 = -0.5, 1.5, step do
        for x2 = -0.5, 1.5, step do
            local ponto = {x1, x2}
            -- Esta linha agora receberá o theta_h_final correto (tamanho 2)
            local net_h = M.vec_add(M.mat_mult_vec(M.mat_transpose(Wh_final), ponto), theta_h_final)
            local out_h = M.vec_map(net_h, activation)
            local net_o = M.vec_dot(out_h, M.mat_get_col(Wo_final, 1)) + theta_o_final[1]
            local z = activation(net_o)
            table.insert(grid_data, {x1, x2, z})
        end
    end
end

local grafico_fronteira = PlotLib.new()
grafico_fronteira:set_title("Fronteira de Decisão (Otimizador: " .. hiperparametros.optimizer .. ")")
grafico_fronteira:set_labels("Entrada X1", "Entrada X2")
grafico_fronteira:add_heatmap_series(grid_data)
grafico_fronteira:add_scatter_series(pontos_xor_data, "Classes XOR")
grafico_fronteira:render("grafico_fronteira_decisao.png")

print("\n====================================================")
print("Projeto concluído com sucesso!")
print("Verifique os arquivos 'grafico_curva_erro.png' e 'grafico_fronteira_decisao.png'.")
print("====================================================")