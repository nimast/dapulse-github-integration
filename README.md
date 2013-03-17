## dapulse-github-integration
This is a sample code for a simple Sinatra service that write commit data from github into a Pulse using daPulse's Email API (http://support.dapulse.com/customer/portal/articles/784629-using-external-systems-to-email-your-pulse)

# Usage

1. Fork it.
2. Modify the tokens hash (line #21) and add the relevant people names and their pulse api tokens.
3. Modify the mail's *from* and *to* addresses (lines 46-47).
4. Publish the service (you can use Heroku for this purpose)
5. Add a WebHook on github pointing to your service
 
