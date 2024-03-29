# Afero Cucumber Steps for Golang

[![GitHub Releases](https://img.shields.io/github/v/release/godogx/aferosteps)](https://github.com/godogx/aferosteps/releases/latest)
[![Build Status](https://github.com/godogx/aferosteps/actions/workflows/test.yaml/badge.svg)](https://github.com/godogx/aferosteps/actions/workflows/test.yaml)
[![codecov](https://codecov.io/gh/godogx/aferosteps/branch/master/graph/badge.svg?token=eTdAgDE2vR)](https://codecov.io/gh/godogx/aferosteps)
[![Go Report Card](https://goreportcard.com/badge/github.com/godogx/aferosteps)](https://goreportcard.com/report/github.com/godogx/aferosteps)
[![GoDevDoc](https://img.shields.io/badge/dev-doc-00ADD8?logo=go)](https://pkg.go.dev/github.com/godogx/aferosteps)

Interacting with multiple filesystems in [`cucumber/godog`](https://github.com/cucumber/godog) with [spf13/afero](https://github.com/spf13/afero)

## Prerequisites

- `Go >= 1.17`

## Install

```bash
go get github.com/godogx/aferosteps
```

## Usage

Initiate a new FS Manager with `aferosteps.NewManager` then add it to `ScenarioInitializer` by
calling `Manager.RegisterContext(*testing.T, *godog.ScenarioContext)`

The `Manager` supports multiple file systems and by default, it uses `afero.NewOsFs()`. If you wish to:

- Change the default fs, use `aferosteps.WithDefaultFs(fs afero.Fs)` in the constructor.
- Add more fs, use `aferosteps.WithFs(name string, fs afero.Fs)` in the constructor.

For example:

```go
package mypackage

import (
    "math/rand"
    "testing"

    "github.com/cucumber/godog"
    "github.com/godogx/aferosteps"
    "github.com/spf13/afero"
    "github.com/stretchr/testify/require"
)

func TestIntegration(t *testing.T) {
    fsManager := aferosteps.NewManager(
        aferosteps.WithFs("mem", afero.NewMemMapFs()),
    )

    suite := godog.TestSuite{
        Name: "Integration",
        ScenarioInitializer: func(ctx *godog.ScenarioContext) {
            fsManager.RegisterContext(t, ctx)
        },
        Options: &godog.Options{
            Strict:    true,
            Randomize: rand.Int63(),
        },
    }

    // Run the suite.
}
```

Note: the `Manager` will reset the working directory at the beginning of the scenario to the one when the test starts.

## Steps

### Change to a temporary directory

Change to a temporary directory provided by calling [`t.(*testing.T).TempDir()`](https://golang.org/pkg/testing/#B.TempDir)

Pattern: `(?:current|working) directory is temporary`

Example:

```gherkin
Feature: OS FS

    Background:
        Given current directory is temporary
        And there is a directory "test"
```

### Change working directory

Change to a directory of your choice.

Pattern:

- `(?:current|working) directory is "([^"]+)"`
- `changes? (?:current|working) directory to "([^"]+)"`

```gherkin
Feature: OS FS

    Scenario: .github equal
        When I reset current directory
        And I change current directory to "../../.github"

        Then there should be only these files:
        """
        - workflows:
            - lint.yaml
            - test.yaml
        """

    Scenario: .github equal with cwd
        When I reset current directory
        And current directory is "../../.github"

        Then there should be only these files:
        """
        - workflows:
            - lint.yaml
            - test.yaml
        """
```

### Reset working directory

Reset the working directory to the one when the test starts.

Pattern: `resets? (?:current|working) directory`

```gherkin
Feature: OS FS

    Scenario: .github equal
        When I reset current directory
        And I change current directory to "../../.github"

        Then there should be only these files:
        """
        - workflows:
            - lint.yaml
            - test.yaml
        """
```

### Remove a file

Remove a file from a fs.

Pattern:

- With the default fs: `^there is no (?:file|directory) "([^"]+)"$`
- With a fs at your choice: `^there is no (?:file|directory) "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system)$`

```gherkin
Feature: Mixed

    Background:
        Given there is no file "test/file1.txt"
        And there is no file "test/file1.txt" in "mem" fs
```

### Create a file

#### Empty file

Pattern:

- With the default fs: `^there is a file "([^"]+)"$`
- With a fs at your choice: `^there is a file "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system)$`

```gherkin
Feature: Mixed

    Background:
        Given there is a file "test/file1.txt"
        And there is a file "test/file1.txt" in "mem" fs
```

#### With Content

Pattern:

- With the default fs: `^there is a file "([^"]+)" with content:`
- With a fs at your choice: `^there is a file "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system) with content:`

```gherkin
Feature: Mixed

    Background:
        Given there is a file "test/file2.sh" with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """

        And there is a file "test/file2.sh" in "mem" fs with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """
```

### Create a directory

Pattern:

- With the default fs: `^there is a directory "([^"]+)"$`
- With a fs at your choice: `^there is a directory "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system)`

```gherkin
Feature: Mixed

    Background:
        Given there is a directory "test"
        And there is a directory "test" in "mem" fs
```

### Change file or directory permission

Pattern:

- With the default fs:
    - `changes? "([^"]+)" permission to ([0-9]+)$`
    - `^(?:file|directory) "([^"]+)" permission is ([0-9]+)$`
- With a fs at your choice:
    - `changes? "([^"]+)" permission in "([^"]+)" (?:fs|filesystem|file system) to ([0-9]+)`
    - `^(?:file|directory) "([^"]+)" permission in "([^"]+)" (?:fs|filesystem|file system) is ([0-9]+)`

```gherkin
Feature: Mixed

    Background:
        Given file "test/file1.txt" permission is 0644
        And file "test/file1.txt" permission in "mem" fs is 0644
        And I change "test/file2.sh" permission to 0755
        And I change "test/file2.sh" permission in "mem" fs to 0755
```

### Assert file exists

Pattern:

- With the default fs: `^there should be a file "([^"]+)"$`
- With a fs at your choice: `^there should be a file "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system)`

```gherkin
Feature: Mixed

    Background:
        Given there should be a file "test/file1.txt"
        And there should be a file "test/file1.txt" in "mem" fs
```

### Assert directory exists

Pattern:

- With the default fs: `^there should be a directory "([^"]+)"$`
- With a fs at your choice: `^there should be a directory "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system)$`

```gherkin
Feature: Mixed

    Background:
        Given there should be a directory "test"
        And there should be a directory "test" in "mem" fs
```

### Assert file content

#### Plain Text

Pattern:

- With the default fs: `^there should be a file "([^"]+)" with content:`
- With a fs at your choice: `^there should be a file "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system) with content:`

```gherkin
Feature: Mixed

    Background:
        Given there should be a file "test/file2.sh" with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """

        And there should be a file "test/file2.sh" in "mem" fs with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """
```

#### Regexp

Pattern:

- With the default fs: `^there should be a file "([^"]+)" with content matches:`
- With a fs at your choice: `^there should be a file "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system) with content matches:`

```gherkin
Feature: Mixed

    Background:
        Given there should be a file "test/file2.sh" with content matches:
        """
        #!/usr/bin/env bash

        echo "<regexp:[^"]+/>"
        """

        And there should be a file "test/file2.sh" in "mem" fs with content matches:
        """
        #!/usr/bin/env bash

        echo "<regexp:[^"]+/>"
        """
```

### Assert file permission

Pattern:

- With the default fs: `^(?:file|directory) "([^"]+)" permission should be ([0-9]+)$`
- With a fs at your choice: `^(?:file|directory) "([^"]+)" permission in "([^"]+)" (?:fs|filesystem|file system) should be ([0-9]+)`

```gherkin
Feature: Mixed

    Background:
        Given directory "test" permission should be 0755
        And file "test/file2.sh" permission should be 0755
        And directory "test" permission in "mem" fs should be 0755
        And file "test/file2.sh" permission in "mem" fs should be 0755
```

### Assert file tree

#### Exact tree

Check whether the file tree is exactly the same as the expectation.

Pattern:

- With the current working directory:
    - With the default fs: `^there should be only these files:`
    - With a fs at your choice: `^there should be only these files in "([^"]+)" (?:fs|filesystem|file system):`
- With a path:
    - With the default fs: `^there should be only these files in "([^"]+)":`
    - With a fs at your choice: `^there should be only these files in "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system):`

```gherkin
Feature: Mixed

    Scenario: OS FS
        And there should be only these files:
        """
        - test 'perm:"0755"':
            - file1.txt 'perm:"0644"'
            - file2.sh 'perm:"0755"'
        """

    Scenario: Memory FS
        Then there should be only these files in "mem" fs:
        """
        - test 'perm:"0755"':
            - file1.txt
            - file2.sh 'perm:"0755"'
        """
```

#### Contains

Check whether the file tree contains the expectation.

Pattern:

- With the current working directory:
    - With the default fs: `^there should be these files:`
    - With a fs at your choice: `^there should be these files in "([^"]+)" (?:fs|filesystem|file system):`
- With a path:
    - With the default fs: `^there should be these files in "([^"]+)":`
    - With a fs at your choice: `^there should be these files in "([^"]+)" in "([^"]+)" (?:fs|filesystem|file system):`

```gherkin
Feature: Mixed

    Scenario: OS FS
        And there should be these files:
        """
        - test 'perm:"0755"':
            - file1.txt 'perm:"0644"'
            - file2.sh 'perm:"0755"'
        """

    Scenario: Memory FS
        Then there should be these files in "mem" fs:
        """
        - test 'perm:"0755"':
            - file1.txt
            - file2.sh 'perm:"0755"'
        """
```

## Variables

You can use these variables in your steps:

Variable | Description
:--- | :---
`$TEST_DIR` | The working directory where tests start
`$CWD` | Current working directory, get from `os.Getwd()`
`$WOKRING_DIR` | Same as `$CWD`

For examples:

```gherkin
    Scenario: .github equal in path
        Then there should be only these files in "$TEST_DIR/../../.github":
        """
        - workflows:
            - lint.yaml
            - test.yaml
        """
```

## Examples

Full suite: https://github.com/godogx/aferosteps/tree/master/features
