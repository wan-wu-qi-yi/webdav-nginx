#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH



# generate cert of public ip
function generate_self_cert_with_IP(){
	echo -e "${Info} ${full_line} 生成公网IP的自签名证书 start...${full_line}" && echo
	while true
	#公网IP
	CommonName=`wget -qO- -t1 -T2 ipinfo.io/ip`
	echo -e "公网IP：${CommonName}"
	do
		if [[ -z ${CommonName} ]]; then
			echo "${Green_font_prefix}${Tip}：获取服务器公网IP失败，请手动输入IP：{Font_color_suffix}" CommonName
		else
			break
		fi
	done
	#生成自签名证书
	./mkcert -key-file ${nginx_key} -cert-file ${nginx_cert} -client  ${CommonName}
	echo -e "${Info} ${full_line} 生成公网IP的自签名证书 END ${full_line}" && echo
}

# generate cert of domain
function generate_self_cert_with_domain (){
	echo -e "${Info} ${full_line} 生成域名自签名证书 start...${full_line}" && echo
	
	# while true
	# do
		# read -e -p "输入你的域名：" CommonName
		# echo -e "是否确定你的域名(选择否可重输你的域名)? [y/n]" && echo
		# read -e -p "(默认: n):" unyn
		# [[ -z ${unyn} ]] && unyn="n"
		# if [[ ${unyn} == [Yy] ]]; then
			# break
		# else
			# echo && echo -e "再次输入你的域名" && echo
		# fi
		
	# done
	
	#生成自签名证书
	./mkcert -key-file ${nginx_key} -cert-file ${nginx_cert} -client  ${CommonName}
	
	echo -e "${Info} ${full_line} 生成域名自签名证书 END ${full_line}" && echo
}



# 1.生成自签名证书
function generate_self_cert(){

	# echo -e "webdav_nginx_install_log=${webdav_nginx_install_log} nginx_and_webdav_module_folder=${nginx_and_webdav_module_folder}"
	
	echo -e "${Info} ${full_line} 生成自签名证书 start...${full_line}" && echo
	
	
	if [[ -e "/root/.local/share/mkcert/rootCA.pem" ]]; then
		
		cd /root/.local/share/mkcert/
		
		# 备份之前的证书
		mv rootCA.pem /root/rootCA.pem.bak
		
		rm -rf /root/.local/share/mkcert/*
		
		
	fi
	
	
	cd $nginx_and_webdav_module_folder
	
	if [[ -e "mkcert-v1.4.3-linux-amd64"  ]]; then
		mv mkcert-v1.4.3-linux-amd64 mkcert && chmod +x mkcert
	fi
	
	
	# 默认或者输入1：公网IP方式
	if [[ -z ${ip_or_domain} ]] || [[ ${ip_or_domain} == "1" ]]; then
	
		# 根据公网IP生成证书 break?
		# generate_self_cert_with_IP && break
		generate_self_cert_with_IP
	
	# 输入2：域名方式
	elif [[ ${ip_or_domain} == "2" ]]; then
	
		# 根据域名生成IP  break?
		# generate_self_cert_with_domain && break
		generate_self_cert_with_domain
	else
		# 系统异常，退出
		echo -e "${Error} 系统异常！，变量 ip_or_domain 异常：ip_or_domain=${ip_or_domain}" & exit
	fi
	
	echo -e "${Info} ${full_line} 生成自签名证书 END...${full_line}" && echo
}


#12.下载根证书
function download_root_cert(){

	cd /root/.local/share/mkcert
	yum -y install lrzsz
	sz rootCA.pem
}




