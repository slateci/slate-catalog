#!/bin/bash

is_valid_fqdn() {
pattern='(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)+[a-zA-Z]{2,63}$)'
#echo "checking $1 now"
r=$( echo "$1" | grep -P $pattern)

if [ "$r" = "$1" ]; then
  return 0 # true  
else
  return 1 # false  
fi

}

run_test(){

echo "======= Running '$1' =======" | tee -a /var/log/demo/demo.out /proc/1/fd/1
$1 | tee -a  /var/log/demo/demo.out /proc/1/fd/1
echo -e "\n" | tee -a /var/log/demo/demo.out /proc/1/fd/1
}

run_all_tests_to() {

if is_valid_fqdn "$1"; then 
	
        run_test "pscheduler task throughput -t 30 --dest $1"
	run_test "pscheduler task latency --packet-count 6000 --packet-interval .01 --dest $1"
	run_test "pscheduler task --tool tracepath trace --dest $1"
else 

	echo "Error: '$1' is not a valid FQDN" | tee -a /var/log/demo/demo.out /proc/1/fd/1 

fi

}


#Waiting for a limited time for services to start up and be ready
sleep 20
i="0"
pscheduler troubleshoot
while [ $? -ne 0 ] && [ $i -le 4 ]
do
echo "Local perfSONAR services are not ready yet...waiting for 15 secs before checking again...." | tee -a /var/log/demo/demo.out /proc/1/fd/1
sleep 15
#Limiting loop iterations to 4 times
i=$(( $i + 1 ))
#echo "Checking the status of local perfSONAR services..."
pscheduler troubleshoot
done

#start running tests and show output to user
run_test "pscheduler troubleshoot"
run_all_tests_to "sl-um-ps01.slateci.io"
run_all_tests_to "uofu-ddc-dmz-latency.chpc.utah.edu"
run_all_tests_to "sl-uu-es1.slateci.io"
echo  "All tests have finished" >> /var/log/demo/demo.out
