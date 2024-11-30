# tflint-ignore: terraform_unused_declarations
variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
}
variable "orgname" {
  description = "the orgname to be used for naming convention"
  type        = string
  default     = null
}
variable "resourcename" {
  description = "the resource name to be used for naming convention"
  type        = string
  default     = null
}
variable "environment" {
  type        = string
  default     = null
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}
variable "project_name" {
  description = "the project name to be used for naming convention"
  type        = string
  default     = null
}
variable "region_name" {
  description = "the region name to be used for naming convention"
  type        = string
  default     = null
}
variable "resource_desc" {
  description = "the resource desc to be used for naming convention"
  type        = string
  default     = null
}
variable "default_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
variable "cluster_depends_on" {
  type        = any
  description = <<-EOT
    If provided, the EKS will depend on this object, and therefore not be created until this object is finalized.
    This is useful if you want to ensure that the cluster is not created before some other condition is met, e.g. VPNs into the subnet are created.
    EOT
  default     = null
}

variable "create_eks_service_role" {
  type        = bool
  description = "Set `false` to use existing `eks_cluster_service_role_arn` instead of creating one"
  default     = true
}

variable "eks_cluster_service_role_arn" {
  type        = string
  description = <<-EOT
    The ARN of an IAM role for the EKS cluster to use that provides permissions
    for the Kubernetes control plane to perform needed AWS API operations.
    Required if `create_eks_service_role` is `false`, ignored otherwise.
    EOT
  default     = null
}

#variable "workers_role_arns" {
#  type        = list(string)
#  description = "List of Role ARNs of the worker nodes"
#  default     = []
#}

variable "kubernetes_version" {
  type        = string
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
  default     = "1.21"
}

variable "oidc_provider_enabled" {
  type        = bool
  description = <<-EOT
    Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a
    service account in the cluster, instead of using kiam or kube2iam. For more information,
    see [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).
    EOT
  default     = false
}

variable "endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
  default     = false
}

variable "endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
  default     = ["0.0.0.0/0"]
}

## node group configuration
variable "nodegroup_instance_type" {
  description = "Instance type of EKS worker nodes"
  type        = list(string)
  default     = []
}
variable "nodegroup_instance_disk_size" {
  description = "ebs volume size associated to worker nodes in GB"
  type        = number
  default     = 300
}
variable "nodegroup_instance_desired_size" {
  description = "node group instance desired count"
  type        = number
  default     = 2
}
variable "nodegroup_instance_max_size" {
  description = "node group instance maximum count"
  type        = number
  default     = 4
}
variable "nodegroup_instance_min_size" {
  description = "node group instance minimum count"
  type        = number
  default     = 2
}

variable "service_ipv4_cidr" {
  type        = string
  description = <<-EOT
    The CIDR block to assign Kubernetes service IP addresses from.
    You can only specify a custom CIDR block when you create a cluster, changing this value will force a new cluster to be created.
    EOT
  default     = null
}

variable "kubernetes_network_ipv6_enabled" {
  type        = bool
  description = "Set true to use IPv6 addresses for Kubernetes pods and services"
  default     = false
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_period" {
  type        = number
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
  default     = 0
}

#variable "apply_config_map_aws_auth" {
#  type        = bool
#  description = "Whether to apply the ConfigMap to allow worker nodes to join the EKS cluster and allow additional users, accounts and roles to acces the cluster"
#  default     = true
#}
#
#variable "map_additional_aws_accounts" {
#  type        = list(string)
#  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
#  default     = []
#}
#
#variable "map_additional_iam_roles" {
#  type = list(object({
#    rolearn  = string
#    username = string
#    groups   = list(string)
#  }))
#  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"
#  default     = []
#}

#variable "map_additional_iam_users" {
#  type = list(object({
#    userarn  = string
#    username = string
#    groups   = list(string)
#  }))
#  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"
#  default     = []
#}
#
#variable "local_exec_interpreter" {
#  type        = list(string)
#  description = "shell to use for local_exec"
#  default     = ["/bin/sh", "-c"]
#}

#variable "wait_for_cluster_command" {
#  type        = string
#  description = "`local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint URL is available as environment variable `ENDPOINT`"
#  ## --max-time is per attempt, --retry is the number of attempts
#  ## Approx. total time limit is (max-time + retry-delay) * retry seconds
#  default = "if test -n \"$ENDPOINT\"; then curl --silent --fail --retry 30 --retry-delay 10 --retry-connrefused --max-time 11 --insecure --output /dev/null $ENDPOINT/healthz; fi"
#}

#variable "kubernetes_config_map_ignore_role_changes" {
#  type        = bool
#  description = "Set to `true` to ignore IAM role changes in the Kubernetes Auth ConfigMap"
#  default     = true
#}

variable "cluster_encryption_config_enabled" {
  type        = bool
  description = "Set to `true` to enable Cluster Encryption Configuration"
  default     = null
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  description = "KMS Key ID to use for cluster encryption config"
  default     = ""
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
  default     = true
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
  default     = 10
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
  default     = null
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
  default     = ["secrets"]
}

variable "permissions_boundary" {
  type        = string
  description = "If provided, all IAM roles will be created with this permissions boundary attached"
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "If provided, the KMS Key ID to use to encrypt AWS CloudWatch logs"
  default     = null
}

variable "addons" {
  type = list(object({
    addon_name                  = string
    addon_version               = string
    configuration_values        = string
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
    service_account_role_arn    = string
    create_timeout              = string
    update_timeout              = string
    delete_timeout              = string
    #delete_timeout              = optional(string, null)
  }))
  description = "Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources"
  default     = []
}

variable "addons_depends_on" {
  type        = any
  description = <<-EOT
    If provided, all addons will depend on this object, and therefore not be installed until this object is finalized.
    This is useful if you want to ensure that addons are not applied before some other condition is met, e.g. node groups are created.
    See [issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details.
    EOT
  default     = null
}

variable "worker_node_additional_policy_arns" {
  description = "List of policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = [] # Default empty list
}

variable "vpc_ssm_id" {
  type        = string
  description = "vpc ssm id for locating the vpc attributes"
  default     = "/ot/eucen1/dev/cicm/vpc"
}

##########################################################################################
# All the following variables are just about configuring the Kubernetes provider
# to be able to modify the aws-auth ConfigMap. Once EKS provides a normal
# AWS API for modifying it, we can do away with all of this.
#
# The reason there are so many options is because at various times, each
# one of them has had problems, so we give you a choice.
#
# The reason there are so many "enabled" inputs rather than automatically
# detecting whether or not they are enabled based on the value of the input
# is that any logic based on input values requires the values to be known during
# the "plan" phase of Terraform, and often they are not, which causes problems.
#
##########################################################################################
#variable "kubeconfig_path_enabled" {
#  type        = bool
#  description = "If `true`, configure the Kubernetes provider with `kubeconfig_path` and use it for authenticating to the EKS cluster"
#  default     = false
#}
#
#variable "kubeconfig_path" {
#  type        = string
#  description = "The Kubernetes provider `config_path` setting to use when `kubeconfig_path_enabled` is `true`"
#  default     = ""
#}
#
#variable "kubeconfig_context" {
#  type        = string
#  description = "Context to choose from the Kubernetes kube config file"
#  default     = ""
#}
#
#variable "kube_data_auth_enabled" {
#  type        = bool
#  description = <<-EOT
#    If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.
#    Disabled by `kubeconfig_path_enabled` or `kube_exec_auth_enabled`.
#    EOT
#  default     = true
#}
#
#variable "kube_exec_auth_enabled" {
#  type        = bool
#  description = <<-EOT
#    If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.
#    Disabled by `kubeconfig_path_enabled`, overrides `kube_data_auth_enabled`.
#    EOT
#  default     = false
#}
#
#
#variable "kube_exec_auth_role_arn" {
#  type        = string
#  description = "The role ARN for `aws eks get-token` to use"
#  default     = ""
#}
#
#variable "kube_exec_auth_role_arn_enabled" {
#  type        = bool
#  description = "If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`"
#  default     = false
#}
#
#variable "kube_exec_auth_aws_profile" {
#  type        = string
#  description = "The AWS config profile for `aws eks get-token` to use"
#  default     = ""
#}
#
#variable "kube_exec_auth_aws_profile_enabled" {
#  type        = bool
#  description = "If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`"
#  default     = false
#}
#
#variable "aws_auth_yaml_strip_quotes" {
#  type        = bool
#  description = "If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans"
#  default     = true
#}
#
#variable "dummy_kubeapi_server" {
#  type        = string
#  default     = "https://jsonplaceholder.typicode.com"
#  description = <<-EOT
#    URL of a dummy API server for the Kubernetes server to use when the real one is unknown.
#    This is a workaround to ignore connection failures that break Terraform even though the results do not matter.
#    You can disable it by setting it to `null`; however, as of Kubernetes provider v2.3.2, doing so _will_
#    cause Terraform to fail in several situations unless you provide a valid `kubeconfig` file
#    via `kubeconfig_path` and set `kubeconfig_path_enabled` to `true`.
#    EOT
#}

#variable "cluster_attributes" {
#  type        = list(string)
#  description = "Override label module default cluster attributes"
#  default     = ["cluster"]
#}

variable "managed_security_group_rules_enabled" {
  type        = bool
  description = "Flag to enable/disable the ingress and egress rules for the EKS managed Security Group"
  default     = true
}
#######################################################################################################
##context file variables
#######################################################################################################

#variable "context" {
#  type = any
#  default = {
#    enabled             = true
#    namespace           = null
#    tenant              = null
#    environment         = null
#    stage               = null
#    name                = null
#    delimiter           = null
#    attributes          = []
#    tags                = {}
#    additional_tag_map  = {}
#    regex_replace_chars = null
#    label_order         = []
#    id_length_limit     = null
#    label_key_case      = null
#    label_value_case    = null
#    descriptor_formats  = {}
#    # Note: we have to use [] instead of null for unset lists due to
#    # https://github.com/hashicorp/terraform/issues/28137
#    # which was not fixed until Terraform 1.0.0,
#    # but we want the default to be all the labels in `label_order`
#    # and we want users to be able to prevent all tag generation
#    # by setting `labels_as_tags` to `[]`, so we need
#    # a different sentinel to indicate "default"
#    labels_as_tags = ["unset"]
#  }
#  description = <<-EOT
#    Single object for setting entire context at once.
#    See description of individual variables for details.
#    Leave string and numeric variables as `null` to use default value.
#    Individual variable settings (non-null) override settings in context object,
#    except for attributes, tags, and additional_tag_map, which are merged.
#  EOT
#
##  validation {
##    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
##    error_message = "Allowed values: `lower`, `title`, `upper`."
##  }
##
##  validation {
##    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
##    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
##  }
#}

#variable "namespace" {
#  type        = string
#  default     = null
#  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
#}

#variable "tenant" {
#  type        = string
#  default     = null
#  description = "ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for"
#}

#variable "stage" {
#  type        = string
#  default     = null
#  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
#}
#
#variable "name" {
#  type        = string
#  default     = null
#  description = <<-EOT
#    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
#    This is the only ID element not also included as a `tag`.
#    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
#    EOT
#}

#variable "delimiter" {
#  type        = string
#  default     = null
#  description = <<-EOT
#    Delimiter to be used between ID elements.
#    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
#  EOT
#}
#
#variable "attributes" {
#  type        = string #list(string)
#  default     = null
#  description = <<-EOT
#    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
#    in the order they appear in the list. New attributes are appended to the
#    end of the list. The elements of the list are joined by the `delimiter`
#    and treated as a single ID element.
#    EOT
#}

#variable "labels_as_tags" {
#  type        = set(string)
#  default     = ["default"]
#  description = <<-EOT
#    Set of labels (ID elements) to include as tags in the `tags` output.
#    Default is to include all labels.
#    Tags with empty values will not be included in the `tags` output.
#    Set to `[]` to suppress all generated tags.
#    **Notes:**
#      The value of the `name` tag, if included, will be the `id`, not the `name`.
#      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
#      changed in later chained modules. Attempts to change it will be silently ignored.
#    EOT
#}
#
#variable "tags" {
#  type        = map(string)
#  default     = {}
#  description = <<-EOT
#    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
#    Neither the tag keys nor the tag values will be modified by this module.
#    EOT
#}

#variable "additional_tag_map" {
#  type        = map(string)
#  default     = {}
#  description = <<-EOT
#    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.
#    This is for some rare cases where resources want additional configuration of tags
#    and therefore take a list of maps with tag key, value, and additional configuration.
#    EOT
#}

#variable "label_order" {
#  type        = list(string)
#  default     = null
#  description = <<-EOT
#    The order in which the labels (ID elements) appear in the `id`.
#    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
#    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
#    EOT
#}

#variable "regex_replace_chars" {
#  type        = string
#  default     = null
#  description = <<-EOT
#    Terraform regular expression (regex) string.
#    Characters matching the regex will be removed from the ID elements.
#    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
#  EOT
#}

#variable "id_length_limit" {
#  type        = number
#  default     = null
#  description = <<-EOT
#    Limit `id` to this many characters (minimum 6).
#    Set to `0` for unlimited length.
#    Set to `null` for keep the existing setting, which defaults to `0`.
#    Does not affect `id_full`.
#  EOT
#  validation {
#    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
#    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
#  }
#}

#variable "label_key_case" {
#  type        = string
#  default     = null
#  description = <<-EOT
#    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
#    Does not affect keys of tags passed in via the `tags` input.
#    Possible values: `lower`, `title`, `upper`.
#    Default value: `title`.
#  EOT
#
#  validation {
#    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
#    error_message = "Allowed values: `lower`, `title`, `upper`."
#  }
#}

#variable "label_value_case" {
#  type        = string
#  default     = null
#  description = <<-EOT
#    Controls the letter case of ID elements (labels) as included in `id`,
#    set as tag values, and output by this module individually.
#    Does not affect values of tags passed in via the `tags` input.
#    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
#    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
#    Default value: `lower`.
#  EOT
#
#  validation {
#    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
#    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
#  }
#}

#variable "descriptor_formats" {
#  type        = any
#  default     = {}
#  description = <<-EOT
#    Describe additional descriptors to be output in the `descriptors` output map.
#    Map of maps. Keys are names of descriptors. Values are maps of the form
#    `{
#       format = string
#       labels = list(string)
#    }`
#    (Type is `any` so the map values can later be enhanced to provide additional options.)
#    `format` is a Terraform format string to be passed to the `format()` function.
#    `labels` is a list of labels, in order, to pass to `format()` function.
#    Label values will be normalized before being passed to `format()` so they will be
#    identical to how they appear in `id`.
#    Default is `{}` (`descriptors` output will be empty).
#    EOT
#}
