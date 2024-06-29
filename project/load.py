import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

# URL и порт для запросов
url = "http://158.160.176.79:80"


def send_request():
    try:
        response = requests.get(url)
        # Выводим статус-код ответа
        print(f"Status Code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")


# Количество потоков и запросов
num_threads = 1000
total_requests = 1000000

# Используем ThreadPoolExecutor для выполнения запросов в несколько потоков
with ThreadPoolExecutor(max_workers=num_threads) as executor:
    futures = [executor.submit(send_request) for _ in range(total_requests)]

    for future in as_completed(futures):
        try:
            future.result()
        except Exception as e:
            print(f"Request generated an exception: {e}")
