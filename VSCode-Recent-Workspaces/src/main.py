#!/usr/bin/env python3
# encoding: utf-8

import json
import os
import sqlite3
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

def get_storage_path():
    return Path.home() / "Library" / "Application Support" / "Code" / "User" / "globalStorage" / "storage.json"

def get_recent_db_path():
    return Path.home() / ".vscode-shared" / "sharedStorage" / "state.vscdb"

def load_storage_data():
    storage_path = get_storage_path()
    if not storage_path.exists():
        return {}
    with open(storage_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_recent_order():
    db_path = get_recent_db_path()
    if not db_path.exists():
        return []

    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        cursor.execute("SELECT value FROM ItemTable WHERE key='history.recentlyOpenedPathsList'")
        row = cursor.fetchone()
        conn.close()

        if not row:
            return []

        data = json.loads(row[0])
        entries = data.get('entries', [])

        order = []
        for entry in entries:
            if 'workspace' in entry:
                config_path = entry['workspace'].get('configPath', '')
                if config_path.startswith('file://'):
                    path = unquote(urlparse(config_path).path)
                    order.append(path)
            elif 'folderUri' in entry:
                folder_uri = entry['folderUri']
                if folder_uri.startswith('file://'):
                    path = unquote(urlparse(folder_uri).path)
                    order.append(path)

        return order
    except Exception:
        return []

def parse_profiles(data):
    profiles = {}
    try:
        items = data['lastKnownMenubarData']['menus']['Preferences']['items']
        for item in items:
            if item.get('id', '') == 'submenuitem.Profiles':
                submenu_items = item.get('submenu', {}).get('items', [])
                for submenu_item in submenu_items:
                    if submenu_item.get('id', '').startswith('workbench.profiles.actions.profileEntry.'):
                        profile_key = submenu_item['id'].replace('workbench.profiles.actions.profileEntry.', '')
                        profile_name = submenu_item.get('label', profile_key)
                        profiles[profile_key] = profile_name
    except (KeyError, IndexError):
        pass
    return profiles

def parse_workspaces(data):
    workspaces = []
    try:
        workspace_map = data.get('profileAssociations', {}).get('workspaces', {})
        for uri, profile_key in workspace_map.items():
            if uri.startswith('file://'):
                parsed = urlparse(uri)
                path = unquote(parsed.path)
                workspaces.append({
                    'path': path,
                    'profile_key': profile_key
                })
    except Exception:
        pass
    return workspaces

def build_alfred_items(workspaces, profiles, recent_order, query=''):
    items = []
    for ws in workspaces:
        path = ws['path']
        profile_key = ws['profile_key']
        profile_name = profiles.get(profile_key, 'Default')

        folder_name = os.path.basename(path)

        if query and query.lower() not in folder_name.lower() and query.lower() not in profile_name.lower():
            continue

        if not os.path.exists(path):
            continue

        item = {
            'uid': path,
            'title': folder_name,
            'subtitle': f'{profile_name} • {path}',
            'arg': f'{path}||{profile_name}',
            'autocomplete': folder_name,
            'icon': {
                'type': 'fileicon',
                'path': path
            },
            'match': f'{folder_name} {profile_name}'
        }
        items.append(item)

    def sort_key(item):
        path = item['uid']
        try:
            return recent_order.index(path)
        except ValueError:
            return len(recent_order)

    items.sort(key=sort_key)
    return items

def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ''

    data = load_storage_data()
    profiles = parse_profiles(data)
    workspaces = parse_workspaces(data)
    recent_order = get_recent_order()
    items = build_alfred_items(workspaces, profiles, recent_order, query)

    output = json.dumps({'items': items})
    print(output)

if __name__ == '__main__':
    main()
