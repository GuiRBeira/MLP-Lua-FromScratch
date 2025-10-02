-- neural_net.lua (versão final com barra de progresso estilo Keras)

local M = require("matlib")
local NeuralNet = {}

-- (Banco de funções de ativação - sem alterações)
local function activation_cubic(x) return x^3 + 0.5 end
local function derivative_cubic(x) return 3 * x^2 end
local function activation_sigmoid(x) return 1 / (1 + math.exp(-x)) end
local function derivative_sigmoid(saida) return saida * (1 - saida) end
local function activation_soft_cubic(x) return 0.5 * (math.tanh(x^3) + 1) end
local function derivative_soft_cubic(x)
    local exp_val = math.tanh(2 * x^3)
    local tanh_val = (exp_val - 1) / (exp_val + 1)
    return 0.5 * (1 - tanh_val^2) * (3 * x^2)
end

-- NOVIDADE: Uma função helper para desenhar a barra de progresso
local function print_progress(epoch, total_epochs, sample_idx, total_samples, loss, accuracy)
    local progress = sample_idx / total_samples
    local bar_width = 30
    local filled_width = math.floor(progress * bar_width)
    
    local bar = "[" .. string.rep("=", filled_width) .. string.rep(".", bar_width - filled_width) .. "]"
    
    -- \r move o cursor para o início da linha
    local line_str = string.format("\rÉpoca %d/%d %s %d/%d ", epoch, total_epochs, bar, sample_idx, total_samples)
    
    -- Os status finais (loss e accuracy) só são mostrados quando a barra está cheia
    if sample_idx == total_samples then
        line_str = line_str .. string.format("- perda: %.4f - acurácia: %.4f", loss, accuracy)
        -- Adicionamos uma quebra de linha no final da época
        io.write(line_str .. "\n")
    else
        io.write(line_str)
    end
    -- Força a impressão imediata no terminal
    io.stdout:flush()
end


-- A função de treinamento principal
function NeuralNet.training(X, T, Wh_inicial, Wo_inicial, theta_h_inicial, theta_o_inicial, hiperparametros)
    -- (Inicialização - sem alterações)
    local Wh, Wo = M.mat_clone(Wh_inicial), M.mat_clone(Wo_inicial)
    local theta_h, theta_o = M.vec_clone(theta_h_inicial), M.vec_clone(theta_o_inicial)
    local eta, epochs = hiperparametros.eta, hiperparametros.epochs
    local activation_func, derivative_func; if hiperparametros.activation == "cubic" then activation_func, derivative_func = activation_cubic, derivative_cubic elseif hiperparametros.activation == "sigmoid" then activation_func, derivative_func = activation_sigmoid, derivative_sigmoid elseif hiperparametros.activation == "soft_cubic" then activation_func, derivative_func = activation_soft_cubic, derivative_soft_cubic else error(string.format("Função de ativação desconhecida: '%s'", hiperparametros.activation)) end
    local mWh, vWh, mWo, vWo, mThetaH, vThetaH, mThetaO, vThetaO; if hiperparametros.optimizer == "adam" then mWh, vWh = M.zeros_like_mat(Wh), M.zeros_like_mat(Wh); mWo, vWo = M.zeros_like_mat(Wo), M.zeros_like_mat(Wo); mThetaH, vThetaH = M.zeros_like_vec(theta_h), M.zeros_like_vec(theta_h); mThetaO, vThetaO = M.zeros_like_vec(theta_o), M.zeros_like_vec(theta_o); end
    local t = 0; local error_history = {}; local acucary_history = {}
    print(string.format("Iniciando treinamento com Otimizador: '%s' | Ativação: '%s'", hiperparametros.optimizer, hiperparametros.activation))

    for epoch = 1, epochs do
        -- Loop de treinamento sobre cada amostra
        for i = 1, #X do
            t = t + 1
            local x_sample, t_sample = X[i], T[i]

            
            -- --- FORWARD E BACKWARD PASS (sem alterações na lógica) ---
            local net_h = M.vec_add(M.mat_mult_vec(M.mat_transpose(Wh), x_sample), theta_h)
            local out_h = M.vec_map(net_h, activation_func)
            local net_o = M.vec_dot(out_h, M.mat_get_col(Wo, 1))  + theta_o[1]
            local y_out = activation_func(net_o)
            
            local error = y_out - t_sample
            local delta_o, delta_h; if hiperparametros.activation == "sigmoid" then delta_o = error * derivative_func(y_out); delta_h = M.vec_mult_vec(M.mat_mult_vec(Wo, {delta_o}), M.vec_map(out_h, derivative_func)) else delta_o = error * derivative_func(net_o); delta_h = M.vec_mult_vec(M.mat_mult_vec(Wo, {delta_o}), M.vec_map(net_h, derivative_func)) end
            local grad_to = {delta_o}; local grad_Wo = M.outer_product(out_h, grad_to)
            local grad_th = delta_h; local grad_Wh = M.outer_product(x_sample, grad_th)
            local clip_value = 1.0; grad_Wo = M.mat_clamp(grad_Wo, -clip_value, clip_value); grad_to = M.vec_clamp(grad_to, -clip_value, clip_value); grad_Wh = M.mat_clamp(grad_Wh, -clip_value, clip_value); grad_th = M.vec_clamp(grad_th, -clip_value, clip_value)

            -- --- BLOCO DE ATUALIZAÇÃO DOS PESOS (sem alterações na lógica) ---
            if hiperparametros.optimizer == "adam" then local beta1, beta2, epsilon = hiperparametros.beta1, hiperparametros.beta2, hiperparametros.epsilon; mWh = M.mat_add(M.mat_mult_scalar(mWh, beta1), M.mat_mult_scalar(grad_Wh, 1 - beta1)); vWh = M.mat_add(M.mat_mult_scalar(vWh, beta2), M.mat_mult_scalar(M.mat_pow(grad_Wh, 2), 1 - beta2)); local m_hat_Wh = M.mat_div_scalar(mWh, 1 - beta1^t); local v_hat_Wh = M.mat_div_scalar(vWh, 1 - beta2^t); local update_Wh = M.mat_mult_scalar(M.mat_div_mat(m_hat_Wh, M.mat_map(v_hat_Wh, math.sqrt), epsilon), eta); Wh = M.mat_sub(Wh, update_Wh); mThetaH = M.vec_add(M.vec_mult_scalar(mThetaH, beta1), M.vec_mult_scalar(grad_th, 1 - beta1)); vThetaH = M.vec_add(M.vec_mult_scalar(vThetaH, beta2), M.vec_mult_scalar(M.vec_pow(grad_th, 2), 1 - beta2)); local m_hat_th = M.vec_div_scalar(mThetaH, 1 - beta1^t); local v_hat_th = M.vec_div_scalar(vThetaH, 1 - beta2^t); local update_th = M.vec_mult_scalar(M.vec_div_vec(m_hat_th, M.vec_map(v_hat_th, math.sqrt), epsilon), eta); theta_h = M.vec_sub(theta_h, update_th); mWo = M.mat_add(M.mat_mult_scalar(mWo, beta1), M.mat_mult_scalar(grad_Wo, 1 - beta1)); vWo = M.mat_add(M.mat_mult_scalar(vWo, beta2), M.mat_mult_scalar(M.mat_pow(grad_Wo, 2), 1 - beta2)); local m_hat_Wo = M.mat_div_scalar(mWo, 1 - beta1^t); local v_hat_Wo = M.mat_div_scalar(vWo, 1 - beta2^t); local update_Wo = M.mat_mult_scalar(M.mat_div_mat(m_hat_Wo, M.mat_map(v_hat_Wo, math.sqrt), epsilon), eta); Wo = M.mat_sub(Wo, update_Wo); mThetaO = M.vec_add(M.vec_mult_scalar(mThetaO, beta1), M.vec_mult_scalar(grad_to, 1 - beta1)); vThetaO = M.vec_add(M.vec_mult_scalar(vThetaO, beta2), M.vec_mult_scalar(M.vec_pow(grad_to, 2), 1 - beta2)); local m_hat_to = M.vec_div_scalar(mThetaO, 1 - beta1^t); local v_hat_to = M.vec_div_scalar(vThetaO, 1 - beta2^t); local update_to = M.vec_mult_scalar(M.vec_div_vec(m_hat_to, M.vec_map(v_hat_to, math.sqrt), epsilon), eta); theta_o = M.vec_sub(theta_o, update_to)
            elseif hiperparametros.optimizer == "sgd" then Wh = M.mat_sub(Wh, M.mat_mult_scalar(grad_Wh, eta)); theta_h = M.vec_sub(theta_h, M.vec_mult_scalar(grad_th, eta)); Wo = M.mat_sub(Wo, M.mat_mult_scalar(grad_Wo, eta)); theta_o = M.vec_sub(theta_o, M.vec_mult_scalar(grad_to, eta))
            else error(string.format("Otimizador desconhecido: '%s'", hiperparametros.optimizer)) end
        end
        
        -- NOVIDADE: Ao final de cada época, calculamos as métricas finais e mostramos a barra completa.
        local total_epoch_error = 0
        local correct_predictions = 0
        for i = 1, #X do
            local x_err, t_err = X[i], T[i]
            local net_h_err = M.vec_add(M.mat_mult_vec(M.mat_transpose(Wh), x_err), theta_h)
            local out_h_err = M.vec_map(net_h_err, activation_func)
            local net_o_err = M.vec_dot(out_h_err, M.mat_get_col(Wo, 1)) + theta_o[1]
            local y_out_err = activation_func(net_o_err)
            
            -- Cálculo da Perda (Loss)
            total_epoch_error = total_epoch_error + (t_err - y_out_err)^2 -- Erro quadrático
            
            local prediction = (y_out_err > 0.5) and 1 or 0  
            -- Comparamos com o alvo real
            if prediction == t_err then
                correct_predictions = correct_predictions + 1
            end
        end
        local final_loss = total_epoch_error / #X
        local final_accuracy = correct_predictions / #X
        table.insert(acucary_history, final_accuracy)
        table.insert(error_history, final_loss)

        -- Imprime a linha final da época, sobrescrevendo a barra de progresso
        print_progress(epoch, epochs, #X, #X, final_loss, final_accuracy)
        if final_accuracy >= 1.0 then
            print(string.format("\nParada antecipada na Época %d: Acurácia de 100%% atingida!", epoch))
            break -- Interrompe o loop principal de épocas
        end
    end

    print("Treinamento concluído.")
    return Wh, Wo, theta_h, theta_o, error_history, acucary_history
end

return NeuralNet