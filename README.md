实时nginx日志入库elasticsearch，傻瓜配置。

依赖openresty，请自行安装

依赖libuuid，请自行安装

依赖https://github.com/ledgetech/lua-resty-http，请自行安装

需要elasticsearch，请自行安装

nginx配置
* 添加shm配置，请适当调整，用于申请共享内存：
    * lua_shared_dict ngx_log_buf0 512m;
    * lua_shared_dict ngx_log_buf1 512m;
* 加载lua文件
    * init_worker_by_lua_file lua/init_worker.lua;
    * log_by_lua_file lua/log.lua;
