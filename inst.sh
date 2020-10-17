#!/bin/bash

###
### DO *NOT* RUN THIS SCRIPT DIRECTLY! RUN BOOTSTRAP.SH FROM OFF OF AN HTTP SERVER!
###

timedatectl set-ntp true

export DISK=/dev/sda
#export WEBROOT=http://192.168.1.3
export USERNAME=jenn
export PASSWORD=jenn
export ROOTPASS=jenn
export hostname=jennhp-arch
export AUR_PKGS="plymouth google-chrome ttf-ms-fonts ttf-vista-fonts ttf-ancient-fonts ttf-twemoji ttf-symbola"
export PACKAGES="base linux linux-firmware grub cinnamon xed xreader vlc lxdm xorg-server gnome-notes sudo git base-devel pulseaudio mesa xf86-video-amdgpu nano efibootmgr dhcpcd networkmanager noto-fonts ttf-droid gnu-free-fonts ttf-liberation ttf-cascadia-code ttf-arphic-uming ttf-indic-otf"

echo -e "\e[93m== Partitioning $DISK ==\e[0m"

# for debugging
umount ${DISK}*
swapoff ${DISK}2

sgdisk --zap-all $DISK
fdisk $DISK -w always -W always <<EOF
g
n


+512M
t
1
n


+2G
t

19
n



w
EOF
# partition map:
# /dev/sda1 EFI
# /dev/sda2 SWAP
# /dev/sda3 BTRFS
#exit
#
echo -e "\e[93m== Formatting $DISK ==\e[0m"
# format
mkswap ${DISK}2 -f
mkfs.btrfs ${DISK}3 -f
mkfs.fat -F32 ${DISK}1
# mount
swapon ${DISK}2
mount ${DISK}3 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

#echo -e "\e[93m== Finding fastest mirrors... (this may take 1-2 min.) ==\e[39m"
#
#yes '
#' | pacman -Sy --needed pacman-contrib sudo

#curl ${WEBROOT}/rankmirrors.sh 2>/dev/null | sh

echo -e "\e[93m== Installing packages ==\e[0m"

pacman -Sy
pacstrap /mnt $PACKAGES

echo -e "\e[93m== Configuring system ==\e[0m"

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    export LANG=en_US.UTF-8
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
    hwclock --systohc
    echo $hostname > /etc/hostname
    sed -i "/localhost/s/$/ $hostname/" /etc/hosts
    echo "root:${ROOTPASS}" | chpasswd
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable lxdm
    useradd -mG wheel,disk,input,scanner,video $USERNAME
    echo "${USERNAME}:${PASSWORD}" | chpasswd
EOF

echo -e "\e[93m== Installing AUR packages ==\e[0m"


arch-chroot /mnt /bin/bash <<EOF
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    su $USERNAME <<EOG
        cd ~
        git clone https://aur.archlinux.org/yay.git yay
        cd yay
        yes '' | makepkg -si
        cd ..
        rm -rf yay
        yes '' | yay -S $AUR_PKGS
EOG
EOF

echo -e "\e[93m== Rebooting ==\e[0m"
umount -R /mnt
reboot