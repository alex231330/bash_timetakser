#!/bin/bash

cfg.parser () {
    fixed_file=$(cat $1 | sed 's/ = /=/g') 
    IFS=$'\n' && ini=( $fixed_file )              
    ini=( ${ini[*]//;*/} )                   
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} )
    ini=( ${ini[*]/%]/ \(} )                
    ini=( ${ini[*]/=/=\( } )                 
    ini=( ${ini[*]/%/ \)} )                  
    ini=( ${ini[*]/%\( \)/\(\) \{} )         
    ini=( ${ini[*]/%\} \)/\}} )              
    ini[0]=''                                
    ini[${#ini[*]} + 1]='}'                  
    eval "$(echo "${ini[*]}")"               
}

#Pase Mounth, Day, Year of target time
function parse_date () {
    big_parsed_date=($(echo $1 | tr "/" "\n"))

    dest_m=${big_parsed_date[0]}
    dest_d=${big_parsed_date[1]}
    dest_y=${big_parsed_date[2]}

    #Parse Hours and Minutes of target time 
    time_parsed_date=($(echo $2 | tr ":" "\n"))

    dest_h=${time_parsed_date[0]}
    dest_min=${time_parsed_date[1]}

    echo $dest_y/$dest_m/$dest_d/$dest_h/$dest_min
}
function main {
        
    cfg.parser './dates.ini'
    cfg.section.dates

    dest_date=($(echo ${date} | tr "&" "\n"))

    #Parse dates in ini file
    local cur_date=($(echo $(date +'%m/%d/%Y&%H:%M') | tr "&" "\n"))

    echo ${cur_date[1]}
    echo ${cur_date[0]}

    echo "Current time"
    local c_date=($(echo $( parse_date ${cur_date[0]} ${cur_date[1]} ) | tr "/" "\n"))
    echo ${c_date[0]} ${c_date[1]} ${c_date[2]} ${c_date[3]} ${c_date[4]}

    echo "Computer will be shut down at"
    t_date=($(echo $( parse_date ${dest_date[0]} ${dest_date[1]} ) | tr "/" "\n"))
    echo ${t_date[0]} ${t_date[1]} ${t_date[2]} ${t_date[3]} ${t_date[4]}

    #Compare Years, Mounth, Days, Hours, Minutes using array index iterations

    array=( 0 1 2 3 4 )

    for i in "${array[@]}"
    do
        if [[ ${t_date[$i]} < ${c_date[$i]} ]]
        then 
            echo "Wrong Target Time"
            exit 0
        fi

        while [[ ${t_date[$i]} != ${c_date[$i]} ]] 
        do
            cur_date=($(echo $(date +'%m/%d/%Y&%H:%M') | tr "&" "\n"))
            c_date=($(echo $( parse_date ${cur_date[0]} ${cur_date[1]} ) | tr "/" "\n"))
            #echo ${c_date[0]} ${c_date[1]} ${c_date[2]} ${c_date[3]} ${c_date[4]}
            echo "DOIT"
            sleep 1
        done
    done

}

main

echo "Reboot system"
reboot

exit 0