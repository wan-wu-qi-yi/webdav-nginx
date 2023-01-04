#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 引入配置变量的shell文件
# source ../config/config.sh


#----------------------------------------随机字符串生成 BEGIN----------------------------------------

# Lowercase character
lowStr="abcdefghijklmnopqrstuvwxyz"

# upperStr character
upperStr="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# special character
specialStr="~!@#$%()_+-[]"

# number
numStr="0123456789"

# 随机获取字符串字符
function getRandomChar() {
    local string=$1
    # echo 字符串：$string

    getStrLength $string
    local strLength=$?
    # echo 字符串长度：$strLength

    generateRand $strLength

    index=$(($random_number - 1))
    # echo "index=$index"
    randowm_char=${string:($index):1}
    # echo 随机的字符：$randowm_char
}

#----------------------------------------字符随机生成函数BEGIN----------------------------------------
# 随机获取字符串小写字符
function getRandLowChar() {
    getRandomChar $lowStr
    # echo -e "小写字符：$randowm_char"
}

#随机获取字符串大写字符
getRandUpperChar() {
    getRandomChar $upperStr
    # echo -e "大写字符：$randowm_char"
}

#随机获取数字字符
getRandNum() {
    getRandomChar $numStr
    # echo -e "数字：$randowm_char"
}

#随机获取特殊字符
getRandSpecialChar() {
    getRandomChar $specialStr
    # echo -e "特殊字符：$randowm_char"
}
#----------------------------------------字符随机生成函数END----------------------------------------

# 获取字符串长度
function getStrLength() {
    return $(expr length $1)
}

# 随机生成1~指定数这个范围的数字
generateRand() {
    randomRange 1 $1
}

# 生成指定范围的数字(min,max)
randomRange() {
    min=$1
    max=$(($2 - $min + 1))
    #时间戳（精确到纳秒）
    # num=$(date +%s%N)
    #系统随机值
    num=$RANDOM
    random_number=$(($num % $max + $min))
    # echo 随机数=$random_number

}

#遍历数组
foreach_arr() {
    # echo -e "数组遍历"
    for item in "${arr_str[@]}"; do
        echo "${item}"
    done

}

#随机调用其中一个的字符随机生成函数
randomInvoke() {
    case "$1" in
    1)
        getRandLowChar
        ;;
    2)
        getRandUpperChar
        ;;
    3)
        getRandNum
        ;;
    *)
        getRandSpecialChar
        ;;
    esac

}

#打乱排序：循环随机位交换法
#原理：
# 循环遍历该数组，在每次遍历中产生一个0 ~ length - 1的数，该数代表本次循环要随机交换的位置。
# 将本次循环当前位置的数和随机位置的数进行交换
random_sort() {
    length=${#arr_str[*]}
    for ((i = 0; i < $length; i++)); do
        generateRand $length
        randomIndex=$(($random_number - 1))

        currentelementValue=${arr_str[i]}
        # echo "currentelementValue $currentelementValue"
        arr_str[i]=${arr_str[${randomIndex}]}
        arr_str[${randomIndex}]=${currentelementValue}
    done
}

#数组转字符串
arrayToString() {
    # echo -e "传来的参数：" $@
    new_arr=($@)
    randomPwd=''
    for i in ${new_arr[@]}; do
        randomPwd=$randomPwd$i
    done

}

#生成随机密码(参数1：指定密码长度)
getRandomPwd() {
    while true; do
        #判断密码长度
        if [ $1 -ge 8 ] && [ $1 -le 20 ]; then
            echo -e "你设置的密码长度为：$1"
            break
        else
            echo -e "密码长度需要在8~20位！" && exit
        fi
    done

    pwd_length=$1

    #定义空数组
    arr_str=()

    #先把 4 种字符每种来一个，并添加到数组中
    getRandLowChar
    # echo -e "数组长度：${#arr_str[*]}"

    arr_str[${#arr_str[*]}]=g

    getRandUpperChar
    arr_str[${#arr_str[*]}]=$randowm_char

    getRandNum
    arr_str[${#arr_str[*]}]=$randowm_char

    getRandSpecialChar
    arr_str[${#arr_str[*]}]=$randowm_char

    # echo -e "第1次打印数组"
    echo ${arr_str[*]}
    # echo -e "第1次遍历数组"
    foreach_arr

    # 因为已经把 4 种字符放进数组了，所以 i 取值从 4开始
    for ((i = 4; i < ${pwd_length}; i++)); do
        generateRand 4
        randomInvoke $random_number
        arr_str[${#arr_str[*]}]=$randowm_char
    done

    # echo -e "第2次打印数组"
    echo ${arr_str[@]}
    # echo -e "第2次遍历数组"
    foreach_arr

    #打乱排序
    random_sort
    # echo -e "打乱排序后：" && echo ${arr_str[*]}

    #将数组转字符串
    arrayToString ${arr_str[@]}

    echo -e "随机密码 $randomPwd"
}
#----------------------------------------随机字符串生成END----------------------------------------


# 生成随机用户名和密码
function generate_random_user_and_pwd(){

	yum -y install openssl
	#随机用户名
	webdav_user=$(openssl rand -hex 3)
	#默认长度的随机密码
	getRandomPwd ${default_random_pwd_length}
	webdav_pwd=$randomPwd
	
}
	
# 6.配置用于登录认证的密码文件
function generate_davpasswd_file(){
	echo -e "${Info} ${full_line} 配置用于登录认证的密码文件 start... ${full_line}" && echo
	
	yum -y install openssl
	
	if [[ -e ${davpasswd_file} ]]; then
		# cd ${dav_config_folder}
		# 备份之前的密码文件
		mv ${davpasswd_file} ${davpasswd_file}.bak
	fi
	
	# 生成密码文件
	echo "${webdav_user}:$(openssl passwd  ${webdav_pwd})" >${davpasswd_file}
	
	#密码文件权限配置
	chown nginx:nginx   ${davpasswd_file}
	chmod 600           ${davpasswd_file}
	
	echo -e "WebDAV用户名：${webdav_user}"
	echo -e "WebDAV密码：${webdav_pwd}"
	
	echo -e "${Info} ${full_line} 配置用于登录认证的密码文件 END	${full_line}" && echo
}




