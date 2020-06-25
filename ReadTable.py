import boto3
from botocore.exceptions import ClientError
import random 


def get_quotes(id, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-1')

    table = dynamodb.Table('Quotes')

    try:
        response = table.get_item(Key={'id': id})
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return response['Item']


if __name__ == '__main__':
    quote_id = random.randint(1, 5)
    quotes = get_quotes(quote_id)
    print(quotes['Quote'], '\n-', quotes['Author'])   
    
    

