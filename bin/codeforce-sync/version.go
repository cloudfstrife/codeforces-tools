package main

import (
	"fmt"
	"io"
)

var (
	// Version version
	Version string
	// CommitHash git commit hash
	CommitHash string
	// BuildTime built at
	BuildTime string
)

// ShowVersion output version
func ShowVersion(w io.Writer) {
	fmt.Fprintf(w,
		`Version
--------------------------------------------------------------
Version:        %s
Commit Hash:    %s
Build Time:     %s
--------------------------------------------------------------
`,
		Version, CommitHash, BuildTime,
	)
}
