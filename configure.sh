#!/bin/bash
OS=''
PACKAGE_MANAGER=''
VUNDLE_DIR="~/.vim/bundle/Vundle.vim"

discover_os_and_pkg_manager () {
  OS_CMD=$(uname)
  case "$OS_CMD" in
    'Linux')
      OS=$(awk '{print $1}' /etc/issue)
      if [[ "$OS" == "Ubuntu" ]]; then
        PACKAGE_MANAGER="apt-get"
      else
        PACKAGE_MANAGER="yum"
      fi
      ;;
    'WindowsNT')
      OS='Windows'
      #TODO: Create container
      PACKAGE_MANAGER="yum"
      ;;
    'Darwin')
      OS='MAC'
      PACKAGE_MANAGER="brew"
      #TODO: Install brew
      ;;
    *)
      echo "---------------------------------"
      echo "Error"
      echo "---------------------------------"
      exit 1
      ;;
  esac
  echo "OS is $OS"
}

switch_caps_to_ctrl () {
  echo "---------------------------------"
  echo "Keyboard Configuration"
  echo "---------------------------------"
  case "$OS" in
    'Ubuntu')
      sudo mv /etc/default/keyboard /etc/default/keyboard.old
      sudo cp ./ubuntu_keyboard /etc/default/keyboard
      sudo /usr/bin/setxkbmap -option "caps:ctrl_modifier"
      ;;
    'MAC')
      ;;
    'Windows')
      echo "---------------------------------"
      echo "Not necessary to configure keyboard on $OS"
      echo "---------------------------------"
      ;;
    *)
      #TODO: Test in CentOS
      sudo xmodmap -e 'keycode 66 = Control_L'
      sudo xmodmap -e 'clear Lock'
      sudo xmodmap -e 'add Control = Control_L'
      sudo xmodmap -pke >~/.Xmodmap
      sudo xmodmap .Xmodmap
      ;;
  esac
}

install_enpass_ubuntu () {
  sudo echo "deb http://repo.sinew.in/ stable main" > /etc/apt/sources.list.d/enpass.list
  wget -O - https://dl.sinew.in/keys/enpass-linux.key | apt-key add -
  apt-get update
  apt-get install enpass
}

install_enpass_redhat () {
  #TODO: Not tested
  wget https://dl.sinew.in/linux/setup/5-5-6/Enpass_Installer_5.5.6
  chmod +x EnpassInstaller
  yum install libXScrnSaver lsof
  ./EnpassInstaller
}
discover_os_and_pkg_manager
switch_caps_to_ctrl


echo "---------------------------------"
echo "Updating Package List"
echo "---------------------------------"
sudo $PACKAGE_MANAGER update

echo "---------------------------------"
echo "Installing Packages"
echo "---------------------------------"
sudo $PACKAGE_MANAGER install vim git curl wget flashplugin-installer wine dropbox chromium-browser shellcheck

if [[ $OS == "Ubuntu" ]]; then
  sudo $PACKAGE_MANAGER install guake playonlinux
  install_enpass_ubuntu
else
  install_enpass_redhat
fi

echo "---------------------------------"
echo "Configuring Dotfiles"
echo "---------------------------------"
cp .gitconfig ~/.gitconfig
cp .vimrc ~/.vimrc

if [[ ! -d $VUNDLE_DIR ]]; then
  echo "---------------------------------"
  echo "Installing Vundle"
  echo "---------------------------------"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi

echo "---------------------------------"
echo "Installing Oh My ZSH"
echo "---------------------------------"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


echo "---------------------------------"
echo "Download Evernote Manually and run wine <installer>"
echo "---------------------------------"