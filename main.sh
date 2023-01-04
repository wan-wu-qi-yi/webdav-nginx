#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


# 引入shell
source /usr/local/webdav-nginx/config/config.sh
source /usr/local/webdav-nginx/certificate/generateCert.sh
source /usr/local/webdav-nginx/passwd/generatePasswd.sh
source /usr/local/webdav-nginx/nginx/WebdavNginx.sh
source /usr/local/webdav-nginx/webdav/webdav.sh
source /usr/local/webdav-nginx/linux/linux.sh
source /usr/local/webdav-nginx/linux/centos.sh





#检查用户是否拥有root权限
function check_root(){
	[[ $EUID != 0 ]] && echo -e " ${Error} ${Red_font_prefix}当前账号非ROOT(或没有ROOT权限)，无法继续操作{Font_color_suffix} 请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
	
}




# 脚本管理
function my_start() {
	echo -e "管理脚本 ${Green_background_prefix}[v2.0]${Font_color_suffix}
———————————————————————————————webdav-nginx安装卸载—————————————————————————————————	
  ${Green_font_prefix}1.${Font_color_suffix} 安装webdav-nginx并启动
  ${Green_font_prefix}2.${Font_color_suffix} 卸载webdav-nginx

———————————————————————————————webdav-nginx启动相关—————————————————————————————————	
  ${Green_font_prefix}3.${Font_color_suffix} 开启webdav-nginx
  ${Green_font_prefix}4.${Font_color_suffix} 关闭webdav-nginx
  ${Green_font_prefix}5.${Font_color_suffix} 重启webdav-nginx
  
———————————————————————————————webdav配置相关————————————————————————————————— 
  ${Green_font_prefix}6.${Font_color_suffix} 修改webdav-nginx的密码
  ${Green_font_prefix}7.${Font_color_suffix} 查看webdav-nginx配置信息
  ${Green_font_prefix}8.${Font_color_suffix} 下载根证书文件
  ${Green_font_prefix}9.${Font_color_suffix} 重新生成根证书文件
  
———————————————————————————————webdav日志—————————————————————————————————  
  ${Green_font_prefix}10.${Font_color_suffix} 查看webdav-nginx日志
  
———————————————————————————————其它—————————————————————————————————
  ${Green_font_prefix}11.${Font_color_suffix} 关闭防火墙
  
  
  "
	# 检测防火墙状态(linux.sh)
	check_firewall_status
	
	#检测webdav-nginx安装和启动情况(WebdavNginx.sh)
	check_nginx_install_status
	
	echo && read -e -p "请输入数字 [1-11]：" num
	case "${num}" in
	1)
		auto_install_and_start_nginx
		;;
	2)
		uninstall_nginx_and_webdav
		;;
	3)
		start_nginx && display_webdav_config
		;;
	4)
		stop_nginx
		;;
	5)
		restart_nginx && display_webdav_config
		;;
	6)
		modify_webdav_passwd
		restart_nginx && display_webdav_config
		
		;;
	7)
		display_webdav_config
		;;
	8)
		download_root_cert
		;;
		
	9)
		# 修改CommonName后，然后生成证书，并显示出配置信息
		modify_webdav_CommonName
		generate_self_cert
		restart_nginx && display_webdav_config
		download_root_cert
		;;
		
	10)
		view_webdav_nginx_log
		;;
	11)
		stop_firewall
		;;
	*)
		clear
		echo -e "${Red_font_prefix}${Error} 请输入正确的数字 [1-11]${Font_color_suffix}"
		;;
	esac
}


# 自动安装用于webdav-nginx并启动
if [[ $1 = "auto" ]]; then
	auto_install_and_start_nginx && exit
	
fi


check_root
my_start










