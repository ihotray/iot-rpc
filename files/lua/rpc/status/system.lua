local rpc = require 'iot.rpc'
local fs = require 'iot.fs'

local M = {}

function M.get_stat()
    local stat_file = '/proc/stat'
    local data = fs.readfile(stat_file)
    local user, nice, system, idle, iowait, irq, softirq, steal = data:match(
        "cpu +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+) +(%d+)")

    user = tonumber(user)
    nice = tonumber(nice)
    system = tonumber(system)
    idle = tonumber(idle)
    iowait = tonumber(iowait)
    irq = tonumber(irq)
    softirq = tonumber(softirq)
    steal = tonumber(steal)

    return rpc.result_response('status/system', {
        stat = {
            user = user,
            nice = nice,
            system = system,
            idle = idle,
            iowait = iowait,
            irq = irq,
            softirq = softirq,
            steal = steal
        }
    })
end

function M.get_uptime()
    local uptime_file = '/proc/uptime'
    local data = fs.readfile(uptime_file)
    local uptime, idle = data:match("(%d+%.%d+) (%d+%.%d+)")
    return rpc.result_response('status/system', {
        uptime = uptime,
        idle = idle
    })
end

function M.get_memory()
    local meminfo_file = '/proc/meminfo'
    local data = fs.readfile(meminfo_file)
    local total = data:match("MemTotal:%s+(%d+) kB")
    local free = data:match("MemFree:%s+(%d+) kB")
    local buffers = data:match("Buffers:%s+(%d+) kB")
    local cached = data:match("Cached:%s+(%d+) kB")
    total = tonumber(total)
    free = tonumber(free)
    buffers = tonumber(buffers)
    cached = tonumber(cached)
    return rpc.result_response('status/system', {
        memory = {
            total = total,
            free = free,
            buffers = buffers,
            cached = cached
        }
    })

end

return M
