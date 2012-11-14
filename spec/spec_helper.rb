%w{kippt json}.each{ |lib| require lib}
%w{bulkippt}.each { |file| require File.join(File.dirname(__FILE__),"../lib", file)}
