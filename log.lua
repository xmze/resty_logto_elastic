--tab内表示要上报的内容，为1则认为是数字。
local ngx_log = {
        server_addr			 	= 0,
        remote_user 				= 0,
        host					= 0,
        rip					= 0,
        upstream_addr				= 0,
        status					= 1,
        server_protocol				= 0,
        request_method				= 0,
        request_only_uri			= 0,
        query_string				= 0,
        request_time				= 1,
        body_bytes_sent				= 1,
        upstream_status				= 1,
        upstream_response_time			= 1,
        http_referer				= 0,
        http_user_agent				= 0,
        http_cookie				= 0,
        upstream_cache_status			= 0,
        arg_devId				= 0,
        qq					= 0,
        uuid					= 0,
        time					= 1 
}
local ngx_log_table = ngx_log
local cjson = require "cjson"
local guuid = require "uuid"
local ngx_wid = ngx.worker.id()
local r_wid = ngx_wid%2
local ngx_shm_name = 'ngx_log_buf'..tostring(r_wid)
local ngx_shm_buf = ngx.shared[ngx_shm_name]
local ngx_log_json_t = {}
local ngx_log_json_s = ''
local uuid = ngx.var.uuid
if not uuid then
        uuid = guuid.uuid()
end
for k,v in pairs(ngx_log_table) do
        local tmp_value = ngx.var[k] or '-'
        if (v == 1) then
                tmp_value = tonumber(tmp_value)
        end
        ngx_log_json_t[k] = tmp_value
end
ngx_log_json_s = cjson.encode(ngx_log_json_t)
ngx_shm_buf:set(uuid,ngx_log_json_s)
