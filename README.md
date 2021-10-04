# pip-apim-infrastructure
Repository for deploying support infrastructure for PIP APIM


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

### Changing password on pact-broker database:
If you need to update the password for the pact-broker database, then you will need to run the Shared Services pipeline and then the Shared Infrastructure pipeline.

### Add Key Vault Secrets from Azure DevOps Library
If you would like to add a new Variable from the Azure DevOps Library to the Shared Key Vault, then you will need to add it to the YAML list in this file.
> pipeline\steps\tf-SharedServices-variables.yaml:19
