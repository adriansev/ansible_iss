#!/usr/bin/env python3

import os
import sys
import requests
import wget

from rich.pretty import pprint

tools_info_json = 'https://raw.githubusercontent.com/Seagate/ToolBin/refs/heads/master/SeaChest/seachestupdate.json'

info_response = requests.get(tools_info_json)
file_content = None
if info_response.status_code == 200:
    file_content = info_response.json()
else:
    print('Failed to retrieve the file.')
    sys.exit(1)

if not file_content:
    print('no file content')
    sys.exit(1)

tools_list = file_content[0]['seachest_apps']

git_path_select = [x for x in tools_list if 'git_path' in x]
git_path = None
if git_path_select: git_path = git_path_select[0]['git_path']
if not git_path:
    print('no git_path')
    sys.exit(1)

for tool in tools_list:
    if 'name' not in tool: continue
    tool_path = tool['lin']['app_path']
    tool_name = tool['lin']['64bit']
    tool_path_full = f'{git_path}{tool_path}{tool_name}'
    tool_name_local = tool_name.replace('_x86_64-alpine-linux-musl_static','').lower()
    downloaded_file = wget.download(tool_path_full, out = f'bin/{tool_name_local}', bar = False)
    if downloaded_file:
        os.chmod(downloaded_file, 0o0754)

