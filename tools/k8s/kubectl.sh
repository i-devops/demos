#!/bin/bash

dealArgs(){
	resource=$1
    rstype=$2
    opt=$3
    kubectlAppendCmd=$4

    if [[ ! $opt ]]; then
    	opt=get
    fi
}

getResourceByName(){
    isGetOneRs=$1
    if [[ ! $isGetOneRs ]]; then
       isGetOneRs=Y
    fi

    resourceInfo=`kubectl get $resource --all-namespaces | grep $rstype `
    resourceName=`echo "$resourceInfo" | awk '{print $2}' `
    namespace=`echo "$resourceInfo" | awk '{print $1}' | head -n1`
    if [[ ! $resourceName ]]; then
        echo "No matched $rstype found !"
        exit;
    fi

    if [[ $isGetOneRs==Y || $isGetOneRs==y ]]; then
        resourceName=`echo "$resourceName" | head -n1 `
    fi
}

optResourceByGrepName(){
	getResourceByName
	case $opt in
		log | logs )
			kubectl logs -n $namespace $resourceName $kubectlAppendCmd 
			;;
		exec )
			kubectl exec -n $namespace $resourceName $kubectlAppendCmd 
			;;
		get | edit | delete | describe | top )
			kubectl $opt $resource $kubectlAppendCmd -n $namespace $resourceName	
			;;
		name )
			echo "$resourceName"
			;;
		namespace | ns )
			echo "$namespace"
			;;
		* ) echo "Command not supported yet."
			;;
	esac    
}

dealResourceName(){
    dealCmd="$1"
    optResourceByGrepName | $dealCmd
}

# init
{
	dealArgs $@
}

optResourceByGrepName