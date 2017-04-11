#!/bin/bash
# writes executable and linked librry info for programs used in moga
# 07/18/14
#
# $Id: get_exe_info.sh,v 1.2 2015/07/01 21:57:40 brockc Exp $
#
# $Name:  $



# write dakota executable and linked library info
printf "DAKOTA EXECUTABLE:\n"     
readlink -f $(which dakota)             
printf "\nVERSION INFO:\n"        
dakota -version                   
printf "\nLINKED LIBRARY INFO:\n" 
ldd -v $(which dakota)            

## write elk executable and linked library info
#printf "ELK EXECUTABLE:\n"        
#readlink -f elk                   
#printf "\nLINKED LIBRARY INFO:\n" 
#ldd -v elk                        

# write atompaw executable and linked library info
printf "\n\n\nATOMPAW EXECUTABLE:\n" 
readlink -f $(which atompaw)               
printf "\nLINKED LIBRARY INFO:\n"    
ldd -v $(which atompaw)              

# write socorro executable info and linked library info
printf "\n\n\nSOCORRO EXECUTABLE:\n"  
readlink -f $(which socorro)                
printf "\nLINKED LIBRARY INFO:\n"     
ldd -v $(which socorro)               
