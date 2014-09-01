#!/bin/sh
# Simple setup.sh for configuring Ubuntu 14.04 LTS Digital Ocean droplet for headless setup.

USER="tibo"

# Create user, add to sudo group without password and change user
adduser --disabled-password --gecos "" $USER
sudo adduser $USER sudo
touch /etc/sudoers.tmp
sudo echo -e "# passwordless sudo functionality\n$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.tmp
visudo -c -f /etc/sudoers.tmp
if [ "$?" -eq "0" ]; then
    cp /etc/sudoers.tmp /etc/sudoers.d/nopwd
fi
rm /etc/sudoers.tmp
sudo service sudo restart
su $USER
cd

# Install git
sudo apt-get install -y git

#---------------#
#<<CHECK BELOW>>#
#---------------#

# Install unzip
sudo apt-get install -y unzip

# Install zsh and make it the default shell
sudo apt-get install -y zsh
sudo chsh -s $(which zsh) ubuntu

# Install fasd for j jump in zsh
wget -qO- https://codeload.github.com/clvv/fasd/legacy.zip/1.0.1 > fasd.zip
unzip fasd.zip
cd clvv-fasd-4822024
sudo make install
cd ~/
rm -rf clvv-fasd-4822024
rm -f fasd.zip

# Install node.js via package manager (npm is included in chris lea's nodejs package)
# https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties python g++ make
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get -qq update
sudo apt-get install -y nodejs

# Install node version manager to switch versions easily
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.12.1/install.sh | bash

# Install zeromq-node binaries so that npm install zmq works
# https://github.com/JustinTulloss/zeromq.node/wiki/Installation
sudo add-apt-repository -y ppa:chris-lea/zeromq
sudo add-apt-repository -y ppa:chris-lea/libpgm
sudo apt-get update
sudo apt-get install -y libzmq3-dev

# Install jshint and js-beautify
sudo npm install -g jshint
sudo npm install -g js-beautify

# Install rlwrap to provide libreadline features with node
# See: http://nodejs.org/api/repl.html#repl_repl
sudo apt-get install -y rlwrap

# Install emacs24
# https://launchpad.net/~cassou/+archive/emacs
sudo add-apt-repository -y ppa:cassou/emacs
sudo apt-get -qq update
sudo apt-get install -y emacs24-nox emacs24-el emacs24-common-non-dfsg

# Install tmuxinator (help for setting tmux sessions)
sudo gem install tmuxinator

# Install Heroku toolbelt
# https://toolbelt.heroku.com/debian
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

# git pull and install dotfiles as well
cd $HOME
if [ -d ./dotfiles/ ]; then
    mv dotfiles dotfiles.old
fi
if [ -d .emacs.d/ ]; then
    mv .emacs.d .emacs.d~
fi
git clone https://github.com/tibotiber/ec2-dotfiles.git dotfiles
ln -sb dotfiles/.tmux.conf .
ln -sb dotfiles/.tmuxinator .
ln -sb dotfiles/.bash_profile .
ln -sb dotfiles/.bashrc .
ln -sb dotfiles/.bashrc_custom .
ln -sf dotfiles/.emacs.d .

# update bash profile
. ~/.bash_profile

# source completion file for tmuxinator
source .tmuxinator/tmuxinator.bash

# Install sails.js MVC framework for node.js
sudo npm -g install sails

# Install MQTT tools
sudo apt-get install -y mosquitto python-mosquitto mosquitto-clients
sudo rm /etc/init/mosquitto.conf # because I don't want mosquitto as a startup service
sudo npm -g install mosca # mosca installed globally if not included in ubismart

# Install i386 architecture & system-level 32bit libs to run yap (eye)
# This bit is Ubuntu 14.04 specific!
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
# Install yap specific 32bit lib
sudo apt-get install -y zlib1g:i386


# config for efficient git
git config --global user.name "Thibaut Tiberghien"
git config --global user.email "thibaut.tiberghien@ipal.cnrs.fr"
ssh-keygen -t rsa -N "" -C "thibaut@planecq.com" -f ~/.ssh/id_rsa
ssh-add id_rsa
echo "You should copy the next line into a new ssh key on github (https://github.com/settings/ssh)."
cat ~/.ssh/id_rsa.pub
echo "Then you can run 'ssh -T git@github.com' to check that the connection is working."
