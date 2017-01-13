Basically any webserver will do, but IIS is recommended (and used for this tutorial).

It must support the necessary authentication mechanism
- Windows Authentication recommend for simplicity
- Authentication mechanisms can be added by adding the role feature
-- "Server Manager > Roles > IIS", then scroll down to role features

Create a new site, define ports, https and certificate if required
Select a root folder for your website
Configure filesystem permissions
- All users of the shell need read permissions
- The account running the IIS application pool needs read permissions
- All developers who can upload code must have read/write permissions
- All users of the shell need write permission to their own userprofile (or you need to handle update submissions for user profiles, which is a mess)

The Webserver must be willing to offer PowerShell script files
- To configure that, open the site menu in the IIS administration console
- Configure "MIME-Types"
- Add a new MIME-Type
-- Extension: .üs1
-- Description: application/powershell

With this the webserver is ready to answer requests :)