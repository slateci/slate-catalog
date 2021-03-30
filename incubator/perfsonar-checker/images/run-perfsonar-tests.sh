#!/bin/bash

print() {
echo $1 | tee -a /var/log/perfsonar-checker/checker.log /proc/1/fd/1
}

print_to_terminal() {
#echo $1 >> /proc/1/fd/1
cat $1 >> /proc/1/fd/1
}

print_to_flog() {
cat $1 >> /var/log/perfsonar-checker/checker.log
}

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

#echo "======= Running "$1" =======" | tee -a /var/log/demo/demo.out /proc/1/fd/1
echo "======= Running: '$1' =======" | print_to_flog
output=`eval "$1"`
#echo "$output" >> all.out
#echo ">>>" >> all.out
if echo "$1" | grep  -q "pscheduler task throughput" ; then
	if echo "$output" | grep -q 'Run did not complete' ; then 
		echo "Run did not complete...Please make sure the destination is a full toolkit install or supports this test." | print_to_terminal
	else
                echo "$output" | grep  -A3 'Summary' | print_to_terminal
	fi
elif echo "$1" | grep  -q "pscheduler task latency" ; then
	echo "$output" | grep  -A7 'Packet Statistics' | print_to_terminal

elif echo "$1" | grep -q "pscheduler task --tool tracepath trace --dest" ; then
        
        echo "$output" | grep ^[1-9] | wc -l | awk '{print "Number of hops to destination is: " $1}' | print_to_terminal
else
        echo "$output" | print_to_terminal
fi

echo "$output" | print_to_flog
#$1 | tee -a  /var/log/demo/demo.out /proc/1/fd/1
echo -e "\n" | print 
}

run_all_tests_to() {
if is_valid_fqdn "$1"; then 
	if pscheduler ping $1; then

		print "Running bandwidth test to: '$1' ....."	
		run_test "pscheduler task throughput -t 30 --dest $1"
		print "Running latency test to: '$1' ....."  
		run_test "pscheduler task latency --packet-count 18000 --packet-interval .01 --dest $1"
		print "Checking network path to: '$1' ....."  
		run_test "pscheduler task --tool tracepath trace --dest $1"

        else
		print "The destination host '$1' is either not alive or not reachable. Skipping all tests to this host."
		print ""
        fi
else 

	#echo "Error: '$1' is not a valid FQDN" | tee -a /var/log/demo/demo.out /proc/1/fd/1 
        print "Error: '$1' is not a valid FQDN"
fi

}

mkdir -p /var/log/perfsonar-checker
dst1="$1"
dst2="$2"
dst3="$3"
#Waiting for a limited time for services to start up and be ready
#echo "Waiting for local perfSONAR services to stat up...." | tee -a /var/log/demo/demo.out /proc/1/fd/1
print "Waiting for local perfSONAR services to start up and be ready...."
sleep 3
i="0"
pscheduler troubleshoot
while [ $? -ne 0 ] && [ $i -le 10 ]
do
#echo "Local perfSONAR services are not ready yet...waiting for 15 secs before checking again...." | tee -a /var/log/demo/demo.out /proc/1/fd/1
print "Local perfSONAR services are not ready yet...waiting for few seconds before checking again...."
sleep 3
#Limiting loop iterations to 5 times
i=$(( $i + 1 ))
#echo "Checking the status of local perfSONAR services..."
pscheduler troubleshoot
done

#start running tests and show output to user
run_test "pscheduler troubleshoot"
#run_all_tests_to "sl-um-ps01.slateci.io"
#run_all_tests_to "uofu-ddc-dmz-latency.chpc.utah.edu"
#run_all_tests_to "sl-uu-es1.slateci.io"
print ""
if [ ! -z "$dst1" ]
  then
    run_all_tests_to "$dst1"
fi

if [ ! -z "$dst2" ]
  then
    run_all_tests_to "$dst2" 
fi

if [ ! -z "$dst3" ]
  then
    run_all_tests_to "$dst3" 
fi

print "All tests have finished!"
print "Once you're done reviewing the test results, you can go ahead and delete this deployed instance using the below commnad along with the <instance-ID>:"
print "slate instance delete <instance-ID>"
print ""
print "Alternatively, you can log into the SLATE portal (https://portal.slateci.io/slate_portal) to delete it."
print ""
print "<<<<<<<<<<<< Thank you for using SLATE! >>>>>>>>>>>>"
