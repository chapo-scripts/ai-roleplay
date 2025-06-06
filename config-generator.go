package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type Config struct {
	Main         string                 `json:"main"`
	Out          string                 `json:"out"`
	Modules      map[string]string      `json:"modules"`
	WatcherDelay float64                `json:"watcher_delay"`
	Constants    map[string]interface{} `json:"const"`
}

const OUTPUT_CONFIG = "bundle-config.json"

var cfg Config = Config{
	Main:    "src\\init.lua",
	Out:     "X:\\Arizona Games Launcher\\bin\\arizona\\moonloader\\ai-rp-bundled.lua", //"D:\\GRAND_PC_ADMIN_03_03_25\\GRAND_PC_ADMIN_03_03_25\\moonloader\\GrandTools-bundled.lua",
	Modules: map[string]string{},
	Constants: map[string]interface{}{
		"VERSION": "0.0.1-DEVELOPMENT",
	},
}

func main() {
	fmt.Println("Generating config...")
	err := filepath.Walk("./src", func(path string, info os.FileInfo, e error) error {
		if !info.IsDir() && e == nil && path != cfg.Main && strings.HasSuffix(path, ".lua") {
			// _, name := filepath.Split(path)
			fmt.Println(path)
			packageName := strings.ReplaceAll(strings.Replace(path, "src\\", "", 1), "\\", ".")
			cfg.Modules[strings.Replace(packageName, ".lua", "", 1)] = path
			fmt.Printf("Added module \"%s\"\n", packageName)
		}
		return nil
	})
	if err != nil {
		panic(err)
	}
	bytes, err := json.Marshal(cfg)
	if err != nil {
		panic(err)
	}

	if err := os.WriteFile(OUTPUT_CONFIG, bytes, 0644); err != nil {
		panic("Error saving file:" + err.Error())
	}
}
