#!/bin/bash

function _set_npm_proxy(){
    local exit_code=0

    if command -v npm &>/dev/null; then
        if [[ -n "$http_proxy" ]]; then
            npm config set proxy "$http_proxy" 
        else
            npm config delete proxy
        fi

        if [[ -n "$https_proxy" ]]; then
            npm config set https-proxy "$https_proxy"
        else
            npm config delete https-proxy
        fi
    fi

    return "$exit_code"
}

_set_npm_proxy

if command -v node &>/dev/null; then
    export NODE_ENV='development'
fi

