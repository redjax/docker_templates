package config

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	path "local/docker-templates/internal/utils/path"

	"github.com/knadh/koanf/parsers/json"
	"github.com/knadh/koanf/parsers/yaml"
	"github.com/knadh/koanf/providers/env"
	"github.com/knadh/koanf/providers/file"
	"github.com/knadh/koanf/providers/posflag"
	"github.com/knadh/koanf/v2"
	"github.com/spf13/pflag"
)

var K = koanf.New(".")
var Cfg *Config

var DefaultRepoRoot = path.GetCwd()

// type DBConfig struct {
// 	Driver   string `koanf:"driver"`
// 	Host     string `koanf:"host"`
// 	Port     int    `koanf:"port"`
// 	User     string `koanf:"user"`
// 	Password string `koanf:"password"`
// 	Database string `koanf:"database"`
// }

type Config struct {
	ConfigFile string `koanf:"config_file"`
	LogLevel   string `koanf:"log_level"`

	RepoPath string `koanf:"local_repo"`

	Github struct {
		PAT string `koanf:"pat"`
	} `koanf:"github"`

	// DB       DBConfig          `koanf:"db"`
	// Schedule map[string]string `koanf:"schedule"`
}

// Default values
func DefaultConfig(configFile string) *Config {
	if configFile == "" {
		configFile = "config.yml"
	}

	return &Config{
		ConfigFile: configFile,
		LogLevel:   "info",
		RepoPath:   DefaultRepoRoot,
		// DB: DBConfig{
		// 	Driver:   "sqlite",
		// 	Host:     "",
		// 	Port:     0,
		// 	User:     "",
		// 	Password: "",
		// 	Database: "data/gitstars.sqlite",
		// },
	}
}

func LoadConfig(flagSet *pflag.FlagSet, configFile string) (*Config, error) {
	// Always reset Koanf
	K = koanf.New(".")

	cfg := DefaultConfig(configFile)

	// Load config file
	if configFile != "" {
		if _, err := os.Stat(configFile); err == nil {
			parser, err := ParserForFile(configFile)
			if err != nil {
				return nil, fmt.Errorf("unsupported config file format: %w", err)
			}

			if err := K.Load(file.Provider(configFile), parser); err != nil {
				return nil, fmt.Errorf("error loading config file %s: %w", configFile, err)
			}

			// Load optional local override
			ext := filepath.Ext(configFile)
			base := strings.TrimSuffix(configFile, ext)
			localFile := base + ".local" + ext

			if _, err := os.Stat(localFile); err == nil {
				if err := K.Load(file.Provider(localFile), parser); err != nil {
					log.Printf("Warning loading %s: %v", localFile, err)
				}
			}
		}
	}

	// Load environment variables
	if err := K.Load(env.Provider("DOCKER_TEMPLATES_", ".", func(s string) string {
		key := strings.ToLower(strings.TrimPrefix(s, "DOCKER_TEMPLATES_"))
		key = strings.ReplaceAll(key, "__", ".")
		return key
	}), nil); err != nil {
		return nil, fmt.Errorf("error loading env vars: %w", err)
	}

	// Load CLI flags
	if flagSet != nil {
		if err := K.Load(posflag.ProviderWithValue(flagSet, ".", K,
			func(key string, value string) (string, interface{}) {
				return strings.ReplaceAll(key, "-", "_"), value
			}),
			nil); err != nil {
			return nil, fmt.Errorf("error loading flags: %w", err)
		}
	}

	// Unmarshal final config
	if err := K.Unmarshal("", cfg); err != nil {
		return nil, fmt.Errorf("error unmarshalling config: %w", err)
	}

	// Save globally so commands can access it
	Cfg = cfg

	return cfg, nil
}

// Detect parser to use for config file input
func ParserForFile(path string) (koanf.Parser, error) {
	ext := strings.ToLower(filepath.Ext(path))
	switch ext {
	case ".yml", ".yaml":
		return yaml.Parser(), nil
	case ".json":
		return json.Parser(), nil
	default:
		return nil, fmt.Errorf("unsupported extension: %s", ext)
	}
}

// Return the Config struct
func GetConfig() *Config {
	return Cfg
}
