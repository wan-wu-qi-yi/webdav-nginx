#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


#get linux type
function get_linux_type() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"

	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	else
		# 未知的linux版本
		release="unknown"
	fi

	bit=$(uname -m)
	echo -e " ${Green_background_prefix}当前Linux版本:${release}${Font_color_suffix}"
	echo -e " ${Green_background_prefix}系统类型：${bit}${Font_color_suffix}"
}


# stop firewall
function stop_firewall() {
	
	get_linux_type
	
	echo -e "release=${release}"
	
	echo -e "${Info} ${full_line} 关闭防火墙 start ${full_line}" && echo
	
	if [[ ${release} = "centos" ]]; then
		centos_stop_firewall
	fi
	
	if [[ ${release} = "unknown" ]]; then
		echo -e "${Error}${Red_font_prefix}未知的linux版本，请手动关闭防火墙！${Font_color_suffix}" && echo
	fi
	
	echo -e "${Info} ${full_line} 关闭防火墙 END ${full_line}" && echo
	

}


# cheking status of  firewall 
function check_firewall_status() {
	if [[ ${release} = "centos" ]]; then
		cenots_check_firewall_status
	fi

	
}

