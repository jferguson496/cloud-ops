# Usage

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.gha-runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecr_lifecycle_policy.remove_stale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.external_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_eip.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.gha-runner_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.gha-runner_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks-worker-eks-worker-ssm-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.gha-runner-AmazonEC2ContainerRegistryPowerUser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_launch_template.gha-runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.gha-runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_ipv4_cidr_block_association.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_ami.gha-runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecr_external_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.twilio_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS CLI profile (as seen in ~/.aws/config) | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy to (e.g. us-east-1) | `string` | n/a | yes |
| <a name="input_ecr_dev_image_tag_prefix"></a> [ecr\_dev\_image\_tag\_prefix](#input\_ecr\_dev\_image\_tag\_prefix) | Dev image tag prefix. Ie. dev matches nginx:dev-alpine | `string` | n/a | yes |
| <a name="input_ecr_dev_image_timeout"></a> [ecr\_dev\_image\_timeout](#input\_ecr\_dev\_image\_timeout) | After how many days should dev images be deleted. | `number` | n/a | yes |
| <a name="input_ecr_external_access"></a> [ecr\_external\_access](#input\_ecr\_external\_access) | AWS entities allowed to read from this repository | `list(string)` | n/a | yes |
| <a name="input_ecr_image_scanning"></a> [ecr\_image\_scanning](#input\_ecr\_image\_scanning) | Wether to scan images on push | `bool` | n/a | yes |
| <a name="input_ecr_image_timeout"></a> [ecr\_image\_timeout](#input\_ecr\_image\_timeout) | After how many days should images be deleted. | `number` | n/a | yes |
| <a name="input_ecr_repositories"></a> [ecr\_repositories](#input\_ecr\_repositories) | List of repositories to create | `set(string)` | n/a | yes |
| <a name="input_ecr_tag_mutability"></a> [ecr\_tag\_mutability](#input\_ecr\_tag\_mutability) | Can the image tags be changed / replaced | `bool` | n/a | yes |
| <a name="input_gha_runner_agent_archive"></a> [gha\_runner\_agent\_archive](#input\_gha\_runner\_agent\_archive) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_agent_archive_hash"></a> [gha\_runner\_agent\_archive\_hash](#input\_gha\_runner\_agent\_archive\_hash) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_agent_name_prefix"></a> [gha\_runner\_agent\_name\_prefix](#input\_gha\_runner\_agent\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_agent_token"></a> [gha\_runner\_agent\_token](#input\_gha\_runner\_agent\_token) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_agent_url"></a> [gha\_runner\_agent\_url](#input\_gha\_runner\_agent\_url) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_count"></a> [gha\_runner\_count](#input\_gha\_runner\_count) | GHA Runner | `number` | n/a | yes |
| <a name="input_gha_runner_extra_labels"></a> [gha\_runner\_extra\_labels](#input\_gha\_runner\_extra\_labels) | n/a | `string` | `""` | no |
| <a name="input_gha_runner_instance_type"></a> [gha\_runner\_instance\_type](#input\_gha\_runner\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_gha_runner_ssh_master_key"></a> [gha\_runner\_ssh\_master\_key](#input\_gha\_runner\_ssh\_master\_key) | n/a | `string` | `""` | no |
| <a name="input_gha_runner_ssm_enabled"></a> [gha\_runner\_ssm\_enabled](#input\_gha\_runner\_ssm\_enabled) | n/a | `bool` | n/a | yes |
| <a name="input_gha_runner_volume_iops"></a> [gha\_runner\_volume\_iops](#input\_gha\_runner\_volume\_iops) | n/a | `number` | `null` | no |
| <a name="input_gha_runner_volume_size"></a> [gha\_runner\_volume\_size](#input\_gha\_runner\_volume\_size) | n/a | `number` | n/a | yes |
| <a name="input_gha_runner_volume_throughput"></a> [gha\_runner\_volume\_throughput](#input\_gha\_runner\_volume\_throughput) | n/a | `number` | `null` | no |
| <a name="input_gha_runner_volume_type"></a> [gha\_runner\_volume\_type](#input\_gha\_runner\_volume\_type) | n/a | `string` | n/a | yes |
| <a name="input_r53_zones"></a> [r53\_zones](#input\_r53\_zones) | Route53 | `any` | `{}` | no |
| <a name="input_s3_ops_aes_encryption"></a> [s3\_ops\_aes\_encryption](#input\_s3\_ops\_aes\_encryption) | Wether to encrypt the ops bucket with AES256 | `bool` | `false` | no |
| <a name="input_s3_ops_bucket"></a> [s3\_ops\_bucket](#input\_s3\_ops\_bucket) | S3 bucket that holds tf states, keys, etc | `string` | n/a | yes |
| <a name="input_scripts_dir"></a> [scripts\_dir](#input\_scripts\_dir) | n/a | `string` | n/a | yes |
| <a name="input_twilio_proxy_caddy_version"></a> [twilio\_proxy\_caddy\_version](#input\_twilio\_proxy\_caddy\_version) | n/a | `string` | n/a | yes |
| <a name="input_twilio_proxy_r53_domain"></a> [twilio\_proxy\_r53\_domain](#input\_twilio\_proxy\_r53\_domain) | n/a | `string` | n/a | yes |
| <a name="input_twilio_proxy_r53_zone"></a> [twilio\_proxy\_r53\_zone](#input\_twilio\_proxy\_r53\_zone) | Twilio callback proxy | `string` | n/a | yes |
| <a name="input_vpc_private_cidr_block"></a> [vpc\_private\_cidr\_block](#input\_vpc\_private\_cidr\_block) | n/a | `string` | n/a | yes |
| <a name="input_vpc_private_subnet_newbits"></a> [vpc\_private\_subnet\_newbits](#input\_vpc\_private\_subnet\_newbits) | n/a | `number` | n/a | yes |
| <a name="input_vpc_public_cidr_block"></a> [vpc\_public\_cidr\_block](#input\_vpc\_public\_cidr\_block) | VPC | `string` | n/a | yes |
| <a name="input_vpc_public_subnet_newbits"></a> [vpc\_public\_subnet\_newbits](#input\_vpc\_public\_subnet\_newbits) | n/a | `number` | n/a | yes |
| <a name="input_vpc_subnet_count"></a> [vpc\_subnet\_count](#input\_vpc\_subnet\_count) | n/a | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_twilio_proxy_domain"></a> [twilio\_proxy\_domain](#output\_twilio\_proxy\_domain) | n/a |
| <a name="output_twilio_proxy_eip"></a> [twilio\_proxy\_eip](#output\_twilio\_proxy\_eip) | n/a |

<!--- END_TF_DOCS --->

