#!/bin/sh /etc/rc.common

# 启动顺序
START=95
STOP=15

USE_PROCD=1
PROG=/usr/sbin/rjlogin
CONF=/etc/config/rjlogin

# 检查配置并设置定时任务
setup_cron() {
    local enable
    local time
    
    config_load rjlogin
    config_get enable server enable "0"
    config_get time server time "06:00"
    
    # 移除旧的定时任务
    sed -i '/rjlogin/d' /etc/crontabs/root 2>/dev/null || true
    
    if [ "$enable" = "1" ]; then
        # 解析时间 (HH:MM 格式)
        local hour=$(echo $time | cut -d':' -f1)
        local minute=$(echo $time | cut -d':' -f2)
        
        # 添加新的定时任务
        echo "$minute $hour * * * /usr/sbin/rjlogin >/dev/null 2>&1" >> /etc/crontabs/root
        
        # 重启cron服务
        /etc/init.d/cron restart
        
        logger -t rjlogin "定时任务已设置: 每天 $time 执行登录"
    else
        logger -t rjlogin "RJLogin已禁用，清除定时任务"
    fi
}

# 清理定时任务
cleanup_cron() {
    sed -i '/rjlogin/d' /etc/crontabs/root 2>/dev/null || true
    /etc/init.d/cron restart
}

start_service() {
    local enable
    
    config_load rjlogin
    config_get enable server enable "0"
    
    if [ "$enable" = "1" ]; then
        setup_cron
        logger -t rjlogin "RJLogin Client 已启动"
    else
        cleanup_cron
        logger -t rjlogin "RJLogin Client 已禁用"
    fi
}

stop_service() {
    cleanup_cron
    logger -t rjlogin "RJLogin Client 已停止"
}

reload_service() {
    stop_service
    start_service
}