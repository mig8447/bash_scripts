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

if [ "$_os_name" == 'Darwin' ] \
    && ip help 2>&1 | grep iproute2mac &>/dev/null \
    && command -v ip &>/dev/null \
    && command -v jq &>/dev/null
then
    # Lists the ipv4s of all the ipv4 network interfaces
    function lsipv4(){
        local exit_code=0

        case "$_os_name" in
            ( Linux )
                ;;
            ( Darwin )
                if ip help 2>&1 \
                    | grep iproute2mac &>/dev/null \
                    && command -v ip &>/dev/null \
                    && command -v jq &>/dev/null
                then
                    (
                        set -o pipefail;
                        # Show the avilable ipv4 addresses
                        ip -4 address show \
                            | perl -0777 -ne 'print "\n$1\t$2" while /([^:]+?):(?:.*?)((?<=inet\s)[^\s\/]+).*?\1/sg' \
                            | tail -n +2 \
                            | jq -Rs '. | split("\n") | map( split("\t") | { key: .[0], value: .[1] } ) | from_entries'
                    )
                else
                    echo 'ERROR: iproute2mac and jq are required. Install them using homebrew' >&2
                    exit_code=1
                fi
                ;;
        esac

        (
            set -o pipefail;
            # Show the avilable ipv4 addresses
            ip -4 address show \
                | perl -0777 -ne 'print "\n$1\t$2" while /([^:]+?):(?:.*?)((?<=inet\s)[^\s\/]+).*?\1/sg' \
                | tail -n +2 \
                | jq -Rs '. | split("\n") | map( split("\t") | { key: .[0], value: .[1] } ) | from_entries'

#ip -4 address show | perl -0777 -ne 'print "\n$2\t$3" while /([^:]+?:\s+)?([^:]+?):(?:.*?)((?<=inet\s)[^\s\/]+).*?\2/sg' | tail -n +2 | jq -Rs '. | split("\n") | map( split("\t") | { key: .[0], value: .[1] } ) | from_entries'
        )
        exit_code="$?"

        return "$exit_code"
    }
fi

