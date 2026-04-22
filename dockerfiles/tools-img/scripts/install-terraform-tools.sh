#!/usr/bin/env bash
set -euo pipefail

echo "Installing Terraform ecosystem tools"

## Versions (can be overridden by build args)
TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.9.8}"
TERRAFORM_LS_VERSION="${TERRAFORM_LS_VERSION:-0.34.3}"
TFSEC_VERSION="${TFSEC_VERSION:-1.28.10}"
TFLINT_VERSION="${TFLINT_VERSION:-0.53.0}"

ARCH="amd64"
OS="linux"

## Install Terraform
echo "Installing Terraform ${TERRAFORM_VERSION}"

wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
unzip -q -o "terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip" terraform

chmod +x terraform

mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"

## Verify installation
terraform version

## Install Terraform Language Server
echo "Installing terraform-ls ${TERRAFORM_LS_VERSION}"

wget -q "https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_${OS}_${ARCH}.zip"
unzip -q -o "terraform-ls_${TERRAFORM_LS_VERSION}_${OS}_${ARCH}.zip" terraform-ls

chmod +x terraform-ls

mv terraform-ls /usr/local/bin/
rm "terraform-ls_${TERRAFORM_LS_VERSION}_${OS}_${ARCH}.zip"

## Verify installation
terraform-ls version

## Install tfsec (security scanner)
echo "Installing tfsec ${TFSEC_VERSION}"

wget -q "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_${OS}_${ARCH}.tar.gz"
tar -xzf "tfsec_${TFSEC_VERSION}_${OS}_${ARCH}.tar.gz" tfsec

chmod +x tfsec

mv tfsec /usr/local/bin/
rm "tfsec_${TFSEC_VERSION}_${OS}_${ARCH}.tar.gz"

## Verify installation
tfsec --version

## Install tflint (linter)
echo "Installing tflint ${TFLINT_VERSION}"

wget -q "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_${OS}_${ARCH}.zip"
unzip -q -o "tflint_${OS}_${ARCH}.zip" tflint

chmod +x tflint

mv tflint /usr/local/bin/
rm "tflint_${OS}_${ARCH}.zip"

## Verify installation
tflint --version

## Clean up any leftover files
rm -f LICENSE* CHANGELOG* README*

echo "Terraform ecosystem tools installed successfully!"
echo "  - Terraform: ${TERRAFORM_VERSION}"
echo "  - terraform-ls: ${TERRAFORM_LS_VERSION}"
echo "  - tfsec: ${TFSEC_VERSION}"
echo "  - tflint: ${TFLINT_VERSION}"
