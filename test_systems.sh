#!/usr/bin/env bash
# shellcheck disable=SC2181
# -----------------------------------------------------------------------------
#  PURPOSE: This script is intended to help Terraform while your public IP
#           IP address changes; for cunsultants or those without a static
#           address form their ISPs. It currently supports Terraform apply or
#           destroy operations.
# -----------------------------------------------------------------------------
#  PREREQS: a) A requisite AMI must exist within the AWS Account.
#           b) The current directory must contain:
#              1) *.tf files, OR
#              2) terraform.tfstate* files.
#              But it's okay if there are both.
# -----------------------------------------------------------------------------
#  EXECUTE: ./test_systems.sh --opt1 --opt2
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
set -x

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
# initialize variables to a default
verbose=0


###----------------------------------------------------------------------------
### Functions
###----------------------------------------------------------------------------
### Turn on debug output if requested
###---
debug_ouput() {
    if [[ "$verbose" -ne '1' ]]; then
        set -x
    fi
}

###---
### Display Help message
###---
show_help()   {
    printf '\n%s\n\n' """
    Please review this help information and try again.
    Description: Build or Destroy systems at will.
    Usage: ./test_systems.sh [OPTION1] [OPTION2]...

    OPTIONS:
    -b, --build       Build a new system from the *.tf files in the current directory.
                      Example: ./test_systems.sh --build

    -d, --destroy     Destroy a system corresponding to the state files in the
                      current directory.
                      Example: ./test_systems.sh -v -d

    -c, --cleanup     After a glitch and manual intervention is required, reset
                      the state and remove the log file from the last run.
                      Example: ./test_systems.sh --cleanup

    -ip, --ip-check   Verify the current gateway address
                      Example: ./test_systems.sh -ip

    -r, --retest      Quickly rebuild a system; calls destroy, then build.
                      Example: ./test_systems.sh -v --retest

    -v, --verbose     Turn on 'set -x' debug output.
    """
}

###---
### On failure, Abort further processing an exit.
###---
preemie()   {
    printf '\n%s\n\n' """
    Abort! Abort!
    """
    exit 1
}

###---
### Check for failure, exit if necessary.
###---
tfCheck()   {
    if [[ $? -ne 0 ]]; then
        preemie
    else
        return
    fi
}

###---
### Get the Public IP address of the gateway at the current location.
###---
getCurrentIP() {
    currentIPAddress="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    if [[ -z "$currentIPAddress" ]]; then
        printf '%s\n' "OMG! You have NO IP ADDRESS!!!"
        preemie
    else
        echo "myIPAddress=$currentIPAddress/32"
    fi
}

success_message() {
    printf '\n%s\n\n' """
        Ready for Testing!
    """
}

###---
### Build it!
###---
build_it() {
    date
    getCurrentIP
    ###---
    ### Validate the Terraform files (current working directory)
    ###---
    terraform validate
    tfCheck

    ###---
    ### Display the plan
    ###---
    terraform plan -var "myIPAddress=$currentIPAddress/32" \
        -var "AWS_PROFILE=$USER"
    tfCheck

    ###---
    ### Build it!
    ###---
    terraform apply -var "myIPAddress=$currentIPAddress/32" \
        -var "AWS_PROFILE=$USER"
    if [[ $? -eq '1' ]]; then
        preemie
    else
        success_message
    fi
    date
}

###---
### Destroy it!
###---
destroy_it() {
    date
    getCurrentIP
    terraform destroy -force -var "myIPAddress=$currentIPAddress/32" \
        -var "AWS_PROFILE=$USER"
    date
}

###---
### These 2 functions only exist to test this script. They should only be used
### when further expanding it.
###---
print_error_noval() {
    printf 'ERROR: "--file" requires a non-empty option argument.\n' >&2
    exit 1
}
# FUNCTION: confirm the argument value is non-zero and
test_opts() {
    myVar=$1
    if [[ -n "$myVar" ]]; then
        export retVal="$myVar"
    else
        print_error_noval
    fi
}

###---
### Clean up after a failure that requires manual intervention
###---
clean_up() {
    currentState=('terraform.tfstate' 'terraform.tfstate.backup')
    ###---
    ### Echo all elements in the array
    ###---
    for stateFile in "${currentState[@]}"; do
        if [[ -s "$stateFile" ]]; then
            printf '%s\n' "  zeroing-out: $stateFile"
            rm -f "$stateFile"
        fi
    done
    # Remove the log file as well
    printf '%s\n\n' "Removing Terraform log file"
    rm -f 'terraform.log'
}


###-----------------------------------------------------------------------------
### MAIN PROGRAM
###-----------------------------------------------------------------------------
### Parse Arguments
###---
#set -x
#echo "$@"
#echo "$#"
while :; do
    case "$1" in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -b | --build)       # Build the systems
            build_it
            shift 2
            break
            ;;
        -c | --cleanup)     # Reset the tfstate files
            clean_up
            shift 2
            break
            ;;
        -d | --destroy)     # Tear them down again
            destroy_it
            #test_opts "$2"
            #echo "$#"
            #echo "$@"
            shift 2
            break
            ;;
        -ip | --ip-check)   # get the gateway address only
            getCurrentIP
            shift 2
            break
            ;;
        -r | --retest)      # Tear down and build again in 1 motion
            destroy_it
            build_it
            shift 2
            break
            ;;
        -v | --verbose)
            debug_ouput
            ;;
        --) # End of all options.
            shift
            break
            ;;
        -?*)
            printf '%s' '  WARN: Unknown option (ignored):' "  '$1'" >&2
            printf '\n%s\n\n' '  Run: ./test_systems.sh --help for more info.'
            exit
            ;;
        *)  # Default case: If no more options then break out of the loop.
            show_help
            break
    esac
    shift
done


###----------------------------------------------------------------------------
### Wrap it up
###----------------------------------------------------------------------------


###---
### fin~
###---
exit 0






