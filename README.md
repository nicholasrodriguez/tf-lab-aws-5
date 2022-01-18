# Terraform State Management

## Examine State with CLI
```
terraform show
terraform state list
```
## Replace a resource with CLI
Terraform usually only updates your infrastructure if it does not match your configuration. You can use the `-replace` flag for `terraform plan` and `terraform apply` operations to safely recreate resources in your environment even if you have not edited the configuration, which can be useful in cases of system malfunction.

In older versions of Terraform, you may have used the terraform taint command to achieve a similar outcome. That command has now been deprecated in favour of the -replace flag,

plan
```
terraform plan -replace="aws_instance.example"
```
apply
```
terraform apply -replace="aws_instance.example"
```

## Move a resource to a different state file
The `terraform state mv` command moves resources from one state file to another. You can also rename resources with `mv`. The move command will update the resource in state, but not in your configuration file. Moving resources is useful when you want to combine modules or resources from other states, but do not want to destroy and recreate the infrastructure.

Move the new new_state resource aws_instance.example_new, to the file in the directory above as specified with the -state-out flag. Set the destination name to the same name, since in this case there is no resource with the same name in the target state file.

```
terraform state mv -state-out=../terraform.tfstate aws_instance.example_new aws_instance.example_new
```

cd ..

```
terraform state list
data.aws_ami.ubuntu
aws_instance.example
aws_instance.example_new
aws_security_group.sg_8080
```
An apply in the root directory will destroy the moved resource as it isn't in the configuration file.
```
terraform state list
data.aws_ami.ubuntu
aws_instance.example
aws_security_group.sg_8080
```
Change to new_state and run `terraform destroy` nothing should be destroyed.

## Remove a resource from state

The `terraform state rm` subcommand removes specific resources from your state file. This does not remove the resource from your configuration or destroy the infrastructure itself.

```
terraform state rm aws_security_group.sg_8080
```
Confirm
```
terraform state list
data.aws_ami.ubuntu
aws_instance.example
```
The removed security_group resource does not exist in the state, but the resource still exists in your AWS account.

Run `terraform import` to bring this security group back into your state file. Removing the security group from state did not remove the output value with its ID, so you can use it for the import.

```
terraform import aws_security_group.sg_8080 $(terraform output -raw security_group)
```

## Refresh modified infrastructure

The `terraform refresh` command updates the state file when physical resources change outside of the Terraform workflow. Delete the instance outside of Terraform and refresh the state.
```
aws ec2 terminate-instances --instance-ids $(terraform output -raw instance_id)
terraform refresh
terraform state list
```
The `terraform refresh` command does not update your configuration file. Run `terraform plan` to review the proposed infrastructure updates. Comment out the following from main.tf and run apply
* resource "aws_instance" "example"
* output "instance_id"
* output "public_ip"
Nothing is destroyed in the infrastructure.
