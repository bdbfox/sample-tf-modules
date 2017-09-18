resource "aws_elasticache_parameter_group" "redis_params" {
  name   = "${var.project_name}-${var.env_name}-api-cluster-parameters"
  family = "redis3.2"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name = "cluster-enabled"
    value = "no"
  }

  parameter {
    name = "reserved-memory-percent"
    value = "35"
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "${var.project_name}-${var.env_name}-redis-group"
  subnet_ids = ["${split(",", length(var.private_subnets) > 0 ? join(",", var.private_subnets) : join(",", data.terraform_remote_state.network.private_subnets))}"]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id                    = "${var.project_name}-${var.env_name}-redis"
  engine                        = "redis"
  node_type                     = "${var.redis_node_type}"
  port                          = 6379
  num_cache_nodes               = 1
  parameter_group_name          = "${aws_elasticache_parameter_group.redis_params.id}"
  security_group_ids            = ["${var.vpc_sg != "" ? var.vpc_sg : data.terraform_remote_state.network.vpc_sg}"]
  subnet_group_name             = "${aws_elasticache_subnet_group.redis_subnet.name}"

  lifecycle {
    create_before_destroy = true
  }
}

output "redis_host" {
  value = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
}
