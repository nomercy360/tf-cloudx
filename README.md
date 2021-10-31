# Terraform configuration to deploy Nextcloud on GCP

## Prerequisite

- gcloud sdk https://cloud.google.com/sdk/docs/install

## Before you start

```
gcloud auth application-default login
```

### Initialize

```
terraform init
terraform plan
```

### Run deploy

```
terraform apply
```

### Destroy infrastructure

```
terraform destroy
```

### Access web-interface

```
# Get the EXTERNAL-IP addres
kubectl get svc | grep nginx-ingress-controller 

# Paste to hosts file address from previous command
<EXTERNAL-IP> nextcloud.kube.home

#Go to http://nextcloud.kube.home in your browser
```



