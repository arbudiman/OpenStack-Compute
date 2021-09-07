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
cin_check=(cinder-volume)
check_cin=($check_cinder)
echo  "${B}Konfigurasi LVM Storage :${R}"
apt install lvm2 thin-provisioning-tools -y
storage=$(ls /dev | grep sd | awk '{print $1}')
dev=($storage)
echo "Pilih storage"
select reply in "${dev[@]}"
do
  [ -n "${reply}" ] && break
done
echo "Storage yang dipilih untuk cinder ${reply}"
pvcreate /dev/${reply}
vgcreate cinder-volumes /dev/${reply}
sed -i -e '/^devices.*/a     filter \= \[ \"a\/'${reply}'\/\"\, \"r\/\.\*\/\"\]' /etc/lvm/lvm.conf
echo  "${B}Instalasi Service Cinder Volume :${R}"
if [[ ${check_cin[@]} = ${cin_check[@]} ]]
then
  echo "${B}${r}Service Cinder sudah terinstall${R}"
  echo "${B}...Uninstall Service cinder...${R}"
  echo -e "\n"
  apt remove --purge ${cin_check[@]} -y
  echo "${B}...Uninstall Service Cinder Sukses...${R}"
fi
apt install cinder-volume -y
echo "${B}${r}...Install Service Cinder Volume Sukses...${R}"
echo "${B}${r}<--- Konfigurasi Service Cinder --->${R}"
check_db1=$(cat /etc/cinder/cinder.conf | grep 'connection = sqlite' | awk '{ print $1 $2 $3; exit}')
check_db2=$(cat /etc/cinder/cinder.conf | grep 'auth_strategy = keystone' | awk '{ print $1 $2 $3; exit}')
if [[ -n ${check_db1[@]} ]]
then
  sed -i -e 's/connection = sqlite/#&/' /etc/cinder/cinder.conf #menambahkan teks
  sed -i '/^\[database\]/a connection \= mysql\+pymysql\:\/\/cinder\:'$dbPWD'\@controller\/cinder' /etc/cinder/cinder.conf
else
  sed -i '/\[database\]/a connection \= mysql\+pymysql\:\/\/cinder\:'$dbPWD'\@controller\/cinder' /etc/cinder/cinder.conf
fi
if [[ -n ${check_db2[@]} ]]
then
  sed -i -e 's/auth_strategy = keystone/#&/' /etc/cinder/cinder.conf #menambahkan teks
  sed -i '/^verbose/a auth_strategy \= keystone' /etc/cinder/cinder.conf
else
  sed -i '/^verbose/a auth_strategy \= keystone' /etc/cinder/cinder.conf
fi
sed -i '/^\[DEFAULT\]/a glance_api_servers = http://controller:9292' /etc/cinder/cinder.conf
sed -i '/^\[DEFAULT\]/a enabled_backends = lvm' /etc/cinder/cinder.conf
sed -i '/^\[DEFAULT\]/a my_ip = '$iphosts'' /etc/cinder/cinder.conf
sed -i '/^\[DEFAULT\]/a auth_strategy = keystone' /etc/cinder/cinder.conf
sed -i '/^\[DEFAULT\]/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller' /etc/cinder/cinder.conf
#sed -i '/^api_paste_confg/a transport_url \= rabbit\:\/\/openstack\:'$rabPWD'\@controller' /etc/cinder/cinder.conf
echo -e "\n" >> /etc/cinder/cinder.conf
echo "[keystone_authtoken]" >> /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a password \= '$admPWD'' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a username \= cinder' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a project_name \= service' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a user_domain_name \= Default' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a project_domain_name \= Default' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a auth_type \= password' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a memcached_servers \= controller:11211' /etc/cinder/cinder.conf
sed -i '/^\[keystone_authtoken\]/a auth_url \= http\:\/\/controller:5000' /etc/cinder/cinder.conf
if [[ "${pack[@]}" = queen ]]
then
  echo "Library..... ${pack[@]}"
  sed -i '/^\[keystone_authtoken\]/a auth_uri \= http\:\/\/controller\:5000' /etc/cinder/cinder.conf
else
  echo "Library..... ${pack[@]}"
  sed -i '/^\[keystone_authtoken\]/a www_authenticate_uri \= http\:\/\/controller\:5000' /etc/cinder/cinder.conf
fi
echo -e "\n" >> /etc/cinder/cinder.conf
echo "[oslo_concurrency]" >> /etc/cinder/cinder.conf
sed -i '/^\[oslo_concurrency\]/a lock_path \= \/var\/lib\/cinder\/tmp' /etc/cinder/cinder.conf

echo -e "\n" >> /etc/cinder/cinder.conf
echo "[lvm]" >> /etc/cinder/cinder.conf
sed -i '/^\[lvm\]/a target\_helper \= tgtadm' /etc/cinder/cinder.conf
sed -i '/^\[lvm\]/a target\_protocol \= iscsi' /etc/cinder/cinder.conf
sed -i '/^\[lvm\]/a volume\_group \= cinder\-volumes' /etc/cinder/cinder.conf
sed -i '/^\[lvm\]/a volume\_driver \= cinder\.volume\.drivers\.lvm\.LVMVolumeDriver' /etc/cinder/cinder.conf

service tgt restart
service cinder-volume restart
