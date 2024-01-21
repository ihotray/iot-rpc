local syslog = require("posix.syslog")

local log = {_version = "0.1.0"}

local level_map = {
    [syslog.LOG_ERR] = "error",
    [syslog.LOG_WARNING]  = "warn",
    [syslog.LOG_NOTICE] = "notice",
    [syslog.LOG_INFO] = "info",
    [syslog.LOG_DEBUG] = "debug"
}

local function build_msg(err_msg, level, msg, error)
    local srv = "iot-rpc"
    local info = debug.getinfo(5, "Sl")
    local caller = info.short_src .. ":" .. info.currentline
    local ts = os.date("%Y-%m-%d %H:%M:%S")
    return string.format(err_msg, srv, level_map[level], ts, caller, msg, error)
end

local text_handle = function (level, msg, error)
    local err_msg = [[srv=%s level=%s ts=%s caller=%s msg=%s]]
    if error then
        err_msg = [[srv=%s level=%s ts=%s caller=%s msg=%s error=%s]]
    end
    return build_msg(err_msg, level, msg, error)
end

local json_handle = function (level, msg, error)
    local err_msg = [[{"srv": "%s", "level": "%s", "ts": "%s", "caller": "%s", "msg": "%s"}]]
    if error then
        err_msg = [[{"srv": "%s", "level": "%s", "ts": "%s", "caller": "%s", "msg": "%s", "error": "%s"}]]
    end
    return build_msg(err_msg, level, msg, error)
end

log.default_handle = "text"

local handle_map = {
    text = text_handle,
    json = json_handle
}

local handel = function (level, msg, err)
    local s = handle_map[log.default_handle](level, msg, err)
    syslog.syslog(level, s)
end

function log.info(msg, err)
    handel(syslog.LOG_INFO, msg, err)
end

function log.debug(msg, err)
    handel(syslog.LOG_DEBUG, msg, err)
end

function log.warn(msg, err)
    handel(syslog.LOG_WARNING, msg, err)
end

function log.error(msg, err)
    handel(syslog.LOG_ERR, msg, err)
end

return log
