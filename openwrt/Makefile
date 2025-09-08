include $(TOPDIR)/rules.mk
 
PKG_NAME:=RJLogin
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
 
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
 
include $(INCLUDE_DIR)/package.mk
 
# 定义基础信息
define Package/rjlogin
    SECTION:=utils
    CATEGORY:=Utilities
    TITLE:=rjlogin
    DEPENDS:=+ipset +dnsmasq-full +curl
    URL:=https://github.com/yourmoln
    MAINTAINER:=yourmoln
endef
 
# 描述信息
define Package/rjlogin/description
    This package contains LuCI configuration pages for rjlogin.
endef
 
# 安装方法
define Package/rjlogin/install
    # 这部分是代码是初始化安装目录
    $(INSTALL_DIR) $(1)/etc/config
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
    $(INSTALL_DIR) $(1)/usr/sbin
 
    # 这里是将需要的文件 copy 的系统中
    $(INSTALL_CONF) ./files/etc/config/rjlogin $(1)/etc/config/rjlogin
    $(INSTALL_BIN) ./files/etc/init.d/rjlogin.sh $(1)/etc/init.d/rjlogin
    $(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/rjlogin.lua $(1)/usr/lib/lua/luci/model/cbi/rjlogin.lua
    $(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/rjlogin.lua $(1)/usr/lib/lua/luci/controller/rjlogin.lua
    $(INSTALL_BIN) ./files/usr/sbin/rjlogin $(1)/usr/sbin/rjlogin
    $(INSTALL_BIN) ./files/usr/sbin/rjlogin-test $(1)/usr/sbin/rjlogin-test
endef
 
$(eval $(call BuildPackage,rjlogin))