def retry_for(timeout, test)
  deadline = Time.now + timeout
  attempts = 0
  while Time.now < deadline
    attempts += 1
    result = yield
    if test.call(result)
      # puts "Succeeded with #{deadline - Time.now}s remaining"
      return result
    end
    sleep 0.5
  end
  fail "Gave up after #{timeout}s (made #{attempts} attempts)"
end
