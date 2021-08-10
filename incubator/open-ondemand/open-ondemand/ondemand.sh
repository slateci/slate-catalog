#!/bin/bash
echo "run helm install? [y/n] "
read yesno
if [[ "$yesno" = "y" ]]
then
        helm install slate-ood .
        ready=$(kubectl get pods | grep slate-ood | awk '{print $2}') # prints 1/1 or 0/1 for each pod
        until [[ ${ready} == "2/2" ]]
        do
                ready=$(kubectl get pods | grep slate-ood | awk '{print $2}')
                echo "..."
                sleep 3
        done
elif [[ "$yesno" = "n" ]]
then
        :
else
        echo "please enter 'y' or 'n'"
fi
echo "run exec command? [y/n] " && read yesno2
id_pattern="pierce-ood-open-ondemand-[a-z0-9]{8,10}-[a-z0-9]{5}"
pod_id=$(kubectl get pods | grep -o -E $id_pattern)
if [[ "$yesno2" = "y" ]]
then
        echo "ondemand or keycloak? " && read kcod
        if [[ "$kcod" = "ondemand" ]]
        then
                kubectl exec -it $pod_id -c open-ondemand -- bash
        elif [[ "$kcod" = "keycloak" ]]
        then
                kubectl exec -it $pod_id -c keycloak -- bash
        else
                echo "please enter 'ondemand' or 'keycloak'"
        fi
elif [[ "$yesno2" = "n" ]]
then
        echo "exiting..."
else
        echo "please enter 'y' or 'n'"
fi