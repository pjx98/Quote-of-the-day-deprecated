import boto3


def put_quotes(id, quote, Author, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('Quotes')
    response = table.put_item(
       Item={
           'id' : id,
           'Quote': quote,
           'Author': Author
             
            }
        
    )
    return response


if __name__ == '__main__':
    quotes_resp = put_quotes(1, '"Live as if you were to die tomorrow. Learn as if you were to live forever"', 'Mahatma Gandhi')
    quotes_resp = put_quotes(2, '"That which does not kill us makes us stronger"', 'Friedrich Nietzsche')
    quotes_resp = put_quotes(3, '"Be who you are and say what you feel, because those who mind don’t matter and those who matter don’t mind"', 'Bernard M. Baruch')
    quotes_resp = put_quotes(4, '"We must not allow other people’s limited perceptions to define us."', 'Virginia Satir')
    quotes_resp = put_quotes(5, '"Do what you can, with what you have, where you are."', 'Theodore Roosevelt' )                            

