# Module : VPC
<br />

### Resources
| Resource Type                 | Purpose                                                              |
| ----------------------------- | -------------------------------------------------------------------- |
| `aws_vpc`                     | Creates the main Virtual Private Cloud                               |
| `aws_subnet`                  | Provisions both public and private subnets across availability zones |
| `aws_internet_gateway`        | Enables internet access for resources in public subnets              |
| `aws_eip`                     | Allocates Elastic IPs for NAT Gateway                                |
| `aws_nat_gateway`             | Enables outbound internet access for private subnets                 |
| `aws_route_table`             | Creates route tables for routing internet/NAT traffic                |
| `aws_route_table_association` | Associates route tables with respective subnets                      |

<br />

### Input Variables

| Variable Name              | Type           | Description                                                        |
| -------------------------- | -------------- | ------------------------------------------------------------------ |
| `vpc`                      | `object`       | VPC configuration, including CIDR, tenancy, DNS settings, and tags |
| `subnets`                  | `list(object)` | Public/Private subnets with CIDR, AZ, and tagging details          |
| `internet_gateway`         | `object`       | Internet Gateway settings, including VPC association and tags      |
| `key_pair`                 | `object`       | Key pair for EC2 access — includes name, public key, and tags      |
| `elastic_ips`              | `object`       | Elastic IP tags (used for NAT Gateway)                             |
| `nat_gateway`              | `object`       | NAT Gateway configuration including allocation ID and subnet ID    |
| `route_table_public`       | `object`       | Public route table including IGW route, CIDR blocks, and tags      |
| `route_table_private`      | `object`       | Private route table including NAT route and tags                   |
| `route_table_associations` | `list(object)` | List of subnet ID and route table ID pairs to associate            |

<br />

### Output Variables
These output values expose key resource attributes that can be used in other modules or for debugging and inspection.


| Output Name               | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| `vpc_id`                  | The ID of the created VPC                                                  |
| `subnet_details`          | Full details (attributes) of all created subnets (both public and private) |
| `public_subnet_ids`       | List of subnet IDs where `map_public_ip_on_launch = true` (i.e., public)   |
| `private_subnet_ids`      | List of subnet IDs where `map_public_ip_on_launch = false` (i.e., private) |
| `internet_gateway_id`     | ID of the attached Internet Gateway                                        |
| `elastic_ip_ids`          | ID of the allocated Elastic IP (for NAT Gateway)                           |
| `nat_gateway_ids`         | ID of the created NAT Gateway                                              |
| `public_route_table_ids`  | ID of the public route table                                               |
| `private_route_table_ids` | ID of the private route table                                              |

<br> <br> <br>

# Module : Security Group

<br>

### Resources
| Resource Type                         | Purpose                                                             |
| ------------------------------------- | ------------------------------------------------------------------- |
| `aws_security_group`                  | Creates the primary security group associated with the provided VPC |
| `aws_vpc_security_group_ingress_rule` | Defines individual ingress rules for the security group             |
| `aws_vpc_security_group_egress_rule`  | Defines individual egress rules for the security group              |

<br>

### Input Variables
| Variable Name                  | Type          | Description                                                             | Default                                    |
| ------------------------------ | ------------- | ----------------------------------------------------------------------- | ------------------------------------------ |
| `vpc_id`                       | `string`      | The ID of the VPC to which the security group will be attached          | –                                          |
| `security_group_name`          | `string`      | The name of the security group                                          | `"security-group-ping-terraform-codebase"` |
| `security_group_description`   | `string`      | Description of the security group                                       | `"Security group for Ping"`                |
| `tags`                         | `map(string)` | Key-value pairs to tag the security group                               | `{}`                                       |
| `security_group_rules_ingress` | `map(object)` | Ingress rules to be applied to the security group (see structure below) | –                                          |
| `security_group_rules_egress`  | `map(object)` | Egress rules to be applied to the security group (see structure below)  | –                                          |

<br>

### Output Variables
| Output Name              | Description                                                                                                                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `security_group_details` | Contains all attributes of the created security group. This includes the security group ID, name, description, VPC ID, and associated tags. Useful when referencing the SG in other modules. |

<br><br><br>

# Module : Route53

<br>

### Resources
| Resource Type        | Purpose                                                                |
| -------------------- | ---------------------------------------------------------------------- |
| `aws_route53_record` | Creates multiple A records in Route 53 with alias to the load balancer |

<br>

### Input Variables
| Variable Name           | Type           | Description                                                                   | Default |
| ----------------------- | -------------- | ----------------------------------------------------------------------------- | ------- |
| `load_balancer_dns`     | `string`       | DNS name of the load balancer to which alias records will point               | –       |
| `load_balancer_zone_id` | `string`       | Route53 zone ID of the load balancer (needed for alias configuration)         | –       |
| `hosted_zone_id`        | `string`       | ID of the Route 53 hosted zone where records will be created                  | –       |
| `a_records`             | `list(string)` | List of subdomain A records (e.g., `[ "dev.example.com", "qa.example.com" ]`) | –       |

<br><br><br>

# Load Balancer

<br>

### Resources
| Resource Type                    | Purpose                                                       |
| -------------------------------- | ------------------------------------------------------------- |
| `aws_lb_target_group`            | Defines a target group for the load balancer                  |
| `aws_lb_target_group_attachment` | Registers EC2 instances to the target group                   |
| `aws_lb`                         | Creates the Application Load Balancer (ALB)                   |
| `aws_lb_listener`                | Defines listener(s) on the ALB for routing HTTP/HTTPS traffic |

<br>

### Input Variables
| Variable Name             | Type                  | Description                                                                                | Default |
| ------------------------- | --------------------- | ------------------------------------------------------------------------------------------ | ------- |
| `target_group`            | `object({...})`       | Configuration for the ALB target group, including health check settings and tags           | –       |
| `target_group_attachment` | `list(object({...}))` | List of target group attachments specifying EC2 instances to be registered with the ALB    | –       |
| `load_balancer`           | `object({...})`       | Configuration for the ALB, including subnets, SGs, internal/external type, tags            | –       |
| `listener`                | `list(object({...}))` | List of listener rules for the ALB, including port, protocol, SSL cert (optional), actions | –       |

<br>

### Output Variables
| Output Name              | Description                                                   |
| ------------------------ | ------------------------------------------------------------- |
| `target_group_arn`       | ARN of the created target group                               |
| `load_balancer_arn`      | ARN of the created Application Load Balancer                  |
| `load_balancer_dns_name` | DNS name of the ALB to be used in Route53 or direct access    |
| `load_balancer_zone_id`  | Hosted zone ID of the ALB (used for alias records in Route53) |

<br><br><br>

# Instance Profile

<br>

### Resources
| Resource Type              | Purpose                                                               |
| -------------------------- | --------------------------------------------------------------------- |
| `aws_iam_instance_profile` | Creates an instance profile and attaches it to the specified IAM role |

<br>

### Input Variables
| Variable Name           | Type     | Description                                        | Default |
| ----------------------- | -------- | -------------------------------------------------- | ------- |
| `instance_profile_name` | `string` | Name of the IAM instance profile to be created     | –       |
| `cloudwatch_role_name`  | `string` | Name of the IAM role to be associated with profile | –       |

<br><br><br>

# IAM

<br>

### Resources
| Resource Type    | Purpose                                                              |
| ---------------- | -------------------------------------------------------------------- |
| `aws_iam_role`   | Creates an IAM role for EC2 to assume and publish logs to CloudWatch |
| `aws_iam_policy` | Creates a policy with CloudWatch Logs permissions                    |

<br>

### Input Variables
| Variable Name                       | Type     | Description                                   | Default |
| ----------------------------------- | -------- | --------------------------------------------- | ------- |
| `cloudwatch_role_name`              | `string` | Name of the IAM role for CloudWatch logging   | –       |
| `cloudwatch_log_policy_name`        | `string` | Name of the IAM policy for CloudWatch logging | –       |
| `cloudwatch_log_policy_description` | `string` | Description for the CloudWatch logging policy | –       |

<br>

### Output Variables
| Output Name      | Description                                       |
| ---------------- | ------------------------------------------------- |
| `iam_policy_arn` | ARN of the IAM policy created for CloudWatch Logs |

<br><br><br>

# EC2

<br>

### Resources
| Resource Type  | Purpose                                                   |
| -------------- | --------------------------------------------------------- |
| `aws_instance` | Creates one or more EC2 instances using the provided list |

<br>

### Input Variables

| Variable Name | Type           | Description                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default |
| ------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ec2`         | `list(object)` | List of EC2 instance configurations. Each object includes:<br>- `ami` (string): AMI ID<br>- `instance_type` (string): EC2 instance type<br>- `key_name` (string): Key pair name<br>- `subnet_id` (string): Subnet ID for EC2<br>- `vpc_security_group_ids` (list): Associated security group IDs<br>- `user_data` (string): Script to bootstrap EC2<br>- `iam_instance_profile_name` (string): Instance profile name<br>- `tags` (map): Metadata tags | –       |

<br>

### Output Variables
| Output Name   | Description                                                                  |
| ------------- | ---------------------------------------------------------------------------- |
| `ec2_details` | List of created EC2 instances with their `id`, `public_ip`, and `private_ip` |

<br><br><br>

# Cloudwatch Logs

<br>

### Resources
| Resource Type                    | Purpose                                                               |
| -------------------------------- | --------------------------------------------------------------------- |
| `aws_iam_role_policy_attachment` | Attaches the provided IAM policy to the specified IAM role            |
| `aws_cloudwatch_log_group`       | Creates a CloudWatch Log Group with defined name, tags, and retention |

<br>

### Input Variables
| Variable Name                         | Type          | Description                                                             | Default |
| ------------------------------------- | ------------- | ----------------------------------------------------------------------- | ------- |
| `cloudwatch_role_name`                | `string`      | Name of the IAM role to which the CloudWatch logging policy is attached | –       |
| `cloudwatch_log_group_name`           | `string`      | Name of the CloudWatch Log Group                                        | –       |
| `cloudwatch_log_group_retention_days` | `number`      | Retention period (in days) for the CloudWatch logs                      | –       |
| `cloudwatch_log_group_tags`           | `map(string)` | Tags for the CloudWatch Log Group                                       | –       |
| `iam_log_policy_arn`                  | `string`      | ARN of the IAM policy that allows access to CloudWatch logging APIs     | –       |
