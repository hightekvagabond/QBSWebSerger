#!/usr/local/bin/python

import sys
import boto3
import time
import json
import os
epoch = time.time()


#TODO: this uses the credentials in my .aws credentials file called "qbs" when we make it a lambda we can take this away
session = boto3.Session(profile_name='qbs')


ec2 = boto3.resource('ec2')
ec2_client = boto3.client('ec2')
cf_client = boto3.client('cloudformation')

#list all the current EC2 Instances 
print("INSTANCES:")
instances = ec2.instances.filter(
    Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
for instance in instances:
    print(instance.id, instance.instance_type)


#looking for an elastic ip named qbswebserver, if it doesn't exist we fail
qbsip = ""
print("Elastic IPS:")
filters = [
    {'Name': 'domain', 'Values': ['vpc']}
]
response = ec2_client.describe_addresses(Filters=filters)
for myip in response['Addresses']:
    for tag in myip['Tags']:
        if tag['Key'] == 'Name':
            if tag['Value'] == 'qbswebserver':
                qbsip = myip
                print(myip)
if qbsip == "":
    sys.exit("This program requires you to create an elastic ip called qbswebserver, do this through the console and set the tag 'Name'")


#Read in the cloud formation, we might generate it in the future, or need to keep it on s3 later
ec2cf = open( '/root/src/EC2InstanceWithSecurityGroupSample.template' , 'r').read()

#TODO: fix this into a proper global variable config
#this is used later on to connect, changing so that filename and AWS entry are the same
keyname="webmail"

#Create the CloudFormation for the EC2 Instance
stackname = 'qbswebserver' + str(int(epoch))
print('Creating stack id ' + stackname)
try:
    response = cf_client.create_stack(
        StackName=stackname,
        TemplateBody=ec2cf,
        Parameters=[
            { 'ParameterKey': 'KeyName', 'ParameterValue': keyname },
            { 'ParameterKey': 'InstanceType', 'ParameterValue': 't2.micro' },
        ],
        OnFailure='ROLLBACK'
    )
except Exception as e:
    print("Stack creation response: %s" % e)

print('##################################################################################################')
print('RESPONSE FROM CREATE:')
print(response)
print('##################################################################################################')


print('RESPONSE FROM DESCRIBE STACKS for Status:')
stackstatus = "CREATE_IN_PROGRESS"
while (stackstatus == 'CREATE_IN_PROGRESS'):
	time.sleep(5)
	response = cf_client.describe_stacks( StackName=stackname) 
	print(response)
	stackstatus = response['Stacks'][0]['StackStatus']
	print("----Checking Creation Status: " + stackstatus)

print('Current Status: ' + stackstatus)
if not stackstatus == 'CREATE_COMPLETE':
	print('SOMETHING WENT WRONG')
	sys.exit
print('##################################################################################################')


myinstanceid = '';
response = cf_client.describe_stack_resources( StackName=stackname)
print('RESPONSE FROM DESCRIBE RESOURCES:')
stackresources = response['StackResources']
for stackres in stackresources:
	if stackres['ResourceType'] == 'AWS::EC2::Instance':
		print('------------')
		myinstanceid = stackres['PhysicalResourceId']
		print(stackres)
		print('myinstanceid: ' + myinstanceid)
print('##################################################################################################')


print('RESPONSE FROM GETTING INSTANCE: ')
response = ec2_client.describe_instances( InstanceIds=[ myinstanceid ])
hostip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
print(response['Reservations'][0]['Instances'][0])
print('hostip: ' + hostip)

print('##################################################################################################')



#####install ansible
time.sleep(120) #Wait for SSH Deamon to come up
connectstr = ' -o StrictHostKeyChecking=no  -i ~/.ssh/%s.pem ' % keyname
connecthost = ' ubuntu@' + hostip 
sshconnectstr = 'ssh ' + connectstr + ' ' + connecthost
scpconnectstr = 'scp ' + connectstr
os.system(scpconnectstr + ' /root/src/install_ansible.sh ' + connecthost + ":/home/ubuntu/install_ansible.sh")
os.system(sshconnectstr +  " '/home/ubuntu/install_ansible.sh' ")




#https://www.techrepublic.com/article/how-to-install-ansible-on-ubuntu-server-18-04/

print(sshconnectstr)


#####TODO: Take this out, it deletes the stack at the end of the script for easy prototyping
#response = cf_client.delete_stack( StackName=stackname)
