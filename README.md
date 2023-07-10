# Github Actions runners (groups) for K8S
```
Available commands:
* Kubectl
* Terraform
```
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

### An action example for build and push to GCR
```
name: runner-build

on: 
  release:
    types: [created]

jobs:

  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Get the version
        id: get_tag_name
        run: echo ::set-output name=GIT_TAG_NAME::${GITHUB_REF/refs\/tags\//}        
      - name: Build and Push
        uses: RafikFarhad/push-to-gcr-github-action@v4.1.0
        with:
          gcloud_service_key: ${{ secrets.ServiceAccountWithGCRAccess }}
          registry: gcr.io
          project_id: yourGCPProject
          image_name: actions-runner
          image_tag: latest,${{ steps.get_tag_name.outputs.GIT_TAG_NAME }}
```
