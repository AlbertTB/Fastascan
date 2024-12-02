FOLDER=$1
N=$2


if [[ -z $FOLDER ]];
	then FOLDER=.
fi


if [[ -d $FOLDER ]];
	if [[ $(find $FOLDER -name "*.fa" -or -name "*.fasta" | wc -l) -eq 0 ]];
		then echo There are no fasta files in this folder or its subfolders.
		
	else	
		echo There are $(find $FOLDER -name "*.fa" -or -name "*.fasta"| wc -l) fasta files.
		echo
		echo There are $(grep ">" *.fa *.fasta 2> /dev/null | awk '{print $1}' | sort | uniq -c | wc -l) unique IDs in readable files.
		echo
	fi
else
	echo Please input a valid directory or leave the first argument blank by using '""' or "''" 
	exit 1
fi


if [[ $N =~ ^[0-9]+$ ]];
	then continue
	
elif [[ -z $N ]];
	then N=0
	
else
	echo Second argument must be a positive integer
	exit 2
fi


for file in $(find $FOLDER -name "*.fa" -or -name "*.fasta"); do
	
	echo
	
	echo ========== $file report ==========
	
	echo


	if [[ ! -s $file ]];
		then echo -File is empty
		echo
		echo //////////////////////////////////////////////////////////////////////////
		continue
	fi
	
	
	if [[ -r $file && $(grep -v ">" $file | sed 's/-//g; s/\n//g' | tr '[a-z]' '[A-Z]') =~ [A-Z]+$ ]];
		then echo -File is readable
		echo
	
	else 
		echo -File is not readable or is a binary file
		echo
		echo //////////////////////////////////////////////////////////////////////////
		continue
	fi

	
	if [[ -h $file ]]; 
		then echo -$file is a symlink
		
	else 
		echo -It is not a symlink
		
	fi


	echo


	if [[ $(grep -c ">" $file) == 1 ]];
		then echo -There is one sequence in this file
		echo
		grep -v ">" $file | sed 's/-//g; s/\n//g' | awk '{x = x + length($0)}END{print "Total length of sequence: " x}'
		
	elif [[ $(grep -c ">" $file) == 0 ]]; 
		then echo -There are no sequences in this file
		
	else 
		echo -There are $(grep -c ">" $file) sequences in this file
		echo
		grep -v ">" $file | sed 's/-//g; s/\n//g' | awk '{x = x + length($0)}END{print "-Total length of sequences: " x}'
	fi
	
	
	if [[ $(grep -v ">" $file | sed 's/-//g; s/\n//g' | tr '[a-z]' '[A-Z]') =~ [ATGCN]+$ ]];
		then echo -This file only contains nucleotides
		echo
		
	else
		echo -This file contains aminoacids
		echo
	fi

	
	if [[ $N != 0 ]];
		then if [[ $(cat $file | wc -l) -le $(( 2 * $N )) ]]; 
			then cat $file
			
		elif [[ $(cat $file | wc -l) -gt $(( 2 * $N )) ]];
			then head -n $N $file
			echo ...
			tail -n $N $file
		fi
		
	fi
	
	
echo

echo //////////////////////////////////////////////////////////////////////////

done



