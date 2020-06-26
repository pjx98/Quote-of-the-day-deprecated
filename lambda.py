from __future__ import print_function
import boto3
import random

client = boto3.client('sns')

def lambda_handler(event, context):
    
    dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-1')
    table = dynamodb.Table('Quotes')
    
    
    
    key = random.randint(1, 5)
    item = table.get_item(Key={'id': key})
    
    Author = (item['Item']['Author'])
    Quote = (item['Item']['Quote'])
    client.publish(TopicArn='arn:aws:sns:ap-southeast-1:149443301097:Email_quotes',
    Message = "Here's your quote for the day!\n \n" + Quote + ' - ' + Author)
    
    
