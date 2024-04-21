import urllib.parse
import hashlib
import base64
import json
import os

def get_result(url, event):
    if url == "/user":
        return shorten(event)

    return response(404, {}, False, 'This path does not exist')

def response(statusCode, headers, isBase64Encoded, body):
    return {
        'statusCode': statusCode,
        'headers': headers,
        'isBase64Encoded': isBase64Encoded,
        'body': body,
    }

def handler(event, context):
    url = event.get('url')
    if url:
        # из API-gateway url может прийти со знаком вопроса на конце
        if url[-1] == '?':
            url = url[:-1]
        return get_result(url, event)
    return response(404, {}, False, 'This function should be called using api-gateway')


def handler(event, context):
    api_key = 'f4572345f38241358bb131242242004'
    city_name = 'London'
    url = f'http://api.weatherapi.com/v1/current.json?key={api_key}&q={city_name}'

    response = requests.get(url)
    if response.status_code == 200:
        weather_data = response.json()
        # Обработка данных о погоде
        return {
            'statusCode': 200,
            'body': weather_data
        }
    else:
        return {
            'statusCode': response.status_code,
            'body': 'Error fetching weather data'
        }