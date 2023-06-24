import sys
from octobrowser.helper import write_file
from octobrowser.octo_service import OctoService

if __name__ == "__main__":

    if len(sys.argv) > 1:
        action = sys.argv[1]
        match action:
            case "export_data":
                profiles = []
                octo_service = OctoService()
                profiles_uuids = octo_service.get_profiles_uuid()

                proxies = octo_service.get_proxies()
                write_file(proxies, f'octobrowser_proxies.json', is_json=True)

                tags = octo_service.get_tags()
                write_file(tags, f'octobrowser_tags.json', is_json=True)

                for uuid in profiles_uuids:
                    profiles.append(octo_service.get_profile_data(uuid))
                write_file(profiles, f'octobrowser_profiles.json', is_json=True)
            case "import_data":
                pass
            case _:
                print("Use the arguments for script 'export_data' or 'import_data'")
    else:
        print("Use the arguments for script 'export_data' or 'import_data'")
