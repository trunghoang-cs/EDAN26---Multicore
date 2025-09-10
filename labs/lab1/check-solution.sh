#/bin/bash

for x in ../data/tiny/*.in ../data/railwayplanning/*/*.in
do
	echo $x
	pre=${x%.in}
	ans=$pre.ans
	$* < $x > all-output
	grep -E '^[0-9]+$' all-output > out
	if diff $ans out
	then
		echo PASS $x 
		rm out
	else
		echo FAIL $x
		exit 1
	fi
done

for x in ../data/big/00[01].in
do
	echo $x
	pre=${x%.in}
	ans=$pre.ans
	$* < $x > all-output
	grep -E '^[0-9]+$' all-output > out
	if diff $ans out
	then
		echo PASS $x 
		rm out
	else
		echo FAIL $x
		exit 1
	fi
done
