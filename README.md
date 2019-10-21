# AWS Complete Environment using Terraform

![Diagram](images/AWS_diagram.jpg)

This AWS environment built using the Terraform automation. We will create everything you need from scratch: VPC, subnets, routes, security groups, an EC2 machine with MySQL installed inside a private network, and a webapp machine with Apache and its PHP module in a public subnet. The webapp machine reads a table in the database and shows the result.

## Prerequisites

There are only 2 prerequisites:

- Having Terraform installed: it is pretty easy to install it if you haven’t already. You can find the instructions in my first article “Introduction to Terraform Modules.”
- If you want to log in to the machines, you need to have an AWS pem key already created in the region of your choice and downloaded on your machine. See how to create a pem key here if you haven’t already.

## The files structure

Terraform elaborates all the files inside the working directory so it does not matter if everything is contained in a single file or divided into many, although it is convenient to organize the resources in logical groups and split them into different files. Let’s take a look at how we can do this effectively:
