#!/bin/bash
if [ $(uname) = "Darwin" ]; then
	if [ $(uname -p) = "arm" ] || [ $(uname -p) = "arm64" ]; then
		ARM=yes
	fi
fi

echo "CheckLiRa bởi Hòa Huỳnh"
echo "(C) 2020, LiRa."

echo ""


if ! which curl >> /dev/null; then
	echo "Error: curl not found"
	exit 1
fi
if [[ "${ARM}" = yes ]]; then
	if ! which zsh >> /dev/null; then
		echo "Error: zsh not found"
		exit 1
	fi
else
	if which iproxy >> /dev/null; then
		iproxy 4444 44 >> /dev/null 2>/dev/null &
	else
		echo "Error: iproxy not found"
		exit 1
	fi
fi
rm -rf LiRa-tmp
mkdir LiRa-tmp
cd LiRa-tmp

echo '#!/bin/zsh' > LiRa-device-deploy.sh
if [[ ! "${ARM}" = yes ]]; then
	echo 'cd /var/root' >> LiRa-device-deploy.sh
fi
echo 'if [[ -f "/.bootstrapped" ]]; then' >> LiRa-device-deploy.sh
echo 'mkdir -p /LiRa && mv migration /LiRa' >> LiRa-device-deploy.sh
echo 'chmod 0755 /LiRa/migration' >> LiRa-device-deploy.sh
echo '/LiRa/migration' >> LiRa-device-deploy.sh
echo 'rm -rf /LiRa' >> LiRa-device-deploy.sh
echo 'else' >> LiRa-device-deploy.sh
echo 'VER=$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)' >> LiRa-device-deploy.sh
echo 'if [[ "${VER%.*}" -ge 12 ]] && [[ "${VER%.*}" -lt 13 ]]; then' >> LiRa-device-deploy.sh
echo 'CFVER=1500' >> LiRa-device-deploy.sh
echo 'elif [[ "${VER%.*}" -ge 13 ]]; then' >> LiRa-device-deploy.sh
echo 'CFVER=1600' >> LiRa-device-deploy.sh
echo 'elif [[ "${VER%.*}" -ge 14 ]]; then' >> LiRa-device-deploy.sh
echo 'CFVER=1700' >> LiRa-device-deploy.sh
echo 'else' >> LiRa-device-deploy.sh
echo 'echo "${VER} not compatible."' >> LiRa-device-deploy.sh
echo 'exit 1' >> LiRa-device-deploy.sh
echo 'fi' >> LiRa-device-deploy.sh
echo 'gzip -d bootstrap_${CFVER}.tar.gz' >> LiRa-device-deploy.sh
echo 'mount -uw -o union /dev/disk0s1s1' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/profile' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/profile.d' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/alternatives' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/apt' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/ssl' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/ssh' >> LiRa-device-deploy.sh
echo 'rm -rf /etc/dpkg' >> LiRa-device-deploy.sh
echo 'rm -rf /Library/dpkg' >> LiRa-device-deploy.sh
echo 'rm -rf /var/cache' >> LiRa-device-deploy.sh
echo 'rm -rf /var/lib' >> LiRa-device-deploy.sh
echo 'tar --preserve-permissions -xkf bootstrap_${CFVER}.tar -C /' >> LiRa-device-deploy.sh
printf %s 'SNAPSHOT=$(snappy -s | ' >> LiRa-device-deploy.sh
printf %s "cut -d ' ' -f 3 | tr -d '\n')" >> LiRa-device-deploy.sh
echo '' >> LiRa-device-deploy.sh
echo 'snappy -f / -r $SNAPSHOT -t orig-fs' >> LiRa-device-deploy.sh
echo 'fi' >> LiRa-device-deploy.sh
echo '/usr/libexec/firmware' >> LiRa-device-deploy.sh
echo 'mkdir -p /etc/apt/sources.list.d/' >> LiRa-device-deploy.sh
echo 'echo "Types: deb" > /etc/apt/sources.list.d/lira.sources' >> LiRa-device-deploy.sh
echo 'echo "URIs: https://hoahuynh-lira.github.io/repo/" >> /etc/apt/sources.list.d/lira.sources' >> LiRa-device-deploy.sh
echo 'echo "Suites: ./" >> /etc/apt/sources.list.d/lira.sources' >> LiRa-device-deploy.sh
echo 'echo "Components: " >> /etc/apt/sources.list.d/lira.sources' >> LiRa-device-deploy.sh
echo 'echo "" >> /etc/apt/sources.list.d/lira.sources' >> LiRa-device-deploy.sh
echo 'mkdir -p /etc/apt/preferences.d/' >> LiRa-device-deploy.sh
echo 'echo "Package: *" > /etc/apt/preferences.d/lira' >> LiRa-device-deploy.sh
echo 'echo "Pin: release n=LiRa-ios" >> /etc/apt/preferences.d/lira' >> LiRa-device-deploy.sh
echo 'echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/lira' >> LiRa-device-deploy.sh
echo 'echo "" >> /etc/apt/preferences.d/lira' >> LiRa-device-deploy.sh
echo 'if [[ $VER = 12.1* ]] || [[ $VER = 12.0* ]]; then' >> LiRa-device-deploy.sh
echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i xyz.willy.zebra_1.1.13_iphoneos-arm.deb' >> LiRa-device-deploy.sh
echo 'uicache -p /Applications/Zebra.app' >> LiRa-device-deploy.sh
echo 'echo -n "" > /var/lib/dpkg/available' >> LiRa-device-deploy.sh
echo '/Library/dpkg/info/profile.d.postinst' >> LiRa-device-deploy.sh
echo 'touch /.mount_rw' >> LiRa-device-deploy.sh
echo 'touch /.installed_LiRa' >> LiRa-device-deploy.sh
echo 'rm bootstrap*.tar*' >> LiRa-device-deploy.sh
echo 'rm migration' >> LiRa-device-deploy.sh
echo 'rm xyz.willy.zebra_1.1.13_iphoneos-arm.deb' >> LiRa-device-deploy.sh
echo 'rm LiRa-device-deploy.sh' >> LiRa-device-deploy.sh

echo "Downloading Files..."
curl -L -O https://github.com/hoahuynh-lira/LiRa-bootstrap/raw/master/bootstrap_1500.tar.gz -O https://github.com/hoahuynh-lira/LiRa-bootstrap/raw/master/bootstrap_1600.tar.gz -O https://github.com/hoahuynh-lira/LiRa-bootstrap/raw/master/bootstrap_1700.tar.gz -O https://github.com/hoahuynh-lira/LiRa-bootstrap/raw/master/migration -O https://github.com/hoahuynh-lira/LiRa-bootstrap/raw/master/xyz.willy.zebra_1.1.13_iphoneos-arm.deb
clear
if [[ ! "${ARM}" = yes ]]; then
	echo "Đang sao chép qua thiết bị"
	echo "password: alpine"
	scp -P444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" bootstrap_1500.tar.gz bootstrap_1600.tar.gz bootstrap_1700.tar.gz migration xyz.willy.zebra_1.1.13_iphoneos-arm.deb  LiRa-device-deploy.sh root@127.0.0.1:/var/root/
	clear
fi
echo "Cài đặt bootstrap và Zebra"
if [[ "${ARM}" = yes ]]; then
	zsh ./LiRa-device-deploy.sh
else
	echo "password: alpine"
	ssh -p4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "zsh /var/root/LiRa-device-deploy.sh"
	echo "Thành Công:)"
	killall iproxy
fi
