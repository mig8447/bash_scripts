#!/bin/bash

case "$_os_name" in
    # Only set the Perl environment variables in macOS
    ( Darwin )
        # Only if the directory exists
        if [[ -d "$HOME"'/perl5' && -r "$HOME"'/perl5' ]]; then
	        export PERL_HOME="$HOME"'/perl5'
	
	        export PERL5LIB="$PERL_HOME/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
	        export PERL_LOCAL_LIB_ROOT="$PERL_HOME${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
	        export PERL_MB_OPT="--install_base \"$PERL_HOME\""; export PERL_MB_OPT
	        export PERL_MM_OPT="INSTALL_BASE=$PERL_HOME"; export PERL_MM_OPT
	
	        prepend_path_to_path "$PERL_HOME"'/bin'
        fi
        ;;
esac
