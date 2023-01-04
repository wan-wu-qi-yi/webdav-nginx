#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


#------------------------------------------


    ##这是个配置变量的shell文件##   


#------------------------------------------


#目录
#基础目录 nginx安装目录所在的目录(根据需要更改)
base_folder="/usr/local"

#nginx安装目录名称(根据需要更改)
nginx_folder_name="nginx_webdav"
nginx_folder="${base_folder}/${nginx_folder_name}" && mkdir -p ${nginx_folder}

#数据存放目录(根据需要更改)
sync_folder="${base_folder}/.webdav_sync_data" &&  mkdir -p ${sync_folder}



#https相关文件存放目录
ssl_folder="${nginx_folder}/conf/ssl" &&  mkdir -p ${ssl_folder}

#git下载的仓库（webdav 扩展模块）存放的目录
nginx_and_webdav_module_folder_name="nginx_and_webdavExtModule"
nginx_and_webdav_module_folder="${base_folder}/${nginx_and_webdav_module_folder_name}" && mkdir -p ${nginx_and_webdav_module_folder}

#webdav配置相关目录
dav_config_folder="${nginx_folder}/conf/dav" && mkdir -p ${dav_config_folder}

#jq解析器(解析json文件)
jq_folder="${base_folder}/jq" && mkdir -p ${jq_folder}



#文件
#证书和私钥文件
nginx_cert="${ssl_folder}/nginx.crt"
nginx_key="${ssl_folder}/nginx.key"

#webdav登录用的密码文件
davpasswd_file="${dav_config_folder}/.davpasswd"
#webdav配置信息文件
webdav_config_file="${dav_config_folder}/webdav.json"

#DH 参数文件
dhparam_file="${ssl_folder}/dhparam.pem"
#会话凭证密钥文件
session_ticket_file="${ssl_folder}/session_ticket.key"

#nginx-webdav配置文件
nginx_webdav_conf="${nginx_folder}/conf/webdav_nginx.conf"

#jq解析器
jq_file="${jq_folder}/jq"

#nginx_webdav日志文件
nginx_webdav_log_file="${nginx_folder}/logs/webdav.access.log"

#安装webdav-nginx的记录日志
webdav_nginx_install_log=${base_folder}/webdav-nginx-install.log



#参数
#仓库
nginx_webdav_download="https://gitee.com/wan-wu-qi-yi/nginx_and_webdav_module.git"

# jq
jq_down_link="https://gitee.com/wan-wu-qi-yi/jq.git"


# 默认nginx端口
default_http_nginx_port=80
default_https_nginx_port=443



#默认登录用户名和密码
default_webdav_user="default"
default_webdav_pwd="default.passwd"
#默认随机密码长度
default_random_pwd_length=16


# 信息和颜色等
Info="${Green_font_prefix}[信息]${Font_color_suffix}"

Error="${Red_font_prefix}[错误]${Font_color_suffix}"

Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

# 绿色字体
Green_font_prefix="\033[32m"
# 红色字体
Red_font_prefix="\033[31m"

Font_color_suffix="\033[0m"

# 背景颜色
Green_background_prefix="\033[42;37m"

Red_background_prefix="\033[41;37m"

full_line="————————————————————————————————————————————"

