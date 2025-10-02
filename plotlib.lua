-- plotlib.lua (versão final com visualização 2D)
-- Disciplina: Sistemas Inteligentes 2
-- Aluno: Guilherme R. Beira

local PlotLib = {}
local PlotLibMT = { __index = PlotLib }

function PlotLib.new()
    local plot = {
        title = "Gráfico",
        xlabel = "Eixo X",
        ylabel = "Eixo Y",
        series = {},
        temp_files_counter = 0,
        temp_files = {}
    }
    setmetatable(plot, PlotLibMT)
    return plot
end

function PlotLib:set_title(title) self.title = title end
function PlotLib:set_labels(xlabel, ylabel) self.xlabel, self.ylabel = xlabel, ylabel end

local function get_temp_filename(plot_obj)
    plot_obj.temp_files_counter = plot_obj.temp_files_counter + 1
    local filename = "temp_data_" .. plot_obj.temp_files_counter .. ".dat"
    table.insert(plot_obj.temp_files, filename)
    return filename
end

function PlotLib:add_line_series(data, legend_title) table.insert(self.series, { type = "line", data = data, filename = get_temp_filename(self), legend = legend_title or "Série"}) end
function PlotLib:add_heatmap_series(data) table.insert(self.series, { type = "heatmap", data = data, filename = get_temp_filename(self) }) end
function PlotLib:add_scatter_series(data, legend_title) table.insert(self.series, { type = "scatter", data = data, filename = get_temp_filename(self), legend = legend_title or "Pontos" }) end

local function write_data_files(series_list)
    for _, s in ipairs(series_list) do
        local file, errmsg = io.open(s.filename, "w")
        if file then
            if s.type == "line" then for i, val in ipairs(s.data) do file:write(string.format("%d\t%f\n", i, val)) end
            elseif s.type == "heatmap" then
                local last_x = nil
                for _, point in ipairs(s.data) do
                    if last_x and point[1] ~= last_x then file:write("\n") end
                    file:write(string.format("%f\t%f\t%f\n", point[1], point[2], point[3]))
                    last_x = point[1]
                end
            elseif s.type == "scatter" then for _, point in ipairs(s.data) do file:write(string.format("%f\t%f\t%d\n", point[1], point[2], point[3])) end
            end
            file:close()
        else
            print(string.format("ERRO CRÍTICO em PlotLib: Não foi possível criar o arquivo temporário '%s'. Motivo: %s", s.filename, errmsg))
            return false
        end
    end
    return true
end

function PlotLib:render(output_filename)
    if #self.series == 0 then print("Aviso em PlotLib: Nenhum dado para plotar."); return end

    local success = write_data_files(self.series)
    if not success then print("PlotLib: Renderização cancelada."); return end

    local gnu_script_name = "temp_script.gnu"; table.insert(self.temp_files, gnu_script_name)
    local script_file, errmsg = io.open(gnu_script_name, "w")
    if not script_file then print(string.format("ERRO CRÍTICO em PlotLib: Não foi possível criar o arquivo de script '%s'. Motivo: %s", gnu_script_name, errmsg)); return end

    script_file:write(string.format("set terminal pngcairo size 800,600 enhanced font 'Verdana,10'\n"))
    script_file:write(string.format("set output '%s'\n", output_filename))
    script_file:write(string.format("set title '%s'\n", self.title))
    script_file:write(string.format("set xlabel '%s'\n", self.xlabel))
    script_file:write(string.format("set ylabel '%s'\n", self.ylabel))
    script_file:write("set grid\n")

    local plot_commands = {}; local has_heatmap = false
    for _, s in ipairs(self.series) do if s.type == "heatmap" then has_heatmap = true end end

    if has_heatmap then
        script_file:write("set palette defined (0 '#3B4CC0', 1 '#B40426')\n")
        script_file:write("set cbrange [0:1]\n")
        
        -- A MUDANÇA ESTÁ AQUI
        script_file:write("set view map\n") -- Muda a perspectiva para uma visão 2D de cima
        
        for _, s in ipairs(self.series) do
            if s.type == "heatmap" then table.insert(plot_commands, string.format("'%s' with pm3d title ''", s.filename))
            elseif s.type == "scatter" then table.insert(plot_commands, string.format("'%s' using 1:2:($3+0.01) with points pt 7 ps 2 palette title '%s'", s.filename, s.legend)) end
        end
        script_file:write("splot " .. table.concat(plot_commands, ", \\\n      "))
    else 
        for _, s in ipairs(self.series) do
            if s.type == "line" then table.insert(plot_commands, string.format("'%s' with lines title '%s'", s.filename, s.legend))
            elseif s.type == "scatter" then table.insert(plot_commands, string.format("'%s' using 1:2 with points pt 7 ps 2 title '%s'", s.filename, s.legend)) end
        end
        script_file:write("plot " .. table.concat(plot_commands, ", "))
    end

    script_file:close()
    
    print(string.format("Executando Gnuplot para gerar '%s'...", output_filename))
    os.execute(string.format("gnuplot %s", gnu_script_name))
    
    for _, filename in ipairs(self.temp_files) do local f = io.open(filename, "r"); if f then f:close(); os.remove(filename) end end
    print("Gráfico gerado e arquivos temporários limpos.")
end

return PlotLib