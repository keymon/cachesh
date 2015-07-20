#!/bin/bash

__CACHESH_STORE_DIR=${__CACHESH_STORE_DIR:-$HOME/.cachesh/cache}
__CACHESH_TTL=60
__CACHESH_COMMAND=$0

__cachesh_usage() {
	cat <<EOF
cachesh is a wrapper command to cache the output, stderr and exit code of
any random command and program. Just use it before any command.

It's purpose is speed up executions of scripts, bootstraps, common tasks, etc.

Usage:

	$__CACHESH_COMMAND <command> [args|...]
EOF
}

__cachesh_compute_key() {
	echo "$@" | shasum -a 256 | cut -f 1 -d ' '
}

__cachesh_exec_command() {
	local key_dir=$1; shift
	local current_time=$1; shift
	local stdout_file=$key_dir/stdout
	local stderr_file=$key_dir/stderr
	local exit_code_file=$key_dir/exit_code
	local timestamp_file=$key_dir/timestamp
	local exit_code
	# Redirect stdout and stderr into a log file.
	mkdir -p $key_dir
	exec 6>&1 7>&2
	exec >  >(tee $stdout_file)
	exec 2> >(tee $stderr_file >&2)
	"$@"
	exit_code=$?
	echo $exit_code > $exit_code_file
	echo $current_time > $timestamp_file
	# Restore stdout and stderr
	exec 1>&- 1>&6 6>&-
	exec 2>&- 2>&7 7>&-

	return $exit_code
}


__cachesh_cache_call() {
	local key=$(__cachesh_compute_key "$@")
    local key_dir="$__CACHESH_STORE_DIR/$key"
	local stdout_file=$key_dir/stdout
	local stderr_file=$key_dir/stderr
	local exit_code_file=$key_dir/exit_code
	local timestamp_file=$key_dir/timestamp
    local cache_time
	local current_time=$(date +%s)

	local use_cache=0
    if [ -d "$key_dir" ]; then
		local cache_time=$(< $timestamp_file)
		cache_time=${cache_time:-0}
		if [ $(( $current_time - $cache_time )) -lt $__CACHESH_TTL ]; then
			use_cache=1
		fi
	fi

	if [ $use_cache == 0 ]; then
		__cachesh_exec_command $key_dir $current_time "$@"
	else
		# FIXME implement something to merge the two outputs at the same time
        cat $stdout_file
        cat $stderr_file >&2
		return $(<$exit_code_file)
	fi
}


__cachesh_main() {
	if [ ! "$@" ]; then
		__cachesh_usage
		exit 0
	fi
	__cachesh_cache_call "$@"
}

__cachesh_main "$@"

