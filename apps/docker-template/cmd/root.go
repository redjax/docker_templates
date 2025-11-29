package cmd

import (
	"fmt"
	"os"

	"local/docker-templates/internal/config"

	"local/docker-templates/internal/version"

	"github.com/spf13/cobra"
)

var (
	cfgFile string
	debug   bool
)

var rootCmd = &cobra.Command{
	Use:     "docker-templates",
	Aliases: []string{"dt"},
	Short:   "CLI for my Docker templates repo.",
	Long:    `Tools for using & developing Docker Templates (https://github.com/redjax/docker_templates)`,
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		// Load config file BEFORE anything else
		cfg, err := config.LoadConfig(cmd.Root().PersistentFlags(), cfgFile)
		if err != nil {
			return fmt.Errorf("error loading config: %w", err)
		}

		if debug {
			cfg.LogLevel = "debug"
			fmt.Printf("Config loaded: %+v\n", cfg)
		}

		// fmt.Printf("Database: %v\n", cfg.DB)

		// database, err := db.OpenDB(cfg)
		// if err != nil {
		// 	return fmt.Errorf("failed opening DB: %w", err)
		// }

		// return db.DoMigrations(database)

		return err
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	// Persistent flags are global for your application
	rootCmd.PersistentFlags().StringVarP(&cfgFile, "config-file", "c", "", "config file (supports .yml, .json, .toml, .env)")
	rootCmd.PersistentFlags().BoolVarP(&debug, "debug", "d", false, "Enable debug logging")

	// Add version flag
	rootCmd.Flags().BoolP("version", "v", false, "Print version information")
	rootCmd.Run = func(cmd *cobra.Command, args []string) {
		versionFlag, _ := cmd.Flags().GetBool("version")
		if versionFlag {
			version.PrintVersion()
			return
		}

		// Default behavior when no subcommand is provided
		cmd.Help()
	}

	// Add subcommands
	rootCmd.AddCommand(version.NewSelfCommand())
}
