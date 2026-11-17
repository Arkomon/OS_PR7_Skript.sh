#!/bin/bash

usage() {
    echo "Usage: $0 [-u|--users] [-p|--processes] [-h|--help] [-l|--log PATH] [-e|--errors PATH]"
}

list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

list_processes() {
    ps -eo pid,comm --sort=pid
}

main() {
    opts=$(getopt -o uphl:e: -l users,processes,help,log:,errors: -- "$@") || {
        usage >&2
        exit 1
    }
    eval set -- "$opts"

    action=""
    log_file=""
    err_file=""

    while true; do
        case "$1" in
            -u|--users)     action="users"; shift ;;
            -p|--processes) action="processes"; shift ;;
            -h|--help)      usage; exit 0 ;;
            -l|--log)       log_file="$2"; shift 2 ;;
            -e|--errors)    err_file="$2"; shift 2 ;;
            --)             shift; break ;;
            *)              usage >&2; exit 1 ;;
        esac
    done

    if [ -n "$log_file" ]; then
        touch "$log_file" 2>/dev/null || { echo "Нет доступа к $log_file" >&2; exit 1; }
        exec 1>"$log_file"
    fi

    if [ -n "$err_file" ]; then
        touch "$err_file" 2>/dev/null || { echo "Нет доступа к $err_file" >&2; exit 1; }
        exec 2>"$err_file"
    fi

    case "$action" in
        users)     list_users ;;
        processes) list_processes ;;
        *)         echo "Не указано действие (-u или -p)" >&2; usage >&2; exit 1 ;;
    esac
}

main "$@"
