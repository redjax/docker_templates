"""Convert a backup.json exported from Linkwarden into a bookmarks.html file.

Description:
  Script copied from: https://gist.github.com/osorionicolas/bac8fb3f0e3cdf38107a803ba7606035

"""

import json
import logging
from datetime import datetime

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(message)s')

def date_to_timestamp(date_str):
    try:
        dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        return int(dt.timestamp())
    except ValueError as e:
        logging.warning(f'Error converting date: {e}')
        return None

def build_collection_tree(collections):
    # Create a dictionary mapping collection IDs to collections with empty children arrays
    id_to_collection = {col['id']: {**col, 'children': []} for col in collections}
    root_collections = []

    # First pass: add collections to their parent's children array
    for col in id_to_collection.values():
        parent_id = col.get('parentId')
        if parent_id and parent_id in id_to_collection:
            id_to_collection[parent_id]['children'].append(col)
        else:
            root_collections.append(col)

    return root_collections

def render_collection(collection):
    html = []
    html.append(f'<DT><H3>{collection["name"]}</H3>')
    html.append('<DL><p>')

    # Add links
    for link in collection.get('links', []):
        try:
            html.append(
                f'    <DT><A HREF="{link["url"]}">{link["name"]}</A>'
            )
        except KeyError as e:
            logging.warning(f'Missing key in link: {e}')
        except Exception as e:
            logging.warning(f'Error processing link: {e}')
    
    # Recursively add children collections
    for child in collection.get('children', []):
        html.append(render_collection(child))

    html.append('</DL><p>')
    return '\n'.join(html)

def json_to_netscape_html(json_data):
    html_output = [
        '<!DOCTYPE NETSCAPE-Bookmark-file-1>',
        '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
        '<TITLE>Bookmarks</TITLE>',
        '<H1>Bookmarks</H1>'
    ]

    collections = json_data.get('collections', [])
    tree = build_collection_tree(collections)

    for collection in tree:
        html_output.append(render_collection(collection))
    
    return '\n'.join(html_output)

# Main
with open('backup.json', 'r', encoding='utf-8') as file:
    json_data = json.load(file)

html_content = json_to_netscape_html(json_data)

with open('bookmarks.html', 'w', encoding='utf-8') as file:
    file.write(html_content)

print("NetScape HTML file generated successfully.")

