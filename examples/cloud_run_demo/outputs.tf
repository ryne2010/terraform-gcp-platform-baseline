output "service_url" {
  value       = module.hello_service.service_uri
  description = "Deployed Cloud Run service URL."
}
