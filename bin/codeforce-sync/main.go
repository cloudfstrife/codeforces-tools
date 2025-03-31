package main

import (
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/cloudfstrife/codeforces-tools/pkg/codeforces"
	"github.com/cloudfstrife/log"
	"go.uber.org/zap"
)

func init() {
	ShowVersion(os.Stdout)
}

var flagGYN = flag.Bool("gyn", false, "fetch GYN")

func main() {
	flag.Parse()

	result, err := codeforces.GetContentAfterToday(*flagGYN)
	if err != nil {
		log.Error("fetch codeforce contest faailed", zap.Error(err))
	}
	fmt.Printf("%-19s\t%s\t%s\t%s\n", "开始时间", "类型", "难度", "名称")
	for i := 0; i < len(result); i++ {
		fmt.Printf("%s\t%s\t%d\t%s\n",
			time.Unix(result[i].StartTimeSeconds, 0).Format(time.DateTime),
			result[i].Type,
			result[i].Difficulty,
			result[i].Name,
		)
	}
}
