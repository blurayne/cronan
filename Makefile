SHELL:=/bin/bash
.SHELLFLAGS=-c
.PHONY: clean

info:
	@echo Make shell: $$0
	SHELL=/bin/zsh
	@echo Make shell: $$0

clean:
	[ ! -d tmp ] && mkdir tmp || rm -f tmp/*

test-option-a: clean
	@echo -e "\nTesting Option -a"
	( ./cronan tests/stdout_exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -eq 0
	( ./cronan -a tests/stdout_exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -gt 0
	( ./cronan -a tests/exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( stat -c %s tmp/stdout ) -gt 0 && echo $$? > tmp/exitcode
	test $$( cat tmp/exitcode ) -eq 0
	grep -q EX_OK tmp/stdout
	grep -q "(empty)" tmp/stdout
	grep -vq "# STDERR" tmp/stdout
	( ./cronan -a tests/stdout_stderr_exit1 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 1
	test $$( stat -c %s tmp/stdout ) -gt 0
	grep -q "# STDERR" tmp/stdout
	grep -vq "HASERROR" tmp/stdout


test-option-x:
	@echo -e "\nTesting Option -x"
	( ./cronan -x -- tests/stdout_stderr_exit1 arg1 arg2 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -gt 0

test-options: test-option-a test-option-x


test-logs: clean
	@echo -e "\nTesting Logs"
	( ./cronan -o tmp/logout -e tmp/logerr tests/stdout_exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -eq 0
	test $$( stat -c %s tmp/logout ) -gt 0
	test $$( stat -c %s tmp/logerr ) -eq 0
	grep -q "\[CMD\] Exec: tests/stdout_exit0" tmp/logout
	grep -q "\[OUT\] HAS_OUTPUT1" tmp/logout
	grep -q "\[OUT\] HAS_OUTPUT2" tmp/logout
	grep -q "\[CMD\] Exit \[0\]" tmp/logout
	( ./cronan -o tmp/logout -e tmp/logerr tests/stdout_stderr_exit1 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 1
	test $$( stat -c %s tmp/stdout ) -gt 0
	test $$( stat -c %s tmp/logout ) -gt 0
	test $$( stat -c %s tmp/logerr ) -gt 0
	grep -q "Exec: tests/stdout_exit0" tmp/logout
	grep -q "\[CMD\] Exec: tests/stdout_exit0" tmp/logout
	grep -q "\[OUT\] HAS_OUTPUT1" tmp/logout
	grep -q "\[OUT\] HAS_OUTPUT2" tmp/logout
	grep -q "\[CMD\] Exit \[0\]" tmp/logout
	grep -q "# STDERR" tmp/stdout
	grep -q "# STDOUT" tmp/stdout
	grep -q "# EXITCODE" tmp/stdout
	grep -q "HAS_ERROR1" tmp/stdout
	grep -q "HAS_ERROR2" tmp/stdout
	grep -q "HAS_OUTPUT1" tmp/stdout
	grep -q "HAS_OUTPUT2" tmp/stdout
	grep -q "# EXITCODE" tmp/stdout
	grep -q "\[1\] general error" tmp/stdout

test-log-grows: clean
	@echo -e "\nTest for growing logs"
	( ./cronan -o tmp/logout tests/stdout_stderr_exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -eq 0
	test $$( stat -c %s tmp/logout ) -gt 0
	cat tmp/logout | wc -l > tmp/linecount
	( ./cronan -o tmp/logout tests/stdout_stderr_exit0 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	test $$( stat -c %s tmp/stdout ) -eq 0
	test $$( stat -c %s tmp/logout ) -gt 0
	test $$( cat tmp/logout | wc -l ) -gt $$( cat tmp/linecount )

test-command-not-found: clean
	@echo -e "\nTest for command not found"
	( ./cronan badcommand 1> tmp/stdout; echo $$? > tmp/exitcode)
	test $$( cat tmp/exitcode ) -eq 127
	test $$( stat -c %s tmp/stdout ) -gt 0
	grep -q "# STDERR" tmp/stdout
	grep -q "command not found" tmp/stdout
	( ./cronan tests/failure_stdout_exit0 1> tmp/stdout; echo $$? > tmp/exitcode)
	test $$( cat tmp/exitcode ) -eq 1
	test $$( stat -c %s tmp/stdout ) -gt 0
	grep -q "# STDERR" tmp/stdout
	grep -q "general error" tmp/stdout
	grep -q "command not found" tmp/stdout

test-command-args:
	@echo -e "\nTest for command args"
	( ./cronan -- true --arg1 --arg2 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	( ./cronan -- true --arg1 --arg2 1> tmp/stdout; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 0
	@echo -e "\nTest for command args"
	( ./cronan -o tmp/logout -- tests/stdout_stderr_exit1 -arg1 arg2 1> tmp/stdout 2> tmp/stderr; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 1
	test $$( stat -c %s tmp/stderr ) -eq 0
	test $$( stat -c %s tmp/logout ) -gt 0
	grep -q "\-arg1 arg2" tmp/stdout
	( ./cronan -o tmp/logout "tests/stdout_stderr_exit1 -arg1 arg2" 1> tmp/stdout 2> tmp/stderr; echo $$? > tmp/exitcode )
	test $$( stat -c %s tmp/stderr ) -eq 0
	test $$( cat tmp/exitcode ) -eq 1
	test $$( stat -c %s tmp/logout ) -gt 0
	grep -q "\-arg1 arg2" tmp/stdout
	( ./cronan -o tmp/logout tests/stdout_stderr_exit1 "-arg1 arg2" 1> tmp/stdout 2> tmp/stderr; echo $$? > tmp/exitcode )
	test $$( cat tmp/exitcode ) -eq 2
	test $$( stat -c %s tmp/stdout ) -eq 0
	test $$( stat -c %s tmp/stderr ) -gt 0
	grep -q "invalid arguments" tmp/stderr

test-commands: test-command-not-found test-command-args

test-sendmail: clean
	( ./cronan --to user@example.com tests/stdout_stderr_exit1; echo $$? > tmp/exitcode )

test-log: clean
	./cronan tests/exec_stderr_stdout_only -e tmp/

test: test-commands test-logs test-options test-sendmail
	@echo -e "\n\nAll tests passed"
