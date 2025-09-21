#!/usr/bin/env bash

isRoot() {
	if [[ $UID -ne 0 ]]; then
		
		echo 'You must run this script as follows sudo ./ipxe_install.sh... Thank you!'
		exit 1	
	fi		

}




main() {
echo 'Installing required packages...' 

while IFS="," read -r _package_name _do_install; do
    	
	if [[ ${_do_install} == 'y' ]]; then
       		echo "Installing ${_package_name}" 
        	dnf install ${_package_name} -y | tee -a /var/log/deploy/deploy_ipxe > /dev/null 2>&1 

        	if [[ $? -eq 1 ]]; then
            
			echo "${_package_name} installed successfully"
        	elif [[ $? -eq 0 ]]; then
            
			echo "${_package_name} failed to install"
        	else
            
			echo "Unknown error or it could already be installed"
        	fi
	 
	else 
		echo "${_package_name} skipped" 
		
	fi

done < ipxe_install.csv

# Set the working directory to the top of the deployment stack
pushd /zachs_lab/ > /dev/null 2>&1  # Silence pushd output

# Clone the repo but suppress git output
git clone https://github.com/ipxe/ipxe.git > /dev/null 2>&1

# Return to previous directory
popd > /dev/null 2>&1

# Set the working directory to the top of the source files
pushd /zachs_lab/ipxe/src/ > /dev/null 2>&1  # Silence pushd output

# Build from source and input data into a log file
make | tee -a /var/log/deploy/deploy_ipxe > /dev/null 2>&1 

# Clean up the source directory
rm -rf /zachs_lab/ipxe > /dev/null 2>&1  # Silence rm output

# Return to previous directory
popd > /dev/null 2>&1
}

isRoot
main
