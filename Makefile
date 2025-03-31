# main version
VERSION ?= $(shell git describe --tags --always --dirty)

# git commit Hash
COMMIT_HASH ?= $(shell git show -s --format=%H)

# build at
BUILD_TIME ?= $(shell date +"%F %T")

# go source file list
GOFILES := $(shell find . ! -path "./vendor/*" -name "*.go")

# build environment
BUILD_ENV := 

# unit test environment
TEST_ENV := 

# benchmark test environment
BENCHMARK_ENV := 

# operating system
GOOSES := linux windows darwin plan9

# compilation architecture
GOARCHES := 386 amd64

# build output folder
BUILD_FOLDER := target/debug

# release output folder
RELEASE_FOLDER := target/release

# folder name which include all target executable program source code 
COMMAND_ROOT := bin

# build options
BUILD_OPTS := -trimpath -ldflags "-s -w -X 'main.Version=${VERSION}' -X 'main.CommitHash=${COMMIT_HASH}' -X 'main.BuildTime=${BUILD_TIME}'"

# release options
RELEASE_OPTS := -trimpath -ldflags "-s -w -X 'main.Version=${VERSION}' -X 'main.CommitHash=${COMMIT_HASH}' -X 'main.BuildTime=${BUILD_TIME}'"

# unit test options
TEST_OPTS := -v

# benchmark test options
BENCHMARK_OPTS := -cpu 1,2,3,4,5,6,7,8

# target executable program name list
COMMAND_LIST := $(shell ls -l --full-time ${COMMAND_ROOT} | grep "^d" | awk '{print $$9}')

# sonar report output folder
REPORT_FOLDER := target/sonar

# sonar report file list
TEST_REPORT := ${REPORT_FOLDER}/test.report 
COVER_REPORT := ${REPORT_FOLDER}/cover.report
GOLANGCI_LINT_REPORT := ${REPORT_FOLDER}/golangci-lint.xml 
GOLINT_REPORT := ${REPORT_FOLDER}/golint.report 
GO_VET_REPORT := ${REPORT_FOLDER}/go_vet.report 

SONAR_SERVICE=http://xxx.xxx.xxx.xxx:9000
SONAR_TOKEN=

.PHONY: build format test benchmark release sonar clean

.DEFAULT_GOAL := build

# build target executable program
build: $(GOFILES)
	@for command in ${COMMAND_LIST} ; do 																					\
		${BUILD_ENV} go build ${BUILD_OPTS} -o ${BUILD_FOLDER}/$${command} ./${COMMAND_ROOT}/$${command} ;					\
	done

# format go code
format:
	@for f in ${GOFILES} ; do 																								\
		gofmt -w $${f};																										\
	done

# unit test
test: 
	${TEST_ENV} go test ${TEST_OPTS} ./...

# benchmark test
benchmark:
	${BENCHMARK_ENV} go test -bench . -run ^$$ ${BENCHMARK_OPTS}  ./...

# sonar
sonar: 
	mkdir -p ${REPORT_FOLDER}
	go test -json ./... > ${TEST_REPORT}
	go test -coverprofile=${COVER_REPORT} ./... 
	golangci-lint run --out-format checkstyle  ./... > ${GOLANGCI_LINT_REPORT}
	# golint ./... > ${GOLINT_REPORT}
	go vet ./... > ${GO_VET_REPORT} 2>&1
	# sonar-scanner -Dsonar.projectKey=${NAME} \
	-Dsonar.sources=. \
	-Dsonar.host.url=${SONAR_SERVICE} \
	-Dsonar.token=${SONAR_TOKEN} 
	-Dproject.settings=target/sonar-project.properties

# cross compiling
release:
	@for command in ${COMMAND_LIST} ; do 																					\
		for os in ${GOOSES} ; do																							\
			for arch in ${GOARCHES} ; do 																					\
				if [ "$${os}" = "windows" ] ;then																			\
					GOOS=$${os} GOARCH=$${arch}  																			\
					${BUILD_ENV} go build ${RELEASE_OPTS} 																	\
					-o ${RELEASE_FOLDER}/$${os}_$${arch}/$${command}.exe ./${COMMAND_ROOT}/$${command} ;					\
				else																										\
					GOOS=$${os} GOARCH=$${arch}  																			\
					${BUILD_ENV} go build ${RELEASE_OPTS}  																	\
					-o ${RELEASE_FOLDER}/$${os}_$${arch}/$${command} ./${COMMAND_ROOT}/$${command} ;						\
				fi																											\
			done																											\
		done																												\
	done

# clean target executable program and sonar report
clean:
	-rm -rf $(BUILD_FOLDER)/*
	-rm -rf $(RELEASE_FOLDER)/*
	-rm -f ${TEST_REPORT}
	-rm -f ${COVER_REPORT}
	-rm -f ${GOLANGCI_LINT_REPORT}
	-rm -f ${GOLINT_REPORT}
	-rm -f ${GO_VET_REPORT}
	-go clean 
	-go clean -cache
