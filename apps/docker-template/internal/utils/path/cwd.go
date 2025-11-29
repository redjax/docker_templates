package path

import (
	"fmt"
	"os"
)

func GetCwd() string {
	pwd, err := os.Getwd()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return pwd
}
