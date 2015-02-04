#Script for testing programs
#!/bin/bash

ErrFunction (){
	if [ ! -r ${line}.in ] || [ ! -r ${line}.out ]; then
		echo "Error: ${line}.in or ${line}.out is unreadable" 1>&2
		exit 1
	fi 
}

#check number of arguments
if [ $# -ne 2 ]; then
	echo "Number of Arguments mismatch" 1>&2
	exit 1
fi

#loop through the test suite
while read line; do
	#checks if the .in and .out files are readable
	ErrFunction

#check if .args file exist
	if [ -e ${line}.args ]; then
		if [ -r ${line}.args ]; then
			${2} $(cat ${line}.args) < ${line}.in > tempOut.txt 		
			valgrind ${2} $(cat ${line}.args) < ${line}.in | egrep "All heap blocks freed"
			if [ $? -ne 0 ]; then
				echo "Memory leak for ${line}"
			fi
		else
			echo "$line.args is not readable" 1>&2 
			exit 1
		fi
	#The case where there are no args
	else
		${2} < ${line}.in > tempOut.txt
		valgrind ${2} $(cat ${line}.args) < ${line}.in | egrep "All heap blocks freed"
			if [ $? -ne 0 ]; then	
				echo "Memory leak for ${line}"
			fi
	fi
	
        diff ${line}.out tempOut.txt > /dev/null
        	if [ $? -ne 0 ]; then
                echo "Test failed: ${line}"
                echo "Input:"
                cat ${line}.in
                echo "Expected:"
                cat ${line}.out
                echo "Actual:"
                cat tempOut.txt
        fi
	rm tempOut.txt
done < ${1}
