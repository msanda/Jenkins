param([string]$filename)
#############CURL / BASH request
## curl (REST API)
## User
#JENKINS_USER=bitwisenote-jenkins1
#
## Api key from "/me/configure" on my Jenkins instance
#JENKINS_USER_KEY=--my secret, get your own--
#
## Url for my local Jenkins instance.
#JENKINS_URL=http://$JENKINS_USER:$JENKINS_USER_KEY@localhost:32769 
#
## JENKINS_CRUMB is needed if your Jenkins master has CRSF protection enabled (which it should)
#JENKINS_CRUMB=`curl "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"`
#curl -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<Jenkinsfile" $JENKINS_URL/pipeline-model-converter/validate
#
####################  Powershell Equivalent ###############
#
## 
## User
$JENKINS_USER="msanda"

# Api key from "/me/configure" on my Jenkins instance
$JENKINS_USER_KEY="bb14151f569b3b96bdee5ee7386f4a52"

$secPasswd = ConvertTo-SecureString $JENKINS_USER_KEY -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential($JENKINS_USER,$secPasswd)
# Url for my local Jenkins instance.
$JENKINS_URL="http://<localdocker>:32773" 


############ grab crumb header ########

##$headers    = $null
$headers    = @{} #create a dictionary 
$headers.Add("Authorization","Basic "+
  [System.Convert]::ToBase64String(
  [System.Text.Encoding]::ASCII.GetBytes("$($JENKINS_USER):$JENKINS_USER_KEY")))
 
$url         = "$($JENKINS_URL)/crumbIssuer/api/xml"
[xml]$crumbs = Invoke-WebRequest $url -Method GET  -Headers $headers
$crumbs.defaultCrumbIssuer.crumb
##
##$filecontent = [IO.File]::ReadAllText('C:\Users\msanda\Documents\jenkins_pipelines\build-automation-scripts\temp.txt')
$filecontent = [IO.File]::ReadAllText($filename)
$fields = @{'jenkinsfile'=$filecontent}

$headers.Add('Jenkins-Crumb',$crumbs.defaultCrumbIssuer.crumb)

Invoke-RestMethod -Method Post -Headers $headers -Uri $JENKINS_URL/pipeline-model-converter/validate -Body $fields;
