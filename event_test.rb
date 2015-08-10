require "selenium-webdriver"

userId = ARGV[0]
eventId = ARGV[1]
userEmail = ARGV[2]
key = ARGV[3]

chromeCapabilities = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {
  "args" => [
    "--disable-web-security",
    "--use-fake-ui-for-media-stream",
    "--mute-audio",
    "--user-data-dir=#{Dir.pwd}/chrome_profiles/user_#{userId}",
    "--use-fake-device-for-media-stream",
    "--use-file-for-fake-video-capture=#{Dir.pwd}/footage/converted/#{i}.y4m"
  ]
})
# chromeCapabilities["maxSessions=5"]
driver = Selenium::WebDriver.for :remote, url: "http://localhost:4444/wd/hub", desired_capabilities: chromeCapabilities

driver.manage.timeouts.implicit_wait = 10 # seconds
driver.get "http://faze-web.dev/e/#{eventId}"

# element = driver.execute_script("return document.body")
begin
  findLoginBtn = driver.find_elements(:class, 'btn-event-login')

  if !findLoginBtn.empty? && loginBtn = findLoginBtn.first
    loginBtn.click
    emailField = driver.find_element :id, 'email'
    emailField.send_keys user['email']
    passwordField = driver.find_element :id, 'password'
    passwordField.send_keys "demouser"
    submitBtn = driver.find_element :css, ".modal.login .btn-primary"
    submitBtn.click
  end

  #ALREADY LOGGED IN
  shortWait = Selenium::WebDriver::Wait.new(:timeout => 1) # seconds
  findMeetupBtn = shortWait.until { driver.find_elements :class, "btn-join-meetup" }
  findAlreadyChattedBtn = shortWait.until { driver.find_elements :class, "btn-already-chatted" }
  findEndChatBtn = shortWait.until { driver.find_elements :class, "btn-end-chat" }
  findLeaveLineBtn = shortWait.until { driver.find_elements :class, "btn-leave-line" }

  if !findMeetupBtn.empty? && meetupBtn = findMeetupBtn.first
    #NOT JOINED MEETUP YET
    puts " NOT YET JOINED THE MEETUP"
    meetupBtn.click
  elsif !findAlreadyChattedBtn.empty? && alreadyChattedBtn = findAlreadyChattedBtn.first
    #ALREADY CHATTED
    puts "ALREADY CHATTED"
  elsif !findEndChatBtn.empty? && endChatBtn = findEndChatBtn.first
    #NOW CHATTING
    puts "NOW CHATTING"

  elsif !findLeaveLineBtn.empty? && endChatBtn = findLeaveLineBtn.first
    #WAITING IN LINE
    puts "WAITING IN LINE"

  end


  puts driver.title

  driver.quit()
rescue Exception => e
  puts e.message
  puts e.backtrace.inspect
  driver.quit()
end
