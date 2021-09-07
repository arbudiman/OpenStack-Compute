#!/bin/sh
source conf_color.sh
source conf_netCheck.sh
source conf_distro.sh
source conf_package.sh
source conf_cdr.sh
source conf_ipc.sh
while true
do
  echo  "${B}Instalasi Service Openstack :${R}"
  select opsi in "Compute" "Neutron" "Storage" "Keluar"
  do
    case $opsi in
      "Compute")
      source nova.sh
      break
      ;;
      "Neutron")
      source neutron.sh
      break
      ;;
      "Storage")
      source cinder.sh
      break
      ;;
      "Keluar")
      break 3
      ;;
      *)
      echo "Opsi Pilihan 1-4...."
      ;;
    esac
  done
done
