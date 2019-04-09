local _M = {} 
local ffi  = require "ffi"
local uuid = ffi.load("uuid")
ffi.cdef [[
	void uuid_generate(unsigned char out[16]);
	void uuid_generate_random(unsigned char out[16]);
	int uuid_is_null(const unsigned char out[16]);
	int uuid_parse(const char *in,const unsigned char out[16]);
	void uuid_unparse(const unsigned char uu[16],char *out);
	void uuid_unparse_lower(const unsigned char uu[16],char *out);
	void *memset(void *s,int c,size_t n);
]]
local guuid = function ()
	local uu = ffi.new("unsigned char [?]",16)
	local out = ffi.new("unsigned char [?]",64)
	ffi.C.memset(out,0,64)
	uuid.uuid_generate_random(uu)
	if uuid.uuid_is_null(uu) == 0 then
		uuid.uuid_unparse_lower(uu,out)
		--print (ffi.string(out))
		return ffi.string(out)
	else
		return nil
	end
end
_M.uuid = guuid
return _M
