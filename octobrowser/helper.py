import json
import os


def read_file(file_path, is_json=False):
    with open(file_path, 'r') as file:
        if is_json:
            data = json.load(file)
        else:
            data = [line.strip() for line in file if not line.startswith("#")]
    return data


def write_file(data, file_path, is_json=False):
    directory = "octo_files"
    if not os.path.exists(directory):
        os.makedirs(directory)
    with open(f"{directory}/" + file_path, 'w') as outfile:
        if is_json:
            json.dump(data, outfile)
        else:
            outfile.write(data)
    print(f"The data is saved in the file {file_path}")
