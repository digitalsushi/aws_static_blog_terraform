# Terraform (version 12 compatible) S3 static website with HTTPS on CloudFront

# DISCLAIMER

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(In plain English: If you use this software, it's not my fault if you spend a lot
of your money.)

# What is this in Plain English?

This code sets AWS up for you to host a free static website with HTTPS. The domain
isn't free, that's up to you to get one.

# What is this?

Terraform is an infrastructure as code tool that allows for the automatic
configuration of servers, networking, storage, and related services. Terraform
operates on AWS products but it also operates on many other vendors. We are going
to be using here to set up a static website on AWS, where we can store the website
in an S3 bucket and serve it on the Internet using a CloudFront CDN on HTTPS, using
a fully signed TLS certificate.

A static website means that all the files on the website are served directly to the
web browser client - there is no running code on a server. 

The result of this code is an HTTPS website that you can upload files to, and get from
https://blog.example.com.  


# How do I get Terraform on my computer?

Terraform is a command line tool created by HashiCorp, the makers of Vagrant and Packer.

The program is written in Golang, and as such its distribution is a single file that has
no specific directory requirements. You can download Terraform yourself at this URL:

https://www.terraform.io/downloads.html

Make sure you're downloading version 12, as this is the version the project is compatible with.

Follow the installation directions so that terraform is available in your $PATH. If you don't
know what this means, that's fine! But you should probably do a refresher on command lines before
you continue, just as a measure for whether you are prepared for the rest of this process.

# How are Terraform projects organized?

Terraform treats directories as its work units. A directory can contain multiple terraform
related files, and terraform will inspect any and all that it deems as relevant for processing
and then calculate what the intended effect is. In the calculus of these files, there is a general
flow of inputs, via the use of runtime parameters (command line arguments), variable input files, and
outputs, which are both the creation of hybrid cloud services, and data files that store the calculated
results from the creation of these services.

Terraform supports the concept of reusable code with its 'terraform modules'. A module can be referenced by
source control (such as git), by other common terraform namespaces, or can be simply a subdirectory within
an existing terraform project.

Most terraform directives are either the 'data' or 'resource' type. Most of these directives will connect
to a cloud environment and use an API to either learn about an existing resource, with the data type, or
create a resource, with the resource type. They generally are very similar to their counterparts, and 
will often use the same property names when possible. 

The code in this project has a minimally implemented module, which performs a very simple string utility
function, and references an existing domain name using a data resource to inspect a domain that you
indicate exists as a variable.

## State Files

Terraform keeps all of the calculated 'state' of your cloud environment in local directory. When it connects
to your account to see what exists and what needs to exists, it calculates and saves this difference. This allows
terraform to remember between running what has already been calculated. If you wait long enough and other
changes happen to your infrastructure, the state files will become out of date and you will need
to regenerate them before you apply a plan. (If you don't, you could cause a small mess to clean up.)

# What is the basic process for a Terraform process?

Terraform has three major phases: Init, Plan, and Apply.

## Init

The `terraform init` command will inspect a terraform project, and then download any required 
depencencies from the network. This is where you will get any syntax errors in your configuration, 
if you have any.

## Plan

The `terraform plan` command has its full runtime environment satisfied by the previous step, so it is
now able to connect to the cloud provider's API and interrogate what exists to calculate what needs to
be created in order to build the project. Semantic errors are caught in this phase - so you may not
have any typos, but you could have specified a configuration that doesn't make sense and this will catch 
most of it.

If you pass a -out parameter with a filename, it will store this elaborate configuration in a file which
can be used by the next step. This is not necessary, however.

Let us assume you are saving the plan with `terraform plan -out planfile`.

Each time you run this, a certificate request will be emailed to you. You need only one to be approved,
and you will manually make a reference to this by pasting the ARN of the certificate into the variables file. 
See below for the process.

## Apply

When you are ready to apply the plan, you can run `terraform apply planfile`.

# This code is not perfect

This project is not a good example of 'idempotent' code because the TLS certificate it
generates will generate a new certificate each time you run it. This is not ideal, so
please keep this in mind if you're looking at this code as a specimen of good idempotent
terraform code. We sidestep this with some shell scripting. Maybe there's a pure Terraform
way to do this - it's escaped me.

You need a TLS certificate for this project. If we request it from terraform, it's going
to keep generating a new certificate each time we run the `terraform plan` command. We 
do not want this. We want only one certificate because it's going to be valid no matter which
server our website lives on.

Instead, we have a tiny script that uses the aws command to request the certificate, and
store the reference to this inside your terraform variables file. This allows you to request
a certificate only once, instead of one for each time you run this experiment.

# Now You Try It

## Prerequisites

You must have terraform version 12, the 'jq' command, and the 'aws' command line installed.

Additionally, you must have your AWS credentials configured for the aws command to work. You can
do this with the aws configure command, or by exporting your keypair in your environment.

## Commands

* ./req\_cert.sh
* terraform init
* terraform plan -out "my\_planfile"
* run terraform apply "my\_planfile"

This process could take a while - a half hour is reasonable for a CloudFront to be created. It has never
finished less than 10 minutes. 

Go to S3 in the AWS Console if this completes, and upload a fun test file. Follow the S3 directions to make sure
the file is public. You can upload a whole folder if you want.

If you go to the HTTPS hostname of your website, the site should load your file! The default html page 
is named index.html. If you do not provide this file, then visiting the '/' URL will result in an error.
You can still load a known filename, such as '/song.mp3' if you loaded a file called song.mp3 into the 
root of the bucket.

That's it! This is just the tip of the iceberg, a little appetizer to get some more interest in using Terraform.

Thanks for checking it out!
