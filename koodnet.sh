#!/usr/bin/env bash

set -e  # Exit the script if any command fails

# Determine system architecture and OS type
OS_ARCH=$(arch)
OS_TYPE=$(uname)

# Ensure the OS is Linux
[[ "${OS_TYPE}" == "Linux" ]] || { echo "Only Linux is supported!"; exit 1; }
# Ensure the script is run as root
[[ "${UID}" == 0 ]] || { echo "Please run this as root!"; exit 1; }

# Determine architecture to use for downloading appropriate binary
case "${OS_ARCH}" in
  aarch64) ARCH="arm_64" ;;
  armv5*) ARCH="arm_5" ;;
  armv6*) ARCH="arm_6" ;;
  armv7*) ARCH="arm_7" ;;
  i386) ARCH="386" ;;
  i686) ARCH="386" ;;
  x86_64) ARCH="amd64_v1" ;;
  x86) ARCH="386" ;;
  *) ARCH="unknown" ;;
esac

# Exit if unknown architecture
[[ "${ARCH}" != "unknown" ]] || { echo "Unknown CPU arch!"; exit 1; }

# Set OSARCH variable for downloading correct artifact
export OSARCH="$(echo ${OS_TYPE}|sed -e 's/Linux/linux/g')_${ARCH}"

# Set default paths for installation and configuration
: ${BIN_DIR:=/usr/local/bin}
: ${KOODNETPATH:=/etc/koodnet} # Customize this at your own risk. koodnet expects its config to be in /etc/koodnet!
: ${KN_VERSION:="latest"}
: ${DOWNLOAD_SERVER:="https://q3x8.c13.e2-2.dev/releases/koodnet/dist"} # Binaries storage
: ${KOODNET_SERVER:="https://koodnet.koodeyo.com/api"} # Koodnet server
: ${ENROLLMENT_CODE:=""} # Enrollment code

# Fetch the correct download URL based on system architecture
KOODNET_DOWNLOAD_URL="${DOWNLOAD_SERVER}/koodnet_${OSARCH}/koodnet"

# Create the configuration directory for koodnet if it doesn't exist
mkdir -p "${KOODNETPATH}"

# Check if required directories exist
[[ -d ${KOODNETPATH} ]] || { echo "The ${KOODNETPATH} directory does not exist! Please create it!"; exit 1; }

# Function to download and install koodnet
download_and_install() {
  # Download and install koodnet if it's not already installed
  if [[ -f ${BIN_DIR}/koodnet ]]; then
    echo "${BIN_DIR}/koodnet is already installed!"
    echo "Stop koodnet and remove ${BIN_DIR}/koodnet to reinstall."
    echo "Skipping koodnet download and install..."
  else
    echo "Downloading binary from ${KOODNET_DOWNLOAD_URL}"
    # Download koodnet and give executable permission
    if curl -sSL ${KOODNET_DOWNLOAD_URL} -o ${BIN_DIR}/koodnet; then
      chmod +x ${BIN_DIR}/koodnet
      echo "Finished downloading."
    else
      echo "Failed to download koodnet. Please check the download URL or your network connection."
      exit 1
    fi
  fi

  echo "Koodnet installed successfully"
}

# Function to enroll host
enroll_host() {
  if [[ -f ${BIN_DIR}/koodnet ]]; then
    echo "Enrolling koodnet with code: ${ENROLLMENT_CODE}"
    ${BIN_DIR}/koodnet -enroll=true -code=${ENROLLMENT_CODE} -server=${KOODNET_SERVER}
    echo "Koodnet enrollment completed successfully"
  else
    echo "Koodnet binary not found at ${BIN_DIR}/koodnet. Please install it first."
    exit 1
  fi
}

# Call the download and install function
download_and_install

# Call the enroll function
if [[ -n "${ENROLLMENT_CODE}" ]]; then
  enroll_host
fi
