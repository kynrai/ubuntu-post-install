#!/usr/bin/env bash

# Install steam before PPAs, possible workaround for i386 packages missing after PPAs
sudo apt-get update
sudo apt-get install -y steam

# Add PPAs
declare -a ppas=(
"ppa:git-core/ppa"
"ppa:nilarimogard/webupd8"
"ppa:videolan/stable-daily"
"ppa:linrunner/tlp"
"ppa:webupd8team/atom"
"ppa:deluge-team/ppa"
)

for ppa in "${ppas[@]}"
do
   sudo add-apt-repository -y "$ppa"
done

sudo apt-get update

# Install apps from the base repos

declare -a packages=(
"git"
"youtube-dl"
"build-essential"
"vlc"
"zsh"
"vim-nox"
"tlp"
"htop"
"atom"
"xclip"
"deluge"
"python-pip"
"libssl-dev"
"sqlite"
"automake"
"autotools-dev"
"libbison-dev"
"libsigsegv2"
"libtinfo-dev"
"m4"
"wkhtmltopdf"
)


sudo apt-get install -y $(printf "%s " "${packages[@]}")

# Install golang
wget https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz
tar xfz go1.7.1.linux-amd64.tar.gz -C /opt
rm go1.7.1.linux-amd64.tar.gz

declare -a go=(
"export GOROOT=/opt/go"
"export GOPATH=\$HOME/gopath"
"export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin"
)
if [ ! -f /etc/profile.d/golang.sh ]; then
	sudo touch /etc/profile.d/golang.sh
	for line in "${go[@]}"
	do
   	echo "$line" | sudo tee --append /etc/profile.d/golang.sh
	done
fi

# Install node
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install rubenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
cd ~
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Start tlp for battery saving
sudo tlp start

# Install oh my zsh as main shell
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Fix for wifi after suspend
declare -a networkScript=(
"#/etc/systemd/system/wifi-resume.service"
"#sudo systemctl enable wifi-resume.service"
"[Unit]"
"Description=Restart networkmanager at resume"
"After=suspend.target"
"After=hibernate.target"
"After=hybrid-sleep.target"
""
"[Service]"
"Type=oneshot"
"ExecStart=/bin/systemctl restart network-manager.service"
""
"[Install]"
"WantedBy=suspend.target"
"WantedBy=hibernate.target"
"WantedBy=hybrid-sleep.target"
)
if [ ! -f /etc/systemd/system/wifi-resume.service ]; then
	sudo touch /etc/systemd/system/wifi-resume.service
	for line in "${networkScript[@]}"
	do
   	echo "$line" | sudo tee --append /etc/systemd/system/wifi-resume.service
	done
fi

# Fix for gvfs 100% CPU usage bug
if [ ! -f /etc/samba/smb.conf ]; then
	sudo mkdir -p /etc/samba
	sudo touch /etc/samba/smb.conf
	echo "[global]" | sudo tee --append /etc/samba/smb.conf
	echo "name resolve order = wins lmhosts bcast" | sudo tee --append /etc/samba/smb.conf
fi

# Requires manual aceptance
sudo apt-get install -y ubuntu-restricted-extras

# Tweaks
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-minimize-window true

echo "Check script for manual steps"

# Fix for VLC not playing properly
#In Tools > Preferences > Video > Output change to "OpenGL GLX video output(XCB), save and restart vlc.

#If you use Intel GPU, following setting speeds up decoding. In Tools > Preferences > Input/Codecs > Hardware-accelerated decoding chant to "VA-API video decoder via X11"
