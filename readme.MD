nproc --> To check how many CPU's are there in the machine
set -x --> Used to run the script in debug mode i.e, place at the top of the script and when we runs the script it will display the command and output of that command for better readability.
set -e --> It exits the script when there is an error
set -o pipefail --> set -e doesn't ignore the errors when there is pipe symbol in the command    i.e, if there is wrong command before the pipe and if there is correct command after the pipe then the script will execute the command so for that we are using this commmand.

We can keep all the above commands in a single line by using --> set -exo pipefail (Not recommended)

trap --> 

jq --> It is known as json parser