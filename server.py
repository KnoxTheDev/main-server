
import os
import requests

api_base_url = 'https://api.papermc.io/v2/projects'
project_name = 'paper'
save_directory = os.getcwd()

def make_api_request(endpoint, params=None):
    response = requests.get(f'{api_base_url}/{endpoint}', params=params)
    return response.json() if response.status_code == 200 else None

def get_version_segment(segment):
    return segment if segment.isdigit() else str(segment)

def get_latest_version():
    versions_response = make_api_request(project_name)
    if versions_response and 'versions' in versions_response:
        versions = versions_response['versions']
        return versions[-1] if versions else None
    else:
        return None

def download_and_save_server_jar(version):
    builds_response = make_api_request(f'{project_name}/versions/{version}')
    if builds_response and 'builds' in builds_response and builds_response['builds']:
        latest_build = builds_response['builds'][-1]
        download_url = f'{api_base_url}/{project_name}/versions/{version}/builds/{latest_build}/downloads/paper-{version}-{latest_build}.jar'
        print(f'Downloading server.jar for version {version} and build {latest_build}...')
        response = requests.get(download_url, allow_redirects=True)
        if response.status_code == 200:
            file_path = os.path.join(save_directory, 'server.jar')
            with open(file_path, 'wb') as file:
                file.write(response.content)
            print(f'Server.jar for version {version} and build {latest_build} downloaded and saved successfully to {file_path}')
        else:
            print(f'Failed to download server.jar for version {version} and build {latest_build}. Status Code: {response.status_code}')
    else:
        print(f'No builds found for version {version}.')

if __name__ == '__main__':
    latest_version = get_latest_version()
    if latest_version:
        download_and_save_server_jar(latest_version)
    else:
        print('Failed to retrieve the latest version.')
