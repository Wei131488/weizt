#!/bin/bash
#author:swenyus 
#data:2022-06-4

#=========================================================#
default_ssh_port="22"
default_ssh_passwd="password"
#=========================================================#
Lock_host=" "
#=========================================================#
Autostart_host=" "
#=========================================================#
Search_list="`echo $Lock_host|tr ',' ' '`"
autostart_kvm_list="`echo $Autostart_host|tr ',' ' '`"
get_lock_host_list=($Search_list)
get_autostart_host_list=($autostart_kvm_list)
#=========================================================#
sh_dir="`dirname $0`/`basename $0`"
#=========================================================#
#  set timeout 20
ssh_expect_login(){
get_ssh_ip=$1;get_passwd=$2 get_ssh_port=$3
[[ "$get_passwd" == "false" ]] && ssh_login_passwd="$default_ssh_passwd" || ssh_login_passwd="$get_passwd"
[[ -z $get_ssh_port ]] && ssh_login_port="$default_ssh_port" || ssh_login_port="$get_ssh_port"
if [ ! -z $get_ssh_ip ];then
mkdir  /log_temporary >/dev/null 2>/dev/null
cat <<-EOF >  /log_temporary/login_log
#!/usr/bin/expect 
spawn ssh -p$ssh_login_port  $get_ssh_ip
expect {
         "*(yes/no)?" { send "yes\r";exp_continue }
         "*assword:" { send "$ssh_login_passwd\r";interact }
}
EOF
else
  clear
fi
}
#=========================================================#
Empty_expect()
{
 sleep 1
 ps -ef|grep expect >/dev/null
 sleep 1
 ls /log_temporary 2>/dev/null >/dev/null && echo > /log_temporary/login_log  2>/dev/null  >/dev/null
}
#===================================================================================================================#
Mark=15;Mark1=4 
schedule()
{
 echo -ne "\033[${Mark1}C "
 while true
 do
   if [ `ps -aux | grep -v grep | grep "$$" | wc -l` == "0" ];then
     exit 
   fi
   echo -n ">";sleep 0.5 
   echo -ne "\033[34m>\033[0m"
   let Get_Mark++
   if [[ $Get_Mark -eq $Mark ]];then
     echo -ne "\033[33${Mark}D"
     echo -ne "\033[K"
     echo -ne "\033[${Mark1}C "
     unset Get_Mark ;Get_Mark=0
   fi
 done
}
#=========================================================#
End_schedule()
{
 kill -9 $Pid_schedule
}  2>/dev/null
#=========================================================#
Delimiter()
{
  I=0
  while [ $I -lt $1 ]
  do
    echo -n "-"
    let I++
  done
  echo
}
#=========================================================#
Get_user_identity()
{
  if [ `id -u` -eq 0 ];then
     echo  "       Hello, super administrator. "
  else
    groups | grep wheel
    if [ $? -eq 0 ];then
      echo "        Hello,administrator.  "
    else
      echo -e "\033[31m !! Permission denied!  \033[0m"
      exit
    fi
  fi

}
#=========================================================#
Executive_item()
{
 while :
 do
   clear
   $1
   echo -e "    Enter R to return Or RR to return main menu"
   Delimiter 82
   read -t 20 -p " Please select input: " Enter_R
   if [[ "$Enter_R" == "R" ]] || [[ "$Enter_R" == "r" ]];then
     $Submenu_name
     break
   elif [[ "$Enter_R" == "RR" ]] || [[ "$Enter_R" == "rr" ]];then
     source main_menu
     break
   elif [[ "$Enter_R" == "Q" ]] || [[ "$Enter_R" == "q" ]];then
     exit
   fi
 done
}
#=========================================================#
##confirm_operation  confirm_fali confirm_null
confirm_operation()
{
  operation_get=$1  operation_host=$2
  read -t 60 -p " whether to $operation_get $operation_host (yes/no)" confirm
  if [[ "$confirm" == "yes" ]] || [[ "$confirm" == "no" ]] ;then
      [[ "$confirm" == "no" ]] && confirm_fali="break"
      [[ "$confirm" == "yes" ]] && confirm_fali="echo "
      confirm_null="echo"
  else
     echo -e "\033[31m  error!! Please confirm the operation \033[0m"
     sleep 3 && confirm_null="break"
  fi
}
#=========================================================#
#=============================================install-kvm===========================================================#
Init_tools_config()
{
 sed -i "s/^default_ssh_port=.*/default_ssh_port=\"22\"/g" $(dirname $0)/$(basename $0)
 sed -i "s/^default_ssh_passwd=.*/default_ssh_passwd=\"password\"/g" $(dirname $0)/$(basename $0)
 sed -i "s/^Lock_host=.*/Lock_host=\" \"/g" $(dirname $0)/$(basename $0)
 sed -i "s/^Autostart_host=.*/Autostart_host=\" \"/g" $(dirname $0)/$(basename $0)
}
#=========================================================#
Online_install_kvm()
{
while :
do
  confirm_operation  "online install kvm service"
  $confirm_fali >/dev/null ; $confirm_null  >/dev/null
  if [[ "$confirm" == "yes" ]];then
    Card_name="`route -n|awk '/UG/{print$NF}'`"
    Card_Dir="/etc/sysconfig/network-scripts"
    cat  ${Card_Dir}/ifcfg-${Card_name}|grep BOOTPROTO|grep dhcp
    if [ $? -ne 0 ];then
      cp ${Card_Dir}/ifcfg-${Card_name}{,-bak};cp ${Card_Dir}/ifcfg-${Card_name} ${Card_Dir}/ifcfg-br0
      yum -y install qemu-kvm python-virtinst libvirt libvirt-python virt-manager libguestfs-tools bridge-utils virt-install expect
      #local_ens33
      sed -i 's/IPADDR/#&/g'  ${Card_Dir}/ifcfg-${Card_name}
      sed -i 's/NETMASK/#&/g'  ${Card_Dir}/ifcfg-${Card_name}
      sed -i 's/GATEWAY/#&/g'  ${Card_Dir}/ifcfg-${Card_name}
      sed -i 's/DNS/#&/g'  ${Card_Dir}/ifcfg-${Card_name}
      sed -i 's/PREFIX/#&/g'  ${Card_Dir}/ifcfg-${Card_name}
      sudo sed -ri '/UUID*/d' ${Card_Dir}/ifcfg-${Card_name}
      sudo sed -ri '/UUID*/d' ${Card_Dir}/ifcfg-br0
      sed -i '/TYPE/a\BRIDGE=br0\' ${Card_Dir}/ifcfg-${Card_name}
      #net-br0 
      sed -i "s/TYPE=.*/TYPE=Bridge/g"  ${Card_Dir}/ifcfg-br0
      sed -i "s/NAME=.*/NAME=br0/g"  ${Card_Dir}/ifcfg-br0
      sed -i "s/DEVICE=.*/DEVICE=br0/g"  ${Card_Dir}/ifcfg-br0
      sed -i "s/BOOTPROTO=.*/BOOTPROTO=static/g"  ${Card_Dir}/ifcfg-br0
      sed -i "s/ONBOOT=.*/ONBOOT=yes/g"  ${Card_Dir}/ifcfg-br0
      systemctl restart network
      echo "net.ipv4.ip_forward = 1" >>  /etc/sysctl.conf;sysctl -p 
      echo "allow br0" >>  /etc/qemu-kvm/bridge.conf
      systemctl enable libvirtd && systemctl start libvirtd;systemctl restart network
    else
      printf "\e[1;31m Must be static ip \e[0m\n " 
      exit
    fi
  break
  fi
done
}
#=========================================================#
#
Offline_install_kvm()
{
 echo notyet

}
#
#=============================================install-kvm===========================================================#

#=====================================kvm-host======================================================================#
#
get_host_ip_name()
{
  unset list_num[*] list_name[*] list_Ip[*]
  clear;clear;clear
  Delimiter 82
  echo -e "    query kvm host list:"
  network_segment=`route -n|grep "UG" |awk '{print $2}'|sed 's/..$//g'`
  for IP in ${network_segment}.{1..253};
  do
    {
      ping -c2 $IP >/dev/null 2>&1
    }&
  done
  kvm_host_run="`virsh list --all|grep -v Name|awk '/running/{print$2}'|sort|xargs`"
  kvm_host_off="`virsh list --all|grep -v Name|awk '/shut.off/{print$2}'|sort|xargs`"
  kvm_host_list="$kvm_host_run $kvm_host_off"
  Num=0;unset list_num[*] list_name[*] 
  for Name in ${kvm_host_list};
  do
    let Num++
    get_Mac0="`virsh dumpxml $Name |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"|wc -l`"
    if [[ $get_Mac0 -gt 1 ]];then
      get_Mac="`virsh dumpxml $Name |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"|xargs|tr ' ' '|'`"
    else
      get_Mac="`virsh dumpxml $Name |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"|xargs`"
    fi
    while :
    do
      Get_vm_ip="`arp -ne |grep -E "$get_Mac"|awk '{print $1}'|sort|xargs|tr ' ' ','`"
      arp -ne |grep -E "$get_Mac"|awk '{print $1}'|xargs -I {} arp -d {} 2>/dev/null
###----------------------------------------------------------------
      if [[ -z "$Get_vm_ip" ]];then
        unset All_host_list[*] All_host_status_list[*] get_status kvm_status result
        All_host_list=(`virsh list --all|grep -v Name |awk '{print$2}'|xargs`)
        All_host_status_list=(`virsh list --all|grep -v Name |awk '{print$3 $4}'|xargs`)
        for (( G=0;G<${#All_host_list[*]};G++))
        do
          if [[ "${All_host_list[$G]}" == "${Name}" ]];then
           get_status=${All_host_status_list[$G]}
           [[ "$get_status" == "running" ]] && kvm_status="running"||kvm_status="off"
           break
          fi
        done
        #===========================
        for (( D=0;D<${#Stop_name_list[*]};D++))
        do
          if [[ "${Stop_name_list[$D]}" == "${Name}" ]];then
              result=stop
           break
          fi
        done
        #===========================
        if [[ "$result" == "stop" ]];then
         [[ "$kvm_status" != "running" ]] && Get_IP="off" || Get_IP="Shutting_down"
        else
          [[ "$kvm_status" == "running" ]] && Get_IP="starting" ||Get_IP="off"
        fi
         break
      elif [[ ! -z "$Get_vm_ip" ]];then
        unset All_host_list[*] All_host_status_list[*] get_status kvm_status1 result
        All_host_list=(`virsh list --all|grep -v Name |awk '{print$2}'|xargs`)
        All_host_status_list=(`virsh list --all|grep -v Name |awk '{print$3 $4}'|xargs`)
        for (( G=0;G<${#All_host_list[*]};G++))
        do
          if [[ "${All_host_list[$G]}" == "${Name}" ]];then
           get_status=${All_host_status_list[$G]}
           [[ "$get_status" == "running" ]] && kvm_status1="running"||kvm_status1="off"
           break
          fi
        done
        #===========================
        for (( D=0;D<${#Stop_name_list[*]};D++))
        do
          if [[ "${Stop_name_list[$D]}" == "${Name}" ]];then
              result=stop
           break
          fi
        done
        #===========================
        if [[ "$result" == "stop" ]];then
          [[ "$kvm_status1" != "running" ]] && Get_IP="off"|| Get_IP="Shutting_down"
        else
          [[ "$kvm_status1" == "running" ]] && Get_IP="$Get_vm_ip"||Get_IP="off"
        fi
          break
      fi
###----------------------------------------------------------------
    done
    Locked_state0="`echo "${get_lock_host_list[@]}"|awk -v A=${Name} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
    Autostart_state0="`echo "${get_autostart_host_list[@]}"|awk -v A=${Name} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
    local_Autostart_state="`virsh dominfo ${Name}|awk '/Autostart:/{print$2}'`";local_add=0
    #================================================================================
    if [[ $local_Autostart_state == "enable" ]];then
      let  local_add++ 
      [[ $local_add -eq 1 ]] && get_autostart_host_list=${Name}
      get_autostart_host_list[${#get_autostart_host_list[*]}]=${Name}
      autostart_host_tmp="${get_autostart_host_list[@]}" && get_autostart_host_list=($autostart_host_tmp)
      Refresh_autostart_host="`echo ${get_autostart_host_list[@]}|tr ' ' '\n'|sort -u|tr '\n' ','`"
      sed -i "s/^Autostart_host=.*/Autostart_host=\"${Refresh_autostart_host}\"/g" $(dirname $0)/$(basename $0)
      unset autostart_host_tmp Refresh_autostart_host  
    fi
    #================================================================================
    if [[ "$Locked_state0" == "true" ]];then
      Get_locked="locked"
      effective_locked[${#effective_locked[*]}]=${Name}
    else
      Get_locked="."
    fi
    [[ "$Autostart_state0" == "true" || $local_Autostart_state == "enable" ]] && Get_autostart="autostart"||Get_autostart="."
    list_num[${#list_num[*]}]=$Num;list_name[${#list_name[*]}]=$Name;list_Ip[${#list_Ip[*]}]=$Get_IP
    Delimiter 82
    printf "   %-5s %-18s %-32s %-11s %-6s \n" $Num  $Name $Get_IP $Get_autostart $Get_locked
    if [[ "$Export_list" == "true" ]];then
      printf "    %-5s %-18s %-32s %-11s %-6s\n" $Num  $Name $Get_IP $Get_autostart $Get_locked >>  /kvm_host_list
      echo "  " >>  /kvm_host_list
    fi
  done
  Refresh_locked_host="`echo ${effective_locked[@]}|tr ' ' '\n'|sort -u|tr '\n' ','`";get_lock_host_list=(${effective_locked[@]})
  [[ ${#list_name[*]} -ne 0 ]] && sed -i "s/^Lock_host=.*/Lock_host=\"${Refresh_locked_host}\"/g" $(dirname $0)/$(basename $0)
  unset Export_list Refresh_locked_host effective_locked Get_locked Get_autostart
  Delimiter 82
}
#=========================================================#
Front-end-query()
{ 
  action="$1"
  action_host="$2"
  while :
  do
    clear;clear;clear;unset options
    get_host_ip_name
    echo -e "    Enter R to return Or RR to return main menu"
    Delimiter 82
    read -t 60 -p " Enter the number to ${action} the kvm host(1/2):" options
    if [[ -z "$options" ]];then
      echo -e "\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$options" == "R" ]]||[[ "$options" == "r" ]];then
          $Submenu_name && unset options && break
    elif [[ "$options" == "Q" ]]||[[ "$options" == "q" ]];then
      exit
    elif [[ "$options" == "RR" ]]||[[ "$options" == "rr" ]];then
       main_menu  && unset options && break
    elif [[ ! -z "$options" ]];then
      options_number="` echo $options|grep "[0-9]$"|wc -L 2>/dev/null`"
      if [ $options_number -gt 0 ];then
        let get_options=$options-1
        search_result="$get_options"
        confirm_operation "$action" ": ${list_name[${search_result}]}" 
        [[ "$confirm" == "yes" ]] && break
      else
        echo -e "\033[31m  error!! Please enter your operation \033[0m"
        sleep 2
      fi
    fi
  done
}
#=========================================================#
Export_list_kvm()
{
 clear;clear
 echo  -e "\n\033[0m     Exporting host list \033[0m"
 unset Pid_schedule ;schedule &
 Pid_schedule=$!
 Export_list=true
 echo "   " >  /kvm_host_list
 printf "       %-13s %-20s  %-20s\n" Num  host_Name  host_IP  >>  /kvm_host_list
 echo "   " >>  /kvm_host_list
 get_host_ip_name  >> /dev/null
 sleep 5
 End_schedule >/dev/null 2>/dev/null
 echo  -e "\n\033[32m     Export_dir: /kvm_host_list \033[0m"
 sleep 4
 $Submenu_name && unset Export_list
}
#=========================================================#
login_the_kvm_host()
{
 while :
 do
    Front-end-query  login  
    Input_login=$search_result ; unset search_result
    read -t 60 -p " Enter the ssh port to login the kvm host(22):" Input_port
   [ "$Input_port" == "Q" -o "$Input_port" == "q" ] && exit 
    read -t 60 -p " Enter the kvm host passwd:" Input_login_passwd
    [[ -z "$Input_login_passwd" ]] && Input_login_passwd=false && Input_login_passwd1=$default_ssh_passwd||Input_login_passwd1=$Input_login_passwd
    [[ -z "$Input_port" ]] && Input_port1=$default_ssh_port || Input_port1=$Input_port
    if [[ -z "$Input_login" ]];then
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$Input_login_passwd" == "R" ]]||[[ "$Input_login_passwd" == "r" ]];then
          $Submenu_name && unset Input_login_passwd Input_login && break
    elif [[ "$Input_login_passwd" == "Q" ]]||[[ "$Input_login_passwd" == "q" ]];then
      exit
    elif [[ "$Input_login_passwd" == "RR" ]]||[[ "$Input_login_passwd" == "rr" ]];then
       main_menu &&  unset Input_login_passwd Input_login && break
    elif [[ ! -z "$Input_login" ]];then
      clear;clear;clear
      Login_ip="`echo ${list_Ip[$Input_login]}|tr ',' ' '|awk '{print$1}'`" 
      echo  -e "      << Login with Host:$Login_ip  Pass:$Input_login_passwd1  Port:$Input_port1 >>"
      ssh_expect_login $Login_ip  $Input_login_passwd $Input_port
      Empty_expect &
      ls /log_temporary/login_log 2>/dev/null >/dev/null && expect /log_temporary/login_log 
      rm -rf /log_temporary 
      unset Input_login_passwd Input_login ;break
    fi
 done
}

#=========================================================#

change_default_port_passwd()
{
 while :
 do
   confirm_operation  "change the default login password and port"
   $confirm_fali >/dev/null ; $confirm_null  >/dev/null 
   clear
   Delimiter 90
   read -t 60 -p " Enter the default login ssh port(22):" Input_change_port
   [ "$Input_change_port" == "Q" -o "$Input_change_port" == "q" ] && exit 
    read -t 60 -p " Enter the kvm host passwd:" Input_change_passwd
    [ "$Input_change_passwd" == "Q" -o "$Input_change_passwd" == "q" ] && exit
    [[ "$Input_change_port" == "" ]]||[[ "$Input_change_passwd" == "" ]] && echo  -e "\n\033[31m  input error \033[0m" && sleep 2 &&  $Submenu_name
    echo $Input_change_port  |grep '[0-9]$' && port_true=true
    if [[ ! -z "$Input_change_port" ]] && [[ ! -z "$Input_change_passwd" ]]&& [[ "$port_true" == "true" ]];then 
      sed -i "/^default_ssh_port=*/c default_ssh_port=\'${Input_change_port}\'" ${sh_dir}
      sed -i "/^default_ssh_passwd=*/c default_ssh_passwd=\'${Input_change_passwd}\'" ${sh_dir}
      source ${sh_dir};break
    else
      echo  -e "\n\033[31m  input error \033[0m" && sleep 2 &&  $Submenu_name;break
    fi
 done
}

#=========================================================#
create_model_host()
{
  virsh list >/dev/null 2>/dev/null
  [[ $? -ne 0 ]]&& echo " error:kvm is not installed"&& exit 
  while :
  do
  clear;clear 
  confirm_operation  "create model host" " "
  $confirm_fali >/dev/null ; $confirm_null  >/dev/null
  read -p " Please enter the kvm hostname :" getName 
  [ "$getName" == "Q" -o "$getName" == "q" ] && exit
  read -p " Please enter the cpu core (1-9)    :" getcpucore
  [ "$getcpucore" == "Q" -o "$getcpucore" == "q" ] && exit
  read -p " Please enter the cpu threads (1-9)  :" getcputhread  
  [ "$getcputhread" == "Q" -o "$getcputhread" == "q" ] && exit
  read -p " Please enter the kvm memory (1-9[G]):" getmemory
  [ "$getmemory" == "Q" -o "$getmemory" == "q" ] && exit
  read -p " Please enter the kvm disk size (1-9[G]):" get_disk_size
  [ "$get_disk_size" == "Q" -o "$get_disk_size" == "q" ] && exit
  read -p " Please enter the kvm disk_data dir:" get_data_dir
  [ "$get_data_dir" == "Q" -o "$get_data_dir" == "q" ] && exit
  read -p " Please enter the source IOS dir:" get_ios_dir 
  [ "$get_ios_dir" == "Q" -o "$get_ios_dir" == "q" ] && exit
  if [[ ! -z $getName ]]&& [[ ! -z $getcpucore ]]&&[[ ! -z $getcputhread ]]&&[[ ! -z $getmemory ]]&&[[ ! -z $get_disk_size  ]]&&[[ ! -z $get_data_dir ]]&&[[ ! -z $get_ios_dir ]];then
    printf "\e[1;32m  hostname: $getName \e[0m\n " 
    printf "\e[1;32m cpu core: $getcpucore\e[0m\n " 
    printf "\e[1;32m cpu threads: $getcputhread \e[0m\n " 
    printf "\e[1;32m memory: ${getmemory}G \e[0m\n " 
    printf "\e[1;32m disk size: ${get_disk_size}G \e[0m\n " 
    [[ ! -d "$get_data_dir" ]] && mkdir -p $get_data_dir 2>/dev/null >/dev/null 
    printf "\e[1;32m disk_data dir: $get_data_dir \e[0m\n "  
    [[ ! -f "$get_ios_dir" ]] && echo " error:Mirror does not exist" && exit|| \
    printf "\e[1;32m source IOS: $get_ios_dir \e[0m\n " 
    printf "\e[1;34m reday deploy ... \e[0m\n " 
    setenforce 0 2>/dev/null >/dev/null && setenforce 0 2>/dev/null >/dev/null && setenforce 0 2>/dev/null >/dev/null
    setenforce 0 2>/dev/null >/dev/null && setenforce 0 2>/dev/null >/dev/null && setenforce 0 2>/dev/null >/dev/null
    virt-install \
    --virt-type=kvm  \
    --name=${getName}  \
    --vcpus sockets=1,cores=${getcpucore},threads=${getcputhread} \
    --memory=$((${getmemory}*1024))  \
    --location=${get_ios_dir}  \
    --disk path=${get_data_dir}/${getName}.qcow2,size=${get_disk_size},format=qcow2 --check disk_size=off  \
    --os-type=linux \
    --os-variant=auto \
    --network bridge=br0  \
    --graphics none  \
    --extra-args='console=ttyS0'  \
    --noreboot \
    --hvm \
    --force
     break
  else
    printf "\e[1;31m input error \e[0m\n " 
    exit 
  fi
  done
}
#=========================================================#
Clone_the_kvm_host()
{
 while :
 do
    Front-end-query  clone 
    Input_clone=$search_result ;unset search_result
    read -t 60 -p " Enter the New kvm hostname(hostname):" Input_clone1
    if [[ -z "$Input_clone1" ]];then
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$Input_clone1" == "R" ]]||[[ "$Input_clone1" == "r" ]];then
          $Submenu_name && unset Input_clone && break
    elif [[ "$Input_clone1" == "Q" ]]||[[ "$Input_clone1" == "q" ]];then
      exit
    elif [[ "$Input_clone1" == "RR" ]]||[[ "$Input_clone1" == "rr" ]];then
       main_menu &&  unset Input_clone && break
    elif [[ ! -z "$Input_clone" ]];then
      echo "    clone: ${list_name[${Input_clone}]} ---> ${Input_clone1} "
      disk_clone="`virsh dumpxml ${list_name[${Input_clone}]} 2>/dev/null|grep "source file="|awk -F "'" '{print$2}'`"
      unset Pid_schedule ;schedule &
      Pid_schedule=$! 
      virsh shutdown ${list_name[${Input_clone}]} 2>/dev/null >/dev/null
      sleep 10 
      virt-clone --connect qemu:///system --original ${list_name[${Input_clone}]} --name $Input_clone1 --file ${disk_clone%/*}/${Input_clone1}.qcow2   2>/dev/null >/dev/null
      End_schedule   >/dev/null 2>/dev/null  
      unset Input_clone
    fi
 done
}
#=========================================================#
change_model_host_xml()
{
  new_kvm_name="$1"
  new_mem_num="$2"
  new_kvm_cores="$3"
  new_kvm_threads="$4"
  #-------------------------------------
  model_xml_name="model_kvm.xml"
  new_memory="`echo $(($new_mem_num*1024*1024))`"
  old_uuid="`cat $model_xml_name|grep uuid|awk -F'[><]' '{print$3}'`"
  old_menory="`cat $model_xml_name|grep "memory"|awk -F'[ ><]' '{print$6}'`"
  old_kvm_name="`cat  $model_xml_name|awk -F'[><]' '/<name>/{print $3}'`"
  old_address="`cat $model_xml_name|awk -F"[']" '/address=/{print$2}'`"
  create_mac="`openssl rand -hex 3 | sed -r 's/..\B/&:/g'`"
  source_mac="`echo $old_address|awk -F":" '{print$1":"$2":"$3}'`"
  new_address="${source_mac}:${create_mac}"
  old_imge_dir_init="`cat $model_xml_name |awk -F"[']" '/<source.*file/{print$2}'`"
  new_imge_dir="`echo $old_imge_dir_init|sed "s/${old_kvm_name}/$new_kvm_name/g"`"
  #===================================
  cp $old_imge_dir_init $new_imge_dir
  #------------------------------------
  sed -i "/$old_uuid/d"  $model_xml_name
  sed -i "s/$old_menory/$new_memory/g"  $model_xml_name
  sed -i "s/$old_kvm_name/$new_kvm_name/g"  $model_xml_name
  sed -i "s/$old_address/$new_address/g"  $model_xml_name
  sed -i "s/sockets='.'/sockets='1'/g"  $model_xml_name
  sed -i "s/cores='.'/cores=\'$new_kvm_cores\'/g"  $model_xml_name
  sed -i "s/threads='.'/threads=\'$new_kvm_threads\'/g"  $model_xml_name
  #------------------------------------
  old_cores="`cat $model_xml_name|awk -F'[><]' '/<vcpu/{print$3}'`"
  new_cores="$((${new_kvm_cores}*${new_kvm_threads}))"
  old_conf="`cat $model_xml_name|awk '/<vcpu/{print}'`"
  new_conf="`cat $model_xml_name|awk '/<vcpu/{print}'|sed "s/$old_cores/$new_cores/g"`"
  sed -i "s@$old_conf@$new_conf@g" $model_xml_name
}
#=========================================================#
Create_host_quickly()
{
 while :
 do
    Front-end-query "choose a template" 
    Input_template=$search_result ;unset search_result
    if [[ ! -z "$Input_template" ]];then
      read -t 60 -p " Enter the created kvm host name :" Input_kvm_name
      [ "$Input_kvm_name" == "q" -o "$Input_kvm_name" == "Q" ] && break
      read -t 60 -p " Enter the created kvm host memory(G):" Input_kvm_mem 
      [ "$Input_kvm_mem" == "q" -o "$Input_kvm_mem" == "Q" ] && break
      read -t 60 -p " Enter the created kvm host cores:" Input_kvm_cores
      [ "$Input_kvm_cores" == "q" -o "$Input_kvm_cores" == "Q" ] && break
      read -t 60 -p " Enter the created kvm host threads :" Input_kvm_threads
      [ "$Input_kvm_threads" == "q" -o "$Input_kvm_threads" == "Q" ] && break
      read -t 60 -p " Enter the number of kvm hosts created:" Input_kvm_num
      if [[ ! -z $Input_kvm_name ]]&&[[ ! -z $Input_kvm_mem ]]&&[[ ! -z $Input_kvm_num ]] &&[[ ! -z $Input_kvm_cores ]]&&[[ ! -z $Input_kvm_threads ]];then
        unset Pid_schedule ;clear;clear;echo "      Creating host";schedule &
        Pid_schedule=$! ;Index=0
        for (( C=0;C<${Input_kvm_num};C++))
        do
          virsh dumpxml ${list_name[${Input_template}]} > model_kvm.xml 2>/dev/null
          if [[ ${Input_kvm_num} -gt 1 ]];then
           let  Index=$Index+1 
            while :
            do
               virsh list --all|grep "${Input_kvm_name}${Index}"  2>/dev/null >/dev/null
               if [[ $? -ne 0 ]];then
                 break
               else
                 let  Index=$Index+1
               fi
            done
            change_model_host_xml ${Input_kvm_name}${Index}  $Input_kvm_mem $Input_kvm_cores $Input_kvm_threads 
            mv model_kvm.xml /etc/libvirt/qemu/${Input_kvm_name}${Index}.xml
            virsh define /etc/libvirt/qemu/${Input_kvm_name}${Index}.xml >/dev/null && echo ok >/dev/null ||exit
          else
            change_model_host_xml ${Input_kvm_name} $Input_kvm_mem $Input_kvm_cores $Input_kvm_threads 
            mv model_kvm.xml /etc/libvirt/qemu/${Input_kvm_name}.xml
            virsh define /etc/libvirt/qemu/${Input_kvm_name}.xml  >/dev/null && echo ok >/dev/null ||exit
          fi
        done
        End_schedule >/dev/null 2>/dev/null ; unset Input_kvm_name Input_kvm_mem Input_kvm_cores Input_kvm_threads Input_kvm_num Index 
      fi
    fi
 done
}
#===================================================================================================================#
Start_kvm_hosts()
{ 
  while :
  do
    Front-end-query start 
    Input_start=$search_result ;unset search_result
    if [[ ! -z "$Input_start" ]];then  
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_start}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_start}]} 2>/dev/null >/dev/null
        Get_num=${#Stop_name_list[*]} 
        for((D=0;D<${Get_num};D++))        
        do
          Stop_name_list=(${Stop_name_list[*]})
          [[ ${Stop_name_list[$D]} == "${list_name[${Input_start}]}" ]] && unset Stop_name_list[$D]
         unset  Get_num; Get_num=${#Stop_name_list[*]} 
        done
      else
        echo -e "\033[31m  error!! The host is locked and cannot be start \033[0m"
        sleep 3
      fi 
      unset Input_start 
    else
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    fi
  done
}
#=========================================================#
Start_all_kvm_hosts()
{
 while :
 do
  confirm_operation  "starting all hosts"
  $confirm_fali >/dev/null ; $confirm_null  >/dev/null
  if [[ "$confirm" == "yes" ]];then 
  clear
  echo "     Starting all hosts" 
  unset Pid_schedule ;schedule &
  Pid_schedule=$! 
  kvm_all="`virsh list --all|grep -v Name|awk '{print $2}'|xargs`"
  for i in $kvm_all
  do
    Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=$i '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
    if [[ "${Locked_state}" != "true" ]];then
      virsh start $i 2>/dev/null >/dev/null
    fi
  done
  End_schedule >/dev/null 2>/dev/null
  clear;unset Stop_name_list[*]
  break
 fi
done
[ "$confirm" == "yes" ] && Executive_item get_host_ip_name
}
#=========================================================#
kvm_hosts_autostart()
{
  while :
  do
    Front-end-query "setting autostart"
    Input_autostart=$search_result ;unset search_result
    if [[ ! -z "$Input_autostart" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_autostart}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh autostart ${list_name[${Input_autostart}]} 2>/dev/null >/dev/null
        get_autostart_host_list[${#get_autostart_host_list[*]}]=${list_name[${Input_autostart}]}
        autostart_host_tmp="${get_autostart_host_list[@]}" && get_autostart_host_list=($autostart_host_tmp)
        Refresh_autostart_host="`echo ${get_autostart_host_list[@]}|tr ' ' '\n'|sort -u|tr '\n' ','`"
        sed -i "s/^Autostart_host=.*/Autostart_host=\"${Refresh_autostart_host}\"/g" $(dirname $0)/$(basename $0)
        . `dirname $0`/`basename $0` Manage_kvm_host
      else
        echo -e "\033[31m  error!! The host is locked and cannot be set to autostart \033[0m"
        sleep 3
      fi
      unset Input_autostart Locked_state 
    else
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    fi
  done
}

#=========================================================#
unset_kvm_autostart()
{
  while :
  do
    Front-end-query "unset autostart"
    Input_unset_autostart=$search_result ;unset search_result
    if [[ ! -z "$Input_unset_autostart" ]] && [[ ! -z "${list_name[${Input_unset_autostart}]}" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_unset_autostart}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh autostart --disable ${list_name[${Input_unset_autostart}]} 2>/dev/null >/dev/null
        cancel_host_settings="${list_name[${Input_unset_autostart}]}"
        cancel_id="`echo "${get_autostart_host_list[@]}" |awk -v A=$cancel_host_settings '{for(i=0;i<=NF;i++){if($i==A){print i}}}'`"
        [[ ${#get_autostart_host_list[*]} -eq 1 ]] && cancel_id=1; unset get_autostart_host_list[$(($cancel_id-1))]
        unset autostart_host_tmp Refresh_autostart_host
        autostart_host_tmp="${get_autostart_host_list[@]}" && get_autostart_host_list=($autostart_host_tmp)
        Refresh_autostart_host="`echo ${get_autostart_host_list[@]}|tr ' ' '\n'|sort -u|tr '\n' ','`"
        sed -i "s/^Autostart_host=.*/Autostart_host=\"${Refresh_autostart_host}\"/g" $(dirname $0)/$(basename $0)
        . `dirname $0`/`basename $0` Manage_kvm_host
      else
        echo -e "\033[31m  error!! The host is locked and autostart setting cannot be canceled \033[0m"
        sleep 3
      fi
      unset Input_unset_autostart 
    else
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    fi
  done
}

#=========================================================#
Shutdown_kvm_hosts()
{ 
 unset Stop_name_list[*]
  while :
  do
    Front-end-query  shutdown  
    Input_stop=$search_result;unset search_result Locked_state
    if [[ ! -z "$Input_stop" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_stop}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh shutdown ${list_name[${Input_stop}]} 2>/dev/null >/dev/null  
        Stop_name_list[${#Stop_name_list[*]}]=${list_name[${Input_stop}]} 
        virsh shutdown ${list_name[${Input_stop}]} 2>/dev/null >/dev/null
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be Shutdown \033[0m"
        sleep 3
      fi
       unset Input_stop Locked_state
    fi
  done
}
#=========================================================#
Shutdown_all_kvm_hosts()
{
while :
do
  confirm_operation  "shutting down all hosts"
  $confirm_fali >/dev/null ; $confirm_null  >/dev/null
  if [[ "$confirm" == "yes" ]];then
    clear
    echo "   Shutting down all hosts" 
    unset Pid_schedule ;schedule &
    Pid_schedule=$! 
    unset Stop_name_list[*] Locked_state
    kvm_all="`virsh list --all|grep -v Name|awk '{print $2}'|xargs`"
    for i in $kvm_all
    do
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${i} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh shutdown $i 2>/dev/null >/dev/null
        Stop_name_list[${#Stop_name_list[*]}]=$i
      fi
    done
    End_schedule >/dev/null 2>/dev/null
    clear
    break
  fi
done
[ "$confirm" == "yes" ] && Executive_item get_host_ip_name
}
#=========================================================#
Delete_kvm_host()
{
 while :
 do
    Front-end-query  delete 
    Input_delete=$search_result;unset search_result Locked_state
    if [[ ! -z "$Input_delete" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_delete}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then 
        virsh start ${list_name[${Input_delete}]} 2>/dev/null >/dev/null
        disk_delete="`virsh dumpxml ${list_name[${Input_delete}]} 2>/dev/null|grep "source file="|awk -F "'" '{print$2}'`"
        disk_delete1="` virsh dumpxml ${list_name[${Input_delete}]} 2>/dev/null|grep "source mode="|awk -F"[=']" '{print$6}'`"
        virsh destroy ${list_name[${Input_delete}]} 2>/dev/null >/dev/null
        virsh undefine  ${list_name[${Input_delete}]} 2>/dev/null >/dev/null
        rm -rf ${disk_delete%/*}/${list_name[${Input_delete}]}.qcow2 && rm -rf "${disk_delete1}"
        rm -rf ${disk_delete%/*}/${list_name[${Input_delete}]}_*.qcow2 
        rm -rf /var/lib/libvirt/qemu/domain-*-${list_name[${Input_delete}]}
        rm -rf /var/lib/libvirt/qemu/channel/target/domain-*-${list_name[${Input_delete}]}
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be delete \033[0m"
        sleep 3
      fi 
      unset Input_delete
    fi
 done
}
#=========================================================#
rename_kvm_host()
{
 while :
 do
    Front-end-query rename 
    Input_rename=$search_result;unset search_result
    read -t 60 -p " Enter the new kvm hostname:" Input_rename_new
    if [[ -z $Input_rename_new ]];then
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$Input_rename_new" == "R" ]]||[[ "$Input_rename_new" == "r" ]];then
          $Submenu_name && unset Input_rename Input_rename_new && break
    elif [[ "$Input_rename_new" == "Q" ]]||[[ "$Input_rename_new" == "q" ]];then
      exit
    elif [[ "$Input_rename_new" == "RR" ]]||[[ "$Input_rename_new" == "rr" ]];then
      main_menu && unset Input_rename Input_rename_new && break
    elif [[ ! -z "$Input_rename" ]]&&[[ ! -z $Input_rename_new ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_rename}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_rename}]} 2>/dev/null >/dev/null
        virsh dumpxml ${list_name[${Input_rename}]} > rename_kvm.xml    2>/dev/null
        virsh destroy ${list_name[${Input_rename}]} 2>/dev/null >/dev/null
        virsh undefine  ${list_name[${Input_rename}]} 2>/dev/null >/dev/null
        rename_new_kvm_name="$Input_rename_new"
        rename_xml_name="rename_kvm.xml"
        rename_old_kvm_name="`cat  $rename_xml_name|awk -F'[><]' '/<name>/{print $3}'`"
        rename_imge_dir="`cat $rename_xml_name |awk -F"[']" '/<source.*file/{print$2}'`"
        new_imge_dir="`echo $rename_imge_dir|sed "s/${rename_old_kvm_name}/$rename_new_kvm_name/g"`"
        #===================================
        mv $rename_imge_dir $new_imge_dir
        #------------------------------------
        sed -i "s/$rename_old_kvm_name/$rename_new_kvm_name/g"  $rename_xml_name
        #------------------------------------
        mv rename_kvm.xml /etc/libvirt/qemu/${rename_new_kvm_name}.xml
        virsh define /etc/libvirt/qemu/${rename_new_kvm_name}.xml >/dev/null && echo ok >/dev/null ||exit
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be change \033[0m"
        sleep 3
      fi
      unset Input_rename  Input_rename_new
    fi
 done
}
#=========================================#
Reset_kvm_host_memory()
{
 while :
 do
    Front-end-query "reset memory for" 
    Input_reset_mem=$search_result;unset search_result
    read -t 60 -p " Enter the new memory size:" Input_new_memory_size
    if [[ -z $Input_new_memory_size ]];then
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$Input_new_memory_size" == "R" ]]||[[ "$Input_new_memory_size" == "r" ]];then
          $Submenu_name && unset Input_reset_mem Input_new_memory_size && break
    elif [[ "$Input_new_memory_size" == "Q" ]]||[[ "$Input_new_memory_size" == "q" ]];then
      exit
    elif [[ "$Input_new_memory_size" == "RR" ]]||[[ "$Input_new_memory_size" == "rr" ]];then
      main_menu && unset Input_reset_mem Input_new_memory_size && break
    elif [[ ! -z "$Input_reset_mem" ]]&&[[ ! -z $Input_new_memory_size ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_reset_mem}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_reset_mem}]} 2>/dev/null >/dev/null
        virsh dumpxml ${list_name[${Input_reset_mem}]} > reset_mem_kvm.xml    2>/dev/null
        virsh destroy ${list_name[${Input_reset_mem}]} 2>/dev/null >/dev/null
        virsh undefine  ${list_name[${Input_reset_mem}]} 2>/dev/null >/dev/null
        set_new_memory=$Input_new_memory_size
        set_new_memory_xml_name="reset_mem_kvm.xml"
        reset_new_memory="`echo $(($set_new_memory*1024*1024))`"
        reset_old_menory="`cat $set_new_memory_xml_name|grep "memory"|awk -F'[ ><]' '{print$6}'`"
        #------------------------------------
        sed -i "s/$reset_old_menory/$reset_new_memory/g"  $set_new_memory_xml_name
        #------------------------------------
        mv reset_mem_kvm.xml /etc/libvirt/qemu/${list_name[${Input_reset_mem}]}.xml
        virsh define /etc/libvirt/qemu/${list_name[${Input_reset_mem}]}.xml >/dev/null && echo ok >/dev/null ||exit
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be change \033[0m"
        sleep 3
      fi
        unset Input_reset_mem Input_new_memory_size
    fi
 done
}
#===================================================================================================================#
kvm_host_add_disk()
{
 while :
 do
    Front-end-query "add disk for" 
    Input_add_disk_host=$search_result;unset search_result
    read -t 60 -p " Enter the new disk size(G):" Input_new_disk_size
    if [[ -z $Input_new_disk_size ]];then
      echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
    elif [[ "$Input_new_disk_size" == "R" ]]||[[ "$Input_new_disk_size" == "r" ]];then
          $Submenu_name && unset Input_add_disk_host Input_new_disk_size && break
    elif [[ "$Input_new_disk_size" == "Q" ]]||[[ "$Input_new_disk_size" == "q" ]];then
      exit
    elif [[ "$Input_new_disk_size" == "RR" ]]||[[ "$Input_new_disk_size" == "rr" ]];then
      main_menu && unset Input_add_disk_host Input_new_disk_size && break
    elif [[ ! -z "$Input_add_disk_host" ]]&&[[ ! -z $Input_new_disk_size ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_add_disk_host}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_add_disk_host}]} 2>/dev/null >/dev/null
        disk_suorce_dir="`virsh dumpxml ${list_name[${Input_add_disk_host}]} 2>/dev/null|grep "source file="|awk -F "'" '{print$2}'|head -1`"
        Check_size="` echo $Input_new_disk_size|grep "[0-9]$"|wc -L 2>/dev/null`"
        if [[ $Check_size -gt 0 ]];then
          Create_size=$Input_new_disk_size
        else
          echo "input error" && exit
        fi
        drive_name="`printf "%s " {a..z}`"
        drive_suffix=($drive_name)
        for((A=1;A<100;A++ ))
        do
         ls -f ${disk_suorce_dir%/*}/${list_name[${Input_add_disk_host}]}_$A.qcow2 2>/dev/null >/dev/null
         if [[ $? -ne 0 ]];then
           unset Add_new_disk_name add_drive_name ;add_drive_name="vd${drive_suffix[$A]}"
           Add_new_disk_name="${disk_suorce_dir%/*}/${list_name[${Input_add_disk_host}]}_$A.qcow2"
           break
         fi
        done
        qemu-img create -f qcow2 ${Add_new_disk_name} ${Create_size}G  2>/dev/null >/dev/null
        virsh attach-disk ${list_name[${Input_add_disk_host}]} ${Add_new_disk_name} ${add_drive_name} --live --cache=none --subdriver=qcow2 2>/dev/null >/dev/null
        virsh dumpxml ${list_name[${Input_add_disk_host}]} > add_disk_temp.xml
        bak_yml_name="/etc/libvirt/qemu/${list_name[${Input_add_disk_host}]}.xml-bak"
        [[ ! -f ${bak_yml_name} ]] && mv /etc/libvirt/qemu/${list_name[${Input_add_disk_host}]}.xml  ${bak_yml_name}
        virsh undefine ${list_name[${Input_add_disk_host}]} 2>/dev/null >/dev/null
        mv  add_disk_temp.xml /etc/libvirt/qemu/${list_name[${Input_add_disk_host}]}.xml
        virsh define /etc/libvirt/qemu/${list_name[${Input_add_disk_host}]}.xml  >/dev/null && echo ok >/dev/null ||exit
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be change \033[0m"
        sleep 3
      fi
      unset Input_add_disk_host Input_new_disk_size 
    fi
 done
}
#============================================================================================#
Host_add_network_card()
{
 while :
 do
    Front-end-query "add network card for" 
    Input_add_network_card=$search_result ;unset search_result
    if [[ ! -z "$Input_add_network_card" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_add_network_card}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_add_network_card}]} 2>/dev/null >/dev/null
        get_suorce_card="`virsh domiflist ${list_name[${Input_add_network_card}]} 2>/dev/null|awk '/:*:*:/{print $3}'|head -1`"
        get_suorce_type="`virsh domiflist ${list_name[${Input_add_network_card}]} 2>/dev/null|awk '/:*:*:/{print $2}'|head -1`"
        virsh attach-interface ${list_name[${Input_add_network_card}]}  --type ${get_suorce_type} --source ${get_suorce_card} 2>/dev/null >/dev/null 
        [[ $? -eq 0 ]] && virsh attach-interface ${list_name[${Input_add_network_card}]} --type ${get_suorce_type} --source ${get_suorce_card} --config 2>/dev/null >/dev/null 
        virsh dumpxml ${list_name[${Input_add_network_card}]} > add_card_temp.xml
        virsh undefine ${list_name[${Input_add_network_card}]} 2>/dev/null >/dev/null
        mv  add_card_temp.xml /etc/libvirt/qemu/${list_name[${Input_add_network_card}]}.xml
        virsh define /etc/libvirt/qemu/${list_name[${Input_add_network_card}]}.xml  >/dev/null && echo ok >/dev/null ||exit
        virsh shutdown ${list_name[${Input_add_network_card}]}2>/dev/null >/dev/null && virsh start ${list_name[${Input_add_network_card}]} 2>/dev/null >/dev/null
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be change \033[0m"
        sleep 3
      fi
        unset Input_add_network_card 
    fi
 done
}
#============================================================================================#
delete_network_card()
{
 while :
 do
    Front-end-query "delete network card for" 
    Input_del_network_card=$search_result ;unset search_result 
    if [[ ! -z "$Input_del_network_card" ]];then
      Locked_state="`echo "${get_lock_host_list[@]}"|awk -v A=${list_name[${Input_del_network_card}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
      if [[ "${Locked_state}" != "true" ]];then
        virsh start ${list_name[${Input_del_network_card}]} 2>/dev/null >/dev/null
        get_suorce_mac0="`virsh domiflist ${list_name[${Input_del_network_card}]} 2>/dev/null|awk '/:*:*:/{print $NF}'|awk 'NR>1'|xargs`"
        get_suorce_type0="`virsh domiflist ${list_name[${Input_del_network_card}]} 2>/dev/null|awk '/:*:*:/{print $2}'|awk 'NR>1'|xargs`"
        get_suorce_mac=($get_suorce_mac0);get_suorce_type=($get_suorce_type0)
        for ((D=0;D<${#get_suorce_mac[*]};D++))
        do
          virsh detach-interface ${list_name[${Input_del_network_card}]} --type ${get_suorce_type[$D]} --mac ${get_suorce_mac[$D]} --config  2>/dev/null >/dev/null
          arp -ne |grep -E "${get_suorce_mac[$D]}"|awk '{print $1}'|xargs -I {} arp -d {} 2>/dev/null
          arp -ne |grep -E "${get_suorce_mac[$D]}"|awk '{print $1}'|xargs -I {} arp -d {} 2>/dev/null
          arp -ne |grep -E "${get_suorce_mac[$D]}"|awk '{print $1}'|xargs -I {} arp -d {} 2>/dev/null
        done
        [[ ${#get_suorce_mac[*]} -ne 0 ]] && virsh shutdown ${list_name[${Input_del_network_card}]} 2>/dev/null >/dev/null
        echo -e "\n\033[36m  Deleting, please wait \033[0m"
        for ((X=0;X<100;X++))
        do
          sleep 1
          virsh list |grep "\<${list_name[${Input_del_network_card}]}\>" 2>/dev/null >/dev/null
          [[ $? -ne 0 ]] && break  
          [[ ${#get_suorce_mac[*]} -eq 0 ]] && break
        done
        virsh start ${list_name[${Input_del_network_card}]} 2>/dev/null >/dev/null 
      else
        echo -e "\n\033[31m  error!! The host is locked and cannot be change \033[0m"
        sleep 3
      fi
      unset Input_del_network_card get_suorce_mac0 get_suorce_mac get_suorce_type0 get_suorce_type 
      clear; get_host_ip_name
    fi
 done
}
#====================================================================================================#
Lock_kvm_host()
{
  while :
  do
    Front-end-query  lock 
    Input_lock=$search_result; unset search_result
    if [[ ! -z ${list_name[${Input_lock}]} ]];then
      lock_up="${list_name[${Input_lock}]}"
      lengh=${#get_lock_host_list[*]}
      for (( G=0;G<${lengh};G++))
      do
        reslut_search="`echo "${list_name[@]}"|awk -v A=${get_lock_host_list[${G}]} '{for(i=0;i<=NF;i++){if($i==A){print "true"}}}'|uniq`"
        [[ "$reslut_search" != "true" ]] && unset get_lock_host_list[${G}]
      done
      Refresh_lock_host="`echo ${get_lock_host_list[@]}|tr ' ' ','`"
      [[ ! -z "$lock_up" ]] && sed -i "s/^Lock_host=.*/Lock_host=\"${Refresh_lock_host},${lock_up}\"/g" $(dirname $0)/$(basename $0)
      . `dirname $0`/`basename $0` Manage_kvm_host
    fi
  done
}
#====================================================================================================#
Unlock_kvm_host()
{
while :
do
  Front-end-query  unlock 
  Input_unlock=$search_result; unset search_result
  if [[ ! -z "${list_name[${Input_unlock}]}" ]];then
    target_host="${list_name[${Input_unlock}]}"
    host_id="`echo "${get_lock_host_list[@]}" |awk -v A=$target_host '{for(i=0;i<=NF;i++){if($i==A){print i}}}'`"
    [[ ${#get_lock_host_list[*]} -eq 1 ]] && host_id=1
    unset get_lock_host_list[$(($host_id-1))];new_lock_list="`echo ${get_lock_host_list[@]}|tr ' ' ','`"
    sed -i "s/^Lock_host=.*/Lock_host=\"${new_lock_list}\"/g" $(dirname $0)/$(basename $0)
    . `dirname $0`/`basename $0` Manage_kvm_host
  fi
done
}
#===================================================================================================================#
Manage_kvm_host(){
  num_in1=3
  unset Submenu_name ;Submenu_name="$FUNCNAME"
  while :
  do
    clear
    Delimiter 60
    echo -e  "      management kvm host "
    Delimiter 60
    echo -e "       A.kvm host list"
    echo -e "       B.Login the host"
    echo -e "       C.Start kvm hosts"
    echo -e "       D.Shutdown kvm hosts "
    echo -e "       E.Clone the kvm host"
    echo -e "       F.Create a host manually"
    echo -e "       G.Quickly create a kvm host"
    echo -e "       H.Rename the kvm host"
    echo -e "       I.Reset kvm host memory"
    echo -e "       J.Add disk to kvm host"
    echo -e "       K.Add network card to kvm host"
    echo -e "       L.Delete network card"
    echo -e "       M.Delete kvm host"
    echo -e "       N.Lock the kvm host"
    echo -e "       O.Unlock the kvm host"
    echo -e "       P.Host settings autostart"
    echo -e "       S.Host unset autostart"
    echo -e "       R.To return main menu"
    echo -e "       T.Export host list"
    echo -e "       U.Change the default login port and password"
    echo -e "       Q.exit "
    echo -e "       remaining times:$num_in1"
    Delimiter 60
    read -t 60 -p " Please enter the operation (A/a):" Input0
    let num_in1=$num_in1-1
 
  case $Input0 in
  A|a)
      Executive_item get_host_ip_name
      ;;
   B|b)
       login_the_kvm_host 
      ;;
   C|c)
       Start_kvm_hosts 
      ;;
    D|d)
      Shutdown_kvm_hosts 
     ;;
    E|e)
      Clone_the_kvm_host
     ;;
    F|f)
      create_model_host
     ;;
    G|g)
      Create_host_quickly
     ;;
    H|h)
      rename_kvm_host
     ;;
    I|i)
      Reset_kvm_host_memory 
     ;;
    J|j)
      kvm_host_add_disk 
     ;;
    K|k)
      Host_add_network_card 
     ;;
    L|l)
      delete_network_card
     ;;
    M|m)
      Delete_kvm_host 
     ;;
    N|n)
      Lock_kvm_host
     ;;
    O|o)
      Unlock_kvm_host
     ;; 
    P|p)
     kvm_hosts_autostart
     ;;
    S|s)
     unset_kvm_autostart
     ;;
    R|r)
      main_menu 
     ;;
    T|t)
      Export_list_kvm
     ;;
    U|u)
      change_default_port_passwd
     ;;
    Q|q)
       exit
     ;;
    *)
     echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
     sleep 2
  esac
  if [ $num_in1 -lt 0 ];then
    exit
  fi
  done


}
#===================================================================================================================#

#================================main_do============================================================================#
#=========================================================#
main_menu(){
  [[ ! -z "$1" ]] && "$1"
  num_in=3;unset Submenu_name ;Submenu_name="$FUNCNAME"
  while :
  do
    clear 
    Delimiter 55
    Get_user_identity
    Delimiter 55
    echo -e  "       kvm integrated management script "
    echo -e "       A.kvm host list"
    echo -e "       B.Manage kvm host"
    echo -e "       C.Start all kvm hosts "
    echo -e "       D.Shutdown all kvm hosts"
    echo -e "       E.Online install kvm service"
    echo -e "       F.Offline install kvm service"
    echo -e "       G.Clear tool configuration"
    echo -e "       Q.exit "
    echo -e "       remaining times:$num_in"
    Delimiter 55
    read -t 60 -p " Please enter the operation (A/a):" Input0
    let num_in=$num_in-1
  #
    case $Input0 in
     A|a)
        Executive_item get_host_ip_name
        ;;
     B|b)
        Executive_item Manage_kvm_host
        ;;
      C|c)
         Start_all_kvm_hosts
       ;;
      D|d)
         Shutdown_all_kvm_hosts
       ;;
      E|e)
        Online_install_kvm
       ;;
      F|f)
        clear 
        Offline_install_kvm
       ;;
      G|g)
        Init_tools_config 
       ;;
      Q|q)
         exit
       ;;
      *)
       echo -e "\n\033[31m  error!! Please enter your operation \033[0m"
       Exit=1
       sleep 2
    esac
    if [ $num_in -lt 0 ];then
      exit
    fi
  done
}
#===================================================================================================================#

main_menu $1
#===================================================================================================================#
