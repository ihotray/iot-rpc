local rpc = require 'iot.rpc'
local fs = require 'iot.fs'
local cjson = require 'cjson.safe'
local ubus = require 'ubus'

local M = {}

function M.get_info()
    local release_file = '/etc/openwrt_release'
    local data = fs.readfile(releas_file)
    local version = data:match("DISTRIB_RELEASE='(%S+)'")

    local board_file = '/etc/board.json'
    data = fs.readfile(board_file)
    local board = cjson.decode(data)
    local address_file = '/sys/class/net/' .. board.network.wan.device .. '/address'
    data = fs.readfile(address_file)

    return rpc.result_response('status/system', {
        info = {
            version = version,
            mac = data
        }
    })

end

function M.get_stat()
    local stat_file = '/proc/stat'
    local data = fs.readfile(stat_file)
    local user, nice, system, idle, iowait, irq, softirq, steal = data:match(
        "cpu +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+)")

    return rpc.result_response('status/system', {
        stat = {
            user = tonumber(user),
            nice = tonumber(nice),
            system = tonumber(system),
            idle = tonumber(idle),
            iowait = tonumber(iowait),
            irq = tonumber(irq),
            softirq = tonumber(softirq),
            steal = tonumber(steal)
        }
    })
end

function M.get_uptime()
    local uptime_file = '/proc/uptime'
    local data = fs.readfile(uptime_file)
    local uptime, idle = data:match("(%d+%.%d+) (%d+%.%d+)")
    return rpc.result_response('status/system', {
        uptime = tonumber(uptime),
        idle = tonumber(idle)
    })
end

function M.get_memory()
    local meminfo_file = '/proc/meminfo'
    local data = fs.readfile(meminfo_file)
    local total = data:match("MemTotal:%s+(%d+) kB")
    local free = data:match("MemFree:%s+(%d+) kB")
    local buffers = data:match("Buffers:%s+(%d+) kB")
    local cached = data:match("Cached:%s+(%d+) kB")

    return rpc.result_response('status/system', {
        memory = {
            total = tonumber(total),
            free = tonumber(free),
            buffers = tonumber(buffers),
            cached = tonumber(cached)
        }
    })

end

function M.get_log()

    local data = {}
    local f = io.popen('logread -l 50', 'r')
    if f then
        for line in f:lines() do
            local date, content = line:match("^(%a+ +%a+ +%d+ +%d+:%d+:%d+ %d+) +(.+)$")
            if date and content then
                local entry = {
                    date = date,
                    content = content
                }
                table.insert(data, entry)
            end
        end
        f:close()
    end

    return rpc.result_response('status/system', {
        log = data
    })
end

return M
