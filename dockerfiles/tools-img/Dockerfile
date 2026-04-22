## https://github.com/astral-sh/uv/releases
ARG UV_BASE=${UV_VER:-0.11.7}
## https://github.com/gitleaks/gitleaks/releases
ARG GITLEAKS_VERSION=${GITLEAKS_VER:-8.30.1}
## https://github.com/google/osv-scanner/releases
ARG OSV_VERSION=${OSV_VER:-2.3.5}
## https://github.com/hashicorp/terraform/releases
ARG TERRAFORM_VERSION=${TERRAFORM_VER:-1.14.9}
## https://github.com/hashicorp/terraform-ls/releases
ARG TERRAFORM_LS_VERSION=${TERRAFORM_LS_VER:-0.38.6}
## https://github.com/aquasecurity/tfsec/releases
ARG TFSEC_VERSION=${TFSEC_VER:-1.28.14}
## https://github.com/terraform-linters/tflint/releases
ARG TFLINT_VERSION=${TFLINT_VER:-0.62.0}
## https://www.python.org/downloads/
ARG PYTHON_VERSION=${PYTHON_VER:-3.14}
## https://go.dev/dl/
ARG GO_VERSION=${GO_VER:-1.26.2}

## Add astral.sh/uv layer
FROM ghcr.io/astral-sh/uv:${UV_BASE} AS uv

FROM python:${PYTHON_VERSION}-slim-bookworm AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/go/bin:/usr/local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

## Install common dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dos2unix \
    git \
    gnupg \
    jq \
    lsb-release \
    wget \
    tar \
    rsync \
    bash-completion \
    unzip \
    sudo \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

## Create non-root user
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && mkdir -p /workspace \
    && chown -R $USERNAME:$USERNAME /workspace

FROM base AS tools-install

## Re-declare ARGs for this stage
ARG GITLEAKS_VERSION
ARG OSV_VERSION
ARG TERRAFORM_VERSION
ARG TERRAFORM_LS_VERSION
ARG TFSEC_VERSION
ARG TFLINT_VERSION
ARG GO_VERSION

## Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az bicep install && \
    rm -rf /var/lib/apt/lists/*

## Install Powershell
RUN wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    ln -s /usr/bin/pwsh /usr/local/bin/powershell

## Install Gitleaks
RUN wget "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" && \
    tar -xzf "gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" gitleaks && \
    mv gitleaks /usr/local/bin/ && \
    rm -f "gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" LICENSE

## Install OSV
RUN wget "https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_linux_amd64" -O /usr/local/bin/osv-scanner && \
    chmod +x /usr/local/bin/osv-scanner

## Install Terraform + helpers
COPY scripts/install-terraform-tools.sh /tmp/
RUN chmod +x /tmp/install-terraform-tools.sh && \
    TERRAFORM_VERSION=${TERRAFORM_VERSION} \
    TERRAFORM_LS_VERSION=${TERRAFORM_LS_VERSION} \
    TFSEC_VERSION=${TFSEC_VERSION} \
    TFLINT_VERSION=${TFLINT_VERSION} \
    /tmp/install-terraform-tools.sh && \
    rm /tmp/install-terraform-tools.sh

## Install Go and gopls
RUN wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" && \
    rm "go${GO_VERSION}.linux-amd64.tar.gz" && \
    /usr/local/go/bin/go install golang.org/x/tools/gopls@latest && \
    mv /root/go/bin/gopls /usr/local/bin/ && \
    rm -rf /root/go

## Install atuin (shell history)
RUN ATUIN_VERSION=$(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//') && \
    wget "https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-musl.tar.gz" && \
    tar -xzf atuin-x86_64-unknown-linux-musl.tar.gz && \
    mv atuin-x86_64-unknown-linux-musl/atuin /usr/local/bin/ && \
    chmod +x /usr/local/bin/atuin && \
    rm -rf atuin-x86_64-unknown-linux-musl.tar.gz atuin-x86_64-unknown-linux-musl

## Install zellij (terminal multiplexer)
RUN ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//') && \
    wget "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" && \
    tar -xzf zellij-x86_64-unknown-linux-musl.tar.gz && \
    mv zellij /usr/local/bin/ && \
    chmod +x /usr/local/bin/zellij && \
    rm zellij-x86_64-unknown-linux-musl.tar.gz

## Install lazygit (git TUI)
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//') && \
    wget "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar -xzf "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" lazygit && \
    mv lazygit /usr/local/bin/ && \
    chmod +x /usr/local/bin/lazygit && \
    rm "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

## Install pre-commit (git hooks framework)
RUN pip install --no-cache-dir pre-commit

## Install neovim
RUN NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | cut -d'"' -f4) && \
    wget "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" && \
    tar -xzf nvim-linux-x86_64.tar.gz && \
    mv nvim-linux-x86_64 /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-x86_64.tar.gz

FROM tools-install AS runtime

## Copy uv into runtime layer
COPY --from=uv /uv /usr/bin/uv

USER $USERNAME

## Copy zellij config
RUN mkdir -p ~/.config/zellij
COPY --chown=$USERNAME:$USERNAME config/zellij/zellij.kdl /home/$USERNAME/.config/zellij/config.kdl

## Copy neovim config
RUN mkdir -p ~/.config/nvim
COPY --chown=$USERNAME:$USERNAME config/neovim/ /home/$USERNAME/.config/nvim/

## Install syst bash completions
RUN mkdir -p ~/.local/share/bash-completion/completions && \
    syst completion bash > ~/.local/share/bash-completion/completions/syst

## Initialize atuin for bash
RUN echo 'eval "$(atuin init bash)"' >> ~/.bashrc
## Source syst completions
RUN echo 'source ~/.local/share/bash-completion/completions/syst' >> ~/.bashrc

WORKDIR /workspace

CMD [ "bash" ]
