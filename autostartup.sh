#!/bin/bash

#Set Timezone
if [[ -z "${TZ}" ]]; then
   ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
else
   ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
fi

#CREATE USERS.
# username:passsword:Y
# username2:password2:Y

file="/root/createusers.txt"
if [ -f $file ]
  then
    while IFS=: read -r username password is_sudo
        do
            echo "Username: $username, Password: $password , Sudo: $is_sudo"

            if getent passwd $username > /dev/null 2>&1
              then
                echo "User Exists"
              else
                useradd -ms /bin/bash $username
                usermod -aG audio $username
                usermod -aG input $username
                usermod -aG video $username
                mkdir -p /run/user/$(id -u $username)/dbus-1/
                chmod -R 700 /run/user/$(id -u $username)/
                chown -R "$username" /run/user/$(id -u $username)/
                echo "$username:$password" | chpasswd
                if [ "$is_sudo" = "Y" ]
                  then
                    usermod -aG sudo $username
                fi
            fi
    done <"$file"
fi

startfile="/root/startup.sh"
if [ -f $startfile ]
  then
    sh $startfile
fi

echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/locale" >> /etc/profile

# Create the PrivSep empty dir if necessary
if [ ! -d /run/sshd ]; then
   mkdir /run/sshd
   chmod 0755 /run/sshd
fi

#This has to be the last command!
/usr/bin/supervisord -n
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    sudo apt-key add -curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.listsudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    sudo docker run --gpus all nvidia/cuda:10.0-base nvidia-smi
