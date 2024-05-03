FROM spacedot/deploy-base AS final

RUN apt-get update && apt-get install --yes --no-install-recommends curl

# brew doesn't run on root - but docker runs on /root. Thus, we create a new user
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER linuxbrew
WORKDIR /home/linuxbrew

# Install brew
RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
    && mkdir ~/.linuxbrew/bin \
    && ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin \
    && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

ENV PATH="/usr/bin:${PATH}" 
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
SHELL ["/bin/bash", "-c"]

RUN source ~/.profile && brew --version
RUN brew install nasa-sw-vnv/core/ikos