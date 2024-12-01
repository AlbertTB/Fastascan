FOLDER=$1
N=$2


if [[ -z $FOLDER ]];
	then FOLDER=.
fi

if [[ $(find $FOLDER -name "*.fa" -or -name "*.fasta" | wc -l) -eq 0 ]];
	then echo There are no fasta files in this folder or its subfolders.
	
else	
	echo There are $(find $FOLDER -name "*.fa" -or -name "*.fasta"| wc -l) fasta files.
	echo
	echo There are $(grep ">" *.fa *.fasta 2> /dev/null | awk '{print $1}' | sort | uniq -c | wc -l) unique IDs in readable files.
	echo
fi;


for file in $(find $FOLDER -name "*.fa" -or -name "*.fasta"); do
	
	echo
	
	echo ========== $file report ==========
	
	echo

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
	
echo

echo //////////////////////////////////////////////////////////////////////////

done



