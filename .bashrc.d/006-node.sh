#!/bin/bash

function _set_npm_proxy(){
    local exit_code=0


    if [[ -n "$http_proxy" ]]; then
        npm config set proxy "$http_proxy" 
    else
        npm config rm proxy
    fi

    if [[ -n "$https_proxy" ]]; then
        npm config set https-proxy "$https_proxy"
    else
        npm config rm https-proxy
    fi

    return "$exit_code"
}

_set_npm_proxy

export NODE_ENV='development'

