#!/bin/bash

run_test(){
echo "======= Running '$1' =======" | tee -a /var/log/demo/demo.out /proc/1/fd/1
$1 | tee -a  /var/log/demo/demo.out /proc/1/fd/1
echo -e "\n" | tee -a /var/log/demo/demo.out /proc/1/fd/1
}

run_all_tests_to() {

#run_test "pscheduler troubleshoot"
run_test "pscheduler task throughput -t 30 --dest $1"
run_test "pscheduler task latency --packet-count 6000 --packet-interval .01 --dest $1"
run_test "pscheduler task --tool tracepath trace --dest $1"

}

#Waiting for a limited time for services to start up and be ready
sleep 20
i="0"
pscheduler troubleshoot
while [ $? -ne 0 ] && [ $i -le 4 ]
do
echo "Local perfSONAR services are not ready yet...waiting for 15 secs before checking again...." | tee -a /var/log/demo/demo.out /proc/1/fd/1
sleep 15
#to limit loop iterations to 4 times
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
