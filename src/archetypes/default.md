+++
title = '{{ replace .Name "-" " " | title }}'
date = {{ .Date }}
type = 'Article'

disqus_identifier = '{{ md5 .Name }}'
## Optional, will use <title> tag value instead.
# disqus_title = ''
## Optional, will use window.location.href instead.
# disqus_url = ''

draft = true
+++
