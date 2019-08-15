In this project we need to automate the infrastructure and application deployment. First we need to create infrastructure using IaC (ARM template) and automate environment’s deployment through Azure DevOps. Then we should achieve application build process in every single code change in specified branches, automatic deploy to DEV environment and deployment with approval to PROD environment.

There are two environments:

DEV:

Needed follow below configuration for resources: 

1.	Virtual Machine
a)	IIS on VM
b)	Rewrite module for IIS
c)	One virtual host to listen port 80
d)	One virtual host to listen port 443
e)	Add Public IP
f)	Add NSG and block all public incoming traffic except Azure defaults rules and 8172
g)	Enable Web Deploy

2.	SQL server
a)	Create and elastic pool
b)	Import all db from backups
c)	Allow connection only from DEV environment

PROD:

Production environment has only two resource:
Needed follow below configuration for resources: 

1.	Virtual Machine
a)	IIS 
b)	Rewrite module for IIS
c)	One virtual host to listen port 80
d)	One virtual host to listen port 443
e)	Add public IP
f)	Allow only 80, 443, 8172 ports for incoming traffics
g)	Enable Dynamic Web Compression
h)	Enable Web Deploy
i)	Use Azure Storage account for all infrastructure artifacts 
j)	Make sure Application Pool Identities runs under Local System

2.	SQL:
a)	Create and elastic pool
b)	Import all db from backups
c)	Allow connection only from PROD environment

Add all infrastructure codes to repo and create pipeline to Deploy and Remove (by keeping all deployment history in resource group) Environments from CI/CD tools (From Azure DevOps) manually.


Build application

Using Azure DevOps:

1.	Get the build in every change in dev and master branch application code repo
2.	Run unit test for application

Deploy application
Using Azure DevOps:

1.	Use same build artifact (without rebuild) for all environments
2.	Automatically Deploy to DEV
3.	If DEV deployment succeed enable deploy to PROD
4.	Deploy to PROD should be on demand and requires approval
5.	Connection to SQL and application setting should be parameterized for different environments.

* Get Application from   https://github.com/BehbudSh/blogapp.git repository.
* Get SQL db backups from https://github.com/BehbudSh/AzureIaCProject/blob/master/dbbackup/newBlog.bacpac URL. 
