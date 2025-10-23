import re
from pathlib import Path
import sys

def check_hdr_state(filepath):
    """Check current HDR state and return status"""
    try:
        monitors_conf_path = Path(filepath)
        if not monitors_conf_path.is_absolute():
            monitors_conf_path = Path.home() / ".config/hypr/monitors.conf"

        with open(monitors_conf_path, 'r') as f:
            content = f.read()
        
        has_hdr_cm = re.search(r'cm\s*=\s*hdr', content)
        has_bitdepth_10 = re.search(r'bitdepth\s*=\s*10', content)
        
        if has_hdr_cm and has_bitdepth_10:
            print("HDR enabled")
            return True
        else:
            print("HDR disabled")
            return False
    except Exception as e:
        print(f"Error checking HDR state: {e}")
        return False

def toggle_monitor_settings(filepath):
    """
    Toggles the 'cm' and 'bitdepth' settings in the monitors.conf file.

    If 'cm = auto' and 'bitdepth = 8', it changes them to 'cm = hdr' and 'bitdepth = 10'.
    Otherwise, it changes 'cm = hdr' and 'bitdepth = 10' to 'cm = auto' and 'bitdepth = 8'.

    Args:
        filepath (str): The path to the monitors.conf file.
    """
    try:
        # Check if the path is absolute, if not, assume it's in the user's home directory
        monitors_conf_path = Path(filepath)
        if not monitors_conf_path.is_absolute():
            monitors_conf_path = Path.home() / ".config/hypr/monitors.conf"

        with open(monitors_conf_path, 'r') as f:
            content = f.read()

        # Check for the current state
        has_auto_cm = re.search(r'cm\s*=\s*auto', content)
        has_hdr_cm = re.search(r'cm\s*=\s*hdr', content)
        has_bitdepth_8 = re.search(r'bitdepth\s*=\s*8', content)
        has_bitdepth_10 = re.search(r'bitdepth\s*=\s*10', content)

        if has_auto_cm and not has_hdr_cm:
            # Change to HDR settings
            new_content = re.sub(r'cm\s*=\s*auto', 'cm = hdr', content)
            # Remove all existing bitdepth lines first
            new_content = re.sub(r'\s*bitdepth\s*=\s*\d+\s*\n', '\n', new_content)
            # Add bitdepth = 10
            new_content = re.sub(r'(cm\s*=\s*hdr)', r'\1\n        bitdepth = 10', new_content)
            print("Changed settings to HDR (cm = hdr, bitdepth = 10).")
        else:
            # Change to SDR settings (assuming it's currently HDR)
            new_content = re.sub(r'cm\s*=\s*hdr', 'cm = auto', content)
            # Remove all existing bitdepth lines first
            new_content = re.sub(r'\s*bitdepth\s*=\s*\d+\s*\n', '\n', new_content)
            # Add bitdepth = 8
            new_content = re.sub(r'(cm\s*=\s*auto)', r'\1\n        bitdepth = 8', new_content)
            print("Changed settings to SDR (cm = auto, bitdepth = 8).")

        # Write the updated content back to the file
        with open(monitors_conf_path, 'w') as f:
            f.write(new_content)

        print(f"File '{monitors_conf_path}' updated successfully.")

    except FileNotFoundError:
        print(f"Error: The file '{monitors_conf_path}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# The path to your monitors.conf file
# Use the full path for better reliability
config_file_path = Path.home() / ".config/hypr/monitors.conf"

# Handle command line arguments
if len(sys.argv) > 1 and sys.argv[1] == "--check":
    # Check HDR state
    check_hdr_state(config_file_path)
else:
    # Toggle HDR state
    toggle_monitor_settings(config_file_path)
