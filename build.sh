#!/bin/bash

# RJLogin OpenWrt 插件编译脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在OpenWrt编译环境中
check_openwrt_env() {
    if [ ! -f "rules.mk" ] || [ ! -d "package" ]; then
        print_error "请在OpenWrt源码根目录运行此脚本"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    print_info "检查编译依赖..."
    
    # 检查必要的工具
    for tool in make gcc; do
        if ! command -v $tool >/dev/null 2>&1; then
            print_error "缺少必要工具: $tool"
            exit 1
        fi
    done
    
    print_success "依赖检查完成"
}

# 复制插件到package目录
copy_package() {
    local src_dir="$(dirname "$0")/openwrt"
    local dst_dir="package/rjlogin"
    
    print_info "复制插件文件到 $dst_dir"
    
    if [ -d "$dst_dir" ]; then
        print_warning "目标目录已存在，将被覆盖"
        rm -rf "$dst_dir"
    fi
    
    mkdir -p "$dst_dir"
    cp -r "$src_dir"/* "$dst_dir"/
    
    print_success "文件复制完成"
}

# 配置编译选项
configure_build() {
    print_info "配置编译选项..."
    
    # 检查.config文件
    if [ ! -f ".config" ]; then
        print_warning "未找到.config文件，需要先配置编译选项"
        print_info "运行 'make menuconfig' 配置编译选项"
        print_info "在 Utilities 分类中启用 rjlogin"
        return 1
    fi
    
    # 检查是否已启用rjlogin
    if ! grep -q "CONFIG_PACKAGE_rjlogin=y" .config 2>/dev/null; then
        print_warning "rjlogin插件未在.config中启用"
        print_info "请运行 'make menuconfig' 并在 Utilities 中启用 rjlogin"
        return 1
    fi
    
    print_success "编译配置检查完成"
    return 0
}

# 编译插件
build_package() {
    print_info "开始编译 rjlogin 插件..."
    
    # 清理之前的编译
    make package/rjlogin/clean V=s
    
    # 编译插件
    if make package/rjlogin/compile V=s; then
        print_success "rjlogin 插件编译成功"
        
        # 查找生成的ipk文件
        local ipk_file=$(find bin/ -name "*rjlogin*.ipk" 2>/dev/null | head -1)
        if [ -n "$ipk_file" ]; then
            print_success "生成的包文件: $ipk_file"
            print_info "可以使用 scp 将此文件传输到路由器并安装"
            print_info "安装命令: opkg install $ipk_file"
        fi
    else
        print_error "编译失败"
        exit 1
    fi
}

# 显示使用说明
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -c, --copy     仅复制文件到package目录"
    echo "  -b, --build    仅编译（不复制文件）"
    echo ""
    echo "默认行为: 复制文件并编译"
}

# 主函数
main() {
    local copy_only=false
    local build_only=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--copy)
                copy_only=true
                shift
                ;;
            -b|--build)
                build_only=true
                shift
                ;;
            *)
                print_error "未知选项: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_info "RJLogin OpenWrt 插件编译脚本"
    print_info "================================"
    
    # 检查环境
    check_openwrt_env
    check_dependencies
    
    if [ "$build_only" = true ]; then
        # 仅编译
        if configure_build; then
            build_package
        fi
    elif [ "$copy_only" = true ]; then
        # 仅复制文件
        copy_package
        print_info "请运行 'make menuconfig' 配置编译选项"
    else
        # 默认：复制并编译
        copy_package
        if configure_build; then
            build_package
        else
            print_info "请先配置编译选项，然后重新运行脚本"
        fi
    fi
    
    print_success "脚本执行完成"
}

# 运行主函数
main "$@"