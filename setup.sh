#!/bin/bash

declare -A RULES
RULES[retry]=2             # Number retries
RULES[minlen]=12           # Minimum password length
RULES[difok]=6             # Number of characters that should be different from old password
RULES[dcredit]=-1          # Minimum number of digits
RULES[ucredit]=-1          # Minimum number of upprecase letters
RULES[lcredit]=-1          # Minimum number of lowercase letters
RULES[ocredit]=-1          # Miniumu number of special characters
RULES['enforce_root']='enforce_for_root'    

install_pkgs() {
    printf "WARNING: $3 package will be installed. Continue (y/N): "
    read answer
    
    if [ "$answer" == "y" ] ; then 
        echo "Installing Packages...."
        # $1 = Package Manager
        # $2 = Install Cmd
        # $3 = Package
        $@
    else
	    ./lsct
    fi
}

get_quality_rules() {
    echo "The following prompts will guide you through the process"
    echo "of setting up password quality rules."
    echo ""
    
    printf "Max number of retries (default $RETRY): "
    read retries

    printf "Minimum password length (default 12): "
    read min_length

    printf "Minimum digits (default 1): "
    read min_digits

    printf "Minimum uppercase letters (default 1): "
    read min_upper

    printf "Minimum lowercase letters (default 1): "
    read min_lower

    printf "Minimum special characters (default 1): "
    read min_special

    printf "Number of characters used from old password (default $DIFOK): "
    read diff_chars

    printf "Enforce the rules for root? (y/N): "
    read root_enforcement
}

set_quality_rules() {
    [ ! -z "$retries" ] && RULES[retry]=$retires
    [ ! -z "$min_length" ] && RULES[minlen]=$min_length
    [ ! -z $min_digits ] && RULES[dcredit]=$min_digits
    [ ! -z "$min_upper" ] && RULES[ucredit]=$min_upper
    [ ! -z "$min_lower" ] && RULES[lcredit]=$min_lower
    [ ! -z "$min_special" ] && RULES[ocredit]=$min_special
    [ ! -z "$diff_chars" ] && RULES[difok]=$diff_chars
    
    if [ "$root_enforcement" == "N" ] ; then 
        RULES['enforce_root']=''
    fi 

    echo "Retry: " ${RULES[retry]}
    echo ${RULES[minlen]}
    echo ${RULES[dcredit]}
    echo ${RULES[ucredit]}
    echo ${RULES[lcredit]}
    echo ${RULES[ocredit]}
    echo ${RULES[difok]}
    echo ${RULES['enforce_root']}
}

reset_password() {
    echo "Password Requirements:"
    echo "  * 12 characters minimum length"
    echo "  * at least 6 characters should be different from old password when entering a new one"
    echo "  * at least 1 digit"
    echo "  * at least 1 uppercase"
    echo "  * at least 1 lowercase"
    echo "  * at least 1 other character"
    echo "  * cannot contain the words "ipdefender", "ip", "defender" and "firewall" "
    echo ""
    echo "Please enter a new root password:"
    
    passwd root
    touch PASS
}

title() {
    echo "--------------------------------------------"
    echo "          Password Quality Rules"
    echo "--------------------------------------------"
}

main() {
    title
    #install_pkgs $@
    get_quality_rules
    set_quality_rules
}

main $@
