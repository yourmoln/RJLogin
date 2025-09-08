require("luci.sys")

-- 页面标题和描述
m = Map("rjlogin", translate("RJLogin Client"), translate("自动执行登录请求的客户端程序"))

-- 读取配置文件
s = m:section(TypedSection, "server", translate("服务器配置"))
s.addremove = false
s.anonymous = true

-- 是否启用的选择框
enable = s:option(Flag, "enable", translate("启用"))
enable.default = "0"
enable.rmempty = false

-- 映射我们的配置到输入框
username = s:option(Value, "username", translate("用户名"))
username.placeholder = "请输入登录用户名"

password = s:option(Value, "password", translate("密码"))
password.password = true
password.placeholder = "请输入登录密码"

time = s:option(Value, "time", translate("执行时间"))
time.placeholder = "06:00"
time.default = "06:00"
time.description = translate("每天执行登录的时间，格式：HH:MM")

url = s:option(Value, "url", translate("登录URL"))
url.default = "http://10.10.12.13/eportal/InterFace.do?method=login"
url.description = translate("登录接口的URL地址")

referer = s:option(Value, "referer", translate("Referer"))
referer.default = "http://10.10.12.13/eportal/index.jsp"
referer.description = translate("HTTP Referer头，用于防盗链")

-- 如果点击了保存按钮
local apply = luci.http.formvalue("cbi.apply")
if apply then
    -- 这里是调用我们自己的程序脚本
    io.popen("/etc/init.d/rjlogin restart > /dev/null &")
end

return m