#!/bin/bash
set -euo pipefail

##############################################################################
# Script Function: Automatically locate and load Conda environment configuration,
#                  verify Conda availability, and accept Anaconda Terms of Service (TOS)
##############################################################################

# ========================== Configuration Section (Modify as Needed) ==========================
# Define the list of search paths for Conda profile scripts, covering mainstream Conda installation scenarios
declare -a CONDA_PROFILE_PATHS=(
    # 1. System-wide global installations (default for admin/container environments)
    "/etc/profile.d/conda.sh"
    "/usr/local/miniconda3/etc/profile.d/conda.sh"
    "/usr/local/anaconda3/etc/profile.d/conda.sh"
    "/opt/miniconda3/etc/profile.d/conda.sh"
    "/opt/anaconda3/etc/profile.d/conda.sh"

    # 2. Root user installations (common in containers)
    "/root/miniconda3/etc/profile.d/conda.sh"
    "/root/anaconda3/etc/profile.d/conda.sh"

    # 3. Regular user-level installations (under home directory)
    "${HOME}/miniconda3/etc/profile.d/conda.sh"
    "${HOME}/anaconda3/etc/profile.d/conda.sh"

    # 4. Custom paths specified by environment variables (flexible compatibility)
    "${CONDA_ROOT:-}/etc/profile.d/conda.sh"
    "${CONDA_PREFIX:-/usr/local/miniconda3}/etc/profile.d/conda.sh"
)

# ========================== Utility Function Definitions ==========================
# Logging functions (formatted output to distinguish info, success, and error messages)
log_info() {
    echo -e "\033[36mℹ️  $1\033[0m"  # Cyan color
}

log_success() {
    echo -e "\033[32m✅ $1\033[0m"  # Green color
}

log_error() {
    echo -e "\033[31m❌ $1\033[0m" >&2  # Red color, redirected to stderr
}

# Locate valid Conda profile script
find_conda_profile() {
    local conda_script=""
    for path in "${CONDA_PROFILE_PATHS[@]}"; do
        # Add symbolic link check (-f does not recognize valid symlinks, -e is more universal)
        if [[ -f "${path}" || -L "${path}" ]]; then
            conda_script="${path}"
            break
        fi
    done
    echo "${conda_script}"
}

# Verify if Conda command is available
verify_conda_command() {
    if command -v conda &> /dev/null; then
        local conda_version=$(conda --version 2>&1)
        log_success "Conda command loaded successfully (${conda_version})"
    else
        log_error "Failed to load Conda command: conda not found in PATH"
        exit 1
    fi
}

# Silently accept Anaconda repository Terms of Service
accept_anaconda_tos() {
    log_info "Accepting Anaconda official repository Terms of Service (silent mode)..."
    # Add command error tolerance to avoid script failure if TOS is already accepted
    if ! conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main >/dev/null 2>&1; then
        log_info "Anaconda main repository TOS has already been accepted"
    fi

    if ! conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r >/dev/null 2>&1; then
        log_info "Anaconda r repository TOS has already been accepted"
    fi
    log_success "Anaconda Terms of Service acceptance completed"
}

# ========================== Main Execution Flow ==========================
main() {
    log_info "Starting Conda environment initialization..."

    # 1. Locate Conda profile script
    local CONDA_PROFILE_SCRIPT=$(find_conda_profile)
    if [[ -z "${CONDA_PROFILE_SCRIPT}" || ! ( -f "${CONDA_PROFILE_SCRIPT}" || -L "${CONDA_PROFILE_SCRIPT}" ) ]]; then
        log_error "No valid Conda profile script found in the specified paths"
        log_info "Paths checked:"
        for path in "${CONDA_PROFILE_PATHS[@]}"; do echo "  - ${path}"; done
        log_info "Hint: Verify the correct Conda installation path in your container/environment"
        exit 1
    fi

    # 2. Load Conda configuration
    log_info "Loading Conda profile configuration from: ${CONDA_PROFILE_SCRIPT}"
    # shellcheck source=/dev/null (suppress shellcheck warning for dynamic path)
    source "${CONDA_PROFILE_SCRIPT}"

    # 3. Verify Conda availability
    verify_conda_command

    # 4. Accept Anaconda TOS
    accept_anaconda_tos

    log_success "Conda environment initialization completed successfully. The conda command is now available."
}

# Execute main workflow
main "$@"
