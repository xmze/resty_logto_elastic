local function write_es(body,endpoint)
        if not (body and endpoint) then
                return -1,-1
        end
        local http = require "resty.http"
        local http_c = http:new()
        local res,err = http_c:request_uri(
                        endpoint,
                        {
                                method = "POST",
                                body = body,
                                headers = {
                                        ["Content-Type"] = "application/json",
                                }
                        }
                        )
        http:close()
        if not res then
                return -1,-2
        end
        if (res.status < 200 or res.status >= 300) then
                return -1,res.status
        end
        return 0,res.status
end

local function loop_hand(premature)
        local wid = ngx.worker.id()
	if ((wid ~= 0) and (wid ~= 1)) then
		return
	end
        if premature then
                return
        end
        local max_keys = 3000
        local ngx_shm_buf = nil
        local es_index_fix = '{"index": { } } \n'
        local es_endpoint = 'http://172.17.0.11:9200/a/b/_bulk'
        local keys_buf = ''
        local r_wid = wid%2
        local ngx_shm_name = 'ngx_log_buf'..tostring(r_wid)
        local ngx_shm_buf = ngx.shared[ngx_shm_name]
	local h = '127.0.0.1' -- es host
	local p = '9200' -- es port
        local es_endpoint = "http://"..h..":"..p.."/lua-2841-"..os.date("%Y%m%d",os.time()).."/ngxlog/_bulk"
		
        local logs = ngx_shm_buf:get_keys(max_keys)
        if (#logs > 0) then
                for k,v in pairs(logs) do
                        local tvv = ngx_shm_buf:get(v)
			if (tvv ~= nil) then 
                        	keys_buf = keys_buf .. es_index_fix .. tvv .. '\n'
			end 
                end
                local a,b = write_es(keys_buf,es_endpoint)
                ngx.log(ngx.ERR,"workerid: "..wid.."\tstatus: "..a..'\t status_code: '..b.."\tnumber: "..#logs..'\n')
                for k,v in pairs(logs) do 
                        ngx_shm_buf:delete(v)
                end
        end
		local sleep_time = 0.5
		if (#logs > (max_keys - 500)) then
			sleep_time = 0.1
		end
		if not ngx.worker.exiting() then
			local ok ,err = ngx.timer.at(sleep_time,loop_hand)
		end
end

if not ngx.worker.exiting() then
	local ok ,err = ngx.timer.at(0.2,loop_hand)
end

