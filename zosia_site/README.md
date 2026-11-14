This infrastructure serves both ZOSIA (zosia.org) and LEOSIA (leosia.org) from a single Cloud Run
service and a single Cloud SQL instance. The app picks the site by the domain of the request and
every site has its own database on the instance. Domains are listed in `locals.tf`. To host only
one site, remove the other site's domains from that list.

# How to contribute?

## 1. Make sure that your Google account has admin access to the Zosia GCP project

## 2. Install terraform and gcloud locally

Run these commands:

`gcloud config set project <project_id>` - sets the default project for your gcloud client

`gcloud auth application-default login` - obtains your ADC (Application Default Credentials), which terraform will later use automatically to authenticate with Google Cloud

## 3. Modify terraform code

## 4. Run `terraform plan`. If you're happy with the results, run `terraform apply`

## 5. Run `terraform fmt` and create a Pull Request with changes

# How to deploy this infrastructure to a new Google Cloud account?

## 1. Create a GCP project and save project id

## 2. Install terraform and gcloud locally

Run these commands:

`gcloud config set project <project_id>` - sets the default project for your gcloud client

`gcloud auth application-default login` - obtains your ADC (Application Default Credentials), which terraform will later use automatically to authenticate with Google Cloud

## 3. Set variables inside `locals.tf`

## 4. Create bucket for terraform backend in Google Cloud Storage

Uncomment the `backend "local"` block and comment out the `backend "gcs"` block in `backend.tf`.

Run:

```
terraform init
terraform apply -target="module.bootstrap"
```

Terraform will print out newly created bucket name (`tfstate_bucket_name = "<bucket_name>"`).

Now, uncomment the `backend "gcs"` block and comment out the `backend "local"` block in `backend.tf`.

Fill the `bucket = <bucket_name>` with the bucket name that terraform printed out earlier.

Run `terraform init -migrate-state`

## 5. Run `terraform apply` to create the entire infrastructure in Google Cloud

You might get errors about some services being disabled. If that happens, wait for a minute or two and run `terraform apply` one more time. The issue here is that while the terraform code automatically enables all required services, it usually takes some time before it propagates through Google's systems.

When you create the infrastructure, terraform will create a new database. This process might take around 10-15 minutes, so be patient.

## 6. In Google Cloud Console Web UI fill in all empty variables inside `django_settings` in the Secret Manager

## 7. Create a super user account

The easiest way to create a first user with admin privileges is to run the `createsuperuser` Cloud Run job from Web UI and set all the environment variables to the new user's data (like password, email, etc.). Just make sure to change this password later, since everyone with access to the GCP project will be able to view provided environment variables!

The job creates the user on the site set in the `SITE` variable (`zosia` or `leosia`), run it once per site.

## 8. Point the domains at Cloud Run

Every domain in `locals.tf` has to be verified for the GCP project (https://cloud.google.com/run/docs/mapping-custom-domains)
and its DNS records have to point at the values shown in the domain mapping.
