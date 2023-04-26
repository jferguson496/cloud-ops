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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_autoscaling_group.worker_blue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_group.worker_green](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.eks_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_customer_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_db_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_snapshot.source_rds_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_snapshot) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_eip.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_elasticache_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_elasticache_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_instance_profile.eks_worker_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.application_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cluster-autoscaler-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.external-dns-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.fluentd-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.application_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster-autoscaler-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_developer_user_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_master_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_master_user_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_worker_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.external-dns-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.fluentd-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.application_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-cluster-autoscaler-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-external-dns-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-fluentd-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-master-AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-worker-eks-worker-ssm-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_alias.rds_encryption_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.rds_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.worker_blue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.worker_green](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.main_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.primary_caa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.rds_cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.public_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_secretsmanager_secret.init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_security_group.eks_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_master-ingress-worker-https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker-ingress-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker-ingress-lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker-ingress-self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.eks_worker-ingress-ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_ipv4_cidr_block_association.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpn_connection.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_wafv2_ip_set.admin_whitelist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.internal_service_whitelist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.partner_whitelist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [kubernetes_cluster_role.node_drainer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.node_drainer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_pod_disruption_budget.coredns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget) | resource |
| [random_string.rds_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.source_snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.eks_worker_blue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.eks_worker_green](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.application_role_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external-dns-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [tls_certificate.eks_oidc](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificates"></a> [acm\_certificates](#input\_acm\_certificates) | ACM | <pre>map(object({<br>    san      = list(string)<br>    r53_zone = string<br>  }))</pre> | `{}` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS CLI profile (as seen in ~/.aws/config) | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy to (e.g. us-east-1) | `string` | n/a | yes |
| <a name="input_eks_kubernetes_version"></a> [eks\_kubernetes\_version](#input\_eks\_kubernetes\_version) | n/a | `string` | n/a | yes |
| <a name="input_eks_kubernetes_version_blue"></a> [eks\_kubernetes\_version\_blue](#input\_eks\_kubernetes\_version\_blue) | n/a | `string` | n/a | yes |
| <a name="input_eks_kubernetes_version_green"></a> [eks\_kubernetes\_version\_green](#input\_eks\_kubernetes\_version\_green) | n/a | `string` | n/a | yes |
| <a name="input_eks_master_authorize_gha_runner"></a> [eks\_master\_authorize\_gha\_runner](#input\_eks\_master\_authorize\_gha\_runner) | n/a | `bool` | n/a | yes |
| <a name="input_eks_master_enabled_log_types"></a> [eks\_master\_enabled\_log\_types](#input\_eks\_master\_enabled\_log\_types) | n/a | `list(string)` | `[]` | no |
| <a name="input_eks_master_gha_runner_role"></a> [eks\_master\_gha\_runner\_role](#input\_eks\_master\_gha\_runner\_role) | n/a | `string` | n/a | yes |
| <a name="input_eks_master_log_retention"></a> [eks\_master\_log\_retention](#input\_eks\_master\_log\_retention) | n/a | `number` | `90` | no |
| <a name="input_eks_master_private_api_access"></a> [eks\_master\_private\_api\_access](#input\_eks\_master\_private\_api\_access) | n/a | `bool` | n/a | yes |
| <a name="input_eks_master_public_access_cidrs"></a> [eks\_master\_public\_access\_cidrs](#input\_eks\_master\_public\_access\_cidrs) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_master_public_api_access"></a> [eks\_master\_public\_api\_access](#input\_eks\_master\_public\_api\_access) | n/a | `bool` | n/a | yes |
| <a name="input_eks_worker_asg_attach_alb_target_groups"></a> [eks\_worker\_asg\_attach\_alb\_target\_groups](#input\_eks\_worker\_asg\_attach\_alb\_target\_groups) | n/a | `list(string)` | `[]` | no |
| <a name="input_eks_worker_asg_metrics"></a> [eks\_worker\_asg\_metrics](#input\_eks\_worker\_asg\_metrics) | n/a | `bool` | n/a | yes |
| <a name="input_eks_worker_asg_volume_size"></a> [eks\_worker\_asg\_volume\_size](#input\_eks\_worker\_asg\_volume\_size) | n/a | `number` | n/a | yes |
| <a name="input_eks_worker_asg_volume_type"></a> [eks\_worker\_asg\_volume\_type](#input\_eks\_worker\_asg\_volume\_type) | n/a | `string` | n/a | yes |
| <a name="input_eks_worker_blue_ami_version"></a> [eks\_worker\_blue\_ami\_version](#input\_eks\_worker\_blue\_ami\_version) | Blue ASG | `string` | n/a | yes |
| <a name="input_eks_worker_blue_asg_max_size"></a> [eks\_worker\_blue\_asg\_max\_size](#input\_eks\_worker\_blue\_asg\_max\_size) | n/a | `number` | n/a | yes |
| <a name="input_eks_worker_blue_asg_min_size"></a> [eks\_worker\_blue\_asg\_min\_size](#input\_eks\_worker\_blue\_asg\_min\_size) | n/a | `number` | n/a | yes |
| <a name="input_eks_worker_green_ami_version"></a> [eks\_worker\_green\_ami\_version](#input\_eks\_worker\_green\_ami\_version) | Green ASG | `string` | n/a | yes |
| <a name="input_eks_worker_green_asg_max_size"></a> [eks\_worker\_green\_asg\_max\_size](#input\_eks\_worker\_green\_asg\_max\_size) | n/a | `number` | n/a | yes |
| <a name="input_eks_worker_green_asg_min_size"></a> [eks\_worker\_green\_asg\_min\_size](#input\_eks\_worker\_green\_asg\_min\_size) | n/a | `number` | n/a | yes |
| <a name="input_eks_worker_instance_type"></a> [eks\_worker\_instance\_type](#input\_eks\_worker\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_eks_worker_kubelet_extra_flags"></a> [eks\_worker\_kubelet\_extra\_flags](#input\_eks\_worker\_kubelet\_extra\_flags) | n/a | `string` | n/a | yes |
| <a name="input_eks_worker_request_spot_instances"></a> [eks\_worker\_request\_spot\_instances](#input\_eks\_worker\_request\_spot\_instances) | n/a | `bool` | n/a | yes |
| <a name="input_eks_worker_ssh_access"></a> [eks\_worker\_ssh\_access](#input\_eks\_worker\_ssh\_access) | n/a | `bool` | n/a | yes |
| <a name="input_eks_worker_ssh_additional_keys"></a> [eks\_worker\_ssh\_additional\_keys](#input\_eks\_worker\_ssh\_additional\_keys) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_worker_ssh_cidr_whitelist"></a> [eks\_worker\_ssh\_cidr\_whitelist](#input\_eks\_worker\_ssh\_cidr\_whitelist) | IPs allowed to SSH into the instance. A map of cidr = description. | `map(string)` | n/a | yes |
| <a name="input_eks_worker_ssh_master_key"></a> [eks\_worker\_ssh\_master\_key](#input\_eks\_worker\_ssh\_master\_key) | n/a | `string` | n/a | yes |
| <a name="input_eks_worker_ssm_access"></a> [eks\_worker\_ssm\_access](#input\_eks\_worker\_ssm\_access) | n/a | `bool` | n/a | yes |
| <a name="input_eks_worker_ssm_rpm"></a> [eks\_worker\_ssm\_rpm](#input\_eks\_worker\_ssm\_rpm) | n/a | `string` | n/a | yes |
| <a name="input_elasticache_instances"></a> [elasticache\_instances](#input\_elasticache\_instances) | ElastiCache | <pre>map(object({<br>    engine         = string<br>    engine_version = string<br>    instance_class = string<br>  }))</pre> | `{}` | no |
| <a name="input_iam_application_roles"></a> [iam\_application\_roles](#input\_iam\_application\_roles) | IAM | <pre>map(object({<br>    bucket_rw_access = list(string)<br>    bucket_ro_access = list(string)<br>    secrets_access   = list(string)<br>    ses_access       = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_lb_instances"></a> [lb\_instances](#input\_lb\_instances) | LB | `any` | `{}` | no |
| <a name="input_project_env"></a> [project\_env](#input\_project\_env) | The stacks environment name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. It will be used for naming resources | `string` | n/a | yes |
| <a name="input_r53_caa_records"></a> [r53\_caa\_records](#input\_r53\_caa\_records) | Route53 CAA records to create | `list(string)` | `[]` | no |
| <a name="input_r53_zones"></a> [r53\_zones](#input\_r53\_zones) | Route53 zones to create | `set(string)` | `[]` | no |
| <a name="input_rds_instances"></a> [rds\_instances](#input\_rds\_instances) | RDS | <pre>map(object({<br>    add_identifier_suffix    = bool<br>    engine                   = string<br>    engine_version           = string<br>    instance_class           = string<br>    allocated_storage        = number<br>    max_allocated_storage    = number<br>    encrypt_storage          = bool<br>    database_name            = string<br>    master_username          = string<br>    master_password          = string<br>    snapshot_source_instance = string<br>    snapshot_identifier      = string<br>    skip_final_snapshot      = bool<br>    backup_retention_period  = number<br>    deletion_protection      = bool<br>    public_access            = bool<br>    custom_cname             = string<br>    custom_cname_zone        = string<br>    multi_az                 = bool<br>    cloudwatch_logs          = list(string)<br>    vpn_subnet_access        = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | n/a | <pre>map(object({<br>    type       = string<br>    cors_url   = string<br>    versioning = bool<br>    encryption = bool<br>  }))</pre> | `{}` | no |
| <a name="input_scripts_dir"></a> [scripts\_dir](#input\_scripts\_dir) | n/a | `string` | n/a | yes |
| <a name="input_secrets_manager_init"></a> [secrets\_manager\_init](#input\_secrets\_manager\_init) | n/a | `set(string)` | n/a | yes |
| <a name="input_vpc_private_cidr_block"></a> [vpc\_private\_cidr\_block](#input\_vpc\_private\_cidr\_block) | n/a | `string` | n/a | yes |
| <a name="input_vpc_private_subnet_newbits"></a> [vpc\_private\_subnet\_newbits](#input\_vpc\_private\_subnet\_newbits) | n/a | `number` | n/a | yes |
| <a name="input_vpc_public_cidr_block"></a> [vpc\_public\_cidr\_block](#input\_vpc\_public\_cidr\_block) | n/a | `string` | n/a | yes |
| <a name="input_vpc_public_subnet_newbits"></a> [vpc\_public\_subnet\_newbits](#input\_vpc\_public\_subnet\_newbits) | n/a | `number` | n/a | yes |
| <a name="input_vpn_connections"></a> [vpn\_connections](#input\_vpn\_connections) | VPN | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_config_command"></a> [eks\_config\_command](#output\_eks\_config\_command) | n/a |

<!--- END_TF_DOCS --->

