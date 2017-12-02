#! /bin/bash
cd ~
rm nghttp2/src/h2.txt 
declare -a lossArray=(0.1 0.3 0.5 1 2 5); 
declare -a delayArray=(10 25 50 75 100 150 250 300 500 1000); 
LIMIT=20 
count=0 
bool=false 
PDT=0 
totalPDT=0 

for (( j=0; j<${#delayArray[@]}; j=j+1 )) do 
	for (( k=0; k<${#lossArray[@]}; k=k+1 )) do 
		for ((i=0; i < LIMIT ; i=i+1)) do 
			data=$(./nghttp2/src/h2load -n100 -c40 https://$1/)
			#echo $data
			for d1 in $data
			do
				if [ $bool == true ]
				then
					if [[ $d1 == *"ms"* ]]
					then
						l1=`echo ${#d1} - 3 | bc -l`
						PDT=${d1:0:$l1}
						totalPDT=`echo $totalPDT + $PDT | bc -l`
					else 
						n=1000
						l1=`echo ${#d1} - 2 | bc -l`
						PDT=${d1:0:$l1}
						PDT=`echo "$PDT * $n" | bc -l`
						totalPDT=`echo $totalPDT + $PDT | bc -l`
					fi
					bool=false
				fi
				if [ $d1 == 'in' ]
				then
					bool=true
				fi
			done
		done
		echo "" >> ./nghttp2/src/h2.txt
                echo "Network delay: ${delayArray[j]}ms , Packet loss: ${lossArray[k]}, Total PDT: $totalPDT"
		echo "Network delay: ${delayArray[j]}ms , Packet loss: ${lossArray[k]}, Total PDT: $totalPDT">> ./nghttp2/src/h2.txt
		totalPDT=0
		echo "" >> ./nghttp2/src/h2.txt
	done 
done

