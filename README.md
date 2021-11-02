# pip-apim-infrastructure
Repository for deploying support infrastructure for PIP APIM

### PostgresSQL Deployment
The infrastructure to deploy Databases for PIP services are done in their respective repositories using the Jenkins pipeline.

### Monitoring and Alerting:
If you need to update web test endpoint, add or modify `var.ping_tests` in /environments/*env*.tfvars:

```
ping_tests = [
  {
    pingTestName = "webcheck-name"
    pingTestURL  = "https://webcheck-url"
    pingText     = "Status: UP" # optional
  }
]
```

To change action group email, modify `var.support_email` in `/environments/shared.tfvars`

### Add Key Vault Secrets from Azure DevOps Library
If you would like to add a new Variable from the Azure DevOps Library to the Shared Key Vault, then you will need to add it to the YAML list in this file.
> pipeline\steps\tf-SharedServices-variables.yaml:19
