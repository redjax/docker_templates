# Calibre/Calibre-Web

## Setup

*Note: If using Readarr, make sure Calibre/Calibre-web are on the same Docker network as the Readarr container.*

## Usage

### Plugins

You can install most plugins through the built-in plugin manager. Some plugins need to be downloaded as a `.zip` file and copied into `docker_calibre/calibre/plugins`.

Useful plugins list:

- DeDRM Tools *[Github](https://github.com/noDRM/DeDRM_tools)*
  - This plugin must be installed by copying into `docker_calibre/calibre/plugins`. It is not available in the plugin manager
  - Download the `.zip` file and extract. The `.zip` files within the extracted archive are the plugins
- Find Duplicates
- Mass Search & Replace
- KFX Input *[MobileRead.com](https://www.mobileread.com/forums/showthread.php?t=291290)*
  - Convert Kindle KFX books to other formats
- Kindle Collections
  - Manage Kindle collections in Calibre
- EpubMerge
- EpubSplit
- Job Spy
  - Make Calibre more useful
- Annotations
  - Fetch annotations (highlights, notes, etc) from eBook readers (like Kindle)
- Count Pages
  - Get a page count for selected book
- 

## Notes

- Calibre-web default login:
  - User: `admin`
  - Password: `admin123`