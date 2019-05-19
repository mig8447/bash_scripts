#!/bin/bash

function confirm_rm {
    local exit_code=0

    # shellcheck disable=SC2154
    if [[ "$_is_interactive_shell" -eq 0 ]]; then
        read -rp 'Are you sure you want to use the "rm" command? (Type "Yes" '\
'to confirm or anything else to exit): ' \
            && {
                {
                    [[ "$REPLY" =~ ^[Yy]$ ]] \
                    && echo 'ERROR: Please type "Yes"' >&2 \
                    && ( exit 1 );
                } \
                || {
                    [[ "$REPLY" == 'Yes' ]] \
                    && command rm -v "$@";
                };
            }
        exit_code="$?"
    else
        rm "$@"
        exit_code="$?"
    fi

    return "$exit_code"
}

function record_terminal(){
    # TODO: Check prerequisites
    local exit_code=0
    local recording_name="${1:-recording_"$( current_datetime )"}"
    local timing_file_path="$TERMINAL_TYPESCRIPTS_DIR"'/'"$recording_name"'.timing.ts'
    local log_file_path="$TERMINAL_TYPESCRIPTS_DIR"'/'"$recording_name"'.ts'

    if [[ ! -f "$timing_file_path" && ! -f "$log_file_path" ]]; then
        echo 'INFO: record_terminal: Now Recording "'"$recording_name"'"...'
        script --timing="$timing_file_path" "$log_file_path"
        exit_code="$?"
        echo 'INFO: record_terminal: "'"$recording_name"'" recording has finished'
    else
        exit_code=1
        echo 'ERROR: record_terminal: Either the timing or the log file for "'"$recording_name"'" already exist' >&2
    fi

    return "$exit_code"
}
function play_terminal_recording(){
    # TODO: Check prerequisites
    local exit_code=0
    local recording_name="$1"
    local timing_file_path="$TERMINAL_TYPESCRIPTS_DIR"'/'"$recording_name"'.timing.ts'
    local log_file_path="$TERMINAL_TYPESCRIPTS_DIR"'/'"$recording_name"'.ts'
    # 1x speed playback by default
    local speed="${2:-1}"

    if [[ -n "$recording_name" ]]; then
        if [[ -f "$timing_file_path" && -r "$timing_file_path" && -f "$log_file_path" && -r "$log_file_path" ]]; then
            echo 'INFO: play_terminal_recording: Now Playing "'"$recording_name"'"...'
            scriptreplay --divisor="$speed" --timing="$timing_file_path" --typescript="$log_file_path"
            exit_code="$?"
            echo 'INFO: play_terminal_recording: "'"$recording_name"'" ended'
        else
            exit_code=1
            echo 'ERROR: play_terminal_recording: Either timing or log files for recording "'"$recording_name"'" don'"'"'t exist or are not readable by the current user' >&2
        fi
    else
        exit_code=1
        echo 'ERROR: play_terminal_recording: You must provide a recording name' >&2
    fi

    return "$exit_code"
}

function vimrcd(){
    local exit_code=0

    local bashrc_directory="$HOME"'/.bashrc.d/'
    local file_name_pattern="$1"
    local file_name=""

    if [[ ! -z "$file_name_pattern" ]]; then
        file_name_pattern='*'"$file_name_pattern"'*'
        if file_name="$( set -o pipefail; find "$bashrc_directory" -iname "$file_name_pattern" -type f 2>/dev/null | sort -u | head -n 1 )"; then
            if [[ ! -z "$file_name" ]]; then
                vim "$file_name"
                exit_code="$?"
            else
                echo 'ERROR: vimrcd: Could not find a match for pattern "'"$file_name_pattern"'" in "'"$bashrc_directory"'"'
                exit_code=1
            fi
        else
            echo 'ERROR: vimrcd: An error occurred while searching for pattern "'"$file_name_pattern"'" in "'"$bashrc_directory"'"'
            exit_code=1
        fi
    else
        # Edit the .bashrc.d directory
        vim -c 'e '"$bashrc_directory"
        exit_code="$?"
    fi

    return "$exit_code"
}
function pyhttpserver(){
    local exit_code=0;
    local port="${1:-8080}"

    python -m SimpleHTTPServer "$port"

    return "$exit_code"
}

# Find files and directories recursively, as with ls -p, directories are appended a / character
function findp(){
    local exit_code=0
    local path="${1:-.}"

    find -L "$path" \( \( -type d -and -regex '.*?[^/]$' -printf '%p/\n' \) -or -print \)

    exit_code="$?"
    return "$exit_code"
}

# Convert string to json
function str2json(){
    local exit_code=0
    local string="$1"

    # jq is much more faster and should be used if available
    if command -v jq &>/dev/null; then
        jq -n --arg string "$string" '$string'
    else
        echo -n "$string" | python -c 'import json, sys; print( json.dumps( sys.stdin.read() ) )'
    fi

    return "$exit_code"
}

# urlencode
function urlencode(){
    local exit_code=0
    local string="$1"

    echo -n "$string" | python -c 'import urllib, sys; print urllib.quote( sys.stdin.read(), "" )'
    exit_code=$?

    return "$exit_code"
}

# Lists the ipv4s of all the ipv4 network interfaces
# TODO: Put the main jq script in a variable to make the code more maintainable
function lsipv4(){
    local exit_code=0

    # Function information
    local long_name='List Interface'"'"'s IPv4'
    local description='List the IPv4 addresses of all IPv4 enabled network interfaces'
    local version='1.0.0'

    # Function variables
    local print_headers=true
    # All supported jq formats (https://stedolan.github.io/jq/manual/#Formatstringsandescaping)
    # text, json, html, uri, csv, tsv, sh, base64, and table, (Note base64d is not on the list) which
    # prints a table using the tsv jq format and then reformatting the output
    # using the column command
    local output_format='json'
    local compact_json=false
    local output

    # Option parsing variables
    local option
    # Needed to localize this variable not to have strange behaviors when
    # running then function multiple times
    local OPTIND

    while getopts ":f:cHh" option; do
        case "$option" in
            f)
                output_format="$OPTARG"
                ;;
            c)
                compact_json=true
                ;;
            H)
                print_headers=false
                ;;
            h)
                cat <<-USAGE
$long_name (${FUNCNAME[0]}) $version

$description

Usage: ${FUNCNAME[0]} [OPTION]...

Options
    -f    Output format. Accepted values: table, json(*Default), csv, tsv, sh
    -c    Compact JSON. If output is to be formatted as JSON then instead of
          producing an array with objects, it will produce a single object
          where its keys will be the interface name and its values the IPv4
          values
    -H    Remove headers from output, except when output is formatted as JSON

Other Options
    -h    Prints this message and exits
USAGE
                return "$exit_code"
                ;;
            \?)
                echo "WARNING: Invalid option -$OPTARG" >&2
                ;;
            :)
                echo "ERROR: Option -$OPTARG requires an argument" >&2
                exit_code=1
                ;;
        esac
    done

    if [[ "$exit_code" -eq 0 ]]; then
        # Validate option compatibility
        if [[ "$output_format" == 'json' ]]; then
            if [[ "$print_headers" == false ]]; then
                echo 'WARNING: Output format is set to JSON. Remove headers option will be ignored' >&2
            fi
        else
            if [[ "$compact_json" == true ]]; then
                echo 'WARNING: Output format is not set to JSON. Compact JSON option will be ignored' >&2
            fi
        fi

        case "$_os_name" in
            ( Linux )
                if command -v ip &>/dev/null \
                    && command -v jq &>/dev/null
                then
                    output="$(
                        set -o pipefail;
                        # Show the avilable ipv4 addresses
                        ip -4 address show \
                            | perl -0777 -ne 'print "\n$2\t$3" while /([^:]+?:\s+)?([^:]+?):(?:.*?)((?<=inet\s)[^\s\/]+).*?\2/sg' \
                            | tail -n +2 \
                            | jq -Rs '. | split("\n") | map( split("\t") | { interface_name: .[0], ipv4: .[1] } )'
                    )"
                    exit_code="$?"
                else
                    echo 'ERROR: ip command from iproute2 and jq are required' >&2
                    exit_code=1
                fi
                ;;
            ( Darwin )
                if command -v ip &>/dev/null \
                    &&  ip help 2>&1 \
                        | grep iproute2mac &>/dev/null \
                    && command -v jq &>/dev/null
                then
                    output="$(
                        set -o pipefail;
                        # Show the avilable ipv4 addresses
                        ip -4 address show \
                            | perl -0777 -ne 'print "\n$1\t$2" while /([^:]+?):(?:.*?)((?<=inet\s)[^\s\/]+).*?\1/sg' \
                            | tail -n +2 \
                            | jq -Rs '. | split("\n") | map( split("\t") | { interface_name: .[0], ipv4: .[1] } )'
                    )"
                    exit_code="$?"
                else
                    echo 'ERROR: iproute2mac and jq are required. Install them using homebrew' >&2
                    exit_code=1
                fi
                ;;
        esac

        if [[ "$exit_code" -eq 0 ]]; then
            # Assuming we have utilities.jq module (Which contains the
            # array_of_simple_objects_to_format function) at ~/.jq/utilities.jq
            # which is true for bash_scripts repo
            case "$output_format" in
                json )
                    if [[ "$compact_json" == true ]]; then
                        output="$( jq 'map( { key: .interface_name, value: .ipv4 } ) | from_entries' <<< "$output" )"
                    fi
                    ;;
                table )
                    output="$(
                        set -o pipefail;
                        jq -r 'import "utilities" as u; . | u::array_of_simple_objects_to_format( @tsv )' <<< "$output" \
                            | column -ts $'\t'
                    )"
                    exit_code="$?"
                    ;;
                * )
                    output="$( jq -r 'import "utilities" as u; . | u::array_of_simple_objects_to_format( @'"$output_format"' )' <<< "$output" )"
                    exit_code="$?"
                    ;;
            esac

            if [[ "$print_headers" == false && "$output_format" =~ html|uri|csv|tsv|sh|base64|table ]]; then
                output="$( tail -n +2 <<< "$output" )"
                exit_code="$?"
            fi

            cat <<< "$output"
        fi
    fi

    return "$exit_code"
}

