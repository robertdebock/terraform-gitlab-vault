output "gitlab_url" {
  value       = gitlab_project.default.web_url
  description = "The URL to the created GitLab URL."
}