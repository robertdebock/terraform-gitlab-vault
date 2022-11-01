# Create an AWS dynamic secrets engine.
resource "vault_aws_secret_backend" "default" {
  description               = "AWS secret engine."
  path                      = "aws"
  access_key                = var.aws_access_key
  secret_key                = var.aws_secret_key
  default_lease_ttl_seconds = 300
  max_lease_ttl_seconds     = 600
}

# Create a role to allow actions.
resource "vault_aws_secret_backend_role" "default" {
  backend         = vault_aws_secret_backend.default.path
  name            = "gitlab"
  credential_type = "iam_user"
  policy_document = file("${path.module}/files/aws_role.json")
}

# Enable the JWT autentication engine.
resource "vault_jwt_auth_backend" "default" {
  description  = "JWT authentication to GitLab"
  path         = "jwt"
  jwks_url     = "https://gitlab.com/-/jwks"
  bound_issuer = "gitlab.com"
  default_role = vault_aws_secret_backend_role.default.name
}

# Allow read access to AWS.
resource "vault_policy" "default" {
  name   = "aws_read"
  policy = file("${path.module}/files/policy.tf")
}

# Create a role to allow requesting AWS access.
resource "vault_jwt_auth_backend_role" "default" {
  backend        = vault_jwt_auth_backend.default.path
  role_name      = "gitlab"
  token_policies = ["default", vault_policy.default.name]

  bound_claims = {
    project_id = gitlab_project.default.id
    ref        = gitlab_project.default.default_branch
    ref_type   = "branch"
  }
  user_claim = "user_email"
  role_type  = "jwt"
}

# Make a GitLab project.
resource "gitlab_project" "default" {
  name                   = "vault-aws-demo"
  description            = "A demo to use HashiCorp Vault in a GitLab pipeline."
  default_branch         = "main"
  shared_runners_enabled = false
  visibility_level       = "public"
  depends_on             = [vault_jwt_auth_backend.default]
}

# Assign a specific runner to the project.
resource "gitlab_project_runner_enablement" "default" {
  project   = gitlab_project.default.id
  runner_id = 18209306
}

# Add a Terraform file to the GitLab project.
resource "gitlab_repository_file" "maintf" {
  project        = gitlab_project.default.id
  file_path      = "main.tf"
  branch         = "main"
  content        = base64encode(file("${path.module}/files/main.tf"))
  author_email   = "robert@meinit.nl"
  author_name    = "Robert de Bock"
  commit_message = "Add main.tf."
  depends_on = [
    gitlab_project_runner_enablement.default
  ]
}

# Add the pipeline file to the GitLab project.
resource "gitlab_repository_file" "gitlabciyml" {
  project        = gitlab_project.default.id
  file_path      = ".gitlab-ci.yml"
  branch         = "main"
  content        = base64encode(file("${path.module}/files/gitlab-ci.yml"))
  author_email   = "robert@meinit.nl"
  author_name    = "Robert de Bock"
  commit_message = "Add .gitlab-ci.yml."
  depends_on = [
    gitlab_repository_file.maintf
  ]
}
