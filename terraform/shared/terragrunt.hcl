include {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}//tf_files/shared/"
}

inputs = {
  aws_profile = "rmc-digital-shared"
  aws_region  = "us-east-1"

  #
  # S3
  #
  s3_ops_bucket         = "rmc-digital-ops"
  s3_ops_aes_encryption = true

  #
  # ECR
  #
  ecr_repositories = [
    "rmc-web-platform/django_backend",
    "rmc-web-platform/react_frontend",
    "rmc-web-platform/cypress_testing_service",
    "rmc-web-platform/sqlserver_db",
    "rmc-web-platform/postgres_db",
    "rmc-web-platform/internal_backend",
    "rmc-web-platform/internal_frontend",
    "rmc-customer-portal/django_backend",
    "rmc-customer-portal/frontend",
    "rmc-customer-portal/test_rmc_api",
    "rmc-customer-portal/cypress_testing_service"
  ]
  ecr_external_access = [
    "arn:aws:iam::903527346668:role/eks_rmc-digital-dev_worker-role",     # EKS worker on dev AWS
    "arn:aws:iam::772628109955:role/eks_rmc-digital-staging_worker-role", # EKS worker on staging AWS
    "arn:aws:iam::398761216938:role/eks_rmc-digital-uat_worker-role",     # EKS worker on uat AWS
    "arn:aws:iam::475588757501:role/eks_rmc-digital-prod_worker-role",    # EKS worker on prod AWS
  ]
  ecr_image_scanning       = false
  ecr_tag_mutability       = false
  ecr_image_timeout        = 180
  ecr_dev_image_tag_prefix = "dev"
  ecr_dev_image_timeout    = 1

  #
  # VPC
  #
  vpc_public_cidr_block      = "10.203.20.0/22"
  vpc_private_cidr_block     = "10.202.20.0/22"
  vpc_subnet_count           = 1
  vpc_public_subnet_newbits  = 2 # vpc_cidr_block mask bits + vpc_subnet_newbits = subnet size
  vpc_private_subnet_newbits = 2 # vpc_cidr_block mask bits + vpc_subnet_newbits = subnet size

  ##
  ## VPN Connection
  ##
  vpn_connections = {
    main = {
      customer_gateway = {
        name       = "RMC-DMZ"
        bgp_asn    = 65040
        ip_address = "52.5.119.209"
        type       = "ipsec.1"
      }
      vpn_gateway = {
        name            = "RMC-Digital-Shared"
        amazon_side_asn = 65029
      }
      vpn_connection = {
        name = "Dig-Dev-DMZ"
        type = "ipsec.1"
      }
    }
  }

  #
  # GHA runner instances
  #
  gha_runner_ssm_enabled        = true
  gha_runner_count              = 1
  gha_runner_instance_type      = "c5.4xlarge"
  gha_runner_volume_type        = "gp3"
  gha_runner_volume_size        = 128
  gha_runner_volume_throughput  = 300 # Applies only for gp3 volume type
  gha_runner_volume_iops        = 3000
  gha_runner_agent_archive      = "https://github.com/actions/runner/releases/download/v2.288.1/actions-runner-linux-x64-2.288.1.tar.gz"
  gha_runner_agent_archive_hash = "325b89bdc1c67264ec6f4515afda4534f14a6477d9ba241da19c43f9bed2f5a6"
  gha_runner_agent_name_prefix  = "shared_gha-runner"
  gha_runner_agent_url          = "https://github.com/RegionalManagement"
  gha_runner_agent_token        = "AYK3BHRCAVL37FXAKG2MJQDCX2I22"
  gha_runner_extra_labels       = "tivix" # comma separated string


  #
  # Route53 zone
  #
  r53_zones = {
    "rmcdigital.net" = {
      "dev" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-889.awsdns-47.net.",
          "ns-1941.awsdns-50.co.uk.",
          "ns-1486.awsdns-57.org.",
          "ns-119.awsdns-14.com.",
        ]
      },
      "connect-dev" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-39.awsdns-04.com",
          "ns-1601.awsdns-08.co.uk",
          "ns-1500.awsdns-59.org",
          "ns-617.awsdns-13.net",
        ]
      },
      "staging" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-319.awsdns-39.com.",
          "ns-737.awsdns-28.net.",
          "ns-1176.awsdns-19.org.",
          "ns-1677.awsdns-17.co.uk.",
        ]
      },
      "connect-staging" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-1731.awsdns-24.co.uk",
          "ns-856.awsdns-43.net",
          "ns-201.awsdns-25.com",
          "ns-1229.awsdns-25.org",
        ]
      },
      "uat" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-920.awsdns-51.net.",
          "ns-276.awsdns-34.com.",
          "ns-1261.awsdns-29.org.",
          "ns-1904.awsdns-46.co.uk.",
        ]
      },
      "connect-uat" = {
        type = "NS",
        ttl  = 3600,
        records = [
          "ns-1287.awsdns-32.org",
          "ns-1912.awsdns-47.co.uk",
          "ns-990.awsdns-59.net",
          "ns-188.awsdns-23.com",
        ]
      },
    }
  }

  #
  # Twilio callback proxy
  #
  twilio_proxy_r53_zone      = "rmcdigital.net"
  twilio_proxy_r53_domain    = "*.twilio-proxy.rmcdigital.net."
  twilio_proxy_caddy_version = "2-alpine"
}
