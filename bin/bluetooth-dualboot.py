#!/usr/bin/env python3
"""
Bluetooth Multi-Boot Key Sync Tool

Sync Bluetooth pairing keys between Windows, Linux, and macOS. Supports:
- Direct sync between OSes on the same machine (dual-boot / hackintosh)
- Export/import via portable JSON file (for transferring between separate machines)

Upstream: https://github.com/nbanks/bluetooth-dualboot
Fork: https://github.com/balcsida/bluetooth-dualboot/tree/claude/bluetooth-keyboard-pairing-hXvlH

Supports both Classic Bluetooth and Bluetooth LE devices.

Usage:
    sudo python3 bluetooth-dualboot.py --from-windows /mnt/windows --to-linux
    sudo python3 bluetooth-dualboot.py --from-linux --export-file keys.json
    sudo python3 bluetooth-dualboot.py --import-file keys.json --to-macos /
"""

import argparse
import configparser
import json
import os
import platform
import plistlib
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


IS_MACOS = platform.system() == 'Darwin'
IS_LINUX = platform.system() == 'Linux'


def check_root():
    """Check if script is running as root."""
    if os.geteuid() != 0:
        print("Error: This script must be run as root (sudo).")
        print("Usage: sudo python3 bluetooth-dualboot.py ...")
        sys.exit(1)


def format_mac_address(mac_string):
    """Format a MAC address string with colons (Linux format)."""
    mac_clean = mac_to_raw(mac_string).upper()
    return ':'.join(mac_clean[i:i+2] for i in range(0, 12, 2))


def mac_to_raw(mac_string):
    """Strip all separators from a MAC address and lowercase it."""
    return mac_string.replace(':', '').replace('-', '').lower()


def mac_to_macos(mac_raw):
    """Format a raw MAC address to macOS format (aa-bb-cc-dd-ee-ff)."""
    mac_clean = mac_to_raw(mac_raw)
    return '-'.join(mac_clean[i:i+2] for i in range(0, 12, 2))


def sanitize_hex_string(hex_str):
    """Remove spaces and convert to uppercase."""
    return hex_str.replace(' ', '').upper()


def reverse_bytes_hex(hex_bytes):
    """Reverse byte order of space-separated hex bytes and return as continuous string."""
    if not hex_bytes:
        return ''
    bytes_list = hex_bytes.strip().split()
    return ''.join(bytes_list[::-1]).upper()


def hex_bytes_to_decimal(hex_bytes):
    """Convert space-separated hex bytes (little-endian) to decimal."""
    if not hex_bytes:
        return ''
    reversed_hex = reverse_bytes_hex(hex_bytes)
    if not reversed_hex:
        return ''
    return str(int(reversed_hex, 16))


def run_chntpw_command(system_path, commands):
    """Run chntpw commands and return output."""
    cmd_input = '\n'.join(commands) + '\nq\n'
    try:
        result = subprocess.run(
            ['chntpw', '-e', system_path],
            input=cmd_input,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.stdout
    except subprocess.TimeoutExpired:
        print("Error: chntpw command timed out")
        return ''
    except FileNotFoundError:
        print("Error: chntpw not found. Please install it with: sudo pacman -S chntpw")
        sys.exit(1)


def parse_hex_value(output, value_name):
    """Parse a hex value from chntpw output."""
    # Match patterns like:
    # :00000  71 39 17 4A 28 B6 AD CE F0 71 90 7E 2F 0C 9E 55 q9.J(....q.~/..U
    pattern = rf'Value <{value_name}>.*?:00000\s+([0-9A-Fa-f\s]+?)(?:\s+\S+)?\s*\n'
    match = re.search(pattern, output, re.DOTALL)
    if match:
        hex_part = match.group(1).strip()
        # Clean up: take only hex characters and spaces
        hex_bytes = ' '.join(re.findall(r'[0-9A-Fa-f]{2}', hex_part))
        return hex_bytes
    return ''


def parse_dword_value(output, value_name):
    """Parse a DWORD value from chntpw ls output."""
    # Match: 4  4 REG_DWORD          <KeyLength>               16 [0x10]
    pattern = rf'REG_DWORD\s+<{value_name}>\s+(\d+)\s+\[0x([0-9A-Fa-f]+)\]'
    match = re.search(pattern, output)
    if match:
        return match.group(1)  # Return decimal value
    return ''


def get_windows_bluetooth_adapters(system_path):
    """Get list of Bluetooth adapters from Windows registry."""
    output = run_chntpw_command(system_path, [
        r'cd \ControlSet001\Services\BTHPORT\Parameters\Keys',
        'ls'
    ])

    adapters = []
    for line in output.split('\n'):
        # Match lines like: <14ac60552e28>
        match = re.search(r'<([0-9a-fA-F]{12})>', line)
        if match:
            adapters.append(match.group(1).lower())
    return adapters


def get_windows_bluetooth_devices(system_path, adapter_mac):
    """Get list of paired devices for an adapter from Windows registry."""
    output = run_chntpw_command(system_path, [
        rf'\ControlSet001\Services\BTHPORT\Parameters\Keys\{adapter_mac}',
        'cd .',
        'ls'
    ])

    # Actually need to cd properly
    output = run_chntpw_command(system_path, [
        rf'cd \ControlSet001\Services\BTHPORT\Parameters\Keys\{adapter_mac}',
        'ls'
    ])

    devices = []
    for line in output.split('\n'):
        # Match device subkeys like: <c3b8103fdd20>
        match = re.search(r'<([0-9a-fA-F]{12})>', line)
        if match:
            mac = match.group(1).lower()
            # Skip if it's MasterIRK or similar (values, not subkeys)
            if mac != adapter_mac:
                devices.append(mac)
    return devices


def get_device_keys(system_path, adapter_mac, device_mac):
    """Extract all Bluetooth keys for a device from Windows registry."""
    base_path = rf'\ControlSet001\Services\BTHPORT\Parameters\Keys\{adapter_mac}\{device_mac}'

    # First get the directory listing to see what keys exist and get DWORD values
    ls_output = run_chntpw_command(system_path, [
        f'cd {base_path}',
        'ls'
    ])

    keys = {
        'mac': device_mac,
        'adapter_mac': adapter_mac,
    }

    # Check if this is a BLE device (has LTK) or classic (just LinkKey at adapter level)
    is_ble = 'LTK' in ls_output
    keys['is_ble'] = is_ble

    # Parse DWORD values from ls output
    key_length = parse_dword_value(ls_output, 'KeyLength')
    ediv = parse_dword_value(ls_output, 'EDIV')

    keys['KeyLength'] = key_length if key_length else '16'
    keys['EDIV'] = ediv if ediv else ''

    if is_ble:
        # Get hex values for BLE device
        hex_output = run_chntpw_command(system_path, [
            f'cd {base_path}',
            'hex LTK',
            'hex ERand',
            'hex IRK',
            'hex CSRK'
        ])

        keys['LTK'] = sanitize_hex_string(parse_hex_value(hex_output, 'LTK'))
        keys['ERand'] = hex_bytes_to_decimal(parse_hex_value(hex_output, 'ERand'))
        keys['IRK'] = sanitize_hex_string(parse_hex_value(hex_output, 'IRK'))
        keys['CSRK'] = sanitize_hex_string(parse_hex_value(hex_output, 'CSRK'))

        # Try to get CSRKInbound if it exists
        if 'CSRKInbound' in ls_output:
            csrk_in_output = run_chntpw_command(system_path, [
                f'cd {base_path}',
                'hex CSRKInbound'
            ])
            keys['CSRKInbound'] = sanitize_hex_string(parse_hex_value(csrk_in_output, 'CSRKInbound'))
    else:
        # Classic Bluetooth - LinkKey is stored at adapter level with device MAC as value name
        linkkey_output = run_chntpw_command(system_path, [
            rf'cd \ControlSet001\Services\BTHPORT\Parameters\Keys\{adapter_mac}',
            f'hex {device_mac}'
        ])
        keys['LinkKey'] = sanitize_hex_string(parse_hex_value(linkkey_output, device_mac))

    return keys


def get_linux_adapters():
    """Get list of Linux Bluetooth adapters."""
    bt_path = Path('/var/lib/bluetooth')
    if not bt_path.exists():
        return []
    try:
        return [d.name for d in bt_path.iterdir() if d.is_dir() and ':' in d.name]
    except PermissionError:
        return []


def get_linux_devices(adapter_mac):
    """Get list of paired devices for a Linux adapter."""
    adapter_path = Path(f'/var/lib/bluetooth/{adapter_mac}')
    if not adapter_path.exists():
        return []

    try:
        devices = []
        for d in adapter_path.iterdir():
            if d.is_dir() and ':' in d.name and d.name != 'cache':
                devices.append(d.name)
        return devices
    except PermissionError:
        return []


def read_linux_info_file(adapter_mac, device_mac):
    """Read and parse Linux Bluetooth info file."""
    info_path = Path(f'/var/lib/bluetooth/{adapter_mac}/{device_mac}/info')
    if not info_path.exists():
        return None

    config = configparser.ConfigParser(interpolation=None)
    config.read(info_path)
    return config


def read_linux_keys(device_filter=None):
    """Read Bluetooth pairing keys from Linux BlueZ config files.

    Returns list of key dicts in canonical format.
    """
    all_keys = []
    linux_adapters = get_linux_adapters()
    if not linux_adapters and os.path.exists('/var/lib/bluetooth') and os.geteuid() != 0:
        print("Error: Permission denied to access /var/lib/bluetooth. Please run with sudo.")
        sys.exit(1)
    for adapter_mac in linux_adapters:
        adapter_raw = mac_to_raw(adapter_mac)
        for device_mac in get_linux_devices(adapter_mac):
            if device_filter:
                requested = format_mac_address(mac_to_raw(device_filter))
                if device_mac != requested:
                    continue

            config = read_linux_info_file(adapter_mac, device_mac)
            if not config:
                continue

            device_raw = mac_to_raw(device_mac)
            keys = {
                'mac': device_raw,
                'adapter_mac': adapter_raw,
                'is_ble': False,
            }

            # Check for BLE keys
            if config.has_section('LongTermKey'):
                keys['is_ble'] = True
                keys['LTK'] = config.get('LongTermKey', 'Key', fallback='')
                keys['KeyLength'] = config.get('LongTermKey', 'EncSize', fallback='16')
                keys['EDIV'] = config.get('LongTermKey', 'EDiv', fallback='')
                keys['ERand'] = config.get('LongTermKey', 'Rand', fallback='')

            if config.has_section('IdentityResolvingKey'):
                keys['is_ble'] = True
                keys['IRK'] = config.get('IdentityResolvingKey', 'Key', fallback='')

            if config.has_section('LocalSignatureKey'):
                keys['CSRK'] = config.get('LocalSignatureKey', 'Key', fallback='')

            if config.has_section('RemoteSignatureKey'):
                keys['CSRKInbound'] = config.get('RemoteSignatureKey', 'Key', fallback='')

            # Check for Classic keys
            if config.has_section('LinkKey'):
                keys['LinkKey'] = config.get('LinkKey', 'Key', fallback='')

            # Get device name
            if config.has_section('General'):
                keys['device_name'] = config.get('General', 'Name', fallback='')

            all_keys.append(keys)
    return all_keys


def find_macos_plist(macos_path):
    """Locate the macOS Bluetooth plist file on a mounted partition or native system."""
    macos_path = Path(macos_path)
    candidates = [
        # Modern macOS (Big Sur+)
        macos_path / 'private' / 'var' / 'root' / 'Library' / 'Preferences' / 'com.apple.Bluetoothd.plist',
        # Older macOS
        macos_path / 'Library' / 'Preferences' / 'com.apple.Bluetooth.plist',
    ]
    # If running natively on macOS, also check system paths
    if platform.system() == 'Darwin':
        candidates.insert(0, Path('/private/var/root/Library/Preferences/com.apple.Bluetoothd.plist'))
        candidates.insert(1, Path('/Library/Preferences/com.apple.Bluetooth.plist'))

    for path in candidates:
        if path.exists():
            return path
    return None


def read_macos_plist(plist_path):
    """Read and parse a macOS Bluetooth plist file."""
    with open(plist_path, 'rb') as f:
        return plistlib.load(f)


def read_macos_keys(macos_path, device_filter=None):
    """Read Bluetooth pairing keys from macOS plist.

    Returns list of key dicts in canonical format.
    """
    plist_path = find_macos_plist(macos_path)
    if not plist_path:
        print(f"Error: No macOS Bluetooth plist found at {macos_path}")
        print("  Looked for com.apple.Bluetoothd.plist and com.apple.Bluetooth.plist")
        sys.exit(1)

    print(f"macOS Bluetooth plist: {plist_path}")
    try:
        plist_data = read_macos_plist(plist_path)
    except PermissionError:
        print(f"Error: Permission denied to read {plist_path}. Please run with sudo.")
        sys.exit(1)

    all_keys = []

    # Process BLE devices from LEKeys
    le_keys = plist_data.get('LEKeys', {})
    for mac_str, device_data in le_keys.items():
        device_raw = mac_to_raw(mac_str)
        if device_filter:
            requested = mac_to_raw(device_filter)
            if device_raw != requested:
                continue

        keys = {
            'mac': device_raw,
            'adapter_mac': '',  # macOS plist doesn't always expose adapter MAC
            'is_ble': True,
        }
        # macOS stores binary data in big-endian (same as Linux BlueZ)
        if isinstance(device_data.get('LTK'), bytes):
            keys['LTK'] = device_data['LTK'].hex().upper()
        if isinstance(device_data.get('IRK'), bytes):
            keys['IRK'] = device_data['IRK'].hex().upper()
        if isinstance(device_data.get('CSRK'), bytes):
            keys['CSRK'] = device_data['CSRK'].hex().upper()
        if 'EDIV' in device_data:
            keys['EDIV'] = str(device_data['EDIV'])
        if 'ERand' in device_data:
            keys['ERand'] = str(device_data['ERand'])
        if 'KeyLength' in device_data:
            keys['KeyLength'] = str(device_data['KeyLength'])
        else:
            keys['KeyLength'] = '16'

        all_keys.append(keys)

    # Process Classic devices from LinkKeys
    link_keys = plist_data.get('LinkKeys', {})
    for mac_str, device_data in link_keys.items():
        device_raw = mac_to_raw(mac_str)
        if device_filter:
            requested = mac_to_raw(device_filter)
            if device_raw != requested:
                continue

        keys = {
            'mac': device_raw,
            'adapter_mac': '',
            'is_ble': False,
        }
        if isinstance(device_data, dict) and isinstance(device_data.get('LinkKey'), bytes):
            keys['LinkKey'] = device_data['LinkKey'].hex().upper()
        elif isinstance(device_data, bytes):
            # Some macOS versions store LinkKey directly as bytes
            keys['LinkKey'] = device_data.hex().upper()

        all_keys.append(keys)

    print(f"Found {len(all_keys)} device(s) in macOS plist")
    return all_keys


def update_macos_plist(plist_path, device_keys_list, dry_run=False):
    """Write pairing keys to a macOS Bluetooth plist file."""
    plist_path = Path(plist_path)

    # Read existing plist
    try:
        with open(plist_path, 'rb') as f:
            plist_data = plistlib.load(f)
    except PermissionError:
        print(f"Error: Permission denied to read/write {plist_path}. Please run with sudo.")
        sys.exit(1)

    if not dry_run:
        # Backup existing file
        backup_path = plist_path.with_suffix('.plist.backup')
        shutil.copy(plist_path, backup_path)
        print(f"  Backed up plist to: {backup_path}")

    updated = 0
    for keys in device_keys_list:
        mac_macos = mac_to_macos(keys['mac'])

        if keys.get('is_ble'):
            if 'LEKeys' not in plist_data:
                plist_data['LEKeys'] = {}

            device_entry = plist_data['LEKeys'].get(mac_macos, {})
            if not isinstance(device_entry, dict):
                device_entry = {}

            if keys.get('LTK'):
                device_entry['LTK'] = bytes.fromhex(keys['LTK'])
            if keys.get('IRK'):
                device_entry['IRK'] = bytes.fromhex(keys['IRK'])
            if keys.get('CSRK'):
                device_entry['CSRK'] = bytes.fromhex(keys['CSRK'])
            if keys.get('EDIV'):
                device_entry['EDIV'] = int(keys['EDIV'])
            if keys.get('ERand'):
                device_entry['ERand'] = int(keys['ERand'])
            if keys.get('KeyLength'):
                device_entry['KeyLength'] = int(keys['KeyLength'])

            plist_data['LEKeys'][mac_macos] = device_entry
            updated += 1

            if dry_run:
                print(f"  [DRY RUN] Would update BLE device {mac_macos} in plist")
            else:
                print(f"  Updated BLE device {mac_macos} in plist")

        elif keys.get('LinkKey'):
            if 'LinkKeys' not in plist_data:
                plist_data['LinkKeys'] = {}

            plist_data['LinkKeys'][mac_macos] = bytes.fromhex(keys['LinkKey'])
            updated += 1

            if dry_run:
                print(f"  [DRY RUN] Would update Classic device {mac_macos} in plist")
            else:
                print(f"  Updated Classic device {mac_macos} in plist")

    # Add to PairedDevices list
    if not dry_run and updated > 0:
        paired = plist_data.get('PairedDevices', [])
        for keys in device_keys_list:
            mac_macos = mac_to_macos(keys['mac'])
            if mac_macos not in paired:
                paired.append(mac_macos)
        plist_data['PairedDevices'] = paired

        with open(plist_path, 'wb') as f:
            plistlib.dump(plist_data, f, fmt=plistlib.FMT_BINARY)
        print(f"  Wrote updated plist: {plist_path}")

    return updated


def write_macos_keys(macos_path, source_keys, dry_run=False):
    """Write pairing keys to macOS Bluetooth plist."""
    plist_path = find_macos_plist(macos_path)
    if not plist_path:
        print(f"Error: No macOS Bluetooth plist found at {macos_path}")
        print("  Looked for com.apple.Bluetoothd.plist and com.apple.Bluetooth.plist")
        sys.exit(1)

    print(f"\nWriting to macOS plist: {plist_path}")
    return update_macos_plist(plist_path, source_keys, dry_run)


def export_keys(source_keys, output_path):
    """Export pairing keys to a portable JSON file."""
    export_data = {
        'version': 1,
        'exported_from': platform.system().lower(),
        'exported_at': datetime.now().isoformat(),
        'devices': []
    }
    for keys in source_keys:
        device = {
            'mac': format_mac_address(keys['mac']),
            'adapter_mac': format_mac_address(keys['adapter_mac']),
            'is_ble': keys.get('is_ble', False),
        }
        for field in ('LTK', 'IRK', 'CSRK', 'CSRKInbound', 'LinkKey',
                      'ERand', 'EDIV', 'KeyLength', 'device_name'):
            if keys.get(field):
                device[field] = keys[field]
        export_data['devices'].append(device)

    with open(output_path, 'w') as f:
        json.dump(export_data, f, indent=2)
    print(f"Exported {len(source_keys)} device(s) to {output_path}")


def import_keys(input_path):
    """Import pairing keys from a portable JSON file.

    Returns list of key dicts in canonical format.
    """
    with open(input_path, 'r') as f:
        data = json.load(f)

    version = data.get('version', 0)
    if version != 1:
        print(f"Warning: Unknown export file version {version}, attempting to read anyway")

    devices = data.get('devices', [])
    all_keys = []
    for device in devices:
        keys = {
            'mac': mac_to_raw(device['mac']),
            'adapter_mac': mac_to_raw(device['adapter_mac']),
            'is_ble': device.get('is_ble', False),
        }
        for field in ('LTK', 'IRK', 'CSRK', 'CSRKInbound', 'LinkKey',
                      'ERand', 'EDIV', 'KeyLength', 'device_name'):
            if device.get(field):
                keys[field] = device[field]
        all_keys.append(keys)

    print(f"Imported {len(all_keys)} device(s) from {input_path}")
    if data.get('exported_from'):
        print(f"  Originally exported from: {data['exported_from']}")
    if data.get('exported_at'):
        print(f"  Exported at: {data['exported_at']}")
    return all_keys


def find_matching_linux_device(adapter_mac, windows_keys, linux_devices):
    """Find a matching Linux device by IRK or similar MAC address.

    Returns tuple: (linux_device_mac, source_device_mac_for_copying)
    - linux_device_mac: The device MAC to use in Linux (Windows MAC for BLE)
    - source_device_mac: If not None, copy config from this device first
    """
    windows_mac = format_mac_address(windows_keys['mac'])
    windows_irk = sanitize_hex_string(windows_keys.get('IRK', ''))
    is_ble = windows_keys.get('is_ble', False)

    # First try exact MAC match
    if windows_mac in linux_devices:
        return windows_mac, None

    # Try to find by IRK match (BLE devices)
    for linux_device in linux_devices:
        config = read_linux_info_file(adapter_mac, linux_device)
        if config and config.has_section('IdentityResolvingKey'):
            linux_irk = config.get('IdentityResolvingKey', 'Key', fallback='')
            if linux_irk and windows_irk and linux_irk.upper() == windows_irk.upper():
                # For BLE devices with IRK match but different MAC,
                # we need to use the Windows MAC (device advertises with that address)
                if is_ble and linux_device != windows_mac:
                    return windows_mac, linux_device
                return linux_device, None

    # Try to find by similar MAC (BLE random addresses may differ slightly)
    windows_mac_prefix = windows_mac[:11]  # First 4 octets
    for linux_device in linux_devices:
        if linux_device.startswith(windows_mac_prefix):
            if is_ble and linux_device != windows_mac:
                return windows_mac, linux_device
            return linux_device, None

    # Check for 1-byte difference (common with BLE random addresses)
    windows_mac_bytes = bytes.fromhex(windows_keys['mac'])
    for linux_device in linux_devices:
        linux_mac_bytes = bytes.fromhex(linux_device.replace(':', ''))
        diff_count = sum(1 for a, b in zip(windows_mac_bytes, linux_mac_bytes) if a != b)
        if diff_count <= 1:
            if is_ble and linux_device != windows_mac:
                return windows_mac, linux_device
            return linux_device, None

    return None, None


def copy_device_config(adapter_mac, source_device, target_device):
    """Copy device configuration from source to target device directory."""
    source_dir = Path(f'/var/lib/bluetooth/{adapter_mac}/{source_device}')
    target_dir = Path(f'/var/lib/bluetooth/{adapter_mac}/{target_device}')

    if not source_dir.exists():
        print(f"  Warning: Source device directory not found: {source_dir}")
        return False

    if target_dir.exists():
        print(f"  Target directory already exists: {target_dir}")
        return True

    # Copy the entire directory
    shutil.copytree(source_dir, target_dir)
    # Fix permissions
    os.chmod(target_dir, 0o700)
    for f in target_dir.iterdir():
        os.chmod(f, 0o600)

    print(f"  Copied device config from {source_device} to {target_device}")
    return True


def update_linux_info_file(adapter_mac, device_mac, windows_keys, device_name=None):
    """Update Linux Bluetooth info file with Windows keys."""
    info_path = Path(f'/var/lib/bluetooth/{adapter_mac}/{device_mac}/info')
    device_dir = info_path.parent

    # Create device directory if it doesn't exist
    if not device_dir.exists():
        device_dir.mkdir(parents=True, mode=0o700)
        print(f"  Created device directory: {device_dir}")

    # Read existing config or create new
    config = configparser.ConfigParser(interpolation=None)
    config.optionxform = str  # Preserve case

    if info_path.exists():
        # Backup existing file
        backup_path = info_path.with_suffix('.info.backup')
        shutil.copy(info_path, backup_path)
        print(f"  Backed up existing info file to: {backup_path}")
        config.read(info_path)
    else:
        # Create basic General section
        config['General'] = {
            'Name': device_name or 'Bluetooth Device',
            'Trusted': 'true',
            'Blocked': 'false'
        }

    if windows_keys.get('is_ble'):
        # Update BLE device keys

        # IdentityResolvingKey
        if windows_keys.get('IRK'):
            if not config.has_section('IdentityResolvingKey'):
                config.add_section('IdentityResolvingKey')
            config['IdentityResolvingKey']['Key'] = windows_keys['IRK']

        # LongTermKey
        if windows_keys.get('LTK'):
            if not config.has_section('LongTermKey'):
                config.add_section('LongTermKey')
            config['LongTermKey']['Key'] = windows_keys['LTK']
            config['LongTermKey']['EncSize'] = windows_keys.get('KeyLength', '16')
            config['LongTermKey']['Authenticated'] = '0'

            if windows_keys.get('EDIV'):
                config['LongTermKey']['EDiv'] = windows_keys['EDIV']

            if windows_keys.get('ERand'):
                config['LongTermKey']['Rand'] = windows_keys['ERand']

        # LocalSignatureKey (CSRK)
        if windows_keys.get('CSRK'):
            if not config.has_section('LocalSignatureKey'):
                config.add_section('LocalSignatureKey')
            config['LocalSignatureKey']['Key'] = windows_keys['CSRK']
            config['LocalSignatureKey']['Counter'] = '0'
            config['LocalSignatureKey']['Authenticated'] = 'false'

        # RemoteSignatureKey (CSRKInbound)
        if windows_keys.get('CSRKInbound'):
            if not config.has_section('RemoteSignatureKey'):
                config.add_section('RemoteSignatureKey')
            config['RemoteSignatureKey']['Key'] = windows_keys['CSRKInbound']
            config['RemoteSignatureKey']['Counter'] = '0'
            config['RemoteSignatureKey']['Authenticated'] = 'false'
    else:
        # Update Classic Bluetooth device keys
        if windows_keys.get('LinkKey'):
            if not config.has_section('LinkKey'):
                config.add_section('LinkKey')
            config['LinkKey']['Key'] = windows_keys['LinkKey']
            config['LinkKey']['Type'] = '4'
            config['LinkKey']['PINLength'] = '0'

    # Write updated config
    with open(info_path, 'w') as f:
        config.write(f, space_around_delimiters=False)

    # Fix file permissions
    os.chmod(info_path, 0o600)

    print(f"  Updated info file: {info_path}")
    return True


def restart_bluetooth_service():
    """Restart the Bluetooth service (Linux or macOS)."""
    print("\nRestarting Bluetooth service...")
    try:
        if IS_MACOS:
            subprocess.run(['launchctl', 'stop', 'com.apple.bluetoothd'], check=True)
            subprocess.run(['launchctl', 'start', 'com.apple.bluetoothd'], check=True)
        else:
            subprocess.run(['systemctl', 'restart', 'bluetooth'], check=True)
        print("Bluetooth service restarted successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error restarting Bluetooth service: {e}")
        return False


def read_windows_keys(windows_path, device_filter=None, verbose=False):
    """Read Bluetooth pairing keys from a mounted Windows partition.

    Returns list of key dicts in canonical format.
    """
    system_path = Path(windows_path) / 'Windows' / 'System32' / 'config' / 'SYSTEM'

    if not system_path.exists():
        print(f"Error: Windows SYSTEM registry not found at {system_path}")
        sys.exit(1)

    print(f"Windows registry: {system_path}")

    win_adapters = get_windows_bluetooth_adapters(str(system_path))
    if not win_adapters:
        print("No Bluetooth adapters found in Windows registry.")
        sys.exit(1)

    print(f"Found {len(win_adapters)} Windows Bluetooth adapter(s)")

    all_keys = []
    for win_adapter in win_adapters:
        win_devices = get_windows_bluetooth_devices(str(system_path), win_adapter)
        print(f"\nAdapter {format_mac_address(win_adapter)}: {len(win_devices)} paired device(s)")

        for win_device in win_devices:
            win_device_mac = format_mac_address(win_device)

            if device_filter:
                requested_mac = format_mac_address(mac_to_raw(device_filter))
                if win_device_mac != requested_mac:
                    continue

            print(f"  Device: {win_device_mac}")
            keys = get_device_keys(str(system_path), win_adapter, win_device)

            if verbose:
                print(f"    Type: {'BLE' if keys.get('is_ble') else 'Classic'}")
                if keys.get('LTK'):
                    print(f"    LTK: {keys['LTK']}")
                if keys.get('IRK'):
                    print(f"    IRK: {keys['IRK']}")

            all_keys.append(keys)

    return all_keys


def write_linux_keys(source_keys, dry_run=False, no_restart=False, verbose=False):
    """Write pairing keys to Linux BlueZ config.

    Handles device matching, config copying, and info file updates.
    Returns number of devices synced.
    """
    linux_adapters = get_linux_adapters()
    if not linux_adapters:
        if os.path.exists('/var/lib/bluetooth') and os.geteuid() != 0:
            print("Error: Permission denied to access /var/lib/bluetooth. Please run with sudo.")
        else:
            print("No Bluetooth adapters found in Linux.")
        sys.exit(1)

    print(f"\nFound {len(linux_adapters)} Linux Bluetooth adapter(s)")

    synced_devices = 0
    for keys in source_keys:
        source_mac = format_mac_address(keys['mac'])

        # Try to match adapter - use keys['adapter_mac'] if available
        linux_adapter = None
        if keys.get('adapter_mac'):
            candidate = format_mac_address(keys['adapter_mac'])
            if candidate in linux_adapters:
                linux_adapter = candidate

        # If no adapter match, use the first Linux adapter
        if not linux_adapter:
            linux_adapter = linux_adapters[0]

        print(f"\n  Processing device: {source_mac} (adapter: {linux_adapter})")

        if verbose:
            print(f"    Type: {'BLE' if keys.get('is_ble') else 'Classic'}")

        # Get Linux devices for matching
        linux_devices = get_linux_devices(linux_adapter)

        # Find matching Linux device
        linux_device, source_device = find_matching_linux_device(linux_adapter, keys, linux_devices)

        if linux_device:
            if source_device:
                print(f"    Found matching device: {source_device}")
                print(f"    BLE address changed - will create new entry: {linux_device}")
            else:
                print(f"    Matched Linux device: {linux_device}")

            # Get device name from source device or target device
            source_for_config = source_device if source_device else linux_device
            config = read_linux_info_file(linux_adapter, source_for_config)
            device_name = keys.get('device_name')
            if not device_name and config and config.has_section('General'):
                device_name = config.get('General', 'Name', fallback=None)

            if dry_run:
                print(f"    [DRY RUN] Would update: /var/lib/bluetooth/{linux_adapter}/{linux_device}/info")
                if source_device:
                    print(f"    [DRY RUN] Would copy config from: {source_device}")
            else:
                if source_device:
                    copy_device_config(linux_adapter, source_device, linux_device)

                if update_linux_info_file(linux_adapter, linux_device, keys, device_name):
                    synced_devices += 1
        else:
            print(f"    No matching Linux device found")
            print(f"    You may need to pair this device in Linux first, then run this script again")

    if synced_devices > 0:
        print(f"\nSynced {synced_devices} device(s)")
        if not no_restart and not dry_run:
            restart_bluetooth_service()
    else:
        if dry_run:
            print("\n[DRY RUN] No changes made")
        else:
            print("\nNo devices were synced")

    return synced_devices


def main():
    current_os = 'macOS' if IS_MACOS else 'Linux'
    parser = argparse.ArgumentParser(
        description='Sync Bluetooth pairing keys between Windows, Linux, and macOS.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
The script auto-detects the current OS ({current_os}) and uses it as the
default source and destination. You only need to specify a source when
importing from a file or a mounted partition from another OS.

Examples:
    # Import keys from a file (auto-writes to {current_os}):
    sudo python3 bluetooth-dualboot.py --import-file keys.json

    # Export current OS keys to a file (for transfer to another machine):
    sudo python3 bluetooth-dualboot.py --export-file keys.json

    # Windows to current OS (Linux):
    sudo python3 bluetooth-dualboot.py --from-windows /mnt/windows

    # macOS mounted partition to Linux:
    sudo python3 bluetooth-dualboot.py --from-macos /mnt/macos --to-linux

    # Linux to macOS (mounted partition):
    sudo python3 bluetooth-dualboot.py --from-linux --to-macos /mnt/macos
        """
    )

    # Source options (optional - defaults to current OS)
    source_group = parser.add_mutually_exclusive_group()
    source_group.add_argument('--from-windows', '--windows-path', '-w',
                              metavar='PATH',
                              help='Read keys from mounted Windows partition')
    source_group.add_argument('--from-macos', metavar='PATH', nargs='?', const='/',
                              help='Read keys from macOS (path to mounted partition, or omit for native)')
    source_group.add_argument('--from-linux', action='store_true',
                              help='Read keys from local Linux BlueZ config')
    source_group.add_argument('--import-file', '-i', metavar='PATH',
                              help='Read keys from exported JSON file')

    # Destination options (optional - defaults to current OS)
    dest_group = parser.add_mutually_exclusive_group()
    dest_group.add_argument('--to-linux', action='store_true',
                            help='Write keys to local Linux BlueZ config')
    dest_group.add_argument('--to-macos', metavar='PATH', nargs='?', const='/',
                            help='Write keys to macOS plist (path to mounted partition, or omit for native)')
    dest_group.add_argument('--export-file', '-e', metavar='PATH',
                            help='Write keys to portable JSON file')

    # Common options
    parser.add_argument('--dry-run', '-n', action='store_true',
                        help='Show what would be done without making changes')
    parser.add_argument('--device', '-d',
                        help='Only sync specific device MAC address')
    parser.add_argument('--no-restart', action='store_true',
                        help='Do not restart Bluetooth service after sync')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Show verbose output')

    args = parser.parse_args()

    # --- Resolve source: default to current OS ---
    has_source = args.from_windows or args.from_macos or args.from_linux or args.import_file
    if not has_source:
        if IS_MACOS:
            args.from_macos = '/'
        else:
            args.from_linux = True
        print(f"Auto-detected source: {current_os}")

    # --- Resolve destination: default to current OS ---
    has_dest = args.to_linux or args.to_macos or args.export_file
    if not has_dest:
        if IS_MACOS:
            args.to_macos = '/'
        else:
            args.to_linux = True

    # Determine if we need root
    needs_root = not args.dry_run and not args.export_file
    if needs_root:
        check_root()

    # --- Phase 1: Read keys from source ---
    source_keys = []

    if args.from_windows:
        source_keys = read_windows_keys(args.from_windows, args.device, args.verbose)
    elif args.from_macos:
        source_keys = read_macos_keys(args.from_macos, args.device)
    elif args.from_linux:
        source_keys = read_linux_keys(args.device)
    elif args.import_file:
        source_keys = import_keys(args.import_file)
        if args.device:
            requested = mac_to_raw(args.device)
            source_keys = [k for k in source_keys if k['mac'] == requested]

    if not source_keys:
        print("\nNo devices found in source.")
        sys.exit(1)

    print(f"\nFound {len(source_keys)} device(s) from source")

    if args.verbose:
        for keys in source_keys:
            print(f"  {format_mac_address(keys['mac'])} ({'BLE' if keys.get('is_ble') else 'Classic'})")

    # --- Phase 2: Write keys to destination ---
    if args.export_file:
        export_keys(source_keys, args.export_file)
    elif args.to_macos:
        write_macos_keys(args.to_macos, source_keys, args.dry_run)
    elif args.to_linux:
        write_linux_keys(source_keys, args.dry_run, args.no_restart, args.verbose)

    print("\nDone!")


if __name__ == "__main__":
    main()
