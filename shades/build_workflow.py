#!/usr/bin/env python3
import os
import sys
import shutil
import zipfile
import subprocess

INFO_PLIST_CONTENT = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>bundleid</key>
	<string>com.jeff.shades.picker</string>
	<key>connections</key>
	<dict>
		<key>E5C3C3B1-94E5-46D9-B6C2-68D72DA7E68F</key>
		<array>
			<dict>
				<key>destinationuid</key>
				<string>33BAEE20-562F-43CF-BCBF-3C7EA092CE40</string>
				<key>modifiers</key>
				<integer>0</integer>
				<key>modifiersubtext</key>
				<string></string>
				<key>vitoclose</key>
				<false/>
			</dict>
		</array>
	</dict>
	<key>createdby</key>
	<string>Antigravity</string>
	<key>description</key>
	<string>Change shades color themes using Alfred</string>
	<key>disabled</key>
	<false/>
	<key>name</key>
	<string>Shades Theme Picker</string>
	<key>objects</key>
	<array>
		<dict>
			<key>config</key>
			<dict>
				<key>alfredfiltersresults</key>
				<true/>
				<key>alfredfiltersresultsmatchmode</key>
				<integer>0</integer>
				<key>argumenttreatemptyqueryasnil</key>
				<true/>
				<key>argumenttrimmode</key>
				<integer>0</integer>
				<key>argumenttype</key>
				<integer>1</integer>
				<key>escaping</key>
				<integer>102</integer>
				<key>keyword</key>
				<string>theme</string>
				<key>queuedelaycustom</key>
				<integer>3</integer>
				<key>queuedelayimmediatelyinitially</key>
				<true/>
				<key>queuedelaymode</key>
				<integer>0</integer>
				<key>queuemode</key>
				<integer>1</integer>
				<key>runningsubtext</key>
				<string>Loading themes...</string>
				<key>script</key>
				<string>python3 list_shades_themes.py</string>
				<key>scriptargtype</key>
				<integer>1</integer>
				<key>scriptfile</key>
				<string></string>
				<key>subtext</key>
				<string>Change shades color themes</string>
				<key>title</key>
				<string>Shades Theme Picker</string>
				<key>type</key>
				<integer>0</integer>
				<key>withspace</key>
				<true/>
			</dict>
			<key>type</key>
			<string>alfred.workflow.input.scriptfilter</string>
			<key>uid</key>
			<string>E5C3C3B1-94E5-46D9-B6C2-68D72DA7E68F</string>
			<key>version</key>
			<integer>3</integer>
		</dict>
		<dict>
			<key>config</key>
			<dict>
				<key>concurrently</key>
				<false/>
				<key>escaping</key>
				<integer>102</integer>
				<key>script</key>
				<string># Ensure path includes standard locations
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/go/bin:$PATH"
shades set "$1"
echo -n "$1"</string>
				<key>scriptargtype</key>
				<integer>1</integer>
				<key>scriptfile</key>
				<string></string>
				<key>type</key>
				<integer>0</integer>
			</dict>
			<key>type</key>
			<string>alfred.workflow.action.script</string>
			<key>uid</key>
			<string>33BAEE20-562F-43CF-BCBF-3C7EA092CE40</string>
			<key>version</key>
			<integer>2</integer>
		</dict>
	</array>
	<key>readme</key>
	<string>Fuzzy search and set your Shades themes using Alfred. Use Shift (or Cmd+Y) to preview the color palette and mockup editor.</string>
	<key>uidata</key>
	<dict>
		<key>E5C3C3B1-94E5-46D9-B6C2-68D72DA7E68F</key>
		<dict>
			<key>xpos</key>
			<real>80</real>
			<key>ypos</key>
			<real>85</real>
		</dict>
		<key>33BAEE20-562F-43CF-BCBF-3C7EA092CE40</key>
		<dict>
			<key>xpos</key>
			<real>290</real>
			<key>ypos</key>
			<real>85</real>
		</dict>
	</dict>
	<key>userconfigurationconfig</key>
	<array/>
	<key>variablesdontexport</key>
	<array/>
	<key>version</key>
	<string>1.2.0</string>
	<key>webaddress</key>
	<string></string>
</dict>
</plist>
"""

LIST_THEMES_SCRIPT = '''#!/usr/bin/env python3
import json
import subprocess
import sys
import os

def format_name(name):
    words = name.replace('-', ' ').replace('_', ' ').split()
    return ' '.join(word.capitalize() for word in words)

def parse_yaml(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    themes = {}
    current_theme = None
    current_variant = None
    in_themes = False
    in_variants = False
    in_colors = False
    
    for line in lines:
        indent = len(line) - len(line.lstrip())
        line_stripped = line.strip()
        if not line_stripped or line_stripped.startswith('#'):
            continue
            
        parts = line_stripped.split(':', 1)
        key = parts[0].strip()
        val = parts[1].strip() if len(parts) > 1 else ""
        
        if val.startswith('"') and val.endswith('"'):
            val = val[1:-1]
        elif val.startswith("'") and val.endswith("'"):
            val = val[1:-1]
            
        if indent == 0:
            in_themes = (key == "themes")
            continue
            
        if in_themes:
            if indent == 2:
                current_theme = key
                themes[current_theme] = {"variants": {}}
                in_variants = False
                in_colors = False
            elif indent == 4:
                if key == "variants":
                    in_variants = True
                else:
                    pass
            elif indent == 6 and in_variants:
                current_variant = key
                themes[current_theme]["variants"][current_variant] = {"colors": {}, "light": False}
                in_colors = False
            elif indent == 8 and in_variants:
                if key == "light":
                    themes[current_theme]["variants"][current_variant]["light"] = (val.lower() == "true")
                elif key == "colors":
                    in_colors = True
            elif indent == 10 and in_variants and in_colors:
                themes[current_theme]["variants"][current_variant]["colors"][key] = val
                
    return themes

def generate_preview_html(theme_name, variant_name, variant_data):
    colors = variant_data.get("colors", {})
    bg_dim = colors.get("BGDIM", "#1e1e2e")
    bg0 = colors.get("BG0", "#1e1e2e")
    bg1 = colors.get("BG1", "#181825")
    bg2 = colors.get("BG2", "#313244")
    fg = colors.get("FG", "#cdd6f4")
    red = colors.get("RED", "#f38ba8")
    orange = colors.get("ORANGE", "#fab387")
    yellow = colors.get("YELLOW", "#f9e2af")
    green = colors.get("GREEN", "#a6e3a1")
    blue = colors.get("BLUE", "#89b4fa")
    aqua = colors.get("AQUA", "#94e2d5")
    purple = colors.get("PURPLE", "#cba6f7")
    
    pretty_theme = theme_name.replace('-', ' ').replace('_', ' ').title()
    pretty_variant = variant_name.replace('-', ' ').replace('_', ' ').title()

    html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500&family=Inter:wght@400;500;600;700&display=swap');
        
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}
        
        body {{
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: {bg_dim};
            color: {fg};
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            min-height: 100vh;
        }}
        
        .header {{
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid {bg2};
            padding-bottom: 16px;
        }}
        
        .title-group h1 {{
            font-size: 24px;
            font-weight: 700;
            letter-spacing: -0.5px;
            color: {fg};
        }}
        
        .title-group p {{
            font-size: 14px;
            color: {fg}88;
            margin-top: 4px;
        }}
        
        .badge {{
            background-color: {bg2};
            color: {fg};
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }}
        
        .layout {{
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            gap: 20px;
            flex: 1;
        }}
        
        .section-title {{
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: {fg}66;
            margin-bottom: 12px;
        }}
        
        .palette-card {{
            background-color: {bg0};
            border: 1px solid {bg2};
            border-radius: 12px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }}
        
        .swatch-grid {{
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }}
        
        .swatch {{
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px;
            background-color: {bg1};
            border: 1px solid {bg2}44;
            border-radius: 8px;
        }}
        
        .color-box {{
            width: 36px;
            height: 36px;
            border-radius: 6px;
            border: 1px solid {fg}11;
        }}
        
        .color-info {{
            display: flex;
            flex-direction: column;
        }}
        
        .color-name {{
            font-size: 12px;
            font-weight: 600;
            color: {fg};
        }}
        
        .color-hex {{
            font-family: 'Fira Code', monospace;
            font-size: 10px;
            color: {fg}99;
            margin-top: 2px;
        }}
        
        .preview-card {{
            background-color: {bg0};
            border: 1px solid {bg2};
            border-radius: 12px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }}
        
        .window {{
            background-color: {bg1};
            border: 1px solid {bg2};
            border-radius: 10px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            flex: 1;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }}
        
        .window-titlebar {{
            background-color: {bg0};
            height: 36px;
            display: flex;
            align-items: center;
            padding: 0 12px;
            border-bottom: 1px solid {bg2};
            position: relative;
        }}
        
        .window-buttons {{
            display: flex;
            gap: 8px;
        }}
        
        .win-btn {{
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }}
        .win-close {{ background-color: #ff5f56; }}
        .win-minimize {{ background-color: #ffbd2e; }}
        .win-zoom {{ background-color: #27c93f; }}
        
        .window-title {{
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            font-size: 11px;
            font-weight: 500;
            color: {fg}88;
            font-family: 'Fira Code', monospace;
        }}
        
        .window-content {{
            padding: 16px;
            font-family: 'Fira Code', 'Fira Mono', monospace;
            font-size: 13px;
            line-height: 1.6;
            color: {fg};
            overflow: auto;
            flex: 1;
        }}
        
        .code-keyword {{ color: {purple}; font-weight: 500; }}
        .code-func {{ color: {blue}; }}
        .code-string {{ color: {green}; }}
        .code-comment {{ color: {fg}55; font-style: italic; }}
        .code-num {{ color: {orange}; }}
        .code-type {{ color: {yellow}; }}
        .code-bracket {{ color: {aqua}; }}
        
    </style>
</head>
<body>
    <div class="header">
        <div class="title-group">
            <h1>{pretty_theme}</h1>
            <p>Shades Color Theme Variant</p>
        </div>
        <span class="badge">{pretty_variant}</span>
    </div>
    
    <div class="layout">
        <div class="palette-card">
            <div class="section-title">Color Palette</div>
            <div class="swatch-grid">
                <div class="swatch">
                    <div class="color-box" style="background-color: {bg0};"></div>
                    <div class="color-info">
                        <span class="color-name">BG0 (Base)</span>
                        <span class="color-hex">{bg0}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {fg};"></div>
                    <div class="color-info">
                        <span class="color-name">FG (Text)</span>
                        <span class="color-hex">{fg}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {red};"></div>
                    <div class="color-info">
                        <span class="color-name">Red</span>
                        <span class="color-hex">{red}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {orange};"></div>
                    <div class="color-info">
                        <span class="color-name">Orange</span>
                        <span class="color-hex">{orange}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {yellow};"></div>
                    <div class="color-info">
                        <span class="color-name">Yellow</span>
                        <span class="color-hex">{yellow}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {green};"></div>
                    <div class="color-info">
                        <span class="color-name">Green</span>
                        <span class="color-hex">{green}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {blue};"></div>
                    <div class="color-info">
                        <span class="color-name">Blue</span>
                        <span class="color-hex">{blue}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {aqua};"></div>
                    <div class="color-info">
                        <span class="color-name">Aqua</span>
                        <span class="color-hex">{aqua}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {purple};"></div>
                    <div class="color-info">
                        <span class="color-name">Purple</span>
                        <span class="color-hex">{purple}</span>
                    </div>
                </div>
                <div class="swatch">
                    <div class="color-box" style="background-color: {bg_dim};"></div>
                    <div class="color-info">
                        <span class="color-name">BG Dim</span>
                        <span class="color-hex">{bg_dim}</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="preview-card">
            <div class="section-title">Editor Preview</div>
            <div class="window">
                <div class="window-titlebar">
                    <div class="window-buttons">
                        <div class="win-btn win-close"></div>
                        <div class="win-btn win-minimize"></div>
                        <div class="win-btn win-zoom"></div>
                    </div>
                    <div class="window-title">main.go</div>
                </div>
                <div class="window-content">
                    <span class="code-keyword">package</span> main<br><br>
                    <span class="code-keyword">import</span> <span class="code-bracket">(</span><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;<span class="code-string">"fmt"</span><br>
                    <span class="code-bracket">)</span><br><br>
                    <span class="code-comment">// Active theme: {pretty_theme}</span><br>
                    <span class="code-keyword">func</span> <span class="code-func">main</span><span class="code-bracket">()</span> <span class="code-bracket">{{</span><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;theme <span class="code-keyword">:=</span> <span class="code-string">"{theme_name};{variant_name}"</span><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;fmt.<span class="code-func">Printf</span><span class="code-bracket">(</span><span class="code-string">"Setting theme to %s\\\\n"</span>, theme<span class="code-bracket">)</span><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;<span class="code-comment">// Applied successfully!</span><br>
                    <span class="code-bracket">}}</span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
"""
    return html

def main():
    home = os.path.expanduser('~')
    os.environ['PATH'] = f"/opt/homebrew/bin:/usr/local/bin:{home}/go/bin:" + os.environ.get('PATH', '')

    config_path = os.path.join(home, ".config", "shades", "shades.yaml")
    if not os.path.exists(config_path):
        config_path = os.path.join(home, "dev", "dotfiles", "shades", ".config", "shades", "shades.yaml")
        
    themes_data = {}
    if os.path.exists(config_path):
        try:
            themes_data = parse_yaml(config_path)
        except Exception as e:
            pass

    try:
        result = subprocess.run(['shades', '-l'], capture_output=True, text=True, check=True)
        lines = result.stdout.strip().split('\\n')
    except Exception as e:
        error_item = {
            "title": "Error listing shades themes",
            "subtitle": f"Verify shades is installed and in PATH. Details: {e}",
            "valid": False
        }
        print(json.dumps({"items": [error_item]}))
        sys.exit(0)

    preview_dir = "/tmp/shades-previews"
    os.makedirs(preview_dir, exist_ok=True)
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    generator_path = os.path.join(script_dir, "shades-icon-generator")

    # Check if any icons are missing. If so, generate all of them once.
    missing_icons = False
    for line in lines:
        line = line.strip()
        if not line or ';' not in line:
            continue
        theme_name, variant = line.split(';', 1)
        icon_path = os.path.join(preview_dir, f"icon-{theme_name}-{variant}.png")
        if not os.path.exists(icon_path):
            missing_icons = True
            break
            
    if missing_icons and os.path.exists(generator_path) and os.path.exists(config_path):
        try:
            subprocess.run([generator_path, config_path, preview_dir], capture_output=True)
        except Exception:
            pass

    items = []
    for line in lines:
        line = line.strip()
        if not line or ';' not in line:
            continue
        
        theme_id = line
        theme_name, variant = line.split(';', 1)
        
        pretty_theme = format_name(theme_name)
        pretty_variant = format_name(variant)
        
        title = f"{pretty_theme} ({pretty_variant})"
        subtitle = f"Press Shift/Cmd+Y to Preview • Enter to Apply {theme_id}"
        
        match_str = f"{theme_name} {pretty_theme} {variant} {pretty_variant}"
        preview_path = os.path.join(preview_dir, f"{theme_name}-{variant}.html")
        icon_path = os.path.join(preview_dir, f"icon-{theme_name}-{variant}.png")
        
        variant_data = themes_data.get(theme_name, {}).get("variants", {}).get(variant, {})
        if variant_data:
            try:
                # Always write HTML to keep it up to date
                html_content = generate_preview_html(theme_name, variant, variant_data)
                with open(preview_path, "w") as f:
                    f.write(html_content)
            except Exception as e:
                pass
        
        item = {
            "uid": theme_id,
            "title": title,
            "subtitle": subtitle,
            "arg": theme_id,
            "autocomplete": title,
            "match": match_str,
            "quicklookurl": preview_path,
            "valid": True
        }
        
        if os.path.exists(icon_path):
            item["icon"] = {
                "path": icon_path
            }
            
        items.append(item)
    
    items.sort(key=lambda x: x['title'])
    print(json.dumps({"items": items}, indent=2))

if __name__ == '__main__':
    main()
'''

def main():
    build_dir = "/tmp/shades-workflow-build"
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir)

    print("Generating files...")
    # Write info.plist
    with open(os.path.join(build_dir, "info.plist"), "w") as f:
        f.write(INFO_PLIST_CONTENT.strip())

    # Write list_shades_themes.py
    script_path = os.path.join(build_dir, "list_shades_themes.py")
    with open(script_path, "w") as f:
        f.write(LIST_THEMES_SCRIPT.strip())
    os.chmod(script_path, 0o755)

    # Compile the Go icon generator and copy binary
    shades_dir = os.path.dirname(os.path.abspath(__file__))
    go_src = os.path.join(shades_dir, "generate_icons.go")
    generator_bin = os.path.join(build_dir, "shades-icon-generator")
    
    if os.path.exists(go_src):
        print("Compiling shades-icon-generator from Go src...")
        try:
            subprocess.run(["go", "build", "-o", generator_bin, go_src], check=True)
            print("Successfully compiled shades-icon-generator")
        except Exception as e:
            print(f"Warning: Failed to compile shades-icon-generator: {e}.")
    else:
        print("generate_icons.go source not found. Skipping compilation.")

    # Convert macOS system icon using sips
    icon_source = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ProfileFontAndColor.icns"
    icon_dest = os.path.join(build_dir, "icon.png")
    
    if os.path.exists(icon_source):
        print("Extracting system icon...")
        try:
            subprocess.run([
                "sips", "-s", "format", "png", 
                "--resampleHeight", "256", 
                icon_source, "--out", icon_dest
            ], capture_output=True, check=True)
            print("Successfully extracted icon.png")
        except Exception as e:
            print(f"Warning: Failed to extract system icon: {e}. Workflow will use Alfred default icon.")
    else:
        print("System icon source not found. Skipping icon extraction.")

    # Zip everything up into shades.alfredworkflow
    output_filename = os.path.join(shades_dir, "shades.alfredworkflow")
    print(f"Creating zip archive {output_filename}...")
    
    with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(build_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, build_dir)
                zipf.write(file_path, arcname)

    # Clean up build directory
    shutil.rmtree(build_dir)
    
    abs_output = os.path.abspath(output_filename)
    print(f"Done! Workflow generated at: {abs_output}")
    print("Double-click this file in Finder to import it into Alfred.")

if __name__ == "__main__":
    main()
