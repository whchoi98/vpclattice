aws ec2 describe-instances --filters 'Name=tag:Name,Values=LatticeWorkshop InstanceClient1' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].InstanceId'
aws ec2 describe-instances --filters 'Name=tag:Name,Values=LatticeWorkshop InstanceClient2' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].InstanceId'
export InstanceClient1=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=LatticeWorkshop InstanceClient1' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].InstanceId')
export InstanceClient2=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=LatticeWorkshop InstanceClient2' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].InstanceId')
echo "export InstanceClient1=${InstanceClient1}"| tee -a ~/.bash_profile
echo "export InstanceClient2=${InstanceClient2}"| tee -a ~/.bash_profile
