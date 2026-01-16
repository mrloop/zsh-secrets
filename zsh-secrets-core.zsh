#!/usr/bin/env zsh
# Core functionality for zsh-secrets - works standalone or as a plugin

# Main secrets function
function secrets() {
    local subcommand=${1:?Subcommand must be specified}
    local file_name=${2:?The secret must be specified}
    local secret_name=${file_name:t}
    local recipient=${ZSH_SECRETS_RECIPIENT:-${RECEPIENT:?GPG recipient must be specified through ZSH_SECRETS_RECIPIENT or RECEPIENT env var}}
    local default_storage="$HOME/.secrets"
    local storage=${ZSH_SECRETS_STORAGE:-${SECRETS_STORAGE:-$default_storage}}
    local secret_filename="$storage/$secret_name.gpg"
    
    # Ensure storage directory exists
    [[ ! -d "$storage" ]] && mkdir -p "$storage"
    
    # Helper functions (defined locally to avoid namespace pollution)
    function _realpath() {
        echo $(cd $(dirname $1) 2>/dev/null && pwd)/$(basename $1)
    }
    
    function _decrypt_to_out() {
        gpg --decrypt "$secret_filename"
    }
    
    function _source_secrets() {
        local file
        {source $file} 3<> ${file::==(gpg -q --decrypt "$secret_filename" 2>/dev/null)}
        export SESSION_SECRETS=true
    }
    
    function _decrypt() {
        gpg -q --decrypt "$secret_filename"
    }
    
    function _encrypt() {
        echo "Encrypting $secret_name as $secret_filename"
        local file=$(_realpath "$file_name")
        if gpg --batch --yes --output "$secret_filename" --encrypt --recipient "$recipient" "$file"; then
            echo "Removing $file"
            rm "$file"
        else
            echo "Failed to encrypt $file"
            return 1
        fi
    }
    
    function __secrets_rm_internal() {
        if [[ -f "$secret_filename" ]]; then
            rm "$secret_filename"
            echo "Removed $secret_name"
        else
            echo "Secret not found: $secret_name"
            return 1
        fi
    }
    
    # Execute subcommand
    case $subcommand in
        source)
            _source_secrets
            ;;
        decrypt)
            _decrypt
            ;;
        encrypt)
            _encrypt
            ;;
        rm)
            __secrets_rm_internal
            ;;
        *)
            echo "Unknown subcommand $1. source, decrypt, encrypt or rm must be used"
            return 1
            ;;
    esac
    
    # Clean up helper functions
    unfunction _decrypt _source_secrets __secrets_rm_internal _decrypt_to_out _realpath 2>/dev/null
}

# Completion function
function _secrets() {
    local default_storage="$HOME/.secrets"
    local storage=${ZSH_SECRETS_STORAGE:-${SECRETS_STORAGE:-$default_storage}}
    
    if (( CURRENT > 2 )); then
        # shift words so _arguments doesn't have to be concerned with second command
        (( CURRENT-- ))
        shift words
        # use _call_function here in case it doesn't exist
        _call_function 1 _secrets_${words[1]}
    else
        _values "secrets command" \
            "source[Load a secret into current session.]" \
            "encrypt[Encrypt a file and move it to $storage.]" \
            "decrypt[Decrypt a secret and print to stdout.]" \
            "rm[Delete a file from $storage.]"
    fi
}

function __list_secrets() {
    local default_storage="$HOME/.secrets"
    local storage=${ZSH_SECRETS_STORAGE:-${SECRETS_STORAGE:-$default_storage}}
    
    if [[ -d "$storage" ]]; then
        local secrets=($(ls "$storage" 2>/dev/null))
        local clean_secrets=()
        for secret in $secrets; do
            clean_secrets+=($secret:r)
        done
        
        _arguments "1: :($clean_secrets)"
    fi
}

function _secrets_encrypt() {
    _arguments '*:filename:_files'
}

function _secrets_decrypt() {
    __list_secrets
}

function _secrets_source() {
    __list_secrets
}

function _secrets_rm() {
    __list_secrets
}

# Register completion (only if completion system is available)
if type compdef >/dev/null 2>&1; then
    compdef _secrets secrets
fi