#!/bin/bash
echo 'installing stuff'
echo "deb http://deb.debian.org/debian stretch main contrib non-free
deb http://deb.debian.org/debian stretch-updates main contrib non-free
deb http://deb.debian.org/debian-security stretch/updates main contrib non-free
deb [arch=armhf] http://repos.rcn-ee.com/debian/ stretch main
deb http://ftp.de.debian.org/debian sid main " > /etc/apt/sources.list

apt-get update
apt-get remove man-db
apt-get install cmake wget nano build-essential git zlib1g-dev python-dev python-smbus python-pip python-imaging python-numpy midori matchbox x11-xserver-utils unclutter sysv-rc-conf xloadimage mplayer ffmpeg autofs pmount usbmount -y

echo 'Installing Poco Lib. This will take a looooooong time. You\'ll need a huge supply of covfefe...'
git clone -b master https://github.com/pocoproject/poco.git /root/poco
cd /root/poco
./configure --omit=NetSSL_OpenSSL,Crypto,Data/ODBC,Data/MySQL
make -s -j4
make install

echo '# Configuration file for the usbmount package, which mounts removable
# storage devices when they are plugged in and unmounts them when they
# are removed.

# Change to zero to disable usbmount
ENABLED=1

# Mountpoints: These directories are eligible as mointpoints for
# removable storage devices.  A newly plugged in device is mounted on
# the first directory in this list that exists and on which nothing is
# mounted yet.
MOUNTPOINTS="/media/usb0"

# Filesystem types: removable storage devices are only mounted if they
# contain a filesystem type which is in this list.
FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus"

#############################################################################
# WARNING!                                                                  #
#                                                                           #
# The "sync" option may not be a good choice to use with flash drives, as   #
# it forces a greater amount of writing operating on the drive. This makes  #
# the writing speed considerably lower and also leads to a faster wear out  #
# of the disk.                                                              #
#                                                                           #
# If you omit it, don't forget to use the command "sync" to synchronize the #
# data on your disk before removing the drive or you may experience data    #
# loss.                                                                     #
#                                                                           #
# It is highly recommended that you use the pumount command (as a regular   #
# user) before unplugging the device. It makes calling the "sync" command   #
# and mounting with the sync option unnecessary---this is similar to other  #
# operating system's "safely disconnect the device" option.                 #
#############################################################################
# Mount options: Options passed to the mount command with the -o flag.
# See the warning above regarding removing "sync" from the options.
MOUNTOPTIONS="sync,noexec,nodev,noatime,nodiratime"

# Filesystem type specific mount options: This variable contains a space
# separated list of strings, each which the form "-fstype=TYPE,OPTIONS".
#
# If a filesystem with a type listed here is mounted, the corresponding
# options are appended to those specificed in the MOUNTOPTIONS variable.
#
# For example, "-fstype=vfat,gid=floppy,dmask=0007,fmask=0117" would add
# the options "gid=floppy,dmask=0007,fmask=0117" when a vfat filesystem
# is mounted.
FS_MOUNTOPTIONS="-fstype=vfat,gid=users,dmask=0007,fmask=0117"

# If set to "yes", more information will be logged via the syslog
# facility.
VERBOSE=no' > /etc/usbmount/usbmount.conf

echo 'disable apache2'
update-rc.d apache2 disable

echo 'Installing NodeJS'
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
source ~/.bashrc
nvm install node

echo 'Installing BeagleBoom'

cd ~
rm -R BeagleBoom
mkdir BeagleBoom

cd ~/BeagleBoom/
git clone --depth=1 git@github.com:BeagleBoom/BeagleQueue.git eventqueue
cd ~/BeagleBoom/eventqueue
cmake .
make
make install


echo 'Installing BeagleBoom ADCManager & Overlays'
cd ~/BeagleBoom/
git clone --depth=1 git@github.com:BeagleBoom/ADCManager.git adc
echo "export PRU_CGT=/usr/share/ti/cgt-pru" >> /root/.bashrc
export PRU_CGT=/usr/share/ti/cgt-pru
cp -r ~/BeagleBoom/adc/pru/demos/pru-software-support-package/include $PRU_CGT/includeSupportPackage
cp ~/BeagleBoom/adc/pru/demos/pru-software-support-package/lib/rpmsg_lib.lib $PRU_CGT/lib
cd ~/BeagleBoom/adc/pru/src
make
cd ~/BeagleBoom/adc/
cmake .
make
cd ~/BeagleBoom/adc/pru/overlay
chmod +x build.sh 
./build.sh

echo 'Installing BeagleBoom Inputs'
cd ~/BeagleBoom/
git clone --depth=1 git@github.com:BeagleBoom/Inputs.git

cd ~/BeagleBoom/inputs
cmake .
make


echo 'Installing BeagleBoom Menu'
cd ~/BeagleBoom/
npm install -g yarn
git clone --depth=1 git@github.com:BeagleBoom/Menu.git
cd ~/BeagleBoom/menu
yarn install --unsafe-perm
pm2 start index.js -- 1
pm2 save
pm2 startup


echo 'Enabling Overlays'

echo "
uname_r=$(uname -r)
dtb=am335x-boneblack-overlay.dtb
###U-Boot Overlays###
###Documentation: http://elinux.org/Beagleboard:BeagleBoneBlack_Debian#U-Boot_Overlays
###Master Enable
enable_uboot_overlays=1
###
###Overide capes with eeprom
uboot_overlay_addr0=/lib/firmware/BB-SPIDEV0-00A0.dtbo
#uboot_overlay_addr1=/lib/firmware/<file1>.dtbo
#uboot_overlay_addr2=/lib/firmware/<file2>.dtbo
#uboot_overlay_addr3=/lib/firmware/<file3>.dtbo
###
###Additional custom capes
#uboot_overlay_addr4=/lib/firmware/<file4>.dtbo
#uboot_overlay_addr5=/lib/firmware/<file5>.dtbo
#uboot_overlay_addr6=/lib/firmware/<file6>.dtbo
#uboot_overlay_addr7=/lib/firmware/<file7>.dtbo
###
###Custom Cape
dtb_overlay=/lib/firmware/SAMPLER-GPIO-00A0.dtbo
###
###Disable auto loading of virtual capes (emmc/video/wireless/adc)
disable_uboot_overlay_emmc=1
disable_uboot_overlay_video=1
disable_uboot_overlay_audio=1
disable_uboot_overlay_wireless=1
disable_uboot_overlay_adc=1
###
###PRUSS OPTIONS
###pru_rproc (4.4.x-ti kernel)
uboot_overlay_pru=/lib/firmware/AM335X-PRU-RPROC-4-4-TI-00A0.dtbo
###pru_uio (4.4.x-ti & mainline/bone kernel)
#uboot_overlay_pru=/lib/firmware/AM335X-PRU-UIO-00A0.dtbo
###
###Cape Universal Enable
#enable_uboot_cape_universal=1
###
###Debug: disable uboot autoload of Cape
#disable_uboot_overlay_addr0=1
#disable_uboot_overlay_addr1=1
#disable_uboot_overlay_addr2=1
#disable_uboot_overlay_addr3=1
###
###U-Boot fdt tweaks...
#uboot_fdt_buffer=0x60000
###U-Boot Overlays###

cmdline=coherent_pool=1M net.ifnames=0 quiet

#In the event of edid real failures, uncomment this next line:
#cmdline=coherent_pool=1M net.ifnames=0 quiet video=HDMI-A-1:1024x768@60e

##Example v3.8.x
#cape_disable=capemgr.disable_partno=
#cape_enable=capemgr.enable_partno=

##Example v4.1.x
#cape_disable=bone_capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,
#cape_enable=bone_capemgr.enable_partno=

##enable Generic eMMC Flasher:
##make sure, these tools are installed: dosfstools rsync
#cmdline=init=/opt/scripts/tools/eMMC/init-eMMC-flasher-v3.sh" > /boot/uEnv.txt

echo "#!/bin/bash
export PRU_CGT=/usr/share/ti/cgt-pru
rmmod pru_rproc -f && modprobe pru_rproc
mkdir /mnt/volume
mount /dev/sda1 /mnt/volume
xinit /root/.xinitrc -- /etc/X11/xinit/xserverrc :0 -auth /tmp/serverauth.1sIKMNHlsy
exit 0" > /etc/rc.local
chmod +x /etc/rc.local
sudo systemctl enable rc-local

git clone https://github.com/RobertCNelson/bb.org-overlays
cd bb.org-overlays
./install.sh

echo 'extending FS'
/opt/scripts/tools/grow_partition.sh


echo 'setting up x11 & midori'

mkdir -p /root/.config/midori/

echo "[settings]
default-encoding=ISO-8859-1
enable-developer-extras=true
enable-site-specific-quirks=true
enable-javascript=true
default-charset=ISO-8859-1
last-window-width=320
last-window-height=240
location-entry-search=https://duckduckgo.com/?q=%s
toolbar-items=TabNew,Back,NextForward,ReloadStop,BookmarkAdd,Location,Search,Trash,CompactMenu
homepage=https://www.google.de
tabhome=about:dial
download-folder=/root
user-agent=Mozilla/5.0 (X11; Linux) AppleWebKit/538.15 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/538.15 Midori/0.5" > /root/.config/midori/config

echo 'cleanup apt'
apt autoremove

echo 'Enabling onboard-TFT'

echo "fbtft_device name=adafruit22a gpios=reset:51,dc:48,led:110 busnum=1 rotate=90" > /etc/initramfs-tools/modules
update-initramfs -u

echo "[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target" > /etc/systemd/system/rc-local.service
 
chmod +x /etc/rc.local

systemctl enable rc-local 

npm install -g pm2

echo "xsetbg -fullscreen /root/BeagleBoom/menu/static/bg.png &
xset -dpms # disable DPMS (Energy Star) features.
xset s off # disable screen saver
xset s noblank # don't blank the video device
unclutter &
matchbox-window-manager &
midori -e Fullscreen -e enable-javascript=true -a file:///root/BeagleBoom/menu/static/connect.html -e enable-developer-extras=true

cd /root/BeagleBoom/inputs/bin
./iosetup
cd ..
nohup bin/iohandler 5  > /dev/null 2>&1 &
cd ..
cd adc
nohup bin/adcmanager 10 > /dev/null 2>&1 &
cd /root/BeagleBoom/menu
forever start index.js 1
" > /root/.xinitrc
systemctl daemon-reload
echo "Disabling unneeded services..."
systemctl disable bonescript.service              
systemctl disable bonescript.socket
systemctl disable bonescript-autorun.service
systemctl disable cloud9.service   
systemctl disable cloud9.socket     
systemctl disable node-red.socket          
systemctl disable gateone.service                 
systemctl disable bonescript.service              
systemctl disable bonescript-autorun.service      
systemctl disable avahi-daemon.service  
systemctl daemon-reload

echo "                                                                                      
                                                                                     
                                                                      @ @             
                                                                       @              
                                                                 @@@@@ ,              
                                                       @      @@@@  ;   @             
                                                      @@@   @@@     @   .             
                                                     @@@@@ @@       @    @            
                                   @@@@@@@@@@       @@@@@@@,        @                 
                                @@@@@@@@@@@@@@@@   @@@@@@@@@@       #                 
                              @@@@@@@@@@@@@@@@@@@@+@@@@@@@@@@@                        
                            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                        
                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         
                         #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+                         
                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                          
                       ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                           
                       @@@@@@@@@@@@@@     .@@@@@@@@@@@@@@@                            
                      @@@@@@@@@@@@'@@@@  #@@@:@@@@@@@@@@@@                            
                     @@@@@@@@@@@@#@@@@@  @@@@@@@@@@@@@@@@@@                           
                     @@@@@@@@@@@@@@@@@@  @@@@@@@ @@@@@@@@@@                          
                    @@@@@@@@@ @@@@@@@@@  @@@@@@@@@.@@@@@@@@@                          
                    @@@@@@@@ @@@@@@@@@@  @@@@@@@@@@ @@@@@@@@                          
                   @@@@@@@@@@@@ @@@@@@@  @@@@@@@@@@@ @@@@@@@@                         
                   @@@@@@@@@@@@@@@@@@@@  @@@@@@@@ @@@@@@@@@@@                         
                   @@@@@@@ @@@ @@@@@@@@  @@@@@@@@:@@@ @@@@@@@                         
                   @@@@@@;@@@@ @@@@@@@@  @@@@@@@@@@@@@ @@@@@@@                        
                  @@@@@@@@@@@@ @@@@@@@@  @@@@@@@@@@@@@@ @@@@@@                        
                  @@@@@@@@@@@@.@@  @@@@  @@@@ +@@ @@@@@@@@@@@@                        
                  @@@@@ @@@@@@@@@@@  @@  @@+.@ @@ @@@@@@ @@@@@                        
                  @@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@                        
                  @@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@ @@@@                        
                  @@@@@@@@@@@@@ @@@@@@    @@@@@@@@@@@@@@@ @@@@                        
                  @@@@@@@@@@@@@@@@@@@      @@@@@ @@@@@@@@ @@@@                        
                  +@@@@@@@@@@@@@@@@@        @@@@+@@@@@@@@@@@@@                        
                   @@@@ @@@@@@@@@@@       :  @@@@@@@@@@@ @@@@@                        
                   @@@@@@@@@@@@@;@    @  @    @@@@@@@@@@@@@@@                         
                   @@@@@@@@@@@@@               #@@@@@@@ @@@@@                         
                   .@@@@@:@@@@@@#               @@@@@@ @@@@@@                         
                    @@@@@@ @@@@@@   @  @@  '    @@@@@'@@@@@@                          
                    @@@@@@@ @@@@@               @@@@@@@@@@@@                          
                     @@@@@@@ @@@@               @@@@@@@@@@@                           
                     ;@@@@@@@@@@ @            @ @@@ @@@@@@@                           
                      @@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@                            
                       @@@@@@@,@@@@@@@@@@@@@@@@@@ @@@@@@@                             
                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,                             
                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+                              
                          @@@@@@@@@@@@@@@@@@@@@@@@@@@@.                               
                           @@@@@@@@@@@@@@@@@@@@@@@@@@                                 
                            ;@@@@@@@@@@@@@@@@@@@@@@@                                  
                              @@@@@@@@@@@@@@@@@@@@                                    
                                 @@@@@@@@@@@@@@@                                      
                                    @@@@@@@@                                          
                                                                                      
                                                                                      
                                                                                      
                                                                                      
                                                                                      
                                                                                      
                                                                                      
 INSTALLATION FINISHED REBOOT NOW!

"
