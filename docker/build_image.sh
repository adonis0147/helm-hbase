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
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/17.0.19.10.1/amazon-corretto-17.0.19.10.1-linux-${arch/86_/}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA512SUM='c2ec54f90191e99dc551e3c072d3ea9e4e20b938162bfbc79cd90ea1065e41705950998f89c134842c8957a8eab29a2a1539512f130d2e8f6370573af564bb7c'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/17.0.19.10.1/amazon-corretto-17.0.19.10.1-linux-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA512SUM='b90dafc4aa4f1d4b26f7081330116b811e2ef3203cdaaf932ee8f7190a886e34cb49309395eceac1efc365312be3e113daa6eafc0e6dcfa594469608c1e7e279'
fi

# shellcheck disable=2034
declare -r HBASE_URL='https://archive.apache.org/dist/hbase/2.6.5/hbase-2.6.5-bin.tar.gz'
# shellcheck disable=2034
declare -r HBASE_SHA512SUM='67c1f59b7530a6f02cce6d3df8c0ba620130862a31828331584eee892922c37fbdb32b9e5320e897e1557d352e2f54aa0ddc097780abcd841a8d494134320a1a'

function download() {
	local package
	package="$(echo "${1}" | awk '{print toupper($0)}')"
	local url_variable="${package}_URL"
	local sha512sum_variable="${package}_SHA512SUM"

	local url="${!url_variable}"
	local checksum="${!sha512sum_variable}"
	local checksum_command
	checksum_command="$(command -v gsha512sum || command -v sha512sum)"
	local filename
	filename="$(basename "${url}")"

	if [[ ! -f "${filename}" ]] || ! echo "${checksum} ${filename}" | "${checksum_command}" --check &>/dev/null; then
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
