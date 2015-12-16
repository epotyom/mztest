include mzteststart
# machinzone test task
# install and configure smokeping
class mzteststart {
  # https://en.wikipedia.org/wiki/List_of_most_popular_websites
  class { 'mztest':
    ssites => {
      'Google'    => 'google.com',
      'Facebook'  => 'facebook.com',
      'Youtube'   => 'youtube.com',
      'Baidu'     => 'baidu.com',
      'Yahoo'     => 'yahoo.com',
      'Amazon'    => 'amazon.com',
      'Wikipedia' => 'wikipedia.org',
      'TencentQQ' => 'qq.com',
      'Twitter'   => 'twitter.com',
    }
  }
}
