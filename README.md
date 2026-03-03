# terraform-precommit

## Overview

Reusable pre-commit hooks and CI/CD workflows for Terraform projects. Consumers reference this repo's tags to pin versions and get consistent Terraform validation, security scanning, and secret detection across all their repos.

## Features

- **Pre-commit Workflows**: Automated checks for code quality and consistency
- **Terraform Linting**: Standardized Terraform code validation
- **Code Formatting**: Consistent code style enforcement
- **Automated Updates**: Renovate configuration for dependency management

## GitHub Actions Usage

### Adding Workflows to Your Repository

1. Create a `.github/workflows` directory in your repository if it doesn't exist
2. Create the GitHub Actions workflow with the name you want (like `pre-commit.yaml`)
3. Paste this to activate it in the repo

   ```yaml
   name: Pre-Commit

   on: pull_request
   jobs:
     build:
       uses: MottoWolf/terraform-precommit/.github/workflows/pre-commit-gha.yaml@main
   ```

4. Now terraform pre-commit it´s activated!

## Local Setup

### Prerequisites

Install the required tools:

```bash
pipx install pre-commit
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

### Quick Setup using an alias

For local usage, you can add this function to your shell configuration (e.g., `~/.bashrc` or `~/.zshrc`):

```bash
pre-commit-run() {
    # Check if pre-commit is installed
    if ! command -v pre-commit &> /dev/null; then
        echo "Error: pre-commit is not installed. Please install it first:"
        echo "  pipx install pre-commit"
        return 1
    fi

    local branch=${1:-main}
    shift || true  # Remaining args will be passed to pre-commit
    local base_url="https://raw.githubusercontent.com/MottoWolf/terraform-precommit/$branch/config"
    local files=(".pre-commit-config.yaml" ".tflint.hcl")
    local temp_dir
    temp_dir="$(mktemp -d)" || {
        echo "Error: failed to create temporary directory"
        return 1
    }

    # Always clean up temp dir
    trap 'rm -rf "$temp_dir" 2>/dev/null || true' EXIT

    echo "Downloading configuration files from branch: $branch"

    # Download files
    for file in "${files[@]}"; do
        local url="$base_url/$file"
        if ! curl -fsSL -o "$temp_dir/$file" "$url"; then
            echo "Error: failed to download $file from $url"
            return 1
        fi
    done

    # Run pre-commit
    echo "Running pre-commit checks..."
    if pre-commit run -a --config "$temp_dir/.pre-commit-config.yaml" "$@"; then
        echo "Pre-commit checks completed successfully"
    else
        echo "Pre-commit checks failed"
        return 1
    fi
}
```

### Available Hooks

| Hook | Tool | What it checks |
|------|------|----------------|
| `terraform_fmt` | antonbabenko/pre-commit-terraform | Terraform formatting |
| `terraform_validate` | antonbabenko/pre-commit-terraform | Terraform configuration validity |
| `terraform_tflint` | antonbabenko/pre-commit-terraform | Terraform linting with AWS ruleset |
| `trivy` | Trivy (binary) | Vulnerabilities, secrets, misconfigurations |
| `check-yaml` | pre-commit-hooks | YAML syntax validation |
| `gitleaks` | gitleaks | Hardcoded secrets detection |

### Usage

Run pre-commit checks manually locally:

```bash
pre-commit-run
```

Or let them run automatically on git commit using the GitHub Actions Workflow.

## Configuration Files

- `.github/workflows/pre-commit-gha.yaml`: GitHub Actions reusable workflow
- `config/.pre-commit-config.yaml`: Pre-commit hooks configuration
- `config/.tflint.hcl`: Terraform linter configuration (AWS plugin)
- `renovate.json`: Automated dependency update configuration
