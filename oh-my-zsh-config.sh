#!/bin/bash

# 检测系统并设置包管理器
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    if [ "$UID" -eq 0 ]; then
        INSTALL_COMMAND="$PKG_MANAGER update && $PKG_MANAGER install -y"
    else
        INSTALL_COMMAND="sudo $PKG_MANAGER update && sudo $PKG_MANAGER install -y"
    fi
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    if [ "$UID" -eq 0 ]; then
        INSTALL_COMMAND="$PKG_MANAGER upgrade && $PKG_MANAGER install -y"
    else
        INSTALL_COMMAND="sudo $PKG_MANAGER upgrade && sudo $PKG_MANAGER install -y"
    fi
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
    if [ "$UID" -eq 0 ]; then
        INSTALL_COMMAND="$PKG_MANAGER update && $PKG_MANAGER install -y"
    else
        INSTALL_COMMAND="sudo $PKG_MANAGER update && sudo $PKG_MANAGER install -y"
    fi
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    if [ "$UID" -eq 0 ]; then
        INSTALL_COMMAND="$PKG_MANAGER -Syyu"
    else
        INSTALL_COMMAND="sudo $PKG_MANAGER -Syyu --noconfirm"
    fi
else
    echo "未找到支持的包管理器"
    exit 1
fi


# 检查zsh是否已经安装
if command -v zsh >/dev/null 2>&1; then
    echo "zsh已经安装"
else
    echo "zsh未安装，开始安装..."
    $INSTALL_COMMAND zsh
    echo "zsh安装完成"
fi

# 检查which是否已经安装
if ! command -v which >/dev/null 2>&1; then
    echo "which未安装，开始安装..."
    $INSTALL_COMMAND which
    echo "which安装完成"
fi

# 检查git是否已经安装
if command -v git >/dev/null 2>&1; then
    echo "git已经安装"
else
    echo "git未安装，开始安装..."
    $INSTALL_COMMAND git
    echo "git安装完成"
fi

# 设置zsh为默认shell
if [ "$(which zsh)" != "$(getent passwd $LOGNAME | cut -d: -f7)" ]; then
    echo "设置zsh为默认shell..."
    chsh -s $(which zsh)
    echo "设置完成"
else
    echo "zsh已经是默认shell"
fi

# 检查oh-my-zsh是否已经安装
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh已经安装"
else
    echo "oh-my-zsh未安装，开始安装..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh安装完成"
fi

# 检查zsh-syntax-highlighting是否已经安装
if [ -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
    echo "zsh-syntax-highlighting已经安装"
else
    echo "zsh-syntax-highlighting未安装，开始安装..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
    echo "source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    echo "zsh-syntax-highlighting安装完成"
fi

# 检查zsh-autosuggestions是否已经安装
if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "zsh-autosuggestions已经安装"
else
    echo "zsh-autosuggestions未安装，开始安装..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    echo "zsh-autosuggestions安装完成"
    sed -i.bak 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ${ZDOTDIR:-$HOME}/.zshrc
fi
