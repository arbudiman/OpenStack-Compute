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
pack=($check_packet)
nov_check=(nova-compute)
check_nov=($check_nova)
check_apc=($check_apache)
check_lib_apc=($check_lib_apache)
echo "${B}${r}###################################### KONFIGURASI COMPUTE ####################################${R}"
if [[ ${check_nov[@]} = ${nov_check[@]} ]]
then
  echo "${B}${r}Service nova compute sudah terinstall${R}"
  echo "${B}...Uninstall Service nova compute...${R}"
  echo -e "\n"
  apt remove --purge ${check_nov[@]} -y
  echo "${B}...Uninstall Service nova compute Sukses...${R}"
fi
echo "${B}${r}Install Service Nova Compute${R}"
if [[ "${pack[@]}" = queen ]] || [[ "${pack[@]}" = rocky ]]
then
  echo "Library.. ${pack[@]}"
  apt install nova-compute -y
elif [[ "${pack[@]}" = stein ]]
then
  echo "Library.. ${pack[@]}"
  apt install nova-compute -y
else
  echo "Library.. ${pack[@]}"
  apt install nova-compute -y
fi
echo "${B}${r}Install Service Nova Compute${R}"
sed -i '/^\[DEFAULT\]/a firewall_driver \= nova\.virt\.firewall\.NoopFirewallDriver' /etc/nova/nova.conf
sed -i '/^\[DEFAULT\]/a use_neutron \= true' /etc/nova/nova.conf
sed -i '/^\[DEFAULT\]/a my_ip \= '$iphosts'' /etc/nova/nova.conf
if [[ "${pack[@]}" = train ]]
then
  echo "Library.... ${pack[@]}"
  sed -i '/^\[DEFAULT\]/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller:5672' /etc/nova/nova.conf
else
  echo "Library.... ${pack[@]}"
  sed -i '/^\[DEFAULT\]/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller' /etc/nova/nova.conf
fi
sed -i '/^\[api\]/a auth_strategy \= keystone' /etc/nova/nova.conf
if [[ "${pack[@]}" = train ]]
then
  echo "Library..... ${pack[@]}"
  sed -i '/^\[keystone_authtoken\]/a password \= '$admPWD'' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a username \= nova' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a project_name \= service' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a user_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a project_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a auth_type \= password' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a memcached_servers \= controller:11211' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a auth_url \= http\:\/\/controller:5000\/' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a www_authenticate_uri \= http\:\/\/controller\:5000\/' /etc/nova/nova.conf
else
  echo "Library..... ${pack[@]}"
  sed -i '/^\[keystone_authtoken\]/a password \= '$admPWD'' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a username \= nova' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a project_name \= service' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a user_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a project_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a auth_type \= password' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a memcached_servers \= controller:11211' /etc/nova/nova.conf
  sed -i '/^\[keystone_authtoken\]/a auth_url \= http\:\/\/controller:5000\/' /etc/nova/nova.conf
fi
sed -i '/^\[vnc\]/a novncproxy_base_url \= http\:\/\/controller\:6080\/vnc\_auto\.html' /etc/nova/nova.conf
sed -i '/^\[vnc\]/a server_proxyclient_address \= $my_ip' /etc/nova/nova.conf
sed -i '/^\[vnc\]/a server_listen \= 0.0.0.0' /etc/nova/nova.conf
sed -i '/^\[vnc\]/a enabled \= true' /etc/nova/nova.conf
sed -i '/^\[glance\]/a api_servers \= http\:\/\/controller\:9292' /etc/nova/nova.conf
sed -i '/^\[oslo_concurrency\]/a lock_path \= \/var\/lib\/nova\/tmp' /etc/nova/nova.conf
if [[ "${pack[@]}" = queen ]]
then
  echo "Library...... ${pack[@]}"
  sed -i '/^\[placement\]/a password \= '$admPWD'' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a username \= placement' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a auth_url \= http\:\/\/controller\:5000\/v3' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a user_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a auth_type \= password' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a project_name \= service' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a project_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a os_region_name \= RegionOne' /etc/nova/nova.conf
else
  echo "Library...... ${pack[@]}"
  sed -i '/^\[placement\]/a password \= '$admPWD'' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a username \= placement' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a auth_url \= http\:\/\/controller\:5000\/v3' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a user_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a auth_type \= password' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a project_name \= service' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a project_domain_name \= Default' /etc/nova/nova.conf
  sed -i '/^\[placement\]/a region_name \= RegionOne' /etc/nova/nova.conf
fi
echo "${B}${r}<--- Konfigurasi Service Nova Compute Sukses... --->${R}"
egrep -c '(vmx|svm)' /proc/cpuinfo
echo "${B}${r}.... Restart Service Nova Compute....${R}"
systemctl restart nova-compute
