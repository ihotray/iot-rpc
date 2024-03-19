local cjson = require 'cjson.safe'
local uci = require 'uci'
local rpc = require 'iot.rpc'
local md5 = require 'iot.md5'


local M = {}

local function random_string(n)
    local t = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    }
    local s = {}
    for i = 1, n do
        s[#s + 1] = t[math.random(#t)]
    end

    return table.concat(s)
end

function M.challenge(req)
    req = cjson.decode(req)
    local username = req.param.username

    if type(username) ~= 'string' then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    local c = uci.cursor()
    local found = false

    c:foreach('iot', 'user', function(s)
        if s.username == username then
            found = true
            return false
        end
    end)

    if not found then
        return rpc.error_response(req.method, rpc.ERROR_COED_INVALID_USERNAME_PASSWORD)
    end

    local nonce = random_string(32)
    local data = {
        username = username,
        nonce = nonce or cjson.null
    }

    return rpc.result_response(req.method, data)

end

function M.login(req)
    req = cjson.decode(req)
    local username = req.param.username
    local password = req.param.password
    local nonce = req.param.nonce

    if type(username) ~= 'string' or type(password) ~= 'string' or type(nonce) ~= 'string' then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    local c = uci.cursor()
    local valid = false
    c:foreach('iot', 'user', function(s)
        if s.username == username then
            if not s.password then
                return false
            end

            local md5ctx = md5.new()
            md5ctx:hash(s.password..':'..nonce)
            if password == md5ctx:done() then
                valid = true
                return false
            end

            return false
        end
    end)

    if not valid then
        return rpc.error_response(req.method, rpc.ERROR_COED_INVALID_USERNAME_PASSWORD)
    end

    local token = random_string(32)
    return rpc.result_response(req.method, {token = token, username = username})

end

function M.init_password(req)
    req = cjson.decode(req)
    local username = req.param.username
    local password = req.param.password

    if type(username) ~= 'string' or type(password) ~= 'string' then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    local c = uci.cursor()
    local valid = false
    local id
    c:foreach('iot', 'user', function(s)
        if s.username == username then
            if not s.password then
                valid = true
            end
            id = s['.name']
            return false
        end
    end)

    -- password is not blank
    if not valid then
        return rpc.error_response(req.method, rpc.ERROR_COED_INVALID_USERNAME_PASSWORD)
    end

    local md5ctx = md5.new()
    md5ctx:hash(username..':'..password)
    c:set('iot', id, 'password', md5ctx:done())
    local res = c:commit('iot')

    local token = random_string(32)
    return rpc.result_response(req.method, {token = token})

end

function M.is_inited(req)
    req = cjson.decode(req)
    local username = req.param.username
    if type(username) ~= 'string' then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    local c = uci.cursor()
    local inited = true
    c:foreach('iot', 'user', function(s)
        if s.username == username then
            if not s.password then
                inited = false
            end
            return false
        end
    end)

    return rpc.result_response(req.method, {inited = inited})
end


function M.get_locale(req)
    req = cjson.decode(req)
    local c = uci.cursor()
    local locale = c:get('iot', 'global', 'locale')

    return rpc.result_response(req.method, { locale = locale })

end

function M.set_locale(req)
    req = cjson.decode(req)

    local c = uci.cursor()
    local locale = req.param.locale
    if type(locale) ~= 'string' then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    c:set('iot', 'global', 'locale', locale)
    local res = c:commit('iot')
    return rpc.result_response(req.method, res or cjson.null)

end

function M.call(req)
    req = cjson.decode(req)

    local param = req.param

    if #param < 2 then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    local mod = param[1]
    local func = param[2]
    local args = param[3] or {}

    if type(mod) ~= "string" or type(func) ~= "string" or type(args) ~= "table" then
        return rpc.error_response(req.method, rpc.ERROR_CODE_INVALID_PARAMS)
    end

    return rpc.call(mod, func, args, {username = req.username, topic = req.topic}) --topic 用于异步回复, 可用于websocket场景

end

function M.board_info(req)
    return M.call(req)
end

return M
