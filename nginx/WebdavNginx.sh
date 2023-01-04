#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


# 引入配置变量的shell文件
# source ../config/config.sh


#install jq
function install_jq() {
    get_linux_type
    
	yum install git -y
	cd $base_folder
	git clone ${jq_down_link}

	
	if [[ ${bit} = "x86_64" ]]; then
		mv $jq_folder/jq-linux64 ${jq_file}
	else
		mv $jq_folder/jq-linux32 ${jq_file}
	fi

	chmod +x ${jq_file}
	[[ ! -e ${jq_file} ]] && echo -e "${Error} ${Red_font_prefix}JQ解析器$({jq_file}) 剪切失败，请检查 ! ${Font_color_suffix}" && exit 1
	[[ -e ${jq_file} ]] && echo -e "${Info}${Green_font_prefix}JQ解析器剪切成功！${Font_color_suffix}"

}


# set http port of nginx 
function set_nginx_http_port(){
	
	while true
	do
		read -e -p "设置nginx监听的http协议端口(默认80端口，不要设置为443端口)" http_nginx_port
		if [[ -z ${http_nginx_port} ]]; then
			http_nginx_port=${default_http_nginx_port}
			echo &&  echo ${full_line} && echo -e "nginx监听的http端口 : ${Green_font_prefix}${http_nginx_port}${Font_color_suffix}" && echo ${full_line} && echo
			
			break
			
		else
			echo -e "设置的端口：${Green_font_prefix}${http_nginx_port}${Font_color_suffix}"
		fi
		
		#使用expr命令检查输入的值是否为整数，如果输入的不为整数，命令返回值$？不为0
		expr $http_nginx_port + 1 &>/dev/null
		if [[ $? != 0 ]]; then
			echo -e "${Error} ${Red_font_prefix}输入的不是纯数字(1-65535)${Font_color_suffix}"
			read -p "按回车键重新设置" && echo
			continue
		fi

		#判断输入的数字是否以0开头  
		if [[ `expr index  ${http_nginx_port} 0` == 1 ]];then
			echo -e "${Error} ${Red_font_prefix}不要以0开头${Font_color_suffix}"
			read -p "按回车键重新设置" && echo
			continue
		fi
		
		
		if [[ $? == 0 ]]; then
			#ge >=   le <=  判断是否在范围1-65535内
			if [[ ${http_nginx_port} -ge 1 ]] && [[ ${http_nginx_port} -le 65535 ]]; then
				
				if [[ ${http_nginx_port} -eq 443 ]]; then
					echo -e "${Error} ${Red_font_prefix}http端口不要设置为443${Font_color_suffix}"
					continue
				else
					echo && echo ${full_line} && echo -e "nginx监听的http端口 : ${Green_font_prefix}${http_nginx_port}${Font_color_suffix}" && echo ${full_line} && echo
					break
				fi
			else
				echo -e "${Error} ${Red_font_prefix}输入的数字不在范围内(1-65535)${Font_color_suffix}"
				read -p "按回车键重新设置" && echo
			fi
		
		else
			echo -e "${Error} ${Red_font_prefix} 执行 set_nginx_port 系统异常！${Font_color_suffix}" & break
		fi
	done
}


# set https port of nginx 
function set_nginx_https_port(){
	while true
	do
		read -e -p "设置nginx监听的https是协议端口(默认443端口，不要设置为80端口)" https_nginx_port
		if [[ -z ${https_nginx_port} ]]; then
			https_nginx_port=${default_https_nginx_port}
			echo &&  echo -e "nginx监听的https端口 : ${Green_font_prefix}${https_nginx_port}${Font_color_suffix}" && echo ${full_line} && echo
			
			break
			
		else
			echo -e "设置的端口：${Green_font_prefix}${https_nginx_port}${Font_color_suffix}"
		fi
		
		#使用expr命令检查输入的值是否为整数，如果输入的不为整数，命令返回值$？不为0
		expr $https_nginx_port + 1 &>/dev/null
		if [[ $? != 0 ]]; then
			echo -e "${Error} ${Red_font_prefix}输入的不是纯数字(1-65535)${Font_color_suffix}"
			read -p "按回车键重新设置" && echo
			continue
		fi

		#判断输入的数字是否以0开头  
		if [[ `expr index  ${https_nginx_port} 0` == 1 ]];then
			echo -e "${Error} ${Red_font_prefix}不要以0开头${Font_color_suffix}"
			read -p "按回车键重新设置" && echo
			continue
		fi
		
		
		if [[ $? == 0 ]]; then
			#ge >=   le <=  判断是否在范围1-65535内
			if [[ ${https_nginx_port} -ge 1 ]] && [[ ${https_nginx_port} -le 65535 ]]; then
				
				if [[ ${https_nginx_port} -eq 80 ]]; then
					echo -e "${Error} ${Red_font_prefix}http端口不要设置为80${Font_color_suffix}"
					continue
				else
					echo && echo ${full_line} && echo -e "nginx监听的https端口 : ${Green_font_prefix}${https_nginx_port}${Font_color_suffix}" && echo ${full_line} && echo
					break
				fi
			else
				echo -e "${Error} ${Red_font_prefix}输入的数字不在范围内(1-65535)${Font_color_suffix}"
				read -p "按回车键重新设置" && echo
			fi
		
		else
			echo -e "${Error} ${Red_font_prefix} 执行 set_nginx_port 系统异常！${Font_color_suffix}" & break
		fi
	done

}



# 0.在一开始就设置需要的参数，方便后面自动运行
function init_param(){

	# (webdav.sh)
	set_webdav_CommonName
	
	set_nginx_http_port
	
	set_nginx_https_port
}


# 1.下载资源
function download_resources(){
	echo -e "${Info} ${full_line} 资源下载 start...${full_line}" && echo
	
	#下载nginx及其webdav扩展模块
	cd $base_folder
	yum install git -y
	git clone ${nginx_webdav_download}
	
	# 重命名
	if [[ ! -d  ${nginx_and_webdav_module_folder} ]]; then
	
		mv nginx_and_webdav_module ${nginx_and_webdav_module_folder_name}
	else 
	
		echo -e "文件夹${nginx_and_webdav_module_folder_name}已存在,不需重命名,移动文件过去即可"
		mv nginx_and_webdav_module/* ${nginx_and_webdav_module_folder_name}
		rm -rf nginx_and_webdav_module
	
	fi
	
	
	
	#下载jq
	install_jq
	echo -e "${Info} ${full_line} 资源下载 END ${full_line}"${webdav_nginx_install_log} && echo
}


# 2.生成自签名证书(见certficate/generateCert.sh  generate_self_cert)



# 3.安装nginx、dav模块、dav扩展模块等等
function install_nginx_and_webdavModule(){
	
	echo -e "${Info} ${full_line} 安装nginx、dav模块、dav扩展模块等等 start... ${full_line}"  && echo 
	
	#创建用于运行Nginx的用户（创建账号nginx，该用户无法登陆系统且没有家目录）
	useradd -M -s /sbin/nologin nginx

	#安装所需依赖包
	# (linux.sh)
	get_linux_type
	
	if [[ ${release} -eq "centos" ]]; then
		yum -y install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre pcre-devel libxslt-devel libxml2 libxml2-dev

	else
		echo -e "${full_line}${Red_font_prefix}暂未提供centos之外的linux版本的脚本，无法安装所需依赖包${Font_color_suffix}${full_line}" & exit
	fi
	
	#查看依赖是否安装成功
	rpm  -qa   make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre pcre-devel libxslt-devel libxml2 libxml2-dev


	#解压下载的资源
	echo -e "解压下载的资源start..."
	cd ${nginx_folder}
	
	tar -zxvf  ${nginx_and_webdav_module_folder}/nginx-1.18.0.tar.gz
	tar -zxvf  ${nginx_and_webdav_module_folder}/nginx-dav-ext-module-3.0.0.tar.gz
	tar -zxvf  ${nginx_and_webdav_module_folder}/headers-more-nginx-module-0.33.tar.gz
	cd nginx-1.18.0/
	
	echo -e "解压下载的资源end"

	#编译
	echo -e "编译nginx start..."
	# 指定nginx程序运行用户、用户组及安装目录、ssl
	./configure \
	--user=nginx --group=nginx --prefix=${nginx_folder} --with-http_ssl_module \
	--with-ipv6 --with-http_v2_module --with-http_dav_module \
	--add-module=${nginx_folder}/nginx-dav-ext-module-3.0.0 \
	--add-module=${nginx_folder}/headers-more-nginx-module-0.33
	#编译安装,make -j 4 会启用多个作业同时进行，比默认的make更快
	make -j 4 && make install

	#添加软链接（不用使用nginx可执行文件的全路径），方便环境变量调用
	ln -s ${nginx_folder}/sbin/nginx   /usr/local/sbin/
	
	echo -e "编译nginx end"
	
	echo -e "${Info} ${full_line} 安装nginx、dav模块、dav扩展模块等等 END ${full_line}" && echo
}


# 4.增强https安全性
function enhance_https_security(){
	echo -e "${Info} ${full_line} 增强https安全性 start...${full_line}" && echo
	#HTTPS 密钥交换算法
	#生成 DH 参数文件
	yum -y install openssl
	openssl dhparam -out ${dhparam_file} 2048

	#HTTPS 会话缓存
	##加快 HTTPS 建立连接的速度，提升性能
	#生成会话凭证密钥文件
	openssl rand 80 >${session_ticket_file}
	echo -e "${Info} ${full_line} 增强https安全性 END ${full_line}" && echo
}


# 5.设置同步目录属性
function set_sync_folder(){
	echo -e "${Info} ${full_line} 设置同步目录属性 start... ${full_line}" && echo
	
	# 所属用户和用户组
	# 设置文件所有者 如果是所有人都可以使用的话设置  nobody:nobody
	chown nginx:nginx  $sync_folder
	#权限设置
	chmod -R 700 $sync_folder
	
	echo -e "${Info} ${full_line} 设置同步目录属性 END ${full_line}" && echo
	
}


# 6.配置用于登录认证的密码文件(见passwd/generatePasswd.sh  generate_davpasswd_file)

# 7.写入WebDAV配置信息(webdav.sh)



# 8.配置nginx配置文件
function set_nginx_config_file(){
	echo -e "${Info} ${full_line} 配置nginx配置文件 start...${full_line}" && echo
	
	
	#备份nginx配置文件
	cd ${nginx_folder}/conf
	mv nginx.conf nginx.conf.bak


#注意此块内容除了EOF所在行，其余不要用Tab符，如果有，请替换为空格，否则重定向无法正确输出
cat >${nginx_webdav_conf} <<-EOF
user nginx nginx; #用户及用户组
#user  nobody;
worker_processes  1;



events {
   worker_connections  1024;
}


http {
   # 定义的日志格式 
   log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
        '\$status \$body_bytes_sent "\$http_referer" '
        '"\$http_user_agent" "\$http_x_forwarded_for"';
   
   #DAV文件锁内存共享区
   dav_ext_lock_zone zone=davlock:10m;
   
   #隐藏nginx版本号，避免被坏人利用
   server_tokens off;
   
   
   include       mime.types;
   default_type  application/octet-stream;
   
   sendfile        on;
   
   keepalive_timeout  65;
   
   #gzip  on;
   
   
   #HTTP server
   server {
      listen       ${http_nginx_port};
      server_name  localhost;
      rewrite ^(.*)\$  https://\$host\$1? permanent;    # 强制HTTP访问跳转为HTTPS访问

      #charset koi8-r;
      
      #access_log  logs/host.access.log  main;
      
      location / {
         root   html;
         index  index.html index.htm;
      }
      
      #error_page  404              /404.html;
      
      #
      error_page   500 502 503 504  /50x.html;
      location = /50x.html {
        root   html;
      }
 }


 # HTTPS server
 server {
 
  # 开启https和http2.0提升传输性能
  listen       ${https_nginx_port} ssl http2;
  
  server_name  localhost;
  
  # 日志文件路径及日志格式类型
  access_log  ${nginx_webdav_log_file}  main;
  
  # 网站证书文件
  ssl_certificate  ssl/nginx.crt;
  
  # 网站证书密钥文件
  ssl_certificate_key  ssl/nginx.key;
  
  # 网站证书密钥密码文件
  # ssl_password_file ssl/xxx;
  
  #开启对来自客户端发送的证书的验证
  #ssl_verify_client on;  # 启用客户端证书认证
  # 客户端证书信任链的CA中间证书或根证书
  #ssl_client_certificate /root/.local/share/mkcert/rootCA.pem; 
  
  
  ssl_dhparam  ssl/dhparam.pem; # DH参数文件
  ssl_ecdh_curve auto; # ECDH椭圆曲线算法为prime256v1
  
  #指定会话凭证密钥文件，用于在多台 Nginx 间实现会话凭证共享
  #否则 Nginx 会随机生成一个会话凭证密钥
  ssl_session_ticket_key  ssl/session_ticket.key;
  ssl_session_tickets on;  # 以会话凭证机制实现会话缓存
  
  # 会话缓存存储大小为10MB
  ssl_session_cache shared:SSL:10m;
  # 会话缓存超时时间为20分钟
  ssl_session_timeout  20m;    
  
  # 最大允许上传的文件大小
  client_max_body_size 20G;
  
  #设置使用的 SSL 协议
  ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  
  #设置 HTTPS 建立连接时用于协商使用的加密算法组合，也称密码套件
  #指令值内容为 openssl 的密码套件名称，多个套件名称间用“:”分隔
  ssl_ciphers  EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
  #是否启用在 SSLv3 和 TLSv1 协议的 HTTPS 连接时优先使用服务端设置的密码套件
  # ssl_prefer_server_ciphers on;
 
 
 # 启用HSTS(网站防护)
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

  add_header X-Frame-Options DENY;               # 禁止被嵌入框架
  add_header X-XSS-Protection "1; mode=block";   # XSS跨站防护
  add_header X-Content-Type-Options nosniff;     # 防止在浏览器中的MIME类型混淆攻击


  location / {
   root html;
   index index.html;
  }

  location /dav {
  
   # 数据存放目录
   alias ${sync_folder};
   
   index index.html index.htm;
   
   # 开启文件索引列表(看情况选择是否开启)
   autoindex on;
   
   #关闭情况下显示的文件时间为GMT时间，开启显示的是服务器中的时间
   autoindex_localtime on; 
    
   set \$dest \$http_destination;
    
   # 对目录请求、对URI自动添加"/"
   if (-d \$request_filename) {                   
    rewrite ^(.*[^/])\$ \$1/;
    set \$dest \$dest/;
   }
   
   #对MOVE|COPY方法强制添加Destination请求头
   if (\$request_method ~ (MOVE|COPY)) {
    more_set_input_headers 'Destination: \$dest';
   }


   if (\$request_method ~ MKCOL) {
    rewrite ^(.*[^/])\$ \$1/ break;
   }
   
   #webdav 配置
   client_body_temp_path /tmp;
   dav_methods PUT DELETE MKCOL COPY MOVE;  # DAV支持的请求方法
   dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK; # DAV扩展支持的请求方法
   dav_ext_lock zone=davlock;     # DAV扩展锁绑定的内存区域
   create_full_put_path  on;      # 启用创建目录支持
   dav_access user:rw group:rw all:r;   #设置创建的文件及目录的访问权限
  
   #auth_basic "Authorized Users WebDAV";
   auth_basic "user login";
   auth_basic_user_file  dav/.davpasswd; #身份鉴权文件
        }
    }
}
	EOF
	echo -e "${Info} ${full_line} 配置nginx配置文件 END ${full_line}" && echo
}






	

#----------------------------------webdav-nginx安装卸载 BEGIN----------------------------------

# 自动安装并启动webdav-nginx
function auto_install_and_start_nginx(){
	# 0.在一开始就设置需要的参数，方便后面自动运行(WebdavNginx.sh)
		init_param

	# echo -e "来自WebdavNginx.sh脚本的CommonName=${CommonName}"

	# 1.下载资源(WebdavNginx.sh)
		download_resources

	# 2.生成自签名证书(generateCert.sh)
		generate_self_cert

	# 3.安装nginx、dav模块、dav扩展模块等等(WebdavNginx.sh)
		install_nginx_and_webdavModule

	# 4.增强https安全性(WebdavNginx.sh)
		enhance_https_security

	# 5.设置同步目录属性(WebdavNginx.sh)
		set_sync_folder

	# 6.配置用于登录认证的密码文件(generatePasswd.sh)
		generate_random_user_and_pwd
		generate_davpasswd_file

	# 7.写入WebDAV配置信息(webdav.sh)
		write_webdav_config

	# 8.配置nginx配置文件(WebdavNginx.sh)
		set_nginx_config_file
		
	# 9.启动nginx(WebdavNginx.sh)
		start_nginx
	
	#10.关闭防火墙(linux.sh)
		stop_firewall
	
	#11.显示WebDAV配置信息(webdav.sh)
		display_webdav_config
	
	#12.下载根证书(generateCert.sh)
		download_root_cert
	
	
}


# 卸载webdav-nginx
function uninstall_nginx_and_webdav(){
	echo "确定要 卸载nginx及其webdav？[y/n]" && echo
	read -e -p "(默认: n):" uninstall_unyn
	[[ -z ${uninstall_unyn} ]] && uninstall_unyn="n"
	if [[ ${uninstall_unyn} == [Yy] ]]; then
		#关闭nginx
		# stop_nginx
		${nginx_folder}/sbin/nginx -c ${nginx_webdav_conf} -s stop

		#删除nginx安装目录
		rm -rf ${nginx_folder}
		#删除根证书文件和下载的仓库
		rm -rf /root/.local/share/mkcert/* && rm -rf ${nginx_and_webdav_module_folder}
		#删除jq解析器
		rm -rf ${jq_folder}
		
		
		#删除链接文件
		# rm -rf /usr/local/sbin/nginx
		
		echo && echo "卸载webdav-nginx完成！" && echo
		
	else
		echo && echo " 已取消卸载..." && echo
	fi
}

#----------------------------------webdav-nginx安装卸载 END----------------------------------





#----------------------------------webdav-nginx进程管理 BEGIN----------------------------------

function check_nginx_status(){
	#nginx进程号，进程号可能有多个
	nginx_pids=$(ps -ef | grep -v "grep" | grep ${nginx_folder_name} | awk '{print $2}')
	echo " nginx进程号：${nginx_pids}"
}


function start_nginx(){
	
	check_nginx_status
	
	if [[ ! -z ${nginx_pids} ]]; then
		echo -e "${Green_font_prefix}[信息]${Font_color_suffix}nginx已经启动，无需再启动" && echo
		
	else
		
		echo -e "${Info_font_prefix}[信息]${Font_color_suffix}  开启nginx中..." && echo 
		echo -e "${nginx_folder}/sbin/nginx -c ${nginx_webdav_conf}"
		${nginx_folder}/sbin/nginx -c ${nginx_webdav_conf}
		
		check_nginx_status
		if [[ -z ${nginx_pids} ]]; then
			echo -e "${Error}${Red_font_prefix}启动失败，请手动启动${Font_color_suffix}  " && echo
		else	
			echo -e "${Green_font_prefix} nginx启动成功！${Font_color_suffix} " && echo
		fi
	fi
}




function stop_nginx(){
	echo -e "${Info} ${full_line} nginx 关闭中... ${full_line}" && echo
	#方式1
	${nginx_folder}/sbin/nginx -c ${nginx_webdav_conf} -s stop
	
	#方式2
	#kill -9 $(ps -ef|grep -v grep |grep nginx |awk  '{print $2}')
	#方式3
	#xargs加-i 参数直接用 {}就能代替管道之前的标准输出的内容，这里指的是进程号
	# ps -ef |grep -v grep |grep ${nginx_folder_name} |awk  '{print $2}' |xargs -i kill -9 {}
	# check_nginx_status
	# if [[ -z ${nginx_pids} ]]; then
		# echo -e "${Tip}${Info_font_prefix}[信息]${Font_suffix}  关闭成功 "
	# else
		# kill -9 ${nginx_pids}
		# #${nginx_folder}/sbin/nginx -s stop

		# if [[ $? -eq 0 ]]; then
			# echo -e "${Tip}${Info_font_prefix}[信息]${Font_suffix}  关闭成功 !"
		# else
			# echo -e "${Error_font_prefix}[错误]${Font_suffix} 关闭失败 !"
		# fi
	# fi
	
	# 方式4： 根据端口查找对应进程，然后杀掉
	# netstat -ntlp|grep 80
}


function restart_nginx(){
	echo -e "${Info} ${full_line} nginx 重启中... ${full_line}" && echo
	check_nginx_status
	if [[ -z ${nginx_pids} ]]; then
		# 当前处于关闭状态
		start_nginx
	else
		# 当前处于开启状态
		stop_nginx && start_nginx
	fi
	
}
#----------------------------------webdav-nginx进程管理 END----------------------------------


#查看webdav-nginx日志
function view_webdav_nginx_log(){
	# view log
	tail -f $nginx_webdav_log_file
}


#检测webdav-nginx安装和启动情况
function check_nginx_install_status(){
	if [[ ! -d "${nginx_folder}/sbin" ]]; then
		echo -e " webdav-nginx状态：${Red_font_prefix} 未安装 ${Font_color_suffix}"
	
	else
		check_nginx_status
		if [[ -z ${nginx_pids} ]]; then
			echo -e " webdav-nginx状态： 已安装但${Red_font_prefix}未启动 ${Font_color_suffix}"
		else
			echo -e " webdav-nginx状态： ${Green_font_prefix}已经启动 ${Font_color_suffix}"
		fi
	fi
	
}