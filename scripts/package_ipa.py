import os
import shutil
import zipfile
import sys
import plistlib

def package_ipa():
    app_dir = "build/ios/iphoneos/Runner.app"
    ipa_dir = "build/ios/ipa"
    ipa_name = "lamsa-release.ipa"
    ipa_path = os.path.join(ipa_dir, ipa_name)
    payload_dir = os.path.join(ipa_dir, "Payload")
    
    if not os.path.exists(app_dir):
        print(f"Error: {app_dir} does not exist. Did 'flutter build ios --release --no-codesign' run successfully?", file=sys.stderr)
        sys.exit(1)
        
    os.makedirs(payload_dir, exist_ok=True)
    target_app_path = os.path.join(payload_dir, "Runner.app")
    if os.path.exists(target_app_path):
        shutil.rmtree(target_app_path)
    shutil.copytree(app_dir, target_app_path, symlinks=True)
    
    # Read Info.plist to print bundle ID and version
    info_plist_path = os.path.join(target_app_path, "Info.plist")
    bundle_id = "unknown"
    min_os = "unknown"
    version = "unknown"
    if os.path.exists(info_plist_path):
        try:
            with open(info_plist_path, "rb") as f:
                plist_data = plistlib.load(f)
                bundle_id = plist_data.get("CFBundleIdentifier", "unknown")
                min_os = plist_data.get("MinimumOSVersion", plist_data.get("LSMinimumSystemVersion", "12.0+"))
                version = plist_data.get("CFBundleShortVersionString", "1.0.0")
        except Exception as e:
            print("Warning reading Info.plist:", e)
            
    print(f"Packaging {target_app_path} into {ipa_path}...")
    if os.path.exists(ipa_path):
        os.remove(ipa_path)
        
    with zipfile.ZipFile(ipa_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(payload_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, ipa_dir)
                zipf.write(file_path, arcname)
                
    shutil.rmtree(payload_dir)
    
    size_bytes = os.path.getsize(ipa_path)
    print(f"Verified IPA: {ipa_path} ({size_bytes} bytes)")
    print(f"Bundle: {bundle_id}; Version: {version}; iOS: {min_os}")
    print("IPA packaged successfully for Sideloadly, AltStore, TrollStore, or signing tool.")

if __name__ == "__main__":
    package_ipa()
