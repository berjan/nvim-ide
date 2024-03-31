# Docker file for base Neovim image.
#
# @author Maciej Bedra

# Debian image as base (unstable for newest software).
FROM debian:latest

# Set image locale.
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV TZ=Europe/Warsaw

# Expose some ports to host by default.
EXPOSE 8080 8081 8082 8083 8084 8085

# Define which Neovim COC extensions should be installed.
ARG COC='coc-css coc-eslint coc-html coc-json coc-sh coc-sql coc-tsserver coc-yaml coc-pyright'

# Lazygit variables
ARG LG='lazygit'
ARG LG_GITHUB='https://github.com/jesseduffield/lazygit/releases/download/v0.31.4/lazygit_0.31.4_Linux_x86_64.tar.gz'
ARG LG_ARCHIVE='lazygit.tar.gz'

# GIT Flow variables
ARG GIT_FLOW_GITHUB='https://github.com/petervanderdoes/gitflow-avh.git'
ARG GIT_FLOW_DIR='gitflow-avh'

# Update repositories and install software:
# 1. curl.
# 2. fzf for fast file search.
# 3. ripgrep for fast text occurrence search.
# 4. tree for files tree visualization.
# 5. Git.
# 6. Lazygit for Git visualization.
# 7. xclip for clipboard handling.
# 8. Python 3.
# 9. pip for Python.
# 10. NodeJS.
# 11. npm for NodeJS.
# 12. tzdata to set default container timezone.
# 13. Everything needed to install Neovim from source.
RUN apt-get update && apt-get -y install zsh curl fzf ripgrep tree git xclip python3 python3-pip nodejs npm tzdata ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config zip unzip libpq-dev gcc

# install ohmyzshh	
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

COPY zsh/_zshrc /root/.zshrc

# Cooperate Neovim with Python 3.
#RUN pip3 install pynvim

# Cooperate NodeJS with Neovim.
RUN npm i -g neovim

# Install Neovim from source.
RUN mkdir -p /root/TMP
RUN cd /root/TMP && git clone https://github.com/neovim/neovim
RUN cd /root/TMP/neovim && git checkout stable && make -j4 && make install
RUN rm -rf /root/TMP

# Create directory for Neovim spell check dictionaries.
RUN mkdir -p /root/.local/share/nvim/site/spell

# Copy Neovim dictionaries.
COPY ./spell/ /root/.local/share/nvim/site/spell/

# Install Vim Plug.
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Create directory for Neovim configuration files.
RUN mkdir -p /root/.config/nvim

# Copy Neovim configuration files. Ensure this COPY includes all needed config files.
COPY ./config/ /root/.config/nvim/

# Install Neovim extensions.
RUN nvim --headless +PlugInstall +qall

# Prepare for COC extensions installation by creating a package.json for coc extensions
RUN mkdir -p /root/.config/coc/extensions && \
    echo '{"dependencies":{}}' > /root/.config/coc/extensions/package.json

# Install COC extensions using the package.json
# Note: The `--global-style` flag ensures dependencies are installed in the node_modules directory under coc/extensions
RUN cd /root/.config/coc/extensions && npm install $COC --global-style --only=prod

# Additional setup for Neovim or other tools can go here
# For example, if you need to install Python language debugger adapter as previously mentioned:
RUN cd /root/.config/nvim/plugins/vimspector && python3 install_gadget.py --enable-python

# Create TMP directory
RUN mkdir -p /root/TMP

# Install Lazygit from binary
RUN cd /root/TMP && curl -L -o $LG_ARCHIVE $LG_GITHUB
RUN cd /root/TMP && tar xzvf $LG_ARCHIVE && mv $LG /usr/bin/

# Install GIT Flow
RUN cd /root/TMP && git clone $GIT_FLOW_GITHUB
RUN cd /root/TMP/$GIT_FLOW_DIR && git checkout master && make install

# Delete TMP directory
RUN rm -rf /root/TMP

# Bash aliases
COPY ./home/ /root/

# Create directories for projects and virtual environments.
RUN mkdir -p /root/workspace /root/workspace/envs

# Install dependencies and prepare the main virtual environment.
# Copy only the necessary file first to leverage Docker cache.
COPY ./env/requirements.txt /root/workspace/requirements.txt

RUN apt-get update && apt-get install -y python3-venv \
    && python3 -m venv /root/workspace/venv \
    && /root/workspace/venv/bin/pip install --upgrade pip \
    && /root/workspace/venv/bin/pip install -r /root/workspace/requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the rest of the environment folder (if necessary).
COPY ./env/ /root/workspace/

WORKDIR /root/workspace/

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
