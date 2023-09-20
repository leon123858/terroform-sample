# Learn Terraform - Provision a GKE Cluster

This repo is a companion repo to the [Provision a GKE Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke), containing Terraform configuration files to provision an GKE cluster on GCP.

This sample repo also creates a VPC and subnet for the GKE cluster. This is not
required but highly recommended to keep your GKE cluster isolated.

## MY RUN STEP

for terraform

```shell
terraform init
terraform apply
```

in cloud shell, after connect gke

```shell
# gcloud container clusters get-credentials <project> --region <region> --project <project>
# write code here: `./sampleIaC.yaml`
vim sampleIaC.yaml
# CLI 跑完還是要等幾分鐘, container 才會完成配置
kubectl apply -f sampleIaC.yaml
```

try result (should wait until GKE state is OK, it need really long time)

```shell
# 可以看到 nginx 的 404 頁面即表示成功
sudo curl --resolve "hello-world.nginx:80:<your-load-balancer-ip>" -i http://hello-world.nginx/hello-world1
sudo curl --resolve "hello-world.nginx:80:<your-load-balancer-ip>" -i http://hello-world.nginx/hello-world2
```

release resource for k8s

注意, kubectl 內部的部分操作會動到 GKE 外部資源, 所以在用 terraform 刪除前要先用 kubectl 刪一次

```shell
# in place connect gke
kubectl delete namespace nginx-group
# in place use terraform
terraform destroy
```
