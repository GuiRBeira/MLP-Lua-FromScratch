-- matlib.lua
-- Disciplina: Sistemas Inteligentes 2
-- Aluno: Guilherme R. Beira
-- A simple matrix library for Lua
-- Matrices are represented as tables of tables (2D arrays)
-- Vectors are represented as tables (1D arrays)

-- Local variable
local M = {}

-- Make a array of zeros with given dimensions
function M.zeros_like_vec(v)
    local zeros_vec = {}
    for i = 1, #v do
        zeros_vec[i] = 0
    end
    return zeros_vec
end

-- Vector operations
function M.vec_add(v1, v2)
    local r = {}
    for i = 1, #v1 do
        r[i] = v1[i] + v2[i]
    end
    return r
end

function M.vec_sub(v1, v2)
    local r = {}
    for i = 1, #v1 do
        r[i] = v1[i] - v2[i]
    end
    return r
end

function M.vec_mult_scalar(v, s)
    local r = {}
    for i = 1, #v do
        r[i] = v[i] * s
    end
    return r
end

function M.vec_mult_vec(v1, v2)
    local r = {}
    for i = 1, #v1 do
        r[i] = v1[i] * v2[i]
    end
    return r
end

function M.vec_div_scalar(v, s)
    local r = {}
    for i = 1, #v do
        r[i] = v[i] / s
    end
    return r
end

function M.vec_div_vec(v1, v2, epsilon)
    epsilon = epsilon or 0.0 
    local r = {}
    for i = 1, #v1 do
        r[i] = v1[i] / (v2[i] + epsilon)
    end
    return r
end

function M.vec_dot(v1, v2)
    local r = 0
    for i = 1, #v1 do
        r = r + v1[i] * v2[i]
    end
    return r
end

function M.vec_pow(v, p)
    local r = {}
    for i = 1, #v do
        r[i] = v[i] ^ p
    end
    return r
end

function M.vec_sqrt(v)
    local r = {}
    for i = 1, #v do
        r[i] = math.sqrt(v[i])
    end
    return r
end

function M.vec_map(v, func)
    local r = {}
    for i = 1, #v do
        r[i] = func(v[i])
    end
    return r 
end

function M.vec_print(v)
    for i = 1, #v do
        io.write(string.format("%8.3f ", v[i]))
    end
    io.write("\n")
end

function M.vec_length(v)
    local sum = 0
    for i = 1, #v do
        sum = sum + v[i] * v[i]
    end
    return math.sqrt(sum)
end

function M.vec_normalize(v)
    local length = M.vec_length(v)
    if length == 0 then
        return v
    end
    return M.vec_div_scalar(v, length)
end

function M.vec_clone(v)
    local r = {}
    for i = 1, #v do
        r[i] = v[i]
    end
    return r
end

function M.vec_equal(v1, v2)
    if #v1 ~= #v2 then
        return false
    end
    for i = 1, #v1 do
        if v1[i] ~= v2[i] then
            return false
        end
    end
    return true
end

function M.vec_concat(v1, v2)
    local r = {}
    for i = 1, #v1 do
        r[#r + 1] = v1[i]
    end
    for i = 1, #v2 do
        r[#r + 1] = v2[i]
    end
    return r
end

function M.vec_slice(v, start_idx, end_idx)
    local r = {}
    for i = start_idx, end_idx do
        r[#r + 1] = v[i]
    end
    return r
end

function M.vec_reverse(v)
    local r = {}
    for i = #v, 1, -1 do
        r[#r + 1] = v[i]
    end
    return r
end

function M.vec_fill(v, value)
    local r = {}
    for i = 1, #v do
        r[i] = value
    end
    return r
end

function M.vec_sum(v)
    local sum = 0
    for i = 1, #v do
        sum = sum + v[i]
    end
    return sum
end

function M.vec_mean(v)
    return M.vec_sum(v) / #v
end

function M.vec_max(v)
    local max_val = v[1]
    for i = 2, #v do
        if v[i] > max_val then
            max_val = v[i]
        end
    end
    return max_val
end

function M.vec_min(v)
    local min_val = v[1]
    for i = 2, #v do
        if v[i] < min_val then
            min_val = v[i]
        end
    end
    return min_val
end

function M.vec_index_of(v, value)
    for i = 1, #v do
        if v[i] == value then
            return i
        end
    end
    return -1
end

function M.vec_contains(v, value)
    return M.vec_index_of(v, value) ~= -1
end

function M.vec_count(v, value)
    local count = 0
    for i = 1, #v do
        if v[i] == value then
            count = count + 1
        end
    end
    return count
end

-- Matrix operations
function M.zeros_like_mat(m)
    local zeros_mat = {}
    for i = 1, #m do
        zeros_mat[i] = {}
        for j = 1, #m[1] do
            zeros_mat[i][j] = 0
        end
    end
    return zeros_mat
end

function M.mat_add(m1, m2)
    local r = {}
    for i = 1, #m1 do
        r[i] = {}
        for j = 1, #m1[1] do
            r[i][j] = m1[i][j] + m2[i][j]
        end
    end
    return r
end

function M.mat_sub(m1, m2)
    local r = {}
    for i = 1, #m1 do
        r[i] = {}
        for j = 1, #m1[1] do
            r[i][j] = m1[i][j] - m2[i][j]
        end
    end
    return r
end

function M.mat_mult_scalar(m, s)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = m[i][j] * s
        end
    end
    return r
end

function M.mat_mult_mat(m1, m2)
    local r = {}
    for i = 1, #m1 do
        r[i] = {}
        for j = 1, #m2[1] do
            r[i][j] = 0
            for k = 1, #m1[1] do
                r[i][j] = r[i][j] + m1[i][k] * m2[k][j]
            end
        end
    end
    return r
end

function M.mat_mult_vec(m, v)
    local r = {}
    for i = 1, #m do
        r[i] = 0
        for j = 1, #m[1] do
            r[i] = r[i] + m[i][j] * v[j]
        end
    end
    return r
end

function M.mat_div_scalar(m, s)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = m[i][j] / s
        end
    end
    return r
end

function M.mat_div_mat(m1, m2, epsilon)
    epsilon = epsilon or 0.0
    local r = {}
    for i = 1, #m1 do
        r[i] = {}
        for j = 1, #m1[1] do
            r[i][j] = m1[i][j] / (m2[i][j] + epsilon)
        end
    end
    return r
end

function M.mat_map(m, func)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = func(m[i][j])
        end
    end
    return r
end

function M.mat_pow(m, p)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = m[i][j] ^ p
        end
    end
    return r
end

function M.mat_sqrt(m)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = math.sqrt(m[i][j])
        end
    end
    return r
end

function M.mat_get_row(m, row)
    local r = {}
    for j = 1, #m[1] do
        r[j] = m[row][j]
    end
    return r
end

function M.mat_get_col(m, col)
    local r = {}
    for i = 1, #m do
        r[i] = m[i][col]
    end
    return r
end

function M.mat_set_row(m, row, v)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            if i == row then
                r[i][j] = v[j]
            else
                r[i][j] = m[i][j]
            end
        end
    end
    return r
end

function M.mat_set_col(m, col, v)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            if j == col then
                r[i][j] = v[i]
            else
                r[i][j] = m[i][j]
            end
        end
    end
    return r 
end

function M.mat_transpose(m)
    local r = {}
    for i = 1, #m[1] do
        r[i] = {}
        for j = 1, #m do
            r[i][j] = m[j][i]
        end
    end
    return r 
end

function M.mat_print(m)
    for i = 1, #m do
        for j = 1, #m[1] do
            io.write(string.format("%8.3f ", m[i][j]))
        end
        io.write("\n")
    end
end

function M.mat_clone(m)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = m[i][j]
        end
    end
    return r 
end

function M.mat_equal(m1, m2)
    if #m1 ~= #m2 or #m1[1] ~= #m2[1] then
        return false
    end
    for i = 1, #m1 do
        for j = 1, #m1[1] do
            if m1[i][j] ~= m2[i][j] then
                return false
            end
        end
    end
    return true
end

function M.mat_fill(m, value)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = value
        end
    end
    return r 
end

function M.mat_sum(m)
    local sum = 0
    for i = 1, #m do
        for j = 1, #m[1] do
            sum = sum + m[i][j]
        end
    end
    return sum
end

function M.mat_mean(m)
    return M.mat_sum(m) / (#m * #m[1])
end

function M.mat_max(m)
    local max_val = m[1][1]
    for i = 1, #m do
        for j = 1, #m[1] do
            if m[i][j] > max_val then
                max_val = m[i][j]
            end
        end
    end
    return max_val
end

function M.mat_min(m)
    local min_val = m[1][1]
    for i = 1, #m do
        for j = 1, #m[1] do
            if m[i][j] < min_val then
                min_val = m[i][j]
            end
        end
    end
    return min_val
end

function M.mat_index_of(m, value)
    for i = 1, #m do
        for j = 1, #m[1] do
            if m[i][j] == value then
                return i, j
            end
        end
    end
    return -1, -1
end

function M.mat_contains(m, value)
    local i, j = M.mat_index_of(m, value)
    return i ~= -1 and j ~= -1
end

function M.mat_count(m, value)
    local count = 0
    for i = 1, #m do
        for j = 1, #m[1] do
            if m[i][j] == value then
                count = count + 1
            end
        end
    end
    return count
end

function M.mat_get_shape(m)
    return #m, #m[1]
end

function M.mat_is_square(m)
    return #m == #m[1]
end

function M.mat_is_vector(m)
    return #m == 1 or #m[1] == 1
end

function M.mat_is_empty(m)
    return #m == 0 or #m[1] == 0
end

function M.outer_product(v1, v2)
    local r = {}
    for i = 1, #v1 do
        r[i] = {}
        for j = 1, #v2 do
            r[i][j] = v1[i] * v2[j]
        end
    end
    return r 
end


-- Clamp functions to limit values within a range
local function clamp(x, min_val, max_val)
    return math.max(min_val, math.min(max_val, x))
end

function M.vec_clamp(v, min_val, max_val)
    local r = {}
    for i = 1, #v do
        r[i] = clamp(v[i], min_val, max_val)
    end
    return r
end

function M.mat_clamp(m, min_val, max_val)
    local r = {}
    for i = 1, #m do
        r[i] = {}
        for j = 1, #m[1] do
            r[i][j] = clamp(m[i][j], min_val, max_val)
        end
    end
    return r
end

return M
-- End of matlib.lua