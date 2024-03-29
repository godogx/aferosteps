Feature: OS FS

    Background:
        Given current directory is temporary
        And there is a directory "test"
        And there is a file "test/file1.txt"
        And there is a file "test/file2.sh" with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """

        And file "test/file1.txt" permission is 0644
        And I change "test/file2.sh" permission to 0755

    Scenario: Basic Assertions
        Then there should be a directory "test"
        And there should be a file "test/file1.txt"
        And there should be a file "test/file2.sh" with content:
        """
        #!/usr/bin/env bash

        echo "hello"
        """

        And directory "test" permission should be 0755
        And file "test/file1.txt" permission should be 0644
        And file "test/file2.sh" permission should be 0755

    Scenario: Regexp Assertions
        And there should be a file "test/file2.sh" with content matches:
        """
        #!/usr/bin/env bash

        echo "<regexp:[^"]+/>"
        """

    Scenario: Tree Contains
        And there should be these files:
        """
        - test 'perm:"0755"':
            - file1.txt 'perm:"0644"'
            - file2.sh 'perm:"0755"'
        """

    Scenario: Tree Equal
        And there should be only these files:
        """
        - test 'perm:"0755"':
            - file1.txt 'perm:"0644"'
            - file2.sh 'perm:"0755"'
        """

    Scenario: .github contains
        When I reset current directory
        And I change current directory to "../.."

        Then there should be these files:
        """
        - .github:
            - workflows:
                - lint.yaml
                - test.yaml
            - dependabot.yml
        """

    Scenario: .github contains with cwd
        When I reset current directory
        And current directory is "../.."

        Then there should be these files:
        """
        - .github:
            - workflows:
                - lint.yaml
                - test.yaml
            - dependabot.yml
        """

    Scenario: .github contains in path
        When I reset current directory

        Then there should be these files in "../..":
        """
        - .github:
            - workflows:
                - lint.yaml
                - test.yaml
            - dependabot.yml
        """

    Scenario: .github contains in path
        When I reset current directory

        Then there should be these files in "../..":
        """
        - .github:
            - workflows:
                - lint.yaml
                - test.yaml
            - dependabot.yml
        """

    Scenario: .github equal
        When I reset current directory
        And I change current directory to "../../.github"

        Then there should be only these files:
        """
        - workflows:
            - lint.yaml
            - test.yaml
        - dependabot.yml
        """

    Scenario: .github equal with cwd
        When I reset current directory
        And current directory is "../../.github"

        Then there should be only these files:
        """
        - workflows:
            - lint.yaml
            - test.yaml
        - dependabot.yml
        """

    Scenario: .github equal in path
        Then there should be only these files in "$TEST_DIR/../../.github":
        """
        - workflows:
            - lint.yaml
            - test.yaml
        - dependabot.yml
        """
