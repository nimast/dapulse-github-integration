require 'json'

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'dapulse.com',
            :user_name            => 'sender@dapulse.com',
            :password             => 'burgul456',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

class GitPublisher < Sinatra::Base
  get '/' do
    'Hello World!'
  end

  post '/' do
    tokens = {
      'Person Name'    => '<api key>',
      'Another Person' => '<api key of another person>'
    }

    push = JSON.parse(params[:payload])
    repo_name = push['repository']['name']

    ref = push['ref'].gsub "refs/heads/", ""
    return unless ref == 'master'

    subject = "#{push['commits'].length} commits to #{repo_name} repo on branch #{ref}"

    body = "(#{push['repository']['url']})<br/><br/>"
    push['commits'].each do |commit|
      body = "#{body}<p>#{commit['author']['name']}: <a href='#{commit['url']}'>#{commit['message']}</a></p>"
    end
    token = tokens[push['commits'].last['author']['name']] || push['commits'].last['author']['name']
    
    body = "#{body}<br/><p>Compare with previous version:<br/> #{push['compare']}</p>"
    
    
    pulse_email_address = "pulse-<some-id>-#{token}@<your company slug>.dapulse.com"
    
    mail = Mail.new do
      from    'git.integration@yourcompany.com'
      to      pulse_email_address
      subject subject
      
      text_part do
        body body
      end
      
      html_part do
        content_type 'text/html; charset=UTF-8'
        body body
      end
    end
    mail.deliver!
  end
end
