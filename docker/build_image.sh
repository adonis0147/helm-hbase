#!/usr/bin/env bash

set -e

SCRIPT_PATH="$(
	cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
	pwd
)"
declare -r SCRIPT_PATH

arch="$(uname -m)"
if [[ "${arch}" == 'arm64' ]]; then
	arch='aarch64'
fi

if [[ "${arch}" == 'x86_64' ]]; then
	# shellcheck disable=2034
	declare -r JAVA_URL="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-${arch/86_/}_bin.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='311f1448312ecab391fe2a1b2ac140d6e1c7aea6fbf08416b466a58874f2b40f'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-${arch}_bin.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='31c2fa06f3f98d92984a86269c71e6b9e956272084f3a1d2db6d07e6164b2f4f'
fi

# shellcheck disable=2034
declare -r HBASE_URL='https://archive.apache.org/dist/hbase/2.6.2/hbase-2.6.2-bin.tar.gz'
# shellcheck disable=2034
declare -r HBASE_SHA256SUM='5ff9a3993031f5a9e1d94fd795fb9ff8ee003b90570e476c63af6d3dd744a583'

function download() {
	local package
	package="$(echo "${1}" | awk '{print toupper($0)}')"
	local url_variable="${package}_URL"
	local checksum_variable="${package}_SHA256SUM"

	local url="${!url_variable}"
	local checksum="${!checksum_variable}"
	local filename
	filename="$(basename "${url}")"

	local SHA256SUM
	SHA256SUM="$(command -v gsha256sum || true)"
	if [[ ! -f "${filename}" ]] || ! echo "${checksum} ${filename}" | "${SHA256SUM:-sha256sum}" --check &>/dev/null; then
		curl -LO "${url}"
	fi
}

function build_hbase() {
	download 'java'
	download 'hbase'

	docker build -t local/hbase .

	minikube image load --alsologtostderr local/hbase:latest
}

function main() {
	pushd "${SCRIPT_PATH}"

	build_hbase

	popd
}

main "${@}"
