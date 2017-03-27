title: Could not verify the SSL certificate
author: kakas
tags:
  - ruby
  - rails
categories:
  - 疑難雜症
date: 2016-10-31 22:10:00
---
今天想開一個新專案的時候，一直出現 `Could not verify the SSL certificate`，如下：

```shell
run  bundle install
Fetching source index from https://rubygems.org/
Retrying fetcher due to error (2/4): Bundler::Fetcher::CertificateFailureError Could not verify the SSL certificate for https://rubygems.org/.
There is a chance you are experiencing a man-in-the-middle attack, but most likely your system doesn't have the CA certificates needed for verification. For information about OpenSSL certificates, see http://bit.ly/ruby-ssl. To connect without using SSL, edit your Gemfile sources and change 'https' to 'http'.
Retrying fetcher due to error (3/4): Bundler::Fetcher::CertificateFailureError Could not verify the SSL certificate for https://rubygems.org/.
There is a chance you are experiencing a man-in-the-middle attack, but most likely your system doesn't have the CA certificates needed for verification. For information about OpenSSL certificates, see http://bit.ly/ruby-ssl. To connect without using SSL, edit your Gemfile sources and change 'https' to 'http'.
Retrying fetcher due to error (4/4): Bundler::Fetcher::CertificateFailureError Could not verify the SSL certificate for https://rubygems.org/.
There is a chance you are experiencing a man-in-the-middle attack, but most likely your system doesn't have the CA certificates needed for verification. For information about OpenSSL certificates, see http://bit.ly/ruby-ssl. To connect without using SSL, edit your Gemfile sources and change 'https' to 'http'.
Could not verify the SSL certificate for https://rubygems.org/.
There is a chance you are experiencing a man-in-the-middle attack, but most
likely your system doesn't have the CA certificates needed for verification. For
information about OpenSSL certificates, see http://bit.ly/ruby-ssl. To connect
without using SSL, edit your Gemfile sources and change 'https' to 'http'.
```

爬了一整天的文都找不到解法，乾脆把所有的 openssl 全部砍掉重裝，結果就正常了，囧

1. $ brew uninstall --force openssl
2. $ brew install openssl