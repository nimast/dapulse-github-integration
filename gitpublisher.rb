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

  def is_bitbucket(payload)
    @is_bitbucket ||= /bitbucket/ =~ payload['canon_url'] 
  end

  def repository_header(payload)
    if is_bitbucket payload
      return "(http://bitbucket.org#{payload['repository']['absolute_url']})<br/>"
    else
      return "(#{payload['repository']['url']})<br/><br/>"
    end
  end

  def commit_url(commit, payload)
    if is_bitbucket payload
      return "http://bitbucket.org#{payload['repository']['absolute_url']}commits/#{commit['raw_node']}"
    else
      return commit['url']
    end
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

    commiter_name = push['commits'].last['author']['name'] || push['commits'].last['author']

    body = repository_header(push)
    push['commits'].each do |commit|
      commit_url = commit_url(commit, push)
      body = "#{body}<p>#{commiter_name}: <a href='#{commit_url}'>#{commit['message']}</a></p>"
    end
    
    token = tokens[commiter_name]
    unless token 
      p "No token for user #{commiter_name}"
      return
    end
    
    unless is_bitbucket push
      body = "#{body}<br/><p>Compare with previous version:<br/> #{push['compare']}</p>"
    end
    
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
