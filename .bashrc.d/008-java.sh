#!/bin/bash

case "$_os_name" in
    # Only set the JAVA_HOME in Linux Systems
    ( Linux )
        # Only set it if the JAVA_HOME variable is unset
        if [[ -z ${JAVA_HOME+set} ]]; then
            export JAVA_HOME="$( dirname "$( dirname "$( readlink -e "$( which java )" )" )" )"
        fi
        ;;
esac

