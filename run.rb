require "json"
require "selenium-webdriver"

processesToRun = ARGV[0]
eventToTest = ARGV[1]

puts "processes = #{processesToRun}"
puts "eventId = #{eventToTest}"
usersFile = File.read('users.json')
users = JSON.parse(usersFile)

thedir = Dir.pwd
spawns = []
processesToRun.to_i.times do |i|
  user = users[i]
  puts user
  userId = user['id']
  puts "userId=#{userId}"
  if i > 1
    sleep(5)
  end
  spawns << fork do
    # caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "--disable-web-security" ]})

    chromeCapabilities = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {
      "args" => [
        "--disable-web-security",
        "--use-fake-ui-for-media-stream",
        "--mute-audio",
        "--user-data-dir=#{Dir.pwd}/chrome_profiles/user_#{userId}",
        "--use-fake-device-for-media-stream"
      ]
    })
    chromeCapabilities["maxSessions=5"]
    driver = Selenium::WebDriver.for :remote, url: "http://localhost:4444/wd/hub", desired_capabilities: chromeCapabilities

    driver.manage.timeouts.implicit_wait = 5 # seconds
    driver.get "http://faze-web.dev/e/#{eventToTest}"

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
      findMeetupBtn = driver.find_elements :class, "btn-join-meetup"
      findAlreadyChattedBtn = driver.find_elements :class, "btn-already-chatted"
      findEndChatBtn = driver.find_elements :class, "btn-end-chat"
      findLeaveLineBtn = driver.find_elements :class, "btn-leave-line"

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

      sleep 1300
      # puts driver.title
      #
      driver.quit()
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      driver.quit()
    end
  end
end
Process.waitall
