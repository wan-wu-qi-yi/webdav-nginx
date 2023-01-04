#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH




# echo -e "来自webdav.sh的CommonName=${CommonName}"

# Getting configuration information of webdav 
function get_webdav_config(){
	echo -e "${Info} ${full_line}读取WebDAV配置信息中...${full_line}" && echo
	
	if [[ ! -e ${jq_file} ]]; then
		install_jq
	fi

	#get config info
	CommonName_from_jq=$(${jq_file} '.CommonName' ${webdav_config_file} | sed 's/^.//;s/.$//')
	http_nginx_port_from_jq=$(${jq_file} '.http_nginx_port' ${webdav_config_file} | sed 's/^.//;s/.$//')
	https_nginx_port_from_jq=$(${jq_file} '.https_nginx_port' ${webdav_config_file} | sed 's/^.//;s/.$//')
	
	webdav_user_from_jq=$(${jq_file} '.webdav_user' ${webdav_config_file} | sed 's/^.//;s/.$//')
	webdav_pwd_from_jq=$(${jq_file} '.webdav_pwd' ${webdav_config_file} | sed 's/^.//;s/.$//')
	
	echo -e "${Info} ${full_line}读取WebDAV配置信息 END${full_line}" && echo
}


# setting password of webdav
function set_webdav_passwd(){
	
		echo "请输入要设置的webdav密码："
		read -e -p "(默认: ${default_webdav_pwd} ):" webdav_pwd
		
		if [[ -z "${webdav_pwd}" ]]; then
			webdav_pwd=${default_webdav_pwd}
			break
		fi
		
		
		#第一个和最后一个echo是输出空行 ，第二个和第四个echo是输出横线
		echo && echo ${full_line} && echo -e "密码 : ${Green_font_prefix}${webdav_pwd}${Font_color_suffix}" && echo ${full_line} && echo
		

}


# set CommonName of webdav
function set_webdav_CommonName(){
	
	# 下载wget
	yum install -y wget
	
	
	while true
	do
		echo -e "${Tip}"
		echo -e "1.为当前服务器公网IP生成自签名证书"
		echo -e "2.为指定域名生成自签名证书"
		echo -e "3. 手动输入公网IP地址（当自动获取公网IP地址失败时选择此项）"
		read -e -p "输入对应选项数字(默认是为公网IP生成自签名证书)：" ip_or_domain
		
		# 默认或者输入1：公网IP方式
		if [[ -z ${ip_or_domain} ]] || [[ ${ip_or_domain} -eq "1" ]]; then
			# 获取公网IP
			CommonName=`wget -qO- -t1 -T2 ipinfo.io/ip`
			break
		fi
		
		
		# 输入2：域名方式
		if [[ ${ip_or_domain} -eq "2" ]]; then
			while true
			do
				read -e -p "输入你的域名：" CommonName
				echo -e "是否确定你的域名(选择否可重输你的域名)? [y/n]" && echo
				read -e -p "(默认: n):" unyn
				[[ -z ${unyn} ]] && unyn="n"
				if [[ ${unyn} == [Yy] ]]; then
					break
				else
					echo && echo -e "再次输入你的域名" && echo
				fi
				
			done
			
			break
		fi
		
		
		# 输入3：手动输入公网IP地址
		if [[ ${ip_or_domain} -eq "3" ]]; then
			while true
			do
				read -e -p "输入你的公网IP：" CommonName
				echo -e "是否确定你的域名(选择否可重输你的域名)? [y/n]" && echo
				read -e -p "(默认: n):" unyn_ip
				[[ -z ${unyn_ip} ]] && unyn_ip="n"
				if [[ ${unyn_ip} == [Yy] ]]; then
					break
				else
					echo && echo -e "再次输入公网IP" && echo
				fi
				
			done
			
			break
		
		
		fi
		
		
		
		#其他输入
		if [[ ${ip_or_domain} -ne "1" ]] && [[ ${ip_or_domain} -ne "2" ]] && [[ ${ip_or_domain} -ne "3" ]] ; then
			echo -e "${Error}请输入正确数字！"
		fi
		
	done
}



# modifing password of webdav 
function modify_webdav_passwd(){
	# 首先需要先获取配置信息
	get_webdav_config
	
	# 重新设置并替换配置文件中的对应配置信息
	set_webdav_passwd
	# echo "sed -i 's/"webdav_pwd": "'"$(echo ${webdav_pwd_from_jq})"'"/"webdav_pwd": "'"$(echo ${webdav_passwd})"'"/g' ${webdav_config_file}"
	sed -i 's/"webdav_pwd": "'"$(echo ${webdav_pwd_from_jq})"'"/"webdav_pwd": "'"$(echo ${webdav_pwd})"'"/g' ${webdav_config_file}
	
	
	
	# 更新登录认证的密码文件
	webdav_user=${webdav_user_from_jq}
	generate_davpasswd_file
}




# modifing CommonName of webdav
function modify_webdav_CommonName(){
	# 首先需要先获取配置信息
	get_webdav_config
	
	# 重新设置并替换配置文件中的对应配置信息
	set_webdav_CommonName
	sed -i 's/"CommonName": "'"$(echo ${CommonName_from_jq})"'"/"CommonName": "'"$(echo ${CommonName})"'"/g' ${webdav_config_file}
}



# modifying webdav config 
function modify_webdav_config(){
	# 首先需要先获取配置信息
	get_webdav_config
	
	# 暂时只提供修改密码
	modify_webdav_passwd

}

# 7.写入WebDAV配置信息
function write_webdav_config(){
echo -e "${Info} ${full_line}写入WebDAV配置信息 start... ${full_line}" && echo

	cat >${webdav_config_file} <<-EOF
{
"CommonName": "${CommonName}",
"http_nginx_port": "${http_nginx_port}",
"https_nginx_port": "${https_nginx_port}",
"webdav_user": "${webdav_user}",
"webdav_pwd": "${webdav_pwd}",
"other": "other"
}
	EOF
	[[ ! -e $webdav_config_file ]] && echo -e "${Error}：配置信息写入失败" && break
	echo -e "${Info} ${full_line}写入WebDAV配置信息 END ${full_line}" && echo
}


#11.显示WebDAV配置信息
function display_webdav_config (){
	get_webdav_config

	#ouput config info
	if [[ ${https_nginx_port} -eq 443 ]]; then
		echo && echo "==================================================="
		echo -e " WebDAV配置信息：" && echo
		echo -e " WebDAV URL\t    : ${Green_font_prefix}https://${CommonName_from_jq}/dav${Font_color_suffix}"
		echo -e " WebDAV用户名\t    : ${Green_font_prefix}${webdav_user_from_jq}${Font_color_suffix}"
		echo -e " WebDAV密码\t    : ${Green_font_prefix}${webdav_pwd_from_jq}${Font_color_suffix}" && echo

		echo && echo "==================================================="
	else
		echo && echo "==================================================="
		echo -e " WebDAV配置信息：" && echo
		echo -e " WebDAV URL\t    : ${Green_font_prefix}https://${CommonName_from_jq}:${https_nginx_port_from_jq}/dav${Font_color_suffix}"
		echo -e " WebDAV用户名\t    : ${Green_font_prefix}${webdav_user_from_jq}${Font_color_suffix}"
		echo -e " WebDAV密码\t    : ${Green_font_prefix}${webdav_pwd_from_jq}${Font_color_suffix}" && echo

		echo && echo "==================================================="
	fi
	
	
}




