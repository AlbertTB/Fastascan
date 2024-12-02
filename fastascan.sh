FOLDER=$1
N=$2

# Check if a value for the folder argument has been passed and if not defaulting to current folder
if [[ -z $FOLDER ]];
	then FOLDER=.
fi

# Check if value of $FOLDER is a directory (if not, throw error) and checking whether there are fasta files in it or not
if [[ -d $FOLDER ]];
	then if [[ $(find $FOLDER -name "*.fa" -or -name "*.fasta" | wc -l) -eq 0 ]];
		then echo There are no fasta files in this folder or its subfolders.
	
	# Counting number of fasta files inside the folder and its subfolders and the number of unique IDs in them
	else	
		echo There are $(find $FOLDER -name "*.fa" -or -name "*.fasta"| wc -l) fasta files.
		echo
		echo There are $(grep ">" *.fa *.fasta 2> /dev/null | awk '{print $1}' | sort | uniq -c | wc -l) unique IDs in readable files.
		echo
	fi;
else
	echo Please input a valid directory or leave the first argument blank by using '""' or "''" 
	exit 1
fi

# Check if second argument is a positive integer (if not, throw error) and if it is null default to 0
if [[ $N =~ ^[0-9]+$ ]];
	then continue
	
elif [[ -z $N ]];
	then N=0
	
else
	echo Second argument must be a positive integer
	exit 2
fi

# Generate a report for each fasta file
for file in $(find $FOLDER -name "*.fa" -or -name "*.fasta"); do
	
	echo
	
	echo ========== $file report ==========
	
	echo

	# Check if file is empty
	if [[ ! -s $file ]];
		then echo -File is empty
		echo
		echo //////////////////////////////////////////////////////////////////////////
		continue
	fi
	
	# Check if file is readable and if it is a binary file
	if [[ -r $file && $(grep -v ">" $file 2> /dev/null | sed 's/-//g; s/\n//g' | tr '[a-z]' '[A-Z]') =~ [A-Z]+$ ]];
		then echo -File is readable
		echo
	
	else 
		echo -File is not readable or is a binary file
		echo
		echo //////////////////////////////////////////////////////////////////////////
		continue
	fi

	# Check if the file is a symlink
	if [[ -h $file ]]; 
		then echo -It is a symlink
		
	else 
		echo -It is not a symlink
		
	fi


	echo

	# Count the number of sequences in the file and the total length of the sequences
	if [[ $(grep -c ">" $file) == 1 ]];
		then echo -There is one sequence in this file
		echo
		grep -v ">" $file | sed 's/-//g; s/\n//g' | awk '{x = x + length($0)}END{print "-Total length of sequence: " x}'
		
	elif [[ $(grep -c ">" $file) == 0 ]]; 
		then echo -There are no sequences in this file
		
	else 
		echo -There are $(grep -c ">" $file) sequences in this file
		echo
		grep -v ">" $file | sed 's/-//g; s/\n//g' | awk '{x = x + length($0)}END{print "-Total length of sequences: " x}'
	fi
	
	echo
	
	# Check if the file contains nucleotides or aminoacids
	if [[ $(grep -v ">" $file | sed 's/-//g; s/\n//g' | tr '[a-z]' '[A-Z]') =~ [ATGCN]+$ ]];
		then echo -This file only contains nucleotides
		echo
		
	else
		echo -This file contains aminoacids
		echo
	fi

	# Print the whole file or only N first lines and N end lines
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



