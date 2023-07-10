# Github Actions runners (groups) for K8S

### 1) Create runner group
```
Org Settings > Actions > Runner groups
```

### 2) Create PAT
```
User Settings > Developer Settings > Personal access tokens > Tokens (classic)
Choose: admmin:org
```

### 3) Create Secret
```
$ kubectl apply -f k8s/secret.yaml
```

### 4) Edit k8s/sdeploy.yaml
```
Change ORGANIZATION_NAME and GROUP_NAME
```

### 5)
```
$ kubectl apply -f k8s/deploy.yaml
```
