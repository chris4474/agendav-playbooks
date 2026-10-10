#!/bin/sh
set -e
source_dir=./init_db.d
myscript_log() {
    echo "$@"
}

if /usr/bin/find "${source_dir}/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    myscript_log "$0: ${source_dir}/ is not empty, will attempt to perform configuration"

    myscript_log "$0: Looking for shell scripts in /docker-entrypoint.d/"
    find "${source_dir}/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.envsh)
                if [ -x "$f" ]; then
                    myscript_log "$0: Sourcing $f";
                    . "$f"
                else
                    # warn on shell scripts without exec bit
                    myscript_log "$0: Ignoring $f, not executable";
                fi
                ;;
            *.sh)
                if [ -x "$f" ]; then
                    myscript_log "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    myscript_log "$0: Ignoring $f, not executable";
                fi
                ;;
            *.sql)
                ;; 
            *) myscript_log "$0: Ignoring $f";;
        esac
    done

    myscript_log "$0: Configuration complete; ready for start up"
else
    myscript_log "$0: No files found in ${source_dir}/, skipping configuration"
fi

