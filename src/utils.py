import csv


def write_csv(data, path, header=None):
    with open(path, "w") as f:
        writer = csv.writer(f)
        if header:
            writer.writerow(header)
        writer.writerows(data)


def write_dict_list_to_csv(dict_list, csv_file):
    fieldnames = dict_list[0].keys()  # Assuming all dictionaries have the same keys

    with open(csv_file, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write the header
        writer.writeheader()

        # Write the data
        writer.writerows(dict_list)


def read_csv_dict(path):
    data = []
    with open(path, "r") as f:
        reader = csv.DictReader(f)
        for line in reader:
            data.append(line)
    return data
