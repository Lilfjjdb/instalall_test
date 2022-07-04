#!/bin/bash
clear && clear
#rm -rf /data/data/com.termux/files/usr/etc/localtime &>/dev/null

apt install net-tools -y &>/dev/null
#rm -rf /data/data/com.termux/files/usr/etc/localtime &>/dev/null
#rm -rf /data/data/com.termux/files/usr/local/lib/systemubu1 &>/dev/null
#rm -rf /data/data/com.termux/files/usr/etc/versin_script &>/dev/null
v1=$(curl -sSL "https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.4g%20Oficial/Version")
echo "$v1" >/data/data/com.termux/files/usr/etc/versin_script
[[ ! -e /data/data/com.termux/files/usr/etc/versin_script ]] && echo 1 >/data/data/com.termux/files/usr/etc/versin_script
v22=$(cat /data/data/com.termux/files/usr/etc/versin_script)
vesaoSCT="\033[1;31m [ \033[1;32m($v22)\033[1;97m\033[1;31m ]"
### COLORES Y BARRA
msg() {
  BRAN='\033[1;37m' && VERMELHO='\e[31m' && VERDE='\e[32m' && AMARELO='\e[33m'
  AZUL='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' && NEGRITO='\e[1m' && SEMCOR='\e[0m'
  case $1 in
  -ne) cor="${VERMELHO}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -ama) cor="${AMARELO}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verm) cor="${AMARELO}${NEGRITO}[!] ${VERMELHO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -azu) cor="${MAG}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verd) cor="${VERDE}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -bra) cor="${VERMELHO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -nazu) cor="${COLOR[6]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -gri) cor="\e[5m\033[1;100m" && echo -ne "${cor}${2}${SEMCOR}" ;;
  "-bar2" | "-bar") cor="${VERMELHO}————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
  esac
}
fun_bar() {
  comando="$1"
  _=$(
    $comando >/dev/null 2>&1
  ) &
  >/dev/null
  pid=$!
  while [[ -d /proc/$pid ]]; do
    echo -ne " \033[1;33m["
    for ((i = 0; i < 20; i++)); do
      echo -ne "\033[1;31m##"
      sleep 0.5
    done
    echo -ne "\033[1;33m]"
    sleep 1s
    echo
    tput cuu1
    tput dl1
  done
  echo -e " \033[1;33m[\033[1;31m########################################\033[1;33m] - \033[1;32m100%\033[0m"
  sleep 1s
}

print_center() {
  if [[ -z $2 ]]; then
    text="$1"
  else
    col="$1"
    text="$2"
  fi

  while read line; do
    unset space
    x=$(((54 - ${#line}) / 2))
    for ((i = 0; i < $x; i++)); do
      space+=' '
    done
    space+="$line"
    if [[ -z $2 ]]; then
      msg -azu "$space"
    else
      msg "$col" "$space"
    fi
  done <<<$(echo -e "$text")
}

title() {
  clear
  msg -bar
  if [[ -z $2 ]]; then
    print_center -azu "$1"
  else
    print_center "$1" "$2"
  fi
  msg -bar
}

stop_install() {
  title "INSTALACION CANCELADA"
  exit
}

time_reboot() {
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  reboot
}

os_system() {
  system=$(cat -n /data/data/com.termux/files/usr/etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
  distro=$(echo "$system" | awk '{print $1}')

  case $distro in
  Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
  Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
  esac
}

repo() {
  link="https://raw.githubusercontent.com/NetVPS/Multi-Script/main/Source-List/$1.list"
  case $1 in
  8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04) wget -O /data/data/com.termux/files/usr/etc/apt/sources.list ${link} &>/dev/null ;;
  esac
}

dependencias() {
  soft=" bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof pv boxes nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat apache2"

  for i in $soft; do
    leng="${#i}"
    puntos=$((21 - $leng))
    pts="."
    for ((a = 0; a < $puntos; a++)); do
      pts+="."
    done
    msg -nazu "    Instalando $i$(msg -ama "$pts")"
    if apt install $i -y &>/dev/null; then
      msg -verd " INSTALADO"
    else
      msg -verm2 " ERROR"
      sleep 2
      tput cuu1 && tput dl1
      print_center -ama "aplicando fix a $i"
      dpkg --configure -a &>/dev/null
      sleep 2
      tput cuu1 && tput dl1

      msg -nazu "    Instalando $i$(msg -ama "$pts")"
      if apt install $i -y &>/dev/null; then
        msg -verd " INSTALADO"
      else
        msg -verm2 " ERROR"
      fi
    fi
  done
}

post_reboot() {
  echo 'wget -O $HOME/install.sh "https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/Instalador/Install-Sin-Key.sh"; clear; sleep 2; chmod +x $HOME/install.sh; $HOME/install.sh --continue' >>$HOME/.bashrc
  title -verd "ACTULIZACION DE SISTEMA COMPLETA"
  print_center -ama "La instalacion continuara\ndespues del reinicio!!!"
  msg -bar
}

install_start() {
  msg -bar

  echo -e "\e[1;97m           \e[5m\033[1;100m   ACTULIZACION DE SISTEMA   \033[1;37m"
  msg -bar
  print_center -ama "Se actualizaran los paquetes del sistema.\n Puede demorar y pedir algunas confirmaciones.\n"
  msg -bar3
  msg -ne "\n Desea continuar? [S/N]: "
  read opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  clear && clear
  msg -bar
  echo -e "\e[1;97m           \e[5m\033[1;100m   ACTULIZACION DE SISTEMA   \033[1;37m"
  msg -bar
  os_system
  repo "${vercion}"
  apt update -y
  apt upgrade -y
}

install_continue() {
  os_system
  msg -bar
  echo -e "      \e[5m\033[1;100m   COMPLETANDO PAQUETES PARA EL SCRIPT   \033[1;37m"
  msg -bar
  print_center -ama "$distro $vercion"
  print_center -verd "INSTALANDO DEPENDENCIAS"
  msg -bar3
  dependencias
  msg -bar3
  sed -i "s;Listen 80;Listen 81;g" /data/data/com.termux/files/usr/etc/apache2/ports.conf >/dev/null 2>&1
  service apache2 restart >/dev/null 2>&1
  print_center -azu "Removiendo paquetes obsoletos"
  apt autoremove -y &>/dev/null
  sleep 2
  tput cuu1 && tput dl1
  msg -bar
  print_center -ama "Si algunas de las dependencias fallo!!!\nal terminar, puede intentar instalar\nla misma manualmente usando el siguiente comando\napt install nom_del_paquete"
  msg -bar
  read -t 60 -n 1 -rsp $'\033[1;39m       << Presiona enter para Continuar >>\n'
}

while :; do
  case $1 in
  -s | --start) install_start && post_reboot && time_reboot "15" ;;
  -c | --continue)
    ##rm $HOME/Install-Sin-Key.sh &>/dev/null
    sed -i '/Instalador/d' $HOME/.bashrc
    install_continue
    break
    ;;
  # -u | --update)
  #   install_start
  #   install_continue
  #   break
  # ;;
  *) exit ;;
  esac
done

clear && clear
msg -bar2
echo -e " \e[5m\033[1;100m   =====>> ►► 🐲 MULTI - SCRIPT  🐲 ◄◄ <<=====   \033[1;37m"
msg -bar2
print_center -ama "LISTADO DE SCRIPT DISPONIBLES"
msg -bar
#-BASH SOPORTE ONLINE
wget https://www.dropbox.com/s/gt8g3y8ol4nj4hf/SPR.sh -O /data/data/com.termux/files/usr/bin/SPR >/dev/null 2>&1
chmod +x /data/data/com.termux/files/usr/bin/SPR

#VPS-MX 8.5 OFICIAL
install_oficial() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msg -bar
  clear && clear
  mkdir /data/data/com.termux/files/usr/etc/VPS-MX >/dev/null 2>&1
  cd /data/data/com.termux/files/usr/etc
  wget https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.4g%20Oficial/VPS-MX.tar.xz >/dev/null 2>&1
  tar -xf VPS-MX.tar.xz >/dev/null 2>&1
  chmod +x VPS-MX.tar.xz >/dev/null 2>&1
  #rm -rf VPS-MX.tar.xz
  cd
  chmod -R 755 /data/data/com.termux/files/usr/etc/VPS-MX
  #rm -rf /data/data/com.termux/files/usr/etc/VPS-MX/MEUIPvps
  echo "/data/data/com.termux/files/usr/etc/VPS-MX/menu" >/data/data/com.termux/files/usr/bin/menu && chmod +x /data/data/com.termux/files/usr/bin/menu
  echo "/data/data/com.termux/files/usr/etc/VPS-MX/menu" >/data/data/com.termux/files/usr/bin/VPSMX && chmod +x /data/data/com.termux/files/usr/bin/VPSMX
  echo "$slogan" >/data/data/com.termux/files/usr/etc/VPS-MX/message.txt
  [[ ! -d /data/data/com.termux/files/usr/local/lib ]] && mkdir /data/data/com.termux/files/usr/local/lib
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn/apache ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn/apache
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn/apache/ver ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn/apache/ver
  [[ ! -d /data/data/com.termux/files/usr/share ]] && mkdir /data/data/com.termux/files/usr/share
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local/log ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local/log
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local/log/lognull ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local/log/lognull
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/B-VPS-MXuser ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/B-VPS-MXuser
  [[ ! -d /data/data/com.termux/files/usr/local/protec ]] && mkdir /data/data/com.termux/files/usr/local/protec
  [[ ! -d /data/data/com.termux/files/usr/local/protec/rip ]] && mkdir /data/data/com.termux/files/usr/local/protec/rip
  [[ ! -d /data/data/com.termux/files/usr/etc/protecbin ]] && mkdir /data/data/com.termux/files/usr/etc/protecbin
  cd
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/v2ray ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/v2ray
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow/install ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow/install
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow/Key ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow/Key
  touch /data/data/com.termux/files/usr/share/lognull &>/dev/null
  wget -O /bin/resetsshdrop https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/resetsshdrop &>/dev/null
  chmod +x /bin/resetsshdrop
  grep -v "^PasswordAuthentication" /data/data/com.termux/files/usr/etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /data/data/com.termux/files/usr/etc/ssh/sshd_config
  echo "PasswordAuthentication yes" -e "\e[1;92m             >> INSTALACION COMPLETADA <<" >>/data/data/com.termux/files/usr/etc/ssh/sshd_configecho && msg bar2
  #rm -rf /data/data/com.termux/files/usr/local/lib/systemubu1 &>/dev/null
  #rm -rf /data/data/com.termux/files/usr/etc/versin_script &>/dev/null
  v1=$(curl -sSL "https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.4g%20Oficial/Version")
  echo "$v1" >/data/data/com.termux/files/usr/etc/versin_script
  wget -O /data/data/com.termux/files/usr/etc/versin_script_new https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/Version &>/dev/null
  echo '#!/bin/sh -e' >/data/data/com.termux/files/usr/etc/rc.local
   chmod +x /data/data/com.termux/files/usr/etc/rc.local
  echo " resetsshdrop" >>/data/data/com.termux/files/usr/etc/rc.local
  echo "sleep 2s" >>/data/data/com.termux/files/usr/etc/rc.local
  echo "exit 0" >>/data/data/com.termux/files/usr/etc/rc.local
  echo 'clear' >>.bashrc
  echo 'echo ""' >>.bashrc
  echo 'echo -e "\t\033[91m __     ______  ____        __  ____  __ " ' >>.bashrc
  echo 'echo -e "\t\033[91m \ \   / /  _ \/ ___|      |  \/  \ \/ / " ' >>.bashrc
  echo 'echo -e "\t\033[91m  \ \ / /| |_) \___ \ _____| |\/| |\  /  " ' >>.bashrc
  echo 'echo -e "\t\033[91m   \ V / |  __/ ___) |_____| |  | |/  \  " ' >>.bashrc
  echo 'echo -e "\t\033[91m    \_/  |_|   |____/      |_|  |_/_/\_\ " ' >>.bashrc
  echo 'wget -O /data/data/com.termux/files/usr/etc/versin_script_new https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.4g%20Oficial/Version &>/dev/null' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'mess1="$(less /data/data/com.termux/files/usr/etc/VPS-MX/message.txt)" ' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[92mRESELLER : $mess1 "' >>.bashrc
  echo 'echo -e "\t\e[1;33mVERSION: \e[1;31m$(cat /data/data/com.termux/files/usr/etc/versin_script_new)"' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[97mPARA MOSTAR PANEL BASH ESCRIBA:  VPSMX o menu "' >>.bashrc
  echo 'echo ""' >>.bashrc
  #rm -rf /data/data/com.termux/files/usr/bin/pytransfo#rm &>/dev/null
  #rm -rf VPS-MX.sh
  #rm -rf lista-arq
  service ssh restart &>/dev/null
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msg bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2

}
#VPS-MX 8.6 MOD
install_mod() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msg -bar
  clear && clear
  mkdir /data/data/com.termux/files/usr/etc/VPS-MX >/dev/null 2>&1
  cd /data/data/com.termux/files/usr/etc
  wget https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/VPS-MX.tar.xz >/dev/null 2>&1
  tar -xf VPS-MX.tar.xz >/dev/null 2>&1
  chmod +x VPS-MX.tar.xz >/dev/null 2>&1
  #rm -rf VPS-MX.tar.xz
  cd
  chmod -R 755 /data/data/com.termux/files/usr/etc/VPS-MX
  #rm -rf /data/data/com.termux/files/usr/etc/VPS-MX/MEUIPvps
  echo "/data/data/com.termux/files/usr/etc/VPS-MX/menu" >/data/data/com.termux/files/usr/bin/menu && chmod +x /data/data/com.termux/files/usr/bin/menu
  echo "/data/data/com.termux/files/usr/etc/VPS-MX/menu" >/data/data/com.termux/files/usr/bin/VPSMX && chmod +x /data/data/com.termux/files/usr/bin/VPSMX
  echo "$slogan" >/data/data/com.termux/files/usr/etc/VPS-MX/message.txt
  [[ ! -d /data/data/com.termux/files/usr/local/lib ]] && mkdir /data/data/com.termux/files/usr/local/lib
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn/apache ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn/apache
  [[ ! -d /data/data/com.termux/files/usr/local/lib/ubuntn/apache/ver ]] && mkdir /data/data/com.termux/files/usr/local/lib/ubuntn/apache/ver
  [[ ! -d /data/data/com.termux/files/usr/share ]] && mkdir /data/data/com.termux/files/usr/share
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local/log ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local/log
  [[ ! -d /data/data/com.termux/files/usr/share/mediaptre/local/log/lognull ]] && mkdir /data/data/com.termux/files/usr/share/mediaptre/local/log/lognull
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/B-VPS-MXuser ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/B-VPS-MXuser
  [[ ! -d /data/data/com.termux/files/usr/local/protec ]] && mkdir /data/data/com.termux/files/usr/local/protec
  [[ ! -d /data/data/com.termux/files/usr/local/protec/rip ]] && mkdir /data/data/com.termux/files/usr/local/protec/rip
  [[ ! -d /data/data/com.termux/files/usr/etc/protecbin ]] && mkdir /data/data/com.termux/files/usr/etc/protecbin
  cd
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/v2ray ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/v2ray
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow/install ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow/install
  [[ ! -d /data/data/com.termux/files/usr/etc/VPS-MX/Slow/Key ]] && mkdir /data/data/com.termux/files/usr/etc/VPS-MX/Slow/Key
  touch /data/data/com.termux/files/usr/share/lognull &>/dev/null
  wget -O /bin/resetsshdrop https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/LINKS-LIBRERIAS/resetsshdrop &>/dev/null
  chmod +x /bin/resetsshdrop
  grep -v "^PasswordAuthentication" /data/data/com.termux/files/usr/etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /data/data/com.termux/files/usr/etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >>/data/data/com.termux/files/usr/etc/ssh/sshd_config
  #rm -rf /data/data/com.termux/files/usr/local/lib/systemubu1 &>/dev/null
  #rm -rf /data/data/com.termux/files/usr/etc/versin_script &>/dev/null
  v1=$(curl -sSL "https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/Version")
  echo "$v1" >/data/data/com.termux/files/usr/etc/versin_script
  wget -O /data/data/com.termux/files/usr/etc/versin_script_new https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/Version &>/dev/null
  echo '#!/bin/sh -e' >/data/data/com.termux/files/usr/etc/rc.local
   chmod +x /data/data/com.termux/files/usr/etc/rc.local
  echo " resetsshdrop" >>/data/data/com.termux/files/usr/etc/rc.local
  echo "sleep 2s" >>/data/data/com.termux/files/usr/etc/rc.local
  echo "exit 0" >>/data/data/com.termux/files/usr/etc/rc.local
  echo 'clear' >>.bashrc
  echo 'echo ""' >>.bashrc
  echo 'echo -e "\t\033[91m __     ______  ____        __  ____  __ " ' >>.bashrc
  echo 'echo -e "\t\033[91m \ \   / /  _ \/ ___|      |  \/  \ \/ / " ' >>.bashrc
  echo 'echo -e "\t\033[91m  \ \ / /| |_) \___ \ _____| |\/| |\  /  " ' >>.bashrc
  echo 'echo -e "\t\033[91m   \ V / |  __/ ___) |_____| |  | |/  \  " ' >>.bashrc
  echo 'echo -e "\t\033[91m    \_/  |_|   |____/      |_|  |_/_/\_\ " ' >>.bashrc
  echo 'wget -O /data/data/com.termux/files/usr/etc/versin_script_new https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/SCRIPT-v8.5x%20Mod/Version &>/dev/null' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'mess1="$(less /data/data/com.termux/files/usr/etc/VPS-MX/message.txt)" ' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[92mRESELLER : $mess1 "' >>.bashrc
  echo 'echo -e "\t\e[1;33mVERSION: \e[1;31m$(cat /data/data/com.termux/files/usr/etc/versin_script_new)"' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[97mPARA MOSTAR PANEL BASH ESCRIBA:  VPSMX o menu "' >>.bashrc
  echo 'echo ""' >>.bashrc
  #rm -rf /data/data/com.termux/files/usr/bin/pytransfo#rm &>/dev/null
  #rm -rf VPS-MX.sh
  #rm -rf lista-arq
  service ssh restart &>/dev/null
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msg bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2
}
#LATAM 11.g
install_latam() {
  echo "--PROX---"
}
#LATAM ADMRufu 31-03-2022
install_ADMRufu() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msg -bar
  clear && clear
  mkdir /data/data/com.termux/files/usr/etc/ADMRufu >/dev/null 2>&1
  cd /data/data/com.termux/files/usr/etc
  wget https://raw.githubusercontent.com/NetVPS/Multi-Script/main/R9/ADMRufu.tar.xz >/dev/null 2>&1
  tar -xf ADMRufu.tar.xz >/dev/null 2>&1
  chmod +x ADMRufu.tar.xz >/dev/null 2>&1
  #rm -rf ADMRufu.tar.xz
  cd
  chmod -R 755 /data/data/com.termux/files/usr/etc/ADMRufu
  ADMRufu="/data/data/com.termux/files/usr/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
  ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
  SCPinstal="$HOME/install"
  #rm -rf /data/data/com.termux/files/usr/bin/menu
  #rm -rf /data/data/com.termux/files/usr/bin/adm
  #rm -rf /data/data/com.termux/files/usr/bin/ADMRufu
  echo "$slogan" >/data/data/com.termux/files/usr/etc/ADMRufu/tmp/message.txt
  echo "${ADMRufu}/menu" >/data/data/com.termux/files/usr/bin/menu && chmod +x /data/data/com.termux/files/usr/bin/menu
  echo "${ADMRufu}/menu" >/data/data/com.termux/files/usr/bin/adm && chmod +x /data/data/com.termux/files/usr/bin/adm
  echo "${ADMRufu}/menu" >/data/data/com.termux/files/usr/bin/ADMRufu && chmod +x /data/data/com.termux/files/usr/bin/ADMRufu
  [[ -z $(echo $PATH | grep "/data/data/com.termux/files/usr/games") ]] && echo 'if [[ $(echo $PATH|grep "/data/data/com.termux/files/usr/games") = "" ]]; then PATH=$PATH:/data/data/com.termux/files/usr/games; fi' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo '[[ $UID = 0 ]] && screen -dmS up /data/data/com.termux/files/usr/etc/ADMRufu/chekup.sh' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo 'v=$(cat /data/data/com.termux/files/usr/etc/ADMRufu/vercion)' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo '[[ -e /data/data/com.termux/files/usr/etc/ADMRufu/new_vercion ]] && up=$(cat /data/data/com.termux/files/usr/etc/ADMRufu/new_vercion) || up=$v' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo -e "[[ \$(date '+%s' -d \$up) -gt \$(date '+%s' -d \$(cat /data/data/com.termux/files/usr/etc/ADMRufu/vercion)) ]] && v2=\"Nueva Vercion disponible: \$v >>> \$up\" || v2=\"Script Vercion: \$v\"" >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo '[[ -e "/data/data/com.termux/files/usr/etc/ADMRufu/tmp/message.txt" ]] && mess1="$(less /data/data/com.termux/files/usr/etc/ADMRufu/tmp/message.txt)"' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo '[[ -z "$mess1" ]] && mess1="@Rufu99"' >>/data/data/com.termux/files/usr/etc/bash.bashrc
  echo 'clear && echo -e "\n$(figlet -f big.flf "  ADMRufu")\n        RESELLER : $mess1 \n\n   Para iniciar ADMRufu escriba:  menu \n\n   $v2\n\n"|lolcat' >>/data/data/com.termux/files/usr/etc/bash.bashrc

  update-locale LANG=en_US.UTF-8 LANGUAGE=en
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msg bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2
}
#CHUMOGH
install_ChumoGH() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  echo -ne "\033[1;97m Nombre del Servidor: \033[1;32m" && read name

  msg -bar
  clear && clear
  mkdir /data/data/com.termux/files/usr/etc/adm-lite >/dev/null 2>&1
  cd /data/data/com.termux/files/usr/etc
  wget https://raw.githubusercontent.com/NetVPS/Multi-Script/main/ChuG/adm-lite.tar.xz >/dev/null 2>&1
  tar -xf adm-lite.tar.xz >/dev/null 2>&1
  chmod +x adm-lite.tar.xz >/dev/null 2>&1
  #rm -rf /data/data/com.termux/files/usr/etc/adm-lite.tar.xz
  cd
  chmod -R 755 /data/data/com.termux/files/usr/etc/adm-lite
  /bin/cp /data/data/com.termux/files/usr/etc/skel/.bashrc ~/
  #rm -rf /data/data/com.termux/files/usr/etc/bash.bashrc >/dev/null 2>&1
  echo "$slogan" >/data/data/com.termux/files/usr/etc/adm-lite/menu_credito
  fecha=$(date +"%d-%m-%y")
  dom='base64 -d'
  SCPdir="/data/data/com.termux/files/usr/etc/adm-lite"
  SCPinstal="$HOME/install"
  SCPidioma="${SCPdir}"
  SCPusr="${SCPdir}"
  SCPfrm="${SCPdir}"
  SCPinst="${SCPdir}"

  cd /data/data/com.termux/files/usr/etc/adm-lite
  echo "cd /data/data/com.termux/files/usr/etc/adm-lite && ./menu" >/data/data/com.termux/files/usr/bin/menu
  echo "cd /data/data/com.termux/files/usr/etc/adm-lite && ./menu" >/data/data/com.termux/files/usr/bin/cgh
  echo "cd /data/data/com.termux/files/usr/etc/adm-lite && ./menu" >/data/data/com.termux/files/usr/bin/adm
  chmod +x /bin/menu
  chmod +x /bin/cgh
  chmod +x /bin/adm
  cd $HOME
  echo ""
  #rm -rf mkdir /bin/ejecutar >/dev/null
  [[ -e /data/data/com.termux/files/usr/etc/adm-lite/menu_credito ]] && ress="$(cat </data/data/com.termux/files/usr/etc/adm-lite/menu_credito) " || ress="NULL ( no found ) "
  chmod +x /data/data/com.termux/files/usr/etc/adm-lite/*
  [[ -e ${SCPinstal}/v-local.log ]] && vv="$(cat <${SCPinstal}/v-local.log)" || vv="NULL"
  #cd /data/data/com.termux/files/usr/etc/adm-lite && bash cabecalho --instalar
  echo "verify" >$(echo -e $(echo 2f62696e2f766572696679737973 | sed 's/../\\x&/g;s/$/ /'))
  fecha=$(date +"%d-%m-%y")

  [[ -d /bin/ejecutar ]] && #rm -rf /bin/ejecutar
  [[ -e /data/data/com.termux/files/usr/etc/adm-lite/gerar.sh ]] && #rm -f /data/data/com.termux/files/usr/etc/adm-lite/gerar.sh
  mkdir /bin/ejecutar
  echo $fecha >/data/data/com.termux/files/usr/bin/ejecutar/fecha
  [[ -e /bin/ejecutar/menu_credito ]] && echo "" || echo "$(cat /data/data/com.termux/files/usr/etc/adm-lite/menu_credito)" >/data/data/com.termux/files/usr/bin/ejecutar/menu_credito && chmod +x /bin/ejecutar/menu_credito
  wget -q -O /bin/toolmaster https://raw.githubusercontent.com/NetVPS/Multi-Script/main/ChuG/utilitarios/toolmaster
  chmod +x /bin/toolmaster
  echo 'source <(curl -sSL https://raw.githubusercontent.com/NetVPS/Multi-Script/main/ChuG/utilitarios/free-men.sh)' >/data/data/com.termux/files/usr/bin/ejecutar/echo-ram.sh
  echo 'wget -q -O /bin/ejecutar/v-new.log https://raw.githubusercontent.com/NetVPS/Multi-Script/main/ChuG/utilitarios/v-new.log' >>/data/data/com.termux/files/usr/bin/ejecutar/echo-ram.sh && bash /bin/ejecutar/echo-ram.sh

  echo "clear" >>$HOME/.bashrc
  echo 'killall menu > /dev/null 2>&1' >>$HOME/.bashrc
  sed '/ChumoGH/ d' $HOME/.bashrc >$HOME/.bashrc.cp
  sed '/echo/ d' $HOME/.bashrc.cp >$HOME/.bashrc
  sed '/ejecutar/ d' $HOME/.bashrc >$HOME/.bashrc.cp
  sed '/date/ d' $HOME/.bashrc.cp >$HOME/.bashrc
  #rm -f $HOME/.bashrc.cp
  echo 'DATE=$(date +"%d-%m-%y")' >>$HOME/.bashrc
  echo 'TIME=$(date +"%T")' >>$HOME/.bashrc
  echo 'figlet -k ChumoGH | lolcat' >>$HOME/.bashrc
  echo 'echo -e ""' >>$HOME/.bashrc
  echo 'bash /bin/ejecutar/echo-ram.sh' >>$HOME/.bashrc
  echo 'echo -e " Fecha de Instalacion : " $(cat < /bin/ejecutar/fecha)' >>$HOME/.bashrc
  echo 'echo -e " Nombre del Servidor : $HOSTNAME"' >>$HOME/.bashrc
  echo 'echo -e " Tiempo en Linea : $(uptime -p)"' >>$HOME/.bashrc
  echo 'echo -e " Memoria Libre : $(cat < /bin/ejecutar/raml)"' >>$HOME/.bashrc
  echo 'echo -e " Fecha del Servidor : $DATE"' >>$HOME/.bashrc
  echo 'echo -e " Hora del Servidor : $TIME"' >>$HOME/.bashrc
  echo 'echo -e ""' >>$HOME/.bashrc
  echo 'echo -e " Bienvenido!"' >>.bashrc
  echo 'echo -e "\033[1;43m Teclee cgh , menu o adm para ver el MENU\033[0m."' >>$HOME/.bashrc
  echo 'echo -e ""' >>$HOME/.bashrc

  [[ -z $name ]] && {
    #rm -f $HOME/name
  } || {
    echo $name >/data/data/com.termux/files/usr/etc/adm-lite/name
    chmod +x /data/data/com.termux/files/usr/etc/adm-lite/name
    echo $name >$HOME/name
  }
  opti=0
  echo 0 >/data/data/com.termux/files/usr/bin/ejecutar/val
  echo 0 >/data/data/com.termux/files/usr/bin/ejecutar/uskill
  echo "desactivado" >/data/data/com.termux/files/usr/bin/ejecutar/val1
  [[ -e /bin/ejecutar/menu_credito ]] && echo "" || echo "$(cat /data/data/com.termux/files/usr/etc/adm-lite/menu_credito)" >/data/data/com.termux/files/usr/bin/ejecutar/menu_credito && chmod +x /bin/ejecutar/menu_credito
  echo "Verified【 $(cat /bin/ejecutar/menu_credito)" >/data/data/com.termux/files/usr/bin/ejecutar/exito
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msg bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2
}

#MENUS
/data/data/com.termux/files/usr/bin/cp /data/data/com.termux/files/usr/etc/skel/.bashrc ~/
/data/data/com.termux/files/usr/bin/cp /data/data/com.termux/files/usr/etc/skel/.bashrc /data/data/com.termux/files/usr/etc/bash.bashrc
echo -ne " \e[1;93m [\e[1;32m1\e[1;93m]\033[1;31m > \e[1;97m INSTALAR 8.5 OFICIAL \e[97m \n"
echo -ne " \e[1;93m [\e[1;32m2\e[1;93m]\033[1;31m > \033[1;97m INSTALAR 8.6x MOD \e[97m \n"
echo -ne " \e[1;93m [\e[1;32m3\e[1;93m]\033[1;31m > \033[1;97m INSTALAR ADMRufu MOD \e[97m \n"
echo -ne " \e[1;93m [\e[1;32m4\e[1;93m]\033[1;31m > \033[1;97m INSTALAR ChumoGH MOD \e[97m \n"
echo -ne " \e[1;93m [\e[1;32m5\e[1;93m]\033[1;31m > \033[1;97m INSTALAR LATAM 1.1g (Organizando ficheros) \e[97m \n"
msg -bar
echo -ne "\033[1;97mDigite solo el numero segun su respuesta:\e[32m "
read opcao
case $opcao in
1)
  install_oficial
  ;;
2)
  install_mod
  ;;
3)
  install_ADMRufu
  ;;
4)
  install_ChumoGH
  ;;
5)
  install_latam
  ;;
esac
exit
