package codeforces

import (
	"os"
	"sort"
	"time"

	"github.com/cloudfstrife/go-codeforces/client"
	"github.com/cloudfstrife/go-codeforces/contest"
	"github.com/cloudfstrife/log"
	"go.uber.org/zap"
)

func GetContentAfterToday(gyn bool) ([]contest.Contest, error) {
	cli := client.NewClient(&client.Config{
		Lang: "en",
	})

	var err error
	var contestList []contest.Contest

	contestList, err = contest.List(cli, gyn)
	if err != nil {
		log.Error("fetch codeforces contest list failed %v", zap.Error(err))
		os.Exit(1)
	}

	now := time.Now()
	beginTime := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Now().Location())
	beginUnix := beginTime.Unix()

	sort.Slice(contestList, func(i, j int) bool {
		return contestList[i].StartTimeSeconds < contestList[j].StartTimeSeconds
	})

	var result = make([]contest.Contest, 0, 10)

	for _, v := range contestList {
		if v.StartTimeSeconds > beginUnix {
			result = append(result, v)
		}
	}
	return result, nil
}
