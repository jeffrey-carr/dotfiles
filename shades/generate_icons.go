package main

import (
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// ThemeVariant represents parsed color tokens from shades.yaml
type ThemeVariant struct {
	BG0   string
	RED   string
	GREEN string
	BLUE  string
}

// Simple YAML indentation-based parser
func parseYAML(filePath string) map[string]map[string]ThemeVariant {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil
	}

	lines := strings.Split(string(data), "\n")
	themes := make(map[string]map[string]ThemeVariant)
	
	var currentTheme string
	var currentVariant string
	var inThemes bool
	var inVariants bool
	var inColors bool
	
	tempColors := make(map[string]string)

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		
		indent := len(line) - len(strings.TrimLeft(line, " \t"))
		parts := strings.SplitN(trimmed, ":", 2)
		key := strings.TrimSpace(parts[0])
		var val string
		if len(parts) > 1 {
			val = strings.TrimSpace(parts[1])
			val = strings.Trim(val, `"'`)
		}

		if indent == 0 {
			inThemes = (key == "themes")
			continue
		}

		if inThemes {
			if indent == 2 {
				// If we have colors from the previous variant, save them before moving on
				if currentTheme != "" && currentVariant != "" && len(tempColors) > 0 {
					themes[currentTheme][currentVariant] = ThemeVariant{
						BG0:   tempColors["BG0"],
						RED:   tempColors["RED"],
						GREEN: tempColors["GREEN"],
						BLUE:  tempColors["BLUE"],
					}
					tempColors = make(map[string]string)
				}
				currentTheme = key
				themes[currentTheme] = make(map[string]ThemeVariant)
				inVariants = false
				inColors = false
			} else if indent == 4 {
				if key == "variants" {
					inVariants = true
				}
			} else if indent == 6 && inVariants {
				if currentVariant != "" && len(tempColors) > 0 {
					themes[currentTheme][currentVariant] = ThemeVariant{
						BG0:   tempColors["BG0"],
						RED:   tempColors["RED"],
						GREEN: tempColors["GREEN"],
						BLUE:  tempColors["BLUE"],
					}
					tempColors = make(map[string]string)
				}
				currentVariant = key
				inColors = false
			} else if indent == 8 && inVariants {
				if key == "colors" {
					inColors = true
				}
			} else if indent == 10 && inVariants && inColors {
				tempColors[key] = val
			}
		}
	}
	
	// Save the final variant
	if currentTheme != "" && currentVariant != "" && len(tempColors) > 0 {
		themes[currentTheme][currentVariant] = ThemeVariant{
			BG0:   tempColors["BG0"],
			RED:   tempColors["RED"],
			GREEN: tempColors["GREEN"],
			BLUE:  tempColors["BLUE"],
		}
	}

	return themes
}

// Parse hex color string to color.RGBA
func hexToRGBA(hex string, defaultColor color.RGBA) color.RGBA {
	hex = strings.TrimPrefix(hex, "#")
	if len(hex) != 6 {
		return defaultColor
	}
	r, err1 := strconv.ParseUint(hex[0:2], 16, 8)
	g, err2 := strconv.ParseUint(hex[2:4], 16, 8)
	b, err3 := strconv.ParseUint(hex[4:6], 16, 8)
	if err1 != nil || err2 != nil || err3 != nil {
		return defaultColor
	}
	return color.RGBA{R: uint8(r), G: uint8(g), B: uint8(b), A: 255}
}

// Draw a circle on an image
func drawCircle(img draw.Image, x, y, radius int, c color.Color) {
	for dy := -radius; dy <= radius; dy++ {
		for dx := -radius; dx <= radius; dx++ {
			if dx*dx+dy*dy <= radius*radius {
				img.Set(x+dx, y+dy, c)
			}
		}
	}
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: generate_icons <shades_yaml_path> <output_dir>")
		os.Exit(1)
	}

	yamlPath := os.Args[1]
	outputDir := os.Args[2]

	themes := parseYAML(yamlPath)
	if themes == nil {
		fmt.Println("Error parsing YAML file")
		os.Exit(1)
	}

	err := os.MkdirAll(outputDir, 0755)
	if err != nil {
		fmt.Printf("Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	const width = 80
	const height = 80

	for themeName, variants := range themes {
		for variantName, theme := range variants {
			img := image.NewRGBA(image.Rect(0, 0, width, height))

			// Use custom colors or fall back to sensible defaults
			bgColor := hexToRGBA(theme.BG0, color.RGBA{24, 24, 37, 255})
			redColor := hexToRGBA(theme.RED, color.RGBA{243, 139, 168, 255})
			greenColor := hexToRGBA(theme.GREEN, color.RGBA{166, 227, 161, 255})
			blueColor := hexToRGBA(theme.BLUE, color.RGBA{137, 180, 250, 255})

			// Draw base rectangle
			draw.Draw(img, img.Bounds(), &image.Uniform{bgColor}, image.Point{}, draw.Src)

			// Round the corners
			cornerRadius := 16
			for y := 0; y < height; y++ {
				for x := 0; x < width; x++ {
					// Top left corner
					if x < cornerRadius && y < cornerRadius {
						dx, dy := cornerRadius-x, cornerRadius-y
						if dx*dx+dy*dy > cornerRadius*cornerRadius {
							img.Set(x, y, color.Transparent)
						}
					}
					// Top right corner
					if x >= width-cornerRadius && y < cornerRadius {
						dx, dy := x-(width-cornerRadius-1), cornerRadius-y
						if dx*dx+dy*dy > cornerRadius*cornerRadius {
							img.Set(x, y, color.Transparent)
						}
					}
					// Bottom left corner
					if x < cornerRadius && y >= height-cornerRadius {
						dx, dy := cornerRadius-x, y-(height-cornerRadius-1)
						if dx*dx+dy*dy > cornerRadius*cornerRadius {
							img.Set(x, y, color.Transparent)
						}
					}
					// Bottom right corner
					if x >= width-cornerRadius && y >= height-cornerRadius {
						dx, dy := x-(width-cornerRadius-1), y-(height-cornerRadius-1)
						if dx*dx+dy*dy > cornerRadius*cornerRadius {
							img.Set(x, y, color.Transparent)
						}
					}
				}
			}

			// Draw three colored circles side-by-side in the center
			dotRadius := 8
			spacing := 20
			centerY := height / 2
			centerX := width / 2

			drawCircle(img, centerX-spacing, centerY, dotRadius, redColor)
			drawCircle(img, centerX, centerY, dotRadius, greenColor)
			drawCircle(img, centerX+spacing, centerY, dotRadius, blueColor)

			filename := fmt.Sprintf("icon-%s-%s.png", themeName, variantName)
			filePath := filepath.Join(outputDir, filename)
			
			f, err := os.Create(filePath)
			if err != nil {
				fmt.Printf("Error creating file %s: %v\n", filePath, err)
				continue
			}
			
			err = png.Encode(f, img)
			f.Close()
			if err != nil {
				fmt.Printf("Error encoding PNG %s: %v\n", filePath, err)
			}
		}
	}
	fmt.Println("Icons generated successfully!")
}
