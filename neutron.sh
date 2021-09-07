#!/bin/sh
source conf_color.sh
source conf_netCheck.sh
source conf_distro.sh
source conf_package.sh
source conf_cdr.sh
source conf_ipc.sh
source conf_file.sh
clear
check_hosts=$(hostnamectl | grep hostname | awk '{print $3}')
#pack=($check_packet)
net_check_1=(neutron-linuxbridge-agent)
net_check_2=(neutron-linuxbridge-agent)
check_net_1=($check_neutron_ops1)
check_net_2=($check_neutron_ops2)
echo "${B}${r}###################################### KONFIGURASI NEUTRON ####################################${R}"
while true
do
  echo  "${B}Instalasi Service Neutron :${R}"
  select opsi in "Providers Network" "Self-Service Network" "Keluar"
  do
    case $opsi in
      "Providers Network")
      echo "${B}${b}<--- Konfigurasi Providers Network --->${R}"
      if [[ ${check_net_1[@]} = ${net_check_1[@]} ]] || [[ ${check_net_2[@]} = ${net_check_2[@]} ]]
      then
        echo "${B}${r}Service Neutron sudah terinstall${R}"
        echo "${B}...Uninstall Service Neutron...${R}"
        echo -e "\n"
        apt remove --purge ${net_check_2[@]} -y
        echo "${B}...Uninstall Service Neutron Sukses...${R}"
      fi
      echo "${B}${r}<--- Install Service Neutron --->${R}"
      apt install neutron-linuxbridge-agent -y
      echo "${B}${r}...Install Service Neutron Sukses...${R}"
      echo "${B}${r}<--- Konfigurasi Service Neutron --->${R}"
      sed -i '/^\[DEFAULT\]/a auth_strategy \= keystone' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a service_plugins \=' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a core_plugin \= ml2' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a password \= '$admPWD'' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a username \= neutron' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a project_name \= service' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a user_domain_name \= Default' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a project_domain_name \= Default' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a auth_type \= password' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a memcached_servers \= controller:11211' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a auth_url \= http\:\/\/controller:5000' /etc/neutron/neutron.conf
      if [[ "${pack[@]}" = queen ]]
      then
        echo "Library..... ${pack[@]}"
        sed -i '/^\[keystone_authtoken\]/a auth_uri \= http\:\/\/controller\:5000' /etc/neutron/neutron.conf
      else
        echo "Library..... ${pack[@]}"
        sed -i '/^\[keystone_authtoken\]/a www_authenticate_uri \= http\:\/\/controller\:5000' /etc/neutron/neutron.conf
      fi
      sed -i '/^\[oslo_concurrency\]/a lock_path \= \/var\/lib\/neutron\/tmp' /etc/neutron/neutron.conf
      sed -i '/^\[linux_bridge\]/a physical_interface_mappings \= provider:'$ethManual'' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[vxlan\]/a enable_vxlan \= false' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[securitygroup\]/a enable_security_group \= true' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[securitygroup\]/a firewall_driver \= neutron\.agent\.linux\.iptables\_firewall\.IptablesFirewallDriver' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      modprobe br_netfilter
      if [[ "${pack[@]}" = train ]]
      then
        echo "Library..... ${pack[@]}"
        sed -i '/^\[neutron\]/a password \= '$admPWD'' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a username \= neutron' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_name \= service' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a region_name \= RegionOne' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a user_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_type \= password' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_url = http://controller:5000' /etc/nova/nova.conf
      else
        echo "Library..... ${pack[@]}"
        sed -i '/^\[neutron\]/a password \= '$admPWD'' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a username \= neutron' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_name \= service' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a region_name \= RegionOne' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a user_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_type \= password' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_url = http://controller:5000' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a url = http://controller:9696' /etc/nova/nova.conf
      fi
      echo "${B}...Restart Service Nova-Compute...${R}"
      service nova-compute restart
      echo "${B}...Restart Service Neutron...${R}"
      service neutron-linuxbridge-agent restart
      break 2
      ;;
      "Self-Service Network")
      echo "${B}${b}<--- Konfigurasi Self-Service Network --->${R}"
      if [[ ${check_net_2[@]} = ${net_check_2[@]} ]] || [[ ${check_net_1[@]} = ${net_check_1[@]} ]]
      then
        echo "${B}${r}Service Neutron sudah terinstall${R}"
        echo "${B}...Uninstall Service Neutron...${R}"
        echo -e "\n"
        apt remove --purge ${net_check_2[@]} -y
        echo "${B}...Uninstall Service Neutron Sukses...${R}"
      fi
      echo "${B}${r}<--- Install Service Neutron --->${R}"
      apt install neutron-linuxbridge-agent -y
      echo "${B}${r}...Install Service Neutron Sukses...${R}"
      echo "${B}${r}<--- Konfigurasi Service Neutron --->${R}"
      sed -i '/^\[DEFAULT\]/a auth_strategy \= keystone' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a service_plugins \=' /etc/neutron/neutron.conf
      sed -i '/^\[DEFAULT\]/a core_plugin \= ml2' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a password \= '$admPWD'' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a username \= neutron' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a project_name \= service' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a user_domain_name \= Default' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a project_domain_name \= Default' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a auth_type \= password' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a memcached_servers \= controller:11211' /etc/neutron/neutron.conf
      sed -i '/^\[keystone_authtoken\]/a auth_url \= http\:\/\/controller:5000' /etc/neutron/neutron.conf
      if [[ "${pack[@]}" = queen ]]
      then
        echo "Library..... ${pack[@]}"
        sed -i '/^\[keystone_authtoken\]/a auth_uri \= http\:\/\/controller\:5000' /etc/neutron/neutron.conf
      else
        echo "Library..... ${pack[@]}"
        sed -i '/^\[keystone_authtoken\]/a www_authenticate_uri \= http\:\/\/controller\:5000' /etc/neutron/neutron.conf
      fi
      sed -i '/^\[oslo_concurrency\]/a lock_path \= \/var\/lib\/neutron\/tmp' /etc/neutron/neutron.conf
      sed -i '/^\[linux_bridge\]/a physical_interface_mappings \= provider:'$ethManual'' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[vxlan\]/a l2_population \= true' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[vxlan\]/a local_ip \= '$ipm1'' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[vxlan\]/a enable_vxlan \= true' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[securitygroup\]/a enable_security_group \= true' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      sed -i '/^\[securitygroup\]/a firewall_driver \= neutron\.agent\.linux\.iptables\_firewall\.IptablesFirewallDriver' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
      modprobe br_netfilter
      if [[ "${pack[@]}" = train ]]
      then
        echo "Library..... ${pack[@]}"
        sed -i '/^\[neutron\]/a password \= '$admPWD'' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a username \= neutron' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_name \= service' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a region_name \= RegionOne' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a user_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_type \= password' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_url = http://controller:5000' /etc/nova/nova.conf
      else
        echo "Library..... ${pack[@]}"
        sed -i '/^\[neutron\]/a password \= '$admPWD'' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a username \= neutron' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_name \= service' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a region_name \= RegionOne' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a user_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a project_domain_name \= Default' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_type \= password' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a auth_url = http://controller:5000' /etc/nova/nova.conf
        sed -i '/^\[neutron\]/a url = http://controller:9696' /etc/nova/nova.conf
      fi
      echo "${B}...Restart Service Nova-Compute...${R}"
      service nova-compute restart
      echo "${B}...Restart Service Neutron...${R}"
      service neutron-linuxbridge-agent restart
      break 2
      ;;
      "Keluar")
      break 2
      ;;
      *)
      echo "Pilih 1-2..."
      ;;
    esac
  done
done
