import os

files_to_check = [
    "lib/pages/home/home.page.dart",
    "lib/pages/projects/projects.page.dart",
    "lib/pages/offer_details/offer_details.page.dart",
    "lib/pages/project_details/project_details.page.dart",
    "lib/pages/wishlist/wishlist.page.dart",
    "lib/pages/plot_availability/plot_availability.page.dart"
]

for file in files_to_check:
    with open(file, 'r') as f:
        content = f.read()
    
    content = content.replace("'/home/projects'", "'/projects'")
    content = content.replace("'/home/project/", "'/project/")
    content = content.replace("'/home/project'", "'/project'")
    
    with open(file, 'w') as f:
        f.write(content)

print("Paths updated.")
