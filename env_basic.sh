#!/bin/sh
source conf_color.sh
source conf_netCheck.sh
source conf_distro.sh
source conf_package.sh
source conf_cdr.sh
source conf_ipc.sh
chrony=($check_chrony)
soft=($check_software)
repository=($check_repository)
lib_openstack=($check_library)
mariadb=($check_mariadb)
pymysql=($check_pymysql)
rabbitmq=($check_rabbitmq)
memcached=($check_memcached)
memcache=($check_memcache)
etcd=($check_etcd)
pack=($check_packet)
#echo -e "\n"
while true
do
  echo  "${B}Instalasi Environment Openstack :${R}"
  select konfig in "Chrony" "Repository Openstack" "Openstack Client" "Keluar"
  do
    case $konfig in
      "Chrony")
      echo "${B}Cek Paket Chrony${R}"
      if [[ -n ${chrony[@]} ]]
      then
        echo "${B}${r}Paket Chrony sudah terinstall${R}"
        echo "...Uninstall paket Chrony..."
        echo
        apt remove --purge ${chrony[@]} -y
      fi
      echo
      echo "${B}Paket Chrony belum terinstall${R}"
      echo "...Install  paket Chrony..."
      apt install chrony -y
      cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori
      sed -i -e 's/^pool/#&/' /etc/chrony/chrony.conf #menambahkan teks
      cek2=$(cat /etc/chrony/chrony.conf | grep pool | awk '/^#pool/{ print $1 $2 }')
      ln=$(awk '/^#pool/{ print NR; exit }' /etc/chrony/chrony.conf) #line number dgn teks tertentu
      sed -i -e ''$ln' i\server controller iburst' /etc/chrony/chrony.conf
      #sed -i -e ''$ln' i\server 0.id.pool.ntp.org iburst' /etc/chrony/chrony.conf
      #ln2=$(awk '/^keyfile/{ print NR; exit }' /etc/chrony/chrony.conf)
      #allow="$net/$pref"
      #sed -i -e ''$ln2' i\allow '$allow'' /etc/chrony/chrony.conf
      systemctl restart chrony
      systemctl enable chrony
      systemctl start chrony
      chronyc sources
      break
      ;;
      "Repository Openstack")
      echo "${B}Cek Software-Common-Properties${R}"
      if [[ -n ${soft[@]} ]]
      then
        echo "${B}${r}Software-Properties-Common sudah di install...${R} "
        apt purge --auto-remove ${soft[@]} -y
      fi
      echo "${B}${b}Re-install Software Properties Common...${R}"
      apt install software-properties-common -y
      echo
      apt update -y
      echo "Menambahkan Repository Openstack"
      if [[ "$id_versi" = 18.04 ]]
      then
        echo "${B}Cek Repository Openstack${R}"
        if [[ -n ${repository[@]} ]]
        then
          echo "${B}${r}Repository Openstack sudah ada...${R} "
          echo "...Hapus Repository Openstack..."
          echo
          rm -f /etc/apt/sources.list.d/cloudarchive*
          apt remove --purge ubuntu-cloud-keyring -y
          echo
        fi
        select repo in "Rocky" "Stein" "Train" "Keluar"
        do
          case $repo in
            "Rocky")
            echo "${B}Menambahkan Repository Openstack Rocky${R}"
            add-apt-repository cloud-archive:rocky
            echo
            break
            ;;
            "Stein")
            echo "${B}Menambahkan Repository Openstack Stein${R}"
            add-apt-repository cloud-archive:stein
            echo
            break
            ;;
            "Train")
            echo "${B}Menambahkan Repository Openstack Train${R}"
            add-apt-repository cloud-archive:train
            echo
            break
            ;;
            "Keluar")
            break 2
            ;;
            *)
            echo "Pilih 1-4..."
            ;;
          esac
        done
      else
        echo
        echo "${B}Menambahkan Repository Openstack Queens${R}"
        add-apt-repository cloud-archive:queens
      fi
      echo "${B}Update System...${R}"
      apt update && apt dist-upgrade -y
      echo
      break
      ;;
      "Openstack Client")
      echo "${B}Install Library Openstack Client${R}"
      if [[ "$id_versi" = 18.04 ]]
      then
        echo "${B}Cek Library Openstack${R}"
        if [[ -n ${lib_openstack[@]} ]]
        then
          echo "${B}${r}Library Openstack sudah terinstall${R}"
          echo "...Uninstall Library Openstack..."
          echo
          apt purge --auto-remove ${lib_openstack[@]} -y
        fi
        echo
        echo "Pilih Library Openstack Client"
        if [[ "${pack[@]}" = rocky ]]
        then
          echo "Install Library Openstack ${pack[@]}"
          apt install python3-openstackclient -y
          echo
          break
        elif [[ "${pack[@]}" = stein ]]
        then
          echo "Install Library Openstack Stein ${pack[@]}"
          apt install python3-openstackclient -y
          echo
        else
          echo "Install Library Openstack ${pack[@]}"
          apt install python3-openstackclient -y
          echo
          break
        fi
      else
        echo
        echo "Install Library Openstack Queens"
        apt install python3-openstackclient -y
      fi
      break
      ;;
      "Keluar")
      break 3
      ;;
      *)
      echo "Opsi Pilihan 1-3...."
      ;;
    esac
  done
done
echo "Lanjut...."
