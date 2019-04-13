#!/bin/sh
DOWNURL="https://blog.tysv.top/mush"
OSV="UNKNOWN"
database="UNCHOOSE"
mysqlpassword="MySQLPassWord1234"
mudpassword="UNSET"
yijian="fuck"
mudir="/home/minecraft/multicraft"
nowdir="/root"
muver="0"
MC_KEY="unset"
function repl {
    LINE="$SETTING = `echo $1 | sed "s/['\\&,]/\\\\&/g"`"
}

function realinstallmu(){
cd /tmp/multicraft
	MC_JAVA="`which java`"
MC_ZIP="`which zip`"
MC_UNZIP="`which unzip`"
	MC_USERADD="`which useradd`"
    MC_GROUPADD="`which groupadd`"
    MC_USERDEL="`which userdel`"
    MC_GROUPDEL="`which groupdel`"
	MC_USER="minecraft"
	MC_DIR=$mudir
	MC_DB_TYPE=$database
	MC_DB_PASS=$mysqlpassword
	MC_WEB_USER="apache"
	MC_DAEMON_PW=$mudpassword
	INSTALL="bin/ jar/ launcher/ scripts/ templates/ eula.txt multicraft.conf.dist default_server.conf.dist server_configs.conf.dist"

	if [ -e "$MC_DIR/bin/multicraft" ]; then
    echo "正在关闭运行中的Daemon"
    "$MC_DIR/bin/multicraft" stop
    "$MC_DIR/bin/multicraft" stop_ftp
    echo "完成."
    sleep 1
fi
	echo
    echo "正在创建用户: '$MC_USER'"
    "$MC_GROUPADD" minecraft
    if [ ! "$?" = "0" ]; then
        echo "错误: 不能创建用户组 '$MC_USER'! 请创建后重新运行脚本"
    fi

    "$MC_USERADD" "$MC_USER" -g "$MC_USER" -s /bin/false
    if [ ! "$?" = "0" ]; then
        echo "错误: 不能创建用户 '$MC_USER'! 请手动创建此用户然后重新安装"
    fi


echo
echo "创建目录 '$MC_DIR'"
mkdir -p "$MC_DIR"

echo
echo "确保该目录可以被'$MC_DIR'读取并修改"
MC_HOME="`grep "^$MC_USER:" /etc/passwd | awk -F":" '{print $6}'`"
mkdir -p "$MC_HOME"
chown "$MC_USER":"$MC_USER" "$MC_HOME"
chmod u+rwx "$MC_HOME"
chmod go+x "$MC_HOME"

echo
if [ -e "$MC_DIR/bin" -a "$( cd "bin/" && pwd )" != "$( cd "$MC_DIR/bin" 2>/dev/null && pwd )" ]; then
    mv "$MC_DIR/bin" "$MC_DIR/bin.bak"
fi
for i in $INSTALL; do
    echo "安装 '$i' 到 '$MC_DIR/$i'"
    cp -a "$i" "$MC_DIR/"
done
echo "删除不必要的文件......"
rm -f "$MC_DIR/bin/_weakref.so"
rm -f "$MC_DIR/bin/collections.so"
rm -f "$MC_DIR/bin/libpython2.5.so.1.0"
rm -f "$MC_DIR/bin/"*-py2.5*.egg

if [ "$MC_KEY" != "" ]; then
	MC_KEY="no"
fi

if [ "$MC_KEY" != "unset" ]; then
	MC_KEY="no"
fi

if [ "$MC_KEY" != "n" ]; then
	MC_KEY="no"
fi

if [ "$MC_KEY" != "no" ]; then
    echo
    echo "安装Multicraft密钥"
    echo "$MC_KEY" > "$MC_DIR/multicraft.key"
fi


### Generate config

echo
CFG="$MC_DIR/multicraft.conf"
if [ -e "$CFG" ]; then
	echo "配置文件已经存在!默认替换!"
fi

if [ "$database" = "mysql" ]; then
    DB_STR="mysql:host=127.0.0.1;dbname=multicraft_daemon"
fi

function repl {
    LINE="$SETTING = `echo $1 | sed "s/['\\&,]/\\\\&/g"`"
}
if [ ! -e "$CFG" ]; then

    if [ -e "$CFG" ]; then
        echo "Multicraft.conf 已经存在,正在备份..."
        cp -a "$CFG" "$CFG.bak"
    fi

    echo "创建 'multicraft.conf'"
    > "$CFG"
ip=`curl -L http://www.multicraft.org/ip`
    SECTION=""
    cat "$CFG.dist" | while IFS="" read -r LINE
    do
        if [ "`echo $LINE | grep "^ *\[\w\+\] *$"`" ]; then
            SECTION="$LINE"
            SETTING=""
        else
            SETTING="`echo $LINE | sed -n 's/^ *\#\? *\([^ ]\+\) *=.*/\1/p'`"
        fi
        case "$SECTION" in
        "[multicraft]")
            case "$SETTING" in
            "user")         repl "minecraft" ;;
            "ip")           if [ "$MC_LOCAL" != "y" ]; then repl "0.0.0.0";       fi ;;
            "port")         if [ "$MC_LOCAL" != "y" ]; then repl "25465";     fi ;;
            "password")     repl "$MC_DAEMON_PW" ;;
            "id")           repl "1" ;;
            "database")     if [ "$MC_DB_TYPE" = "mysql" ]; then repl "$DB_STR";        fi ;;
            "dbUser")       if [ "$MC_DB_TYPE" = "mysql" ]; then repl "root";    fi ;;
            "dbPassword")   if [ "$MC_DB_TYPE" = "mysql" ]; then repl "$MC_DB_PASS";    fi ;;
            "webUser")      if [ "$MC_DB_TYPE" = "mysql" ]; then repl "";               else repl "$MC_WEB_USER"; fi ;;
            "baseDir")      repl "$MC_DIR" ;;
            esac
        ;;
        "[ftp]")
            case "$SETTING" in
            "enabled")          if [ "aaa" = "aaa" ]; then repl "true";    else repl "false"; fi ;;
            "ftpIp")            repl "0.0.0.0" ;;
			"ftpExternalIp")    if [ ! "$ip" = "" ]; then repl "$ip"; fi ;;
            "ftpPort")          repl "$MC_FTP_PORT" ;;
            "forbiddenFiles")   if [ "a" = "ymmm" ]; then repl "";           fi ;;
            esac
        ;;
        "[minecraft]")
            case "$SETTING" in
            "java") repl "$MC_JAVA" ;;
            esac
        ;;
        "[system]")
            case "$SETTING" in
            "unpackCmd")    repl "$MC_UNZIP"' -quo "{FILE}"' ;;
            "packCmd")      repl "$MC_ZIP"' -qr "{FILE}" .' ;;
            esac
            if [ "y" = "y" ]; then
                case "$SETTING" in
                "multiuser")    repl "true" ;;
                "addUser")      repl "$MC_USERADD"' -c "Multicraft Server {ID}" -d "{DIR}" -g "{GROUP}" -s /bin/false "{USER}"' ;;
                "addGroup")     repl "$MC_GROUPADD"' "{GROUP}"' ;;
                "delUser")      repl "$MC_USERDEL"' "{USER}"' ;;
                "delGroup")     repl "$MC_GROUPDEL"' "{GROUP}"' ;;
                esac
            fi
        ;;
        "[backup]")
            case "$SETTING" in
            "command")  repl "$MC_ZIP"' -qr "{WORLD}-tmp.zip" . -i "{WORLD}"*/*' ;;
            esac
        ;;
        esac
        echo "$LINE" >> "$CFG"
    done
fi

echo
echo "设置 '$MC_DIR' 的主人为 '$MC_USER'"
chown "$MC_USER":"$MC_USER" "$MC_DIR"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/bin"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/launcher"
chmod 555 "$MC_DIR/launcher/launcher"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/jar"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/scripts"
chmod 555 "$MC_DIR/scripts/getquota.sh"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/templates"
chown "$MC_USER":"$MC_USER" "$MC_DIR/default_server.conf.dist"
chown "$MC_USER":"$MC_USER" "$MC_DIR/server_configs.conf.dist"

echo "设置特殊的权限"

    chown 0:"$MC_USER" "$MC_DIR/bin/useragent"
    chmod 4550 "$MC_DIR/bin/useragent"

chmod 755 "$MC_DIR/jar/"*.jar 2> /dev/null

### Install PHP frontend
MC_WEB_DIR="/var/www/html"
if [ "y" = "y" ]; then
    echo

    if [ -e "$MC_WEB_DIR" -a -e "$MC_WEB_DIR/protected/data/data.db" ]; then
        echo "网页面板文件存在,正在备份 protected/data/data.db"
        cp -a "$MC_WEB_DIR/protected/data/data.db" "$MC_WEB_DIR/protected/data/data.db.bak"
    fi

    echo "创建目录 '$MC_WEB_DIR'"
    mkdir -p "$MC_WEB_DIR"

    echo "安装网页面板 'panel/' to '$MC_WEB_DIR'"
    cp -a panel/* "$MC_WEB_DIR"
    cp -a panel/.ht* "$MC_WEB_DIR"


    echo "设置 '$MC_WEB_DIR' 的主人为 '$MC_WEB_USER'"
    chown -R "$MC_WEB_USER":"$MC_WEB_USER" "$MC_WEB_DIR"
    echo "设置权限给 '$MC_WEB_DIR'"
    chmod -R o-rwx "$MC_WEB_DIR"

else
    ### PHP frontend not on local machine
    echo
    echo "* NOTE: 网页面板不会安装到这台机子"
fi

echo "尝试运行来设置权限"
"$MC_DIR/bin/multicraft" set_permissions

}

function installtools()
{
if [ "$OSV" == "C7" ]; then
	echo "您的系统是CentOS 7,正在升级组件"
	sleep 3
	yum -y update
	echo "升级成功!正在安装必要组件!"
	sleep 3
	echo "正在卸载MySQL以防止不必要的错误!"
	yum -y remove mari*
	rm -rf /var/lib/mysql/*
	sleep 3
	yum -y install java-1.8.0-openjdk vim unzip zip wget gcc gcc-c++ kernel-devel mariadb mariadb-server httpd php nano php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc PHP sed httpd-manual mod_ssl mod_perl mod_auth_mysql
	if [ "$database" == "mysql" ]; then
        installmysql
	fi
	echo "All Done!"
elif [ "$OSV" == "C6" ]; then
	echo "您的系统是CentOS 6,正在升级组件"
	sleep 3 
	yum -y update
	echo "升级成功!正在安装必要组件!"
	sleep 3
	echo "正在卸载MySQL以防止不必要的错误!"
	yum -y remove mysql mysql-server
	sleep 3
	yum -y install java-1.8.0-openjdk unzip zip wget gcc gcc-c++ kernel-devel mysql mysql-server httpd php nano php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc PHP sed httpd-manual mod_ssl mod_perl mod_auth_mysql
	if [ "$database" == "mysql" ]; then
        installmysql
	fi
	echo "All Done!"
else
	echo "对不起,作者的这个脚本只支持CentOS 6 或 CentOS 7"
	realver=`cat /etc/redhat-release`
	echo "你的系统为 $realver ,如果实在想要安装的话联系作者Q 1136772134"
	sleep 10
	exit 1
fi
service iptables stop
setenforce 0
service httpd start
}

function askallthing()
{
	clear
	read -p "请选择要安装的Multicraft版本:
	[0] => Multicraft官网最新版
	[1] => Multicraft 2.1.0-pre5
	[2] => Multicraft 2.1.1
	[3] => Multicraft 2.2.0
	[4] => Multicraft 2.2.1
	[5] => Multicraft 2.3.0
	请输入选项(数字): " muver
	read -p "请选择要安装的数据库,请按照格式(mysql/sqlite): " database
	if [ "$database" == "mysql" ]; then
        echo "您选择了MySQL数据库!"
		echo "请输入您想设置的MySQL密码"
		read -p "作者保证不会泄露您的密码: " mysqlpassword
		echo "您的密码设置为: $mysqlpassword 为您暂停十秒确定和记忆"
		sleep 10
	fi
	read -p "请输入您要设置的Multicraft Daemon密码:" mudpassword
	read -p "请输入Multicraft安装目录:" mudir
	read -p "请输入Multicraft许可证密钥(没有输入n):" mukey
	read -p "是否使用一键配置(y/n):" yijian
	echo "正在自动安装……如果不出意外的话,应该不会有问题吧......"
	echo "倒计时5秒 随时按 Ctrl+c 退出脚本"
	sleep 1
	echo "倒计时4秒 最好不要离开,免得出错后来不及处理"
	sleep 1
	echo "倒计时3秒 感谢Frank大佬提供某些资源!"
	sleep 1
	echo "倒计时2秒 作者Kengwang,禁止盗版,此脚本只是为了方便,不可能完美支持"
	sleep 1
	echo "倒计时1秒 作者QQ 1136772134"
	sleep 1
	echo "正在载入……"

}

function installmysql()
{

if [ "$database"=="mysql" ]; then
	if [ "$OSV" == "C7" ]; then
		service mariadb start
	elif [ "$OSV" == "C6" ]; then
		service mysqld start
	else
		echo "MySQL开启指令可能无法执行,正在尝试执行"
		service mysqld start
		service mariadb start
	fi
sleep 7 
echo "正在尝试修改密码"
mysqladmin -uroot password $mysqlpassword
sleep 5
echo "设置可能成功了哦,正在创建数据库"
mysql -u root -p$mysqlpassword << EOF
create database multicraft_daemon;create database multicraft_panel;
EOF
fi
echo "数据库安装完成!正在继续……"
}

# function pj (){
# read -p "请输入Multicraft安装目录" muinsdir
# echo "是否要破解 $muinsdir ,Ctrl + C退出,否则等待10秒"
# sleep 10
# echo "正在处理……"
# cd $muinsdir
# echo "677D-3C64-8B93-BFFC" > multicraft.key
# echo "127.0.0.1 multicraft.org
# 127.0.0.1 www.multicraft.org" >/etc/hosts
# echo "可能已经破解完成!正在重启Multicraft"
# $muinsdir/bin/multicraft restart
# }

function Init()
{
#版本判断
v=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'` 
if [ $v -eq 6 ]; then 
#CentOS 6
OSV="C6" 
fi
 if [ $v -eq 7 ]; then
#CentOS 7
OSV="C7" 
fi
nowdir=`pwd`
clear
echo -e "********欢迎使用Multicraft一键脚本！*********
------提示:您正在使用 $OSV 版系统--------
***如果没有正常显示请联系作者Q1136772134***
***首发 -> http://blog.tysv.top <-
******该脚本由 Kengwang编写 ********
===============Menu==============
->1.Multicraft下载安装
->2.维护中,请勿进入
->6.开机启动Multicraft Mysql Httpd等
->7.破解Multicraft           (嘿嘿,没有违规)
->8.修改Apache端口配置及启用htaccess
->a.升级脚本
->0.退出脚本"
read -p "请输入序号并回车：" num
case "$num" in
[1] ) (Installmu "Mu");;
[2] ) (Installmu "JY");;
[3] ) (byphp);;
[4] ) (hexin);;
[5] ) (phpaz);;
[6] ) (kjqd);;
[7] ) (pj);;
[8] ) (apache);;
[a] ) (update);;
[0] ) (exit);;
*) (Init);;
esac
}

function kjqd(){
echo "正在处理……"
if [ "$OSV" == "C6" ]; then
	service mysqld enable
elif [ "$OSV" == "C7" ]; then
	service mariadb enable
else
	echo "您的系统版本暂不支持此功能"
	exit;
fi
read -p "请输入multicraft安装目录(不要最后斜线)" mudir
echo "$mudir/bin/multicraft -v start
" > $mudir/sh/autostart.sh
echo "正在给予权限"
chmod +x $mudir/sh/autostart.sh
echo "$mudir/sh/autostart.sh">>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
echo "可能已经OK!"
}

function update(){
echo "正在更新脚本,请稍等"
wget -O multicraft.sh $DOWNURL/multicraft.sh;sh multicraft.sh
}

function apache(){
clear
read -p "请输入您要设置并开放的端口: " port
sent=`cat /etc/httpd/conf/httpd.conf | grep 'Listen ' | awk 'END {print}'`

sed -i "s/$sent/Listen $port/g" /etc/httpd/conf/httpd.conf
echo "即将重启httpd,有报错的话就可怜了"
sleep 5
clear
service httpd restart
echo "正在开放端口 $port"
chkconfig iptables off
if [ "$OSV" == "C7" ]; then
	firewall-cmd --get-active-zones
	firewall-cmd --zone=public --add-port=$port/tcp --permanent
	firewall-cmd --reload
	status=`lsof -i:$port`
	if [ "$status" == "" ]; then
		echo "开放失败"
	else
		echo "开放成功"
	fi
fi
echo "正在开启htaccess"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf
res=`cat /etc/httpd/conf/httpd.conf | grep 'AllowOverride None'`
if [ "$res" == "" ]; then
	echo "成功!"
else
	echo "开启htaccess失败"
fi
}

function downmu()
{

echo "正在下载Multicraft"

if [ "$1" == "Mu" ]; then
	echo "" > /etc/hosts
	echo "正在获取您的版本请求……"
	case "$muver" in	
	"1" ) 
	echo "您已选择2.1.0-pre5 正在从作者服务器下载"
	instver="$DOWNURL/muallver/Linux64/2.1.0-pre5.tar.gz";;
	"2" ) 
	echo "您已选择2.1.1 正在从作者服务器下载"
	instver="$DOWNURL/muallver/Linux64/2.1.1.tar.gz";;
	"3" )
	echo "您已选择2.2.0 正在从作者服务器下载"
	instver="$DOWNURL/muallver/Linux64/2.2.0.tar.gz";;
	"4" )
	echo "您已选择2.2.1 正在从作者服务器下载"
	instver="$DOWNURL/muallver/Linux64/2.2.1.tar.gz";;
	"5" )
	echo "您已选择2.3.0 正在从作者服务器下载"
	instver="$DOWNURL/muallver/Linux64/2.3.0.tar.gz";;
	* )
	echo "您已选择从Multicraft官网下载最新版"
	instver="http://www.multicraft.org/download/linux64";;
	esac
	
	echo "正在下载Multicraft"
	mkdir /tmp
	cd /tmp
	wget -O mu.tar.gz "$instver"
	tar xvzf mu.tar.gz
	cd multicraft
	chmod +x ./setup.sh
else
	echo "你是怎么执行这个的呀!"
	exit;
	fi
	
ip=`curl -L http://www.multicraft.org/ip`
if [ "$yijian" != "n" ]; then
	realinstallmu
else
	sh ./setup.sh
fi
sleep 5
echo "Multicraft安装完成,正在启动"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf
$mudir/bin/multicraft restart
ip=`curl -L http://www.multicraft.org/ip`
clear
echo "
******启动Multicraft成功!感谢使用Kengwang一键安装脚本*********
-----httpd的配置就麻烦自己改了吧,嘻嘻......----
-----你可以登录 $ip 来查看您的服务器-----
-----如果需要改端口,重启脚本并且选择更改Apache端口-----
作者Kengwang QQ:1136772134
"
}

function Installmu()
{
askallthing
echo "正在开启安装线程!"
installtools
downmu $1
}


	Init

