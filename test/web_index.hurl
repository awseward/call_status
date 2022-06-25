GET {{base_url}}/
HTTP/* 200
[Asserts]
header "Content-Type" contains "text/html;"
header "Content-Type" contains "charset=utf-8"
