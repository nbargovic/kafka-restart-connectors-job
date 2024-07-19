#!/bin/bash

if [ -z $3 ] ; then
  echo "Usage: ./restart-connectors.sh <connect-api-route> <username> <password>"
  echo "Example: ./restart-connectors.sh https://connect.my.domain.com connect-user password123"
  exit 1
fi

url=$1
user=$2
pass=$3

response=$(curl -k -s -o /dev/null -w "%{http_code}" "${url}" -u "${user}":"${pass}")

if [[ "$response" -ne 200 ]] ; then
  echo "Error code ${response} from the connect rest API. Please make sure the url, username, and password are correct. Also ensure the connect service is running."
  exit 1
fi

date
echo 'Looking for failed tasks and connectors...'
curl -k -s "${url}/connectors?expand=info&expand=status" -u "${user}":"${pass}" | jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"] | join(":|:")' | grep FAILED

echo 'Restarting failed tasks...'
curl -k -s "${url}/connectors?expand=status" -u "${user}":"${pass}" | jq -c -M 'map({name: .status.name } +  {tasks: .status.tasks}) | .[] | {task: ((.tasks[]) + {name: .name})}  | select(.task.state=="FAILED") | {name: .task.name, task_id: .task.id|tostring} | ("/connectors/"+ .name + "/tasks/" + .task_id + "/restart")'
curl -k -s "${url}/connectors?expand=status" -u "${user}":"${pass}" | jq -c -M 'map({name: .status.name } +  {tasks: .status.tasks}) | .[] | {task: ((.tasks[]) + {name: .name})}  | select(.task.state=="FAILED") | {name: .task.name, task_id: .task.id|tostring} | ("/connectors/"+ .name + "/tasks/" + .task_id + "/restart")' | xargs -I{connector_and_task} curl -k -s -X POST "${url}"\{connector_and_task\} -u "${user}":"${pass}"

echo 'Restarting failed connectors...'
curl -k -s "${url}/connectors?expand=status" -u "${user}":"${pass}" | jq -c -M 'map({name: .status.name } + {status: .status.connector.state}) | .[] | select(.status=="FAILED") | ("/connectors/"+ .name + "/restart")'
curl -k -s "${url}/connectors?expand=status" -u "${user}":"${pass}" | jq -c -M 'map({name: .status.name } + {status: .status.connector.state}) | .[] | select(.status=="FAILED") | ("/connectors/"+ .name + "/restart")'| xargs -I{connector_and_task} curl -k -s -X POST "${url}"\{connector_and_task\} -u "${user}":"${pass}"

echo 'Done.'