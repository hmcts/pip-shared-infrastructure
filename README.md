# pip-apim-infrastructure
Repository for deploying support infrastructure for PIP APIM

### PostgresSQL release issue
Due to Azure DevOps having dynamic build server, we need to white list the IP address during deployment.
There is a task to do this, but it happens before the database is created.
Therefore, if it is a new build it will fail on the first run, but on the second run the database should be created, so it will work.
Fix for this is to add the script to whitelist in the postgres module between the DB deployment and user access.

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
