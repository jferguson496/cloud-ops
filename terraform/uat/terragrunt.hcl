include {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}//tf_files/envs/"
}

inputs = {
  project_name = "rmc-digital"
  project_env  = "uat"
  aws_profile  = "rmc-digital-uat"
  aws_region   = "us-east-1"
  aws_account  = "398761216938"

  vpc_public_cidr_block      = "10.203.8.0/22"
  vpc_private_cidr_block     = "10.202.8.0/22"
  vpc_public_subnet_newbits  = 2 # vpc_cidr_block mask bits + vpc_subnet_newbits = subnet size
  vpc_private_subnet_newbits = 2 # vpc_cidr_block mask bits + vpc_subnet_newbits = subnet size

  ##
  ## EKS
  ##
  eks_kubernetes_version = "1.21"

  eks_master_private_api_access = true
  eks_master_public_api_access  = true
  eks_master_public_access_cidrs = [
    "34.205.12.175/32", # digital-shared NAT gateway (used by GHA runners)
    "18.207.10.253/32", # Regionals VPN public IP
  ]
  eks_master_authorize_gha_runner = true
  eks_master_gha_runner_role      = "arn:aws:iam::340962741254:role/gha-runner_role"
  eks_master_enabled_log_types    = ["audit", "authenticator"]
  eks_master_log_retention        = 180

  ##
  ## EKS Workers
  ##
  eks_worker_instance_type  = "m5.large"

  #Blue ASG 
  eks_worker_blue_ami_version    = "v20220303" # to use latest, remove this variable, or enter "latest" or "*"
  eks_worker_blue_asg_min_size   = 2
  eks_worker_blue_asg_max_size   = 4
  eks_kubernetes_version_blue    = "1.21"
  #Green ASG
  eks_worker_green_ami_version    = "v20220303" # to use latest, remove this variable, or enter "latest" or "*"
  eks_worker_green_asg_min_size   = 0
  eks_worker_green_asg_max_size   = 0
  eks_kubernetes_version_green    = "1.21"

  eks_worker_asg_metrics    = true
  eks_worker_ssm_access     = true
  eks_worker_ssm_rpm        = "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
  eks_worker_ssh_access     = false
  eks_worker_ssh_master_key = ""
  eks_worker_ssh_additional_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqWa+NyCNFLEn3HkUf5hAaolo+pFTVbQa4EtowdEgtw6+m6smUPwR8XMHycjWKBsrAthdzYp20ozc8n5vUEylCp7e4Ef5jGg4imEzxAZwV648KDwvSPNVUlsfXAmMCo1mBhuv2jypayY+9O7EXXGvNvFOjznHl9A2CrzYam4pjyT89R3GdeDlbwpuYIK7x9udJ0RslJnwWChs3P6UJIYB111o8u2NyQYR67Zre2zpjibMzosraPMX2kZHtWORIbEft+l8ZZt8DKEBpEn4ggtymjviFgMFBHOeGVNgclC1qfbjyiDs0r651ZimWU9AvH7Xvpm3ZvZTNf4v2hMoFOlUNtWkPDWThZ9u4xJOz5r/rkujt49ZGBAS/Z2wxGmIJ0rWiCekBPb0P4fxhVjlOWcLDmtYx3g9dgC3nlpeizQYBf/AL0A8awXQyL7uxA5RIIS2KRpKRjc7rrezfT53SYU5ghEB/9exUmj8kT9yj32UCn/O9ib5yS/LVicOCD6tqxQfj0FOM2n/vP7hITVAuA37psTVkAUxaoZMkqMWH3xYE9TaMwxG4KhW3GgV5AP0HOv8k4TsTHkSjMWlFr92kBv9Qdos+1A0hBmoBipBamhVzh4M9ukU0MHyPf3il2O1OUj1US1ntaOeIRgl38yR6mf02Y9jI4HuJmHbIsuArsyjXfw== michal.weinert@tivix.com",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA/g3GqiuXzVTNFSOCrAAolp7An3dRrm5Ww/Ac6r04+BoVXfbKe9Lp8BTK8LNI6zR7y4BgD+WxKumZWMhCnBLdHX3QSE7EcLJeqwxPmFwKSIF3ZBcEUo8o/FWMwACALgQDi9PPt0hNlgYzaSJ6rh1UkdDU+hYUzJLEX3IEb0hHnkFBnYTJ7uL7RIHMWiEcnUKp4r7e92VySB/sH9SfsRCNxbTplAXrAIMinUQyeBpIXNA+rxmBU8b4WII6owAo2DP36vVnZpzvXYQ5FoLSq+q7497kOlvPARjBhhdquenBM4wMV/G1ekfjjGfbAbgAytDfdKiVt9eEMRISL+lUjqa/ michal.kopacki@tivix.com"
  ]
  eks_worker_ssh_cidr_whitelist = {
    "79.110.200.68/32" = "Michal Weinert home",
    "71.198.132.36/32" = "Sumit home",
  }
  eks_worker_asg_volume_size              = 32
  eks_worker_asg_volume_type              = "gp2"
  eks_worker_kubelet_extra_flags          = ""
  eks_worker_request_spot_instances       = false
  eks_worker_asg_attach_alb_target_groups = ["main"]

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
        name            = "Dig-UAT-VPG"
        amazon_side_asn = 65031
      }
      vpn_connection = {
        name = "RMC-Prod-VPC"
        type = "ipsec.1"
      }
    }
  }

  ##
  ## LB
  ##
  lb_instances = {
    main = {
      deletion_protection = true
      allowed_cidrs = [
        {
          cidr        = "18.207.10.253/32"
          description = "Regional VPN public IP"
        },
        {
          cidr        = "4.246.174.46/32"
          description = "Regional AVD public IP"
        },
        {
          cidr        = "34.252.84.235/32"
          description = "Tivix VPN public IP"
        },
        {
          cidr        = "75.101.130.73/32"
          description = "Twilio development proxy"
        },
        {
          cidr        = "34.193.150.126/32"
          description = "Even Financial Dev/Test"
        },
        {
          cidr        = "12.152.18.0/23"
          description = "Lending Tree 1"
        },
        {
          cidr        = "54.208.21.156/32"
          description = "Lending Tree 2"
        },
        {
          cidr        = "54.208.190.122/32"
          description = "Lending Tree 3"
        },
        {
          cidr        = "54.209.199.49/32"
          description = "Lending Tree 4"
        },
        {
          cidr        = "54.208.145.91/32"
          description = "Lending Tree 5"
        },
        {
          cidr        = "54.209.114.236/32"
          description = "Lending Tree 6"
        },
        {
          cidr        = "54.209.197.116/32"
          description = "Lending Tree 7"
        },
        {
          cidr        = "3.219.52.123/32"
          description = "Modelshop"
        },
        {
          cidr        = "34.214.216.179/32"
          description = "SuperMoney - Dev2 Host"
        },
        {
          cidr        = "12.50.44.226/32"
          description = "SuperMoney - Office"
        },
        {
          cidr        = "12.231.13.202/32"
          description = "SuperMoney - Office Alt"
        },
        {
          cidr        = "182.75.67.222/32"
          description = "QuinStreet 1"
        },
        {
          cidr        = "216.211.175.4/32"
          description = "QuinStreet 2"
        },
        {
          cidr        = "216.211.175.49/32"
          description = "QuinStreet 3"
        },
        {
          cidr        = "216.211.175.81/32"
          description = "QuinStreet 4"
        },
        {
          cidr        = "216.211.175.82/32"
          description = "QuinStreet 5"
        },
        {
          cidr        = "216.211.175.83/32"
          description = "QuinStreet 6"
        },
        {
          cidr        = "216.211.175.84/32"
          description = "QuinStreet 7"
        },
        {
          cidr        = "67.106.145.117/32"
          description = "QuinStreet 8"
        },
        {
          cidr        = "67.106.145.4/32"
          description = "QuinStreet 9"
        },
        {
          cidr        = "70.42.22.2/32"
          description = "QuinStreet 10"
        },
        {
          cidr        = "70.42.23.154/32"
          description = "QuinStreet 11"
        },
        {
          cidr        = "134.238.14.12/32"
          description = "QuinStreet 12"
        },
        {
          cidr        = "216.211.175.0/24"
          description = "QuinStreet 13"
        },
        {
          cidr        = "202.135.181.177/32"
          description = "QuinStreet 14"
        },
        {
          cidr        = "209.112.104.0/22"
          description = "DocuSign 1"
        },
        {
          cidr        = "64.207.216.0/22"
          description = "DocuSign 2"
        },
        {
          cidr        = "162.248.184.0/22"
          description = "DocuSign 3"
        }
      ]
      waf = {
        enabled    = true
        cloudwatch = true
        # https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html
        managed_rules = [
          {
            name     = "AWSManagedRulesCommonRuleSet"
            vendor   = "AWS"
            priority = 20
            excluded_rules = [
              "SizeRestrictions_BODY",
            ]
          }
        ]
        country_whitelist = {
          enabled = true
          whitelisted_countries = [
            "CA",
            "IN",
            "IE",
            "PL",
            "US",
          ]
          priority = 0
        }
        rate_limit = {
          enabled  = true
          limit    = 3000
          priority = 10
        }
        admin_whitelist = {
          enabled = true
          path    = "/admin" # matches paths beginning with this value
          ip_list = [
            "18.207.10.253/32", # Regionals VPN public IP
            "34.252.84.235/32", # Tivix VPN proxy
            "4.246.174.46/32", # Regionals AVD Public IP
          ]
          priority = 40
        }
        partner_whitelist = {
          enabled = true
          path    = "/api/v1/partners" # matches paths beginning with this value
          ip_list = [
            "18.207.10.253/32",  # Regionals VPN public IP
            "4.246.174.46/32",   # Regionals AVD Public IP
            "34.193.150.126/32", # Even Financial Dev/Test
            "12.152.18.0/23",    # Lending Tree 1
            "54.208.21.156/32",  # Lending Tree 2
            "54.208.190.122/32", # Lending Tree 3
            "54.209.199.49/32",  # Lending Tree 4
            "54.208.145.91/32",  # Lending Tree 5
            "54.209.114.236/32", # Lending Tree 6
            "54.209.197.116/32", # Lending Tree 7
            "12.231.13.202/32",  # SuperMoney
            "12.50.44.226/32",   # SuperMoney
            "34.214.216.179/32", # SuperMoney
            "182.75.67.222/32",  # QuinStreet
            "216.211.175.4/32",  # QuinStreet
            "216.211.175.49/32", # QuinStreet  
            "216.211.175.81/32", # QuinStreet
            "216.211.175.82/32", # QuinStreet
            "216.211.175.83/32", # QuinStreet
            "216.211.175.84/32", # QuinStreet
            "67.106.145.117/32", # QuinStreet
            "67.106.145.4/32",   # QuinStreet
            "70.42.22.2/32",     # QuinStreet
            "70.42.23.154/32",   # QuinStreet
            "134.238.14.12/32",   # Quinstreet
          ]
          priority = 50
        }
        internal_service_whitelist = {
          enabled = true
          domain  = "connect.regionalfinance.com"
          ip_list = [
            "18.207.10.253/32", # Regionals VPN public IP
            "34.252.84.235/32", # Tivix VPN proxy
            "4.246.174.46/32", # Regionals AVD Public IP
          ]
          priority = 30
        }
        docusign_whitelist = {
          enabled = true
          domainCom = ".docusign.com"
          domainNet = ".docusign.net"
          ip_list = [
            "209.112.104.0/22", ######################
            "64.207.216.0/22",  # Docusign IP Ranges #
            "162.248.184.0/22", ######################
          ]
          headers = [
            "X-DocuSign-Signature-1",
          ]
          priority = 15
        }
        # required_headers = {
        #   enabled = true
        #   headers = [
        #     "User-Agent",
        #   ]
        # }
        /* customer_portal_whitelist = {
          enabled = true
          domain  = "myaccount.regionalfinance.com"
          ip_list = [
            "18.207.10.253/32", # Regionals VPN public IP
            "4.246.174.46/32", # Regionals AVD Public IP
          ]
          priority = 60
        } */
      }
      listeners = {
        http = {
          port        = 80
          protocol    = "HTTP"
          action_type = "redirect"
          redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
          }
        },
        https = {
          port                = 443
          protocol            = "HTTPS"
          action_type         = "forward"
          ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
          default_certificate = "uat.rmcdigital.net"
          extra_certificates  = ["connect-uat.rmcdigital.net"]
        }
      }
      target_group = {
        port                          = 30080
        deregistration_delay          = 30
        load_balancing_algorithm_type = "least_outstanding_requests"
        healthcheck = {
          path                = "/healthz"
          interval            = 10
          success_codes       = "200"
          healthy_threshold   = 2
          unhealthy_threshold = 2
        }
      }
    }
  }

  ##
  ## Route53
  ##
  r53_zones = [
    "uat.rmcdigital.net",
    "connect-uat.rmcdigital.net",
  ]
  r53_caa_records = ["amazon.com"]

  ##
  ## ACM
  ##
  acm_certificates = {
    "uat.rmcdigital.net" = {
       san = [
        "myaccount.uat.rmcdigital.net",
      ]
      r53_zone = "uat.rmcdigital.net"
    },
    "connect-uat.rmcdigital.net" = {
      san      = []
      r53_zone = "connect-uat.rmcdigital.net"
    }
  }

  ##
  ## RDS
  ##
  rds_instances = {
    rmc-uat = {
      add_identifier_suffix    = true
      engine                   = "postgres"
      engine_version           = "12.11"
      instance_class           = "db.t2.small"
      allocated_storage        = 20
      max_allocated_storage    = 100
      encrypt_storage          = true
      database_name            = "rmc_web_platform"
      master_username          = "rmc_web_platform"
      master_password          = get_env("TF_RDS_PASSWORD", "dummy")
      snapshot_source_instance = ""
      snapshot_identifier      = ""
      skip_final_snapshot      = true
      backup_retention_period  = 2
      deletion_protection      = true
      public_access            = false
      custom_cname             = "rds.uat.rmcdigital.net"
      custom_cname_zone        = "uat.rmcdigital.net"
      multi_az                 = false
      cloudwatch_logs          = ["postgresql", "upgrade"]
      vpn_subnet_access        = [        
        {
          description = "RMC VPN traffic"
          source      = ["10.10.60.0/24"]
        },
        {
          description = "RMC VPN traffic"
          source      = ["10.30.0.0/16"]
        },
        {
          description = "RMC VPN traffic"
          source      = ["172.28.240.0/23"]
        },
        {
          description = "RMC VPN traffic"
          source      = ["10.28.12.4/32"]
        },
        {
          description = "RMC VPN traffic"
          source      = ["10.51.249.0/26"]
        },
        {
          description = "OneTrust"
          source      = ["10.0.10.31/32"]
        },
      ]
      # additional_access = []
    },
  }

  ##
  ##POSTGRES - Customer Portal DB
  ##
  main_postgres_password = get_env("TF_RDS_PASSWORD", "dummy")
  custportl_postgres_password = get_env("TF_CUSTPORTL_PASS", "dummy")

  ##
  ## IAM
  ##
  iam_application_roles = {
    rmc-uat = {
      bucket_rw_access = [
        "rmc-digital-uat-public",
        "rmc-digital-uat-private",
        "rmc-digital-uat-reports",
        "rmc-customer-portal-uat-public",
      ],
      bucket_ro_access = [
      ],
      secrets_access = [
        "rmc-digital/uat"
      ],
      ses_access = [
        "uat.rmcdigital.net"
      ],
    },
  }

  ##
  ## S3
  ##
  s3_buckets = {
    "rmc-digital-uat-public" = {
      type       = "public"
      cors_url   = "https://uat.rmcdigital.net"
      versioning = false
      encryption = false
    },
    "rmc-digital-uat-private" = {
      type       = "private"
      cors_url   = ""
      versioning = false
      encryption = true
    },
    "rmc-digital-uat-reports" = {
      type       = "private"
      cors_url   = ""
      versioning = false
      encryption = true
    },
    "rmc-customer-portal-uat-public" = {
      type       = "public"
      cors_url   = "https://uat.portal.rmcdigital.net"
      versioning = false
      encryption = false
    },
  }

  ##
  ## Secrets manager
  ##
  secrets_manager_init = [
    "uat",
  ]

  ##
  ## ElastiCache
  ##
  elasticache_instances = {
    rmc-uat = {
      engine         = "redis"
      engine_version = "6.x"
      instance_class = "cache.t3.micro"
    },
  }
}
