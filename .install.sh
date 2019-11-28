#!/bin/bash

if [ "$1" = "cli" ]; then
    cli_config_files=".aliases .hushlogin .tmux.conf .vimrc .zshenv .zshrc"

    for file in $cli_config_files; do
        ln -s $(pwd)/$file $HOME/$file
    done

    exit 0
fi

# Update existing sudo time stamp if the script is still running
while true; do
    sleep 60
    sudo -v
    kill -0 "$$" || exit
done 2>/dev/null &

install_list=( $(whiptail --notags --title "Dotfiles" --checklist "Install list" 20 45 11 \
    install_dotfiles "All config files" on \
    install_aur_helper "AUR helper (trizen)" on \
    install_core_packages "Recommended packages" on \
    install_extra_packages "Extra packages" on \
    install_onedark_terminal_theme "One Dark terminal theme" off \
    install_intel_graphics "Intel graphics driver" on \
    install_bumblebee "Bumblebee for NVIDIA Optimus" on \
    install_unikey "Unikey" on \
    install_system_config "System config files" on \
    install_battery_saver "Install battery saver for laptop" on \
    create_ssh_key "Create SSH key for GitHub" on \
    3>&1 1>&2 2>&3 | sed 's/"//g') )

install_dotfiles() {
    REPO="https://github.com/khuedoan98/dotfiles.git"
    GITDIR=$HOME/.dotfiles/

    git clone --branch gnome --bare $REPO $GITDIR

    dotfiles() {
        /usr/bin/git --git-dir=$GITDIR --work-tree=$HOME $@
    }

    if ! dotfiles checkout; then
        echo "All of the above files will be deleted, are you sure? (y/N) "
        read -r response
        if [ "$response" = "y" ]; then
            dotfiles checkout 2>&1 | grep -E "^\s+" | sed -e 's/^[ \t]*//' | xargs -d "\n" -I {} rm -v {}
            dotfiles checkout
            dotfiles config status.showUntrackedFiles no
        else
            rm -rf $GITDIR
            echo "Installation cancelled"
            exit 1
        fi
    else
        dotfiles config status.showUntrackedFiles no
    fi
}

install_aur_helper() {
    git clone https://aur.archlinux.org/trizen.git
    cd trizen
    makepkg -si --noconfirm
    cd ..
    rm -rf trizen
}

install_core_packages() {
    sudo pacman --noconfirm --needed -S eog evince file-roller fzf gdm git gnome-calculator gnome-control-center gnome-keyring gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-tweaks gvim mpv nautilus npm sushi xcape xdg-user-dirs-gtk

    # zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

    # enable gdm at boot
    systemctl enable gdm
}

install_extra_packages() {
    sudo pacman --noconfirm --needed -S arc-gtk-theme aria2 man noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra tmux tree unrar youtube-dl xorg-xprop
    gpg --recv-keys EB4F9E5A60D32232BB52150C12C87A28FEAC6B20
    trizen --noconfirm --needed -S --sudo-autorepeat-at-runtime chromium-vaapi-bin gnome-shell-extension-unite la-capitaine-icon-theme-git nerd-fonts-source-code-pro ttf-ms-fonts
}

install_onedark_terminal_theme() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-dark.sh)"
}

install_intel_graphics() {
    sudo pacman --noconfirm --needed -S xf86-video-intel libva-intel-driver
}

install_bumblebee() {
    sudo pacman --noconfirm --needed -S bumblebee nvidia lib32-nvidia-utils lib32-virtualgl nvidia-settings bbswitch
    sudo gpasswd -a $USER bumblebee
    sudo gpasswd -a $USER video
    sudo systemctl enable bumblebeed.service
    sudo sed -i -e "s/#RUNTIME_PM_BLACKLIST=.*/RUNTIME_PM_BLACKLIST=\"$(lspci | grep NVIDIA | cut -b -7)\"/g" /etc/default/tlp
    # Run NVIDIA settings with optirun -b none /usr/bin/nvidia-settings -c :8
}

install_unikey() {
    sudo pacman --noconfirm --needed -S ibus-unikey
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Unikey')]"
}

install_system_config() {
    sudo cp -riv .root/* /
    for i in {1..9}; do gsettings set "org.gnome.shell.keybindings" "switch-to-application-$i" "[]"; done
}

install_battery_saver() {
    sudo pacman --noconfirm --needed -S tlp powertop
    trizen --noconfirm --needed -S --sudo-autorepeat-at-runtime intel-undervolt
    sudo systemctl enable tlp.service
    sudo systemctl enable tlp-sleep.service
    sudo intel-undervolt apply
    sudo systemctl enable intel-undervolt.service
}

create_ssh_key() {
    email=$(whiptail --inputbox "Enter email for SSH key" 10 20 3>&1 1>&2 2>&3)
    ssh-keygen -t rsa -b 4096 -C "${email}"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
}

for install_function in "${install_list[@]}"; do
    $install_function
done
