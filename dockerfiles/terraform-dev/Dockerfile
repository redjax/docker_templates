ARG TERRAFORM_VERSION=${TERRAFORM_VER:-1.9.8}
ARG TERRAFORM_LS_VERSION=${TERRAFORM_LS_VER:-0.34.3}
ARG TFSEC_VERSION=${TFSEC_VER:-1.28.10}
ARG TFLINT_VERSION=${TFLINT_VER:-0.53.0}

FROM debian:bookworm-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/bin:${PATH}"

## Install common dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    lsb-release \
    wget \
    tar \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

## Create non-root user
ARG USERNAME=tfuser
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
ARG TERRAFORM_VERSION
ARG TERRAFORM_LS_VERSION
ARG TFSEC_VERSION
ARG TFLINT_VERSION

## Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az bicep install && \
    rm -rf /var/lib/apt/lists/*

## Install Terraform
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -q -o "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" terraform && \
    mv terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

## Install terraform-ls
RUN wget "https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_amd64.zip" && \
    unzip -q -o "terraform-ls_${TERRAFORM_LS_VERSION}_linux_amd64.zip" terraform-ls && \
    mv terraform-ls /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform-ls && \
    rm "terraform-ls_${TERRAFORM_LS_VERSION}_linux_amd64.zip"

## Install tfsec
RUN wget "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" -O /usr/local/bin/tfsec && \
    chmod +x /usr/local/bin/tfsec

## Install tflint
RUN wget "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" && \
    unzip -q -o tflint_linux_amd64.zip tflint && \
    mv tflint /usr/local/bin/ && \
    chmod +x /usr/local/bin/tflint && \
    rm tflint_linux_amd64.zip

FROM tools-install AS runtime

USER $USERNAME
WORKDIR /workspace

CMD [ "bash" ]
