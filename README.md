# terroform-sample

## basic command

init

```sh
terraform init
```

next state check

```sh
terraform plan
```

now state

```sh
terraform show
```

migrate to next state

```sh
terraform apply
```

remove all state now

```sh
terraform destroy
```

recreate all resource

```sh
# terraform taint [some resource]
terraform taint google_compute_instance.vm_instance
```
