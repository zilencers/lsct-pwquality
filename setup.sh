#!/bin/bash

PAM_PASSWD="/etc/pam.d/passwd"

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
    
    printf "Max number of retries (default ${RULES[retry]}): "
    read retries

    printf "Minimum password length (default ${RULES[minlen]}): "
    read min_length

    printf "Minimum digits (default 1): "
    read min_digits

    printf "Minimum uppercase letters (default 1): "
    read min_upper

    printf "Minimum lowercase letters (default 1): "
    read min_lower

    printf "Minimum special characters (default 1): "
    read min_special

    printf "Number of characters used from old password (default ${RULES[difok]}): "
    read diff_chars

    printf "Enforce the rules for root? (y/N): "
    read root_enforcement
}

set_quality_rules() {
    [ ! -z "$retries" ] && RULES[retry]=$retires
    [ ! -z "$min_length" ] && RULES[minlen]=$min_length
    [ ! -z $min_digits ] && RULES[dcredit]=-$min_digits
    [ ! -z "$min_upper" ] && RULES[ucredit]=-$min_upper
    [ ! -z "$min_lower" ] && RULES[lcredit]=-$min_lower
    [ ! -z "$min_special" ] && RULES[ocredit]=-$min_special
    [ ! -z "$diff_chars" ] && RULES[difok]=$diff_chars
    
    if [ "$root_enforcement" == "N" ] ; then 
        RULES['enforce_root']=''
    fi

    [ -f $PAM_PASSWD.bak ] && rm $PAM_PASSWD.bak
    touch $PAM_PASSWD.bak

    echo "#%PAM-1.0" >> "$PAM_PASSWD.bak"
    echo "password   required   pam_pwquality.so retry=${RULES[retry]} minlen=${RULES[minlen]} difok=${RULES[difok]} dcredit=${RULES[dcredit]}\
    ucredit=${RULES[ucredit]} lcredit=${RULES[lcredit]} ocredit=${RULES[ocredit]} ${RULES['enforce_root']}" >> $PAM_PASSWD.bak
    echo "password   required   pam_unix.so use_authtok sha512 shadow" >> $PAM_PASSWD.bak

    cp $PAM_PASSWD.bak $PAM_PASSWD
}

reset_password() {
    echo ""
    echo "Password Quality Rules are now setup"
    printf "Would you like to reset your password now? (y/N): "
    read answer

    if [ "$answer" == "y" ] ; then 
        echo "Password Requirements:"
        echo "  * minimum ${RULES[minlen]} character in length"
        echo "  * at least ${RULES[difok]} characters should be different from previous password"
        echo "  * at least ${RULES[dcredit]} digit"
        echo "  * at least ${RULES[ucredit]} uppercase"
        echo "  * at least ${RULES[lcredit]} lowercase"
        echo "  * at least ${RULES[ocredit]} other character"
        echo ""
        echo "Please enter a new password:"
    
        passwd $(whoami)
        touch PASS
    fi
}

title() {
    echo "--------------------------------------------"
    echo "          Password Quality Rules"
    echo "--------------------------------------------"
}

main() {
    title
    install_pkgs $@
    get_quality_rules
    set_quality_rules
    reset_password
}

main $@
