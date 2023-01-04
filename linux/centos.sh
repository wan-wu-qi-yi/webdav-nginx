#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH




# Checking status of firewall
function cenots_check_firewall_status() {
	if [[ ! -z $(systemctl status firewalld | grep dead) ]]; then
		echo -e " 防火墙状态：${Green_font_prefix}已关闭${Font_color_suffix}"
	elif [[ ! -z $(systemctl status firewalld | grep running) ]]; then
		echo -e " 防火墙状态：${Red_font_prefix}开启（建议关闭）${Font_color_suffix}"
	fi
}

# stopping firewall of centos
function centos_stop_firewall() {
	
	systemctl stop firewalld.service
	if [[ ! -z $(systemctl status firewalld | grep dead) ]]; then
		echo -e " ${Green_font_prefix}防火墙关闭成功！${Font_color_suffix}"
		
	else
	
		echo -e " ${Error}${Red_font_prefix}系统异常！${Font_color_suffix}"
	
	fi
	
}






