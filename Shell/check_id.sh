#!/usr/bin/bash

function verify_soeid {

    # Asign the first argument to remove cross-variable carriage.
    soeid=${1};

    # Flag to capture if any checks fail, better this way instead of writing multi-level if-loops
    invalid_flag=0

    # Check the length, allow ONLY =7
    if [[ ${#soeid} -eq 7 ]]; then

        # The first part breaks down the variable in to individual character with placeholder number and so on. 0 indicates the first character and 1 indicates the length. If the checks fails it will mark the flag to 1.
        # The second part will check if it is a alphabet.
        echo ${soeid:0:1} | grep -q "[[:alpha:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }
        echo ${soeid:1:1} | grep -q "[[:alpha:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }

        # The first part breaks down the variable in to individual character with placeholder number and so on. 0 indicates the first character and 1 indicates the length. If the checks fails it will mark the flag to 1.
        # The second part will check if it is a number.
        echo ${soeid:2:1} | grep -q "[[:digit:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }
        echo ${soeid:3:1} | grep -q "[[:digit:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }
        echo ${soeid:4:1} | grep -q "[[:digit:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }
        echo ${soeid:5:1} | grep -q "[[:digit:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }
        echo ${soeid:6:1} | grep -q "[[:digit:]]"
        [[ $? -eq 0 ]] || { invalid_flag=1 ; }

        # Final check.
        if [[ ${invalid_flag} -eq 0 ]]; then
            echo "--> Valid SOEID: ${soeid}"
        else
            echo "Invalid SOEID: ${soeid}"
        fi
    else
        echo "len: Invalid SOEID: ${soeid}"
    fi
}

# Mimic Jenkins parameterized below, this will be supplied by the pipeline.
SOEID="sr87813 1234567 abcdged sr87s13 srr87813 s87813 sr878133 sr8781 ab12345"

# Loop thru the IDs
for soe_id in $(echo ${SOEID}); do
    # For every id call the function verify_soeid
    verify_soeid ${soe_id}
done

#end_check_ids.sh
